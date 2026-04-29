# Quotio/ViewModels/QuotaViewModel.swift

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 3486
- **Language:** Swift
- **Symbols:** 157
- **Public symbols:** 0

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 11 | class | QuotaViewModel | (internal) | `class QuotaViewModel` |
| 165 | fn | loadDisabledAuthFiles | (private) | `private func loadDisabledAuthFiles() -> Set<Str...` |
| 171 | fn | saveDisabledAuthFiles | (private) | `private func saveDisabledAuthFiles(_ names: Set...` |
| 176 | fn | syncDisabledStatesToBackend | (private) | `private func syncDisabledStatesToBackend() async` |
| 195 | fn | notifyQuotaDataChanged | (private) | `private func notifyQuotaDataChanged()` |
| 198 | method | init | (internal) | `init()` |
| 237 | fn | setupProxyURLObserver | (private) | `private func setupProxyURLObserver()` |
| 253 | fn | setupAccountRemarksObserver | (private) | `private func setupAccountRemarksObserver()` |
| 281 | fn | normalizedProxyURL | (private) | `private func normalizedProxyURL(_ rawValue: Str...` |
| 301 | fn | updateProxyConfiguration | (internal) | `func updateProxyConfiguration() async` |
| 314 | fn | setupRefreshCadenceCallback | (private) | `private func setupRefreshCadenceCallback()` |
| 322 | fn | setupAppActivationObserver | (private) | `private func setupAppActivationObserver()` |
| 334 | fn | refreshOnAppResumeIfNeeded | (private) | `private func refreshOnAppResumeIfNeeded() async` |
| 353 | fn | setupWarmupCallback | (private) | `private func setupWarmupCallback()` |
| 371 | fn | restartAutoRefresh | (private) | `private func restartAutoRefresh()` |
| 385 | fn | initialize | (internal) | `func initialize() async` |
| 395 | fn | initializeFullMode | (private) | `private func initializeFullMode() async` |
| 416 | fn | checkForProxyUpgrade | (private) | `private func checkForProxyUpgrade() async` |
| 421 | fn | initializeQuotaOnlyMode | (private) | `private func initializeQuotaOnlyMode() async` |
| 431 | fn | initializeRemoteMode | (private) | `private func initializeRemoteMode() async` |
| 468 | fn | startRemoteRelay | (private) | `private func startRemoteRelay(config: RemoteCon...` |
| 480 | fn | setupRemoteAPIClient | (private) | `private func setupRemoteAPIClient(config: Remot...` |
| 488 | fn | reconnectRemote | (internal) | `func reconnectRemote() async` |
| 497 | fn | loadDirectAuthFiles | (internal) | `func loadDirectAuthFiles() async` |
| 500 | fn | createIdentityPackage | (internal) | `func createIdentityPackage(name: String? = nil)` |
| 505 | fn | createIdentityPackages | (internal) | `func createIdentityPackages(count: Int, namePre...` |
| 510 | fn | identityPackage | (internal) | `func identityPackage(for authFile: AuthFile) ->...` |
| 514 | fn | identityBinding | (internal) | `func identityBinding(for authFile: AuthFile) ->...` |
| 518 | fn | availableIdentityPackages | (internal) | `func availableIdentityPackages(for authFile: Au...` |
| 522 | fn | bindIdentityPackage | (internal) | `func bindIdentityPackage(packageId: UUID, to au...` |
| 527 | fn | unbindIdentityPackage | (internal) | `func unbindIdentityPackage(from authFile: AuthF...` |
| 532 | fn | updateIdentityPackage | (internal) | `func updateIdentityPackage(_ package: RuntimeId...` |
| 537 | fn | updateIdentityPackage | (internal) | `func updateIdentityPackage(_ package: RuntimeId...` |
| 542 | fn | markIdentityPackageVerificationFailure | (internal) | `func markIdentityPackageVerificationFailure(id:...` |
| 547 | fn | markIdentityPackageBlocked | (internal) | `func markIdentityPackageBlocked(id: UUID, reaso...` |
| 552 | fn | clearIdentityPackageOperationalStatus | (internal) | `func clearIdentityPackageOperationalStatus(id: ...` |
| 557 | fn | identityPackageProxyPassword | (internal) | `func identityPackageProxyPassword(for packageId...` |
| 561 | fn | importIdentityPackages | (internal) | `func importIdentityPackages(from rawText: Strin...` |
| 567 | fn | deleteIdentityPackage | (internal) | `@discardableResult   func deleteIdentityPackage...` |
| 576 | fn | migrateLegacyIdentityPackages | (internal) | `func migrateLegacyIdentityPackages(force: Bool ...` |
| 583 | fn | refreshQuotasDirectly | (internal) | `func refreshQuotasDirectly() async` |
| 611 | fn | autoSelectMenuBarItems | (private) | `private func autoSelectMenuBarItems()` |
| 645 | fn | syncMenuBarSelection | (internal) | `func syncMenuBarSelection()` |
| 652 | fn | refreshClaudeCodeQuotasInternal | (private) | `private func refreshClaudeCodeQuotasInternal() ...` |
| 673 | fn | refreshCursorQuotasInternal | (private) | `private func refreshCursorQuotasInternal() async` |
| 684 | fn | refreshCodexCLIQuotasInternal | (private) | `private func refreshCodexCLIQuotasInternal() async` |
| 700 | fn | refreshGeminiCLIQuotasInternal | (private) | `private func refreshGeminiCLIQuotasInternal() a...` |
| 718 | fn | refreshGlmQuotasInternal | (private) | `private func refreshGlmQuotasInternal() async` |
| 728 | fn | refreshWarpQuotasInternal | (private) | `private func refreshWarpQuotasInternal() async` |
| 752 | fn | refreshTraeQuotasInternal | (private) | `private func refreshTraeQuotasInternal() async` |
| 762 | fn | refreshKiroQuotasInternal | (private) | `private func refreshKiroQuotasInternal() async` |
| 768 | fn | cleanName | (internal) | `func cleanName(_ name: String) -> String` |
| 818 | fn | startQuotaOnlyAutoRefresh | (private) | `private func startQuotaOnlyAutoRefresh()` |
| 837 | fn | startQuotaAutoRefreshWithoutProxy | (private) | `private func startQuotaAutoRefreshWithoutProxy()` |
| 857 | fn | isWarmupEnabled | (internal) | `func isWarmupEnabled(for provider: AIProvider, ...` |
| 861 | fn | warmupStatus | (internal) | `func warmupStatus(provider: AIProvider, account...` |
| 866 | fn | warmupNextRunDate | (internal) | `func warmupNextRunDate(provider: AIProvider, ac...` |
| 871 | fn | toggleWarmup | (internal) | `func toggleWarmup(for provider: AIProvider, acc...` |
| 880 | fn | setWarmupEnabled | (internal) | `func setWarmupEnabled(_ enabled: Bool, provider...` |
| 892 | fn | nextDailyRunDate | (private) | `private func nextDailyRunDate(minutes: Int, now...` |
| 903 | fn | restartWarmupScheduler | (private) | `private func restartWarmupScheduler()` |
| 936 | fn | runWarmupCycle | (private) | `private func runWarmupCycle() async` |
| 999 | fn | warmupAccount | (private) | `private func warmupAccount(provider: AIProvider...` |
| 1045 | fn | warmupAccount | (private) | `private func warmupAccount(     provider: AIPro...` |
| 1108 | fn | fetchWarmupModels | (private) | `private func fetchWarmupModels(     provider: A...` |
| 1132 | fn | warmupAvailableModels | (internal) | `func warmupAvailableModels(provider: AIProvider...` |
| 1145 | fn | warmupAuthInfo | (private) | `private func warmupAuthInfo(provider: AIProvide...` |
| 1167 | fn | warmupTargets | (private) | `private func warmupTargets() -> [WarmupAccountKey]` |
| 1181 | fn | updateWarmupStatus | (private) | `private func updateWarmupStatus(for key: Warmup...` |
| 1210 | fn | startProxy | (internal) | `func startProxy() async` |
| 1260 | fn | stopProxy | (internal) | `func stopProxy()` |
| 1289 | fn | toggleProxy | (internal) | `func toggleProxy() async` |
| 1306 | fn | stopRemoteRelayEntrypoint | (private) | `private func stopRemoteRelayEntrypoint()` |
| 1314 | fn | setupAPIClient | (private) | `private func setupAPIClient()` |
| 1321 | fn | startAutoRefresh | (private) | `private func startAutoRefresh()` |
| 1359 | fn | attemptProxyRecovery | (private) | `private func attemptProxyRecovery() async` |
| 1419 | fn | refreshData | (internal) | `func refreshData() async` |
| 1478 | fn | loadProvidersScreenData | (internal) | `func loadProvidersScreenData() async` |
| 1488 | fn | manualRefresh | (internal) | `func manualRefresh() async` |
| 1505 | fn | refreshAllQuotas | (internal) | `func refreshAllQuotas() async` |
| 1541 | fn | refreshQuotasUnified | (internal) | `func refreshQuotasUnified() async` |
| 1575 | fn | refreshAntigravityQuotasInternal | (private) | `private func refreshAntigravityQuotasInternal()...` |
| 1595 | fn | refreshAntigravityQuotasWithoutDetect | (private) | `private func refreshAntigravityQuotasWithoutDet...` |
| 1612 | fn | isAntigravityAccountActive | (internal) | `func isAntigravityAccountActive(email: String) ...` |
| 1617 | fn | switchAntigravityAccount | (internal) | `func switchAntigravityAccount(email: String) async` |
| 1627 | fn | beginAntigravitySwitch | (internal) | `func beginAntigravitySwitch(accountId: String, ...` |
| 1632 | fn | cancelAntigravitySwitch | (internal) | `func cancelAntigravitySwitch()` |
| 1637 | fn | dismissAntigravitySwitchResult | (internal) | `func dismissAntigravitySwitchResult()` |
| 1640 | fn | refreshOpenAIQuotasInternal | (private) | `private func refreshOpenAIQuotasInternal() async` |
| 1645 | fn | refreshCopilotQuotasInternal | (private) | `private func refreshCopilotQuotasInternal() async` |
| 1650 | fn | refreshQuotaForProvider | (internal) | `func refreshQuotaForProvider(_ provider: AIProv...` |
| 1685 | fn | refreshAutoDetectedProviders | (internal) | `func refreshAutoDetectedProviders() async` |
| 1692 | fn | preparePendingAccountSetup | (private) | `private func preparePendingAccountSetup(for pro...` |
| 1723 | fn | clearPendingAccountSetup | (private) | `private func clearPendingAccountSetup(for provi...` |
| 1730 | fn | applyPendingAccountSetupIfNeeded | (private) | `private func applyPendingAccountSetupIfNeeded(f...` |
| 1765 | fn | resolvePendingAccountTarget | (private) | `private func resolvePendingAccountTarget(from p...` |
| 1782 | fn | authFileTimestamp | (private) | `private func authFileTimestamp(for file: AuthFi...` |
| 1804 | fn | startOAuth | (internal) | `func startOAuth(     for provider: AIProvider, ...` |
| 1863 | fn | startCopilotAuth | (private) | `private func startCopilotAuth() async` |
| 1881 | fn | startKiroAuth | (private) | `private func startKiroAuth(method: AuthCommand)...` |
| 1917 | fn | pollCopilotAuthCompletion | (private) | `private func pollCopilotAuthCompletion() async` |
| 1936 | fn | pollKiroAuthCompletion | (private) | `private func pollKiroAuthCompletion() async` |
| 1956 | fn | pollOAuthStatus | (private) | `private func pollOAuthStatus(state: String, pro...` |
| 2017 | fn | cancelOAuth | (internal) | `@discardableResult   func cancelOAuth() async -...` |
| 2061 | fn | applyOAuthCancellationFailure | (private) | `private func applyOAuthCancellationFailure(_ me...` |
| 2071 | fn | submitOAuthCallback | (internal) | `func submitOAuthCallback(for provider: AIProvid...` |
| 2091 | fn | fetchOAuthReauthHistory | (internal) | `func fetchOAuthReauthHistory(authName: String, ...` |
| 2098 | fn | deleteAuthFile | (internal) | `func deleteAuthFile(_ file: AuthFile) async` |
| 2134 | fn | toggleAuthFileDisabled | (internal) | `func toggleAuthFileDisabled(_ file: AuthFile) a...` |
| 2165 | fn | toggleDirectAuthFileDisabled | (internal) | `func toggleDirectAuthFileDisabled(_ file: Direc...` |
| 2174 | fn | refreshAuthFileStatus | (internal) | `func refreshAuthFileStatus(_ file: AuthFile, tr...` |
| 2185 | fn | silentlyRefreshProblemAuthFilesIfNeeded | (private) | `private func silentlyRefreshProblemAuthFilesIfN...` |
| 2216 | fn | authFileNeedsSilentStatusRefresh | (private) | `private func authFileNeedsSilentStatusRefresh(_...` |
| 2241 | fn | normalizedProblemStatusMessage | (private) | `private func normalizedProblemStatusMessage(for...` |
| 2245 | fn | mergeAuthFile | (private) | `private func mergeAuthFile(_ refreshedFile: Aut...` |
| 2253 | fn | reloadAuthFilesSnapshot | (private) | `private func reloadAuthFilesSnapshot() async` |
| 2273 | fn | pruneSilentAuthStatusRefreshCache | (private) | `private func pruneSilentAuthStatusRefreshCache(...` |
| 2278 | fn | loadAuthFileProxyURL | (internal) | `func loadAuthFileProxyURL(_ file: AuthFile) asy...` |
| 2292 | fn | loadAuthFileAccountSettings | (internal) | `func loadAuthFileAccountSettings(_ file: AuthFi...` |
| 2309 | fn | updateAuthFileNote | (internal) | `func updateAuthFileNote(     _ note: String?,  ...` |
| 2356 | fn | updateAuthFileProxyURL | (internal) | `func updateAuthFileProxyURL(_ proxyURL: String?...` |
| 2381 | fn | loadAuthFileUserAgent | (internal) | `func loadAuthFileUserAgent(_ file: AuthFile) as...` |
| 2398 | fn | loadAuthFileRecoveredFingerprintProfile | (internal) | `func loadAuthFileRecoveredFingerprintProfile(  ...` |
| 2420 | fn | loadDirectAuthFileRecoveredFingerprintProfile | (internal) | `func loadDirectAuthFileRecoveredFingerprintProf...` |
| 2431 | fn | updateAuthFileUserAgent | (internal) | `func updateAuthFileUserAgent(_ userAgent: Strin...` |
| 2499 | fn | updateAuthFileManagedHeaders | (internal) | `func updateAuthFileManagedHeaders(     _ header...` |
| 2568 | fn | updateDirectAuthFileUserAgent | (internal) | `func updateDirectAuthFileUserAgent(_ userAgent:...` |
| 2584 | fn | updateDirectAuthFileManagedHeaders | (internal) | `func updateDirectAuthFileManagedHeaders(     _ ...` |
| 2606 | fn | updateDirectAuthFileProxyURL | (internal) | `func updateDirectAuthFileProxyURL(_ proxyURL: S...` |
| 2611 | fn | updateDirectAuthFileNote | (internal) | `func updateDirectAuthFileNote(_ note: String?, ...` |
| 2616 | fn | deleteDirectAuthFile | (internal) | `func deleteDirectAuthFile(_ file: DirectAuthFil...` |
| 2625 | fn | parseProxyURL | (private) | `private static func parseProxyURL(from data: Da...` |
| 2635 | fn | parseNote | (private) | `private static func parseNote(from data: Data) ...` |
| 2953 | fn | desiredRemarkNote | (private) | `private func desiredRemarkNote(for authFile: Au...` |
| 2959 | fn | syncLocalRemarksToAuthFileNotesIfNeeded | (private) | `@discardableResult   private func syncLocalRema...` |
| 3004 | fn | directAuthFileForProxyFallback | (private) | `private func directAuthFileForProxyFallback(nam...` |
| 3015 | fn | pruneMenuBarItems | (private) | `private func pruneMenuBarItems()` |
| 3051 | fn | syncIdentityPackageState | (private) | `private func syncIdentityPackageState(reconcili...` |
| 3060 | fn | autoMigrateLegacyIdentityPackagesIfNeeded | (private) | `private func autoMigrateLegacyIdentityPackagesI...` |
| 3066 | fn | migrateLegacyIdentityPackages | (private) | `private func migrateLegacyIdentityPackages(    ...` |
| 3083 | fn | buildLegacyIdentityPackageSeeds | (private) | `private func buildLegacyIdentityPackageSeeds(fr...` |
| 3134 | fn | accountMetadataKey | (private) | `private func accountMetadataKey(for authFile: A...` |
| 3141 | fn | legacyMetadataFallbackUserDefaults | (private) | `private func legacyMetadataFallbackUserDefaults...` |
| 3146 | fn | importVertexServiceAccount | (internal) | `func importVertexServiceAccount(url: URL) async` |
| 3170 | fn | fetchAPIKeys | (internal) | `func fetchAPIKeys() async` |
| 3180 | fn | addAPIKey | (internal) | `func addAPIKey(_ key: String) async` |
| 3192 | fn | updateAPIKey | (internal) | `func updateAPIKey(old: String, new: String) async` |
| 3204 | fn | deleteAPIKey | (internal) | `func deleteAPIKey(_ key: String) async` |
| 3217 | fn | checkAccountStatusChanges | (private) | `private func checkAccountStatusChanges()` |
| 3238 | fn | checkQuotaNotifications | (internal) | `func checkQuotaNotifications()` |
| 3270 | fn | scanIDEsWithConsent | (internal) | `func scanIDEsWithConsent(options: IDEScanOption...` |
| 3340 | fn | savePersistedIDEQuotas | (private) | `private func savePersistedIDEQuotas()` |
| 3363 | fn | loadPersistedIDEQuotas | (private) | `private func loadPersistedIDEQuotas()` |
| 3425 | fn | shortenAccountKey | (private) | `private func shortenAccountKey(_ key: String) -...` |
| 3437 | struct | OAuthState | (internal) | `struct OAuthState` |
| 3444 | method | init | (internal) | `init(     provider: AIProvider,     status: OAu...` |
| 3466 | enum | OAuthCancellationResult | (internal) | `enum OAuthCancellationResult` |

## Memory Markers

### 🟢 `NOTE` (line 408)

> checkForProxyUpgrade() is now called inside startProxy()

### 🟢 `NOTE` (line 582)

> Cursor and Trae are NOT auto-refreshed - user must use "Scan for IDEs" (issue #29)

### 🟢 `NOTE` (line 590)

> Cursor and Trae removed from auto-refresh to address privacy concerns (issue #29)

### 🟢 `NOTE` (line 1515)

> Cursor and Trae removed from auto-refresh (issue #29)

### 🟢 `NOTE` (line 1540)

> Cursor and Trae require explicit user scan (issue #29)

### 🟢 `NOTE` (line 1550)

> Cursor and Trae removed - require explicit scan (issue #29)

### 🟢 `NOTE` (line 1605)

> Don't call detectActiveAccount() here - already set by switch operation

