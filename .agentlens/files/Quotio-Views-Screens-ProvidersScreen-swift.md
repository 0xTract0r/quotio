# Quotio/Views/Screens/ProvidersScreen.swift

[← Back to Module](../modules/Quotio-Views-Screens/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 3017
- **Language:** Swift
- **Symbols:** 83
- **Public symbols:** 0

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 16 | struct | ProvidersScreen | (internal) | `struct ProvidersScreen` |
| 448 | fn | handleAddProvider | (private) | `private func handleAddProvider(_ provider: AIPr...` |
| 471 | fn | accountMetadataKey | (private) | `private func accountMetadataKey(for authFile: A...` |
| 478 | fn | accountMetadataKey | (private) | `private func accountMetadataKey(for directAuthF...` |
| 482 | fn | resolvedAccountRemark | (private) | `private func resolvedAccountRemark(for metadata...` |
| 487 | fn | displayRemark | (private) | `private func displayRemark(for authFile: AuthFi...` |
| 494 | fn | effectiveProxyURL | (private) | `private func effectiveProxyURL(for authFile: Au...` |
| 504 | fn | sortedAccounts | (private) | `private func sortedAccounts(_ accounts: [Accoun...` |
| 527 | fn | moveAccounts | (private) | `private func moveAccounts(in provider: AIProvid...` |
| 536 | fn | deleteAccount | (private) | `private func deleteAccount(_ account: AccountRo...` |
| 582 | fn | toggleAccountDisabled | (private) | `private func toggleAccountDisabled(_ account: A...` |
| 593 | fn | openIdentityBinding | (private) | `private func openIdentityBinding(for account: A...` |
| 602 | fn | unbindIdentityBinding | (private) | `private func unbindIdentityBinding(for account:...` |
| 611 | fn | handleEditGlmAccount | (private) | `private func handleEditGlmAccount(_ account: Ac...` |
| 618 | fn | handleEditWarpAccount | (private) | `private func handleEditWarpAccount(_ account: A...` |
| 626 | fn | handleConfigureAccountSettings | (private) | `private func handleConfigureAccountSettings(_ a...` |
| 672 | fn | applyLaunchAutomationIfNeeded | (private) | `private func applyLaunchAutomationIfNeeded()` |
| 741 | fn | accountSourceSmokeName | (private) | `private func accountSourceSmokeName(_ source: A...` |
| 752 | fn | matchingLaunchAutomationAccounts | (private) | `private func matchingLaunchAutomationAccounts( ...` |
| 772 | fn | uiSmokeLog | (private) | `private func uiSmokeLog(_ message: String)` |
| 778 | fn | syncCustomProvidersToConfig | (private) | `private func syncCustomProvidersToConfig()` |
| 785 | fn | providersMetadataFallbackUserDefaults | (private) | `private func providersMetadataFallbackUserDefau...` |
| 790 | fn | providersResolvedRemark | (private) | `@MainActor private func providersResolvedRemark...` |
| 799 | fn | providersResolvedFingerprintProfile | (private) | `@MainActor private func providersResolvedFinger...` |
| 809 | struct | AccountSettingsEditorContext | (private) | `struct AccountSettingsEditorContext` |
| 820 | enum | AuthStatusRefreshFeedbackTone | (private) | `enum AuthStatusRefreshFeedbackTone` |
| 826 | struct | AccountSettingsSheet | (private) | `struct AccountSettingsSheet` |
| 1144 | fn | remoteSummaryRow | (private) | `private func remoteSummaryRow(title: String, va...` |
| 1156 | fn | openRemoteManagementCenter | (private) | `private func openRemoteManagementCenter()` |
| 1251 | fn | detailBlock | (private) | `private func detailBlock(title: String, value: ...` |
| 1262 | fn | detailList | (private) | `private func detailList(title: String, values: ...` |
| 1276 | fn | detailHeaders | (private) | `private func detailHeaders(title: String, heade...` |
| 1292 | fn | managedUpstreamHeaders | (private) | `private func managedUpstreamHeaders(for profile...` |
| 1305 | fn | httpSummaryText | (private) | `private func httpSummaryText(for profile: Accou...` |
| 1586 | fn | copyOAuthLinkButton | (private) | `private func copyOAuthLinkButton(authURLString:...` |
| 1595 | fn | openOAuthLinkButton | (private) | `private func openOAuthLinkButton(authURL: URL) ...` |
| 1616 | fn | statusMessageRow | (private) | `private func statusMessageRow(icon: String, col...` |
| 1725 | fn | regenerateFingerprintProfile | (private) | `private func regenerateFingerprintProfile()` |
| 1734 | fn | loadCurrentValue | (private) | `private func loadCurrentValue() async` |
| 1815 | fn | loadReauthHistory | (private) | `private func loadReauthHistory() async` |
| 1836 | fn | runProvidersReauthSmokeIfNeeded | (private) | `private func runProvidersReauthSmokeIfNeeded() ...` |
| 1868 | fn | reauthenticateCurrentAccount | (private) | `private func reauthenticateCurrentAccount() async` |
| 1876 | fn | cancelCurrentReauthentication | (private) | `private func cancelCurrentReauthentication() async` |
| 1884 | fn | waitForCurrentOAuthURL | (private) | `private func waitForCurrentOAuthURL() async -> ...` |
| 1894 | fn | waitForReauthIdle | (private) | `private func waitForReauthIdle() async -> Bool` |
| 1904 | fn | copyOAuthLink | (private) | `private func copyOAuthLink(_ authURLString: Str...` |
| 1913 | fn | uiSmokeLog | (private) | `private func uiSmokeLog(_ message: String)` |
| 1919 | fn | refreshCurrentAuthStatus | (private) | `private func refreshCurrentAuthStatus() async` |
| 1947 | fn | historyStatusTitle | (private) | `private func historyStatusTitle(for event: OAut...` |
| 1951 | fn | historyStatusColor | (private) | `private func historyStatusColor(for event: OAut...` |
| 1955 | fn | formattedHistoryOccurredAt | (private) | `private func formattedHistoryOccurredAt(for eve...` |
| 1966 | fn | historyAccountSummary | (private) | `private func historyAccountSummary(for event: O...` |
| 1976 | fn | historyPlanSummary | (private) | `private func historyPlanSummary(for event: OAut...` |
| 1985 | fn | historyErrorSummary | (private) | `private func historyErrorSummary(for event: OAu...` |
| 2002 | fn | save | (private) | `private func save() async` |
| 2086 | struct | CustomProviderRow | (internal) | `struct CustomProviderRow` |
| 2187 | struct | MenuBarBadge | (internal) | `struct MenuBarBadge` |
| 2210 | class | TooltipWindow | (private) | `class TooltipWindow` |
| 2222 | method | init | (private) | `private init()` |
| 2252 | fn | show | (internal) | `func show(text: String, near view: NSView)` |
| 2281 | fn | hide | (internal) | `func hide()` |
| 2287 | class | TooltipTrackingView | (private) | `class TooltipTrackingView` |
| 2289 | fn | updateTrackingAreas | (internal) | `override func updateTrackingAreas()` |
| 2300 | fn | mouseEntered | (internal) | `override func mouseEntered(with event: NSEvent)` |
| 2304 | fn | mouseExited | (internal) | `override func mouseExited(with event: NSEvent)` |
| 2308 | fn | hitTest | (internal) | `override func hitTest(_ point: NSPoint) -> NSView?` |
| 2314 | struct | NativeTooltipView | (private) | `struct NativeTooltipView` |
| 2316 | fn | makeNSView | (internal) | `func makeNSView(context: Context) -> TooltipTra...` |
| 2322 | fn | updateNSView | (internal) | `func updateNSView(_ nsView: TooltipTrackingView...` |
| 2328 | mod | extension View | (private) | - |
| 2329 | fn | nativeTooltip | (internal) | `func nativeTooltip(_ text: String) -> some View` |
| 2336 | struct | MenuBarHintView | (internal) | `struct MenuBarHintView` |
| 2351 | struct | OAuthSheet | (internal) | `struct OAuthSheet` |
| 2579 | struct | OAuthCallbackPasteSection | (private) | `struct OAuthCallbackPasteSection` |
| 2656 | fn | submitCallback | (private) | `private func submitCallback() async` |
| 2676 | enum | OAuthCallbackSubmissionFeedback | (private) | `enum OAuthCallbackSubmissionFeedback` |
| 2697 | enum | OAuthCallbackPasteValidation | (private) | `enum OAuthCallbackPasteValidation` |
| 2701 | method | init | (internal) | `init(rawValue: String, expectedState: String?)` |
| 2761 | fn | normalizedCallbackURL | (private) | `private static func normalizedCallbackURL(from ...` |
| 2780 | fn | queryItems | (private) | `private static func queryItems(from components:...` |
| 2789 | fn | queryValue | (private) | `private static func queryValue(named name: Stri...` |
| 2796 | struct | OAuthStatusView | (private) | `struct OAuthStatusView` |
| 2996 | enum | CustomProviderSheetMode | (internal) | `enum CustomProviderSheetMode` |

## Memory Markers

### 🟢 `NOTE` (line 83)

> GLM uses API key auth via CustomProviderService, so skip it here

