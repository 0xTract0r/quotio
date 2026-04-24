//
//  ProxyBridge.swift
//  Quotio - TCP Proxy Bridge for Connection Management
//
//  This proxy sits between CLI tools and CLIProxyAPI to solve the stale
//  connection issue. By forcing "Connection: close" on every request,
//  we prevent HTTP keep-alive connections from becoming stale after idle periods.
//
//  Additionally handles Model Fallback: when a virtual model is detected,
//  resolves it to real models and automatically retries on quota exhaustion.
//
//  Architecture:
//    CLI Tools → ProxyBridge (user port) → CLIProxyAPI (internal port)
//

import Foundation
import Darwin
import Network
import Security

// MARK: - Fallback Context

/// Context for tracking fallback state during request processing
struct FallbackContext: Sendable {
    let virtualModelName: String?
    let fallbackEntries: [FallbackEntry]
    let currentIndex: Int
    let originalBody: String
    let wasLoadedFromCache: Bool
    let attempts: [FallbackAttempt]
    let triedSanitization: Bool

    /// Whether this request has fallback enabled
    nonisolated var hasFallback: Bool { !fallbackEntries.isEmpty }

    /// Whether there are more fallbacks to try
    nonisolated var hasMoreFallbacks: Bool { currentIndex + 1 < fallbackEntries.count }

    /// Get next fallback context
    nonisolated func next() -> FallbackContext {
        FallbackContext(
            virtualModelName: virtualModelName,
            fallbackEntries: fallbackEntries,
            currentIndex: currentIndex + 1,
            originalBody: originalBody,
            wasLoadedFromCache: false,
            attempts: attempts,
            triedSanitization: false
        )
    }

    /// Append a new attempt entry
    nonisolated func appendingAttempt(_ attempt: FallbackAttempt) -> FallbackContext {
        FallbackContext(
            virtualModelName: virtualModelName,
            fallbackEntries: fallbackEntries,
            currentIndex: currentIndex,
            originalBody: originalBody,
            wasLoadedFromCache: wasLoadedFromCache,
            attempts: attempts + [attempt],
            triedSanitization: triedSanitization
        )
    }

    /// Mark that sanitization has been attempted for this context
    nonisolated func withSanitizationAttempted() -> FallbackContext {
        FallbackContext(
            virtualModelName: virtualModelName,
            fallbackEntries: fallbackEntries,
            currentIndex: currentIndex,
            originalBody: originalBody,
            wasLoadedFromCache: wasLoadedFromCache,
            attempts: attempts,
            triedSanitization: true
        )
    }

    /// Current fallback entry
    nonisolated var currentEntry: FallbackEntry? {
        guard currentIndex < fallbackEntries.count else { return nil }
        return fallbackEntries[currentIndex]
    }

    /// Empty context for non-fallback requests
    nonisolated static let empty = FallbackContext(
        virtualModelName: nil,
        fallbackEntries: [],
        currentIndex: 0,
        originalBody: "",
        wasLoadedFromCache: false,
        attempts: [],
        triedSanitization: false
    )
}

/// A lightweight TCP proxy that forwards requests to CLIProxyAPI while
/// ensuring fresh connections by forcing "Connection: close" on all requests.
@MainActor
@Observable
final class ProxyBridge {
    struct Target: Sendable {
        let host: String
        let port: UInt16
        let hostHeader: String
        let pathPrefix: String
        let usesTLS: Bool
        let verifySSL: Bool

        static func local(port: UInt16) -> Target {
            Target(
                host: "127.0.0.1",
                port: port,
                hostHeader: "127.0.0.1:\(port)",
                pathPrefix: "",
                usesTLS: false,
                verifySSL: true
            )
        }

        static func remote(baseURL: String, verifySSL: Bool) throws -> Target {
            guard let url = URL(string: baseURL),
                  let scheme = url.scheme?.lowercased(),
                  RemoteURLValidator.supportedSchemes.contains(scheme),
                  let host = url.host,
                  !host.isEmpty else {
                throw ProxyBridgeError.invalidRemoteTarget
            }

            let portValue = url.port ?? (scheme == "https" ? 443 : 80)
            guard let port = UInt16(exactly: portValue) else {
                throw ProxyBridgeError.invalidRemoteTarget
            }
            let pathPrefix = url.path == "/" ? "" : url.path
            let hostHeader = url.port == nil ? host : "\(host):\(port)"

            return Target(
                host: host,
                port: port,
                hostHeader: hostHeader,
                pathPrefix: pathPrefix,
                usesTLS: scheme == "https",
                verifySSL: verifySSL
            )
        }

        func forwardingPath(for path: String) -> String {
            guard !pathPrefix.isEmpty else { return path }
            let normalizedPath = path.hasPrefix("/") ? path : "/" + path
            return pathPrefix + normalizedPath
        }
    }

    enum ProxyBridgeError: LocalizedError {
        case invalidRemoteTarget

        var errorDescription: String? {
            switch self {
            case .invalidRemoteTarget:
                return "Invalid remote relay target"
            }
        }
    }
    
    // MARK: - Properties
    
    private var listener: NWListener?
    private var socketRelayListener: SocketHTTPRelayListener?
    private let stateQueue = DispatchQueue(label: "dev.quotio.desktop.proxy-bridge-state")
    
    /// The port this proxy listens on (user-facing port)
    private(set) var listenPort: UInt16 = 8080

    /// Optional bind host for local-only relay exposure.
    private(set) var listenHost: NWEndpoint.Host?
    
    /// The port CLIProxyAPI runs on (internal port)
    private(set) var targetPort: UInt16 = 18080

    /// Target endpoint for forwarded client traffic.
    private(set) var target = Target.local(port: 18080)
    
    /// Whether the proxy bridge is currently running
    private(set) var isRunning = false
    
    /// Last error message
    private(set) var lastError: String?
    
    /// Statistics: total requests forwarded
    private(set) var totalRequests: Int = 0
    
    /// Statistics: active connections count
    private(set) var activeConnections: Int = 0
    
    /// Maximum concurrent connections to prevent resource exhaustion
    private let maxActiveConnections = 100
    
