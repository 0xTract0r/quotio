//
//  AccountMetadataStore.swift
//  Quotio
//
//  Stores local-only metadata for provider accounts, such as user remarks.
//

import Foundation
import Observation
import CryptoKit

struct AccountUserAgentProfile: Codable, Equatable, Sendable {
    let family: String
    let value: String
    let platform: String
    let appVersion: String
    let notes: [String]
}

struct AccountTLSFingerprintProfile: Codable, Equatable, Sendable {
    let preset: String
    let transport: String
    let alpn: [String]
    let notes: [String]
}

struct AccountUpstreamHeaderProfile: Codable, Equatable, Sendable {
    let headers: [String: String]
    let notes: [String]
}

struct AccountFingerprintProfile: Codable, Equatable, Sendable {
    let version: Int
    let generatedAt: Date
    let userAgent: AccountUserAgentProfile
    let tls: AccountTLSFingerprintProfile
    let upstreamHTTP: AccountUpstreamHeaderProfile?

    static func managedHeaderNames(for provider: AIProvider) -> [String] {
        switch provider {
        case .claude:
            return [
                "User-Agent",
                "X-App",
                "X-Stainless-Package-Version",
                "X-Stainless-Runtime-Version",
                "X-Stainless-Timeout"
            ]
        case .codex:
            return [
                "User-Agent",
                "Version"
            ]
        default:
            return []
        }
    }

