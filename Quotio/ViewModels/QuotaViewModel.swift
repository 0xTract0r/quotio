//
//  QuotaViewModel.swift
//  Quotio - CLIProxyAPI GUI Wrapper
//

import Foundation
import SwiftUI
import AppKit
import Observation

@MainActor
@Observable
final class QuotaViewModel {
    let proxyManager: CLIProxyManager
    @ObservationIgnored private var _apiClient: ManagementAPIClient?
    
    var apiClient: ManagementAPIClient? { _apiClient }
    @ObservationIgnored private let antigravityFetcher = AntigravityQuotaFetcher()
    @ObservationIgnored private let openAIFetcher = OpenAIQuotaFetcher()
    @ObservationIgnored private let copilotFetcher = CopilotQuotaFetcher()
    @ObservationIgnored private let glmFetcher = GLMQuotaFetcher()
    @ObservationIgnored private let warpFetcher = WarpQuotaFetcher()
    @ObservationIgnored private let directAuthService = DirectAuthFileService()
    @ObservationIgnored private let accountMetadataStore = AccountMetadataStore.shared
    @ObservationIgnored private let notificationManager = NotificationManager.shared
    @ObservationIgnored private let modeManager = OperatingModeManager.shared
    @ObservationIgnored private let refreshSettings = RefreshSettingsManager.shared
    @ObservationIgnored private let warmupSettings = WarmupSettingsManager.shared
    @ObservationIgnored private let warmupService = WarmupService()
    private var warmupNextRun: [WarmupAccountKey: Date] = [:]
    private var warmupStatuses: [WarmupAccountKey: WarmupStatus] = [:]
    @ObservationIgnored private var warmupModelCache: [WarmupAccountKey: (models: [WarmupModelInfo], fetchedAt: Date)] = [:]
    @ObservationIgnored private let warmupModelCacheTTL: TimeInterval = 28800
    @ObservationIgnored private var lastProxyURL: String?
    
    /// Request tracker for monitoring API requests through ProxyBridge
    let requestTracker = RequestTracker.shared
    
    /// Tunnel manager for Cloudflare Tunnel integration
    let tunnelManager = TunnelManager.shared
    
    // Quota-Only Mode Fetchers (CLI-based)
    @ObservationIgnored private let claudeCodeFetcher = ClaudeCodeQuotaFetcher()
    @ObservationIgnored private let cursorFetcher = CursorQuotaFetcher()
    @ObservationIgnored private let codexCLIFetcher = CodexCLIQuotaFetcher()
    @ObservationIgnored private let geminiCLIFetcher = GeminiCLIQuotaFetcher()
    @ObservationIgnored private let traeFetcher = TraeQuotaFetcher()
    @ObservationIgnored private let kiroFetcher = KiroQuotaFetcher()
    
    @ObservationIgnored private var lastKnownAccountStatuses: [String: String] = [:]
    @ObservationIgnored private var pendingAccountSetup: PendingAccountSetup?
    
    var currentPage: NavigationPage = .dashboard
    var authFiles: [AuthFile] = []
    var usageStats: UsageStats?
    var apiKeys: [String] = []
    var isLoading = false
    var isLoadingQuotas = false
    var errorMessage: String?
    var oauthState: OAuthState?

    /// Notification name for quota data updates (used for menu bar refresh)
    static let quotaDataDidChangeNotification = Notification.Name("QuotaViewModel.quotaDataDidChange")
    
    /// Direct auth files for quota-only mode
    var directAuthFiles: [DirectAuthFile] = []
    
    /// Last quota refresh time (for quota-only mode display)
    var lastQuotaRefreshTime: Date?
    
    /// IDE Scan state
    var showIDEScanSheet = false
    @ObservationIgnored private let ideScanSettings = IDEScanSettingsManager.shared
    
    @ObservationIgnored private var _agentSetupViewModel: AgentSetupViewModel?
    var agentSetupViewModel: AgentSetupViewModel {
        if let vm = _agentSetupViewModel {
            return vm
        }
        let vm = AgentSetupViewModel()
        vm.setup(proxyManager: proxyManager, quotaViewModel: self)
        _agentSetupViewModel = vm
        return vm
    }
    
    /// Quota data per provider per account (email -> QuotaData)
    var providerQuotas: [AIProvider: [String: ProviderQuotaData]] = [:]
    
    /// Subscription info per provider per account (provider -> email -> SubscriptionInfo)
    var subscriptionInfos: [AIProvider: [String: SubscriptionInfo]] = [:]
    
    /// Antigravity account switcher (for IDE token injection)
    let antigravitySwitcher = AntigravityAccountSwitcher.shared
    
    @ObservationIgnored private var refreshTask: Task<Void, Never>?
    @ObservationIgnored private var warmupTask: Task<Void, Never>?
    @ObservationIgnored private var isStartingProxyFlow = false
    @ObservationIgnored private var lastLogTimestamp: Int?
    @ObservationIgnored private var isWarmupRunning = false
    @ObservationIgnored private var warmupRunningAccounts: Set<WarmupAccountKey> = []
    @ObservationIgnored private nonisolated(unsafe) var appDidBecomeActiveObserver: NSObjectProtocol?
    @ObservationIgnored private var lastResumeRefreshTime: Date = Date()

    struct WarmupStatus: Sendable {
        var isRunning: Bool = false
        var lastRun: Date?
        var nextRun: Date?
        var lastError: String?
        var progressCompleted: Int = 0
        var progressTotal: Int = 0
        var currentModel: String?
        var modelStates: [String: WarmupModelState] = [:]
    }

    enum WarmupModelState: String, Sendable {
        case pending
        case running
        case succeeded
        case failed
    }

    private struct PendingAccountSetup: Sendable {
        let provider: AIProvider
        let remark: String?
        let proxyURL: String?
        let existingAuthFileNames: Set<String>
        let startedAt: Date
    }
    
    // MARK: - IDE Quota Persistence Keys

    private static let ideQuotasKey = "persisted.ideQuotas"
    private static let ideProvidersToSave: Set<AIProvider> = [.cursor, .trae]

    /// Key for tracking when auth files last changed (for model cache invalidation)
    static let authFilesChangedKey = "quotio.authFiles.lastChanged"

    // MARK: - Disabled Auth Files Persistence

    private static let disabledAuthFilesKey = "persisted.disabledAuthFiles"

