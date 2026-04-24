//
//  ConnectionMode.swift
//  Quotio - CLIProxyAPI GUI Wrapper
//
//  Remote Management support: Local vs Remote connection modes
//

import Foundation
import SwiftUI

// MARK: - Connection Mode

/// Represents how Quotio connects to CLIProxyAPI
enum ConnectionMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case local = "local"    // Connect to localhost proxy (default)
    case remote = "remote"  // Connect to remote CLIProxyAPI instance
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .local: return "Local"
        case .remote: return "Remote"
        }
    }
    
    var description: String {
        switch self {
        case .local:
            return "Connect to local CLIProxyAPI on this machine"
        case .remote:
            return "Connect to a remote CLIProxyAPI server"
        }
    }
    
    var icon: String {
        switch self {
        case .local: return "desktopcomputer"
        case .remote: return "network"
        }
    }
    
    /// Features available in this connection mode
    var features: [String] {
        switch self {
        case .local:
            return [
                "Start/stop proxy server",
                "Configure proxy port and paths",
                "Auto-upgrade proxy binary",
                "Full OAuth authentication",
                "Configure CLI agents"
            ]
        case .remote:
            return [
                "Connect to remote CLIProxyAPI",
                "View and manage accounts",
                "Track quota usage",
                "OAuth for web-based providers",
                "No local proxy required"
            ]
        }
    }
    
    /// Whether proxy start/stop controls should be shown
    var supportsProxyControl: Bool {
        self == .local
    }
    
    /// Whether binary upgrade UI should be shown
    var supportsBinaryUpgrade: Bool {
        self == .local
    }
    
    /// Whether port configuration should be shown
    var supportsPortConfig: Bool {
        self == .local
    }
    
    /// Whether CLI-based OAuth (Copilot, Kiro) is available
    /// These require local CLI binaries to run
    var supportsCLIBasedOAuth: Bool {
        self == .local
    }
}

// MARK: - Remote Connection Config

/// Configuration for connecting to a remote CLIProxyAPI instance
struct RemoteConnectionConfig: Codable, Equatable, Sendable {
    /// The primary URL of the remote CLIProxyAPI core entrypoint.
    /// Users typically paste the remote core address here, for example:
    /// "https://proxy.example.com:8317"
    var endpointURL: String

    /// Optional override when management API is exposed on a different base URL.
    /// If omitted, management requests are derived from `endpointURL`.
    var managementEndpointOverride: String?

    /// Whether local clients should keep using Quotio's localhost entrypoint.
    /// When enabled, Quotio starts a local relay instead of asking CLI tools to
    /// connect directly to `clientBaseURL`.
    var exposeLocalRelay: Bool
    
    /// Display name for this connection (user-defined)
    var displayName: String
    
    /// Whether to verify SSL certificates (should be true in production)
    var verifySSL: Bool
    
    /// Connection timeout in seconds
    var timeoutSeconds: Int
    
    /// Last successful connection timestamp
    var lastConnected: Date?
    
    /// Unique identifier for this config
    let id: String
    
    init(
        endpointURL: String,
        managementEndpointOverride: String? = nil,
        exposeLocalRelay: Bool = false,
        displayName: String = "Remote Server",
        verifySSL: Bool = true,
        timeoutSeconds: Int = 30,
        lastConnected: Date? = nil,
        id: String = UUID().uuidString
    ) {
        self.endpointURL = endpointURL
        self.managementEndpointOverride = managementEndpointOverride
        self.exposeLocalRelay = exposeLocalRelay
        self.displayName = displayName
        self.verifySSL = verifySSL
        self.timeoutSeconds = timeoutSeconds
        self.lastConnected = lastConnected
        self.id = id
    }

    enum CodingKeys: String, CodingKey {
        case endpointURL
        case managementEndpointOverride
        case exposeLocalRelay
        case displayName
        case verifySSL
        case timeoutSeconds
        case lastConnected
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        endpointURL = try container.decode(String.self, forKey: .endpointURL)
        managementEndpointOverride = try container.decodeIfPresent(String.self, forKey: .managementEndpointOverride)
        exposeLocalRelay = try container.decodeIfPresent(Bool.self, forKey: .exposeLocalRelay) ?? false
        displayName = try container.decode(String.self, forKey: .displayName)
        verifySSL = try container.decode(Bool.self, forKey: .verifySSL)
        timeoutSeconds = try container.decode(Int.self, forKey: .timeoutSeconds)
        lastConnected = try container.decodeIfPresent(Date.self, forKey: .lastConnected)
        id = try container.decode(String.self, forKey: .id)
    }
    
