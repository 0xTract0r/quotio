# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 7 large files in this module.

## Quotio/Views/Screens/DashboardScreen.swift (1125 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 9 | struct | DashboardScreen | (internal) |
| 608 | fn | handleStepAction | (private) |
| 619 | fn | showProviderPicker | (private) |
| 648 | fn | showAgentPicker | (private) |
| 752 | fn | usageDayMetric | (private) |
| 919 | struct | GettingStartedStep | (internal) |
| 928 | struct | GettingStartedStepRow | (internal) |
| 983 | struct | KPICard | (internal) |
| 1011 | struct | ProviderChip | (internal) |
| 1035 | struct | FlowLayout | (internal) |
| 1049 | fn | layout | (private) |
| 1077 | struct | QuotaProviderRow | (internal) |

## Quotio/Views/Screens/FallbackScreen.swift (539 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 8 | struct | FallbackScreen | (internal) |
| 113 | fn | loadModelsIfNeeded | (private) |
| 322 | struct | VirtualModelsEmptyState | (internal) |
| 364 | struct | VirtualModelRow | (internal) |
| 485 | struct | FallbackEntryRow | (internal) |

## Quotio/Views/Screens/IdentityPackagesScreen.swift (688 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 8 | struct | IdentityPackagesScreen | (internal) |
| 452 | fn | detailRow | (private) |
| 463 | fn | verificationLabel | (private) |
| 501 | fn | proxyOptionalBinding | (private) |
| 511 | fn | optionalStringBinding | (private) |
| 521 | fn | syncDraftFromSelection | (private) |
| 526 | fn | scheduleFixtureFlowSmokeIfNeeded | (private) |
| 536 | fn | emitEmptyStateSmokeLogIfNeeded | (private) |
| 549 | fn | runFixtureFlowSmokeIfNeeded | (private) |
| 580 | fn | uiSmokeLog | (private) |
| 586 | fn | saveDraft | (private) |
| 593 | fn | deleteSelectedPackage | (private) |
| 600 | fn | markVerificationFailure | (private) |
| 606 | fn | markBlocked | (private) |
| 612 | fn | clearOperationalStatus | (private) |
| 618 | fn | migrateLegacyPackages | (private) |
| 630 | fn | importMessage | (private) |
| 657 | fn | migrationMessage | (private) |
| 664 | fn | statusBadge | (private) |
| 673 | fn | statusColor | (private) |

## Quotio/Views/Screens/LogsScreen.swift (585 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 8 | struct | LogsScreen | (internal) |
| 338 | struct | RequestRow | (internal) |
| 519 | fn | attemptOutcomeLabel | (private) |
| 530 | fn | attemptOutcomeColor | (private) |
| 545 | struct | StatItem | (internal) |
| 562 | struct | LogRow | (internal) |

## Quotio/Views/Screens/ProvidersScreen.swift (2801 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 16 | struct | ProvidersScreen | (internal) |
| 447 | fn | handleAddProvider | (private) |
| 470 | fn | accountMetadataKey | (private) |
| 477 | fn | accountMetadataKey | (private) |
| 481 | fn | resolvedAccountRemark | (private) |
| 486 | fn | effectiveProxyURL | (private) |
| 493 | fn | sortedAccounts | (private) |
| 516 | fn | moveAccounts | (private) |
| 525 | fn | deleteAccount | (private) |
| 571 | fn | toggleAccountDisabled | (private) |
| 582 | fn | openIdentityBinding | (private) |
| 591 | fn | unbindIdentityBinding | (private) |
| 600 | fn | handleEditGlmAccount | (private) |
| 607 | fn | handleEditWarpAccount | (private) |
| 615 | fn | handleConfigureAccountSettings | (private) |
| 661 | fn | applyLaunchAutomationIfNeeded | (private) |
| 718 | fn | matchingLaunchAutomationAccounts | (private) |
| 738 | fn | uiSmokeLog | (private) |
| 744 | fn | syncCustomProvidersToConfig | (private) |
| 751 | fn | providersMetadataFallbackUserDefaults | (private) |
| 756 | fn | providersResolvedRemark | (private) |
| 765 | fn | providersResolvedFingerprintProfile | (private) |
| 775 | struct | AccountSettingsEditorContext | (private) |
| 786 | enum | AuthStatusRefreshFeedbackTone | (private) |
| 792 | struct | AccountSettingsSheet | (private) |
| 1087 | fn | detailBlock | (private) |
| 1098 | fn | detailList | (private) |
| 1112 | fn | detailHeaders | (private) |
| 1128 | fn | managedUpstreamHeaders | (private) |
| 1141 | fn | httpSummaryText | (private) |
| 1422 | fn | copyOAuthLinkButton | (private) |
| 1431 | fn | openOAuthLinkButton | (private) |
| 1452 | fn | statusMessageRow | (private) |
| 1561 | fn | regenerateFingerprintProfile | (private) |
| 1570 | fn | loadCurrentValue | (private) |
| 1617 | fn | loadReauthHistory | (private) |
| 1638 | fn | runProvidersReauthSmokeIfNeeded | (private) |
| 1670 | fn | reauthenticateCurrentAccount | (private) |
| 1678 | fn | cancelCurrentReauthentication | (private) |
| 1686 | fn | waitForCurrentOAuthURL | (private) |
| 1696 | fn | waitForReauthIdle | (private) |
| 1706 | fn | copyOAuthLink | (private) |
| 1715 | fn | uiSmokeLog | (private) |
| 1721 | fn | refreshCurrentAuthStatus | (private) |
| 1749 | fn | historyStatusTitle | (private) |
| 1753 | fn | historyStatusColor | (private) |
| 1757 | fn | formattedHistoryOccurredAt | (private) |
| 1768 | fn | historyAccountSummary | (private) |
| 1778 | fn | historyPlanSummary | (private) |
| 1787 | fn | historyErrorSummary | (private) |
| 1804 | fn | save | (private) |
| 1883 | struct | CustomProviderRow | (internal) |
| 1984 | struct | MenuBarBadge | (internal) |
| 2007 | class | TooltipWindow | (private) |
| 2019 | method | init | (private) |
| 2049 | fn | show | (internal) |
| 2078 | fn | hide | (internal) |
| 2084 | class | TooltipTrackingView | (private) |
| 2086 | fn | updateTrackingAreas | (internal) |
| 2097 | fn | mouseEntered | (internal) |
| 2101 | fn | mouseExited | (internal) |
| 2105 | fn | hitTest | (internal) |
| 2111 | struct | NativeTooltipView | (private) |
| 2113 | fn | makeNSView | (internal) |
| 2119 | fn | updateNSView | (internal) |
| 2125 | mod | extension View | (private) |
| 2126 | fn | nativeTooltip | (internal) |
| 2133 | struct | MenuBarHintView | (internal) |
| 2148 | struct | OAuthSheet | (internal) |
| 2363 | struct | OAuthCallbackPasteSection | (private) |
| 2440 | fn | submitCallback | (private) |
| 2460 | enum | OAuthCallbackSubmissionFeedback | (private) |
| 2481 | enum | OAuthCallbackPasteValidation | (private) |
| 2485 | method | init | (internal) |
| 2545 | fn | normalizedCallbackURL | (private) |
| 2564 | fn | queryItems | (private) |
| 2573 | fn | queryValue | (private) |
| 2580 | struct | OAuthStatusView | (private) |
| 2780 | enum | CustomProviderSheetMode | (internal) |

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