    static func generate(for provider: AIProvider, metadataKey: String) -> AccountFingerprintProfile {
        let macOSVersions = ["15_3_1", "15_2_0", "15_1_1", "14_7_4", "14_6_1"]
        let macOSVersionsDot = ["15.3.1", "15.2.0", "15.1.1", "14.7.4", "14.6.1"]
        let chromeVersions = ["136.0.7103.114", "135.0.7049.115", "134.0.6998.205"]
        let claudeVersions = ["2.1.63", "2.1.58", "2.1.44"]
        let claudePackageVersions = ["0.74.0", "0.73.1", "0.72.0"]
        let codexVersions = ["0.114.0", "0.111.0", "0.109.1"]
        let vscodeVersions = ["1.111.0", "1.110.2", "1.109.1"]
        let antigravityVersions = ["1.12.1", "1.11.3", "1.10.9"]
        let sdkVersions = ["3.980.0", "3.975.0", "3.808.0", "3.738.0"]
        let nodeVersions = ["22.21.1", "22.20.0", "20.18.0"]
        let kiroVersions = ["0.10.32", "0.10.16", "0.9.47", "0.8.206"]

        let arch = "arm64"
        let macOSUnderscore = macOSVersions.randomElement() ?? "15_3_1"
        let macOSDot = macOSVersionsDot.randomElement() ?? "15.3.1"
        let browserVersion = chromeVersions.randomElement() ?? "136.0.7103.114"
        let claudeVersion = claudeVersions.randomElement() ?? "2.1.63"
        let claudePackageVersion = claudePackageVersions.randomElement() ?? "0.74.0"
        let codexVersion = codexVersions.randomElement() ?? "0.114.0"
        let vscodeVersion = vscodeVersions.randomElement() ?? "1.111.0"
        let antigravityVersion = antigravityVersions.randomElement() ?? "1.11.3"
        let sdkVersion = sdkVersions.randomElement() ?? "3.980.0"
        let nodeVersion = nodeVersions.randomElement() ?? "22.21.1"
        let kiroVersion = kiroVersions.randomElement() ?? "0.10.32"
        let hashPrefix = String(
            SHA256.hash(data: Data((metadataKey + UUID().uuidString).utf8))
                .compactMap { String(format: "%02x", $0) }
                .joined()
                .prefix(12)
        )

        let userAgent: AccountUserAgentProfile
        let tls: AccountTLSFingerprintProfile
        let upstreamHTTP: AccountUpstreamHeaderProfile?

        switch provider {
        case .cursor, .trae:
            userAgent = AccountUserAgentProfile(
                family: "browser",
                value: "Mozilla/5.0 (Macintosh; Intel Mac OS X \(macOSUnderscore)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(browserVersion) Safari/537.36",
                platform: "macOS \(macOSDot) / \(arch)",
                appVersion: browserVersion,
                notes: ["参考社区常见浏览器伪装格式，适合需要 Chromium 风格请求头的场景。"]
            )
            tls = AccountTLSFingerprintProfile(
                preset: "browser-like",
                transport: "system-default",
                alpn: ["h2", "http/1.1"],
                notes: ["当前 Quotio 仅保存该档案，不会直接改写 Cursor/Trae 上游 TLS ClientHello。"]
            )
            upstreamHTTP = nil
        case .antigravity:
            userAgent = AccountUserAgentProfile(
                family: "native-client",
                value: "antigravity/\(antigravityVersion) Darwin/\(arch)",
                platform: "Darwin / \(arch)",
                appVersion: antigravityVersion,
                notes: ["保存后会同步写入 auth 文件的 `user_agent` 字段，CLIProxyAPIPlus 会优先使用它。"]
            )
            tls = AccountTLSFingerprintProfile(
                preset: "google-h2",
                transport: "CLIProxyAPIPlus",
                alpn: ["h2"],
                notes: ["Antigravity 目前可稳定控制的是 User-Agent；TLS 指纹仍由上游运行时决定。"]
            )
            upstreamHTTP = nil
        case .kiro:
            userAgent = AccountUserAgentProfile(
                family: "kiro-runtime",
                value: "aws-sdk-js/\(sdkVersion) ua/2.1 os/darwin#\(macOSDot) lang/js md/nodejs#\(nodeVersion) api/codewhispererstreaming#1.0.27 m/E KiroIDE-\(kiroVersion)-\(hashPrefix)",
                platform: "darwin#\(macOSDot) / node \(nodeVersion)",
                appVersion: kiroVersion,
                notes: ["参考 CLIProxyAPIPlus 内建的 Kiro 动态指纹格式生成，可用于对齐账户档案。"]
            )
            tls = AccountTLSFingerprintProfile(
                preset: "kiro-dynamic",
                transport: "CLIProxyAPIPlus",
                alpn: ["h2", "http/1.1"],
                notes: ["Kiro 本身已有账号级动态指纹；当前 Quotio 不覆写其全局指纹配置。"]
            )
            upstreamHTTP = nil
        case .claude:
            userAgent = AccountUserAgentProfile(
                family: "cli",
                value: "claude-cli/\(claudeVersion) (external, sdk-cli)",
                platform: "macOS \(macOSDot) / \(arch)",
                appVersion: claudeVersion,
                notes: ["参考 CLIProxyAPIPlus 的 Claude 上游默认格式。保存后会作为账户级上游 HTTP 头档案的一部分写入 auth 记录。"]
            )
            tls = AccountTLSFingerprintProfile(
                preset: "chrome-utls",
                transport: "CLIProxyAPIPlus",
                alpn: ["h2"],
                notes: ["Claude 运行期的 TLS 指纹不由该档案逐账号控制；当前真正可控的是出口代理与上游 HTTP 头。"]
            )
            upstreamHTTP = AccountUpstreamHeaderProfile(
                headers: [
                    "User-Agent": userAgent.value,
                    "X-App": "cli",
                    "X-Stainless-Package-Version": claudePackageVersion,
                    "X-Stainless-Runtime-Version": "v" + nodeVersion,
                    "X-Stainless-Timeout": "600"
                ],
                notes: [
                    "这些头会写入 auth 记录的 `headers`，并在支持该能力的 CLIProxyAPIPlus 上游请求中覆盖默认值。",
                    "`Anthropic-Version`、`Anthropic-Beta` 等核心协议头仍由代理按请求场景生成，不建议按账号随意改写。"
                ]
            )
        case .codex:
            userAgent = AccountUserAgentProfile(
                family: "cli",
                value: "codex_cli_rs/\(codexVersion) (Mac OS \(macOSDot); \(arch)) vscode/\(vscodeVersion)",
                platform: "macOS \(macOSDot) / \(arch)",
                appVersion: codexVersion,
                notes: ["参考 CLIProxyAPIPlus 的 Codex 默认头格式。保存后会作为账户级上游 HTTP 头档案的一部分写入 auth 记录。"]
            )
            tls = AccountTLSFingerprintProfile(
                preset: "system-or-upstream",
                transport: "CLIProxyAPIPlus",
                alpn: ["h2", "http/1.1"],
                notes: ["Codex 当前没有通用的每账户 TLS 指纹写入口；当前真正可控的是出口代理与上游 HTTP 头。"]
            )
            upstreamHTTP = AccountUpstreamHeaderProfile(
                headers: [
                    "User-Agent": userAgent.value,
                    "Version": codexVersion
                ],
                notes: [
                    "`Version` 会覆盖核心默认 client version；`Session_id` 仍由核心逐请求生成，不做账户级持久化。",
                    "Codex websocket 链路仍由核心决定连接与协议细节，这里只管理可稳定持久化的上游 HTTP 头。"
                ]
            )
        default:
            let genericVersion = browserVersion
            userAgent = AccountUserAgentProfile(
                family: "generic",
                value: "\(provider.rawValue)/\(genericVersion) (macOS \(macOSDot); \(arch))",
                platform: "macOS \(macOSDot) / \(arch)",
                appVersion: genericVersion,
                notes: ["使用通用 CLI/桌面客户端格式，便于后续与 provider 专项实现对齐。"]
            )
            tls = AccountTLSFingerprintProfile(
                preset: "system-default",
                transport: "Quotio / CLIProxyAPIPlus",
                alpn: ["h2", "http/1.1"],
                notes: ["当前 Quotio 仅保存该 TLS 档案，尚无通用的每账户实际注入入口。"]
            )
            upstreamHTTP = nil
        }

        return AccountFingerprintProfile(
            version: 2,
            generatedAt: Date(),
            userAgent: userAgent,
            tls: tls,
            upstreamHTTP: upstreamHTTP
        )
    }
}

