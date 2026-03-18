//
//  IdentityPackagesScreen.swift
//  Quotio
//

import SwiftUI

struct IdentityPackagesScreen: View {
    @Environment(QuotaViewModel.self) private var viewModel
    @State private var selectedPackageID: UUID?
    @State private var draftPackage: RuntimeIdentityPackage?
    @State private var draftProxyPassword = ""
    @State private var showDeleteConfirmation = false
    @State private var showImportSheet = false
    @State private var showGenerateSheet = false
    @State private var importResultMessage: String?

    private var selectedPackage: RuntimeIdentityPackage? {
        guard let selectedPackageID else { return viewModel.identityPackages.first }
        return viewModel.identityPackages.first(where: { $0.id == selectedPackageID }) ?? viewModel.identityPackages.first
    }

    private var hasUnsavedChanges: Bool {
        draftPackage != selectedPackage || draftProxyPassword != selectedProxyPassword
    }

    private var selectedProxyPassword: String {
        guard let selectedPackage else { return "" }
        return viewModel.identityPackageProxyPassword(for: selectedPackage.id)
    }

    private var canDeleteSelectedPackage: Bool {
        selectedPackage?.isBound == false
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
                            statusBadge(for: package.status)
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
                                if let statusReason = draftPackage.statusReason, !statusReason.isEmpty {
                                    detailRow(label: "Status Note", value: statusReason)
                                }
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

                                SecureField("Password", text: $draftProxyPassword)
                                    .textFieldStyle(.roundedBorder)

                                detailRow(
                                    label: "Password Storage",
                                    value: draftPackage.proxy.passwordRef == nil ? "Not stored" : "Stored in Keychain"
                                )

                                detailRow(
                                    label: "Password Ref",
                                    value: draftPackage.proxy.passwordRef ?? "Generated on save"
                                )

                                Text("代理密码会保存在 Keychain 中；模型里只保留 `passwordRef`。")
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
                                if let note = draftPackage.verification?.note, !note.isEmpty {
                                    detailRow(label: "Verification Note", value: note)
                                }

                                Text("这些状态按钮只记录 Quotio 本地运维状态，不代表真实运行时已经完成验证或强绑定。")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                HStack {
                                    Button("Mark Verification Failed") {
                                        markVerificationFailure()
                                    }
                                    .disabled(draftPackage.status == .verificationFailed)

                                    Button("Mark Blocked") {
                                        markBlocked()
                                    }
                                    .disabled(draftPackage.status == .blocked)

                                    Spacer()

                                    Button("Clear Local Status") {
                                        clearOperationalStatus()
                                    }
                                    .disabled(!canClearOperationalStatus)
                                }
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
                                .disabled(!canDeleteSelectedPackage)

                                Button("Save") {
                                    saveDraft()
                                }
                                .keyboardShortcut(.defaultAction)
                                .disabled(!canSaveDraft)
                            }

                            if !canDeleteSelectedPackage {
                                Text("已绑定身份包不可直接删除，请先解绑账号。")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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
        .sheet(isPresented: $showImportSheet) {
            ImportIdentityPackagesSheet { rawText in
                let result = viewModel.importIdentityPackages(from: rawText)
                importResultMessage = importMessage(for: result)
            }
        }
        .sheet(isPresented: $showGenerateSheet) {
            GenerateIdentityPackagesSheet { count, namePrefix in
                viewModel.createIdentityPackages(count: count, namePrefix: namePrefix)
                selectedPackageID = viewModel.identityPackages.first?.id
            }
        }
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
            ToolbarItem(placement: .automatic) {
                Button {
                    showImportSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .help("Import proxies as identity packages")
            }

            ToolbarItem(placement: .automatic) {
                Button {
                    showGenerateSheet = true
                } label: {
                    Image(systemName: "square.stack.3d.up.badge.a")
                }
                .help("Batch-generate identity packages")
            }

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
        .alert(
            "Import Result",
            isPresented: Binding(
                get: { importResultMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        importResultMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importResultMessage ?? "")
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

    private var canClearOperationalStatus: Bool {
        guard let draftPackage else { return false }
        switch draftPackage.status {
        case .verificationFailed, .blocked:
            return true
        case .draft, .available, .bound:
            return false
        }
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
        draftProxyPassword = selectedProxyPassword
    }

    private func saveDraft() {
        guard var draftPackage else { return }
        draftPackage.name = draftPackage.name.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.updateIdentityPackage(draftPackage, proxyPassword: draftProxyPassword)
        syncDraftFromSelection()
    }

    private func deleteSelectedPackage() {
        guard let selectedPackageID else { return }
        guard viewModel.deleteIdentityPackage(id: selectedPackageID) else { return }
        self.selectedPackageID = viewModel.identityPackages.first?.id
        syncDraftFromSelection()
    }

    private func markVerificationFailure() {
        guard let selectedPackageID else { return }
        viewModel.markIdentityPackageVerificationFailure(id: selectedPackageID)
        syncDraftFromSelection()
    }

    private func markBlocked() {
        guard let selectedPackageID else { return }
        viewModel.markIdentityPackageBlocked(id: selectedPackageID)
        syncDraftFromSelection()
    }

    private func clearOperationalStatus() {
        guard let selectedPackageID else { return }
        viewModel.clearIdentityPackageOperationalStatus(id: selectedPackageID)
        syncDraftFromSelection()
    }

    private func importMessage(for result: IdentityPackageImportResult) -> String {
        if result.issues.isEmpty {
            return "Imported \(result.importedCount) identity package(s)."
        }

        let issuePreview = result.issues.prefix(3).map { issue in
            "Line \(issue.lineNumber): \(issue.reason)"
        }.joined(separator: "\n")

        if result.importedCount == 0 {
            return """
            No identity packages were imported.

            \(issuePreview)
            """
        }

        let remainingCount = result.issues.count - min(result.issues.count, 3)
        let suffix = remainingCount > 0 ? "\nAnd \(remainingCount) more issue(s)." : ""

        return """
        Imported \(result.importedCount) identity package(s), skipped \(result.skippedCount).

        \(issuePreview)\(suffix)
        """
    }

    private func statusBadge(for status: IdentityPackageStatus) -> some View {
        Text(status.displayName)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(for: status).opacity(0.14), in: Capsule())
            .foregroundStyle(statusColor(for: status))
    }

    private func statusColor(for status: IdentityPackageStatus) -> Color {
        switch status {
        case .draft:
            return .secondary
        case .available:
            return .blue
        case .bound:
            return .green
        case .verificationFailed:
            return .orange
        case .blocked:
            return .red
        }
    }
}