## Quotio/Views/Screens/SettingsScreen.swift (3051 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 9 | struct | SettingsScreen | (internal) |
| 111 | struct | OperatingModeSection | (internal) |
| 176 | fn | handleModeSelection | (private) |
| 195 | fn | switchToMode | (private) |
| 210 | struct | RemoteServerSection | (internal) |
| 327 | fn | saveRemoteConfig | (private) |
| 335 | fn | reconnect | (private) |
| 350 | struct | UnifiedProxySettingsSection | (internal) |
| 573 | fn | loadConfig | (private) |
| 620 | fn | saveProxyURL | (private) |
| 638 | fn | saveRoutingStrategy | (private) |
| 647 | fn | saveSwitchProject | (private) |
| 656 | fn | saveSwitchPreviewModel | (private) |
| 665 | fn | saveRequestRetry | (private) |
| 674 | fn | saveMaxRetryInterval | (private) |
| 683 | fn | saveLoggingToFile | (private) |
| 692 | fn | saveRequestLog | (private) |
| 701 | fn | saveDebugMode | (private) |
| 714 | struct | LocalProxyServerSection | (internal) |
| 788 | struct | NetworkAccessSection | (internal) |
| 822 | struct | LocalPathsSection | (internal) |
| 846 | struct | PathLabel | (internal) |
| 870 | struct | NotificationSettingsSection | (internal) |
| 940 | struct | QuotaDisplaySettingsSection | (internal) |
| 982 | struct | RefreshCadenceSettingsSection | (internal) |
| 1021 | struct | UpdateSettingsSection | (internal) |
| 1063 | struct | ProxyUpdateSettingsSection | (internal) |
| 1223 | fn | checkForUpdate | (private) |
| 1237 | fn | performUpgrade | (private) |
| 1256 | struct | ProxyVersionManagerSheet | (internal) |
| 1415 | fn | sectionHeader | (private) |
| 1430 | fn | isVersionInstalled | (private) |
| 1434 | fn | refreshInstalledVersions | (private) |
| 1438 | fn | loadReleases | (private) |
| 1452 | fn | installVersion | (private) |
| 1470 | fn | performInstall | (private) |
| 1491 | fn | activateVersion | (private) |
| 1509 | fn | deleteVersion | (private) |
| 1522 | struct | InstalledVersionRow | (private) |
| 1580 | struct | AvailableVersionRow | (private) |
| 1666 | fn | formatDate | (private) |
| 1684 | struct | MenuBarSettingsSection | (internal) |
| 1825 | struct | AppearanceSettingsSection | (internal) |
| 1854 | struct | PrivacySettingsSection | (internal) |
| 1876 | struct | GeneralSettingsTab | (internal) |
| 1915 | struct | AboutTab | (internal) |
| 1942 | struct | AboutScreen | (internal) |
| 2157 | struct | AboutUpdateSection | (internal) |
| 2213 | struct | AboutProxyUpdateSection | (internal) |
| 2366 | fn | checkForUpdate | (private) |
| 2380 | fn | performUpgrade | (private) |
| 2399 | struct | VersionBadge | (internal) |
| 2451 | struct | AboutUpdateCard | (internal) |
| 2542 | struct | AboutProxyUpdateCard | (internal) |
| 2716 | fn | checkForUpdate | (private) |
| 2730 | fn | performUpgrade | (private) |
| 2749 | struct | LinkCard | (internal) |
| 2836 | struct | ManagementKeyRow | (internal) |
| 2930 | struct | LaunchAtLoginToggle | (internal) |
| 2988 | struct | UsageDisplaySettingsSection | (internal) |

