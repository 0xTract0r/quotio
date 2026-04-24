# Quotio/Views/Screens/ProvidersScreen.swift

[← Back to Module](../modules/Quotio-Views-Screens/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2801
- **Language:** Swift
- **Symbols:** 79
- **Public symbols:** 0

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 16 | struct | ProvidersScreen | (internal) | `struct ProvidersScreen` |
| 447 | fn | handleAddProvider | (private) | `private func handleAddProvider(_ provider: AIPr...` |
| 470 | fn | accountMetadataKey | (private) | `private func accountMetadataKey(for authFile: A...` |
| 477 | fn | accountMetadataKey | (private) | `private func accountMetadataKey(for directAuthF...` |
| 481 | fn | resolvedAccountRemark | (private) | `private func resolvedAccountRemark(for metadata...` |
| 486 | fn | effectiveProxyURL | (private) | `private func effectiveProxyURL(for authFile: Au...` |
| 493 | fn | sortedAccounts | (private) | `private func sortedAccounts(_ accounts: [Accoun...` |
| 516 | fn | moveAccounts | (private) | `private func moveAccounts(in provider: AIProvid...` |
| 525 | fn | deleteAccount | (private) | `private func deleteAccount(_ account: AccountRo...` |
| 571 | fn | toggleAccountDisabled | (private) | `private func toggleAccountDisabled(_ account: A...` |
| 582 | fn | openIdentityBinding | (private) | `private func openIdentityBinding(for account: A...` |
| 591 | fn | unbindIdentityBinding | (private) | `private func unbindIdentityBinding(for account:...` |
| 600 | fn | handleEditGlmAccount | (private) | `private func handleEditGlmAccount(_ account: Ac...` |
| 607 | fn | handleEditWarpAccount | (private) | `private func handleEditWarpAccount(_ account: A...` |
| 615 | fn | handleConfigureAccountSettings | (private) | `private func handleConfigureAccountSettings(_ a...` |
| 661 | fn | applyLaunchAutomationIfNeeded | (private) | `private func applyLaunchAutomationIfNeeded()` |
| 718 | fn | matchingLaunchAutomationAccounts | (private) | `private func matchingLaunchAutomationAccounts( ...` |
| 738 | fn | uiSmokeLog | (private) | `private func uiSmokeLog(_ message: String)` |
| 744 | fn | syncCustomProvidersToConfig | (private) | `private func syncCustomProvidersToConfig()` |
| 751 | fn | providersMetadataFallbackUserDefaults | (private) | `private func providersMetadataFallbackUserDefau...` |
| 756 | fn | providersResolvedRemark | (private) | `@MainActor private func providersResolvedRemark...` |
| 765 | fn | providersResolvedFingerprintProfile | (private) | `@MainActor private func providersResolvedFinger...` |
| 775 | struct | AccountSettingsEditorContext | (private) | `struct AccountSettingsEditorContext` |
| 786 | enum | AuthStatusRefreshFeedbackTone | (private) | `enum AuthStatusRefreshFeedbackTone` |
| 792 | struct | AccountSettingsSheet | (private) | `struct AccountSettingsSheet` |
| 1087 | fn | detailBlock | (private) | `private func detailBlock(title: String, value: ...` |
| 1098 | fn | detailList | (private) | `private func detailList(title: String, values: ...` |
| 1112 | fn | detailHeaders | (private) | `private func detailHeaders(title: String, heade...` |
| 1128 | fn | managedUpstreamHeaders | (private) | `private func managedUpstreamHeaders(for profile...` |
| 1141 | fn | httpSummaryText | (private) | `private func httpSummaryText(for profile: Accou...` |
| 1422 | fn | copyOAuthLinkButton | (private) | `private func copyOAuthLinkButton(authURLString:...` |
| 1431 | fn | openOAuthLinkButton | (private) | `private func openOAuthLinkButton(authURL: URL) ...` |
| 1452 | fn | statusMessageRow | (private) | `private func statusMessageRow(icon: String, col...` |
| 1561 | fn | regenerateFingerprintProfile | (private) | `private func regenerateFingerprintProfile()` |
| 1570 | fn | loadCurrentValue | (private) | `private func loadCurrentValue() async` |
| 1617 | fn | loadReauthHistory | (private) | `private func loadReauthHistory() async` |
| 1638 | fn | runProvidersReauthSmokeIfNeeded | (private) | `private func runProvidersReauthSmokeIfNeeded() ...` |
| 1670 | fn | reauthenticateCurrentAccount | (private) | `private func reauthenticateCurrentAccount() async` |
| 1678 | fn | cancelCurrentReauthentication | (private) | `private func cancelCurrentReauthentication() async` |
| 1686 | fn | waitForCurrentOAuthURL | (private) | `private func waitForCurrentOAuthURL() async -> ...` |
| 1696 | fn | waitForReauthIdle | (private) | `private func waitForReauthIdle() async -> Bool` |
| 1706 | fn | copyOAuthLink | (private) | `private func copyOAuthLink(_ authURLString: Str...` |
| 1715 | fn | uiSmokeLog | (private) | `private func uiSmokeLog(_ message: String)` |
| 1721 | fn | refreshCurrentAuthStatus | (private) | `private func refreshCurrentAuthStatus() async` |
| 1749 | fn | historyStatusTitle | (private) | `private func historyStatusTitle(for event: OAut...` |
| 1753 | fn | historyStatusColor | (private) | `private func historyStatusColor(for event: OAut...` |
| 1757 | fn | formattedHistoryOccurredAt | (private) | `private func formattedHistoryOccurredAt(for eve...` |
| 1768 | fn | historyAccountSummary | (private) | `private func historyAccountSummary(for event: O...` |
| 1778 | fn | historyPlanSummary | (private) | `private func historyPlanSummary(for event: OAut...` |
| 1787 | fn | historyErrorSummary | (private) | `private func historyErrorSummary(for event: OAu...` |
| 1804 | fn | save | (private) | `private func save() async` |
| 1883 | struct | CustomProviderRow | (internal) | `struct CustomProviderRow` |
| 1984 | struct | MenuBarBadge | (internal) | `struct MenuBarBadge` |
| 2007 | class | TooltipWindow | (private) | `class TooltipWindow` |
| 2019 | method | init | (private) | `private init()` |
| 2049 | fn | show | (internal) | `func show(text: String, near view: NSView)` |
| 2078 | fn | hide | (internal) | `func hide()` |
| 2084 | class | TooltipTrackingView | (private) | `class TooltipTrackingView` |
| 2086 | fn | updateTrackingAreas | (internal) | `override func updateTrackingAreas()` |
| 2097 | fn | mouseEntered | (internal) | `override func mouseEntered(with event: NSEvent)` |
| 2101 | fn | mouseExited | (internal) | `override func mouseExited(with event: NSEvent)` |
| 2105 | fn | hitTest | (internal) | `override func hitTest(_ point: NSPoint) -> NSView?` |
| 2111 | struct | NativeTooltipView | (private) | `struct NativeTooltipView` |
| 2113 | fn | makeNSView | (internal) | `func makeNSView(context: Context) -> TooltipTra...` |
| 2119 | fn | updateNSView | (internal) | `func updateNSView(_ nsView: TooltipTrackingView...` |
| 2125 | mod | extension View | (private) | - |
| 2126 | fn | nativeTooltip | (internal) | `func nativeTooltip(_ text: String) -> some View` |
| 2133 | struct | MenuBarHintView | (internal) | `struct MenuBarHintView` |
| 2148 | struct | OAuthSheet | (internal) | `struct OAuthSheet` |
| 2363 | struct | OAuthCallbackPasteSection | (private) | `struct OAuthCallbackPasteSection` |
| 2440 | fn | submitCallback | (private) | `private func submitCallback() async` |
| 2460 | enum | OAuthCallbackSubmissionFeedback | (private) | `enum OAuthCallbackSubmissionFeedback` |
| 2481 | enum | OAuthCallbackPasteValidation | (private) | `enum OAuthCallbackPasteValidation` |
| 2485 | method | init | (internal) | `init(rawValue: String, expectedState: String?)` |
| 2545 | fn | normalizedCallbackURL | (private) | `private static func normalizedCallbackURL(from ...` |
| 2564 | fn | queryItems | (private) | `private static func queryItems(from components:...` |
| 2573 | fn | queryValue | (private) | `private static func queryValue(named name: Stri...` |
| 2580 | struct | OAuthStatusView | (private) | `struct OAuthStatusView` |
| 2780 | enum | CustomProviderSheetMode | (internal) | `enum CustomProviderSheetMode` |

## Memory Markers

### 🟢 `NOTE` (line 83)

> GLM uses API key auth via CustomProviderService, so skip it here

