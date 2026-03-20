//
//  AccountFingerprintRuntime.swift
//  Quotio
//

import Foundation

enum AccountFingerprintRuntime {
    private static let fingerprintStorageKey = "providers.accountFingerprints"

    private struct StoredFingerprintProfile: Decodable {
        let userAgent: StoredUserAgent?
    }

    private struct StoredUserAgent: Decodable {
        let value: String
    }

    static func storedUserAgent(for metadataKey: String, fallback: String? = nil) -> String? {
        if let configured = fingerprintProfile(for: metadataKey)?.userAgent?.value,
           let trimmedConfigured = trimmedNonEmpty(configured) {
            return trimmedConfigured
        }

        return trimmedNonEmpty(fallback)
    }

    @discardableResult
    static func applyUserAgent(
        to request: inout URLRequest,
        metadataKey: String?,
        fallback: String? = nil
    ) -> String? {
        let resolvedUserAgent: String?

        if let metadataKey {
            resolvedUserAgent = storedUserAgent(for: metadataKey, fallback: fallback)
        } else {
            resolvedUserAgent = trimmedNonEmpty(fallback)
        }

        guard let resolvedUserAgent else {
            request.setValue(nil, forHTTPHeaderField: "User-Agent")
            return nil
        }

        request.setValue(resolvedUserAgent, forHTTPHeaderField: "User-Agent")
        return resolvedUserAgent
    }

    static func derivedKiroXAmzUserAgent(from userAgent: String?, fallback: String) -> String {
        guard let userAgent = trimmedNonEmpty(userAgent) else {
            return fallback
        }

        let prefixes = ["aws-sdk-js/", "ua/", "os/", "lang/", "md/", "api/", "m/"]
        let derived = userAgent
            .split(separator: " ")
            .filter { token in
                prefixes.contains { prefix in
                    token.hasPrefix(prefix)
                }
            }
            .joined(separator: " ")

        return derived.isEmpty ? fallback : derived
    }

    private static func fingerprintProfile(for key: String) -> StoredFingerprintProfile? {
        guard let data = UserDefaults.standard.data(forKey: fingerprintStorageKey),
              let decoded = try? JSONDecoder().decode([String: StoredFingerprintProfile].self, from: data) else {
            return nil
        }

        return decoded[key]
    }

    private static func trimmedNonEmpty(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }

        return trimmed
    }
}
