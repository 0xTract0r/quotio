# Quotio/Services/Proxy/CLIProxyManager.swift

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2135
- **Language:** Swift
- **Symbols:** 69
- **Public symbols:** 0

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 9 | class | CLIProxyManager | (internal) | `class CLIProxyManager` |
| 50 | fn | configuredTestCAFilePath | (private) | `private func configuredTestCAFilePath() -> String?` |
| 80 | fn | makeProcessEnvironment | (private) | `private func makeProcessEnvironment() -> [Strin...` |
| 245 | method | init | (internal) | `init()` |
| 290 | fn | restartProxyIfRunning | (private) | `private func restartProxyIfRunning()` |
| 308 | fn | updateConfigValue | (private) | `private func updateConfigValue(pattern: String,...` |
| 328 | fn | updateConfigPort | (private) | `private func updateConfigPort(_ newPort: UInt16)` |
| 332 | fn | updateConfigHost | (private) | `private func updateConfigHost(_ host: String)` |
| 336 | fn | ensureApiKeyExistsInConfig | (private) | `private func ensureApiKeyExistsInConfig()` |
| 385 | fn | updateConfigAllowRemote | (internal) | `func updateConfigAllowRemote(_ enabled: Bool)` |
| 389 | fn | updateConfigLogging | (internal) | `func updateConfigLogging(enabled: Bool)` |
| 397 | fn | updateConfigRoutingStrategy | (internal) | `func updateConfigRoutingStrategy(_ strategy: St...` |
| 402 | fn | updateConfigProxyURL | (internal) | `func updateConfigProxyURL(_ url: String?)` |
| 430 | fn | applyBaseURLWorkaround | (internal) | `func applyBaseURLWorkaround()` |
| 459 | fn | removeBaseURLWorkaround | (internal) | `func removeBaseURLWorkaround()` |
| 501 | fn | ensureConfigExists | (private) | `private func ensureConfigExists()` |
| 538 | fn | ensureLogRetentionDefaultsInConfig | (private) | `private func ensureLogRetentionDefaultsInConfig()` |
| 578 | fn | rootKeyIndex | (private) | `private func rootKeyIndex(_ key: String, in lin...` |
| 585 | fn | syncSecretKeyInConfig | (private) | `private func syncSecretKeyInConfig()` |
| 598 | fn | ensureManagementPanelAutoUpdateDisabledInConfig | (private) | `private func ensureManagementPanelAutoUpdateDis...` |
| 653 | fn | regenerateManagementKey | (internal) | `func regenerateManagementKey() async throws` |
| 695 | fn | syncProxyURLInConfig | (private) | `private func syncProxyURLInConfig()` |
| 712 | fn | syncCustomProvidersToConfig | (private) | `private func syncCustomProvidersToConfig()` |
| 729 | fn | downloadAndInstallBinary | (internal) | `func downloadAndInstallBinary() async throws` |
| 790 | fn | fetchLatestRelease | (private) | `private func fetchLatestRelease() async throws ...` |
| 811 | fn | findCompatibleAsset | (private) | `private func findCompatibleAsset(in release: Re...` |
| 836 | fn | downloadAsset | (private) | `private func downloadAsset(url: String) async t...` |
| 855 | fn | extractAndInstall | (private) | `private func extractAndInstall(data: Data, asse...` |
| 917 | fn | findBinaryInDirectory | (private) | `private func findBinaryInDirectory(_ directory:...` |
| 950 | fn | start | (internal) | `func start() async throws` |
| 1081 | fn | stop | (internal) | `func stop()` |
| 1133 | fn | startHealthMonitor | (private) | `private func startHealthMonitor()` |
| 1147 | fn | stopHealthMonitor | (private) | `private func stopHealthMonitor()` |
| 1152 | fn | performHealthCheck | (private) | `private func performHealthCheck() async` |
| 1215 | fn | cleanupOrphanProcesses | (private) | `private func cleanupOrphanProcesses() async` |
| 1278 | fn | terminateAuthProcess | (internal) | `func terminateAuthProcess()` |
| 1284 | fn | toggle | (internal) | `func toggle() async throws` |
| 1292 | fn | copyEndpointToClipboard | (internal) | `func copyEndpointToClipboard()` |
| 1297 | fn | revealInFinder | (internal) | `func revealInFinder()` |
| 1304 | enum | ProxyError | (internal) | `enum ProxyError` |
| 1335 | enum | AuthCommand | (internal) | `enum AuthCommand` |
| 1373 | struct | AuthCommandResult | (internal) | `struct AuthCommandResult` |
| 1379 | mod | extension CLIProxyManager | (internal) | - |
| 1380 | fn | runAuthCommand | (internal) | `func runAuthCommand(_ command: AuthCommand) asy...` |
| 1410 | fn | appendOutput | (internal) | `func appendOutput(_ str: String)` |
| 1414 | fn | tryResume | (internal) | `func tryResume() -> Bool` |
| 1425 | fn | safeResume | (internal) | `@Sendable func safeResume(_ result: AuthCommand...` |
| 1525 | mod | extension CLIProxyManager | (internal) | - |
| 1555 | fn | checkForUpgrade | (internal) | `func checkForUpgrade() async` |
| 1606 | fn | saveInstalledVersion | (private) | `private func saveInstalledVersion(_ version: St...` |
| 1614 | fn | fetchAvailableReleases | (internal) | `func fetchAvailableReleases(limit: Int = 10) as...` |
| 1636 | fn | versionInfo | (internal) | `func versionInfo(from release: GitHubRelease) -...` |
| 1642 | fn | fetchGitHubRelease | (private) | `private func fetchGitHubRelease(tag: String) as...` |
| 1664 | fn | findCompatibleAsset | (private) | `private func findCompatibleAsset(from release: ...` |
| 1697 | fn | performManagedUpgrade | (internal) | `func performManagedUpgrade(to version: ProxyVer...` |
| 1755 | fn | downloadAndInstallVersion | (private) | `private func downloadAndInstallVersion(_ versio...` |
| 1802 | fn | startDryRun | (private) | `private func startDryRun(version: String) async...` |
| 1871 | fn | promote | (private) | `private func promote(version: String) async throws` |
| 1906 | fn | rollback | (internal) | `func rollback() async throws` |
| 1939 | fn | stopTestProxy | (private) | `private func stopTestProxy() async` |
| 1968 | fn | stopTestProxySync | (private) | `private func stopTestProxySync()` |
| 1994 | fn | findUnusedPort | (private) | `private func findUnusedPort() throws -> UInt16` |
| 2004 | fn | isPortInUse | (private) | `private func isPortInUse(_ port: UInt16) -> Bool` |
| 2023 | fn | createTestConfig | (private) | `private func createTestConfig(port: UInt16) -> ...` |
| 2054 | fn | cleanupTestConfig | (private) | `private func cleanupTestConfig(_ configPath: St...` |
| 2062 | fn | isNewerVersion | (private) | `private func isNewerVersion(_ newer: String, th...` |
| 2065 | fn | parseVersion | (internal) | `func parseVersion(_ version: String) -> [Int]` |
| 2097 | fn | findPreviousVersion | (private) | `private func findPreviousVersion() -> String?` |
| 2110 | fn | migrateToVersionedStorage | (internal) | `func migrateToVersionedStorage() async throws` |

## Memory Markers

### 🟢 `NOTE` (line 278)

> Bridge mode default is registered in AppDelegate.applicationDidFinishLaunching()

### 🟢 `NOTE` (line 396)

> Changes take effect after proxy restart (CLIProxyAPI does not support live routing API)

### 🟢 `NOTE` (line 1589)

> Notification is handled by AtomFeedUpdateService polling