    /// Connection timeout in seconds (for target connection setup)
    private let connectionTimeoutSeconds: UInt64 = 10
    
    /// Callback for request metadata extraction (for RequestTracker)
    var onRequestCompleted: ((RequestMetadata) -> Void)?
    
    // MARK: - Request Metadata

    /// Metadata extracted from proxied requests
    struct RequestMetadata: Sendable {
        let timestamp: Date
        let method: String
        let path: String
        let provider: String?
        let model: String?
        let resolvedModel: String?  // Actual model used after fallback resolution
        let resolvedProvider: String?  // Actual provider used after fallback resolution
        let statusCode: Int?
        let durationMs: Int
        let requestSize: Int
        let responseSize: Int
        let fallbackAttempts: [FallbackAttempt]
        let fallbackStartedFromCache: Bool
        let responseSnippet: String?
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Configuration
    
    /// Configure the proxy ports
    /// - Parameters:
    ///   - listenPort: The port to listen on (user-facing)
    ///   - targetPort: The port CLIProxyAPI runs on
    func configure(listenPort: UInt16, targetPort: UInt16) {
        self.listenPort = listenPort
        self.listenHost = nil
        self.targetPort = targetPort
        self.target = .local(port: targetPort)
    }

    /// Configure this bridge to expose a local client port backed by a remote core.
    func configureRemote(listenPort: UInt16, remoteBaseURL: String, verifySSL: Bool) throws {
        guard let loopback = IPv4Address("127.0.0.1") else {
            throw ProxyBridgeError.invalidRemoteTarget
        }

        self.listenPort = listenPort
        self.listenHost = .ipv4(loopback)
        self.target = try .remote(baseURL: remoteBaseURL, verifySSL: verifySSL)
        self.targetPort = target.port
    }
    
    /// Calculate internal port from user port (offset by 10000)
    /// This is nonisolated so it can be called from static contexts
    nonisolated static func internalPort(from userPort: UInt16) -> UInt16 {
        // Use offset of 10000, but cap at valid port range
        // For high ports (55536+), use a smaller offset to stay within valid range
        let preferredPort = UInt32(userPort) + 10000
        if preferredPort <= 65535 {
            return UInt16(preferredPort)
        }
        // Fallback: use modular offset within high port range (49152-65535)
        let highPortBase: UInt16 = 49152
        let offset = userPort % 1000
        return highPortBase + offset
    }
    
    // MARK: - Lifecycle
    
    /// Starts the proxy bridge
    func start() {
        guard !isRunning else {
            return
        }

        lastError = nil

        do {
            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true

            guard let port = NWEndpoint.Port(rawValue: listenPort) else {
                lastError = "Invalid port: \(listenPort)"
                return
            }

            if let listenHost {
                parameters.requiredLocalEndpoint = .hostPort(host: listenHost, port: port)
                listener = try NWListener(using: parameters)
            } else {
                listener = try NWListener(using: parameters, on: port)
            }

            listener?.stateUpdateHandler = { [weak self] state in
                guard let weakSelf = self else { return }
                Task { @MainActor in
                    weakSelf.handleListenerState(state)
                }
            }

            listener?.newConnectionHandler = { [weak self] connection in
                guard let weakSelf = self else { return }
                Task { @MainActor in
                    weakSelf.handleNewConnection(connection)
                }
            }

            listener?.start(queue: .global(qos: .userInitiated))

        } catch {
            lastError = error.localizedDescription
            startSocketRelayFallback(reason: error.localizedDescription)
        }
    }

    /// Stops the proxy bridge
    func stop() {
        stateQueue.sync {
            listener?.cancel()
            listener = nil
            socketRelayListener?.cancel()
            socketRelayListener = nil
        }

        isRunning = false
    }
    
