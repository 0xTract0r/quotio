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

## Quotio/Models/Models.swift (1357 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 9 | enum | RuntimeProfile | (internal) |
| 32 | fn | applicationSupportDirectory | (internal) |
| 209 | fn | queueLabel | (internal) |
| 246 | fn | sanitizedStorageComponent | (private) |
| 255 | fn | stringValue | (private) |
| 263 | fn | intValue | (private) |
| 268 | fn | boolValue | (private) |
| 284 | enum | AIProvider | (internal) |
| 535 | struct | ProxyStatus | (internal) |
| 545 | fn | trimmedAccountSettingsString | (private) |
| 554 | struct | AuthFileAccountSettingsProfile | (internal) |
| 569 | method | init | (internal) |
| 603 | fn | encode | (internal) |
| 618 | struct | AuthFileAccountSettingsActivation | (internal) |
| 635 | method | init | (internal) |
| 681 | fn | encode | (internal) |
| 698 | struct | AuthFileAccountSettings | (internal) |
| 720 | method | init | (internal) |
| 754 | struct | AuthFile | (internal) |
| 882 | fn | hash | (internal) |
| 896 | struct | AuthFilesResponse | (internal) |
| 900 | struct | OAuthReauthHistoryFileSummary | (internal) |
| 920 | struct | OAuthReauthHistoryEvent | (internal) |
| 944 | struct | OAuthReauthHistoryResponse | (internal) |
| 957 | struct | APIKeysResponse | (internal) |
| 967 | struct | UsageStats | (internal) |
| 977 | struct | UsageData | (internal) |
| 1034 | struct | UsageDaySnapshot | (internal) |
| 1050 | struct | OAuthURLResponse | (internal) |
| 1057 | struct | OAuthStatusResponse | (internal) |
| 1078 | struct | OAuthCancelResponse | (internal) |
| 1088 | struct | OAuthCallbackResponse | (internal) |
| 1093 | struct | AuthFileStatusRefreshResponse | (internal) |
| 1113 | struct | AppConfig | (internal) |
| 1144 | struct | RoutingConfig | (internal) |
| 1148 | struct | QuotaExceededConfig | (internal) |
| 1158 | struct | RemoteManagementConfig | (internal) |
| 1174 | struct | LogEntry | (internal) |
| 1196 | enum | NavigationPage | (internal) |
| 1228 | mod | extension Color | (internal) |
| 1229 | method | init | (internal) |
| 1246 | mod | extension Int | (internal) |
| 1257 | mod | extension Double | (internal) |
| 1274 | enum | ProxyURLValidationResult | (internal) |
| 1305 | enum | ProxyURLValidator | (internal) |
| 1307 | fn | validate | (internal) |
| 1347 | fn | sanitize | (internal) |

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

