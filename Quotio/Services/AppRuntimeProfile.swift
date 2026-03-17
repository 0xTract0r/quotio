//
//  AppRuntimeProfile.swift
//  Quotio
//

import Foundation

enum AppRuntimeProfile {
    private static let primaryBundleIdentifier = "dev.quotio.desktop"

    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? primaryBundleIdentifier
    }

    static var suffix: String? {
        guard bundleIdentifier != primaryBundleIdentifier else { return nil }

        if let lastComponent = bundleIdentifier.components(separatedBy: ".").last,
           !lastComponent.isEmpty {
            return sanitize(lastComponent)
        }

        return sanitize(bundleIdentifier.replacingOccurrences(of: ".", with: "-"))
    }

    static var appSupportDirectoryName: String {
        guard let suffix else { return "Quotio" }
        return "Quotio-\(suffix.capitalized)"
    }

    static var authDirectoryName: String {
        guard let suffix else { return ".cli-proxy-api" }
        return ".cli-proxy-api-\(suffix)"
    }

    static var defaultProxyPort: UInt16 {
        suffix == nil ? 8317 : 9317
    }

    static var appSupportDirectoryURL: URL {
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Application Support directory not found")
        }

        let directory = appSupport.appendingPathComponent(appSupportDirectoryName)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    static var authDirectoryURL: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(authDirectoryName)
    }

    static func namespacedKeychainService(_ baseService: String) -> String {
        guard let suffix else { return baseService }
        return "\(baseService).\(suffix)"
    }

    private static func sanitize(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        let scalars = value.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }
        let sanitized = String(scalars).trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return sanitized.isEmpty ? "test" : sanitized.lowercased()
    }
}
