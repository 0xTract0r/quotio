# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 7 large files in this module.

## Quotio/Views/Screens/DashboardScreen.swift (1156 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 9 | struct | DashboardScreen | (internal) |
| 639 | fn | handleStepAction | (private) |
| 650 | fn | showProviderPicker | (private) |
| 679 | fn | showAgentPicker | (private) |
| 783 | fn | usageDayMetric | (private) |
| 950 | struct | GettingStartedStep | (internal) |
| 959 | struct | GettingStartedStepRow | (internal) |
| 1014 | struct | KPICard | (internal) |
| 1042 | struct | ProviderChip | (internal) |
| 1066 | struct | FlowLayout | (internal) |
| 1080 | fn | layout | (private) |
| 1108 | struct | QuotaProviderRow | (internal) |

## Quotio/Views/Screens/FallbackScreen.swift (539 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 8 | struct | FallbackScreen | (internal) |
| 113 | fn | loadModelsIfNeeded | (private) |
| 322 | struct | VirtualModelsEmptyState | (internal) |
| 364 | struct | VirtualModelRow | (internal) |
| 485 | struct | FallbackEntryRow | (internal) |

## Quotio/Views/Screens/IdentityPackagesScreen.swift (769 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 8 | struct | IdentityPackagesScreen | (internal) |
| 516 | fn | detailRow | (private) |
| 527 | fn | verificationLabel | (private) |
| 565 | fn | proxyOptionalBinding | (private) |
| 575 | fn | optionalStringBinding | (private) |
| 585 | fn | syncDraftFromSelection | (private) |
| 600 | fn | scheduleFixtureFlowSmokeIfNeeded | (private) |
| 610 | fn | emitEmptyStateSmokeLogIfNeeded | (private) |
| 623 | fn | runFixtureFlowSmokeIfNeeded | (private) |
| 654 | fn | uiSmokeLog | (private) |
| 660 | fn | saveDraft | (private) |
| 668 | fn | loadStoredProxyPassword | (private) |
| 674 | fn | deleteSelectedPackage | (private) |
| 681 | fn | markVerificationFailure | (private) |
| 687 | fn | markBlocked | (private) |
| 693 | fn | clearOperationalStatus | (private) |
| 699 | fn | migrateLegacyPackages | (private) |
| 711 | fn | importMessage | (private) |
| 738 | fn | migrationMessage | (private) |
| 745 | fn | statusBadge | (private) |
| 754 | fn | statusColor | (private) |

## Quotio/Views/Screens/LogsScreen.swift (599 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 8 | struct | LogsScreen | (internal) |
| 352 | struct | RequestRow | (internal) |
| 533 | fn | attemptOutcomeLabel | (private) |
| 544 | fn | attemptOutcomeColor | (private) |
| 559 | struct | StatItem | (internal) |
| 576 | struct | LogRow | (internal) |

