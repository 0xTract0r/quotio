//
//  IdentityPackagesScreen.swift
//  Quotio
//

import SwiftUI

struct IdentityPackagesScreen: View {
    @Environment(QuotaViewModel.self) private var viewModel
    @State private var selectedPackageID: UUID?
    @State private var draftPackage: RuntimeIdentityPackage?
    @State private var showDeleteConfirmation = false

    private var selectedPackage: RuntimeIdentityPackage? {
        guard let selectedPackageID else { return viewModel.identityPackages.first }
        return viewModel.identityPackages.first(where: { $0.id == selectedPackageID }) ?? viewModel.identityPackages.first
    }

    private var hasUnsavedChanges: Bool {
        draftPackage != selectedPackage
    }

    var body: some View {
        HSplitView {
            List(selection: $selectedPackageID) {
                ForEach(viewModel.identityPackages) { package in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(package.name)
                                .font(.headline)
                            Spacer()
                            Text(package.status.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text(package.proxy.displayValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(package.bindingDisplayName)
                            .font(.caption)
                            .foregroundStyle(package.isBound ? .primary : .secondary)
                    }
                    .tag(package.id)
                    .padding(.vertical, 4)
                }
            }
            .frame(minWidth: 280, idealWidth: 320)

            Group {
                if let draftPackage {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            detailSection(title: "Overview") {
                                TextField("Identity package name", text: binding(for: \.name, default: ""))
                                    .textFieldStyle(.roundedBorder)

                                detailRow(label: "Status", value: draftPackage.status.displayName)
                                detailRow(label: "Bound Account", value: draftPackage.bindingDisplayName)
                                detailRow(label: "Package ID", value: draftPackage.id.uuidString)
                            }

                            detailSection(title: "Proxy") {
                                Picker("Scheme", selection: proxyBinding(for: \.scheme, default: .http)) {
                                    ForEach(IdentityProxyScheme.allCases, id: \.self) { scheme in
                                        Text(scheme.rawValue.uppercased())
                                            .tag(scheme)
                                    }
                                }
                                .pickerStyle(.segmented)

                                TextField("Host", text: proxyBinding(for: \.host, default: ""))
                                    .textFieldStyle(.roundedBorder)

                                TextField("Port", value: proxyBinding(for: \.port, default: 0), format: .number)
                                    .textFieldStyle(.roundedBorder)

                                TextField("Username", text: proxyOptionalBinding(for: \.username))
                                    .textFieldStyle(.roundedBorder)

                                TextField("Password Ref", text: proxyOptionalBinding(for: \.passwordRef))
                                    .textFieldStyle(.roundedBorder)

                                Text("`Password Ref` 当前只是本地字段预留，尚未接 Keychain。")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            detailSection(title: "User-Agent") {
                                detailRow(label: "Profile", value: draftPackage.uaProfile.shortDisplayName)
                                Text(draftPackage.uaProfile.userAgent)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .textSelection(.enabled)
                            }

                            detailSection(title: "TLS") {
                                detailRow(label: "Profile", value: draftPackage.tlsProfile.shortDisplayName)
                                detailRow(label: "Mode", value: draftPackage.tlsProfile.mode.displayName)
                                detailRow(label: "ALPN", value: draftPackage.tlsProfile.alpn.joined(separator: ", "))
                                Text("TLS 指纹当前仅为模型预留，尚未接入真实运行时执行层。")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            detailSection(title: "Verification") {
                                detailRow(
                                    label: "Last Result",
                                    value: verificationLabel(for: draftPackage)
                                )
                                detailRow(
                                    label: "Exit IP",
                                    value: draftPackage.verification?.lastExitIPAddress ?? "Unknown"
                                )
                                detailRow(
                                    label: "TLS Digest",
                                    value: draftPackage.verification?.lastTLSDigest ?? "Unknown"
                                )
                            }

                            HStack {
                                Button("Reset") {
                                    syncDraftFromSelection()
                                }
                                .disabled(!hasUnsavedChanges)

                                Spacer()

                                Button("Delete", role: .destructive) {
                                    showDeleteConfirmation = true
                                }

                                Button("Save") {
                                    saveDraft()
                                }
                                .keyboardShortcut(.defaultAction)
                                .disabled(!canSaveDraft)
                            }
                        }
                        .padding(20)
                    }
                } else {
                    ContentUnavailableView(
                        "No Identity Packages",
                        systemImage: "shield.lefthalf.filled.badge.checkmark",
                        description: Text("Create your first runtime identity package to start assigning OAuth accounts.")
                    )
                }
            }
            .frame(minWidth: 420)
        }
        .navigationTitle("Identity Packages")
        .onAppear {
            if selectedPackageID == nil {
                selectedPackageID = viewModel.identityPackages.first?.id
            }
            syncDraftFromSelection()
        }
        .onChange(of: selectedPackageID) { _, _ in
            syncDraftFromSelection()
        }
        .onChange(of: viewModel.identityPackages) { _, _ in
            if selectedPackage == nil {
                selectedPackageID = viewModel.identityPackages.first?.id
            }
            syncDraftFromSelection()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.createIdentityPackage()
                    selectedPackageID = viewModel.identityPackages.first?.id
                } label: {
                    Image(systemName: "plus")
                }
                .help("Create identity package")
            }
        }
        .confirmationDialog("Delete this identity package?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteSelectedPackage()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This only removes the local identity package record in Quotio.")
        }
    }

    @ViewBuilder
    private func detailSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func verificationLabel(for package: RuntimeIdentityPackage) -> String {
        guard let verification = package.verification else { return "Not verified" }
        return verification.passed ? "Passed" : "Failed"
    }

    private var canSaveDraft: Bool {
        guard let draftPackage else { return false }
        return !draftPackage.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func binding<Value>(for keyPath: WritableKeyPath<RuntimeIdentityPackage, Value>, default defaultValue: Value) -> Binding<Value> {
        Binding(
            get: { draftPackage?[keyPath: keyPath] ?? defaultValue },
            set: { newValue in
                draftPackage?[keyPath: keyPath] = newValue
            }
        )
    }

    private func proxyBinding<Value>(for keyPath: WritableKeyPath<IdentityProxyConfig, Value>, default defaultValue: Value) -> Binding<Value> {
        Binding(
            get: { draftPackage?.proxy[keyPath: keyPath] ?? defaultValue },
            set: { newValue in
                draftPackage?.proxy[keyPath: keyPath] = newValue
            }
        )
    }

    private func proxyOptionalBinding(for keyPath: WritableKeyPath<IdentityProxyConfig, String?>) -> Binding<String> {
        Binding(
            get: { draftPackage?.proxy[keyPath: keyPath] ?? "" },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                draftPackage?.proxy[keyPath: keyPath] = trimmed.isEmpty ? nil : trimmed
            }
        )
    }

    private func syncDraftFromSelection() {
        draftPackage = selectedPackage
    }

    private func saveDraft() {
        guard var draftPackage else { return }
        draftPackage.name = draftPackage.name.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.updateIdentityPackage(draftPackage)
        syncDraftFromSelection()
    }

    private func deleteSelectedPackage() {
        guard let selectedPackageID else { return }
        viewModel.deleteIdentityPackage(id: selectedPackageID)
        self.selectedPackageID = viewModel.identityPackages.first?.id
        syncDraftFromSelection()
    }
}
