# Quotio/Views/Screens/SettingsScreen.swift

[← Back to Module](../modules/Quotio-Views-Screens/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 3100
- **Language:** Swift
- **Symbols:** 60
- **Public symbols:** 0

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 9 | struct | SettingsScreen | (internal) | `struct SettingsScreen` |
| 113 | struct | OperatingModeSection | (internal) | `struct OperatingModeSection` |
| 183 | fn | handleModeSelection | (private) | `private func handleModeSelection(_ mode: Operat...` |
| 204 | fn | switchToMode | (private) | `private func switchToMode(_ mode: OperatingMode)` |
| 239 | struct | RemoteServerSection | (internal) | `struct RemoteServerSection` |
| 356 | fn | saveRemoteConfig | (private) | `private func saveRemoteConfig(_ config: RemoteC...` |
| 369 | fn | reconnect | (private) | `private func reconnect()` |
| 384 | struct | UnifiedProxySettingsSection | (internal) | `struct UnifiedProxySettingsSection` |
| 607 | fn | loadConfig | (private) | `private func loadConfig() async` |
| 654 | fn | saveProxyURL | (private) | `private func saveProxyURL() async` |
| 672 | fn | saveRoutingStrategy | (private) | `private func saveRoutingStrategy(_ strategy: St...` |
| 681 | fn | saveSwitchProject | (private) | `private func saveSwitchProject(_ enabled: Bool)...` |
| 690 | fn | saveSwitchPreviewModel | (private) | `private func saveSwitchPreviewModel(_ enabled: ...` |
| 699 | fn | saveRequestRetry | (private) | `private func saveRequestRetry(_ count: Int) async` |
| 708 | fn | saveMaxRetryInterval | (private) | `private func saveMaxRetryInterval(_ seconds: In...` |
| 717 | fn | saveLoggingToFile | (private) | `private func saveLoggingToFile(_ enabled: Bool)...` |
| 726 | fn | saveRequestLog | (private) | `private func saveRequestLog(_ enabled: Bool) async` |
| 735 | fn | saveDebugMode | (private) | `private func saveDebugMode(_ enabled: Bool) async` |
| 748 | struct | LocalProxyServerSection | (internal) | `struct LocalProxyServerSection` |
| 837 | struct | NetworkAccessSection | (internal) | `struct NetworkAccessSection` |
| 871 | struct | LocalPathsSection | (internal) | `struct LocalPathsSection` |
| 895 | struct | PathLabel | (internal) | `struct PathLabel` |
| 919 | struct | NotificationSettingsSection | (internal) | `struct NotificationSettingsSection` |
| 989 | struct | QuotaDisplaySettingsSection | (internal) | `struct QuotaDisplaySettingsSection` |
| 1031 | struct | RefreshCadenceSettingsSection | (internal) | `struct RefreshCadenceSettingsSection` |
| 1070 | struct | UpdateSettingsSection | (internal) | `struct UpdateSettingsSection` |
| 1112 | struct | ProxyUpdateSettingsSection | (internal) | `struct ProxyUpdateSettingsSection` |
| 1272 | fn | checkForUpdate | (private) | `private func checkForUpdate()` |
| 1286 | fn | performUpgrade | (private) | `private func performUpgrade(to version: ProxyVe...` |
| 1305 | struct | ProxyVersionManagerSheet | (internal) | `struct ProxyVersionManagerSheet` |
| 1464 | fn | sectionHeader | (private) | `@ViewBuilder   private func sectionHeader(_ tit...` |
| 1479 | fn | isVersionInstalled | (private) | `private func isVersionInstalled(_ version: Stri...` |
| 1483 | fn | refreshInstalledVersions | (private) | `private func refreshInstalledVersions()` |
| 1487 | fn | loadReleases | (private) | `private func loadReleases() async` |
| 1501 | fn | installVersion | (private) | `private func installVersion(_ release: GitHubRe...` |
| 1519 | fn | performInstall | (private) | `private func performInstall(_ release: GitHubRe...` |
| 1540 | fn | activateVersion | (private) | `private func activateVersion(_ version: String)` |
| 1558 | fn | deleteVersion | (private) | `private func deleteVersion(_ version: String)` |
| 1571 | struct | InstalledVersionRow | (private) | `struct InstalledVersionRow` |
| 1629 | struct | AvailableVersionRow | (private) | `struct AvailableVersionRow` |
| 1715 | fn | formatDate | (private) | `private func formatDate(_ isoString: String) ->...` |
| 1733 | struct | MenuBarSettingsSection | (internal) | `struct MenuBarSettingsSection` |
| 1874 | struct | AppearanceSettingsSection | (internal) | `struct AppearanceSettingsSection` |
| 1903 | struct | PrivacySettingsSection | (internal) | `struct PrivacySettingsSection` |
| 1925 | struct | GeneralSettingsTab | (internal) | `struct GeneralSettingsTab` |
| 1964 | struct | AboutTab | (internal) | `struct AboutTab` |
| 1991 | struct | AboutScreen | (internal) | `struct AboutScreen` |
| 2206 | struct | AboutUpdateSection | (internal) | `struct AboutUpdateSection` |
| 2262 | struct | AboutProxyUpdateSection | (internal) | `struct AboutProxyUpdateSection` |
| 2415 | fn | checkForUpdate | (private) | `private func checkForUpdate()` |
| 2429 | fn | performUpgrade | (private) | `private func performUpgrade(to version: ProxyVe...` |
| 2448 | struct | VersionBadge | (internal) | `struct VersionBadge` |
| 2500 | struct | AboutUpdateCard | (internal) | `struct AboutUpdateCard` |
| 2591 | struct | AboutProxyUpdateCard | (internal) | `struct AboutProxyUpdateCard` |
| 2765 | fn | checkForUpdate | (private) | `private func checkForUpdate()` |
| 2779 | fn | performUpgrade | (private) | `private func performUpgrade(to version: ProxyVe...` |
| 2798 | struct | LinkCard | (internal) | `struct LinkCard` |
| 2885 | struct | ManagementKeyRow | (internal) | `struct ManagementKeyRow` |
| 2979 | struct | LaunchAtLoginToggle | (internal) | `struct LaunchAtLoginToggle` |
| 3037 | struct | UsageDisplaySettingsSection | (internal) | `struct UsageDisplaySettingsSection` |

