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

    private var currentPackage: RuntimeIdentityPackage? {
        viewModel.identityPackage(for: authFile)
    }

    private var availablePackages: [RuntimeIdentityPackage] {
        viewModel.availableIdentityPackages(for: authFile)
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
                    Text("Available Packages")
                        .font(.headline)
                    Spacer()
                    Text("\(availablePackages.count)")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }

                if availablePackages.isEmpty {
                    ContentUnavailableView(
                        "No Bindable Packages",
                        systemImage: "shield.slash",
                        description: Text("Only identity packages in Available status can be bound. Configure or unblock a package first.")
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(availablePackages) { package in
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
                        viewModel.unbindIdentityPackage(from: authFile)
                        dismiss()
                    }
                }

                Button(currentPackage == nil ? "Bind" : "Save Binding") {
                    saveBinding()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canSaveBinding)
            }
        }
        .padding(20)
        .frame(width: 560, height: 620)
        .task(id: authFile.id) {
            selectedPackageID = currentPackage?.id ?? availablePackages.first?.id
        }
    }

    private var canSaveBinding: Bool {
        guard let authIndex = authFile.authIndex, !authIndex.isEmpty else { return false }
        return selectedPackageID != nil
    }

    private func saveBinding() {
        guard let selectedPackageID else { return }

        if currentPackage?.id == selectedPackageID {
            dismiss()
            return
        }

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