@MainActor
@Observable
final class AccountMetadataStore {
    static let shared = AccountMetadataStore()

    @ObservationIgnored private let userDefaults = UserDefaults.standard
    @ObservationIgnored private let storageKey = "providers.accountRemarks"
    @ObservationIgnored private let orderStorageKey = "providers.accountOrder"
    @ObservationIgnored private let fingerprintStorageKey = "providers.accountFingerprints"

    private var remarksByKey: [String: String]
    private var accountOrderByProvider: [String: [String]]
    private var fingerprintsByKey: [String: AccountFingerprintProfile]

    private init() {
        self.remarksByKey = userDefaults.dictionary(forKey: storageKey) as? [String: String] ?? [:]
        self.accountOrderByProvider = userDefaults.dictionary(forKey: orderStorageKey) as? [String: [String]] ?? [:]
        if let data = userDefaults.data(forKey: fingerprintStorageKey),
           let decoded = try? JSONDecoder().decode([String: AccountFingerprintProfile].self, from: data) {
            self.fingerprintsByKey = decoded
        } else {
            self.fingerprintsByKey = [:]
        }
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

    func fingerprintProfile(for key: String) -> AccountFingerprintProfile? {
        fingerprintsByKey[key]
    }

    func setFingerprintProfile(_ profile: AccountFingerprintProfile?, for key: String) {
        if let profile {
            guard fingerprintsByKey[key] != profile else { return }
            fingerprintsByKey[key] = profile
        } else {
            guard fingerprintsByKey.removeValue(forKey: key) != nil else { return }
        }
        persistFingerprints()
    }

    func removeFingerprintProfile(for key: String) {
        guard fingerprintsByKey.removeValue(forKey: key) != nil else {
            return
        }
        persistFingerprints()
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

    private func persistFingerprints() {
        guard let data = try? JSONEncoder().encode(fingerprintsByKey) else { return }
        userDefaults.set(data, forKey: fingerprintStorageKey)
    }

    private nonisolated static func normalize(_ remark: String?) -> String? {
        guard let trimmed = remark?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}
