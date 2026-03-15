//
//  IdentityPackageModels.swift
//  Quotio
//

import Foundation

enum IdentityPackageStatus: String, CaseIterable, Codable, Sendable {
    case draft
    case available
    case bound
    case verificationFailed
    case blocked

    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .available: return "Available"
        case .bound: return "Bound"
        case .verificationFailed: return "Verification Failed"
        case .blocked: return "Blocked"
        }
    }
}

enum IdentityProxyScheme: String, CaseIterable, Codable, Sendable {
    case http
    case https
    case socks5
}

struct IdentityProxyConfig: Codable, Hashable, Sendable {
    var scheme: IdentityProxyScheme
    var host: String
    var port: Int
    var username: String?
    var passwordRef: String?

    static let empty = IdentityProxyConfig(
        scheme: .http,
        host: "",
        port: 0,
        username: nil,
        passwordRef: nil
    )

    var displayValue: String {
        guard !host.isEmpty, port > 0 else { return "Unconfigured" }
        return "\(scheme.rawValue)://\(host):\(port)"
    }

    var isConfigured: Bool {
        !host.isEmpty && port > 0
    }
}

struct UserAgentProfile: Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var userAgent: String
    var secChUa: String?
    var secChUaMobile: String?
    var secChUaPlatform: String?
    var acceptLanguage: String?

    var shortDisplayName: String {
        name.isEmpty ? "UA Profile" : name
    }
}

enum TLSFingerprintMode: String, CaseIterable, Codable, Sendable {
    case inherited
    case browserLike
    case customTemplate

    var displayName: String {
        switch self {
        case .inherited: return "Inherited"
        case .browserLike: return "Browser-like"
        case .customTemplate: return "Custom Template"
        }
    }
}

struct TLSFingerprintProfile: Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var mode: TLSFingerprintMode
    var clientHelloTemplate: String?
    var alpn: [String]
    var sniStrategy: String?

    var shortDisplayName: String {
        name.isEmpty ? mode.displayName : name
    }
}

struct IdentityVerificationSnapshot: Codable, Hashable, Sendable {
    var lastVerifiedAt: Date?
    var lastExitIPAddress: String?
    var lastEchoedUserAgent: String?
    var lastTLSDigest: String?
    var passed: Bool
    var traceId: String?
    var note: String?
}

struct BoundAccountRef: Codable, Hashable, Sendable {
    var authFileId: String
    var authIndex: String
    var providerRawValue: String
    var accountKey: String
    var displayName: String
}

enum BindingMode: String, CaseIterable, Codable, Sendable {
    case strict
}

struct AccountIdentityBinding: Codable, Identifiable, Hashable, Sendable {
    let authFileId: String
    let authIndex: String
    let provider: AIProvider
    let accountKey: String
    let packageId: UUID
    let bindingMode: BindingMode
    let createdAt: Date
    let updatedAt: Date

    var id: String { authFileId }
}

struct RuntimeIdentityPackage: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var status: IdentityPackageStatus
    var proxy: IdentityProxyConfig
    var uaProfile: UserAgentProfile
    var tlsProfile: TLSFingerprintProfile
    var verification: IdentityVerificationSnapshot?
    var binding: BoundAccountRef?
    var createdAt: Date
    var updatedAt: Date

    var isBound: Bool {
        binding != nil
    }

    var bindingDisplayName: String {
        binding?.displayName ?? "Unbound"
    }
}

struct IdentityPackageImportIssue: Identifiable, Hashable, Sendable {
    let lineNumber: Int
    let content: String
    let reason: String

    var id: String {
        "\(lineNumber):\(content):\(reason)"
    }
}

struct IdentityPackageImportResult: Hashable, Sendable {
    let importedCount: Int
    let issues: [IdentityPackageImportIssue]

    var skippedCount: Int {
        issues.count
    }
}
