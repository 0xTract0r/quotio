//
//  IdentityPackagesScreen.swift
//  Quotio
//

import SwiftUI

struct IdentityPackagesScreen: View {
    @Environment(QuotaViewModel.self) private var viewModel
    @State private var modeManager = OperatingModeManager.shared
    @State private var selectedPackageID: UUID?
    @State private var draftPackage: RuntimeIdentityPackage?
    @State private var draftProxyPassword = ""
    @State private var showDeleteConfirmation = false
    @State private var showImportSheet = false
    @State private var showGenerateSheet = false
    @State private var importResultMessage: String?
    @State private var isMigratingLegacyPackages = false
    @State private var didEmitEmptyStateSmokeLog = false
    @State private var didRunFixtureFlowSmoke = false
    @State private var isRunningFixtureFlowSmoke = false
    @State private var didLoadStoredProxyPassword = false
    @State private var proxyPasswordDirty = false

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

    private var isRemoteMode: Bool {
        modeManager.currentMode.usesRemoteConnection
    }

    private var hasStoredProxyPassword: Bool {
        selectedPackage?.proxy.passwordRef != nil
    }

    private var proxyPasswordBinding: Binding<String> {
        Binding(
            get: { draftProxyPassword },
            set: { newValue in
                draftProxyPassword = newValue
                proxyPasswordDirty = true
                didLoadStoredProxyPassword = true
            }
        )
    }

    private var canDeleteSelectedPackage: Bool {
        selectedPackage?.isBound == false
    }

    private var isIsolatedRuntime: Bool {
        !RuntimeProfile.isPrimaryApp
    }