    // MARK: - State Handling

    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .ready:
            isRunning = true
            lastError = nil
        case .failed(let error):
            isRunning = false
            lastError = error.localizedDescription
            listener?.cancel()
            listener = nil
            startSocketRelayFallback(reason: error.localizedDescription)
        case .cancelled:
            isRunning = socketRelayListener != nil
        default:
            break
        }
    }

    private func startSocketRelayFallback(reason: String) {
        // Only remote-relay config sets a local-only listenHost. Keep the local proxy bridge
        // on its existing NWListener path so fallback does not change local-mode semantics.
        guard listenHost != nil, socketRelayListener == nil else { return }

        do {
            let fallback = try SocketHTTPRelayListener(
                listenHost: "127.0.0.1",
                listenPort: listenPort,
                target: target
            )
            fallback.onConnectionAccepted = { [weak self] in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.totalRequests += 1
                    self.activeConnections += 1
                }
            }
            fallback.onConnectionClosed = { [weak self] in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.activeConnections = max(0, self.activeConnections - 1)
                }
            }
            fallback.start()
            socketRelayListener = fallback
            isRunning = true
            lastError = nil
            NSLog("[ProxyBridge] NWListener failed (\(reason)); using socket HTTP relay fallback on 127.0.0.1:\(listenPort)")
        } catch {
            lastError = "\(reason); socket relay fallback failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Connection Handling

    private func handleNewConnection(_ connection: NWConnection) {
        if activeConnections >= maxActiveConnections {
            connection.cancel()
            return
        }

        activeConnections += 1
        totalRequests += 1

        let connectionId = totalRequests
        let startTime = Date()

        connection.stateUpdateHandler = { [weak self] state in
            guard let weakSelf = self else { return }
            if case .cancelled = state {
                Task { @MainActor in
                    weakSelf.activeConnections -= 1
                }
            } else if case .failed = state {
                Task { @MainActor in
                    weakSelf.activeConnections -= 1
                }
            }
        }
        
        connection.start(queue: .global(qos: .userInitiated))
        
        // Start receiving request
        receiveRequest(
            from: connection,
            connectionId: connectionId,
            startTime: startTime,
            accumulatedData: Data()
        )
    }
    
    // MARK: - Request Receiving (Iterative)
    
    /// Receives HTTP request data iteratively to avoid stack overflow
    private nonisolated func receiveRequest(
        from connection: NWConnection,
        connectionId: Int,
        startTime: Date,
        accumulatedData: Data
    ) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1048576) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }

            if error != nil {
                connection.cancel()
                return
            }
            
            guard let data = data, !data.isEmpty else {
                if isComplete {
                    connection.cancel()
                }
                return
            }
            
            var newData = accumulatedData
            newData.append(data)
            
            // Check if we have a complete HTTP request
            if let requestString = String(data: newData, encoding: .utf8),
               let headerEndRange = requestString.range(of: "\r\n\r\n") {
                
                let headerEndIndex = requestString.distance(from: requestString.startIndex, to: headerEndRange.upperBound)
                let headerPart = String(requestString.prefix(headerEndIndex))
                
                // Check Content-Length to determine if we have full body
                if let contentLengthLine = headerPart
                    .components(separatedBy: "\r\n")
                    .first(where: { $0.lowercased().hasPrefix("content-length:") }) {
                    
                    let headerParts = contentLengthLine.components(separatedBy: ":")
                    guard headerParts.count > 1 else { return }
                    
                    let lengthStr = headerParts[1].trimmingCharacters(in: .whitespaces)
                    if let contentLength = Int(lengthStr) {
                        let currentBodyLength = newData.count - headerEndIndex
                        
                        // Need more data
                        if currentBodyLength < contentLength {
                            let nextData = newData
                            // Use async dispatch to break recursion stack
                            DispatchQueue.global(qos: .userInitiated).async {
                                self.receiveRequest(
                                    from: connection,
                                    connectionId: connectionId,
                                    startTime: startTime,
                                    accumulatedData: nextData
                                )
                            }
                            return
                        }
                    }
                }
                
                // Complete request - process it
                self.processRequest(
                    data: newData,
                    connection: connection,
                    connectionId: connectionId,
                    startTime: startTime
                )
                
            } else if !isComplete {
                // Haven't found header end yet, continue receiving
                // Use async dispatch to break recursion stack
                let nextData = newData
                DispatchQueue.global(qos: .userInitiated).async {
                    self.receiveRequest(
                        from: connection,
                        connectionId: connectionId,
                        startTime: startTime,
                        accumulatedData: nextData
                    )
                }
            } else {
                // Complete but malformed
                self.processRequest(
                    data: newData,
                    connection: connection,
                    connectionId: connectionId,
                    startTime: startTime
                )
            }
        }
    }
    
    // MARK: - Request Processing

    private nonisolated func processRequest(
        data: Data,
        connection: NWConnection,
        connectionId: Int,
        startTime: Date
    ) {
        guard let requestString = String(data: data, encoding: .utf8) else {
            sendError(to: connection, statusCode: 400, message: "Invalid request encoding")
            return
        }

        // Parse HTTP request line
        let lines = requestString.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            sendError(to: connection, statusCode: 400, message: "Missing request line")
            return
        }

        let parts = requestLine.components(separatedBy: " ")
        guard parts.count >= 3 else {
            sendError(to: connection, statusCode: 400, message: "Invalid request format")
            return
        }

        let method = parts[0]
        let path = parts[1]
        let httpVersion = parts[2]

        // Collect headers
        var headers: [(String, String)] = []
        for line in lines.dropFirst() {
            if line.isEmpty { break }
            guard let colonIndex = line.firstIndex(of: ":") else { continue }
            let name = String(line[..<colonIndex]).trimmingCharacters(in: .whitespaces)
            let value = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
            headers.append((name, value))
        }

        // Extract body
        var body = ""
        if let bodyRange = requestString.range(of: "\r\n\r\n") {
            body = String(requestString[bodyRange.upperBound...])
        }

        let metadata = extractMetadata(method: method, path: path, body: body)

        // Check for virtual model and create fallback context
        Task { @MainActor [weak self] in
            guard let self = self else { return }

            let fallbackContext = self.createFallbackContext(body: body)
            let resolvedBody: String

            if fallbackContext.hasFallback, let entry = fallbackContext.currentEntry {
                // Replace model in body with resolved model
                resolvedBody = self.replaceModelInBody(body, with: entry.modelId)
            } else {
                resolvedBody = body
            }

            let targetValue = self.target

            self.forwardRequest(
                method: method,
                path: path,
                version: httpVersion,
                headers: headers,
                body: resolvedBody,
                originalConnection: connection,
                connectionId: connectionId,
                startTime: startTime,
                requestSize: data.count,
                metadata: metadata,
                target: targetValue,
                fallbackContext: fallbackContext
            )
        }
    }

    // MARK: - Fallback Support

    /// Create fallback context if the request uses a virtual model
    private func createFallbackContext(body: String) -> FallbackContext {
        let settings = FallbackSettingsManager.shared

        // Check if fallback is enabled
        guard settings.isEnabled else {
            return .empty
        }

        // Extract model from body
        guard let bodyData = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
              let model = json["model"] as? String else {
            return .empty
        }

        // Check if this is a virtual model
        guard settings.isVirtualModel(model) else {
            return .empty
        }

        guard let virtualModel = settings.findVirtualModel(name: model) else {
            return .empty
        }

        let entries = virtualModel.sortedEntries
        guard !entries.isEmpty else {
            return .empty
        }

        // Get cached entry ID and find its current index (handles reordering correctly)
        var startIndex = 0
        var wasLoadedFromCache = false
        if let cachedEntryId = settings.getCachedEntryId(for: model) {
            if let cachedIndex = entries.firstIndex(where: { $0.id == cachedEntryId }) {
                startIndex = cachedIndex
                wasLoadedFromCache = true
            }
        }

        var attempts: [FallbackAttempt] = []
        if wasLoadedFromCache, startIndex < entries.count {
            let cachedEntry = entries[startIndex]
            attempts.append(FallbackAttempt(entry: cachedEntry, outcome: .skipped, reason: .cachedRoute))
        }

        return FallbackContext(
            virtualModelName: model,
            fallbackEntries: entries,
            currentIndex: startIndex,
            originalBody: body,
            wasLoadedFromCache: wasLoadedFromCache,
            attempts: attempts,
            triedSanitization: false
        )
    }

    // MARK: - Request Body Transformation

    private nonisolated func replaceModelInBody(
        _ body: String,
        with newModel: String
    ) -> String {
        guard let bodyData = body.data(using: .utf8),
              var json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
              json["model"] != nil else {
            return body
        }

        json["model"] = newModel

        guard let newData = try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys]),
              let newBody = String(data: newData, encoding: .utf8) else {
            return body
        }

        return newBody
    }

    private nonisolated func sanitizeThinkingBlocks(_ body: String, targetModelId: String) -> String {
        guard let bodyData = body.data(using: .utf8),
              var json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
              var messages = json["messages"] as? [[String: Any]] else {
            return body
        }

        var modified = false

        for i in messages.indices {
            guard let content = messages[i]["content"] as? [[String: Any]] else { continue }

            let filteredContent = content.filter { block in
                guard let blockType = block["type"] as? String else { return true }
                if blockType == "thinking" || blockType == "redacted_thinking" {
                    modified = true
                    return false
                }
                return true
            }

            if filteredContent.count != content.count {
                if filteredContent.isEmpty {
                    messages[i]["content"] = [["type": "text", "text": "[reasoning omitted]"]]
                } else {
                    messages[i]["content"] = filteredContent
                }
            }
        }

        guard modified else { return body }

        json["messages"] = messages
        json["model"] = targetModelId

        guard let newData = try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys]),
              let newBody = String(data: newData, encoding: .utf8) else {
            return body
        }

        return newBody
    }

    /// Check why a response should trigger fallback (if any)
    private nonisolated func fallbackReason(responseData: Data) -> FallbackTriggerReason? {
        return FallbackFormatConverter.fallbackReason(responseData: responseData)
    }

    private nonisolated func responseBodySnippet(from responseData: Data, limit: Int = 512) -> String? {
        guard let responseString = String(data: responseData.prefix(4096), encoding: .utf8) else {
            return nil
        }
        let parts = responseString.components(separatedBy: "\r\n\r\n")
        let body = parts.dropFirst().joined(separator: "\r\n\r\n").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else {
            return nil
        }
        return String(body.prefix(limit))
    }
    
    // MARK: - Metadata Extraction
    
    private nonisolated func extractMetadata(method: String, path: String, body: String) -> (provider: String?, model: String?, method: String, path: String) {
        // Detect provider from path
        var provider: String?
        if path.contains("/anthropic/") || path.contains("/claude") {
            provider = "claude"
        } else if path.contains("/gemini/") || path.contains("/google/") {
            provider = "gemini"
        } else if path.contains("/openai/") || path.contains("/chat/completions") {
            provider = "openai"
        } else if path.contains("/copilot/") {
            provider = "copilot"
        } else if path.contains("codewhisperer") || path.contains("kiro") {
            provider = "kiro"
        }
        
        // Extract model from JSON body
        var model: String?
        if let bodyData = body.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
           let modelValue = json["model"] as? String {
            model = modelValue
            
            // Infer provider from model name if not already detected
            if provider == nil {
                if FallbackFormatConverter.isClaudeModel(modelValue) {
                    provider = "claude"
                } else if modelValue.hasPrefix("gemini") || modelValue.hasPrefix("models/gemini") {
                    provider = "gemini"
                } else if modelValue.hasPrefix("gpt") || modelValue.hasPrefix("o1") || modelValue.hasPrefix("o3") {
                    provider = "openai"
                } else if modelValue.contains("kiro") || modelValue.contains("codewhisperer") {
                    provider = "kiro"
                }
            }
        }
        
        return (provider, model, method, path)
    }
    
    // MARK: - Request Forwarding

    private nonisolated func makeTLSOptions(for target: Target) -> NWProtocolTLS.Options? {
        guard target.usesTLS else { return nil }

        let options = NWProtocolTLS.Options()
        target.host.withCString { serverName in
            sec_protocol_options_set_tls_server_name(options.securityProtocolOptions, serverName)
        }

        if !target.verifySSL {
            sec_protocol_options_set_verify_block(
                options.securityProtocolOptions,
                { _, _, complete in
                    complete(true)
                },
                DispatchQueue.global(qos: .userInitiated)
            )
        }

        return options
    }

    private nonisolated func forwardRequest(
        method: String,
        path: String,
        version: String,
        headers: [(String, String)],
        body: String,
        originalConnection: NWConnection,
        connectionId: Int,
        startTime: Date,
        requestSize: Int,
        metadata: (provider: String?, model: String?, method: String, path: String),
        target: Target,
        fallbackContext: FallbackContext
    ) {
        // Create connection to CLIProxyAPI
        guard let port = NWEndpoint.Port(rawValue: target.port) else {
            sendError(to: originalConnection, statusCode: 500, message: "Invalid target port")
            return
        }

        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(target.host), port: port)

        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.enableKeepalive = true
        tcpOptions.keepaliveIdle = 30
        tcpOptions.keepaliveInterval = 5
        tcpOptions.keepaliveCount = 3
        let tlsOptions = makeTLSOptions(for: target)
        let parameters = NWParameters(tls: tlsOptions, tcp: tcpOptions)

        let targetConnection = NWConnection(to: endpoint, using: parameters)

        let timeoutSeconds = self.connectionTimeoutSeconds

        // Use class-based wrapper for thread-safe cancellation flag
        final class TimeoutState: @unchecked Sendable {
            var cancelled = false
        }
        let timeoutState = TimeoutState()

        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(Int(timeoutSeconds))) { [weak targetConnection] in
            guard !timeoutState.cancelled else { return }
            guard let conn = targetConnection, conn.state != .ready else { return }
            conn.cancel()
        }

        // Capture for closure
        let capturedFallbackContext = fallbackContext
        let capturedHeaders = headers
        let capturedMethod = method
        let capturedPath = target.forwardingPath(for: path)
        let capturedVersion = version

        targetConnection.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .ready:
                timeoutState.cancelled = true
                // Build forwarded request with Connection: close
                var forwardedRequest = "\(capturedMethod) \(capturedPath) \(capturedVersion)\r\n"

                // Forward headers, excluding ones we'll override or that break error detection
                let excludedHeaders: Set<String> = ["connection", "content-length", "host", "transfer-encoding", "accept-encoding"]
                for (name, value) in capturedHeaders {
                    if !excludedHeaders.contains(name.lowercased()) {
                        forwardedRequest += "\(name): \(value)\r\n"
                    }
                }

                // Add our headers
                forwardedRequest += "Host: \(target.hostHeader)\r\n"
                forwardedRequest += "Connection: close\r\n"  // KEY: Force fresh connections
                forwardedRequest += "Content-Length: \(body.utf8.count)\r\n"
                forwardedRequest += "\r\n"
                forwardedRequest += body

                guard let requestData = forwardedRequest.data(using: .utf8) else {
                    self.sendError(to: originalConnection, statusCode: 500, message: "Failed to encode request")
                    targetConnection.cancel()
                    return
                }

                targetConnection.send(content: requestData, completion: .contentProcessed { error in
                    if error != nil {
                        targetConnection.cancel()
                        originalConnection.cancel()
                    } else {
                        // Start receiving response
                        self.receiveResponse(
                            from: targetConnection,
                            to: originalConnection,
                            connectionId: connectionId,
                            startTime: startTime,
                            requestSize: requestSize,
                            metadata: metadata,
                            responseData: Data(),
                            fallbackContext: capturedFallbackContext,
                            headers: capturedHeaders,
                            method: capturedMethod,
                            path: capturedPath,
                            version: capturedVersion,
                            target: target
                        )
                    }
                })

            case .failed:
                timeoutState.cancelled = true
                self.sendError(to: originalConnection, statusCode: 502, message: "Bad Gateway - Cannot connect to proxy")
                targetConnection.cancel()

            default:
                break
            }
        }

        targetConnection.start(queue: .global(qos: .userInitiated))
    }
    
    // MARK: - Response Streaming (Iterative)

    private nonisolated func receiveResponse(
        from targetConnection: NWConnection,
        to originalConnection: NWConnection,
        connectionId: Int,
        startTime: Date,
        requestSize: Int,
        metadata: (provider: String?, model: String?, method: String, path: String),
        responseData: Data,
        fallbackContext: FallbackContext,
        headers: [(String, String)],
        method: String,
        path: String,
        version: String,
        target: Target
    ) {
        targetConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }

            if error != nil {
                targetConnection.cancel()
                originalConnection.cancel()
                return
            }

            // Use let to avoid captured var warning - Data is already accumulated via parameter
            let accumulatedResponse: Data
            if let data = data, !data.isEmpty {
                var newAccumulated = responseData
                newAccumulated.append(data)
                accumulatedResponse = newAccumulated
            } else {
                accumulatedResponse = responseData
            }

            // Check for quota exceeded BEFORE forwarding to client (within first 4KB to catch streaming errors)
            let quotaCheckThreshold = 4096
            if accumulatedResponse.count <= quotaCheckThreshold && !accumulatedResponse.isEmpty && fallbackContext.hasFallback {
                let fallbackReason = self.fallbackReason(responseData: accumulatedResponse)

                // Check for thinking signature errors - retry same provider with sanitized body
                if fallbackReason != nil {
                    let isSignatureError = FallbackFormatConverter.isThinkingSignatureError(responseData: accumulatedResponse)

                    if isSignatureError && !fallbackContext.triedSanitization,
                       let currentEntry = fallbackContext.currentEntry {
                        let sanitizedBody = self.sanitizeThinkingBlocks(fallbackContext.originalBody, targetModelId: currentEntry.modelId)

                        if sanitizedBody != fallbackContext.originalBody {
                            targetConnection.cancel()
                            let retryContext = fallbackContext.withSanitizationAttempted()

                            self.forwardRequest(
                                method: method,
                                path: path,
                                version: version,
                                headers: headers,
                                body: sanitizedBody,
                                originalConnection: originalConnection,
                                connectionId: connectionId,
                                startTime: startTime,
                                requestSize: requestSize,
                                metadata: metadata,
                                target: target,
                                fallbackContext: retryContext
                            )
                            return
                        }
                    }
                }

                if let reason = fallbackReason, fallbackContext.hasMoreFallbacks {
                    // Don't forward error to client, try next fallback instead
                    targetConnection.cancel()

                    // Try next fallback
                    let updatedContext: FallbackContext
                    if let failedEntry = fallbackContext.currentEntry {
                        let failedAttempt = FallbackAttempt(entry: failedEntry, outcome: .failed, reason: reason)
                        updatedContext = fallbackContext.appendingAttempt(failedAttempt)
                    } else {
                        updatedContext = fallbackContext
                    }
                    let nextContext = updatedContext.next()
                    if let nextEntry = nextContext.currentEntry,
                       let virtualModelName = nextContext.virtualModelName {

                        // Update route state for UI display (cache is only updated on success)
                        Task { @MainActor in
                            let settings = FallbackSettingsManager.shared
                            settings.updateRouteState(
                                virtualModelName: virtualModelName,
                                entryIndex: nextContext.currentIndex,
                                entry: nextEntry,
                                totalEntries: nextContext.fallbackEntries.count
                            )
                        }

                        let nextBody = self.replaceModelInBody(fallbackContext.originalBody, with: nextEntry.modelId)

                        self.forwardRequest(
                            method: method,
                            path: path,
                            version: version,
                            headers: headers,
                            body: nextBody,
                            originalConnection: originalConnection,
                            connectionId: connectionId,
                            startTime: startTime,
                            requestSize: requestSize,
                            metadata: metadata,
                            target: target,
                            fallbackContext: nextContext
                        )
                    }
                    return
                }
            }

            if let data = data, !data.isEmpty {
                // Forward chunk to client
                originalConnection.send(content: data, completion: .contentProcessed { sendError in
                    if isComplete {
                        // Request complete - record metadata
                        self.recordCompletion(
                            connectionId: connectionId,
                            startTime: startTime,
                            requestSize: requestSize,
                            responseSize: accumulatedResponse.count,
                            responseData: accumulatedResponse,
                            metadata: metadata,
                            fallbackContext: fallbackContext
                        )

                        targetConnection.cancel()
                        originalConnection.send(content: nil, isComplete: true, completion: .contentProcessed { _ in
                            originalConnection.cancel()
                        })
                    } else {
                        // Continue streaming - use async dispatch to break recursion stack
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.receiveResponse(
                                from: targetConnection,
                                to: originalConnection,
                                connectionId: connectionId,
                                startTime: startTime,
                                requestSize: requestSize,
                                metadata: metadata,
                                responseData: accumulatedResponse,
                                fallbackContext: fallbackContext,
                                headers: headers,
                                method: method,
                                path: path,
                                version: version,
                                target: target
                            )
                        }
                    }
                })
            } else if isComplete {
                // Record completion
                self.recordCompletion(
                    connectionId: connectionId,
                    startTime: startTime,
                    requestSize: requestSize,
                    responseSize: accumulatedResponse.count,
                    responseData: accumulatedResponse,
                    metadata: metadata,
                    fallbackContext: fallbackContext
                )

                targetConnection.cancel()
                originalConnection.send(content: nil, isComplete: true, completion: .contentProcessed { _ in
                    originalConnection.cancel()
                })
            }
        }
    }
    
    // MARK: - Completion Recording

    private nonisolated func recordCompletion(
        connectionId: Int,
        startTime: Date,
        requestSize: Int,
        responseSize: Int,
        responseData: Data,
        metadata: (provider: String?, model: String?, method: String, path: String),
        fallbackContext: FallbackContext
    ) {
        let durationMs = Int(Date().timeIntervalSince(startTime) * 1000)

        // Extract status code from response
        var statusCode: Int?
        if let responseString = String(data: responseData.prefix(100), encoding: .utf8),
           let statusLine = responseString.components(separatedBy: "\r\n").first {
            // Parse "HTTP/1.1 200 OK"
            let parts = statusLine.components(separatedBy: " ")
            if parts.count >= 2, let code = Int(parts[1]) {
                statusCode = code
            }
        }

        // Capture variables for Sendable closure
        let capturedStatusCode = statusCode
        let capturedMetadata = metadata

        // Extract resolved model/provider from fallback context
        let resolvedModel: String? = fallbackContext.currentEntry?.modelId
        let resolvedProvider: String? = fallbackContext.currentEntry?.provider.rawValue

        let finalReason: FallbackTriggerReason?
        if let statusCode = statusCode, !(200..<300).contains(statusCode) {
            finalReason = fallbackReason(responseData: responseData) ?? .httpStatus(statusCode)
        } else {
            finalReason = nil
        }

        var attempts = fallbackContext.attempts
        if fallbackContext.hasFallback,
           (fallbackContext.wasLoadedFromCache ||
            fallbackContext.currentIndex > 0 ||
            !attempts.isEmpty ||
            finalReason != nil),
           let entry = fallbackContext.currentEntry {
            let outcome: FallbackAttemptOutcome = finalReason == nil ? .success : .failed
            let finalAttempt = FallbackAttempt(entry: entry, outcome: outcome, reason: finalReason)
            attempts.append(finalAttempt)
        }

        let responseSnippet: String? = finalReason == nil ? nil : responseBodySnippet(from: responseData)

        // Notify callback on main thread
        Task { @MainActor [weak self] in
            // Cache successful entry ONLY if:
            // 1. Response is successful (HTTP 2xx)
            // 2. Fallback was actually triggered (currentIndex > 0)
            // 3. Entry was NOT loaded from cache (wasLoadedFromCache == false)
            if let statusCode = capturedStatusCode, (200..<300).contains(statusCode),
               fallbackContext.currentIndex > 0,
               !fallbackContext.wasLoadedFromCache,
               let virtualModelName = fallbackContext.virtualModelName,
               let currentEntry = fallbackContext.currentEntry {
                let settings = FallbackSettingsManager.shared
                settings.setCachedEntryId(for: virtualModelName, entryId: currentEntry.id)
                settings.updateRouteState(
                    virtualModelName: virtualModelName,
                    entryIndex: fallbackContext.currentIndex,
                    entry: currentEntry,
                    totalEntries: fallbackContext.fallbackEntries.count
                )
            }

            let requestMetadata = RequestMetadata(
                timestamp: startTime,
                method: capturedMetadata.method,
                path: capturedMetadata.path,
                provider: capturedMetadata.provider,
                model: capturedMetadata.model,
                resolvedModel: resolvedModel,
                resolvedProvider: resolvedProvider,
                statusCode: capturedStatusCode,
                durationMs: durationMs,
                requestSize: requestSize,
                responseSize: responseSize,
                fallbackAttempts: attempts,
                fallbackStartedFromCache: fallbackContext.wasLoadedFromCache,
                responseSnippet: responseSnippet
            )
            self?.onRequestCompleted?(requestMetadata)
        }
    }
    
    // MARK: - Error Response
    
    private nonisolated func sendError(to connection: NWConnection, statusCode: Int, message: String) {
        guard let bodyData = message.data(using: .utf8) else {
            connection.cancel()
            return
        }
        
        // Map status code to proper HTTP reason phrase
        let reasonPhrase: String
        switch statusCode {
        case 400: reasonPhrase = "Bad Request"
        case 404: reasonPhrase = "Not Found"
        case 500: reasonPhrase = "Internal Server Error"
        case 502: reasonPhrase = "Bad Gateway"
        case 503: reasonPhrase = "Service Unavailable"
        default: reasonPhrase = "Error"
        }
        
        // Build HTTP response with proper CRLF line endings (no leading whitespace)
        let headers = "HTTP/1.1 \(statusCode) \(reasonPhrase)\r\n" +
            "Content-Type: text/plain\r\n" +
            "Content-Length: \(bodyData.count)\r\n" +
            "Connection: close\r\n" +
            "\r\n"
        
        guard let headerData = headers.data(using: .utf8) else {
            connection.cancel()
            return
        }
        
        var responseData = Data()
        responseData.append(headerData)
        responseData.append(bodyData)
        
        connection.send(content: responseData, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
}

private final class SocketHTTPRelayListener: @unchecked Sendable {
    private let listenHost: String
    private let listenPort: UInt16
    private let target: ProxyBridge.Target
    private let queue = DispatchQueue(label: "dev.quotio.desktop.socket-http-relay-listener")
    private var listenSocket: Int32 = -1
    private var source: DispatchSourceRead?
    private let activeConnectionsLock = NSLock()
    private var activeConnections: [UUID: SocketHTTPRelayConnection] = [:]

    var onConnectionAccepted: (@Sendable () -> Void)?
    var onConnectionClosed: (@Sendable () -> Void)?

    init(listenHost: String, listenPort: UInt16, target: ProxyBridge.Target) throws {
        self.listenHost = listenHost
        self.listenPort = listenPort
        self.target = target
        self.listenSocket = try Self.makeListenSocket(host: listenHost, port: listenPort)
    }

    deinit {
        cancel()
    }

    func start() {
        let readSource = DispatchSource.makeReadSource(fileDescriptor: listenSocket, queue: queue)
        readSource.setEventHandler { [weak self] in
            self?.acceptAvailableConnections()
        }
        readSource.setCancelHandler { [socket = listenSocket] in
            if socket >= 0 {
                Darwin.close(socket)
            }
        }
        source = readSource
        readSource.resume()
    }

    func cancel() {
        source?.cancel()
        source = nil
        listenSocket = -1

        let connections = removeAllActiveConnections()
        for connection in connections {
            connection.cancel()
        }
    }

    private func acceptAvailableConnections() {
        while true {
            let clientSocket = Darwin.accept(listenSocket, nil, nil)
            if clientSocket < 0 {
                if errno == EAGAIN || errno == EWOULDBLOCK || errno == EINTR {
                    return
                }
                return
            }

            Self.configureClientSocket(clientSocket)
            onConnectionAccepted?()

            let connectionId = UUID()
            let connection = SocketHTTPRelayConnection(
                clientSocket: clientSocket,
                target: target,
                onClose: { [weak self] in
                    self?.removeActiveConnection(id: connectionId)
                    self?.onConnectionClosed?()
                }
            )
            storeActiveConnection(id: connectionId, connection: connection)
            connection.start()
        }
    }

    private func storeActiveConnection(id: UUID, connection: SocketHTTPRelayConnection) {
        activeConnectionsLock.lock()
        activeConnections[id] = connection
        activeConnectionsLock.unlock()
    }

    private func removeActiveConnection(id: UUID) {
        activeConnectionsLock.lock()
        activeConnections[id] = nil
        activeConnectionsLock.unlock()
    }

    private func removeAllActiveConnections() -> [SocketHTTPRelayConnection] {
        activeConnectionsLock.lock()
        let connections = Array(activeConnections.values)
        activeConnections.removeAll()
        activeConnectionsLock.unlock()
        return connections
    }

    private static func makeListenSocket(host: String, port: UInt16) throws -> Int32 {
        let fd = Darwin.socket(AF_INET, SOCK_STREAM, 0)
        guard fd >= 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }

        var reuse: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))

        var noSigPipe: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &noSigPipe, socklen_t(MemoryLayout<Int32>.size))

        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = port.bigEndian
        address.sin_addr.s_addr = inet_addr(host)

        let bindResult = withUnsafePointer(to: &address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        guard bindResult == 0 else {
            let code = POSIXErrorCode(rawValue: errno) ?? .EIO
            Darwin.close(fd)
            throw POSIXError(code)
        }

        guard Darwin.listen(fd, SOMAXCONN) == 0 else {
            let code = POSIXErrorCode(rawValue: errno) ?? .EIO
            Darwin.close(fd)
            throw POSIXError(code)
        }

        let flags = fcntl(fd, F_GETFL, 0)
        if flags >= 0 {
            _ = fcntl(fd, F_SETFL, flags | O_NONBLOCK)
        }

        return fd
    }

    private static func configureClientSocket(_ fd: Int32) {
        var noSigPipe: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &noSigPipe, socklen_t(MemoryLayout<Int32>.size))

        var timeout = timeval(tv_sec: 30, tv_usec: 0)
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    }
}