    /// Validate the endpoint URL format
    var validationResult: RemoteURLValidationResult {
        RemoteURLValidator.validate(endpointURL)
    }
    
    /// Whether the configuration is valid for connection
    var isValid: Bool {
        validationResult == .valid
    }

    func withLocalRelay(_ enabled: Bool) -> RemoteConnectionConfig {
        RemoteConnectionConfig(
            endpointURL: endpointURL,
            managementEndpointOverride: managementEndpointOverride,
            exposeLocalRelay: enabled,
            displayName: displayName,
            verifySSL: verifySSL,
            timeoutSeconds: timeoutSeconds,
            lastConnected: lastConnected,
            id: id
        )
    }

    /// Normalized base URL for client traffic (no `/v1`, `/v0`, or management suffix).
    nonisolated var clientBaseURL: String {
        Self.normalizedBaseURL(endpointURL)
    }
    
    /// Extract base URL for ManagementAPIClient
    /// Converts full endpoint to base management URL
    nonisolated var managementBaseURL: String {
        let raw = managementEndpointOverride?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? managementEndpointOverride ?? endpointURL
            : endpointURL
        return Self.normalizedManagementBaseURL(raw)
    }

    private static func normalizedBaseURL(_ rawURL: String) -> String {
        var url = RemoteURLValidator.sanitize(rawURL)

        for suffix in ["/v0/management", "/v0", "/v1"] {
            if url.hasSuffix(suffix) {
                url.removeLast(suffix.count)
                break
            }
        }

        while url.hasSuffix("/") {
            url.removeLast()
        }

        return url
    }

    private static func normalizedManagementBaseURL(_ rawURL: String) -> String {
        var url = normalizedBaseURL(rawURL)
        url += "/v0/management"
        return url
    }
}

// MARK: - Remote URL Validation

enum RemoteURLValidationResult: Equatable, Sendable {
    case valid
    case empty
    case invalidScheme      // Must be http:// or https://
    case invalidURL         // Malformed URL
    case missingHost        // No host specified
    case localhostNotAllowed // Use Local mode for localhost
    
    var isValid: Bool {
        self == .valid
    }
    
    var localizationKey: String? {
        switch self {
        case .valid:
            return nil
        case .empty:
            return "remote.error.empty"
        case .invalidScheme:
            return "remote.error.invalidScheme"
        case .invalidURL:
            return "remote.error.invalidURL"
        case .missingHost:
            return "remote.error.missingHost"
        case .localhostNotAllowed:
            return "remote.error.localhostNotAllowed"
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .empty:
            return "Please enter a remote endpoint URL"
        case .invalidScheme:
            return "URL must start with http:// or https://"
        case .invalidURL:
            return "Invalid URL format"
        case .missingHost:
            return "URL must include a host address"
        case .localhostNotAllowed:
            return "Use Local mode for localhost connections"
        }
    }
}

enum RemoteURLValidator {
    static let supportedSchemes = ["http", "https"]
    
    static func validate(_ urlString: String) -> RemoteURLValidationResult {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return .empty
        }
        
        // Check scheme
        let hasValidScheme = supportedSchemes.contains { scheme in
            trimmed.lowercased().hasPrefix("\(scheme)://")
        }
        
        guard hasValidScheme else {
            return .invalidScheme
        }
        
        // Parse URL
        guard let url = URL(string: trimmed) else {
            return .invalidURL
        }
        
        // Check host
        guard let host = url.host, !host.isEmpty else {
            return .missingHost
        }
        
        // Note: localhost is now allowed for users running their own CLIProxyAPI
        // (e.g., installed via Homebrew) without using the bundled binary
        
        return .valid
    }
    
    /// Sanitize URL by trimming and removing trailing slashes
    static func sanitize(_ urlString: String) -> String {
        var trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        while trimmed.hasSuffix("/") {
            trimmed.removeLast()
        }
        return trimmed
    }
}

// MARK: - Connection Status

/// Status of the connection to CLIProxyAPI (local or remote)
enum ConnectionStatus: Equatable, Sendable {
    case disconnected
    case connecting
    case connected
    case error(String)
    
    var displayName: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .error: return "Error"
        }
    }
    
    var color: Color {
        switch self {
        case .disconnected: return .gray
        case .connecting: return .orange
        case .connected: return .green
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .disconnected: return "circle"
        case .connecting: return "circle.dotted"
        case .connected: return "circle.fill"
        case .error: return "exclamationmark.circle.fill"
        }
    }
    
    var isConnected: Bool {
        self == .connected
    }
}
