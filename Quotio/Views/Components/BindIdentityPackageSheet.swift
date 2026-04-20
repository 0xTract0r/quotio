//
//  BindIdentityPackageSheet.swift
//  Quotio
//

import SwiftUI

struct BindIdentityPackageSheet: View {
    @Environment(QuotaViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    let authFile: AuthFile

    @State private var selectedPackageID: UUID?
    @State private var errorMessage: String?
    @State private var showUnbindConfirmation = false
    @State private var didRunProvidersIdentityBindingSmoke = false

    private var currentPackage: RuntimeIdentityPackage? {
        viewModel.identityPackage(for: authFile)
    }

    private var bindablePackages: [RuntimeIdentityPackage] {
        viewModel.availableIdentityPackages(for: authFile)
    }

    private var alternativePackages: [RuntimeIdentityPackage] {
        bindablePackages.filter { $0.id != currentPackage?.id }
    }

    private var accountDisplayName: String {
        authFile.email ?? authFile.account ?? authFile.name
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Bind Identity Package")
                    .font(.title3.bold())

                Text(accountDisplayName)
                    .font(.headline)

                Text("Provider: \(authFile.providerType?.displayName ?? authFile.provider)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let authIndex = authFile.authIndex, !authIndex.isEmpty {
                    Text("Auth Index: \(authIndex)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("This account does not expose an auth index yet, so binding cannot be saved.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Current Binding")
                    .font(.headline)

                if let currentPackage {
                    bindingSummary(
                        title: currentPackage.name,
                        subtitle: currentPackage.proxy.displayValue,
                        tint: color(for: currentPackage.status),
                        status: currentPackage.status.displayName
                    )
                } else {
                    bindingSummary(
                        title: "Unbound identity package",
                        subtitle: "This account is not linked to any runtime identity package yet.",
                        tint: .orange,
                        status: "Required"
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(currentPackage == nil ? "Available Packages" : "Other Packages")
                        .font(.headline)
                    Spacer()
                    Text("\(alternativePackages.count)")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }

                if alternativePackages.isEmpty {
                    if currentPackage == nil {
                        ContentUnavailableView(
                            "No Bindable Packages",
                            systemImage: "shield.slash",
                            description: Text("Only identity packages in Available status can be bound. Configure or unblock a package first.")
                        )
                        .frame(maxWidth: .infinity)
                    } else {
                        ContentUnavailableView(
                            "No Other Packages",
                            systemImage: "shield.lefthalf.filled",
                            description: Text("The current binding is shown above. Create or prepare another identity package if you want to switch.")
                        )
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(alternativePackages) { package in
                                packageOption(package)
                            }
                        }
                    }
                    .frame(minHeight: 220)
                }
            }

            Text("Phase 1 only stores the local account-to-package mapping in Quotio. Real runtime proxy, UA, and TLS enforcement still depends on CLIProxyAPIPlus support.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack {
                Button("Open Identity Packages") {
                    viewModel.currentPage = .identityPackages
                    dismiss()
                }

                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                if currentPackage != nil {
                    Button("Unbind", role: .destructive) {
                        showUnbindConfirmation = true
                    }
                }

                Button(currentPackage == nil ? "Bind" : "Change Binding") {
                    saveBinding()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canSaveBinding)
            }
        }
        .padding(20)
        .frame(width: 560, height: 620)
        .task(id: authFile.id) {
            selectedPackageID = alternativePackages.first?.id
            await runProvidersIdentityBindingSmokeIfNeeded()
        }
        .confirmationDialog("Unbind this identity package?", isPresented: $showUnbindConfirmation) {
            Button("Unbind", role: .destructive) {
                viewModel.unbindIdentityPackage(from: authFile)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The identity package record will be kept. This only removes the current account-to-package binding, and you can bind it again later.")
        }
    }

    private var canSaveBinding: Bool {
        guard let authIndex = authFile.authIndex, !authIndex.isEmpty else { return false }
        guard let selectedPackageID else { return false }
        return selectedPackageID != currentPackage?.id
    }

    private func saveBinding() {
        guard let selectedPackageID else { return }

        do {
            try viewModel.bindIdentityPackage(packageId: selectedPackageID, to: authFile)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func packageOption(_ package: RuntimeIdentityPackage) -> some View {
        Button {
            selectedPackageID = package.id
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: selectedPackageID == package.id ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(selectedPackageID == package.id ? Color.accentColor : .secondary)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(package.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()

                        Text(package.status.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(color(for: package.status).opacity(0.12))
                            .foregroundStyle(color(for: package.status))
                            .clipShape(Capsule())
                    }

                    Text(package.proxy.displayValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("UA: \(package.uaProfile.shortDisplayName) | TLS: \(package.tlsProfile.shortDisplayName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedPackageID == package.id ? Color.accentColor.opacity(0.08) : Color.secondary.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPackageID == package.id ? Color.accentColor.opacity(0.35) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func bindingSummary(title: String, subtitle: String, tint: Color, status: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Text(status)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(tint.opacity(0.12))
                    .foregroundStyle(tint)
                    .clipShape(Capsule())
            }

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func runProvidersIdentityBindingSmokeIfNeeded() async {
        guard RuntimeProfile.providersIdentityBindingSmokeEnabled,
              !didRunProvidersIdentityBindingSmoke,
              authFile.providerType != nil else {
            return
        }

        didRunProvidersIdentityBindingSmoke = true

        do {
            try prepareProvidersIdentityBindingSmokeState()
        } catch {
            uiSmokeLog("providers-identity-binding-failed auth=\(authFile.name) error=\(error.localizedDescription)")
            return
        }

        let currentName = currentPackage?.name ?? "none"
        uiSmokeLog(
            "providers-identity-binding-ready auth=\(authFile.name) " +
            "current=\(currentName) " +
            "alternatives=\(alternativePackages.count) " +
            "selected=\(selectedPackageID?.uuidString ?? "nil")"
        )

        guard let currentPackageID = currentPackage?.id else {
            return
        }

        showUnbindConfirmation = true
        uiSmokeLog("providers-identity-unbind-confirmation auth=\(authFile.name) current=\(currentName)")

        try? await Task.sleep(nanoseconds: 200_000_000)
        viewModel.unbindIdentityPackage(from: authFile)
        try? await Task.sleep(nanoseconds: 200_000_000)

        let reboundVisible = alternativePackages.contains(where: { $0.id == currentPackageID })
        uiSmokeLog(
            "providers-identity-unbound auth=\(authFile.name) " +
            "rebound_visible=\(reboundVisible) " +
            "alternatives=\(alternativePackages.count)"
        )
    }

    private func prepareProvidersIdentityBindingSmokeState() throws {
        let boundPackageID = try ensureSmokePackage(
            name: "UI Smoke Bound Package",
            note: "providers identity binding smoke",
            host: "bound.identity.smoke.local",
            port: 18443
        )
        _ = try ensureSmokePackage(
            name: "UI Smoke Spare Package",
            note: "providers identity binding smoke",
            host: "spare.identity.smoke.local",
            port: 19443
        )

        try viewModel.bindIdentityPackage(packageId: boundPackageID, to: authFile)
        selectedPackageID = alternativePackages.first(where: { $0.id != boundPackageID })?.id
            ?? alternativePackages.first?.id
    }

    private func ensureSmokePackage(
        name: String,
        note: String,
        host: String,
        port: Int
    ) throws -> UUID {
        if !viewModel.identityPackages.contains(where: { $0.name == name }) {
            viewModel.createIdentityPackage(name: name)
        }

        guard var package = viewModel.identityPackages.first(where: { $0.name == name }) else {
            throw IdentityPackageError.packageNotFound
        }

        package.note = note
        package.status = .available
        package.statusReason = nil
        package.binding = nil
        package.proxy = IdentityProxyConfig(
            scheme: .https,
            host: host,
            port: port,
            username: "ui-smoke",
            passwordRef: nil
        )
        package.updatedAt = Date()
        viewModel.updateIdentityPackage(package)
        return package.id
    }

    private func uiSmokeLog(_ message: String) {
        #if DEBUG
        RuntimeIsolationDebugLog.write("[ui-smoke] \(message)")
        #endif
    }

    private func color(for status: IdentityPackageStatus) -> Color {
        switch status {
        case .bound:
            return .green
        case .verificationFailed, .blocked:
            return .red
        case .available, .draft:
            return .orange
        }
    }
}