    /// Load disabled auth file names from UserDefaults
    private func loadDisabledAuthFiles() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: Self.disabledAuthFilesKey) ?? []
        return Set(array)
    }

    /// Save disabled auth file names to UserDefaults
    private func saveDisabledAuthFiles(_ names: Set<String>) {
        UserDefaults.standard.set(Array(names), forKey: Self.disabledAuthFilesKey)
    }

    /// Sync local disabled state to backend after proxy starts
    private func syncDisabledStatesToBackend() async {
        guard let client = apiClient else { return }

        let localDisabled = loadDisabledAuthFiles()
        guard !localDisabled.isEmpty else { return }

        for name in localDisabled {
            // Only sync if this auth file exists
            guard authFiles.contains(where: { $0.name == name }) else { continue }

            do {
                try await client.setAuthFileDisabled(name: name, disabled: true)
            } catch {
                Log.error("syncDisabledStatesToBackend: Failed for \(name) - \(error.localizedDescription)")
            }
        }
    }

    /// Post notification to trigger UI updates (works even when window is closed)
    private func notifyQuotaDataChanged() {
        NotificationCenter.default.post(name: Self.quotaDataDidChangeNotification, object: nil)
    }

    init() {
        self.proxyManager = CLIProxyManager.shared
        loadPersistedIDEQuotas()
        setupRefreshCadenceCallback()
        setupWarmupCallback()
        setupAppActivationObserver()
        restartWarmupScheduler()
        lastProxyURL = normalizedProxyURL(UserDefaults.standard.string(forKey: "proxyURL"))
        setupProxyURLObserver()
    }

    deinit {
        if let observer = appDidBecomeActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func setupProxyURLObserver() {
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                let currentProxyURL = self.normalizedProxyURL(UserDefaults.standard.string(forKey: "proxyURL"))
                guard currentProxyURL != self.lastProxyURL else { return }
                self.lastProxyURL = currentProxyURL
                await self.updateProxyConfiguration()
            }
        }
    }

    private func normalizedProxyURL(_ rawValue: String?) -> String? {
        guard let rawValue = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawValue.isEmpty else {
            return nil
        }

        let sanitized = ProxyURLValidator.sanitize(rawValue)
        return sanitized.isEmpty ? nil : sanitized
    }

    /// Update proxy configuration for all quota fetchers
    func updateProxyConfiguration() async {
        await antigravityFetcher.updateProxyConfiguration()
        await openAIFetcher.updateProxyConfiguration()
        await copilotFetcher.updateProxyConfiguration()
        await glmFetcher.updateProxyConfiguration()
        await claudeCodeFetcher.updateProxyConfiguration()
        await cursorFetcher.updateProxyConfiguration()
        await codexCLIFetcher.updateProxyConfiguration()
        await geminiCLIFetcher.updateProxyConfiguration()
        await warpFetcher.updateProxyConfiguration()
        await traeFetcher.updateProxyConfiguration()
        await kiroFetcher.updateProxyConfiguration()
    }

    private func setupRefreshCadenceCallback() {
        refreshSettings.onRefreshCadenceChanged = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.restartAutoRefresh()
            }
        }
    }

    private func setupAppActivationObserver() {
        appDidBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refreshOnAppResumeIfNeeded()
            }
        }
    }

    private func refreshOnAppResumeIfNeeded() async {
        let now = Date()
        guard now.timeIntervalSince(lastResumeRefreshTime) >= 15 else { return }
        guard !isStartingProxyFlow, !isLoading, !isLoadingQuotas else { return }

        lastResumeRefreshTime = now

        if modeManager.isRemoteProxyMode || proxyManager.proxyStatus.running {
            await refreshData()
        } else if modeManager.isMonitorMode {
            await loadDirectAuthFiles()
            _ = await kiroFetcher.refreshAllTokensIfNeeded()
            await refreshQuotasDirectly()
        } else {
            _ = await kiroFetcher.refreshAllTokensIfNeeded()
            await refreshQuotasUnified()
        }
    }
    
    private func setupWarmupCallback() {
        warmupSettings.onEnabledAccountsChanged = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.restartWarmupScheduler()
            }
        }
        warmupSettings.onWarmupCadenceChanged = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.restartWarmupScheduler()
            }
        }
        warmupSettings.onWarmupScheduleChanged = { [weak self] in
            Task { @MainActor [weak self] in
                self?.restartWarmupScheduler()
            }
        }
    }
    
    private func restartAutoRefresh() {
        if modeManager.isMonitorMode {
            startQuotaOnlyAutoRefresh()
        } else if proxyManager.proxyStatus.running {
            startAutoRefresh()
        } else {
            startQuotaAutoRefreshWithoutProxy()
        }
    }
    
    // MARK: - Mode-Aware Initialization
    
    func initialize() async {
        if modeManager.isRemoteProxyMode {
            await initializeRemoteMode()
        } else if modeManager.isMonitorMode {
            await initializeQuotaOnlyMode()
        } else {
            await initializeFullMode()
        }
    }
    
    private func initializeFullMode() async {
        if RuntimeProfile.proxyOnlyTestMode {
            await startProxy()
            return
        }

        // Always refresh quotas directly first (works without proxy)
        await refreshQuotasUnified()
        
        let autoStartProxy = RuntimeProfile.autoStartProxyOverride ?? UserDefaults.standard.bool(forKey: "autoStartProxy")
        if autoStartProxy && proxyManager.isBinaryInstalled {
            await startProxy()
            // Note: checkForProxyUpgrade() is now called inside startProxy()
        } else {
            // If not auto-starting proxy, start quota auto-refresh
            startQuotaAutoRefreshWithoutProxy()
        }
    }
    
    /// Check for proxy upgrade (non-blocking)
    private func checkForProxyUpgrade() async {
        await proxyManager.checkForUpgrade()
    }
    
    /// Initialize for Quota-Only Mode (no proxy)
    private func initializeQuotaOnlyMode() async {
        // Load auth files directly from filesystem
        await loadDirectAuthFiles()
        
        // Fetch quotas directly
        await refreshQuotasDirectly()
        
        // Start auto-refresh for quota-only mode
        startQuotaOnlyAutoRefresh()
    }
    
    private func initializeRemoteMode() async {
        guard modeManager.hasValidRemoteConfig,
              let config = modeManager.remoteConfig,
              let managementKey = modeManager.remoteManagementKey else {
            modeManager.setConnectionStatus(.error("No valid remote configuration"))
            return
        }
        
        modeManager.setConnectionStatus(.connecting)
        
        await setupRemoteAPIClient(config: config, managementKey: managementKey)
        
        guard let client = apiClient else {
            modeManager.setConnectionStatus(.error("Failed to create API client"))
            return
        }
        
        let isConnected = await client.checkProxyResponding()
        
        if isConnected {
            modeManager.markConnected()
            await refreshData()
            startAutoRefresh()
        } else {
            modeManager.setConnectionStatus(.error("Could not connect to remote server"))
        }
    }
    
    private func setupRemoteAPIClient(config: RemoteConnectionConfig, managementKey: String) async {
        if let existingClient = _apiClient {
            await existingClient.invalidate()
        }
        
        _apiClient = ManagementAPIClient(config: config, managementKey: managementKey)
    }
    
    func reconnectRemote() async {
        guard modeManager.isRemoteProxyMode else { return }
        await initializeRemoteMode()
    }
    
    // MARK: - Direct Auth File Management (Quota-Only Mode)
    
    /// Load auth files directly from filesystem
    func loadDirectAuthFiles() async {
        directAuthFiles = await directAuthService.scanAllAuthFiles()
    }
    
    /// Refresh quotas directly without proxy (for Quota-Only Mode)
    /// Note: Cursor and Trae are NOT auto-refreshed - user must use "Scan for IDEs" (issue #29)
    func refreshQuotasDirectly() async {
        guard !isLoadingQuotas else { return }
        
        isLoadingQuotas = true
        lastQuotaRefreshTime = Date()
        
        // Fetch from available fetchers in parallel
        // Note: Cursor and Trae removed from auto-refresh to address privacy concerns (issue #29)
        // User must explicitly scan for IDEs to detect Cursor/Trae quotas
        async let antigravity: () = refreshAntigravityQuotasInternal()
        async let openai: () = refreshOpenAIQuotasInternal()
        async let copilot: () = refreshCopilotQuotasInternal()
        async let claudeCode: () = refreshClaudeCodeQuotasInternal()
        async let codexCLI: () = refreshCodexCLIQuotasInternal()
        async let geminiCLI: () = refreshGeminiCLIQuotasInternal()
        async let glm: () = refreshGlmQuotasInternal()
        async let warp: () = refreshWarpQuotasInternal()
        async let kiro: () = refreshKiroQuotasInternal()

        _ = await (antigravity, openai, copilot, claudeCode, codexCLI, geminiCLI, glm, warp, kiro)
        
        checkQuotaNotifications()
        pruneMenuBarItems()
        autoSelectMenuBarItems()

        isLoadingQuotas = false
        notifyQuotaDataChanged()
    }

    private func autoSelectMenuBarItems() {
        var availableItems: [MenuBarQuotaItem] = []
        var seen = Set<String>()
        
        for (provider, accountQuotas) in providerQuotas {
            for (accountKey, _) in accountQuotas {
                let item = MenuBarQuotaItem(provider: provider.rawValue, accountKey: accountKey)
                if !seen.contains(item.id) {
                    seen.insert(item.id)
                    availableItems.append(item)
                }
            }
        }
        
        for file in authFiles {
            guard let provider = file.providerType else { continue }
            let item = MenuBarQuotaItem(provider: provider.rawValue, accountKey: file.menuBarAccountKey)
            if !seen.contains(item.id) {
                seen.insert(item.id)
                availableItems.append(item)
            }
        }
        
        for file in directAuthFiles {
            let item = MenuBarQuotaItem(provider: file.provider.rawValue, accountKey: file.menuBarAccountKey)
            if !seen.contains(item.id) {
                seen.insert(item.id)
                availableItems.append(item)
            }
        }
        
        menuBarSettings.autoSelectNewAccounts(availableItems: availableItems)
    }
    
    func syncMenuBarSelection() {
        pruneMenuBarItems()
        autoSelectMenuBarItems()
    }
    
    /// Refresh Claude Code quota using CLI
    private func refreshClaudeCodeQuotasInternal() async {
        let quotas = await claudeCodeFetcher.fetchAsProviderQuota()
        if quotas.isEmpty {
            // Only remove if no other source has Claude data
            if providerQuotas[.claude]?.isEmpty ?? true {
                providerQuotas.removeValue(forKey: .claude)
            }
        } else {
            // Merge with existing data (don't overwrite proxy data)
            if var existing = providerQuotas[.claude] {
                for (email, quota) in quotas {
                    existing[email] = quota
                }
                providerQuotas[.claude] = existing
            } else {
                providerQuotas[.claude] = quotas
            }
        }
    }
    
    /// Refresh Cursor quota using browser cookies
    private func refreshCursorQuotasInternal() async {
        let quotas = await cursorFetcher.fetchAsProviderQuota()
        if quotas.isEmpty {
            // No Cursor auth found - remove from providerQuotas
            providerQuotas.removeValue(forKey: .cursor)
        } else {
            providerQuotas[.cursor] = quotas
        }
    }
    
    /// Refresh Codex quota using CLI auth file (~/.codex/auth.json)
    private func refreshCodexCLIQuotasInternal() async {
        // Only use CLI fetcher if proxy is not available or in quota-only mode
        // The openAIFetcher handles Codex via proxy auth files
        guard modeManager.isMonitorMode else { return }

        // Skip if OpenAI fetcher already populated codex quotas (avoids duplicate entries
        // since OpenAIQuotaFetcher keys by filename while CodexCLIFetcher keys by JWT email)
        if let existing = providerQuotas[.codex], !existing.isEmpty { return }

        let quotas = await codexCLIFetcher.fetchAsProviderQuota()
        if !quotas.isEmpty {
            providerQuotas[.codex] = quotas
        }
    }
    
    /// Refresh Gemini quota using CLI auth file (~/.gemini/oauth_creds.json)
    private func refreshGeminiCLIQuotasInternal() async {
        // Only use CLI fetcher in quota-only mode
        guard modeManager.isMonitorMode else { return }

        let quotas = await geminiCLIFetcher.fetchAsProviderQuota()
        if !quotas.isEmpty {
            if var existing = providerQuotas[.gemini] {
                for (email, quota) in quotas {
                    existing[email] = quota
                }
                providerQuotas[.gemini] = existing
            } else {
                providerQuotas[.gemini] = quotas
            }
        }
    }

    /// Refresh GLM quota using API keys from CustomProviderService
    private func refreshGlmQuotasInternal() async {
        let quotas = await glmFetcher.fetchAllQuotas()
        if !quotas.isEmpty {
            providerQuotas[.glm] = quotas
        } else {
            providerQuotas.removeValue(forKey: .glm)
        }
    }
    
    /// Refresh Warp quota using API keys from WarpService
    private func refreshWarpQuotasInternal() async {
        let warpTokens = await MainActor.run {
            WarpService.shared.tokens.filter { $0.isEnabled }
        }
        
        var results: [String: ProviderQuotaData] = [:]
        
        for entry in warpTokens {
            do {
                let quota = try await warpFetcher.fetchQuota(apiKey: entry.token)
                results[entry.name] = quota
            } catch {
                Log.quota("Failed to fetch Warp quota for \(entry.name): \(error)")
            }
        }
        
        if !results.isEmpty {
            providerQuotas[.warp] = results
        } else {
            providerQuotas.removeValue(forKey: .warp)
        }
    }
    
    /// Refresh Trae quota using SQLite database
    private func refreshTraeQuotasInternal() async {
        let quotas = await traeFetcher.fetchAsProviderQuota()
        if quotas.isEmpty {
            providerQuotas.removeValue(forKey: .trae)
        } else {
            providerQuotas[.trae] = quotas
        }
    }
    
    /// Refresh Kiro quota using IDE JSON tokens
    private func refreshKiroQuotasInternal() async {
        let rawQuotas = await kiroFetcher.fetchAllQuotas()
        
        var remappedQuotas: [String: ProviderQuotaData] = [:]
        
        // Helper: clean filename (remove .json)
        func cleanName(_ name: String) -> String {
            name.replacingOccurrences(of: ".json", with: "")
        }
        
        // 1. Remap for Proxy AuthFiles
        var consumedRawKeys = Set<String>()
        
        for file in authFiles where file.providerType == .kiro {
            // The fetcher returns data keyed by clean filename
            let filenameKey = cleanName(file.name)

            if let data = rawQuotas[filenameKey] {
                // Store under the key the UI expects (AuthFile.quotaLookupKey)
                let targetKey = file.quotaLookupKey.isEmpty ? file.name : file.quotaLookupKey
                remappedQuotas[targetKey] = data
                consumedRawKeys.insert(filenameKey)
            }
        }
        
        // 2. Remap for Direct AuthFiles (Monitor Mode)
        if modeManager.isMonitorMode {
            for file in directAuthFiles where file.provider == .kiro {
                let filenameKey = cleanName(file.filename)
                
                // Skip if already processed by Proxy loop
                if consumedRawKeys.contains(filenameKey) { continue }
                
                if let data = rawQuotas[filenameKey] {
                    let targetKey = file.email ?? file.filename
                    remappedQuotas[targetKey] = data
                    consumedRawKeys.insert(filenameKey)
                }
            }
        }
        
        // 3. Fallback: Include original keys ONLY if not mapped
        for (key, data) in rawQuotas {
            if !consumedRawKeys.contains(key) {
                remappedQuotas[key] = data
            }
        }

        if remappedQuotas.isEmpty {
            providerQuotas.removeValue(forKey: .kiro)
        } else {
            providerQuotas[.kiro] = remappedQuotas
        }
    }
    
    /// Start auto-refresh for quota-only mode
    private func startQuotaOnlyAutoRefresh() {
        refreshTask?.cancel()
        
        guard let intervalNs = refreshSettings.refreshCadence.intervalNanoseconds else {
            // Manual mode - no auto-refresh
            return
        }
        
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: intervalNs)
                guard NSApplication.shared.isActive else { continue }
                _ = await kiroFetcher.refreshAllTokensIfNeeded()
                await refreshQuotasDirectly()
            }
        }
    }
    
    /// Start auto-refresh for quota when proxy is not running (Full Mode)
    private func startQuotaAutoRefreshWithoutProxy() {
        refreshTask?.cancel()
        
        guard let intervalNs = refreshSettings.refreshCadence.intervalNanoseconds else {
            return
        }
        
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: intervalNs)
                guard NSApplication.shared.isActive else { continue }
                if !proxyManager.proxyStatus.running {
                    _ = await kiroFetcher.refreshAllTokensIfNeeded()
                    await refreshQuotasUnified()
                }
            }
        }
    }

    // MARK: - Warmup

    func isWarmupEnabled(for provider: AIProvider, accountKey: String) -> Bool {
        warmupSettings.isEnabled(provider: provider, accountKey: accountKey)
    }

    func warmupStatus(provider: AIProvider, accountKey: String) -> WarmupStatus {
        let key = WarmupAccountKey(provider: provider, accountKey: accountKey)
        return warmupStatuses[key] ?? WarmupStatus()
    }

    func warmupNextRunDate(provider: AIProvider, accountKey: String) -> Date? {
        let key = WarmupAccountKey(provider: provider, accountKey: accountKey)
        return warmupNextRun[key]
    }

    func toggleWarmup(for provider: AIProvider, accountKey: String) {
        guard provider == .antigravity else {
            // Warmup not supported for this provider; no log.
            return
        }
        warmupSettings.toggle(provider: provider, accountKey: accountKey)
        // Warmup toggle state changed; no log.
    }

    func setWarmupEnabled(_ enabled: Bool, provider: AIProvider, accountKey: String) {
        guard provider == .antigravity else {
            // Warmup not supported for this provider; no log.
            return
        }
        if warmupSettings.isEnabled(provider: provider, accountKey: accountKey) == enabled {
            return
        }
        warmupSettings.setEnabled(enabled, provider: provider, accountKey: accountKey)
        // Warmup toggle state changed; no log.
    }

    private func nextDailyRunDate(minutes: Int, now: Date) -> Date {
        let calendar = Calendar.current
        let hour = minutes / 60
        let minute = minutes % 60
        let today = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
        if today > now {
            return today
        }
        return calendar.date(byAdding: .day, value: 1, to: today) ?? today
    }

    private func restartWarmupScheduler() {
        warmupTask?.cancel()
        
        guard !warmupSettings.enabledAccountIds.isEmpty else { return }
        
        let now = Date()
        warmupNextRun = [:]
        for target in warmupTargets() {
            let mode = warmupSettings.warmupScheduleMode(provider: target.provider, accountKey: target.accountKey)
            switch mode {
            case .interval:
                warmupNextRun[target] = now
            case .daily:
                let minutes = warmupSettings.warmupDailyMinutes(provider: target.provider, accountKey: target.accountKey)
                warmupNextRun[target] = nextDailyRunDate(minutes: minutes, now: now)
            }
            updateWarmupStatus(for: target) { status in
                status.nextRun = warmupNextRun[target]
            }
        }
        guard !warmupNextRun.isEmpty else { return }
        
        warmupTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                guard let next = warmupNextRun.values.min() else { return }
                let delay = max(next.timeIntervalSince(Date()), 1)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                await runWarmupCycle()
            }
        }
    }

    private func runWarmupCycle() async {
        guard !isWarmupRunning else { return }
        let targets = warmupTargets()
        guard !targets.isEmpty else { return }
        
        guard proxyManager.proxyStatus.running else {
            let now = Date()
            for target in targets {
                let mode = warmupSettings.warmupScheduleMode(provider: target.provider, accountKey: target.accountKey)
                switch mode {
                case .interval:
                    let cadence = warmupSettings.warmupCadence(provider: target.provider, accountKey: target.accountKey)
                    warmupNextRun[target] = now.addingTimeInterval(cadence.intervalSeconds)
                case .daily:
                    let minutes = warmupSettings.warmupDailyMinutes(provider: target.provider, accountKey: target.accountKey)
                    warmupNextRun[target] = nextDailyRunDate(minutes: minutes, now: now)
                }
                updateWarmupStatus(for: target) { status in
                    status.nextRun = warmupNextRun[target]
                }
            }
            return
        }
        
        isWarmupRunning = true
        defer { isWarmupRunning = false }
        
        // Warmup cycle started; no log.
        
        let now = Date()
        let dueTargets = targets.filter { target in
            guard let next = warmupNextRun[target] else { return false }
            return next <= now
        }
        
        for target in dueTargets {
            if Task.isCancelled { break }
            await warmupAccount(
                provider: target.provider,
                accountKey: target.accountKey
            )
            let mode = warmupSettings.warmupScheduleMode(provider: target.provider, accountKey: target.accountKey)
            switch mode {
            case .interval:
                let cadence = warmupSettings.warmupCadence(provider: target.provider, accountKey: target.accountKey)
                warmupNextRun[target] = Date().addingTimeInterval(cadence.intervalSeconds)
            case .daily:
                let minutes = warmupSettings.warmupDailyMinutes(provider: target.provider, accountKey: target.accountKey)
                warmupNextRun[target] = nextDailyRunDate(minutes: minutes, now: Date())
            }
            updateWarmupStatus(for: target) { status in
                status.nextRun = warmupNextRun[target]
                status.lastError = nil
            }
        }

        for target in targets where !dueTargets.contains(target) {
            updateWarmupStatus(for: target) { status in
                status.lastError = nil
            }
        }
    }

    private func warmupAccount(provider: AIProvider, accountKey: String) async {
        guard provider == .antigravity else {
            // Warmup not supported for this provider; no log.
            return
        }
        let account = WarmupAccountKey(provider: provider, accountKey: accountKey)
        guard warmupRunningAccounts.insert(account).inserted else {
            // Warmup already running for this account; no log.
            return
        }
        defer { warmupRunningAccounts.remove(account) }
        guard proxyManager.proxyStatus.running else {
            // Warmup skipped when proxy is not running; no log.
            return
        }
        
        guard let apiClient else {
            // Warmup skipped when management client is missing; no log.
            return
        }
        
        guard let authInfo = warmupAuthInfo(provider: provider, accountKey: accountKey) else {
            // Warmup skipped when auth index is missing; no log.
            return
        }
        
        let availableModels = await fetchWarmupModels(
            provider: provider,
            accountKey: accountKey,
            authFileName: authInfo.authFileName,
            apiClient: apiClient
        )
        guard !availableModels.isEmpty else {
            // Warmup skipped when no models are available; no log.
            return
        }
        await warmupAccount(
            provider: provider,
            accountKey: accountKey,
            availableModels: availableModels,
            authIndex: authInfo.authIndex,
            authFileName: authInfo.authFileName,
            apiClient: apiClient
        )
    }

    private func warmupAccount(
        provider: AIProvider,
        accountKey: String,
        availableModels: [WarmupModelInfo],
        authIndex: String,
        authFileName: String,
        apiClient: ManagementAPIClient
    ) async {
        guard provider == .antigravity else {
            // Warmup not supported for this provider; no log.
            return
        }
        let availableIds = availableModels.map(\.id)
        let selectedModels = warmupSettings.selectedModels(provider: provider, accountKey: accountKey)
        let models = selectedModels.filter { availableIds.contains($0) }
        guard !models.isEmpty else {
            // Warmup skipped when no matching models; no log.
            return
        }
        let account = WarmupAccountKey(provider: provider, accountKey: accountKey)
        updateWarmupStatus(for: account) { status in
            status.isRunning = true
            status.lastError = nil
            status.progressTotal = models.count
            status.progressCompleted = 0
            status.currentModel = nil
            for model in models {
                status.modelStates[model] = .pending
            }
        }
        
        for model in models {
            if Task.isCancelled { break }
            do {
                updateWarmupStatus(for: account) { status in
                    status.currentModel = model
                    status.modelStates[model] = .running
                }
                try await warmupService.warmup(
                    managementClient: apiClient,
                    authIndex: authIndex,
                    authFileName: authFileName,
                    model: model
                )
                updateWarmupStatus(for: account) { status in
                    status.progressCompleted += 1
                    status.modelStates[model] = .succeeded
                }
            } catch {
                updateWarmupStatus(for: account) { status in
                    status.progressCompleted += 1
                    status.modelStates[model] = .failed
                    status.lastError = error.localizedDescription
                }
            }
        }
        updateWarmupStatus(for: account) { status in
            status.isRunning = false
            status.currentModel = nil
            status.lastRun = Date()
        }
    }

    private func fetchWarmupModels(
        provider: AIProvider,
        accountKey: String,
        authFileName: String,
        apiClient: ManagementAPIClient
    ) async -> [WarmupModelInfo] {
        do {
            let key = WarmupAccountKey(provider: provider, accountKey: accountKey)
            if let cached = warmupModelCache[key] {
                let age = Date().timeIntervalSince(cached.fetchedAt)
                if age <= warmupModelCacheTTL {
                    return cached.models
                }
            }
            let models = try await warmupService.fetchModels(managementClient: apiClient, authFileName: authFileName)
            warmupModelCache[key] = (models: models, fetchedAt: Date())
            // Warmup fetched models; no log.
            return models
        } catch {
            // Warmup fetch failed; no log.
            return []
        }
    }

    func warmupAvailableModels(provider: AIProvider, accountKey: String) async -> [String] {
        guard provider == .antigravity else { return [] }
        guard let apiClient else { return [] }
        guard let authInfo = warmupAuthInfo(provider: provider, accountKey: accountKey) else { return [] }
        let models = await fetchWarmupModels(
            provider: provider,
            accountKey: accountKey,
            authFileName: authInfo.authFileName,
            apiClient: apiClient
        )
        return models.map(\.id).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private func warmupAuthInfo(provider: AIProvider, accountKey: String) -> (authIndex: String, authFileName: String)? {
        guard let authFile = authFiles.first(where: {
            $0.providerType == provider && $0.quotaLookupKey == accountKey
        }) else {
            // Warmup skipped when auth file is missing; no log.
            return nil
        }
        
        guard let authIndex = authFile.authIndex, !authIndex.isEmpty else {
            // Warmup skipped when auth index is missing; no log.
            return nil
        }
        
        let name = authFile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            // Warmup skipped when auth file name is missing; no log.
            return nil
        }
        
        return (authIndex: authIndex, authFileName: name)
    }

    private func warmupTargets() -> [WarmupAccountKey] {
        let keys = warmupSettings.enabledAccountIds.compactMap { id in
            WarmupSettingsManager.parseAccountId(id)
        }
        return keys.filter { $0.provider == .antigravity }.sorted { lhs, rhs in
            if lhs.provider.displayName == rhs.provider.displayName {
                return lhs.accountKey < rhs.accountKey
            }
            return lhs.provider.displayName < rhs.provider.displayName
        }
    }

    // Warmup logging intentionally disabled.
    
    private func updateWarmupStatus(for key: WarmupAccountKey, update: (inout WarmupStatus) -> Void) {
        var status = warmupStatuses[key] ?? WarmupStatus()
        update(&status)
        warmupStatuses[key] = status
    }
    
    var authFilesByProvider: [AIProvider: [AuthFile]] {
        var result: [AIProvider: [AuthFile]] = [:]
        for file in authFiles {
            if let provider = file.providerType {
                result[provider, default: []].append(file)
            }
        }
        return result
    }
    
    var connectedProviders: [AIProvider] {
        Array(Set(authFiles.compactMap { $0.providerType })).sorted { $0.displayName < $1.displayName }
    }
    
    var disconnectedProviders: [AIProvider] {
        AIProvider.allCases.filter { provider in
            !connectedProviders.contains(provider)
        }
    }
    
    var totalAccounts: Int { authFiles.count }
    var readyAccounts: Int { authFiles.filter { $0.isReady }.count }
    
    func startProxy() async {
        guard !isStartingProxyFlow else { return }
        isStartingProxyFlow = true

        defer {
            isStartingProxyFlow = false
        }

        do {
            // Wire up ProxyBridge callback to RequestTracker before starting
            proxyManager.proxyBridge.onRequestCompleted = { [weak self] metadata in
                self?.requestTracker.addRequest(from: metadata)
            }

            try await proxyManager.start()
            setupAPIClient()
            await requestTracker.configureRouteObserver(
                baseURL: proxyManager.managementURL,
                authKey: proxyManager.managementKey
            )
            requestTracker.start()

            if RuntimeProfile.proxyOnlyTestMode {
                return
            }
            startAutoRefresh()
            restartWarmupScheduler()

            await refreshData()

            // Sync local disabled states to backend after data is loaded
            await syncDisabledStatesToBackend()
            await refreshData()

            await runWarmupCycle()

            // Check for proxy upgrade (non-blocking, fire-and-forget)
            Task {
                await checkForProxyUpgrade()
            }

            let autoStartTunnel = UserDefaults.standard.bool(forKey: "autoStartTunnel")
            if autoStartTunnel && tunnelManager.installation.isInstalled {
                await tunnelManager.startTunnel(port: proxyManager.port)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func stopProxy() {
        refreshTask?.cancel()
        refreshTask = nil

        if tunnelManager.tunnelState.isActive || tunnelManager.tunnelState.status == .starting {
            Task { @MainActor in
                await tunnelManager.stopTunnel()
            }
        }
        
        // Stop RequestTracker
        requestTracker.stop()
        requestTracker.resetRouteObserver()
        
        proxyManager.stop()
        restartWarmupScheduler()
        
        // Invalidate URLSession to close all connections
        // Capture client reference before setting to nil to avoid race condition
        let clientToInvalidate = _apiClient
        _apiClient = nil
        
        if let client = clientToInvalidate {
            Task {
                await client.invalidate()
            }
        }
    }
    
    func toggleProxy() async {
        if proxyManager.proxyStatus.running {
            stopProxy()
        } else {
            await startProxy()
        }
    }
    
    private func setupAPIClient() {
        _apiClient = ManagementAPIClient(
            baseURL: proxyManager.managementURL,
            authKey: proxyManager.managementKey
        )
    }
    
    private func startAutoRefresh() {
        refreshTask?.cancel()
        
        guard let intervalNs = refreshSettings.refreshCadence.intervalNanoseconds else {
            return
        }
        
        refreshTask = Task {
            var consecutiveFailures = 0
            let maxFailuresBeforeRecovery = max(3, Int(180_000_000_000 / intervalNs))
            
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: intervalNs)
                guard NSApplication.shared.isActive else { continue }
                
                await refreshData()
                
                if errorMessage != nil {
                    consecutiveFailures += 1
                    Log.quota("Refresh failed, consecutive failures: \(consecutiveFailures)")
                    
                    if consecutiveFailures >= maxFailuresBeforeRecovery {
                        Log.quota("Attempting proxy recovery...")
                        await attemptProxyRecovery()
                        consecutiveFailures = 0
                    }
                } else {
                    if consecutiveFailures > 0 {
                        Log.quota("Refresh succeeded, resetting failure count")
                    }
                    consecutiveFailures = 0
                }
            }
        }
    }
    
    /// Attempt to recover an unresponsive proxy
    private func attemptProxyRecovery() async {
        // Check if process is still running
        if proxyManager.proxyStatus.running {
            // Proxy process is running but not responding - likely hung
            // Stop and restart
            stopProxy()
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            await startProxy()
        }
    }
    
    @ObservationIgnored private var lastQuotaRefresh: Date?
    
    private var quotaRefreshInterval: TimeInterval {
        refreshSettings.refreshCadence.intervalSeconds ?? 60
    }

    private var managementUnavailableMessage: String {
        modeManager.isRemoteProxyMode ? "Remote server not connected" : "Proxy not running"
    }

    /// 本地代理重启或重建密钥后，旧 client 可能仍持有过期 management key。
    /// 对本地 401 做一次重建并重试，避免账号代理/禁用/删除等操作偶发失败。
    private func withManagementClient<T: Sendable>(
        operationName: String,
        _ operation: (ManagementAPIClient) async throws -> T
    ) async throws -> T {
        guard let client = apiClient else {
            throw APIError.connectionError(managementUnavailableMessage)
        }

        do {
            return try await operation(client)
        } catch APIError.httpError(401) where !modeManager.isRemoteProxyMode && proxyManager.proxyStatus.running {
            Log.warning("\(operationName): management key rejected, rebuilding local client and retrying once")
            setupAPIClient()
            await requestTracker.configureRouteObserver(
                baseURL: proxyManager.managementURL,
                authKey: proxyManager.managementKey
            )

            guard let refreshedClient = apiClient else {
                throw APIError.connectionError(managementUnavailableMessage)
            }

            return try await operation(refreshedClient)
        }
    }
    
    func refreshData() async {
        do {
            let snapshot = try await withManagementClient(operationName: "refreshData") { client in
                // Serialize requests to avoid connection contention (issue #37)
                // This reduces pressure on the connection pool
                let newAuthFiles = try await client.fetchAuthFiles()
                let usageStats = try await client.fetchUsageStats()
                let apiKeys = try await client.fetchAPIKeys()
                return (newAuthFiles, usageStats, apiKeys)
            }
            let newAuthFiles = snapshot.0

            // Only update timestamp if auth files actually changed (account added/removed)
            let oldNames = Set(self.authFiles.map { $0.name })
            let newNames = Set(newAuthFiles.map { $0.name })
            if oldNames != newNames {
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Self.authFilesChangedKey)
            }

            self.authFiles = newAuthFiles

            self.usageStats = snapshot.1
            self.apiKeys = snapshot.2
            
            // Clear any previous error on success
            errorMessage = nil
            
            checkAccountStatusChanges()
            
            // Prune menu bar items for accounts that no longer exist
            pruneMenuBarItems()
            
            let shouldRefreshQuotas: Bool
            if let lastRefresh = lastQuotaRefresh {
                shouldRefreshQuotas = Date().timeIntervalSince(lastRefresh) >= quotaRefreshInterval
            } else {
                shouldRefreshQuotas = true
            }
            
            if shouldRefreshQuotas && !isLoadingQuotas {
                Task {
                    await refreshAllQuotas()
                }
            }
        } catch {
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func manualRefresh() async {
        if modeManager.isMonitorMode {
            await refreshQuotasDirectly()
        } else if proxyManager.proxyStatus.running {
            await refreshData()
        } else {
            await refreshQuotasUnified()
        }
        lastQuotaRefreshTime = Date()
    }
    
    func refreshAllQuotas() async {
        guard !isLoadingQuotas else { return }

        isLoadingQuotas = true
        lastQuotaRefresh = Date()

        // In remote mode, skip local filesystem fetchers — only show data from the remote proxy
        // (auth files, usage stats, API keys are already fetched by refreshData())
        if !modeManager.isRemoteProxyMode {
            // Note: Cursor and Trae removed from auto-refresh (issue #29)
            // User must use "Scan for IDEs" to detect these
            async let antigravity: () = refreshAntigravityQuotasInternal()
            async let openai: () = refreshOpenAIQuotasInternal()
            async let copilot: () = refreshCopilotQuotasInternal()
            async let claudeCode: () = refreshClaudeCodeQuotasInternal()
            async let glm: () = refreshGlmQuotasInternal()
            async let warp: () = refreshWarpQuotasInternal()
            async let kiro: () = refreshKiroQuotasInternal()

            _ = await (antigravity, openai, copilot, claudeCode, glm, warp, kiro)
        }

        checkQuotaNotifications()
        pruneMenuBarItems()
        autoSelectMenuBarItems()

        isLoadingQuotas = false
        notifyQuotaDataChanged()
    }

    /// Unified quota refresh - works in both Full Mode and Quota-Only Mode
    /// In Full Mode: uses direct fetchers (works without proxy)
    /// In Quota-Only Mode: uses direct fetchers + CLI fetchers
    /// In Remote Mode: skips local fetchers (data comes from remote proxy)
    /// Note: Cursor and Trae require explicit user scan (issue #29)
    func refreshQuotasUnified() async {
        guard !isLoadingQuotas else { return }
        guard !modeManager.isRemoteProxyMode else { return }

        isLoadingQuotas = true
        lastQuotaRefreshTime = Date()
        lastQuotaRefresh = Date()

        // Refresh direct fetchers (these don't need proxy)
        // Note: Cursor and Trae removed - require explicit scan (issue #29)
        async let antigravity: () = refreshAntigravityQuotasInternal()
        async let openai: () = refreshOpenAIQuotasInternal()
        async let copilot: () = refreshCopilotQuotasInternal()
        async let claudeCode: () = refreshClaudeCodeQuotasInternal()
        async let glm: () = refreshGlmQuotasInternal()
        async let warp: () = refreshWarpQuotasInternal()
        async let kiro: () = refreshKiroQuotasInternal()

        // In Quota-Only Mode, also include CLI fetchers
        if modeManager.isMonitorMode {
            async let codexCLI: () = refreshCodexCLIQuotasInternal()
            async let geminiCLI: () = refreshGeminiCLIQuotasInternal()
            _ = await (antigravity, openai, copilot, claudeCode, glm, warp, kiro, codexCLI, geminiCLI)
        } else {
            _ = await (antigravity, openai, copilot, claudeCode, glm, warp, kiro)
        }

        checkQuotaNotifications()
        pruneMenuBarItems()
        autoSelectMenuBarItems()

        isLoadingQuotas = false
        notifyQuotaDataChanged()
    }

    private func refreshAntigravityQuotasInternal() async {
        // Fetch both quotas and subscriptions in one call (avoids duplicate API calls)
        let (quotas, subscriptions) = await antigravityFetcher.fetchAllAntigravityData()
        
        providerQuotas[.antigravity] = quotas
        
        // Merge instead of replace to preserve data if API fails
        var providerInfos = subscriptionInfos[.antigravity] ?? [:]
        for (email, info) in subscriptions {
            providerInfos[email] = info
        }
        subscriptionInfos[.antigravity] = providerInfos
        
        // Detect active account in IDE (reads email directly from database)
        await antigravitySwitcher.detectActiveAccount()
    }
    
    /// Refresh Antigravity quotas without re-detecting active account
    /// Used after switching accounts (active account already set by switch operation)
    private func refreshAntigravityQuotasWithoutDetect() async {
        let (quotas, subscriptions) = await antigravityFetcher.fetchAllAntigravityData()
        
        providerQuotas[.antigravity] = quotas
        
        var providerInfos = subscriptionInfos[.antigravity] ?? [:]
        for (email, info) in subscriptions {
            providerInfos[email] = info
        }
        subscriptionInfos[.antigravity] = providerInfos
        // Note: Don't call detectActiveAccount() here - already set by switch operation
    }
    
    // MARK: - Antigravity Account Switching
    
    /// Check if an Antigravity account is currently active in the IDE
    /// Simply compares email from database with the given email
    func isAntigravityAccountActive(email: String) -> Bool {
        return antigravitySwitcher.isActiveAccount(email: email)
    }
    
    /// Switch Antigravity account in the IDE
    func switchAntigravityAccount(email: String) async {
        await antigravitySwitcher.executeSwitchForEmail(email)

        // Refresh to update active account
        if case .success = antigravitySwitcher.switchState {
            await refreshAntigravityQuotasWithoutDetect()
        }
    }
    
    /// Begin the switch confirmation flow
    func beginAntigravitySwitch(accountId: String, email: String) {
        antigravitySwitcher.beginSwitch(accountId: accountId, accountEmail: email)
    }
    
    /// Cancel the switch operation
    func cancelAntigravitySwitch() {
        antigravitySwitcher.cancelSwitch()
    }
    
    /// Dismiss switch result
    func dismissAntigravitySwitchResult() {
        antigravitySwitcher.dismissResult()
    }
    
    private func refreshOpenAIQuotasInternal() async {
        let quotas = await openAIFetcher.fetchAllCodexQuotas()
        providerQuotas[.codex] = quotas
    }
    
    private func refreshCopilotQuotasInternal() async {
        let quotas = await copilotFetcher.fetchAllCopilotQuotas()
        providerQuotas[.copilot] = quotas
    }
    
    func refreshQuotaForProvider(_ provider: AIProvider) async {
        switch provider {
        case .antigravity:
            await refreshAntigravityQuotasInternal()
        case .codex:
            await refreshOpenAIQuotasInternal()
            await refreshCodexCLIQuotasInternal()
        case .copilot:
            await refreshCopilotQuotasInternal()
        case .claude:
            await refreshClaudeCodeQuotasInternal()
        case .cursor:
            await refreshCursorQuotasInternal()
        case .gemini:
            await refreshGeminiCLIQuotasInternal()
        case .trae:
            await refreshTraeQuotasInternal()
        case .glm:
            await refreshGlmQuotasInternal()
        case .warp:
            await refreshWarpQuotasInternal()
        case .kiro:
            await refreshKiroQuotasInternal()
        default:
            break
        }

        // Prune menu bar items after refresh to remove deleted accounts
        pruneMenuBarItems()

        notifyQuotaDataChanged()
    }

    /// Refresh all auto-detected providers (those that don't support manual auth)
    func refreshAutoDetectedProviders() async {
        let autoDetectedProviders = AIProvider.allCases.filter { !$0.supportsManualAuth }
        
        for provider in autoDetectedProviders {
            await refreshQuotaForProvider(provider)
        }
    }

    private func preparePendingAccountSetup(for provider: AIProvider, remark: String?, proxyURL: String?) {
        let normalizedRemark = remark?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedProxyURL = ProxyURLValidator.validate(proxyURL ?? "").isValid
            ? (proxyURL?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? ProxyURLValidator.sanitize(proxyURL ?? "") : nil)
            : nil

        guard (normalizedRemark?.isEmpty == false) || sanitizedProxyURL != nil else {
            pendingAccountSetup = nil
            return
        }

        let existingAuthFileNames = Set(
            authFiles
                .filter { $0.providerType == provider }
                .map(\.name)
        )

        pendingAccountSetup = PendingAccountSetup(
            provider: provider,
            remark: normalizedRemark?.isEmpty == true ? nil : normalizedRemark,
            proxyURL: sanitizedProxyURL,
            existingAuthFileNames: existingAuthFileNames,
            startedAt: Date()
        )
    }

    private func clearPendingAccountSetup(for provider: AIProvider) {
        guard pendingAccountSetup?.provider == provider else {
            return
        }
        pendingAccountSetup = nil
    }

    private func applyPendingAccountSetupIfNeeded(for provider: AIProvider) async {
        guard let pending = pendingAccountSetup, pending.provider == provider else {
            return
        }
        defer { pendingAccountSetup = nil }

        guard let targetAuthFile = resolvePendingAccountTarget(from: pending) else {
            return
        }

        if let remark = pending.remark {
            let metadataKey = AccountMetadataStore.authFileKey(provider: provider, fileName: targetAuthFile.name)
            accountMetadataStore.setRemark(remark, for: metadataKey)
        }

        if let proxyURL = pending.proxyURL {
            do {
                try await updateAuthFileProxyURL(proxyURL, for: targetAuthFile)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func resolvePendingAccountTarget(from pending: PendingAccountSetup) -> AuthFile? {
        let providerFiles = authFiles.filter { $0.providerType == pending.provider }
        let newFiles = providerFiles.filter { !pending.existingAuthFileNames.contains($0.name) }

        if !newFiles.isEmpty {
            return newFiles.max { lhs, rhs in
                authFileTimestamp(for: lhs) < authFileTimestamp(for: rhs)
            }
        }

        return providerFiles
            .filter { authFileTimestamp(for: $0) >= pending.startedAt.addingTimeInterval(-5) }
            .max { lhs, rhs in
                authFileTimestamp(for: lhs) < authFileTimestamp(for: rhs)
            }
    }

    private func authFileTimestamp(for file: AuthFile) -> Date {
        for candidate in [file.updatedAt, file.createdAt, file.lastRefresh] {
            guard let candidate else { continue }
            if let parsed = Self.parseISO8601Timestamp(candidate) {
                return parsed
            }
        }
        return .distantPast
    }

    private nonisolated static func parseISO8601Timestamp(_ value: String) -> Date? {
        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFractional.date(from: value) {
            return date
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }
    
    func startOAuth(for provider: AIProvider, projectId: String? = nil, authMethod: AuthCommand? = nil, remark: String? = nil, proxyURL: String? = nil) async {
        preparePendingAccountSetup(for: provider, remark: remark, proxyURL: proxyURL)

        // GitHub Copilot uses Device Code Flow via CLI binary, not Management API
        if provider == .copilot {
            await startCopilotAuth()
            return
        }
        
        // Kiro uses CLI-based auth with multiple options
        if provider == .kiro {
            await startKiroAuth(method: authMethod ?? .kiroGoogleLogin)
            return
        }

        oauthState = OAuthState(provider: provider, status: .waiting)
        
        do {
            let response = try await withManagementClient(operationName: "startOAuth") { client in
                try await client.getOAuthURL(for: provider, projectId: projectId)
            }
            
            guard response.status == "ok", let urlString = response.url, let state = response.state else {
                oauthState = OAuthState(provider: provider, status: .error, error: response.error)
                return
            }
            
            // Store URL for copy/open buttons (don't auto-open browser)
            oauthState = OAuthState(provider: provider, status: .polling, state: state, authURL: urlString)
            await pollOAuthStatus(state: state, provider: provider)
            
        } catch {
            if apiClient == nil {
                clearPendingAccountSetup(for: provider)
            }
            oauthState = OAuthState(provider: provider, status: .error, error: error.localizedDescription)
        }
    }
    
    /// Start GitHub Copilot authentication using Device Code Flow
    private func startCopilotAuth() async {
        oauthState = OAuthState(provider: .copilot, status: .waiting)
        
        let result = await proxyManager.runAuthCommand(.copilotLogin)
        
        if result.success {
            if let deviceCode = result.deviceCode {
                oauthState = OAuthState(provider: .copilot, status: .polling, state: deviceCode, error: result.message)
            } else {
                oauthState = OAuthState(provider: .copilot, status: .polling, error: result.message)
            }
            
            await pollCopilotAuthCompletion()
        } else {
            clearPendingAccountSetup(for: .copilot)
            oauthState = OAuthState(provider: .copilot, status: .error, error: result.message)
        }
    }
    
    private func startKiroAuth(method: AuthCommand) async {
        oauthState = OAuthState(provider: .kiro, status: .waiting)
        
        let result = await proxyManager.runAuthCommand(method)
        
        if result.success {
            // Check if it's an import - simply wait and refresh, don't poll for new files (files might already exist)
            if method == .kiroImport {
                oauthState = OAuthState(provider: .kiro, status: .polling, error: "Importing quotas...")
                
                // Allow some time for file operations
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await refreshData()
                await applyPendingAccountSetupIfNeeded(for: .kiro)
                
                // For import, we assume success if the command succeeded
                oauthState = OAuthState(provider: .kiro, status: .success)
                return
            }
            
            // For other methods (login), poll for new auth files
            if let deviceCode = result.deviceCode {
                oauthState = OAuthState(provider: .kiro, status: .polling, state: deviceCode, error: result.message)
            } else {
                oauthState = OAuthState(provider: .kiro, status: .polling, error: result.message)
            }
            
            await pollKiroAuthCompletion()
        } else {
            clearPendingAccountSetup(for: .kiro)
            oauthState = OAuthState(provider: .kiro, status: .error, error: result.message)
        }
    }
    
    /// Poll for Copilot auth completion by monitoring auth files
    private func pollCopilotAuthCompletion() async {
        let startFileCount = authFiles.filter { $0.provider == "github-copilot" || $0.provider == "copilot" }.count
        
        for _ in 0..<90 {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await refreshData()
            
            let currentFileCount = authFiles.filter { $0.provider == "github-copilot" || $0.provider == "copilot" }.count
            if currentFileCount > startFileCount {
                await applyPendingAccountSetupIfNeeded(for: .copilot)
                oauthState = OAuthState(provider: .copilot, status: .success)
                return
            }
        }
        
        clearPendingAccountSetup(for: .copilot)
        oauthState = OAuthState(provider: .copilot, status: .error, error: "Authentication timeout")
    }
    
    private func pollKiroAuthCompletion() async {
        let startFileCount = authFiles.filter { $0.provider == "kiro" }.count
        
        for _ in 0..<90 {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await refreshData()
            
            let currentFileCount = authFiles.filter { $0.provider == "kiro" }.count
            if currentFileCount > startFileCount {
                await applyPendingAccountSetupIfNeeded(for: .kiro)
                oauthState = OAuthState(provider: .kiro, status: .success)
                return
            }
        }
        
        clearPendingAccountSetup(for: .kiro)
        oauthState = OAuthState(provider: .kiro, status: .error, error: "Authentication timeout")
    }
    
    private func pollOAuthStatus(state: String, provider: AIProvider) async {
        for _ in 0..<60 {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            do {
                let response = try await withManagementClient(operationName: "pollOAuthStatus") { client in
                    try await client.pollOAuthStatus(state: state)
                }
                
                switch response.status {
                case "ok":
                    await refreshData()
                    await applyPendingAccountSetupIfNeeded(for: provider)
                    oauthState = OAuthState(provider: provider, status: .success)
                    return
                case "error":
                    clearPendingAccountSetup(for: provider)
                    oauthState = OAuthState(provider: provider, status: .error, error: response.error)
                    return
                default:
                    continue
                }
            } catch {
                continue
            }
        }
        
        clearPendingAccountSetup(for: provider)
        oauthState = OAuthState(provider: provider, status: .error, error: "OAuth timeout")
    }
    
    func cancelOAuth() {
        pendingAccountSetup = nil
        oauthState = nil
    }
    
    func deleteAuthFile(_ file: AuthFile) async {
        do {
            try await withManagementClient(operationName: "deleteAuthFile") { client in
                try await client.deleteAuthFile(name: file.name)
            }

            let accountKey = file.quotaLookupKey.isEmpty ? file.name : file.quotaLookupKey

            // Remove quota data for this account
            if let provider = file.providerType {
                providerQuotas[provider]?.removeValue(forKey: accountKey)

                // Also try with email if different
                if let email = file.email, email != accountKey {
                    providerQuotas[provider]?.removeValue(forKey: email)
                }
            }

            // Clear persisted disabled flags for this account
            var disabledSet = loadDisabledAuthFiles()
            disabledSet.remove(file.name)
            disabledSet.remove(accountKey)
            if let email = file.email, email != accountKey {
                disabledSet.remove(email)
            }
            saveDisabledAuthFiles(disabledSet)

            // Prune menu bar items that no longer exist
            pruneMenuBarItems()

            await refreshData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleAuthFileDisabled(_ file: AuthFile) async {
        guard apiClient != nil else {
            Log.error("toggleAuthFileDisabled: No API client available")
            return
        }

        let newDisabled = !file.disabled

        do {
            Log.debug("toggleAuthFileDisabled: Setting \(file.name) disabled=\(newDisabled)")
            try await withManagementClient(operationName: "toggleAuthFileDisabled") { client in
                try await client.setAuthFileDisabled(name: file.name, disabled: newDisabled)
            }

            // Update local persistence
            var disabledSet = loadDisabledAuthFiles()
            if newDisabled {
                disabledSet.insert(file.name)
            } else {
                disabledSet.remove(file.name)
            }
            saveDisabledAuthFiles(disabledSet)

            Log.debug("toggleAuthFileDisabled: Success, refreshing data")
            await refreshData()
        } catch {
            Log.error("toggleAuthFileDisabled: Failed - \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    func toggleDirectAuthFileDisabled(_ file: DirectAuthFile) async {
        do {
            try await directAuthService.updateDisabled(filePath: file.filePath, disabled: !file.isDisabled)
            await loadDirectAuthFiles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadAuthFileProxyURL(_ file: AuthFile) async throws -> String? {
        let data = try await withManagementClient(operationName: "loadAuthFileProxyURL") { client in
            try await client.downloadAuthFile(name: file.name)
        }
        if let proxyURL = Self.parseProxyURL(from: data) {
            return proxyURL
        }

        return await directAuthFileForProxyFallback(named: file.name)?.proxyURL
    }

    func updateAuthFileProxyURL(_ proxyURL: String?, for file: AuthFile) async throws {
        let trimmedProxyURL = proxyURL?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        try await withManagementClient(operationName: "updateAuthFileProxyURL") { client in
            try await client.setAuthFileProxyURL(name: file.name, proxyURL: trimmedProxyURL)
        }

        let expectedProxyURL = trimmedProxyURL.isEmpty ? nil : trimmedProxyURL
        let persistedProxyURL = try await withManagementClient(operationName: "verifyAuthFileProxyURL") { client in
            let data = try await client.downloadAuthFile(name: file.name)
            return Self.parseProxyURL(from: data)
        }

        if persistedProxyURL != expectedProxyURL,
           let directAuthFile = await directAuthFileForProxyFallback(named: file.name) {
            Log.warning("updateAuthFileProxyURL: management API did not persist proxy_url for \(file.name), falling back to direct auth file update")
            try await directAuthService.updateProxyURL(filePath: directAuthFile.filePath, proxyURL: expectedProxyURL)
        }

        await refreshData()
        await loadDirectAuthFiles()
    }

    func loadAuthFileUserAgent(_ file: AuthFile) async throws -> String? {
        let data = try await withManagementClient(operationName: "loadAuthFileUserAgent") { client in
            try await client.downloadAuthFile(name: file.name)
        }
        if let userAgent = Self.parseUserAgent(from: data, provider: file.providerType) {
            return userAgent
        }

        if let directAuthFile = await directAuthFileForProxyFallback(named: file.name) {
            return Self.readStoredUserAgent(for: directAuthFile.provider, fromFileAt: directAuthFile.filePath)
        }
        return nil
    }

    func updateAuthFileUserAgent(_ userAgent: String?, for file: AuthFile) async throws {
        switch Self.userAgentStorage(for: file.providerType) {
        case .authField:
            guard let directAuthFile = await directAuthFileForProxyFallback(named: file.name) else {
                throw DirectAuthFileError.invalidAuthFile
            }

            try await directAuthService.updateUserAgent(filePath: directAuthFile.filePath, userAgent: userAgent)
        case .header:
            let expectedUserAgent = Self.trimmedNonEmpty(userAgent)

            do {
                try await withManagementClient(operationName: "updateAuthFileHeaderUserAgent") { client in
                    try await client.setAuthFileHeader(
                        name: file.name,
                        header: "User-Agent",
                        value: expectedUserAgent
                    )
                }
            } catch let APIError.httpError(statusCode) where statusCode == 400 || statusCode == 404 {
                guard let directAuthFile = await directAuthFileForProxyFallback(named: file.name) else {
                    throw APIError.httpError(statusCode)
                }
                Log.warning("updateAuthFileUserAgent: management API returned \(statusCode) for headers.User-Agent on \(file.name), falling back to direct auth file update")
                try await directAuthService.updateHeader(
                    filePath: directAuthFile.filePath,
                    header: "User-Agent",
                    value: expectedUserAgent
                )
                await refreshData()
                await loadDirectAuthFiles()
                return
            }

            let persistedUserAgent = try await withManagementClient(operationName: "verifyAuthFileHeaderUserAgent") { client in
                let data = try await client.downloadAuthFile(name: file.name)
                return Self.parseUserAgent(from: data, provider: file.providerType)
            }

            if persistedUserAgent != expectedUserAgent {
                guard let directAuthFile = await directAuthFileForProxyFallback(named: file.name) else {
                    throw APIError.invalidResponse
                }

                Log.warning("updateAuthFileUserAgent: management API did not persist headers.User-Agent for \(file.name), falling back to direct auth file update")
                try await directAuthService.updateHeader(
                    filePath: directAuthFile.filePath,
                    header: "User-Agent",
                    value: expectedUserAgent
                )
            }
        case .localOnly:
            break
        }

        await refreshData()
        await loadDirectAuthFiles()
    }

    func updateAuthFileManagedHeaders(
        _ headers: [String: String],
        managedHeaderNames: [String],
        for file: AuthFile
    ) async throws {
        guard Self.userAgentStorage(for: file.providerType) == .header else {
            return
        }

        let desiredHeaders = Self.sanitizedHeaders(headers)
        let managedNames = Self.normalizedHeaderNames(managedHeaderNames)

        let existingHeaders = try await withManagementClient(operationName: "loadAuthFileManagedHeaders") { client in
            let data = try await client.downloadAuthFile(name: file.name)
            return Self.parseHeaders(from: data)
        }
        let mergedHeaders = Self.mergeManagedHeaders(
            existing: existingHeaders,
            desired: desiredHeaders,
            managedHeaderNames: managedNames
        )

        do {
            try await withManagementClient(operationName: "updateAuthFileManagedHeaders") { client in
                try await client.setAuthFileHeaders(name: file.name, headers: mergedHeaders)
            }
        } catch let APIError.httpError(statusCode) where statusCode == 400 || statusCode == 404 {
            guard let directAuthFile = await directAuthFileForProxyFallback(named: file.name) else {
                throw APIError.httpError(statusCode)
            }
            Log.warning("updateAuthFileManagedHeaders: management API returned \(statusCode) for \(file.name), falling back to direct auth file update")
            try await directAuthService.replaceHeaders(filePath: directAuthFile.filePath, headers: mergedHeaders)
            await refreshData()
            await loadDirectAuthFiles()
            return
        }

        let persistedHeaders = try await withManagementClient(operationName: "verifyAuthFileManagedHeaders") { client in
            let data = try await client.downloadAuthFile(name: file.name)
            return Self.parseHeaders(from: data)
        }
        let persistedManagedHeaders = Self.selectManagedHeaders(
            from: persistedHeaders,
            managedHeaderNames: managedNames
        )
        let expectedManagedHeaders = Self.selectManagedHeaders(
            from: mergedHeaders,
            managedHeaderNames: managedNames
        )

        if Self.normalizedHeaders(persistedManagedHeaders) != Self.normalizedHeaders(expectedManagedHeaders) {
            guard let directAuthFile = await directAuthFileForProxyFallback(named: file.name) else {
                throw APIError.invalidResponse
            }

            Log.warning("updateAuthFileManagedHeaders: management API did not persist managed headers for \(file.name), falling back to direct auth file update")
            try await directAuthService.replaceHeaders(filePath: directAuthFile.filePath, headers: mergedHeaders)
        }

        await refreshData()
        await loadDirectAuthFiles()
    }

    func updateDirectAuthFileUserAgent(_ userAgent: String?, for file: DirectAuthFile) async throws {
        switch Self.userAgentStorage(for: file.provider) {
        case .authField:
            try await directAuthService.updateUserAgent(filePath: file.filePath, userAgent: userAgent)
        case .header:
            try await directAuthService.updateHeader(
                filePath: file.filePath,
                header: "User-Agent",
                value: userAgent
            )
        case .localOnly:
            break
        }
        await loadDirectAuthFiles()
    }

    func updateDirectAuthFileManagedHeaders(
        _ headers: [String: String],
        managedHeaderNames: [String],
        for file: DirectAuthFile
    ) async throws {
        guard Self.userAgentStorage(for: file.provider) == .header else {
            return
        }

        let desiredHeaders = Self.sanitizedHeaders(headers)
        let managedNames = Self.normalizedHeaderNames(managedHeaderNames)
        let existingHeaders = Self.readStoredHeaders(fromFileAt: file.filePath)
        let mergedHeaders = Self.mergeManagedHeaders(
            existing: existingHeaders,
            desired: desiredHeaders,
            managedHeaderNames: managedNames
        )

        try await directAuthService.replaceHeaders(filePath: file.filePath, headers: mergedHeaders)
        await loadDirectAuthFiles()
    }

    func updateDirectAuthFileProxyURL(_ proxyURL: String?, for file: DirectAuthFile) async throws {
        try await directAuthService.updateProxyURL(filePath: file.filePath, proxyURL: proxyURL)
        await loadDirectAuthFiles()
    }

    func deleteDirectAuthFile(_ file: DirectAuthFile) async {
        do {
            try await directAuthService.deleteAuthFile(filePath: file.filePath)
            await loadDirectAuthFiles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func parseProxyURL(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rawProxyURL = json["proxy_url"] as? String else {
            return nil
        }

        let trimmedProxyURL = rawProxyURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedProxyURL.isEmpty ? nil : trimmedProxyURL
    }

    private static func parseUserAgent(from data: Data, provider: AIProvider?) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        return parseStoredUserAgent(from: json, provider: provider)
    }

    private nonisolated static func readStringField(named key: String, fromFileAt path: String) -> String? {
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rawValue = json[key] as? String else {
            return nil
        }

        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    private enum UserAgentStorage {
        case authField
        case header
        case localOnly
    }

    private nonisolated static func userAgentStorage(for provider: AIProvider?) -> UserAgentStorage {
        switch provider {
        case .antigravity:
            return .authField
        case .codex, .claude:
            return .header
        default:
            return .localOnly
        }
    }

    private nonisolated static func parseStoredUserAgent(from json: [String: Any], provider: AIProvider?) -> String? {
        switch userAgentStorage(for: provider) {
        case .authField:
            return trimmedNonEmpty(json["user_agent"] as? String)
        case .header:
            if let headers = json["headers"] as? [String: Any] {
                for (key, value) in headers where key.caseInsensitiveCompare("User-Agent") == .orderedSame {
                    if let stringValue = value as? String,
                       let trimmed = trimmedNonEmpty(stringValue) {
                        return trimmed
                    }
                }
            }
            return trimmedNonEmpty(json["user_agent"] as? String)
        case .localOnly:
            return nil
        }
    }

    private nonisolated static func parseHeaders(from data: Data) -> [String: String] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }

        return parseStoredHeaders(from: json)
    }

    private nonisolated static func parseStoredHeaders(from json: [String: Any]) -> [String: String] {
        guard let headers = json["headers"] as? [String: Any] else {
            return [:]
        }

        return Dictionary(uniqueKeysWithValues: headers.compactMap { key, value in
            guard let stringValue = value as? String,
                  let trimmedKey = trimmedNonEmpty(key),
                  let trimmedValue = trimmedNonEmpty(stringValue) else {
                return nil
            }
            return (trimmedKey, trimmedValue)
        })
    }

    private nonisolated static func readStoredUserAgent(for provider: AIProvider, fromFileAt path: String) -> String? {
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        return parseStoredUserAgent(from: json, provider: provider)
    }

    private nonisolated static func readStoredHeaders(fromFileAt path: String) -> [String: String] {
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }

        return parseStoredHeaders(from: json)
    }

    private nonisolated static func sanitizedHeaders(_ headers: [String: String]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: headers.compactMap { key, value in
            guard let trimmedKey = trimmedNonEmpty(key),
                  let trimmedValue = trimmedNonEmpty(value) else {
                return nil
            }
            return (trimmedKey, trimmedValue)
        })
    }

    private nonisolated static func normalizedHeaderNames(_ headerNames: [String]) -> Set<String> {
        Set(headerNames.compactMap { trimmedNonEmpty($0)?.lowercased() })
    }

    private nonisolated static func normalizedHeaders(_ headers: [String: String]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: sanitizedHeaders(headers).map { key, value in
            (key.lowercased(), value)
        })
    }

    private nonisolated static func mergeManagedHeaders(
        existing: [String: String],
        desired: [String: String],
        managedHeaderNames: Set<String>
    ) -> [String: String] {
        var merged = existing

        for key in merged.keys where managedHeaderNames.contains(key.lowercased()) {
            merged.removeValue(forKey: key)
        }

        for (key, value) in desired {
            merged[key] = value
        }

        return sanitizedHeaders(merged)
    }

    private nonisolated static func selectManagedHeaders(
        from headers: [String: String],
        managedHeaderNames: Set<String>
    ) -> [String: String] {
        Dictionary(uniqueKeysWithValues: headers.compactMap { key, value in
            guard managedHeaderNames.contains(key.lowercased()) else {
                return nil
            }
            return (key, value)
        })
    }

    private nonisolated static func trimmedNonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    private func directAuthFileForProxyFallback(named name: String) async -> DirectAuthFile? {
        if let cachedMatch = directAuthFiles.first(where: { $0.filename == name }) {
            return cachedMatch
        }

        let scannedFiles = await directAuthService.scanAllAuthFiles()
        return scannedFiles.first(where: { $0.filename == name })
    }

    /// Remove menu bar items that no longer have valid quota data
    private func pruneMenuBarItems() {
        var validItems: [MenuBarQuotaItem] = []
        var seen = Set<String>()
        
        // Collect valid items from current quota data
        for (provider, accountQuotas) in providerQuotas {
            for (accountKey, _) in accountQuotas {
                let item = MenuBarQuotaItem(provider: provider.rawValue, accountKey: accountKey)
                if !seen.contains(item.id) {
                    seen.insert(item.id)
                    validItems.append(item)
                }
            }
        }
        
        // Add items from auth files
        for file in authFiles {
            guard let provider = file.providerType else { continue }
            let item = MenuBarQuotaItem(provider: provider.rawValue, accountKey: file.menuBarAccountKey)
            if !seen.contains(item.id) {
                seen.insert(item.id)
                validItems.append(item)
            }
        }
        
        // Add items from direct auth files (quota-only mode)
        for file in directAuthFiles {
            let item = MenuBarQuotaItem(provider: file.provider.rawValue, accountKey: file.menuBarAccountKey)
            if !seen.contains(item.id) {
                seen.insert(item.id)
                validItems.append(item)
            }
        }
        
        menuBarSettings.pruneInvalidItems(validItems: validItems)
    }

    func importVertexServiceAccount(url: URL) async {
        guard let client = apiClient else {
            errorMessage = "Proxy not running"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw NSError(domain: "Quotio", code: 403, userInfo: [NSLocalizedDescriptionKey: "Permission denied"])
            }
            let data = try Data(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
            
            try await client.uploadVertexServiceAccount(data: data)
            await refreshData()
            errorMessage = nil
        } catch {
            errorMessage = "Import failed: \(error.localizedDescription)"
        }
    }
    
    func fetchAPIKeys() async {
        guard let client = apiClient else { return }
        
        do {
            apiKeys = try await client.fetchAPIKeys()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addAPIKey(_ key: String) async {
        guard let client = apiClient else { return }
        guard !key.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        do {
            try await client.addAPIKey(key)
            await fetchAPIKeys()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateAPIKey(old: String, new: String) async {
        guard let client = apiClient else { return }
        guard !new.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        do {
            try await client.updateAPIKey(old: old, new: new)
            await fetchAPIKeys()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAPIKey(_ key: String) async {
        guard let client = apiClient else { return }
        
        do {
            try await client.deleteAPIKey(value: key)
            await fetchAPIKeys()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Notification Helpers
    
    private func checkAccountStatusChanges() {
        for file in authFiles {
            let accountKey = "\(file.provider)_\(file.email ?? file.name)"
            let previousStatus = lastKnownAccountStatuses[accountKey]
            
            if file.status == "cooling" && previousStatus != "cooling" {
                notificationManager.notifyAccountCooling(
                    provider: file.providerType?.displayName ?? file.provider,
                    account: file.email ?? file.name
                )
            } else if file.status == "ready" && previousStatus == "cooling" {
                notificationManager.clearCoolingNotification(
                    provider: file.provider,
                    account: file.email ?? file.name
                )
            }
            
            lastKnownAccountStatuses[accountKey] = file.status
        }
    }
    
    func checkQuotaNotifications() {
        for (provider, accountQuotas) in providerQuotas {
            for (account, quotaData) in accountQuotas {
                guard !quotaData.models.isEmpty else { continue }
                
                // Filter out models with unknown percentage (-1 means unavailable/unknown)
                let validPercentages = quotaData.models.map(\.percentage).filter { $0 >= 0 }
                guard !validPercentages.isEmpty else { continue }
                
                let minRemainingPercent = validPercentages.min() ?? 100.0
                
                if minRemainingPercent <= notificationManager.quotaAlertThreshold {
                    notificationManager.notifyQuotaLow(
                        provider: provider.displayName,
                        account: account,
                        remainingPercent: minRemainingPercent
                    )
                } else {
                    notificationManager.clearQuotaNotification(
                        provider: provider.rawValue,
                        account: account
                    )
                }
            }
        }
    }
    
    // MARK: - IDE Scan with Consent
    
    /// Scan IDEs with explicit user consent - addresses issue #29
    /// Only scans what the user has opted into
    func scanIDEsWithConsent(options: IDEScanOptions) async {
        ideScanSettings.setScanningState(true)
        
        var cursorFound = false
        var cursorEmail: String?
        var traeFound = false
        var traeEmail: String?
        var cliToolsFound: [String] = []
        
        // Scan Cursor if opted in
        if options.scanCursor {
            let quotas = await cursorFetcher.fetchAsProviderQuota()
            if !quotas.isEmpty {
                cursorFound = true
                cursorEmail = quotas.keys.first
                providerQuotas[.cursor] = quotas
            } else {
                // Clear stale data when not found (consistent with refreshCursorQuotasInternal)
                providerQuotas.removeValue(forKey: .cursor)
            }
        }
        
        // Scan Trae if opted in
        if options.scanTrae {
            let quotas = await traeFetcher.fetchAsProviderQuota()
            if !quotas.isEmpty {
                traeFound = true
                traeEmail = quotas.keys.first
                providerQuotas[.trae] = quotas
            } else {
                // Clear stale data when not found (consistent with refreshTraeQuotasInternal)
                providerQuotas.removeValue(forKey: .trae)
            }
        }
        
        // Scan CLI tools if opted in
        if options.scanCLITools {
            let cliNames = ["claude", "codex", "gemini", "gh"]
            for name in cliNames {
                if await CLIExecutor.shared.isCLIInstalled(name: name) {
                    cliToolsFound.append(name)
                }
            }
        }
        
        let result = IDEScanResult(
            cursorFound: cursorFound,
            cursorEmail: cursorEmail,
            traeFound: traeFound,
            traeEmail: traeEmail,
            cliToolsFound: cliToolsFound,
            timestamp: Date()
        )
        
        ideScanSettings.updateScanResult(result)
        ideScanSettings.setScanningState(false)
        
        // Persist IDE quota data for Cursor and Trae
        savePersistedIDEQuotas()

        // Update menu bar items
        pruneMenuBarItems()
        autoSelectMenuBarItems()

        notifyQuotaDataChanged()
    }

    // MARK: - IDE Quota Persistence
    
    /// Save Cursor and Trae quota data to UserDefaults for persistence across app restarts
    private func savePersistedIDEQuotas() {
        var dataToSave: [String: [String: ProviderQuotaData]] = [:]
        
        for provider in Self.ideProvidersToSave {
            if let quotas = providerQuotas[provider], !quotas.isEmpty {
                dataToSave[provider.rawValue] = quotas
            }
        }
        
        if dataToSave.isEmpty {
            UserDefaults.standard.removeObject(forKey: Self.ideQuotasKey)
            return
        }
        
        do {
            let encoded = try JSONEncoder().encode(dataToSave)
            UserDefaults.standard.set(encoded, forKey: Self.ideQuotasKey)
        } catch {
            Log.error("Failed to save IDE quotas: \(error)")
        }
    }
    
    /// Load persisted Cursor and Trae quota data from UserDefaults
    private func loadPersistedIDEQuotas() {
        guard let data = UserDefaults.standard.data(forKey: Self.ideQuotasKey) else { return }
        
        do {
            let decoded = try JSONDecoder().decode([String: [String: ProviderQuotaData]].self, from: data)
            
            for (providerRaw, quotas) in decoded {
                if let provider = AIProvider(rawValue: providerRaw),
                   Self.ideProvidersToSave.contains(provider) {
                    providerQuotas[provider] = quotas
                }
            }
        } catch {
            Log.error("Failed to load IDE quotas: \(error)")
            // Clear corrupted data
            UserDefaults.standard.removeObject(forKey: Self.ideQuotasKey)
        }
    }
    
    // MARK: - Menu Bar Quota Items
    
    var menuBarSettings: MenuBarSettingsManager {
        MenuBarSettingsManager.shared
    }
    
    var menuBarQuotaItems: [MenuBarQuotaDisplayItem] {
        let settings = menuBarSettings
        guard settings.showQuotaInMenuBar else { return [] }
        
        var items: [MenuBarQuotaDisplayItem] = []
        
        for selectedItem in settings.selectedItems {
            guard let provider = selectedItem.aiProvider else { continue }
            
            let shortAccount = shortenAccountKey(selectedItem.accountKey)
            
            if let accountQuotas = providerQuotas[provider],
               let quotaData = accountQuotas[selectedItem.accountKey],
               !quotaData.models.isEmpty {
                // Filter out -1 (unknown) percentages when calculating lowest
                let validPercentages = quotaData.models.map(\.percentage).filter { $0 >= 0 }
                let lowestPercent = validPercentages.min() ?? (quotaData.models.first?.percentage ?? -1)
                items.append(MenuBarQuotaDisplayItem(
                    id: selectedItem.id,
                    providerSymbol: provider.menuBarSymbol,
                    accountShort: shortAccount,
                    percentage: lowestPercent,
                    provider: provider
                ))
            } else {
                items.append(MenuBarQuotaDisplayItem(
                    id: selectedItem.id,
                    providerSymbol: provider.menuBarSymbol,
                    accountShort: shortAccount,
                    percentage: -1,
                    provider: provider
                ))
            }
        }
        
        return items
    }
    
    private func shortenAccountKey(_ key: String) -> String {
        if let atIndex = key.firstIndex(of: "@") {
            let user = String(key[..<atIndex].prefix(4))
            let domainStart = key.index(after: atIndex)
            let domain = String(key[domainStart...].prefix(1))
            return "\(user)@\(domain)"
        }
        return String(key.prefix(6))
    }
}

struct OAuthState {
    let provider: AIProvider
    var status: OAuthStatus
    var state: String?
    var error: String?
    var authURL: String?
    
    enum OAuthStatus {
        case waiting, polling, success, error
    }
}
