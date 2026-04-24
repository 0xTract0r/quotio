# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 4 large files in this module.

## Quotio/Models/CustomProviderModels.swift (510 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 14 | enum | CustomProviderType | (internal) |
| 148 | struct | CustomAPIKeyEntry | (internal) |
| 179 | struct | ModelMapping | (internal) |
| 206 | struct | CustomHeader | (internal) |
| 225 | struct | CustomProvider | (internal) |
| 275 | fn | validate | (internal) |
| 313 | mod | extension CustomProvider | (internal) |
| 315 | fn | toYAMLBlock | (internal) |
| 329 | fn | generateOpenAICompatibilityYAML | (private) |
| 358 | fn | generateClaudeCompatibilityYAML | (private) |
| 387 | fn | generateGeminiCompatibilityYAML | (private) |
| 415 | fn | generateCodexCompatibilityYAML | (private) |
| 432 | fn | generateGlmCompatibilityYAML | (private) |
| 462 | fn | toYAMLSections | (internal) |

## Quotio/Models/MenuBarSettings.swift (632 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 13 | mod | extension String | (internal) |
| 17 | fn | masked | (internal) |
| 38 | fn | masked | (internal) |
| 46 | struct | MenuBarQuotaItem | (internal) |
| 70 | enum | AppearanceMode | (internal) |
| 97 | class | AppearanceManager | (internal) |
| 112 | method | init | (private) |
| 119 | fn | applyAppearance | (internal) |
| 134 | enum | MenuBarColorMode | (internal) |
| 151 | enum | QuotaDisplayMode | (internal) |
| 165 | fn | displayValue | (internal) |
| 183 | enum | QuotaDisplayStyle | (internal) |
| 210 | enum | RefreshCadence | (internal) |
| 253 | enum | TotalUsageMode | (internal) |
| 270 | enum | ModelAggregationMode | (internal) |
| 286 | mod | extension MenuBarSettingsManager | (internal) |
| 334 | fn | calculateTotalUsagePercent | (internal) |
| 359 | fn | aggregateModelPercentages | (internal) |
| 376 | class | RefreshSettingsManager | (internal) |
| 394 | method | init | (private) |
| 404 | struct | MenuBarQuotaDisplayItem | (internal) |
| 423 | class | MenuBarSettingsManager | (internal) |
| 515 | method | init | (private) |
| 553 | fn | saveSelectedItems | (private) |
| 559 | fn | loadSelectedItems | (private) |
| 567 | fn | addItem | (internal) |
| 581 | fn | removeItem | (internal) |
| 587 | fn | isSelected | (internal) |
| 592 | fn | toggleItem | (internal) |
| 602 | fn | pruneInvalidItems | (internal) |
| 606 | fn | autoSelectNewAccounts | (internal) |
| 621 | fn | enforceMaxItems | (private) |
| 628 | fn | clampedMenuBarMax | (private) |

## Quotio/Models/Models.swift (1093 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 9 | enum | RuntimeProfile | (internal) |
| 32 | fn | applicationSupportDirectory | (internal) |
| 181 | fn | queueLabel | (internal) |
| 209 | fn | stringValue | (private) |
| 217 | fn | intValue | (private) |
| 222 | fn | boolValue | (private) |
| 238 | enum | AIProvider | (internal) |
| 489 | struct | ProxyStatus | (internal) |
| 500 | struct | AuthFile | (internal) |
| 618 | fn | hash | (internal) |
| 632 | struct | AuthFilesResponse | (internal) |
| 636 | struct | OAuthReauthHistoryFileSummary | (internal) |
| 656 | struct | OAuthReauthHistoryEvent | (internal) |
| 680 | struct | OAuthReauthHistoryResponse | (internal) |
| 693 | struct | APIKeysResponse | (internal) |
| 703 | struct | UsageStats | (internal) |
| 713 | struct | UsageData | (internal) |
| 770 | struct | UsageDaySnapshot | (internal) |
| 786 | struct | OAuthURLResponse | (internal) |
| 793 | struct | OAuthStatusResponse | (internal) |
| 814 | struct | OAuthCancelResponse | (internal) |
| 824 | struct | OAuthCallbackResponse | (internal) |
| 829 | struct | AuthFileStatusRefreshResponse | (internal) |
| 849 | struct | AppConfig | (internal) |
| 880 | struct | RoutingConfig | (internal) |
| 884 | struct | QuotaExceededConfig | (internal) |
| 894 | struct | RemoteManagementConfig | (internal) |
| 910 | struct | LogEntry | (internal) |
| 932 | enum | NavigationPage | (internal) |
| 964 | mod | extension Color | (internal) |
| 965 | method | init | (internal) |
| 982 | mod | extension Int | (internal) |
| 993 | mod | extension Double | (internal) |
| 1010 | enum | ProxyURLValidationResult | (internal) |
| 1041 | enum | ProxyURLValidator | (internal) |
| 1043 | fn | validate | (internal) |
| 1083 | fn | sanitize | (internal) |

## Quotio/Models/RequestLog.swift (522 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 13 | enum | FallbackAttemptOutcome | (internal) |
| 19 | enum | FallbackTriggerReason | (internal) |
| 39 | struct | FallbackAttempt | (internal) |
| 44 | method | init | (internal) |
| 51 | method | init | (internal) |
| 57 | struct | RequestIdentityEvidence | (internal) |
| 68 | struct | RequestLog | (internal) |
| 199 | fn | withRouteObservation | (internal) |
| 227 | struct | RequestRouteObservation | (internal) |
| 237 | struct | RequestStats | (internal) |
| 289 | struct | ProviderStats | (internal) |
| 302 | struct | ModelStats | (internal) |
| 318 | struct | RequestHistoryStore | (internal) |
| 347 | fn | calculateStats | (internal) |
| 440 | mod | extension RequestLog | (internal) |
| 512 | mod | extension Int | (internal) |