## Quotio/Views/Screens/ProvidersScreen.swift (3022 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 16 | struct | ProvidersScreen | (internal) |
| 453 | fn | handleAddProvider | (private) |
| 476 | fn | accountMetadataKey | (private) |
| 483 | fn | accountMetadataKey | (private) |
| 487 | fn | resolvedAccountRemark | (private) |
| 492 | fn | displayRemark | (private) |
| 499 | fn | effectiveProxyURL | (private) |
| 509 | fn | sortedAccounts | (private) |
| 532 | fn | moveAccounts | (private) |
| 541 | fn | deleteAccount | (private) |
| 587 | fn | toggleAccountDisabled | (private) |
| 598 | fn | openIdentityBinding | (private) |
| 607 | fn | unbindIdentityBinding | (private) |
| 616 | fn | handleEditGlmAccount | (private) |
| 623 | fn | handleEditWarpAccount | (private) |
| 631 | fn | handleConfigureAccountSettings | (private) |
| 677 | fn | applyLaunchAutomationIfNeeded | (private) |
| 746 | fn | accountSourceSmokeName | (private) |
| 757 | fn | matchingLaunchAutomationAccounts | (private) |
| 777 | fn | uiSmokeLog | (private) |
| 783 | fn | syncCustomProvidersToConfig | (private) |
| 790 | fn | providersMetadataFallbackUserDefaults | (private) |
| 795 | fn | providersResolvedRemark | (private) |
| 804 | fn | providersResolvedFingerprintProfile | (private) |
| 814 | struct | AccountSettingsEditorContext | (private) |
| 825 | enum | AuthStatusRefreshFeedbackTone | (private) |
| 831 | struct | AccountSettingsSheet | (private) |
| 1149 | fn | remoteSummaryRow | (private) |
| 1161 | fn | openRemoteManagementCenter | (private) |
| 1256 | fn | detailBlock | (private) |
| 1267 | fn | detailList | (private) |
| 1281 | fn | detailHeaders | (private) |
| 1297 | fn | managedUpstreamHeaders | (private) |
| 1310 | fn | httpSummaryText | (private) |
| 1591 | fn | copyOAuthLinkButton | (private) |
| 1600 | fn | openOAuthLinkButton | (private) |
| 1621 | fn | statusMessageRow | (private) |
| 1730 | fn | regenerateFingerprintProfile | (private) |
| 1739 | fn | loadCurrentValue | (private) |
| 1820 | fn | loadReauthHistory | (private) |
| 1841 | fn | runProvidersReauthSmokeIfNeeded | (private) |
| 1873 | fn | reauthenticateCurrentAccount | (private) |
| 1881 | fn | cancelCurrentReauthentication | (private) |
| 1889 | fn | waitForCurrentOAuthURL | (private) |
| 1899 | fn | waitForReauthIdle | (private) |
| 1909 | fn | copyOAuthLink | (private) |
| 1918 | fn | uiSmokeLog | (private) |
| 1924 | fn | refreshCurrentAuthStatus | (private) |
| 1952 | fn | historyStatusTitle | (private) |
| 1956 | fn | historyStatusColor | (private) |
| 1960 | fn | formattedHistoryOccurredAt | (private) |
| 1971 | fn | historyAccountSummary | (private) |
| 1981 | fn | historyPlanSummary | (private) |
| 1990 | fn | historyErrorSummary | (private) |
| 2007 | fn | save | (private) |
| 2091 | struct | CustomProviderRow | (internal) |
| 2192 | struct | MenuBarBadge | (internal) |
| 2215 | class | TooltipWindow | (private) |
| 2227 | method | init | (private) |
| 2257 | fn | show | (internal) |
| 2286 | fn | hide | (internal) |
| 2292 | class | TooltipTrackingView | (private) |
| 2294 | fn | updateTrackingAreas | (internal) |
| 2305 | fn | mouseEntered | (internal) |
| 2309 | fn | mouseExited | (internal) |
| 2313 | fn | hitTest | (internal) |
| 2319 | struct | NativeTooltipView | (private) |
| 2321 | fn | makeNSView | (internal) |
| 2327 | fn | updateNSView | (internal) |
| 2333 | mod | extension View | (private) |
| 2334 | fn | nativeTooltip | (internal) |
| 2341 | struct | MenuBarHintView | (internal) |
| 2356 | struct | OAuthSheet | (internal) |
| 2584 | struct | OAuthCallbackPasteSection | (private) |
| 2661 | fn | submitCallback | (private) |
| 2681 | enum | OAuthCallbackSubmissionFeedback | (private) |
| 2702 | enum | OAuthCallbackPasteValidation | (private) |
| 2706 | method | init | (internal) |
| 2766 | fn | normalizedCallbackURL | (private) |
| 2785 | fn | queryItems | (private) |
| 2794 | fn | queryValue | (private) |
| 2801 | struct | OAuthStatusView | (private) |
| 3001 | enum | CustomProviderSheetMode | (internal) |

## Quotio/Views/Screens/QuotaScreen.swift (1599 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 8 | struct | QuotaScreen | (internal) |
| 37 | fn | accountCount | (private) |
| 54 | fn | lowestQuotaPercent | (private) |
| 213 | struct | QuotaDisplayHelper | (private) |
| 215 | fn | statusColor | (internal) |
| 231 | fn | displayPercent | (internal) |
| 240 | struct | ProviderSegmentButton | (private) |
| 318 | struct | QuotaStatusDot | (private) |
| 337 | struct | ProviderQuotaView | (private) |
| 419 | struct | AccountInfo | (private) |
| 431 | struct | AccountQuotaCardV2 | (private) |
| 815 | fn | standardContentByStyle | (private) |
| 843 | struct | PlanBadgeV2Compact | (private) |
| 897 | struct | PlanBadgeV2 | (private) |
| 952 | struct | SubscriptionBadgeV2 | (private) |
| 993 | struct | AntigravityDisplayGroup | (private) |
| 1003 | struct | AntigravityGroupRow | (private) |
| 1080 | struct | AntigravityLowestBarLayout | (private) |
| 1099 | fn | displayPercent | (private) |
| 1161 | struct | AntigravityRingLayout | (private) |
| 1173 | fn | displayPercent | (private) |
| 1202 | struct | StandardLowestBarLayout | (private) |
| 1221 | fn | displayPercent | (private) |
| 1294 | struct | StandardRingLayout | (private) |
| 1306 | fn | displayPercent | (private) |
| 1341 | struct | AntigravityModelsDetailSheet | (private) |
| 1410 | struct | ModelDetailCard | (private) |
| 1477 | struct | UsageRowV2 | (private) |
| 1565 | struct | QuotaLoadingView | (private) |

