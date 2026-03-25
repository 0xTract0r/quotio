//
//  CompatibilityChecker.swift
//  Quotio - CLIProxyAPI GUI Wrapper
//
//  Service for validating proxy is responding before activation.
//

import Foundation
import Network

/// Service for checking proxy compatibility with Quotio.
/// Simplified to just verify proxy responds to API requests.
actor CompatibilityChecker {
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 10
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Compatibility Check
    
    /// Check if a running proxy is responding to API requests.
    /// - Parameters:
    ///   - port: The port the proxy is running on
    ///   - host: The host (defaults to 127.0.0.1)
    /// - Returns: Compatibility check result
    func checkCompatibility(port: UInt16, host: String = "127.0.0.1", authKey: String? = nil) async -> CompatibilityCheckResult {
        let baseURL = "http://\(host):\(port)"
        
        // Try to call a simple management endpoint
        do {
            let isResponding = try await checkManagementEndpoint(baseURL: baseURL, authKey: authKey)
            return isResponding ? .compatible : .proxyNotResponding
        } catch {
            return .connectionError(error.localizedDescription)
        }
    }
    
    /// Check if a proxy is running and healthy.
    /// - Parameters:
    ///   - port: The port to check
    ///   - host: The host (defaults to 127.0.0.1)
    /// - Returns: true if the proxy responds
    func isHealthy(port: UInt16, host: String = "127.0.0.1") async -> Bool {
        await isPortReachable(port: port, host: host)
    }
    
    /// Perform a full compatibility check including health.
    /// - Parameters:
    ///   - port: The port the proxy is running on
    ///   - host: The host (defaults to 127.0.0.1)
    /// - Returns: Compatibility check result (checks health first, then compatibility)
    func fullCheck(port: UInt16, host: String = "127.0.0.1", authKey: String? = nil) async -> CompatibilityCheckResult {
        // First check if proxy is healthy
        guard await isHealthy(port: port, host: host) else {
            return .proxyNotRunning
        }
        
        // Then check compatibility (which is now just verifying it responds)
        return await checkCompatibility(port: port, host: host, authKey: authKey)
    }
    
    // MARK: - Private Helpers
    
    private func checkManagementEndpoint(baseURL: String, authKey: String?) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/v0/management/debug") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 3
        request.addValue("application/json", forHTTPHeaderField: "Accept"
        )
        if let authKey, !authKey.isEmpty {
            request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Any response (even 401/403) means the proxy is running
        return 200...499 ~= httpResponse.statusCode
    }

    private func isPortReachable(port: UInt16, host: String) async -> Bool {
        await withCheckedContinuation { continuation in
            final class ResumeState: @unchecked Sendable {
                var hasResumed = false
            }

            let endpointHost = NWEndpoint.Host(host)
            guard let endpointPort = NWEndpoint.Port(rawValue: port) else {
                continuation.resume(returning: false)
                return
            }

            let connection = NWConnection(host: endpointHost, port: endpointPort, using: .tcp)
            let queue = DispatchQueue(label: "dev.quotio.compatibility-check")
            let resumeState = ResumeState()

            let finish: @Sendable (Bool) -> Void = { value in
                guard !resumeState.hasResumed else { return }
                resumeState.hasResumed = true
                connection.cancel()
                continuation.resume(returning: value)
            }

            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    finish(true)
                case .failed(_), .cancelled:
                    finish(false)
                default:
                    break
                }
            }

            queue.asyncAfter(deadline: .now() + 3) {
                finish(false)
            }

            connection.start(queue: queue)
        }
    }
}

// MARK: - Convenience Extensions

extension CompatibilityCheckResult {
    /// Check if the result indicates the proxy should be usable.
    var shouldProceed: Bool {
        switch self {
        case .compatible:
            return true
        case .proxyNotResponding, .proxyNotRunning, .connectionError:
            return false
        }
    }
}
