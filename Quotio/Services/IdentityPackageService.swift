//
//  IdentityPackageService.swift
//  Quotio
//

import Foundation
import Observation

@MainActor
@Observable
final class IdentityPackageService {
    static let shared = IdentityPackageService()

    private let defaults = UserDefaults.standard
    private let packagesKey = "identityPackages.storage"
    private let bindingsKey = "identityPackages.bindings"

    private(set) var packages: [RuntimeIdentityPackage] = []
    private(set) var bindings: [String: AccountIdentityBinding] = [:]

    private init() {
        load()
    }

    var sortedPackages: [RuntimeIdentityPackage] {
        packages.sorted { lhs, rhs in
            lhs.createdAt > rhs.createdAt
        }
    }

    func createPackage(name: String? = nil) {
        let now = Date()
        let package = RuntimeIdentityPackage(
            id: UUID(),
            name: name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? name!.trimmingCharacters(in: .whitespacesAndNewlines)
                : defaultPackageName(for: packages.count + 1),
            status: .draft,
            proxy: .empty,
            uaProfile: generateUAProfile(),
            tlsProfile: generateTLSProfile(),
            verification: nil,
            binding: nil,
            createdAt: now,
            updatedAt: now
        )
        packages.insert(package, at: 0)
        persistPackages()
    }

    func deletePackage(id: UUID) {
        packages.removeAll { $0.id == id }
        bindings = bindings.filter { $0.value.packageId != id }
        persistPackages()
        persistBindings()
    }

    func updatePackage(_ package: RuntimeIdentityPackage) {
        guard let index = packages.firstIndex(where: { $0.id == package.id }) else { return }
        var updated = package
        updated.updatedAt = Date()
        updated.status = normalizedStatus(for: updated)
        packages[index] = updated
        persistPackages()
    }

    func package(id: UUID) -> RuntimeIdentityPackage? {
        packages.first { $0.id == id }
    }

    func package(for authFileId: String) -> RuntimeIdentityPackage? {
        guard let binding = bindings[authFileId] else { return nil }
        return package(id: binding.packageId)
    }

    func binding(for authFileId: String) -> AccountIdentityBinding? {
        bindings[authFileId]
    }

    func availablePackages(for authFileId: String?) -> [RuntimeIdentityPackage] {
        sortedPackages.filter { package in
            guard let authFileId else { return !package.isBound }
            guard let boundAuthFileId = package.binding?.authFileId else { return true }
            return boundAuthFileId == authFileId
        }
    }

    func bind(packageId: UUID, to authFile: AuthFile) throws {
        guard let authIndex = authFile.authIndex, !authIndex.isEmpty else {
            throw IdentityPackageError.missingAuthIndex
        }
        guard let provider = authFile.providerType else {
            throw IdentityPackageError.unsupportedProvider
        }
        guard let index = packages.firstIndex(where: { $0.id == packageId }) else {
            throw IdentityPackageError.packageNotFound
        }

        if let occupiedPackage = packages.first(where: { $0.id == packageId }),
           let bound = occupiedPackage.binding,
           bound.authFileId != authFile.id {
            throw IdentityPackageError.packageAlreadyBound
        }

        if let existingBinding = bindings[authFile.id], existingBinding.packageId != packageId {
            unbind(authFileId: authFile.id)
        }

        let now = Date()
        let accountKey = authFile.quotaLookupKey.isEmpty ? authFile.name : authFile.quotaLookupKey
        let boundRef = BoundAccountRef(
            authFileId: authFile.id,
            authIndex: authIndex,
            providerRawValue: provider.rawValue,
            accountKey: accountKey,
            displayName: authFile.email ?? authFile.account ?? authFile.name
        )
        let binding = AccountIdentityBinding(
            authFileId: authFile.id,
            authIndex: authIndex,
            provider: provider,
            accountKey: accountKey,
            packageId: packageId,
            bindingMode: .strict,
            createdAt: now,
            updatedAt: now
        )

        packages[index].binding = boundRef
        packages[index].status = .bound
        packages[index].updatedAt = now
        bindings[authFile.id] = binding

        persistPackages()
        persistBindings()
    }

    func unbind(authFileId: String) {
        guard let binding = bindings.removeValue(forKey: authFileId) else { return }
        guard let index = packages.firstIndex(where: { $0.id == binding.packageId }) else {
            persistBindings()
            return
        }

        packages[index].binding = nil
        packages[index].status = packages[index].proxy.isConfigured ? .available : .draft
        packages[index].updatedAt = Date()

        persistPackages()
        persistBindings()
    }

    func markVerificationResult(
        packageId: UUID,
        passed: Bool,
        exitIP: String? = nil,
        echoedUA: String? = nil,
        tlsDigest: String? = nil,
        traceId: String? = nil,
        note: String? = nil
    ) {
        guard let index = packages.firstIndex(where: { $0.id == packageId }) else { return }
        packages[index].verification = IdentityVerificationSnapshot(
            lastVerifiedAt: Date(),
            lastExitIPAddress: exitIP,
            lastEchoedUserAgent: echoedUA,
            lastTLSDigest: tlsDigest,
            passed: passed,
            traceId: traceId,
            note: note
        )
        packages[index].status = passed ? (packages[index].isBound ? .bound : .available) : .verificationFailed
        packages[index].updatedAt = Date()
        persistPackages()
    }

