//
//  AccountMetadataStore.swift
//  Quotio
//
//  Stores local-only metadata for provider accounts, such as user remarks.
//

import Foundation
import Observation

@MainActor
@Observable
final class AccountMetadataStore {
    static let shared = AccountMetadataStore()

    @ObservationIgnored private let userDefaults = UserDefaults.standard
    @ObservationIgnored private let storageKey = "providers.accountRemarks"
    @ObservationIgnored private let orderStorageKey = "providers.accountOrder"

    private var remarksByKey: [String: String]
    private var accountOrderByProvider: [String: [String]]

    private init() {
        self.remarksByKey = userDefaults.dictionary(forKey: storageKey) as? [String: String] ?? [:]
        self.accountOrderByProvider = userDefaults.dictionary(forKey: orderStorageKey) as? [String: [String]] ?? [:]
    }

    nonisolated static func authFileKey(provider: AIProvider, fileName: String) -> String {
        provider.rawValue + ":auth:" + fileName
    }

    nonisolated static func autoDetectedKey(provider: AIProvider, accountKey: String) -> String {
        provider.rawValue + ":auto:" + accountKey
    }

    nonisolated static func customAccountKey(provider: AIProvider, id: String) -> String {
        provider.rawValue + ":custom:" + id
    }

    func remark(for key: String) -> String? {
        Self.normalize(remarksByKey[key])
    }

    func setRemark(_ remark: String?, for key: String) {
        let normalized = Self.normalize(remark)
        let current = remarksByKey[key]

        if normalized == current {
            return
        }

        if let normalized {
            remarksByKey[key] = normalized
        } else {
            remarksByKey.removeValue(forKey: key)
        }

        persist()
    }

    func removeRemark(for key: String) {
        guard remarksByKey.removeValue(forKey: key) != nil else {
            return
        }
        persist()
    }

    func orderedKeys(for provider: AIProvider) -> [String] {
        accountOrderByProvider[provider.rawValue] ?? []
    }

    func setOrderedKeys(_ keys: [String], for provider: AIProvider) {
        let deduplicated = Array(NSOrderedSet(array: keys)) as? [String] ?? keys
        guard accountOrderByProvider[provider.rawValue] != deduplicated else {
            return
        }
        accountOrderByProvider[provider.rawValue] = deduplicated
        persistOrder()
    }

    func removeAccountFromOrder(_ key: String, for provider: AIProvider) {
        guard var keys = accountOrderByProvider[provider.rawValue] else {
            return
        }
        let originalCount = keys.count
        keys.removeAll { $0 == key }
        guard keys.count != originalCount else {
            return
        }
        accountOrderByProvider[provider.rawValue] = keys
        persistOrder()
    }

    private func persist() {
        userDefaults.set(remarksByKey, forKey: storageKey)
    }

    private func persistOrder() {
        userDefaults.set(accountOrderByProvider, forKey: orderStorageKey)
    }

    private nonisolated static func normalize(_ remark: String?) -> String? {
        guard let trimmed = remark?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}