    var body: some View {
        Group {
            if viewModel.identityPackages.isEmpty {
                emptyStateView
            } else {
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
                                    if isRemoteMode {
                                        remoteModeBanner
                                    }

                                    if isIsolatedRuntime {
                                        runtimeScopeBanner
                                    }

                                    detailSection(title: "Overview") {
                                        TextField("Identity package name", text: binding(for: \.name, default: ""))
                                            .textFieldStyle(.roundedBorder)

                                        Text("Notes")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        TextEditor(text: optionalStringBinding(for: \.note))
                                            .frame(minHeight: 80)
                                            .padding(8)
                                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))

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

                                        SecureField("Password", text: proxyPasswordBinding)
                                            .textFieldStyle(.roundedBorder)

                                        detailRow(
                                            label: "Password Storage",
                                            value: draftPackage.proxy.passwordRef == nil ? "Not stored" : "Stored in Keychain"
                                        )

                                        if hasStoredProxyPassword {
                                            HStack(spacing: 12) {
                                                Button(didLoadStoredProxyPassword ? "Reload Saved Password" : "Load Saved Password") {
                                                    loadStoredProxyPassword()
                                                }
                                                .buttonStyle(.bordered)

                                                Text(
                                                    didLoadStoredProxyPassword
                                                        ? "Loaded from this Quotio instance's local Keychain."
                                                        : "Not auto-loaded to avoid an unexpected local Keychain prompt."
                                                )
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            }
                                        }

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
                            emptyStateView
                        }
                    }
                    .frame(minWidth: 420)
                }
            }
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
            if RuntimeProfile.identityPackagesEmptyStateSmokeEnabled || RuntimeProfile.identityPackagesFixtureFlowSmokeEnabled {
                uiSmokeLog("identity-screen-appeared count=\(viewModel.identityPackages.count)")
            }
            if selectedPackageID == nil {
                selectedPackageID = viewModel.identityPackages.first?.id
            }
            syncDraftFromSelection()
            scheduleFixtureFlowSmokeIfNeeded()
        }
        .onChange(of: selectedPackageID) { _, _ in
            syncDraftFromSelection()
            scheduleFixtureFlowSmokeIfNeeded()
        }
        .onChange(of: viewModel.identityPackages) { _, _ in
            if selectedPackage == nil {
                selectedPackageID = viewModel.identityPackages.first?.id
            }
            syncDraftFromSelection()
            if viewModel.identityPackages.isEmpty {
                didRunFixtureFlowSmoke = false
            }
            scheduleFixtureFlowSmokeIfNeeded()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    Task { await migrateLegacyPackages() }
                } label: {
                    Image(systemName: "arrow.down.doc")
                }
                .help("Migrate existing account identity data into identity packages")
                .disabled(isMigratingLegacyPackages)
            }

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

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("No Identity Packages")
                    .font(.title3.weight(.semibold))

                Text("Create, batch-generate, or import identity packages before binding them to provider accounts.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
            }

            if isIsolatedRuntime {
                runtimeScopeBanner
                    .frame(maxWidth: 560)
            }

            ViewThatFits {
                HStack(spacing: 12) {
                    migrateLegacyPackagesButton
                    createPackageButton
                    generatePackagesButton
                    importPackagesButton
                }

                VStack(spacing: 12) {
                    migrateLegacyPackagesButton
                    createPackageButton
                    generatePackagesButton
                    importPackagesButton
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .onAppear {
            emitEmptyStateSmokeLogIfNeeded()
        }
    }

    private var runtimeScopeBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "externaldrive.badge.person.crop")
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 6) {
                Text("当前是隔离运行时")
                    .font(.subheadline.weight(.semibold))

                Text("当前实例使用 `\(RuntimeProfile.bundleIdentifier)` 命名空间。身份包只保存在这个实例自己的本地记录里，不会显示正式版 Quotio 的身份包。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var remoteModeBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "externaldrive.badge.icloud")
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 6) {
                Text("Remote mode still uses local identity packages")
                    .font(.subheadline.weight(.semibold))

                Text("Providers, logs, usage, and API keys come from the remote core. Identity packages and their saved proxy passwords still belong to this local Quotio instance.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var createPackageButton: some View {
        Button {
            viewModel.createIdentityPackage()
            selectedPackageID = viewModel.identityPackages.first?.id
        } label: {
            Label("Create Identity Package", systemImage: "plus")
        }
        .buttonStyle(.borderedProminent)
    }

    private var migrateLegacyPackagesButton: some View {
        Button {
            Task { await migrateLegacyPackages() }
        } label: {
            if isMigratingLegacyPackages {
                Label("Migrating…", systemImage: "arrow.triangle.2.circlepath")
            } else {
                Label("Migrate Existing Accounts", systemImage: "arrow.down.doc")
            }
        }
        .buttonStyle(.bordered)
        .disabled(isMigratingLegacyPackages)
    }

    private var generatePackagesButton: some View {
        Button {
            showGenerateSheet = true
        } label: {
            Label("Batch Generate", systemImage: "square.stack.3d.up.badge.a")
        }
        .buttonStyle(.bordered)
    }

    private var importPackagesButton: some View {
        Button {
            showImportSheet = true
        } label: {
            Label("Import Proxies", systemImage: "square.and.arrow.down")
        }
        .buttonStyle(.bordered)
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

    private func optionalStringBinding(for keyPath: WritableKeyPath<RuntimeIdentityPackage, String?>) -> Binding<String> {
        Binding(
            get: { draftPackage?[keyPath: keyPath] ?? "" },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                draftPackage?[keyPath: keyPath] = trimmed.isEmpty ? nil : trimmed
            }
        )
    }

    private func syncDraftFromSelection() {
        draftPackage = selectedPackage
        proxyPasswordDirty = false

        // Remote mode keeps identity-package data local today, so do not auto-read the
        // saved proxy password from Keychain just by opening this detail view.
        if isRemoteMode {
            draftProxyPassword = ""
            didLoadStoredProxyPassword = false
        } else {
            draftProxyPassword = selectedProxyPassword
            didLoadStoredProxyPassword = hasStoredProxyPassword
        }
    }

    private func scheduleFixtureFlowSmokeIfNeeded() {
        guard RuntimeProfile.identityPackagesFixtureFlowSmokeEnabled else {
            return
        }

        Task { @MainActor in
            await runFixtureFlowSmokeIfNeeded()
        }
    }

    private func emitEmptyStateSmokeLogIfNeeded() {
        guard RuntimeProfile.identityPackagesEmptyStateSmokeEnabled,
              !didEmitEmptyStateSmokeLog,
              viewModel.identityPackages.isEmpty else {
            return
        }

        didEmitEmptyStateSmokeLog = true
        uiSmokeLog(
            "identity-empty-state-ready bundle=\(RuntimeProfile.bundleIdentifier) isolated=\(!RuntimeProfile.isPrimaryApp) actions=migrate,create,generate,import"
        )
    }

    private func runFixtureFlowSmokeIfNeeded() async {
        guard RuntimeProfile.identityPackagesFixtureFlowSmokeEnabled,
              !didRunFixtureFlowSmoke,
              !isRunningFixtureFlowSmoke,
              selectedPackageID != nil,
              draftPackage != nil else {
            return
        }

        isRunningFixtureFlowSmoke = true
        didRunFixtureFlowSmoke = true
        defer { isRunningFixtureFlowSmoke = false }

        uiSmokeLog(
            "identity-fixture-ready name=\(selectedPackage?.name ?? "unknown") status=\(selectedPackage?.status.rawValue ?? "unknown")"
        )

        draftPackage?.proxy.host = "updated.identity.local"
        draftPackage?.proxy.port = 8443
        saveDraft()
        uiSmokeLog(
            "identity-fixture-saved host=\(selectedPackage?.proxy.host ?? "unknown") port=\(selectedPackage?.proxy.port ?? 0)"
        )

        markBlocked()
        uiSmokeLog("identity-fixture-blocked status=\(selectedPackage?.status.rawValue ?? "unknown")")

        clearOperationalStatus()
        uiSmokeLog("identity-fixture-cleared status=\(selectedPackage?.status.rawValue ?? "unknown")")
    }

    private func uiSmokeLog(_ message: String) {
        #if DEBUG
        RuntimeIsolationDebugLog.write("[ui-smoke] \(message)")
        #endif
    }

    private func saveDraft() {
        guard var draftPackage else { return }
        draftPackage.name = draftPackage.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let proxyPasswordToPersist = proxyPasswordDirty ? draftProxyPassword : nil
        viewModel.updateIdentityPackage(draftPackage, proxyPassword: proxyPasswordToPersist)
        syncDraftFromSelection()
    }

    private func loadStoredProxyPassword() {
        draftProxyPassword = selectedProxyPassword
        didLoadStoredProxyPassword = true
        proxyPasswordDirty = false
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

    private func migrateLegacyPackages() async {
        guard !isMigratingLegacyPackages else { return }
        isMigratingLegacyPackages = true
        defer { isMigratingLegacyPackages = false }

        let result = await viewModel.migrateLegacyIdentityPackages()
        if result.migratedCount > 0 {
            selectedPackageID = viewModel.identityPackages.first?.id
        }
        importResultMessage = migrationMessage(for: result)
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

    private func migrationMessage(for result: IdentityPackageMigrationResult) -> String {
        if result.migratedCount == 0 {
            return "No legacy account identity data was migrated."
        }
        return "Migrated \(result.migratedCount) identity package(s). Skipped \(result.skippedCount) account(s) that were already bound or had no legacy identity data."
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