    func reconcileBindings(with authFiles: [AuthFile]) {
        let authFilesByID = Dictionary(uniqueKeysWithValues: authFiles.map { ($0.id, $0) })
        let staleAuthFileIDs = bindings.keys.filter { authFilesByID[$0] == nil }

        for authFileId in staleAuthFileIDs {
            unbind(authFileId: authFileId)
        }

        var didUpdatePackages = false
        var didUpdateBindings = false

        for (authFileId, authFile) in authFilesByID {
            guard let existingBinding = bindings[authFileId],
                  let packageIndex = packages.firstIndex(where: { $0.id == existingBinding.packageId }) else {
                continue
            }

            guard let authIndex = authFile.authIndex, !authIndex.isEmpty,
                  let provider = authFile.providerType else {
                unbind(authFileId: authFileId)
                continue
            }

            let accountKey = authFile.quotaLookupKey.isEmpty ? authFile.name : authFile.quotaLookupKey
            let displayName = authFile.email ?? authFile.account ?? authFile.name

            let refreshedBoundRef = BoundAccountRef(
                authFileId: authFile.id,
                authIndex: authIndex,
                providerRawValue: provider.rawValue,
                accountKey: accountKey,
                displayName: displayName
            )
            let refreshedBinding = AccountIdentityBinding(
                authFileId: authFile.id,
                authIndex: authIndex,
                provider: provider,
                accountKey: accountKey,
                packageId: existingBinding.packageId,
                bindingMode: existingBinding.bindingMode,
                createdAt: existingBinding.createdAt,
                updatedAt: Date()
            )

            if packages[packageIndex].binding != refreshedBoundRef {
                packages[packageIndex].binding = refreshedBoundRef
                didUpdatePackages = true
            }

            if packages[packageIndex].status == .draft || packages[packageIndex].status == .available {
                packages[packageIndex].status = .bound
                didUpdatePackages = true
            }

            if bindings[authFileId] != refreshedBinding {
                bindings[authFileId] = refreshedBinding
                didUpdateBindings = true
            }
        }

        if didUpdatePackages {
            persistPackages()
        }

        if didUpdateBindings {
            persistBindings()
        }
    }

    private func load() {
        if let data = defaults.data(forKey: packagesKey),
           let decoded = try? JSONDecoder().decode([RuntimeIdentityPackage].self, from: data) {
            packages = decoded
        }

        if let data = defaults.data(forKey: bindingsKey),
           let decoded = try? JSONDecoder().decode([String: AccountIdentityBinding].self, from: data) {
            bindings = decoded
        }
    }

    private func persistPackages() {
        do {
            let data = try JSONEncoder().encode(packages)
            defaults.set(data, forKey: packagesKey)
        } catch {
            Log.error("IdentityPackageService.persistPackages failed: \(error.localizedDescription)")
        }
    }

    private func persistBindings() {
        do {
            let data = try JSONEncoder().encode(bindings)
            defaults.set(data, forKey: bindingsKey)
        } catch {
            Log.error("IdentityPackageService.persistBindings failed: \(error.localizedDescription)")
        }
    }

    private func defaultPackageName(for ordinal: Int) -> String {
        "Identity Package \(ordinal)"
    }

    private func generateUAProfile() -> UserAgentProfile {
        let browserVersion = [131, 132, 133].randomElement() ?? 132
        let patchVersion = Int.random(in: 0...9)
        let macOSVersion = ["14_7", "15_1", "15_3"].randomElement() ?? "15_1"

        return UserAgentProfile(
            id: UUID(),
            name: "Chrome macOS \(browserVersion)",
            userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X \(macOSVersion)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(browserVersion).0.0.\(patchVersion) Safari/537.36",
            secChUa: "\"Chromium\";v=\"\(browserVersion)\", \"Google Chrome\";v=\"\(browserVersion)\", \"Not_A Brand\";v=\"24\"",
            secChUaMobile: "?0",
            secChUaPlatform: "\"macOS\"",
            acceptLanguage: "en-US,en;q=0.9"
        )
    }

    private func generateTLSProfile() -> TLSFingerprintProfile {
        TLSFingerprintProfile(
            id: UUID(),
            name: "Browser-like TLS",
            mode: .browserLike,
            clientHelloTemplate: nil,
            alpn: ["h2", "http/1.1"],
            sniStrategy: "default"
        )
    }

    private func normalizedStatus(for package: RuntimeIdentityPackage) -> IdentityPackageStatus {
        if package.isBound {
            return .bound
        }

        switch package.status {
        case .verificationFailed, .blocked:
            return package.status
        case .draft, .available, .bound:
            return package.proxy.isConfigured ? .available : .draft
        }
    }
}

enum IdentityPackageError: LocalizedError {
    case missingAuthIndex
    case unsupportedProvider
    case packageNotFound
    case packageAlreadyBound

    var errorDescription: String? {
        switch self {
        case .missingAuthIndex:
            return "This account does not expose an auth index yet."
        case .unsupportedProvider:
            return "This provider cannot be bound to an identity package."
        case .packageNotFound:
            return "Identity package not found."
        case .packageAlreadyBound:
            return "Identity package is already bound to another account."
        }
    }
}
