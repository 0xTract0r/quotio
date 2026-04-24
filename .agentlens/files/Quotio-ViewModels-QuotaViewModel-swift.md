# Quotio/ViewModels/QuotaViewModel.swift

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 3405
- **Language:** Swift
- **Symbols:** 154
- **Public symbols:** 0

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 11 | class | QuotaViewModel | (internal) | `class QuotaViewModel` |
| 162 | fn | loadDisabledAuthFiles | (private) | `private func loadDisabledAuthFiles() -> Set<Str...` |
| 168 | fn | saveDisabledAuthFiles | (private) | `private func saveDisabledAuthFiles(_ names: Set...` |
| 173 | fn | syncDisabledStatesToBackend | (private) | `private func syncDisabledStatesToBackend() async` |
| 192 | fn | notifyQuotaDataChanged | (private) | `private func notifyQuotaDataChanged()` |
| 195 | method | init | (internal) | `init()` |
| 234 | fn | setupProxyURLObserver | (private) | `private func setupProxyURLObserver()` |
| 250 | fn | setupAccountRemarksObserver | (private) | `private func setupAccountRemarksObserver()` |
| 278 | fn | normalizedProxyURL | (private) | `private func normalizedProxyURL(_ rawValue: Str...` |
| 298 | fn | updateProxyConfiguration | (internal) | `func updateProxyConfiguration() async` |
| 311 | fn | setupRefreshCadenceCallback | (private) | `private func setupRefreshCadenceCallback()` |
| 319 | fn | setupAppActivationObserver | (private) | `private func setupAppActivationObserver()` |
| 331 | fn | refreshOnAppResumeIfNeeded | (private) | `private func refreshOnAppResumeIfNeeded() async` |
| 350 | fn | setupWarmupCallback | (private) | `private func setupWarmupCallback()` |
| 368 | fn | restartAutoRefresh | (private) | `private func restartAutoRefresh()` |
| 382 | fn | initialize | (internal) | `func initialize() async` |
| 392 | fn | initializeFullMode | (private) | `private func initializeFullMode() async` |
| 413 | fn | checkForProxyUpgrade | (private) | `private func checkForProxyUpgrade() async` |
| 418 | fn | initializeQuotaOnlyMode | (private) | `private func initializeQuotaOnlyMode() async` |
| 428 | fn | initializeRemoteMode | (private) | `private func initializeRemoteMode() async` |
| 456 | fn | setupRemoteAPIClient | (private) | `private func setupRemoteAPIClient(config: Remot...` |
| 464 | fn | reconnectRemote | (internal) | `func reconnectRemote() async` |
| 473 | fn | loadDirectAuthFiles | (internal) | `func loadDirectAuthFiles() async` |
| 476 | fn | createIdentityPackage | (internal) | `func createIdentityPackage(name: String? = nil)` |
| 481 | fn | createIdentityPackages | (internal) | `func createIdentityPackages(count: Int, namePre...` |
| 486 | fn | identityPackage | (internal) | `func identityPackage(for authFile: AuthFile) ->...` |
| 490 | fn | identityBinding | (internal) | `func identityBinding(for authFile: AuthFile) ->...` |
| 494 | fn | availableIdentityPackages | (internal) | `func availableIdentityPackages(for authFile: Au...` |
| 498 | fn | bindIdentityPackage | (internal) | `func bindIdentityPackage(packageId: UUID, to au...` |
| 503 | fn | unbindIdentityPackage | (internal) | `func unbindIdentityPackage(from authFile: AuthF...` |
| 508 | fn | updateIdentityPackage | (internal) | `func updateIdentityPackage(_ package: RuntimeId...` |
| 513 | fn | updateIdentityPackage | (internal) | `func updateIdentityPackage(_ package: RuntimeId...` |
| 518 | fn | markIdentityPackageVerificationFailure | (internal) | `func markIdentityPackageVerificationFailure(id:...` |
| 523 | fn | markIdentityPackageBlocked | (internal) | `func markIdentityPackageBlocked(id: UUID, reaso...` |
| 528 | fn | clearIdentityPackageOperationalStatus | (internal) | `func clearIdentityPackageOperationalStatus(id: ...` |
| 533 | fn | identityPackageProxyPassword | (internal) | `func identityPackageProxyPassword(for packageId...` |
| 537 | fn | importIdentityPackages | (internal) | `func importIdentityPackages(from rawText: Strin...` |
| 543 | fn | deleteIdentityPackage | (internal) | `@discardableResult   func deleteIdentityPackage...` |
| 552 | fn | migrateLegacyIdentityPackages | (internal) | `func migrateLegacyIdentityPackages(force: Bool ...` |
| 559 | fn | refreshQuotasDirectly | (internal) | `func refreshQuotasDirectly() async` |
| 587 | fn | autoSelectMenuBarItems | (private) | `private func autoSelectMenuBarItems()` |
| 621 | fn | syncMenuBarSelection | (internal) | `func syncMenuBarSelection()` |
| 628 | fn | refreshClaudeCodeQuotasInternal | (private) | `private func refreshClaudeCodeQuotasInternal() ...` |
| 649 | fn | refreshCursorQuotasInternal | (private) | `private func refreshCursorQuotasInternal() async` |
| 660 | fn | refreshCodexCLIQuotasInternal | (private) | `private func refreshCodexCLIQuotasInternal() async` |
| 676 | fn | refreshGeminiCLIQuotasInternal | (private) | `private func refreshGeminiCLIQuotasInternal() a...` |
| 694 | fn | refreshGlmQuotasInternal | (private) | `private func refreshGlmQuotasInternal() async` |
| 704 | fn | refreshWarpQuotasInternal | (private) | `private func refreshWarpQuotasInternal() async` |
| 728 | fn | refreshTraeQuotasInternal | (private) | `private func refreshTraeQuotasInternal() async` |
| 738 | fn | refreshKiroQuotasInternal | (private) | `private func refreshKiroQuotasInternal() async` |
| 744 | fn | cleanName | (internal) | `func cleanName(_ name: String) -> String` |
| 794 | fn | startQuotaOnlyAutoRefresh | (private) | `private func startQuotaOnlyAutoRefresh()` |
| 813 | fn | startQuotaAutoRefreshWithoutProxy | (private) | `private func startQuotaAutoRefreshWithoutProxy()` |
| 833 | fn | isWarmupEnabled | (internal) | `func isWarmupEnabled(for provider: AIProvider, ...` |
| 837 | fn | warmupStatus | (internal) | `func warmupStatus(provider: AIProvider, account...` |
| 842 | fn | warmupNextRunDate | (internal) | `func warmupNextRunDate(provider: AIProvider, ac...` |
| 847 | fn | toggleWarmup | (internal) | `func toggleWarmup(for provider: AIProvider, acc...` |
| 856 | fn | setWarmupEnabled | (internal) | `func setWarmupEnabled(_ enabled: Bool, provider...` |
| 868 | fn | nextDailyRunDate | (private) | `private func nextDailyRunDate(minutes: Int, now...` |
| 879 | fn | restartWarmupScheduler | (private) | `private func restartWarmupScheduler()` |
| 912 | fn | runWarmupCycle | (private) | `private func runWarmupCycle() async` |
| 975 | fn | warmupAccount | (private) | `private func warmupAccount(provider: AIProvider...` |
| 1021 | fn | warmupAccount | (private) | `private func warmupAccount(     provider: AIPro...` |
| 1084 | fn | fetchWarmupModels | (private) | `private func fetchWarmupModels(     provider: A...` |
| 1108 | fn | warmupAvailableModels | (internal) | `func warmupAvailableModels(provider: AIProvider...` |
| 1121 | fn | warmupAuthInfo | (private) | `private func warmupAuthInfo(provider: AIProvide...` |
| 1143 | fn | warmupTargets | (private) | `private func warmupTargets() -> [WarmupAccountKey]` |
| 1157 | fn | updateWarmupStatus | (private) | `private func updateWarmupStatus(for key: Warmup...` |
| 1186 | fn | startProxy | (internal) | `func startProxy() async` |
| 1236 | fn | stopProxy | (internal) | `func stopProxy()` |
| 1265 | fn | toggleProxy | (internal) | `func toggleProxy() async` |
| 1273 | fn | setupAPIClient | (private) | `private func setupAPIClient()` |
| 1280 | fn | startAutoRefresh | (private) | `private func startAutoRefresh()` |
| 1318 | fn | attemptProxyRecovery | (private) | `private func attemptProxyRecovery() async` |
| 1366 | fn | refreshData | (internal) | `func refreshData() async` |
| 1425 | fn | loadProvidersScreenData | (internal) | `func loadProvidersScreenData() async` |
| 1435 | fn | manualRefresh | (internal) | `func manualRefresh() async` |
| 1452 | fn | refreshAllQuotas | (internal) | `func refreshAllQuotas() async` |
| 1488 | fn | refreshQuotasUnified | (internal) | `func refreshQuotasUnified() async` |
| 1522 | fn | refreshAntigravityQuotasInternal | (private) | `private func refreshAntigravityQuotasInternal()...` |
| 1542 | fn | refreshAntigravityQuotasWithoutDetect | (private) | `private func refreshAntigravityQuotasWithoutDet...` |
| 1559 | fn | isAntigravityAccountActive | (internal) | `func isAntigravityAccountActive(email: String) ...` |
| 1564 | fn | switchAntigravityAccount | (internal) | `func switchAntigravityAccount(email: String) async` |
| 1574 | fn | beginAntigravitySwitch | (internal) | `func beginAntigravitySwitch(accountId: String, ...` |
| 1579 | fn | cancelAntigravitySwitch | (internal) | `func cancelAntigravitySwitch()` |
| 1584 | fn | dismissAntigravitySwitchResult | (internal) | `func dismissAntigravitySwitchResult()` |
| 1587 | fn | refreshOpenAIQuotasInternal | (private) | `private func refreshOpenAIQuotasInternal() async` |
| 1592 | fn | refreshCopilotQuotasInternal | (private) | `private func refreshCopilotQuotasInternal() async` |
| 1597 | fn | refreshQuotaForProvider | (internal) | `func refreshQuotaForProvider(_ provider: AIProv...` |
| 1632 | fn | refreshAutoDetectedProviders | (internal) | `func refreshAutoDetectedProviders() async` |
| 1639 | fn | preparePendingAccountSetup | (private) | `private func preparePendingAccountSetup(for pro...` |
| 1665 | fn | clearPendingAccountSetup | (private) | `private func clearPendingAccountSetup(for provi...` |
| 1672 | fn | applyPendingAccountSetupIfNeeded | (private) | `private func applyPendingAccountSetupIfNeeded(f...` |
| 1702 | fn | resolvePendingAccountTarget | (private) | `private func resolvePendingAccountTarget(from p...` |
| 1719 | fn | authFileTimestamp | (private) | `private func authFileTimestamp(for file: AuthFi...` |
| 1741 | fn | startOAuth | (internal) | `func startOAuth(     for provider: AIProvider, ...` |
| 1800 | fn | startCopilotAuth | (private) | `private func startCopilotAuth() async` |
| 1818 | fn | startKiroAuth | (private) | `private func startKiroAuth(method: AuthCommand)...` |
| 1854 | fn | pollCopilotAuthCompletion | (private) | `private func pollCopilotAuthCompletion() async` |
| 1873 | fn | pollKiroAuthCompletion | (private) | `private func pollKiroAuthCompletion() async` |
| 1893 | fn | pollOAuthStatus | (private) | `private func pollOAuthStatus(state: String, pro...` |
| 1954 | fn | cancelOAuth | (internal) | `@discardableResult   func cancelOAuth() async -...` |
| 1998 | fn | applyOAuthCancellationFailure | (private) | `private func applyOAuthCancellationFailure(_ me...` |
| 2008 | fn | submitOAuthCallback | (internal) | `func submitOAuthCallback(for provider: AIProvid...` |
| 2028 | fn | fetchOAuthReauthHistory | (internal) | `func fetchOAuthReauthHistory(authName: String, ...` |
| 2035 | fn | deleteAuthFile | (internal) | `func deleteAuthFile(_ file: AuthFile) async` |
| 2071 | fn | toggleAuthFileDisabled | (internal) | `func toggleAuthFileDisabled(_ file: AuthFile) a...` |
| 2102 | fn | toggleDirectAuthFileDisabled | (internal) | `func toggleDirectAuthFileDisabled(_ file: Direc...` |
| 2111 | fn | refreshAuthFileStatus | (internal) | `func refreshAuthFileStatus(_ file: AuthFile, tr...` |
| 2122 | fn | silentlyRefreshProblemAuthFilesIfNeeded | (private) | `private func silentlyRefreshProblemAuthFilesIfN...` |
| 2153 | fn | authFileNeedsSilentStatusRefresh | (private) | `private func authFileNeedsSilentStatusRefresh(_...` |
| 2178 | fn | normalizedProblemStatusMessage | (private) | `private func normalizedProblemStatusMessage(for...` |
| 2182 | fn | mergeAuthFile | (private) | `private func mergeAuthFile(_ refreshedFile: Aut...` |
| 2190 | fn | reloadAuthFilesSnapshot | (private) | `private func reloadAuthFilesSnapshot() async` |
| 2210 | fn | pruneSilentAuthStatusRefreshCache | (private) | `private func pruneSilentAuthStatusRefreshCache(...` |
| 2215 | fn | loadAuthFileProxyURL | (internal) | `func loadAuthFileProxyURL(_ file: AuthFile) asy...` |
| 2229 | fn | updateAuthFileNote | (internal) | `func updateAuthFileNote(     _ note: String?,  ...` |
| 2276 | fn | updateAuthFileProxyURL | (internal) | `func updateAuthFileProxyURL(_ proxyURL: String?...` |
| 2301 | fn | loadAuthFileUserAgent | (internal) | `func loadAuthFileUserAgent(_ file: AuthFile) as...` |
| 2318 | fn | loadAuthFileRecoveredFingerprintProfile | (internal) | `func loadAuthFileRecoveredFingerprintProfile(  ...` |
| 2340 | fn | loadDirectAuthFileRecoveredFingerprintProfile | (internal) | `func loadDirectAuthFileRecoveredFingerprintProf...` |
| 2351 | fn | updateAuthFileUserAgent | (internal) | `func updateAuthFileUserAgent(_ userAgent: Strin...` |
| 2419 | fn | updateAuthFileManagedHeaders | (internal) | `func updateAuthFileManagedHeaders(     _ header...` |
| 2488 | fn | updateDirectAuthFileUserAgent | (internal) | `func updateDirectAuthFileUserAgent(_ userAgent:...` |
| 2504 | fn | updateDirectAuthFileManagedHeaders | (internal) | `func updateDirectAuthFileManagedHeaders(     _ ...` |
| 2526 | fn | updateDirectAuthFileProxyURL | (internal) | `func updateDirectAuthFileProxyURL(_ proxyURL: S...` |
| 2531 | fn | updateDirectAuthFileNote | (internal) | `func updateDirectAuthFileNote(_ note: String?, ...` |
| 2536 | fn | deleteDirectAuthFile | (internal) | `func deleteDirectAuthFile(_ file: DirectAuthFil...` |
| 2545 | fn | parseProxyURL | (private) | `private static func parseProxyURL(from data: Da...` |
| 2555 | fn | parseNote | (private) | `private static func parseNote(from data: Data) ...` |
| 2873 | fn | desiredRemarkNote | (private) | `private func desiredRemarkNote(for authFile: Au...` |
| 2879 | fn | syncLocalRemarksToAuthFileNotesIfNeeded | (private) | `@discardableResult   private func syncLocalRema...` |
| 2923 | fn | directAuthFileForProxyFallback | (private) | `private func directAuthFileForProxyFallback(nam...` |
| 2934 | fn | pruneMenuBarItems | (private) | `private func pruneMenuBarItems()` |
| 2970 | fn | syncIdentityPackageState | (private) | `private func syncIdentityPackageState(reconcili...` |
| 2979 | fn | autoMigrateLegacyIdentityPackagesIfNeeded | (private) | `private func autoMigrateLegacyIdentityPackagesI...` |
| 2985 | fn | migrateLegacyIdentityPackages | (private) | `private func migrateLegacyIdentityPackages(    ...` |
| 3002 | fn | buildLegacyIdentityPackageSeeds | (private) | `private func buildLegacyIdentityPackageSeeds(fr...` |
| 3053 | fn | accountMetadataKey | (private) | `private func accountMetadataKey(for authFile: A...` |
| 3060 | fn | legacyMetadataFallbackUserDefaults | (private) | `private func legacyMetadataFallbackUserDefaults...` |
| 3065 | fn | importVertexServiceAccount | (internal) | `func importVertexServiceAccount(url: URL) async` |
| 3089 | fn | fetchAPIKeys | (internal) | `func fetchAPIKeys() async` |
| 3099 | fn | addAPIKey | (internal) | `func addAPIKey(_ key: String) async` |
| 3111 | fn | updateAPIKey | (internal) | `func updateAPIKey(old: String, new: String) async` |
| 3123 | fn | deleteAPIKey | (internal) | `func deleteAPIKey(_ key: String) async` |
| 3136 | fn | checkAccountStatusChanges | (private) | `private func checkAccountStatusChanges()` |
| 3157 | fn | checkQuotaNotifications | (internal) | `func checkQuotaNotifications()` |
| 3189 | fn | scanIDEsWithConsent | (internal) | `func scanIDEsWithConsent(options: IDEScanOption...` |
| 3259 | fn | savePersistedIDEQuotas | (private) | `private func savePersistedIDEQuotas()` |
| 3282 | fn | loadPersistedIDEQuotas | (private) | `private func loadPersistedIDEQuotas()` |
| 3344 | fn | shortenAccountKey | (private) | `private func shortenAccountKey(_ key: String) -...` |
| 3356 | struct | OAuthState | (internal) | `struct OAuthState` |
| 3363 | method | init | (internal) | `init(     provider: AIProvider,     status: OAu...` |
| 3385 | enum | OAuthCancellationResult | (internal) | `enum OAuthCancellationResult` |

## Memory Markers

### 🟢 `NOTE` (line 405)

> checkForProxyUpgrade() is now called inside startProxy()

### 🟢 `NOTE` (line 558)

> Cursor and Trae are NOT auto-refreshed - user must use "Scan for IDEs" (issue #29)

### 🟢 `NOTE` (line 566)

> Cursor and Trae removed from auto-refresh to address privacy concerns (issue #29)

### 🟢 `NOTE` (line 1462)

> Cursor and Trae removed from auto-refresh (issue #29)

### 🟢 `NOTE` (line 1487)

> Cursor and Trae require explicit user scan (issue #29)

### 🟢 `NOTE` (line 1497)

> Cursor and Trae removed - require explicit scan (issue #29)

### 🟢 `NOTE` (line 1552)

> Don't call detectActiveAccount() here - already set by switch operation

