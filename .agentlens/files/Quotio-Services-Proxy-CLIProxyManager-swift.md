# Quotio/Services/Proxy/CLIProxyManager.swift

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2278
- **Language:** Swift
- **Symbols:** 75
- **Public symbols:** 0

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 9 | class | CLIProxyManager | (internal) | `class CLIProxyManager` |
| 52 | fn | configuredTestCAFilePath | (private) | `private func configuredTestCAFilePath() -> String?` |
| 82 | fn | makeProcessEnvironment | (private) | `private func makeProcessEnvironment() -> [Strin...` |
| 255 | method | init | (internal) | `init()` |
| 290 | fn | shouldDeferLocalRuntimePreparation | (private) | `private static func shouldDeferLocalRuntimePrep...` |
| 303 | fn | resolveInitialLocalManagementKey | (private) | `private static func resolveInitialLocalManageme...` |
| 325 | fn | prepareLocalRuntimeConfiguration | (private) | `private func prepareLocalRuntimeConfiguration()` |
| 332 | fn | ensurePersistentLocalManagementKeyIfNeeded | (private) | `private func ensurePersistentLocalManagementKey...` |
| 357 | fn | restartProxyIfRunning | (private) | `private func restartProxyIfRunning()` |
| 390 | fn | updateConfigValue | (private) | `private func updateConfigValue(pattern: String,...` |
| 410 | fn | updateConfigPort | (private) | `private func updateConfigPort(_ newPort: UInt16)` |
| 414 | fn | updateConfigHost | (private) | `private func updateConfigHost(_ host: String)` |
| 418 | fn | ensureApiKeyExistsInConfig | (private) | `private func ensureApiKeyExistsInConfig()` |
| 467 | fn | updateConfigAllowRemote | (internal) | `func updateConfigAllowRemote(_ enabled: Bool)` |
| 471 | fn | updateConfigLogging | (internal) | `func updateConfigLogging(enabled: Bool)` |
| 479 | fn | updateConfigRoutingStrategy | (internal) | `func updateConfigRoutingStrategy(_ strategy: St...` |
| 484 | fn | updateConfigProxyURL | (internal) | `func updateConfigProxyURL(_ url: String?)` |
| 512 | fn | applyBaseURLWorkaround | (internal) | `func applyBaseURLWorkaround()` |
| 541 | fn | removeBaseURLWorkaround | (internal) | `func removeBaseURLWorkaround()` |
| 583 | fn | ensureConfigExists | (private) | `private func ensureConfigExists()` |
| 620 | fn | ensureLogRetentionDefaultsInConfig | (private) | `private func ensureLogRetentionDefaultsInConfig()` |
| 660 | fn | rootKeyIndex | (private) | `private func rootKeyIndex(_ key: String, in lin...` |
| 667 | fn | syncSecretKeyInConfig | (private) | `private func syncSecretKeyInConfig()` |
| 680 | fn | ensureManagementPanelAutoUpdateDisabledInConfig | (private) | `private func ensureManagementPanelAutoUpdateDis...` |
| 735 | fn | regenerateManagementKey | (internal) | `func regenerateManagementKey() async throws` |
| 785 | fn | syncProxyURLInConfig | (private) | `private func syncProxyURLInConfig()` |
| 802 | fn | syncCustomProvidersToConfig | (private) | `private func syncCustomProvidersToConfig()` |
| 819 | fn | downloadAndInstallBinary | (internal) | `func downloadAndInstallBinary() async throws` |
| 880 | fn | fetchLatestRelease | (private) | `private func fetchLatestRelease() async throws ...` |
| 901 | fn | findCompatibleAsset | (private) | `private func findCompatibleAsset(in release: Re...` |
| 926 | fn | downloadAsset | (private) | `private func downloadAsset(url: String) async t...` |
| 945 | fn | extractAndInstall | (private) | `private func extractAndInstall(data: Data, asse...` |
| 1007 | fn | findBinaryInDirectory | (private) | `private func findBinaryInDirectory(_ directory:...` |
| 1040 | fn | start | (internal) | `func start() async throws` |
| 1173 | fn | startRemoteRelay | (internal) | `func startRemoteRelay(config: RemoteConnectionC...` |
| 1209 | fn | stopRemoteRelay | (internal) | `func stopRemoteRelay()` |
| 1216 | fn | stop | (internal) | `func stop()` |
| 1273 | fn | startHealthMonitor | (private) | `private func startHealthMonitor()` |
| 1287 | fn | stopHealthMonitor | (private) | `private func stopHealthMonitor()` |
| 1292 | fn | performHealthCheck | (private) | `private func performHealthCheck() async` |
| 1355 | fn | cleanupOrphanProcesses | (private) | `private func cleanupOrphanProcesses() async` |
| 1418 | fn | terminateAuthProcess | (internal) | `func terminateAuthProcess()` |
| 1424 | fn | toggle | (internal) | `func toggle() async throws` |
| 1432 | fn | copyEndpointToClipboard | (internal) | `func copyEndpointToClipboard()` |
| 1437 | fn | revealInFinder | (internal) | `func revealInFinder()` |
| 1444 | enum | ProxyError | (internal) | `enum ProxyError` |
| 1478 | enum | AuthCommand | (internal) | `enum AuthCommand` |
| 1516 | struct | AuthCommandResult | (internal) | `struct AuthCommandResult` |
| 1522 | mod | extension CLIProxyManager | (internal) | - |
| 1523 | fn | runAuthCommand | (internal) | `func runAuthCommand(_ command: AuthCommand) asy...` |
| 1553 | fn | appendOutput | (internal) | `func appendOutput(_ str: String)` |
| 1557 | fn | tryResume | (internal) | `func tryResume() -> Bool` |
| 1568 | fn | safeResume | (internal) | `@Sendable func safeResume(_ result: AuthCommand...` |
| 1668 | mod | extension CLIProxyManager | (internal) | - |
| 1698 | fn | checkForUpgrade | (internal) | `func checkForUpgrade() async` |
| 1749 | fn | saveInstalledVersion | (private) | `private func saveInstalledVersion(_ version: St...` |
| 1757 | fn | fetchAvailableReleases | (internal) | `func fetchAvailableReleases(limit: Int = 10) as...` |
| 1779 | fn | versionInfo | (internal) | `func versionInfo(from release: GitHubRelease) -...` |
| 1785 | fn | fetchGitHubRelease | (private) | `private func fetchGitHubRelease(tag: String) as...` |
| 1807 | fn | findCompatibleAsset | (private) | `private func findCompatibleAsset(from release: ...` |
| 1840 | fn | performManagedUpgrade | (internal) | `func performManagedUpgrade(to version: ProxyVer...` |
| 1898 | fn | downloadAndInstallVersion | (private) | `private func downloadAndInstallVersion(_ versio...` |
| 1945 | fn | startDryRun | (private) | `private func startDryRun(version: String) async...` |
| 2014 | fn | promote | (private) | `private func promote(version: String) async throws` |
| 2049 | fn | rollback | (internal) | `func rollback() async throws` |
| 2082 | fn | stopTestProxy | (private) | `private func stopTestProxy() async` |
| 2111 | fn | stopTestProxySync | (private) | `private func stopTestProxySync()` |
| 2137 | fn | findUnusedPort | (private) | `private func findUnusedPort() throws -> UInt16` |
| 2147 | fn | isPortInUse | (private) | `private func isPortInUse(_ port: UInt16) -> Bool` |
| 2166 | fn | createTestConfig | (private) | `private func createTestConfig(port: UInt16) -> ...` |
| 2197 | fn | cleanupTestConfig | (private) | `private func cleanupTestConfig(_ configPath: St...` |
| 2205 | fn | isNewerVersion | (private) | `private func isNewerVersion(_ newer: String, th...` |
| 2208 | fn | parseVersion | (internal) | `func parseVersion(_ version: String) -> [Int]` |
| 2240 | fn | findPreviousVersion | (private) | `private func findPreviousVersion() -> String?` |
| 2253 | fn | migrateToVersionedStorage | (internal) | `func migrateToVersionedStorage() async throws` |

## Memory Markers

### 🟢 `NOTE` (line 281)

> Bridge mode default is registered in AppDelegate.applicationDidFinishLaunching()

### 🟢 `NOTE` (line 478)

> Changes take effect after proxy restart (CLIProxyAPI does not support live routing API)

### 🟢 `NOTE` (line 1732)

> Notification is handled by AtomFeedUpdateService polling

