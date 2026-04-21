//
//  ProvidersScreen.swift
//  Quotio
//
//  Redesigned ProvidersScreen with improved UI/UX:
//  - Consolidated from 5-6 sections to 2 main sections
//  - Accounts grouped by provider using DisclosureGroup
//  - Add Provider moved to toolbar popover
//  - IDE Scan integrated into toolbar and empty state
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ProvidersScreen: View {
    @Environment(QuotaViewModel.self) private var viewModel
    @State private var isImporterPresented = false
    @State private var selectedProvider: AIProvider?
    @State private var projectId: String = ""
    @State private var showProxyRequiredAlert = false
    @State private var showIDEScanSheet = false
    @State private var customProviderSheetMode: CustomProviderSheetMode?
    @State private var showWarpConnectionSheet = false
    @State private var editingWarpToken: WarpService.WarpToken?
    @State private var showAddProviderPopover = false
    @State private var switchingAccount: AccountRowData?
    @State private var accountSettingsEditor: AccountSettingsEditorContext?
    @State private var didApplyLaunchAutomation = false
    @State private var bindingTargetAuthFile: AuthFile?
    @State private var accountMetadataStore = AccountMetadataStore.shared
    @State private var modeManager = OperatingModeManager.shared

    private let customProviderService = CustomProviderService.shared
    private let warpService = WarpService.shared
    
    // MARK: - Computed Properties
    
    /// Providers that can be added manually
    private var addableProviders: [AIProvider] {
        if modeManager.isLocalProxyMode {
            return AIProvider.allCases.filter { $0.supportsManualAuth }
        } else if modeManager.isRemoteProxyMode {
            return AIProvider.allCases.filter { $0.supportsManualAuth && $0.supportsRemoteCoreMode }
        } else {
            return AIProvider.allCases.filter { $0.supportsQuotaOnlyMode && $0.supportsManualAuth }
        }
    }
    
    /// All accounts grouped by provider
    private var groupedAccounts: [AIProvider: [AccountRowData]] {
        var groups: [AIProvider: [AccountRowData]] = [:]

        if (modeManager.isLocalProxyMode && viewModel.proxyManager.proxyStatus.running) || modeManager.isRemoteProxyMode {
            // From management-backed auth files (local proxy running or remote core connected)
            for file in viewModel.authFiles {
                guard let provider = file.providerType else { continue }
                let metadataKey = accountMetadataKey(for: file)
                let data = AccountRowData.from(
                    authFile: file,
                    metadataKey: metadataKey,
                    remark: resolvedAccountRemark(for: metadataKey),
                    hasConfiguredProxy: effectiveProxyURL(for: file) != nil,
                    identityPackage: modeManager.isLocalProxyMode ? viewModel.identityPackage(for: file) : nil,
                    supportsIdentityBinding: modeManager.isLocalProxyMode
                )
                groups[provider, default: []].append(data)
            }
        } else {
            // From direct auth files (proxy not running or quota-only mode)
            for file in viewModel.directAuthFiles {
                let metadataKey = accountMetadataKey(for: file)
                let data = AccountRowData.from(
                    directAuthFile: file,
                    metadataKey: metadataKey,
                    remark: resolvedAccountRemark(for: metadataKey)
                )
                groups[file.provider, default: []].append(data)
            }
        }

        // Add auto-detected accounts (Cursor, Trae)
        // Note: GLM uses API key auth via CustomProviderService, so skip it here
        for (provider, quotas) in viewModel.providerQuotas {
            if !provider.supportsManualAuth && provider != .glm {
                for (accountKey, _) in quotas {
                    let metadataKey = AccountMetadataStore.autoDetectedKey(provider: provider, accountKey: accountKey)
                    let data = AccountRowData.from(
                        provider: provider,
                        accountKey: accountKey,
                        metadataKey: metadataKey,
                        remark: resolvedAccountRemark(for: metadataKey)
                    )
                    groups[provider, default: []].append(data)
                }
            }
        }

        // Add GLM providers from CustomProviderService
        for glmProvider in customProviderService.providers.filter({ $0.type == .glmCompatibility && $0.isEnabled }) {
            // Use provider name as display name (store provider ID for editing)
            let metadataKey = AccountMetadataStore.customAccountKey(provider: .glm, id: glmProvider.id.uuidString)
            let data = AccountRowData(
                id: glmProvider.id.uuidString,
                provider: .glm,
                displayName: glmProvider.name.isEmpty ? "GLM" : glmProvider.name,
                menuBarAccountKey: glmProvider.name,
                metadataKey: metadataKey,
                remark: resolvedAccountRemark(for: metadataKey),
                source: .direct,
                status: "ready",
                statusMessage: nil,
                isDisabled: false,
                hasConfiguredProxy: false,
                canToggleDisabled: false,
                canDelete: true,
                canEdit: true
            )
            groups[.glm, default: []].append(data)
        }

        // Add Warp providers from WarpService
        for warpToken in warpService.tokens.filter({ $0.isEnabled }) {
            let metadataKey = AccountMetadataStore.customAccountKey(provider: .warp, id: warpToken.id.uuidString)
            let data = AccountRowData(
                id: warpToken.id.uuidString,
                provider: .warp,
                displayName: warpToken.name.isEmpty ? "Warp" : warpToken.name,
                menuBarAccountKey: warpToken.name,
                metadataKey: metadataKey,
                remark: resolvedAccountRemark(for: metadataKey),
                source: .direct,
                status: "ready",
                statusMessage: nil,
                isDisabled: false,
                hasConfiguredProxy: false,
                canToggleDisabled: false,
                canDelete: true,
                canEdit: true
            )
            groups[.warp, default: []].append(data)
        }

        for provider in groups.keys {
            groups[provider] = sortedAccounts(groups[provider] ?? [], for: provider)
        }

        return groups
    }
    
    /// Sorted providers for consistent display order
    private var sortedProviders: [AIProvider] {
        groupedAccounts.keys.sorted { $0.displayName < $1.displayName }
    }
    
    /// Total account count across all providers
    private var totalAccountCount: Int {
        groupedAccounts.values.reduce(0) { $0 + $1.count }
    }

    private var launchAutomationSignature: String {
        let allAccounts = groupedAccounts.values.flatMap { $0 }
        let markers = allAccounts.map { account in
            account.id + "|" + account.provider.rawValue + "|" + String(describing: account.source) + "|" + account.primaryDisplayTitle
        }
        return markers.sorted().joined(separator: "||")
    }

    /// Account count per provider (for AddProviderPopover badge display)
    private var providerAccountCounts: [AIProvider: Int] {
        groupedAccounts.mapValues { $0.count }
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            // Section 1: Your Accounts (grouped by provider)
            accountsSection
            
            // Section 2: Custom Providers (Local Proxy Mode only)
            if modeManager.isLocalProxyMode {
                customProvidersSection
            }
        }
        .navigationTitle(modeManager.isMonitorMode ? "nav.accounts".localized() : "nav.providers".localized())
        .toolbar {
            toolbarContent
        }
        .sheet(item: $selectedProvider) { provider in
            OAuthSheet(provider: provider, projectId: $projectId) {
                selectedProvider = nil
                projectId = ""
            }
            .environment(viewModel)
        }
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                Task { await viewModel.importVertexServiceAccount(url: url) }
            }
            // Failure case is silently ignored - user can retry via UI
        }
        .task {
            await viewModel.loadProvidersScreenData()
            applyLaunchAutomationIfNeeded()
        }
        .onChange(of: launchAutomationSignature) { _, _ in
            applyLaunchAutomationIfNeeded()
        }
        .alert("providers.proxyRequired.title".localized(), isPresented: $showProxyRequiredAlert) {
            Button("action.startProxy".localized()) {
                Task { await viewModel.startProxy() }
            }
            Button("action.cancel".localized(), role: .cancel) {}
        } message: {
            Text("providers.proxyRequired.message".localized())
        }
        .sheet(isPresented: $showIDEScanSheet) {
            IDEScanSheet {}
            .environment(viewModel)
        }
        .sheet(item: $customProviderSheetMode) { mode in
            CustomProviderSheet(provider: mode.provider) { provider in
                // Check if provider already exists by ID to determine if we're updating or adding
                if customProviderService.providers.contains(where: { $0.id == provider.id }) {
                    customProviderService.updateProvider(provider)
                } else {
                    customProviderService.addProvider(provider)
                }
                syncCustomProvidersToConfig()
            }
        }
        .sheet(isPresented: $showWarpConnectionSheet) {
            WarpConnectionSheet(token: editingWarpToken) { name, token in
                if let existing = editingWarpToken {
                    var updated = existing
                    updated.name = name
                    updated.token = token
                    warpService.updateToken(updated)
                } else {
                    warpService.addToken(name: name, token: token)
                }
                editingWarpToken = nil
                Task { await viewModel.refreshAutoDetectedProviders() }
            }
        }
        .sheet(isPresented: $showAddProviderPopover) {
            AddProviderPopover(
                providers: addableProviders,
                existingCounts: providerAccountCounts,
                onSelectProvider: { provider in
                    handleAddProvider(provider)
                },
                onScanIDEs: {
                    showIDEScanSheet = true
                },
                onAddCustomProvider: {
                    customProviderSheetMode = .add
                },
                onDismiss: {
                    showAddProviderPopover = false
                }
            )
        }
        .sheet(item: $switchingAccount) { account in
            SwitchAccountSheet(
                accountEmail: account.displayName,
                onDismiss: {
                    switchingAccount = nil
                }
            )
            .environment(viewModel)
        }
        .sheet(item: $accountSettingsEditor) { context in
            AccountSettingsSheet(context: context)
                .environment(viewModel)
        }
        .sheet(item: $bindingTargetAuthFile) { authFile in
            BindIdentityPackageSheet(authFile: authFile)
                .environment(viewModel)
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showAddProviderPopover = true
            } label: {
                Image(systemName: "plus")
            }
            .help("providers.addAccount".localized())
        }
        
        ToolbarItem(placement: .automatic) {
            Button {
                Task {
                    if modeManager.isLocalProxyMode && viewModel.proxyManager.proxyStatus.running {
                        await viewModel.refreshData()
                        await viewModel.loadDirectAuthFiles()
                    } else {
                        await viewModel.loadDirectAuthFiles()
                    }
                    await viewModel.refreshAutoDetectedProviders()
                }
            } label: {
                if viewModel.isLoadingQuotas {
                    SmallProgressView()
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .disabled(viewModel.isLoadingQuotas)
            .help("action.refresh".localized())
        }
    }
    
    // MARK: - Accounts Section
    
    @ViewBuilder
    private var accountsSection: some View {
        Section {
            if groupedAccounts.isEmpty {
                // Empty state
                AccountsEmptyState(
                    onScanIDEs: {
                        showIDEScanSheet = true
                    },
                    onAddProvider: {
                        showAddProviderPopover = true
                    }
                )
            } else {
                // Grouped accounts by provider
                ForEach(sortedProviders, id: \.self) { provider in
                    ProviderDisclosureGroup(
                        provider: provider,
                        accounts: groupedAccounts[provider] ?? [],
                        onMoveAccount: { source, destination in
                            moveAccounts(in: provider, from: source, to: destination)
                        },
                        onDeleteAccount: { account in
                            Task { await deleteAccount(account) }
                        },
                        onEditAccount: { account in
                            if provider == .glm {
                                handleEditGlmAccount(account)
                            } else if provider == .warp {
                                handleEditWarpAccount(account)
                            }
                        },
                        onConfigureSettings: { account in
                            handleConfigureAccountSettings(account)
                        },
                        onSwitchAccount: provider == .antigravity ? { account in
                            switchingAccount = account
                        } : nil,
                        onToggleDisabled: { account in
                            Task { await toggleAccountDisabled(account) }
                        },
                        onManageIdentityBinding: { account in
                            openIdentityBinding(for: account)
                        },
                        onUnbindIdentityBinding: { account in
                            unbindIdentityBinding(for: account)
                        },
                        isAccountActive: provider == .antigravity ? { account in
                            viewModel.isAntigravityAccountActive(email: account.displayName)
                        } : nil
                    )
                }
            }
        } header: {
            HStack {
                Label("providers.yourAccounts".localized(), systemImage: "person.2.badge.key")
                
                if totalAccountCount > 0 {
                    Spacer()
                    Text("\(totalAccountCount)")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        } footer: {
            if !groupedAccounts.isEmpty {
                MenuBarHintView()
            }
        }
    }
    
    // MARK: - Custom Providers Section

    @ViewBuilder
    private var customProvidersSection: some View {
        // Filter out GLM providers (they're shown in Your Accounts section)
        let nonGlmProviders = customProviderService.providers.filter { $0.type != .glmCompatibility }

        Section {
            // List existing custom providers
            ForEach(nonGlmProviders) { provider in
                CustomProviderRow(
                    provider: provider,
                    onEdit: {
                        customProviderSheetMode = .edit(provider)
                    },
                    onDelete: {
                        customProviderService.deleteProvider(id: provider.id)
                        syncCustomProvidersToConfig()
                    },
                    onToggle: {
                        customProviderService.toggleProvider(id: provider.id)
                        syncCustomProvidersToConfig()
                    }
                )
            }
        } header: {
            HStack {
                Label("customProviders.title".localized(), systemImage: "puzzlepiece.extension.fill")

                if !nonGlmProviders.isEmpty {
                    Spacer()
                    Text("\(nonGlmProviders.count)")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        } footer: {
            Text("customProviders.footer".localized())
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
    
    // MARK: - Helper Functions

    private func handleAddProvider(_ provider: AIProvider) {
        // In Local Proxy Mode, require proxy to be running for OAuth
        if modeManager.isLocalProxyMode && !viewModel.proxyManager.proxyStatus.running {
            showProxyRequiredAlert = true
            return
        }

        if provider == .vertex {
            isImporterPresented = true
        } else if provider == .warp {
            editingWarpToken = nil
            showWarpConnectionSheet = true
        } else {
            Task {
                let result = await viewModel.cancelOAuth()
                guard result.didCancel else {
                    return
                }
                selectedProvider = provider
            }
        }
    }

    private func accountMetadataKey(for authFile: AuthFile) -> String {
        guard let provider = authFile.providerType else {
            return AccountMetadataStore.authFileKey(provider: .gemini, fileName: authFile.name)
        }
        return AccountMetadataStore.authFileKey(provider: provider, fileName: authFile.name)
    }

    private func accountMetadataKey(for directAuthFile: DirectAuthFile) -> String {
        AccountMetadataStore.authFileKey(provider: directAuthFile.provider, fileName: directAuthFile.filename)
    }

    private func resolvedAccountRemark(for metadataKey: String) -> String? {
        accountMetadataStore.remark(for: metadataKey)
            ?? providersMetadataFallbackUserDefaults().flatMap { AccountMetadataStore.remark(for: metadataKey, in: $0) }
    }

    private func effectiveProxyURL(for authFile: AuthFile) -> String? {
        guard let directAuthFile = viewModel.directAuthFiles.first(where: { $0.filename == authFile.name }) else {
            return nil
        }
        return directAuthFile.proxyURL
    }

    private func sortedAccounts(_ accounts: [AccountRowData], for provider: AIProvider) -> [AccountRowData] {
        let orderedKeys = accountMetadataStore.orderedKeys(for: provider)
        let rankByKey = Dictionary(uniqueKeysWithValues: orderedKeys.enumerated().map { ($1, $0) })

        return accounts.sorted { lhs, rhs in
            let lhsRank = rankByKey[lhs.metadataKey]
            let rhsRank = rankByKey[rhs.metadataKey]

            switch (lhsRank, rhsRank) {
            case let (left?, right?) where left != right:
                return left < right
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            default:
                let leftTitle = lhs.remark ?? lhs.displayName
                let rightTitle = rhs.remark ?? rhs.displayName
                return leftTitle.localizedCaseInsensitiveCompare(rightTitle) == .orderedAscending
            }
        }
    }

    private func moveAccounts(in provider: AIProvider, from source: IndexSet, to destination: Int) {
        guard var accounts = groupedAccounts[provider], !accounts.isEmpty else {
            return
        }

        accounts.move(fromOffsets: source, toOffset: destination)
        accountMetadataStore.setOrderedKeys(accounts.map(\.metadataKey), for: provider)
    }
    
    private func deleteAccount(_ account: AccountRowData) async {
        // Only proxy accounts can be deleted via API
        guard account.canDelete else { return }

        // Handle GLM accounts (stored in CustomProviderService)
        if account.provider == .glm {
            // GLM accounts are stored as custom providers
            // Find the GLM provider by ID and delete it
            if let glmProvider = customProviderService.providers.first(where: { $0.id.uuidString == account.id }) {
                customProviderService.deleteProvider(id: glmProvider.id)
                accountMetadataStore.removeRemark(for: account.metadataKey)
                accountMetadataStore.removeFingerprintProfile(for: account.metadataKey)
                accountMetadataStore.removeAccountFromOrder(account.metadataKey, for: account.provider)
                syncCustomProvidersToConfig()
            }
            return
        }
        
        // Handle Warp accounts (stored in WarpService)
        if account.provider == .warp {
            if let uuid = UUID(uuidString: account.id) {
                warpService.deleteToken(id: uuid)
                accountMetadataStore.removeRemark(for: account.metadataKey)
                accountMetadataStore.removeFingerprintProfile(for: account.metadataKey)
                accountMetadataStore.removeAccountFromOrder(account.metadataKey, for: account.provider)
                await viewModel.refreshQuotaForProvider(.warp)
            }
            return
        }

        if let authFile = viewModel.authFiles.first(where: { $0.id == account.id }) {
            await viewModel.deleteAuthFile(authFile)
            accountMetadataStore.removeRemark(for: account.metadataKey)
            accountMetadataStore.removeFingerprintProfile(for: account.metadataKey)
            accountMetadataStore.removeAccountFromOrder(account.metadataKey, for: account.provider)
            return
        }

        if let directAuthFile = viewModel.directAuthFiles.first(where: { $0.id == account.id }) {
            await viewModel.deleteDirectAuthFile(directAuthFile)
            accountMetadataStore.removeRemark(for: account.metadataKey)
            accountMetadataStore.removeFingerprintProfile(for: account.metadataKey)
            accountMetadataStore.removeAccountFromOrder(account.metadataKey, for: account.provider)
        }
    }

    private func toggleAccountDisabled(_ account: AccountRowData) async {
        if let authFile = viewModel.authFiles.first(where: { $0.id == account.id }) {
            await viewModel.toggleAuthFileDisabled(authFile)
            return
        }

        if let directAuthFile = viewModel.directAuthFiles.first(where: { $0.id == account.id }) {
            await viewModel.toggleDirectAuthFileDisabled(directAuthFile)
        }
    }

    private func openIdentityBinding(for account: AccountRowData) {
        guard account.supportsIdentityBinding,
              let authFile = viewModel.authFiles.first(where: { $0.id == account.id }) else {
            return
        }

        bindingTargetAuthFile = authFile
    }

    private func unbindIdentityBinding(for account: AccountRowData) {
        guard account.supportsIdentityBinding,
              let authFile = viewModel.authFiles.first(where: { $0.id == account.id }) else {
            return
        }

        viewModel.unbindIdentityPackage(from: authFile)
    }

    private func handleEditGlmAccount(_ account: AccountRowData) {
        // Find the GLM provider by ID and open edit sheet using CustomProviderSheet
        if let glmProvider = customProviderService.providers.first(where: { $0.id.uuidString == account.id }) {
            customProviderSheetMode = .edit(glmProvider)
        }
    }
    
    private func handleEditWarpAccount(_ account: AccountRowData) {
        // Find the Warp token by ID and open edit sheet
        if let token = warpService.tokens.first(where: { $0.id.uuidString == account.id }) {
            editingWarpToken = token
            showWarpConnectionSheet = true
        }
    }

    private func handleConfigureAccountSettings(_ account: AccountRowData) {
        if let authFile = viewModel.authFiles.first(where: { $0.id == account.id }) {
            accountSettingsEditor = AccountSettingsEditorContext(
                id: account.id,
                provider: account.provider,
                displayName: account.displayName,
                remark: account.remark,
                metadataKey: account.metadataKey,
                supportsProxy: account.canConfigureProxy,
                authFile: authFile,
                directAuthFile: nil
            )
            return
        }

        if let directAuthFile = viewModel.directAuthFiles.first(where: { $0.id == account.id }) {
            accountSettingsEditor = AccountSettingsEditorContext(
                id: account.id,
                provider: account.provider,
                displayName: account.displayName,
                remark: account.remark,
                metadataKey: account.metadataKey,
                supportsProxy: account.canConfigureProxy,
                authFile: nil,
                directAuthFile: directAuthFile
            )
            return
        }

        if account.canConfigureProxy {
            viewModel.errorMessage = "providers.accountProxy.missing".localized()
            return
        }

        accountSettingsEditor = AccountSettingsEditorContext(
            id: account.id,
            provider: account.provider,
            displayName: account.displayName,
            remark: account.remark,
            metadataKey: account.metadataKey,
            supportsProxy: false,
            authFile: nil,
            directAuthFile: nil
        )
    }

    private func applyLaunchAutomationIfNeeded() {
        guard !didApplyLaunchAutomation else {
            return
        }

        let allAccounts = groupedAccounts.values.flatMap { $0 }
        if let identityBindingQuery = RuntimeProfile.autoOpenIdentityBindingQuery?.trimmingCharacters(in: .whitespacesAndNewlines),
           !identityBindingQuery.isEmpty {
            let matchingAccounts = matchingLaunchAutomationAccounts(
                for: identityBindingQuery,
                in: allAccounts
            )

            guard let proxyAccount = matchingAccounts.first(where: { $0.source == .proxy && $0.supportsIdentityBinding }) else {
                return
            }

            didApplyLaunchAutomation = true
            if RuntimeProfile.providersIdentityBindingSmokeEnabled {
                uiSmokeLog(
                    "providers-identity-row-ready auth=\(proxyAccount.id) " +
                    "title=\(proxyAccount.primaryDisplayTitle) " +
                    "remark_visible=\(proxyAccount.remark != nil) " +
                    "email_secondary=\(proxyAccount.primaryDisplayTitle != proxyAccount.displayName) " +
                    "supports_binding=\(proxyAccount.supportsIdentityBinding) " +
                    "identity_badge=\(proxyAccount.identityPackage?.name ?? "unbound")"
                )
            }
            openIdentityBinding(for: proxyAccount)
            return
        }

        guard let accountSettingsQuery = RuntimeProfile.autoOpenAccountSettingsQuery?.trimmingCharacters(in: .whitespacesAndNewlines),
              !accountSettingsQuery.isEmpty else {
            return
        }
        let matchingAccounts = matchingLaunchAutomationAccounts(for: accountSettingsQuery, in: allAccounts)

        if matchingAccounts.isEmpty {
            return
        }

        if let proxyAccount = matchingAccounts.first(where: { $0.source == .proxy }) {
            didApplyLaunchAutomation = true
            handleConfigureAccountSettings(proxyAccount)
            return
        }

        // 对支持重认证的 provider，优先等待 proxy 上下文，避免误打开 direct-only 设置页。
        if matchingAccounts.contains(where: { $0.provider.supportsOAuthReauthentication }) {
            return
        }

        didApplyLaunchAutomation = true
        handleConfigureAccountSettings(matchingAccounts[0])
    }

    private func matchingLaunchAutomationAccounts(
        for query: String,
        in allAccounts: [AccountRowData]
    ) -> [AccountRowData] {
        let normalizedQuery = query.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        return allAccounts.filter { account in
            let candidates = [
                account.id,
                account.metadataKey,
                account.displayName,
                account.remark,
                account.primaryDisplayTitle
            ].compactMap { $0?.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) }

            return candidates.contains(where: { candidate in
                candidate == normalizedQuery || candidate.localizedCaseInsensitiveContains(normalizedQuery)
            })
        }
    }

    private func uiSmokeLog(_ message: String) {
        #if DEBUG
        RuntimeIsolationDebugLog.write("[ui-smoke] \(message)")
        #endif
    }

    private func syncCustomProvidersToConfig() {
        // Silent failure - custom provider sync is non-critical
        // Config will be synced on next proxy start
        try? customProviderService.syncToConfigFile(configPath: viewModel.proxyManager.configPath)
    }
}

private func providersMetadataFallbackUserDefaults() -> UserDefaults? {
    guard !RuntimeProfile.isPrimaryApp else { return nil }
    return UserDefaults(suiteName: RuntimeProfile.primaryBundleIdentifier)
}

@MainActor
private func providersResolvedRemark(
    for metadataKey: String,
    store: AccountMetadataStore
) -> String? {
    store.remark(for: metadataKey)
        ?? providersMetadataFallbackUserDefaults().flatMap { AccountMetadataStore.remark(for: metadataKey, in: $0) }
}

@MainActor
private func providersResolvedFingerprintProfile(
    for metadataKey: String,
    store: AccountMetadataStore
) -> AccountFingerprintProfile? {
    store.fingerprintProfile(for: metadataKey)
        ?? providersMetadataFallbackUserDefaults().flatMap { AccountMetadataStore.fingerprintProfile(for: metadataKey, in: $0) }
}

private struct AccountSettingsEditorContext: Identifiable {
    let id: String
    let provider: AIProvider
    let displayName: String
    let remark: String?
    let metadataKey: String
    let supportsProxy: Bool
    let authFile: AuthFile?
    let directAuthFile: DirectAuthFile?
}

private enum AuthStatusRefreshFeedbackTone {
    case success
    case warning
    case error
}

private struct AccountSettingsSheet: View {
    @Environment(QuotaViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    let context: AccountSettingsEditorContext

    @State private var accountMetadataStore = AccountMetadataStore.shared
    @State private var remark = ""
    @State private var proxyURL = ""
    @State private var fingerprintProfile: AccountFingerprintProfile?
    @State private var validation: ProxyURLValidationResult = .empty
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var loadError: String?
    @State private var saveError: String?
    @State private var showFingerprintDetails = false
    @State private var showRegenerateConfirmation = false
    @State private var showReauthConfirmation = false
    @State private var copiedOAuthLink = false
    @State private var reauthHistoryEvents: [OAuthReauthHistoryEvent] = []
    @State private var isLoadingReauthHistory = false
    @State private var reauthHistoryError: String?
    @State private var isRefreshingAuthStatus = false
    @State private var authStatusRefreshFeedback: String?
    @State private var authStatusRefreshFeedbackTone: AuthStatusRefreshFeedbackTone = .success
    @State private var didRunProvidersReauthSmoke = false

    private var headerTitle: String {
        let remark = context.remark?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let remark, !remark.isEmpty else {
            return context.displayName
        }
        return remark
    }

    private var headerSubtitle: String? {
        guard headerTitle != context.displayName else {
            return nil
        }
        return context.displayName
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        ProviderIcon(provider: context.provider, size: 28)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("providers.accountSettings.title".localized())
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(headerTitle)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            if let headerSubtitle {
                                Text(headerSubtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text("settings.remote.loading".localized())
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("providers.accountSettings.description".localized())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("providers.accountSettings.remark".localized())
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                TextField("providers.accountSettings.remarkPlaceholder".localized(), text: $remark)
                                    .textFieldStyle(.roundedBorder)
                                    .onChange(of: remark) { _, _ in
                                        saveError = nil
                                    }
                            }

                            if context.supportsProxy {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("providers.accountProxy.title".localized())
                                        .font(.subheadline)
                                        .fontWeight(.medium)

                                    TextField("settings.upstreamProxy.placeholder".localized(), text: $proxyURL)
                                        .textFieldStyle(.roundedBorder)
                                        .onChange(of: proxyURL) { _, newValue in
                                            validation = ProxyURLValidator.validate(newValue)
                                            saveError = nil
                                        }

                                    if validation != .valid && validation != .empty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundStyle(.orange)
                                            Text((validation.localizationKey ?? "").localized())
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    } else {
                                        Text("providers.accountProxy.fallback".localized())
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }

                            fingerprintSection
                            oauthReauthenticationSection

                            if let loadError {
                                Text(loadError)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }

                            if let saveError {
                                Text(saveError)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
                .padding(24)
            }

            Divider()

            HStack {
                if context.supportsProxy {
                    Button("providers.accountProxy.clear".localized()) {
                        proxyURL = ""
                        validation = .empty
                        saveError = nil
                    }
                    .disabled(isLoading || isSaving || proxyURL.isEmpty)
                }

                Spacer()

                Button("action.cancel".localized(), role: .cancel) {
                    dismiss()
                }

                Button {
                    Task { await save() }
                } label: {
                    if isSaving {
                        SmallProgressView()
                    } else {
                        Text("action.save".localized())
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || isSaving || !validation.isValid)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .frame(width: 540, height: 620)
        .task {
            await loadCurrentValue()
            await runProvidersReauthSmokeIfNeeded()
        }
        .onChange(of: currentOAuthState?.status) { _, newValue in
            guard let newValue else {
                return
            }
            switch newValue {
            case .success, .error:
                Task { await loadReauthHistory() }
            case .waiting, .polling, .cancelled:
                break
            }
        }
        .confirmationDialog("重新生成上游请求标识？", isPresented: $showRegenerateConfirmation) {
            Button("重新生成", role: .destructive) {
                regenerateFingerprintProfile()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("重新生成会替换当前账户的上游 HTTP 标识档案。需点击保存后才会真正写入 auth 配置。")
        }
        .confirmationDialog("确认重新认证当前账户？", isPresented: $showReauthConfirmation) {
            Button("继续重新认证") {
                Task { await reauthenticateCurrentAccount() }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("开始后当前 auth 文件不会立刻被替换，只有新 OAuth 成功完成时才会覆盖原文件。你也可以随时取消，保留当前账户状态不变。")
        }
    }

    @ViewBuilder
    private var fingerprintSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("上游请求标识")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if fingerprintProfile != nil {
                    Button(showFingerprintDetails ? "收起详情" : "查看详情") {
                        showFingerprintDetails.toggle()
                    }
                    .buttonStyle(.borderless)
                }
            }

            Text(runtimeImpactDescription)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let fingerprintProfile {
                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        LabeledContent("最近生成") {
                            Text(fingerprintProfile.generatedAt.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }

                        LabeledContent("UA 摘要") {
                            Text(fingerprintProfile.userAgent.family + " / " + fingerprintProfile.userAgent.appVersion)
                                .foregroundStyle(.secondary)
                        }

                        LabeledContent("HTTP 摘要") {
                            Text(httpSummaryText(for: fingerprintProfile))
                                .foregroundStyle(.secondary)
                        }

                        LabeledContent("TLS 边界") {
                            Text(fingerprintProfile.tls.transport)
                                .foregroundStyle(.secondary)
                        }

                        if showFingerprintDetails {
                            VStack(alignment: .leading, spacing: 10) {
                                detailBlock(title: "User-Agent", value: fingerprintProfile.userAgent.value)
                                detailList(title: "UA 说明", values: fingerprintProfile.userAgent.notes)
                                if !managedUpstreamHeaders(for: fingerprintProfile).isEmpty {
                                    detailHeaders(title: "上游 HTTP 头", headers: managedUpstreamHeaders(for: fingerprintProfile))
                                }
                                if let upstreamNotes = fingerprintProfile.upstreamHTTP?.notes, !upstreamNotes.isEmpty {
                                    detailList(title: "HTTP 说明", values: upstreamNotes)
                                }
                                detailBlock(title: "TLS 预设", value: fingerprintProfile.tls.preset)
                                detailBlock(title: "TLS 传输", value: fingerprintProfile.tls.transport)
                                detailBlock(title: "ALPN", value: fingerprintProfile.tls.alpn.joined(separator: ", "))
                                detailList(title: "TLS 说明", values: fingerprintProfile.tls.notes)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text("尚未为该账户生成上游请求标识档案。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                if fingerprintProfile == nil {
                    Button("生成标识") {
                        regenerateFingerprintProfile()
                    }
                } else {
                    Button("重新生成") {
                        showRegenerateConfirmation = true
                    }
                }

                if fingerprintProfile != nil {
                    Text("变更会在点击保存后写入本地配置与 auth 记录。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func detailBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
        }
    }

    private func detailList(title: String, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(values, id: \.self) { value in
                Text("• " + value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func detailHeaders(title: String, headers: [String: String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(headers.keys.sorted(), id: \.self) { key in
                if let value = headers[key] {
                    Text(key + ": " + value)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func managedUpstreamHeaders(for profile: AccountFingerprintProfile) -> [String: String] {
        if let headers = profile.upstreamHTTP?.headers, !headers.isEmpty {
            return headers
        }

        switch context.provider {
        case .claude, .codex:
            return ["User-Agent": profile.userAgent.value]
        default:
            return [:]
        }
    }

    private func httpSummaryText(for profile: AccountFingerprintProfile) -> String {
        let headers = managedUpstreamHeaders(for: profile)
        guard !headers.isEmpty else {
            return "仅本地保存档案"
        }

        return String(headers.count) + " 项托管请求头"
    }

    private var runtimeImpactDescription: String {
        switch context.provider {
        case .antigravity:
            return "保存后会把 UA 写入 Antigravity auth 文件，后续通过 CLIProxyAPIPlus 发起的 Antigravity 请求会实际使用它。"
        case .codex:
            return "这里生成的是账户级上游 HTTP 头档案。保存后会写入 auth 记录的 `headers`，只有提供商真正能看到这些上游头；本地 CLI 入站头不属于验收目标。"
        case .kiro:
            return "Kiro 已有 CLIProxyAPIPlus 内建的账号级动态指纹。这里保存的是本地档案，不会覆写其全局指纹配置。"
        case .claude:
            return "这里生成的是账户级上游 HTTP 头档案。保存后会写入 auth 记录的 `headers`，Anthropic 侧真正可见的是这些上游头与账号代理出口；TLS 仍不是按账号生效。"
        default:
            return "当前 Quotio 会保存这份账户档案，但并非所有 provider 都有通用的每账户上游写入口。"
        }
    }

    @ViewBuilder
    private var oauthReauthenticationSection: some View {
        if canReauthenticate {
            VStack(alignment: .leading, spacing: 10) {
                Text("quota.reauthenticate".localized())
                    .font(.subheadline)
                    .fontWeight(.medium)

                VStack(alignment: .leading, spacing: 8) {
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: 10) {
                            refreshAuthStatusButton
                            reauthenticateButton
                            if isReauthenticating {
                                cancelReauthenticationButton
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            refreshAuthStatusButton
                            reauthenticateButton
                            if isReauthenticating {
                                cancelReauthenticationButton
                            }
                        }
                    }

                    Text("会重新检查当前认证状态，能清掉的旧警告会自动清掉。")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if let authURL = currentOAuthURL,
                       let authURLString = currentOAuthState?.authURL {
                        Text("oauth.copyLinkOrOpen".localized())
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ViewThatFits(in: .horizontal) {
                            HStack(alignment: .top, spacing: 10) {
                                copyOAuthLinkButton(authURLString: authURLString)
                                openOAuthLinkButton(authURL: authURL)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                copyOAuthLinkButton(authURLString: authURLString)
                                openOAuthLinkButton(authURL: authURL)
                            }
                        }
                    }

                    if let currentOAuthState,
                       context.provider.supportsOAuthCallbackSubmission,
                       currentOAuthState.authURL != nil,
                       isReauthenticating {
                        OAuthCallbackPasteSection(
                            provider: context.provider,
                            session: currentOAuthState
                        )
                        .environment(viewModel)
                    }

                    Text("当前 auth 文件会一直保留到新的 OAuth 成功完成；取消后会恢复为未开始状态。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                oauthReauthenticationStatusCard

                reauthHistorySection
            }
        }
    }

    private var canReauthenticate: Bool {
        liveAuthFile != nil && context.provider.supportsOAuthReauthentication
    }

    private var currentOAuthState: OAuthState? {
        guard let authFile = liveAuthFile,
              let state = viewModel.oauthState,
              state.provider == context.provider,
              state.targetAuthName == authFile.name else {
            return nil
        }
        return state
    }

    private var liveAuthFile: AuthFile? {
        guard let authFile = context.authFile else {
            return nil
        }
        return viewModel.authFiles.first(where: { $0.id == authFile.id || $0.name == authFile.name }) ?? authFile
    }

    private var currentOAuthURL: URL? {
        guard let authURL = currentOAuthState?.authURL else {
            return nil
        }
        return URL(string: authURL)
    }

    private var currentAuthProblemMessage: String? {
        let message = liveAuthFile?.normalizedProblemStatus?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let message, !message.isEmpty else {
            return nil
        }
        return message
    }

    private var currentAuthProblemColor: Color {
        if liveAuthFile?.status == "error" || liveAuthFile?.unavailable == true {
            return .red
        }
        return .orange
    }

    private var currentAuthProblemIsError: Bool {
        liveAuthFile?.status == "error" || liveAuthFile?.unavailable == true
    }

    private var shouldShowOAuthStatusCard: Bool {
        currentAuthProblemMessage != nil ||
        (authStatusRefreshFeedback?.isEmpty == false) ||
        currentOAuthState != nil
    }

    @ViewBuilder
    private var oauthReauthenticationStatusCard: some View {
        if shouldShowOAuthStatusCard {
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    if let currentAuthProblemMessage {
                        statusMessageRow(
                            icon: currentAuthProblemIsError ? "xmark.octagon.fill" : "exclamationmark.triangle.fill",
                            color: currentAuthProblemColor,
                            text: currentAuthProblemMessage
                        )
                    }

                    if let authStatusRefreshFeedback, !authStatusRefreshFeedback.isEmpty {
                        statusMessageRow(
                            icon: authStatusRefreshFeedbackIcon,
                            color: authStatusRefreshFeedbackColor,
                            text: authStatusRefreshFeedback
                        )
                    }

                    if let currentOAuthState {
                        switch currentOAuthState.status {
                        case .waiting, .polling:
                            statusMessageRow(
                                icon: "clock.fill",
                                color: .secondary,
                                text: "oauth.waitingForAuth".localized()
                            )

                            if let error = currentOAuthState.error, !error.isEmpty {
                                statusMessageRow(
                                    icon: "exclamationmark.triangle.fill",
                                    color: .orange,
                                    text: error
                                )
                            }
                        case .success:
                            statusMessageRow(
                                icon: "checkmark.circle.fill",
                                color: .green,
                                text: "oauth.success".localized()
                            )
                        case .cancelled:
                            statusMessageRow(
                                icon: "minus.circle.fill",
                                color: .orange,
                                text: currentOAuthState.error ?? "Authentication was cancelled"
                            )
                        case .error:
                            statusMessageRow(
                                icon: "xmark.octagon.fill",
                                color: .red,
                                text: currentOAuthState.error ?? "oauth.failed".localized()
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } label: {
                Text("当前状态")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }

    private var refreshAuthStatusButton: some View {
        Button {
            Task { await refreshCurrentAuthStatus() }
        } label: {
            if isRefreshingAuthStatus {
                HStack(spacing: 6) {
                    SmallProgressView()
                    Text("刷新状态")
                }
            } else {
                Label("刷新状态", systemImage: "arrow.clockwise")
            }
        }
        .buttonStyle(.bordered)
        .disabled(isLoading || isSaving || isReauthenticating || isRefreshingAuthStatus)
    }

    private var authStatusRefreshFeedbackIcon: String {
        switch authStatusRefreshFeedbackTone {
        case .success:
            return "checkmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.circle.fill"
        }
    }

    private var authStatusRefreshFeedbackColor: Color {
        switch authStatusRefreshFeedbackTone {
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        }
    }

    private var reauthenticateButton: some View {
        Button {
            showReauthConfirmation = true
        } label: {
            if isReauthenticating {
                HStack(spacing: 8) {
                    SmallProgressView()
                    Text("quota.reauthenticating".localized())
                }
            } else {
                Label("quota.reauthenticate".localized(), systemImage: "arrow.clockwise.circle")
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(isLoading || isSaving || isReauthenticating)
    }

    private var cancelReauthenticationButton: some View {
        Button("action.cancel".localized(), role: .cancel) {
            Task { await cancelCurrentReauthentication() }
        }
        .buttonStyle(.bordered)
        .disabled(isLoading || isSaving)
    }

    private func copyOAuthLinkButton(authURLString: String) -> some View {
        Button {
            copyOAuthLink(authURLString)
        } label: {
            Label(copiedOAuthLink ? "oauth.copied".localized() : "oauth.copyLink".localized(), systemImage: copiedOAuthLink ? "checkmark" : "doc.on.doc")
        }
        .buttonStyle(.bordered)
    }

    private func openOAuthLinkButton(authURL: URL) -> some View {
        Button {
            NSWorkspace.shared.open(authURL)
        } label: {
            Label("oauth.openLink".localized(), systemImage: "safari")
        }
        .buttonStyle(.bordered)
    }

    private var isReauthenticating: Bool {
        guard let currentOAuthState else {
            return false
        }
        switch currentOAuthState.status {
        case .waiting, .polling:
            return true
        case .success, .cancelled, .error:
            return false
        }
    }

    private func statusMessageRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)

            Text(text)
                .font(.caption)
                .foregroundStyle(color)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var reauthHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("最近重认证历史")
                    .font(.caption)
                    .fontWeight(.medium)

                Spacer()

                Button {
                    Task { await loadReauthHistory() }
                } label: {
                    if isLoadingReauthHistory {
                        SmallProgressView()
                    } else {
                        Text("刷新")
                    }
                }
                .buttonStyle(.borderless)
                .disabled(isLoading || isSaving || isLoadingReauthHistory)
            }

            if let reauthHistoryError, !reauthHistoryError.isEmpty {
                Text("历史加载失败：" + reauthHistoryError)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if isLoadingReauthHistory && reauthHistoryEvents.isEmpty {
                HStack(spacing: 8) {
                    SmallProgressView()
                    Text("加载最近重认证历史…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if reauthHistoryEvents.isEmpty {
                Text("暂无重认证历史。这里展示的是独立历史记录，不是 auth 文件最近修改时间。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(reauthHistoryEvents) { event in
                        GroupBox {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(historyStatusTitle(for: event))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(historyStatusColor(for: event))

                                    Spacer()

                                    if let occurredAtText = formattedHistoryOccurredAt(for: event) {
                                        Text(occurredAtText)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                if let accountSummary = historyAccountSummary(for: event) {
                                    Text("账户：" + accountSummary)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                if let planSummary = historyPlanSummary(for: event) {
                                    Text("计划：" + planSummary)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if event.overwroteExisting, event.eventType == "success" {
                                    Text("已覆盖原 auth 文件，账户身份保持不变。")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if let errorSummary = historyErrorSummary(for: event) {
                                    Text("错误：" + errorSummary)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }

            Text("仅显示最近几条记录；源文件来自 `<authDir>/.oauth-history/reauth.jsonl`。")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func regenerateFingerprintProfile() {
        fingerprintProfile = AccountFingerprintProfile.generate(
            for: context.provider,
            metadataKey: context.metadataKey
        )
        showFingerprintDetails = true
        saveError = nil
    }

    private func loadCurrentValue() async {
        isLoading = true
        loadError = nil
        authStatusRefreshFeedback = nil
        authStatusRefreshFeedbackTone = .success
        reauthHistoryError = nil
        remark = providersResolvedRemark(for: context.metadataKey, store: accountMetadataStore) ?? ""
        fingerprintProfile = providersResolvedFingerprintProfile(for: context.metadataKey, store: accountMetadataStore)

        if fingerprintProfile == nil {
            if let authFile = context.authFile {
                fingerprintProfile = try? await viewModel.loadAuthFileRecoveredFingerprintProfile(
                    authFile,
                    metadataKey: context.metadataKey
                )
            } else if let directAuthFile = context.directAuthFile {
                fingerprintProfile = await viewModel.loadDirectAuthFileRecoveredFingerprintProfile(
                    directAuthFile,
                    metadataKey: context.metadataKey
                )
            }
        }

        do {
            if context.supportsProxy {
                if let authFile = context.authFile {
                    proxyURL = try await viewModel.loadAuthFileProxyURL(authFile) ?? ""
                } else if let directAuthFile = context.directAuthFile {
                    proxyURL = directAuthFile.proxyURL ?? ""
                } else {
                    loadError = "providers.accountProxy.missing".localized()
                }

                validation = ProxyURLValidator.validate(proxyURL)
            } else {
                proxyURL = ""
                validation = .empty
            }
        } catch {
            loadError = error.localizedDescription
        }

        await loadReauthHistory()

        isLoading = false
    }

    private func loadReauthHistory() async {
        guard canReauthenticate, let authFile = liveAuthFile else {
            reauthHistoryEvents = []
            reauthHistoryError = nil
            isLoadingReauthHistory = false
            return
        }

        isLoadingReauthHistory = true
        reauthHistoryError = nil

        do {
            reauthHistoryEvents = try await viewModel.fetchOAuthReauthHistory(authName: authFile.name, limit: 5)
        } catch {
            reauthHistoryEvents = []
            reauthHistoryError = error.localizedDescription
        }

        isLoadingReauthHistory = false
    }

    private func runProvidersReauthSmokeIfNeeded() async {
        guard RuntimeProfile.providersReauthSmokeEnabled,
              !didRunProvidersReauthSmoke,
              canReauthenticate,
              let authFile = liveAuthFile else {
            return
        }

        didRunProvidersReauthSmoke = true
        uiSmokeLog("providers-reauth-sheet-ready auth=\(authFile.name) provider=\(context.provider.rawValue)")

        await reauthenticateCurrentAccount()
        uiSmokeLog("providers-reauth-started auth=\(authFile.name)")

        guard let authURLString = await waitForCurrentOAuthURL() else {
            uiSmokeLog("providers-reauth-timeout auth=\(authFile.name)")
            return
        }

        copyOAuthLink(authURLString)
        let pastedURL = NSPasteboard.general.string(forType: .string) ?? ""
        let pasteboardMatches = pastedURL == authURLString
        let callbackVisible = context.provider.supportsOAuthCallbackSubmission
        uiSmokeLog(
            "providers-reauth-url-ready auth=\(authFile.name) copy_open_visible=true callback_visible=\(callbackVisible) pasteboard_matches=\(pasteboardMatches)"
        )

        await cancelCurrentReauthentication()
        let idleRestored = await waitForReauthIdle()
        uiSmokeLog("providers-reauth-cancelled auth=\(authFile.name) idle=\(idleRestored)")
    }

    private func reauthenticateCurrentAccount() async {
        guard let authFile = liveAuthFile else {
            return
        }
        copiedOAuthLink = false
        await viewModel.startOAuth(for: context.provider, targetAuthName: authFile.name)
    }

    private func cancelCurrentReauthentication() async {
        guard currentOAuthState != nil else {
            return
        }
        copiedOAuthLink = false
        _ = await viewModel.cancelOAuth()
    }

    private func waitForCurrentOAuthURL() async -> String? {
        for _ in 0..<40 {
            if let authURLString = currentOAuthState?.authURL, !authURLString.isEmpty {
                return authURLString
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
        return nil
    }

    private func waitForReauthIdle() async -> Bool {
        for _ in 0..<20 {
            if currentOAuthState == nil {
                return true
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
        return currentOAuthState == nil
    }

    private func copyOAuthLink(_ authURLString: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(authURLString, forType: .string)
        copiedOAuthLink = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedOAuthLink = false
        }
    }

    private func uiSmokeLog(_ message: String) {
        #if DEBUG
        RuntimeIsolationDebugLog.write("[ui-smoke] \(message)")
        #endif
    }

    private func refreshCurrentAuthStatus() async {
        guard let authFile = liveAuthFile else {
            return
        }

        isRefreshingAuthStatus = true
        authStatusRefreshFeedback = nil
        authStatusRefreshFeedbackTone = .success
        defer { isRefreshingAuthStatus = false }

        do {
            let response = try await viewModel.refreshAuthFileStatus(authFile)
            if let warningMessage = response.warningMessage {
                authStatusRefreshFeedback = warningMessage
                authStatusRefreshFeedbackTone = .warning
            } else if response.isSuccess {
                authStatusRefreshFeedback = "已刷新当前认证状态。"
                authStatusRefreshFeedbackTone = .success
            } else {
                authStatusRefreshFeedback = response.error ?? "当前认证状态刷新失败。"
                authStatusRefreshFeedbackTone = .error
            }
        } catch {
            authStatusRefreshFeedback = error.localizedDescription
            authStatusRefreshFeedbackTone = .error
        }
    }

    private func historyStatusTitle(for event: OAuthReauthHistoryEvent) -> String {
        event.eventType == "success" ? "重认证成功" : "重认证失败"
    }

    private func historyStatusColor(for event: OAuthReauthHistoryEvent) -> Color {
        event.eventType == "success" ? .green : .red
    }

    private func formattedHistoryOccurredAt(for event: OAuthReauthHistoryEvent) -> String? {
        guard let raw = event.occurredAt?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            return nil
        }
        if let date = Self.parseHistoryTimestamp(raw) {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
        return raw
    }

    private func historyAccountSummary(for event: OAuthReauthHistoryEvent) -> String? {
        let before = event.before?.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let after = event.after?.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !before.isEmpty && !after.isEmpty && before != after {
            return before + " -> " + after
        }
        let single = after.isEmpty ? before : after
        return single.isEmpty ? nil : single
    }

    private func historyPlanSummary(for event: OAuthReauthHistoryEvent) -> String? {
        let afterPlan = event.after?.plan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !afterPlan.isEmpty {
            return afterPlan
        }
        let beforePlan = event.before?.plan?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return beforePlan.isEmpty ? nil : beforePlan
    }

    private func historyErrorSummary(for event: OAuthReauthHistoryEvent) -> String? {
        let message = event.error?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return message.isEmpty ? nil : message
    }

    private nonisolated static func parseHistoryTimestamp(_ value: String) -> Date? {
        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFractional.date(from: value) {
            return date
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }

    private func save() async {
        guard validation.isValid else {
            saveError = (validation.localizationKey ?? "").localized()
            return
        }

        isSaving = true
        saveError = nil
        defer { isSaving = false }

        let sanitizedProxyURL = proxyURL.isEmpty ? nil : ProxyURLValidator.sanitize(proxyURL)

        do {
            accountMetadataStore.setRemark(remark, for: context.metadataKey)
            accountMetadataStore.setFingerprintProfile(fingerprintProfile, for: context.metadataKey)

            let sanitizedRemark = remark.trimmingCharacters(in: .whitespacesAndNewlines)
            if let authFile = context.authFile {
                try await viewModel.updateAuthFileNote(
                    sanitizedRemark.isEmpty ? nil : sanitizedRemark,
                    for: authFile
                )
            } else if let directAuthFile = context.directAuthFile {
                try await viewModel.updateDirectAuthFileNote(
                    sanitizedRemark.isEmpty ? nil : sanitizedRemark,
                    for: directAuthFile
                )
            }

            if context.supportsProxy {
                if let authFile = context.authFile {
                    try await viewModel.updateAuthFileProxyURL(sanitizedProxyURL, for: authFile)
                } else if let directAuthFile = context.directAuthFile {
                    try await viewModel.updateDirectAuthFileProxyURL(sanitizedProxyURL, for: directAuthFile)
                } else {
                    saveError = "providers.accountProxy.missing".localized()
                    return
                }
            }

            if let fingerprintProfile {
                switch context.provider {
                case .antigravity:
                    if let authFile = context.authFile {
                        try await viewModel.updateAuthFileUserAgent(fingerprintProfile.userAgent.value, for: authFile)
                    } else if let directAuthFile = context.directAuthFile {
                        try await viewModel.updateDirectAuthFileUserAgent(fingerprintProfile.userAgent.value, for: directAuthFile)
                    }
                case .codex, .claude:
                    let managedHeaderNames = AccountFingerprintProfile.managedHeaderNames(for: context.provider)
                    let headers = managedUpstreamHeaders(for: fingerprintProfile)
                    if let authFile = context.authFile {
                        try await viewModel.updateAuthFileManagedHeaders(
                            headers,
                            managedHeaderNames: managedHeaderNames,
                            for: authFile
                        )
                    } else if let directAuthFile = context.directAuthFile {
                        try await viewModel.updateDirectAuthFileManagedHeaders(
                            headers,
                            managedHeaderNames: managedHeaderNames,
                            for: directAuthFile
                        )
                    }
                default:
                    break
                }
            }

            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

// MARK: - Custom Provider Row

struct CustomProviderRow: View {
    let provider: CustomProvider
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggle: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Provider type icon
            ZStack {
                Circle()
                    .fill(provider.type.color.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(provider.type.providerIconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            }
            
            // Provider info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(provider.name)
                        .fontWeight(.medium)
                    
                    if !provider.isEnabled {
                        Text("customProviders.disabled".localized())
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .foregroundStyle(.secondary)
                            .clipShape(Capsule())
                    }
                }
                
                HStack(spacing: 6) {
                    Text(provider.type.localizedDisplayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    let keyCount = provider.apiKeys.count
                    Text("\(keyCount) \(keyCount == 1 ? "customProviders.key".localized() : "customProviders.keys".localized())")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            // Toggle button
            Button {
                onToggle()
            } label: {
                Image(systemName: provider.isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(provider.isEnabled ? .green : .secondary)
            }
            .buttonStyle(.subtle)
            .help(provider.isEnabled ? "customProviders.disable".localized() : "customProviders.enable".localized())
        }
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("action.edit".localized(), systemImage: "pencil")
            }
            
            Button {
                onToggle()
            } label: {
                Label(provider.isEnabled ? "customProviders.disable".localized() : "customProviders.enable".localized(), systemImage: provider.isEnabled ? "xmark.circle" : "checkmark.circle")
            }
            
            Divider()
            
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("action.delete".localized(), systemImage: "trash")
            }
        }
        .confirmationDialog("customProviders.deleteConfirm".localized(), isPresented: $showDeleteConfirmation) {
            Button("action.delete".localized(), role: .destructive) {
                onDelete()
            }
            Button("action.cancel".localized(), role: .cancel) {}
        } message: {
            Text("customProviders.deleteMessage".localized())
        }
    }
}

// MARK: - Menu Bar Badge Component

struct MenuBarBadge: View {
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .frame(width: 28, height: 28)

                Image(systemName: isSelected ? "chart.bar.fill" : "chart.bar")
                    .font(.system(size: 14))
                    .foregroundStyle(isSelected ? .blue : .secondary)
            }
        }
        .buttonStyle(.plain)
        .nativeTooltip(isSelected ? "menubar.hideFromMenuBar".localized() : "menubar.showOnMenuBar".localized())
    }
}

// MARK: - Native Tooltip Support

private class TooltipWindow: NSWindow {
    static let shared = TooltipWindow()

    private let label: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.textColor = .labelColor
        label.backgroundColor = .clear
        label.isBezeled = false
        label.isEditable = false
        return label
    }()

    private init() {
        super.init(
            contentRect: .zero,
            styleMask: .borderless,
            backing: .buffered,
            defer: true
        )
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .floating
        self.ignoresMouseEvents = true

        let visualEffect = NSVisualEffectView()
        visualEffect.material = .toolTip
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 4

        label.translatesAutoresizingMaskIntoConstraints = false
        visualEffect.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: visualEffect.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor, constant: -4)
        ])

        self.contentView = visualEffect
    }

    func show(text: String, near view: NSView) {
        label.stringValue = text
        label.sizeToFit()

        let labelSize = label.fittingSize
        let windowSize = NSSize(width: labelSize.width + 16, height: labelSize.height + 8)

        guard let screen = view.window?.screen ?? NSScreen.main else { return }
        let viewFrameInScreen = view.window?.convertToScreen(view.convert(view.bounds, to: nil)) ?? .zero
        var origin = NSPoint(
            x: viewFrameInScreen.midX - windowSize.width / 2,
            y: viewFrameInScreen.minY - windowSize.height - 4
        )

        // Keep tooltip on screen
        if origin.x < screen.visibleFrame.minX {
            origin.x = screen.visibleFrame.minX
        }
        if origin.x + windowSize.width > screen.visibleFrame.maxX {
            origin.x = screen.visibleFrame.maxX - windowSize.width
        }
        if origin.y < screen.visibleFrame.minY {
            origin.y = viewFrameInScreen.maxY + 4
        }

        setFrame(NSRect(origin: origin, size: windowSize), display: true)
        orderFront(nil)
    }

    func hide() {
        orderOut(nil)
    }
}

private class TooltipTrackingView: NSView {
    var text: String = ""

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInActiveApp],
            owner: self,
            userInfo: nil
        ))
    }

    override func mouseEntered(with event: NSEvent) {
        TooltipWindow.shared.show(text: text, near: self)
    }

    override func mouseExited(with event: NSEvent) {
        TooltipWindow.shared.hide()
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}

private struct NativeTooltipView: NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> TooltipTrackingView {
        let view = TooltipTrackingView()
        view.text = text
        return view
    }

    func updateNSView(_ nsView: TooltipTrackingView, context: Context) {
        nsView.text = text
    }
}

private extension View {
    func nativeTooltip(_ text: String) -> some View {
        self.overlay(NativeTooltipView(text: text))
    }
}

// MARK: - Menu Bar Hint View

struct MenuBarHintView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "chart.bar.fill")
                .foregroundStyle(.blue)
                .font(.caption2)
            Text("menubar.hint".localized())
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - OAuth Sheet

struct OAuthSheet: View {
    @Environment(QuotaViewModel.self) private var viewModel
    let provider: AIProvider
    @Binding var projectId: String
    let onDismiss: () -> Void
    
    @State private var hasStartedAuth = false
    @State private var selectedKiroMethod: AuthCommand = .kiroImport
    @State private var remark = ""
    @State private var proxyURL = ""
    @State private var proxyValidation: ProxyURLValidationResult = .empty

    private var activeOAuthState: OAuthState? {
        guard let state = viewModel.oauthState,
              state.provider == provider,
              state.targetAuthName == nil else {
            return nil
        }
        return state
    }
    
    private var isPolling: Bool {
        activeOAuthState?.status == .polling || activeOAuthState?.status == .waiting
    }
    
    private var isSuccess: Bool {
        activeOAuthState?.status == .success
    }
    
    private var isError: Bool {
        activeOAuthState?.status == .error
    }

    private var canStartAuthentication: Bool {
        !isPolling && proxyValidation.isValid
    }

    private var shouldShowCallbackPasteSection: Bool {
        guard let activeOAuthState,
              provider.supportsOAuthCallbackSubmission,
              activeOAuthState.authURL != nil else {
            return false
        }
        return activeOAuthState.status == .waiting || activeOAuthState.status == .polling
    }
    
    private var kiroAuthMethods: [AuthCommand] {
        [.kiroImport, .kiroGoogleLogin, .kiroAWSAuthCode, .kiroAWSLogin]
    }
    
    var body: some View {
        VStack(spacing: 28) {
            ProviderIcon(provider: provider, size: 64)
            
            VStack(spacing: 8) {
                Text("oauth.connect".localized() + " " + provider.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("oauth.authenticateWith".localized() + " " + provider.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if provider == .gemini {
                VStack(alignment: .leading, spacing: 6) {
                    Text("oauth.projectId".localized())
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("oauth.projectIdPlaceholder".localized(), text: $projectId)
                        .textFieldStyle(.roundedBorder)
                }
                .frame(maxWidth: 320)
            }

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("providers.accountSettings.remark".localized())
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("providers.accountSettings.remarkPlaceholder".localized(), text: $remark)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("providers.accountProxy.title".localized())
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("settings.upstreamProxy.placeholder".localized(), text: $proxyURL)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: proxyURL) { _, newValue in
                            proxyValidation = ProxyURLValidator.validate(newValue)
                        }

                    if proxyValidation != .valid && proxyValidation != .empty {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text((proxyValidation.localizationKey ?? "").localized())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("providers.accountProxy.fallback".localized())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: 320)
            
            if provider == .kiro {
                VStack(alignment: .leading, spacing: 6) {
                    Text("oauth.authMethod".localized())
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Picker("", selection: $selectedKiroMethod) {
                        ForEach(kiroAuthMethods, id: \.self) { method in
                            Text(method.displayName).tag(method)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    

                }
                .frame(maxWidth: 320)
            }
            
            if let state = activeOAuthState {
                OAuthStatusView(status: state.status, error: state.error, state: state.state, authURL: state.authURL, provider: provider)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            if let activeOAuthState, shouldShowCallbackPasteSection {
                OAuthCallbackPasteSection(provider: provider, session: activeOAuthState)
                    .environment(viewModel)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            HStack(spacing: 16) {
                Button("action.cancel".localized(), role: .cancel) {
                    Task {
                        if activeOAuthState != nil {
                            let result = await viewModel.cancelOAuth()
                            guard result.didCancel else {
                                return
                            }
                        }
                        onDismiss()
                    }
                }
                .buttonStyle(.bordered)
                
                if isError {
                    Button {
                        hasStartedAuth = false
                        Task {
                            await viewModel.startOAuth(
                                for: provider,
                                projectId: projectId.isEmpty ? nil : projectId,
                                authMethod: provider == .kiro ? selectedKiroMethod : nil,
                                remark: remark,
                                proxyURL: proxyURL
                            )
                        }
                    } label: {
                        Label("oauth.retry".localized(), systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                } else if !isSuccess {
                    Button {
                        hasStartedAuth = true
                        Task {
                            await viewModel.startOAuth(
                                for: provider,
                                projectId: projectId.isEmpty ? nil : projectId,
                                authMethod: provider == .kiro ? selectedKiroMethod : nil,
                                remark: remark,
                                proxyURL: proxyURL
                            )
                        }
                    } label: {
                        if isPolling {
                            SmallProgressView()
                        } else {
                            Label("oauth.authenticate".localized(), systemImage: "key.fill")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(provider.color)
                    .disabled(!canStartAuthentication)
                }
            }
        }
        .padding(40)
        .frame(width: 480)
        .frame(minHeight: 350)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.easeInOut(duration: 0.2), value: activeOAuthState?.status)
        .onAppear {
            proxyValidation = ProxyURLValidator.validate(proxyURL)
        }
        .onChange(of: activeOAuthState?.status) { _, newStatus in
            if newStatus == .success {
                Task {
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    onDismiss()
                }
            }
        }
    }
}

private struct OAuthCallbackPasteSection: View {
    @Environment(QuotaViewModel.self) private var viewModel
    let provider: AIProvider
    let session: OAuthState

    @State private var callbackURL = ""
    @State private var isSubmitting = false
    @State private var submissionFeedback: OAuthCallbackSubmissionFeedback?

    private var validation: OAuthCallbackPasteValidation {
        OAuthCallbackPasteValidation(rawValue: callbackURL, expectedState: session.state)
    }

    private var canSubmit: Bool {
        switch session.status {
        case .waiting, .polling:
            return validation.isValid && !isSubmitting
        case .success, .cancelled, .error:
            return false
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("oauth.callbackTitle".localized())
                .font(.subheadline)
                .fontWeight(.medium)

            Text("oauth.callbackHint".localized())
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("oauth.callbackPlaceholder".localized(), text: $callbackURL, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            if let validationKey = validation.localizationKey {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(validationKey.localized())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if let submissionFeedback {
                Text(submissionFeedback.message)
                    .font(.caption)
                    .foregroundStyle(submissionFeedback.color)
            }

            Button {
                Task {
                    await submitCallback()
                }
            } label: {
                if isSubmitting {
                    HStack(spacing: 8) {
                        SmallProgressView()
                        Text("oauth.submittingCallback".localized())
                    }
                } else {
                    Label("oauth.submitCallback".localized(), systemImage: "paperplane.fill")
                }
            }
            .buttonStyle(.bordered)
            .disabled(!canSubmit)
        }
        .frame(maxWidth: 320, alignment: .leading)
        .onChange(of: callbackURL) { _, _ in
            submissionFeedback = nil
        }
        .onChange(of: session.state) { _, _ in
            callbackURL = ""
            isSubmitting = false
            submissionFeedback = nil
        }
    }

    private func submitCallback() async {
        guard let normalizedURL = validation.normalizedURL else {
            return
        }

        isSubmitting = true
        submissionFeedback = nil

        do {
            try await viewModel.submitOAuthCallback(for: provider, redirectURL: normalizedURL)
            submissionFeedback = .success("oauth.callbackSubmitted".localized())
        } catch {
            submissionFeedback = .error(error.localizedDescription)
        }

        isSubmitting = false
    }
}

private enum OAuthCallbackSubmissionFeedback {
    case success(String)
    case error(String)

    var message: String {
        switch self {
        case .success(let message), .error(let message):
            return message
        }
    }

    var color: Color {
        switch self {
        case .success:
            return .green
        case .error:
            return .red
        }
    }
}

private enum OAuthCallbackPasteValidation {
    case empty
    case valid(normalizedURL: String)
    case invalid(localizationKey: String)

    init(rawValue: String, expectedState: String?) {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            self = .empty
            return
        }

        guard let normalizedURL = Self.normalizedCallbackURL(from: trimmedValue),
              let components = URLComponents(string: normalizedURL) else {
            self = .invalid(localizationKey: "oauth.callbackInvalidFormat")
            return
        }

        let queryItems = Self.queryItems(from: components)
        let state = Self.queryValue(named: "state", in: queryItems)
        let code = Self.queryValue(named: "code", in: queryItems)
        let error = Self.queryValue(named: "error", in: queryItems)
            ?? Self.queryValue(named: "error_description", in: queryItems)

        guard let state, !state.isEmpty else {
            self = .invalid(localizationKey: "oauth.callbackMissingState")
            return
        }

        if let expectedState,
           !expectedState.isEmpty,
           state != expectedState {
            self = .invalid(localizationKey: "oauth.callbackStateMismatch")
            return
        }

        guard (code?.isEmpty == false) || (error?.isEmpty == false) else {
            self = .invalid(localizationKey: "oauth.callbackMissingCode")
            return
        }

        self = .valid(normalizedURL: normalizedURL)
    }

    var isValid: Bool {
        if case .valid = self {
            return true
        }
        return false
    }

    var normalizedURL: String? {
        guard case .valid(let normalizedURL) = self else {
            return nil
        }
        return normalizedURL
    }

    var localizationKey: String? {
        guard case .invalid(let localizationKey) = self else {
            return nil
        }
        return localizationKey
    }

    private static func normalizedCallbackURL(from rawValue: String) -> String? {
        if rawValue.contains("://") {
            return rawValue
        }
        if rawValue.hasPrefix("?") {
            return "http://localhost/auth/callback" + rawValue
        }
        if rawValue.hasPrefix("/") {
            return "http://localhost" + rawValue
        }
        if rawValue.contains("=") && !rawValue.contains("?") {
            return "http://localhost/auth/callback?" + rawValue
        }
        if rawValue.contains("/?#") || rawValue.contains(":") {
            return "http://" + rawValue
        }
        return nil
    }

    private static func queryItems(from components: URLComponents) -> [URLQueryItem] {
        var items = components.queryItems ?? []
        if let fragment = components.fragment,
           let fragmentItems = URLComponents(string: "http://localhost/?" + fragment)?.queryItems {
            items.append(contentsOf: fragmentItems)
        }
        return items
    }

    private static func queryValue(named name: String, in items: [URLQueryItem]) -> String? {
        items.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }?.value?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct OAuthStatusView: View {
    let status: OAuthState.OAuthStatus
    let error: String?
    let state: String?
    let authURL: String?
    let provider: AIProvider
    
    /// Stable rotation angle for spinner animation (fixes UUID() infinite re-render)
    @State private var rotationAngle: Double = 0
    
    /// Visual feedback for copy action
    @State private var copied = false
    
    var body: some View {
        Group {
            switch status {
            case .waiting:
                VStack(spacing: 12) {
                    ProgressView()
                    Text("oauth.openingBrowser".localized())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let error, !error.isEmpty {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 350)
                    }
                }
                .padding(.vertical, 16)
                
            case .polling:
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(provider.color.opacity(0.2), lineWidth: 4)
                            .frame(width: 56, height: 56)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(provider.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 56, height: 56)
                            .rotationEffect(.degrees(rotationAngle - 90))
                            .onAppear {
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                    rotationAngle = 360
                                }
                            }
                        
                        Image(systemName: "person.badge.key.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(provider.color)
                    }
                    
                    // For Copilot Device Code flow, show device code with copy button
                    if provider == .copilot, let deviceCode = state, !deviceCode.isEmpty {
                        VStack(spacing: 8) {
                            Text("oauth.enterCodeInBrowser".localized())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 12) {
                                Text(deviceCode)
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundStyle(provider.color)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(provider.color.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Button {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(deviceCode, forType: .string)
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.title3)
                                }
                                .buttonStyle(.subtle)
                                .help("action.copyCode".localized())
                            }
                            
                            Text("oauth.waitingForAuth".localized())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else if provider == .copilot, let message = error {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 350)
                    } else {
                        Text("oauth.waitingForAuth".localized())
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        // Show auth URL with copy/open buttons
                        if let urlString = authURL, let url = URL(string: urlString) {
                            VStack(spacing: 12) {
                                Text("oauth.copyLinkOrOpen".localized())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                HStack(spacing: 12) {
                                    Button {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(urlString, forType: .string)
                                        copied = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            copied = false
                                        }
                                    } label: {
                                        Label(copied ? "oauth.copied".localized() : "oauth.copyLink".localized(), systemImage: copied ? "checkmark" : "doc.on.doc")
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Button {
                                        NSWorkspace.shared.open(url)
                                    } label: {
                                        Label("oauth.openLink".localized(), systemImage: "safari")
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(provider.color)
                                }
                            }
                        } else {
                            Text("oauth.completeBrowser".localized())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let error, !error.isEmpty {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 350)
                        }
                    }
                }
                .padding(.vertical, 16)
                
            case .success:
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                    
                    Text("oauth.success".localized())
                        .font(.headline)
                        .foregroundStyle(.green)
                    
                    Text("oauth.closingSheet".localized())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 16)

            case .cancelled:
                VStack(spacing: 12) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text(error ?? "Authentication was cancelled")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 16)
                
            case .error:
                VStack(spacing: 12) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.red)
                    
                    Text("oauth.failed".localized())
                        .font(.headline)
                        .foregroundStyle(.red)
                    
                    if let error = error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300)
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .frame(minHeight: 100)
    }
}

// MARK: - Custom Provider Sheet Mode

enum CustomProviderSheetMode: Identifiable {
    case add
    case edit(CustomProvider)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let provider):
            return provider.id.uuidString
        }
    }

    var provider: CustomProvider? {
        switch self {
        case .add:
            return nil
        case .edit(let provider):
            return provider
        }
    }
}
