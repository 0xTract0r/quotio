//
//  KeychainHelper.swift
//  Quotio - CLIProxyAPI GUI Wrapper
//
//  Keychain helper for secure credential storage
//

import Foundation
import LocalAuthentication
import Security

// MARK: - Keychain Helper

enum KeychainHelper {
    private static let remoteServiceBase = "dev.quotio.desktop.remote-management"
    private static let localServiceBase = "dev.quotio.desktop.local-management"
    private static let warpServiceBase = "dev.quotio.desktop.warp"
    private static let identityProxyServiceBase = "dev.quotio.desktop.identity-package.proxy"
    private static let localManagementAccount = "local-management-key"
    private static let warpTokensAccount = "warp-tokens"
    private static let localManagementDefaultsKey = "managementKey"
    private static let warpTokensDefaultsKey = "warpTokens"
    private static let useDataProtectionKeychain = true
    private static let legacyMigrationEnvironmentKey = "QUOTIO_ENABLE_LEGACY_KEYCHAIN_MIGRATION"

    // Legacy service names for keychain migration (newest first)
    private static let legacyRemoteServices = [
        "proseek.io.vn.Quotio.remote-management",
        "com.quotio.remote-management",
    ]
    private static let legacyLocalServices = [
        "proseek.io.vn.Quotio.local-management",
        "com.quotio.local-management",
    ]
    private static let legacyWarpServices = [
        "proseek.io.vn.Quotio.warp",
        "com.quotio.warp",
    ]

    private static var remoteService: String { AppRuntimeProfile.namespacedKeychainService(remoteServiceBase) }
    private static var localService: String { AppRuntimeProfile.namespacedKeychainService(localServiceBase) }
    private static var warpService: String { AppRuntimeProfile.namespacedKeychainService(warpServiceBase) }
    private static var identityProxyService: String { AppRuntimeProfile.namespacedKeychainService(identityProxyServiceBase) }

    static func saveManagementKey(_ key: String, for configId: String) {
        let account = "management-key-\(configId)"
        guard let data = key.data(using: .utf8) else { return }
        if !saveData(data, service: remoteService, account: account) {
            Log.keychain("Failed to save management key for config \(configId)")
        }
    }

    static func getManagementKey(for configId: String) -> String? {
        let account = "management-key-\(configId)"
        if let key = readString(service: remoteService, account: account) {
            return key
        }
        return migrateString(from: legacyRemoteServices, to: remoteService, account: account)
    }

    static func deleteManagementKey(for configId: String) {
        let account = "management-key-\(configId)"
        deleteData(service: remoteService, account: account)
        for legacy in legacyRemoteServices {
            deleteLegacyData(service: legacy, account: account)
        }
    }

    static func hasManagementKey(for configId: String) -> Bool {
        getManagementKey(for: configId) != nil
    }

    static func saveLocalManagementKey(_ key: String) -> Bool {
        if RuntimeProfile.localManagementKeyOverride != nil {
            return true
        }
        guard let data = key.data(using: .utf8) else { return false }
        let saved = saveData(data, service: localService, account: localManagementAccount)
        if !saved {
            Log.keychain("Failed to save local management key")
        }
        return saved
    }

    static func getLocalManagementKey() -> String? {
        if let override = RuntimeProfile.localManagementKeyOverride {
            return override
        }
        // Local runtime startup should not probe the classic login keychain and trigger access prompts.
        if let key = readString(
            service: localService,
            account: localManagementAccount,
            allowClassicFallback: false
        ) {
            return key
        }

        // Migrate from legacy keychain service name
        if let legacyKey = migrateString(from: legacyLocalServices, to: localService, account: localManagementAccount) {
            return legacyKey
        }

        guard let legacyKey = UserDefaults.standard.string(forKey: localManagementDefaultsKey),
              !legacyKey.hasPrefix("$2a$") else {
            return nil
        }

        if saveLocalManagementKey(legacyKey) {
            UserDefaults.standard.removeObject(forKey: localManagementDefaultsKey)
        }

        return legacyKey
    }

    static func deleteLocalManagementKey() {
        guard RuntimeProfile.localManagementKeyOverride == nil else { return }
        deleteData(service: localService, account: localManagementAccount)
        for legacy in legacyLocalServices {
            deleteLegacyData(service: legacy, account: localManagementAccount)
        }
        UserDefaults.standard.removeObject(forKey: localManagementDefaultsKey)
    }

    static func saveWarpTokens(_ data: Data) -> Bool {
        let saved = saveData(data, service: warpService, account: warpTokensAccount)
        if !saved {
            Log.keychain("Failed to save Warp tokens")
        }
        return saved
    }

    static func getWarpTokens() -> Data? {
        if let data = readData(service: warpService, account: warpTokensAccount) {
            return data
        }

        if let legacyData = migrateData(from: legacyWarpServices, to: warpService, account: warpTokensAccount) {
            return legacyData
        }

        guard let legacyData = UserDefaults.standard.data(forKey: warpTokensDefaultsKey) else {
            return nil
        }

        if saveWarpTokens(legacyData) {
            UserDefaults.standard.removeObject(forKey: warpTokensDefaultsKey)
        }

        return legacyData
    }