## Quotio/Views/Screens/SettingsScreen.swift (3100 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 9 | struct | SettingsScreen | (internal) |
| 113 | struct | OperatingModeSection | (internal) |
| 183 | fn | handleModeSelection | (private) |
| 204 | fn | switchToMode | (private) |
| 239 | struct | RemoteServerSection | (internal) |
| 356 | fn | saveRemoteConfig | (private) |
| 369 | fn | reconnect | (private) |
| 384 | struct | UnifiedProxySettingsSection | (internal) |
| 607 | fn | loadConfig | (private) |
| 654 | fn | saveProxyURL | (private) |
| 672 | fn | saveRoutingStrategy | (private) |
| 681 | fn | saveSwitchProject | (private) |
| 690 | fn | saveSwitchPreviewModel | (private) |
| 699 | fn | saveRequestRetry | (private) |
| 708 | fn | saveMaxRetryInterval | (private) |
| 717 | fn | saveLoggingToFile | (private) |
| 726 | fn | saveRequestLog | (private) |
| 735 | fn | saveDebugMode | (private) |
| 748 | struct | LocalProxyServerSection | (internal) |
| 837 | struct | NetworkAccessSection | (internal) |
| 871 | struct | LocalPathsSection | (internal) |
| 895 | struct | PathLabel | (internal) |
| 919 | struct | NotificationSettingsSection | (internal) |
| 989 | struct | QuotaDisplaySettingsSection | (internal) |
| 1031 | struct | RefreshCadenceSettingsSection | (internal) |
| 1070 | struct | UpdateSettingsSection | (internal) |
| 1112 | struct | ProxyUpdateSettingsSection | (internal) |
| 1272 | fn | checkForUpdate | (private) |
| 1286 | fn | performUpgrade | (private) |
| 1305 | struct | ProxyVersionManagerSheet | (internal) |
| 1464 | fn | sectionHeader | (private) |
| 1479 | fn | isVersionInstalled | (private) |
| 1483 | fn | refreshInstalledVersions | (private) |
| 1487 | fn | loadReleases | (private) |
| 1501 | fn | installVersion | (private) |
| 1519 | fn | performInstall | (private) |
| 1540 | fn | activateVersion | (private) |
| 1558 | fn | deleteVersion | (private) |
| 1571 | struct | InstalledVersionRow | (private) |
| 1629 | struct | AvailableVersionRow | (private) |
| 1715 | fn | formatDate | (private) |
| 1733 | struct | MenuBarSettingsSection | (internal) |
| 1874 | struct | AppearanceSettingsSection | (internal) |
| 1903 | struct | PrivacySettingsSection | (internal) |
| 1925 | struct | GeneralSettingsTab | (internal) |
| 1964 | struct | AboutTab | (internal) |
| 1991 | struct | AboutScreen | (internal) |
| 2206 | struct | AboutUpdateSection | (internal) |
| 2262 | struct | AboutProxyUpdateSection | (internal) |
| 2415 | fn | checkForUpdate | (private) |
| 2429 | fn | performUpgrade | (private) |
| 2448 | struct | VersionBadge | (internal) |
| 2500 | struct | AboutUpdateCard | (internal) |
| 2591 | struct | AboutProxyUpdateCard | (internal) |
| 2765 | fn | checkForUpdate | (private) |
| 2779 | fn | performUpgrade | (private) |
| 2798 | struct | LinkCard | (internal) |
| 2885 | struct | ManagementKeyRow | (internal) |
| 2979 | struct | LaunchAtLoginToggle | (internal) |
| 3037 | struct | UsageDisplaySettingsSection | (internal) |

