# Quotio/Views/Screens/ProvidersScreen.swift

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 3022
- **Language:** Swift
- **Symbols:** 83
- **Public symbols:** 0

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 16 | struct | ProvidersScreen | (internal) | `struct ProvidersScreen` |
| 453 | fn | handleAddProvider | (private) | `private func handleAddProvider(_ provider: AIPr...` |
| 476 | fn | accountMetadataKey | (private) | `private func accountMetadataKey(for authFile: A...` |
| 483 | fn | accountMetadataKey | (private) | `private func accountMetadataKey(for directAuthF...` |
| 487 | fn | resolvedAccountRemark | (private) | `private func resolvedAccountRemark(for metadata...` |
| 492 | fn | displayRemark | (private) | `private func displayRemark(for authFile: AuthFi...` |
| 499 | fn | effectiveProxyURL | (private) | `private func effectiveProxyURL(for authFile: Au...` |
| 509 | fn | sortedAccounts | (private) | `private func sortedAccounts(_ accounts: [Accoun...` |
| 532 | fn | moveAccounts | (private) | `private func moveAccounts(in provider: AIProvid...` |
| 541 | fn | deleteAccount | (private) | `private func deleteAccount(_ account: AccountRo...` |
| 587 | fn | toggleAccountDisabled | (private) | `private func toggleAccountDisabled(_ account: A...` |
| 598 | fn | openIdentityBinding | (private) | `private func openIdentityBinding(for account: A...` |
| 607 | fn | unbindIdentityBinding | (private) | `private func unbindIdentityBinding(for account:...` |
| 616 | fn | handleEditGlmAccount | (private) | `private func handleEditGlmAccount(_ account: Ac...` |
| 623 | fn | handleEditWarpAccount | (private) | `private func handleEditWarpAccount(_ account: A...` |
| 631 | fn | handleConfigureAccountSettings | (private) | `private func handleConfigureAccountSettings(_ a...` |
| 677 | fn | applyLaunchAutomationIfNeeded | (private) | `private func applyLaunchAutomationIfNeeded()` |
| 746 | fn | accountSourceSmokeName | (private) | `private func accountSourceSmokeName(_ source: A...` |
| 757 | fn | matchingLaunchAutomationAccounts | (private) | `private func matchingLaunchAutomationAccounts( ...` |
| 777 | fn | uiSmokeLog | (private) | `private func uiSmokeLog(_ message: String)` |
| 783 | fn | syncCustomProvidersToConfig | (private) | `private func syncCustomProvidersToConfig()` |
| 790 | fn | providersMetadataFallbackUserDefaults | (private) | `private func providersMetadataFallbackUserDefau...` |
| 795 | fn | providersResolvedRemark | (private) | `@MainActor private func providersResolvedRemark...` |
| 804 | fn | providersResolvedFingerprintProfile | (private) | `@MainActor private func providersResolvedFinger...` |
| 814 | struct | AccountSettingsEditorContext | (private) | `struct AccountSettingsEditorContext` |
| 825 | enum | AuthStatusRefreshFeedbackTone | (private) | `enum AuthStatusRefreshFeedbackTone` |
| 831 | struct | AccountSettingsSheet | (private) | `struct AccountSettingsSheet` |
| 1149 | fn | remoteSummaryRow | (private) | `private func remoteSummaryRow(title: String, va...` |
| 1161 | fn | openRemoteManagementCenter | (private) | `private func openRemoteManagementCenter()` |
| 1256 | fn | detailBlock | (private) | `private func detailBlock(title: String, value: ...` |
| 1267 | fn | detailList | (private) | `private func detailList(title: String, values: ...` |
| 1281 | fn | detailHeaders | (private) | `private func detailHeaders(title: String, heade...` |
| 1297 | fn | managedUpstreamHeaders | (private) | `private func managedUpstreamHeaders(for profile...` |
| 1310 | fn | httpSummaryText | (private) | `private func httpSummaryText(for profile: Accou...` |
| 1591 | fn | copyOAuthLinkButton | (private) | `private func copyOAuthLinkButton(authURLString:...` |
| 1600 | fn | openOAuthLinkButton | (private) | `private func openOAuthLinkButton(authURL: URL) ...` |
| 1621 | fn | statusMessageRow | (private) | `private func statusMessageRow(icon: String, col...` |
| 1730 | fn | regenerateFingerprintProfile | (private) | `private func regenerateFingerprintProfile()` |
| 1739 | fn | loadCurrentValue | (private) | `private func loadCurrentValue() async` |
| 1820 | fn | loadReauthHistory | (private) | `private func loadReauthHistory() async` |
| 1841 | fn | runProvidersReauthSmokeIfNeeded | (private) | `private func runProvidersReauthSmokeIfNeeded() ...` |
| 1873 | fn | reauthenticateCurrentAccount | (private) | `private func reauthenticateCurrentAccount() async` |
| 1881 | fn | cancelCurrentReauthentication | (private) | `private func cancelCurrentReauthentication() async` |
| 1889 | fn | waitForCurrentOAuthURL | (private) | `private func waitForCurrentOAuthURL() async -> ...` |
| 1899 | fn | waitForReauthIdle | (private) | `private func waitForReauthIdle() async -> Bool` |
| 1909 | fn | copyOAuthLink | (private) | `private func copyOAuthLink(_ authURLString: Str...` |
| 1918 | fn | uiSmokeLog | (private) | `private func uiSmokeLog(_ message: String)` |
| 1924 | fn | refreshCurrentAuthStatus | (private) | `private func refreshCurrentAuthStatus() async` |
| 1952 | fn | historyStatusTitle | (private) | `private func historyStatusTitle(for event: OAut...` |
| 1956 | fn | historyStatusColor | (private) | `private func historyStatusColor(for event: OAut...` |
| 1960 | fn | formattedHistoryOccurredAt | (private) | `private func formattedHistoryOccurredAt(for eve...` |
| 1971 | fn | historyAccountSummary | (private) | `private func historyAccountSummary(for event: O...` |
| 1981 | fn | historyPlanSummary | (private) | `private func historyPlanSummary(for event: OAut...` |
| 1990 | fn | historyErrorSummary | (private) | `private func historyErrorSummary(for event: OAu...` |
| 2007 | fn | save | (private) | `private func save() async` |
| 2091 | struct | CustomProviderRow | (internal) | `struct CustomProviderRow` |
| 2192 | struct | MenuBarBadge | (internal) | `struct MenuBarBadge` |
| 2215 | class | TooltipWindow | (private) | `class TooltipWindow` |
| 2227 | method | init | (private) | `private init()` |
| 2257 | fn | show | (internal) | `func show(text: String, near view: NSView)` |
| 2286 | fn | hide | (internal) | `func hide()` |
| 2292 | class | TooltipTrackingView | (private) | `class TooltipTrackingView` |
| 2294 | fn | updateTrackingAreas | (internal) | `override func updateTrackingAreas()` |
| 2305 | fn | mouseEntered | (internal) | `override func mouseEntered(with event: NSEvent)` |
| 2309 | fn | mouseExited | (internal) | `override func mouseExited(with event: NSEvent)` |
| 2313 | fn | hitTest | (internal) | `override func hitTest(_ point: NSPoint) -> NSView?` |
| 2319 | struct | NativeTooltipView | (private) | `struct NativeTooltipView` |
| 2321 | fn | makeNSView | (internal) | `func makeNSView(context: Context) -> TooltipTra...` |
| 2327 | fn | updateNSView | (internal) | `func updateNSView(_ nsView: TooltipTrackingView...` |
| 2333 | mod | extension View | (private) | - |
| 2334 | fn | nativeTooltip | (internal) | `func nativeTooltip(_ text: String) -> some View` |
| 2341 | struct | MenuBarHintView | (internal) | `struct MenuBarHintView` |
| 2356 | struct | OAuthSheet | (internal) | `struct OAuthSheet` |
| 2584 | struct | OAuthCallbackPasteSection | (private) | `struct OAuthCallbackPasteSection` |
| 2661 | fn | submitCallback | (private) | `private func submitCallback() async` |
| 2681 | enum | OAuthCallbackSubmissionFeedback | (private) | `enum OAuthCallbackSubmissionFeedback` |
| 2702 | enum | OAuthCallbackPasteValidation | (private) | `enum OAuthCallbackPasteValidation` |
| 2706 | method | init | (internal) | `init(rawValue: String, expectedState: String?)` |
| 2766 | fn | normalizedCallbackURL | (private) | `private static func normalizedCallbackURL(from ...` |
| 2785 | fn | queryItems | (private) | `private static func queryItems(from components:...` |
| 2794 | fn | queryValue | (private) | `private static func queryValue(named name: Stri...` |
| 2801 | struct | OAuthStatusView | (private) | `struct OAuthStatusView` |
| 3001 | enum | CustomProviderSheetMode | (internal) | `enum CustomProviderSheetMode` |

## Memory Markers

### 🟢 `NOTE` (line 85)

> GLM uses API key auth via CustomProviderService, so skip it here