    static func deleteWarpTokens() {
        deleteData(service: warpService, account: warpTokensAccount)
        for legacy in legacyWarpServices {
            deleteLegacyData(service: legacy, account: warpTokensAccount)
        }
        UserDefaults.standard.removeObject(forKey: warpTokensDefaultsKey)
    }

    static func saveIdentityPackageProxyPassword(_ password: String, reference: String) -> Bool {
        guard let data = password.data(using: .utf8) else { return false }
        let saved = saveData(data, service: identityProxyService, account: reference)
        if !saved {
            Log.keychain("Failed to save identity package proxy password for reference \(reference)")
        }
        return saved
    }

    static func getIdentityPackageProxyPassword(reference: String) -> String? {
        readString(service: identityProxyService, account: reference)
    }

    static func deleteIdentityPackageProxyPassword(reference: String) {
        deleteData(service: identityProxyService, account: reference)
    }

    private static func migrateData(from oldServices: [String], to newService: String, account: String) -> Data? {
        guard legacyKeychainMigrationEnabled else {
            return nil
        }

        for oldService in oldServices {
            guard let data = readLegacyData(service: oldService, account: account) else { continue }
            if saveData(data, service: newService, account: account) {
                deleteLegacyData(service: oldService, account: account)
            }
            return data
        }
        return nil
    }

    private static func migrateString(from oldServices: [String], to newService: String, account: String) -> String? {
        guard legacyKeychainMigrationEnabled else {
            return nil
        }

        // Non-destructive read: validate UTF-8 before committing the destructive migration
        for oldService in oldServices {
            guard let data = readLegacyData(service: oldService, account: account) else { continue }
            guard let decoded = String(data: data, encoding: .utf8) else { continue }
            _ = migrateData(from: [oldService], to: newService, account: account)
            return decoded
        }
        return nil
    }


    private static func saveData(_ data: Data, service: String, account: String) -> Bool {
        deleteData(service: service, account: account)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        if useDataProtectionKeychain {
            query[kSecUseDataProtectionKeychain as String] = true
        }

        applyNonInteractiveOptions(to: &query)

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            return true
        }

        Log.keychain("Keychain save failed (service: \(service), account: \(account)): \(status)")
        return false
    }

    private static func readData(
        service: String,
        account: String,
        allowClassicFallback: Bool = true
    ) -> Data? {
        if let data = readData(service: service, account: account, useDataProtection: useDataProtectionKeychain) {
            return data
        }

        guard allowClassicFallback else {
            return nil
        }

        return copyClassicKeychainDataIfAvailable(service: service, account: account)
    }

    private static func readLegacyData(service: String, account: String) -> Data? {
        readData(service: service, account: account, useDataProtection: false)
    }

    private static func readData(service: String, account: String, useDataProtection: Bool) -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        if useDataProtection {
            query[kSecUseDataProtectionKeychain as String] = true
        }

        applyNonInteractiveOptions(to: &query)

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            return result as? Data
        }

        if status != errSecItemNotFound {
            Log.keychain("Keychain read failed (service: \(service), account: \(account)): \(status)")
        }

        return nil
    }

    private static func copyClassicKeychainDataIfAvailable(service: String, account: String) -> Data? {
        guard useDataProtectionKeychain,
              let data = readLegacyData(service: service, account: account) else {
            return nil
        }

        if !saveData(data, service: service, account: account) {
            Log.keychain("Failed to copy existing keychain item into Data Protection keychain (service: \(service), account: \(account))")
        }

        return data
    }

    private static func readString(
        service: String,
        account: String,
        allowClassicFallback: Bool = true
    ) -> String? {
        guard let data = readData(
            service: service,
            account: account,
            allowClassicFallback: allowClassicFallback
        ) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private static func deleteData(service: String, account: String) {
        deleteData(service: service, account: account, useDataProtection: useDataProtectionKeychain)
    }

    private static func deleteLegacyData(service: String, account: String) {
        deleteData(service: service, account: account, useDataProtection: false)
    }

    private static func deleteData(service: String, account: String, useDataProtection: Bool) {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        if useDataProtection {
            query[kSecUseDataProtectionKeychain as String] = true
        }

        applyNonInteractiveOptions(to: &query)

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            Log.keychain("Keychain delete failed (service: \(service), account: \(account)): \(status)")
        }
    }

    private static func applyNonInteractiveOptions(to query: inout [String: Any]) {
        query[kSecUseAuthenticationContext as String] = nonInteractiveContext()
        query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUIFail
    }

    private static func nonInteractiveContext() -> LAContext {
        let context = LAContext()
        context.interactionNotAllowed = true
        return context
    }

    private static var legacyKeychainMigrationEnabled: Bool {
        ProcessInfo.processInfo.environment[legacyMigrationEnvironmentKey] == "1"
    }
}