private final class SocketHTTPRelayConnection: @unchecked Sendable {
    private let clientSocket: Int32
    private let target: ProxyBridge.Target
    private let queue = DispatchQueue(label: "dev.quotio.desktop.socket-http-relay-connection")
    private let onClose: (@Sendable () -> Void)?
    private let closeLock = NSLock()
    private var closed = false
    private var targetConnection: NWConnection?

    init(clientSocket: Int32, target: ProxyBridge.Target, onClose: (@Sendable () -> Void)?) {
        self.clientSocket = clientSocket
        self.target = target
        self.onClose = onClose
    }

    func start() {
        queue.async { [self] in
            do {
                let request = try Self.readHTTPRequest(from: clientSocket)
                let forwardedRequest = try Self.rewriteRequest(request, target: target)
                startTargetConnection(requestData: forwardedRequest)
            } catch {
                writeErrorResponse(statusCode: 400, message: "Bad Request")
                close()
            }
        }
    }

    func cancel() {
        close()
    }

    private func startTargetConnection(requestData: Data) {
        guard let port = NWEndpoint.Port(rawValue: target.port) else {
            writeErrorResponse(statusCode: 500, message: "Invalid target port")
            close()
            return
        }

        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.enableKeepalive = true
        tcpOptions.keepaliveIdle = 30
        tcpOptions.keepaliveInterval = 5
        tcpOptions.keepaliveCount = 3

        let parameters = NWParameters(tls: Self.makeTLSOptions(for: target), tcp: tcpOptions)
        let connection = NWConnection(
            to: .hostPort(host: NWEndpoint.Host(target.host), port: port),
            using: parameters
        )
        targetConnection = connection

        connection.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                self.sendRequest(requestData, to: connection)
            case .failed:
                self.writeErrorResponse(statusCode: 502, message: "Remote relay target failed")
                self.close()
            case .cancelled:
                self.close()
            default:
                break
            }
        }
        connection.start(queue: queue)
    }

    private func sendRequest(_ requestData: Data, to connection: NWConnection) {
        connection.send(content: requestData, completion: .contentProcessed { [weak self, weak connection] error in
            guard let self else { return }
            guard error == nil, let connection else {
                self.close()
                return
            }
            self.receiveResponse(from: connection)
        })
    }

    private func receiveResponse(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { [weak self, weak connection] data, _, isComplete, error in
            guard let self else { return }

            if let data, !data.isEmpty {
                do {
                    try Self.writeAll(data, to: self.clientSocket)
                } catch {
                    self.close()
                    return
                }
            }

            if isComplete || error != nil {
                self.close()
                return
            }

            if let connection {
                self.receiveResponse(from: connection)
            } else {
                self.close()
            }
        }
    }

    private func close() {
        closeLock.lock()
        if closed {
            closeLock.unlock()
            return
        }
        closed = true
        let connection = targetConnection
        targetConnection = nil
        closeLock.unlock()

        connection?.cancel()
        Darwin.shutdown(clientSocket, SHUT_RDWR)
        Darwin.close(clientSocket)
        onClose?()
    }

    private func writeErrorResponse(statusCode: Int, message: String) {
        let reason: String
        switch statusCode {
        case 400: reason = "Bad Request"
        case 500: reason = "Internal Server Error"
        case 502: reason = "Bad Gateway"
        default: reason = "Error"
        }

        let body = Data(message.utf8)
        let headers = "HTTP/1.1 \(statusCode) \(reason)\r\n" +
            "Content-Type: text/plain\r\n" +
            "Content-Length: \(body.count)\r\n" +
            "Connection: close\r\n" +
            "\r\n"
        let head = Data(headers.utf8)
        var response = Data()
        response.append(head)
        response.append(body)
        try? Self.writeAll(response, to: clientSocket)
    }

    private static func readHTTPRequest(from fd: Int32) throws -> Data {
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 65_536)
        let maxRequestBytes = 64 * 1024 * 1024

        while data.count < maxRequestBytes {
            let count = Darwin.recv(fd, &buffer, buffer.count, 0)
            if count > 0 {
                data.append(buffer, count: count)
                if requestIsComplete(data) {
                    return data
                }
                continue
            }

            if count == 0 {
                throw POSIXError(.ECONNRESET)
            }

            if errno == EINTR {
                continue
            }

            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }

        throw POSIXError(.EOVERFLOW)
    }

    private static func requestIsComplete(_ data: Data) -> Bool {
        guard let headerRange = data.range(of: Data("\r\n\r\n".utf8)) else {
            return false
        }

        let headerData = data[..<headerRange.upperBound]
        guard let headerText = String(data: headerData, encoding: .utf8) else {
            return false
        }

        let bodyBytes = data.count - headerRange.upperBound
        let contentLength = headerText
            .components(separatedBy: "\r\n")
            .first { $0.range(of: #"^\s*content-length\s*:"#, options: [.regularExpression, .caseInsensitive]) != nil }
            .flatMap { line -> Int? in
                guard let separator = line.firstIndex(of: ":") else { return nil }
                return Int(line[line.index(after: separator)...].trimmingCharacters(in: .whitespaces))
            }

        return bodyBytes >= (contentLength ?? 0)
    }

    private static func rewriteRequest(_ request: Data, target: ProxyBridge.Target) throws -> Data {
        guard let headerRange = request.range(of: Data("\r\n\r\n".utf8)) else {
            throw POSIXError(.EINVAL)
        }

        let headerData = request[..<headerRange.lowerBound]
        let bodyData = request[headerRange.upperBound...]

        guard let headerText = String(data: headerData, encoding: .utf8) else {
            throw POSIXError(.EINVAL)
        }

        var lines = headerText.components(separatedBy: "\r\n")
        guard !lines.isEmpty else {
            throw POSIXError(.EINVAL)
        }

        let requestLineParts = lines.removeFirst().split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        guard requestLineParts.count == 3 else {
            throw POSIXError(.EINVAL)
        }

        let method = String(requestLineParts[0])
        let rawPath = normalizeRequestTarget(String(requestLineParts[1]))
        let version = String(requestLineParts[2])
        let forwardedPath = target.forwardingPath(for: rawPath)

        var rewrittenLines = ["\(method) \(forwardedPath) \(version)"]
        for line in lines where !line.isEmpty {
            let lowercased = line.lowercased()
            if lowercased.hasPrefix("host:")
                || lowercased.hasPrefix("connection:")
                || lowercased.hasPrefix("proxy-connection:") {
                continue
            }
            rewrittenLines.append(line)
        }

        rewrittenLines.append("Host: \(target.hostHeader)")
        rewrittenLines.append("Connection: close")

        var rewritten = Data((rewrittenLines.joined(separator: "\r\n") + "\r\n\r\n").utf8)
        rewritten.append(bodyData)
        return rewritten
    }

    private static func normalizeRequestTarget(_ target: String) -> String {
        guard let url = URL(string: target),
              url.scheme != nil else {
            return target
        }

        var path = url.path.isEmpty ? "/" : url.path
        if let query = url.query, !query.isEmpty {
            path += "?\(query)"
        }
        return path
    }

    private static func writeAll(_ data: Data, to fd: Int32) throws {
        try data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else { return }

            var sent = 0
            while sent < data.count {
                let result = Darwin.send(fd, baseAddress.advanced(by: sent), data.count - sent, 0)
                if result > 0 {
                    sent += result
                    continue
                }

                if result == 0 {
                    throw POSIXError(.ECONNRESET)
                }

                if errno == EINTR {
                    continue
                }

                throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
            }
        }
    }

    private static func makeTLSOptions(for target: ProxyBridge.Target) -> NWProtocolTLS.Options? {
        guard target.usesTLS else { return nil }

        let options = NWProtocolTLS.Options()
        target.host.withCString { serverName in
            sec_protocol_options_set_tls_server_name(options.securityProtocolOptions, serverName)
        }

        if !target.verifySSL {
            sec_protocol_options_set_verify_block(
                options.securityProtocolOptions,
                { _, _, complete in
                    complete(true)
                },
                DispatchQueue.global(qos: .userInitiated)
            )
        }

        return options
    }
}
