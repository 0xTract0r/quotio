//
//  RuntimeProfile.swift
//  Quotio
//

import Foundation

enum RuntimeProfile {
    private static let environment = ProcessInfo.processInfo.environment

    static var quotioAppSupportDirectory: URL {
        if let override = stringValue(for: "QUOTIO_APP_SUPPORT_DIR") {
            return URL(fileURLWithPath: override, isDirectory: true)
        }

        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Application Support directory not found")
        }
        return appSupport.appendingPathComponent("Quotio", isDirectory: true)
    }

    static var authDirectory: URL {
        if let override = stringValue(for: "QUOTIO_AUTH_DIR") {
            return URL(fileURLWithPath: override, isDirectory: true)
        }
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".cli-proxy-api", isDirectory: true)
    }

    static var localManagementKeyOverride: String? {
        stringValue(for: "QUOTIO_LOCAL_MANAGEMENT_KEY")
    }

    static var keychainNamespace: String? {
        stringValue(for: "QUOTIO_KEYCHAIN_NAMESPACE")
    }

    static var operatingModeOverride: OperatingMode? {
        guard let raw = stringValue(for: "QUOTIO_OPERATING_MODE") else { return nil }
        return OperatingMode(rawValue: raw)
    }

    static var autoStartProxyOverride: Bool? {
        boolValue(for: "QUOTIO_AUTO_START_PROXY")
    }

    static var showInDockOverride: Bool? {
        boolValue(for: "QUOTIO_SHOW_IN_DOCK")
    }

    static var skipOnboarding: Bool {
        boolValue(for: "QUOTIO_SKIP_ONBOARDING") ?? false
    }

    static var disableUpdateChecks: Bool {
        boolValue(for: "QUOTIO_DISABLE_UPDATE_CHECKS") ?? false
    }

    static var proxyOnlyTestMode: Bool {
        boolValue(for: "QUOTIO_PROXY_ONLY_TEST_MODE") ?? false
    }

    static var proxyPortOverride: UInt16? {
        guard let value = intValue(for: "QUOTIO_PROXY_PORT"),
              value > 0,
              value < 65536 else {
            return nil
        }
        return UInt16(value)
    }

    private static func stringValue(for key: String) -> String? {
        guard let value = environment[key]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }
        return value
    }

    private static func intValue(for key: String) -> Int? {
        guard let value = stringValue(for: key) else { return nil }
        return Int(value)
    }

    private static func boolValue(for key: String) -> Bool? {
        guard let value = stringValue(for: key)?.lowercased() else { return nil }
        switch value {
        case "1", "true", "yes", "on":
            return true
        case "0", "false", "no", "off":
            return false
        default:
            return nil
        }
    }
}
