# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 11 large files in this module.

## third_party/Cli-Proxy-API-Management-Center/src/pages/AiProvidersAmpcodeEditPage.tsx (538 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 25 | type | LocationState | (private) |
| 27 | fn | getErrorMessage | (private) |
| 33 | fn | normalizeMappingEntries | (private) |
| 42 | type | AmpcodeFormBaseline | (private) |
| 58 | fn | areUpstreamApiKeysEqual | (private) |
| 74 | fn | areModelMappingsEqual | (private) |
| 89 | fn | AiProvidersAmpcodeEditPage | pub |
| 126 | fn | handleKeyDown | (private) |
| 214 | fn | clearAmpcodeUpstreamApiKey | (private) |
| 244 | fn | performSaveAmpcode | (private) |
| 328 | fn | saveAmpcode | (private) |

## third_party/Cli-Proxy-API-Management-Center/src/pages/AiProvidersClaudeEditPage.tsx (587 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 24 | fn | getErrorMessage | (private) |
| 30 | fn | hasHeader | (private) |
| 44 | fn | AiProvidersClaudeEditPage | pub |
| 77 | fn | handleKeyDown | (private) |
| 153 | fn | openClaudeModelDiscovery | (private) |

## third_party/Cli-Proxy-API-Management-Center/src/pages/AiProvidersCodexEditPage.tsx (817 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 27 | type | LocationState | (private) |
| 43 | fn | parseIndexParam | (private) |
| 49 | fn | getErrorMessage | (private) |
| 55 | fn | normalizeModelEntries | (private) |
| 67 | type | CodexFormBaseline | (private) |
| 92 | fn | AiProvidersCodexEditPage | pub |
| 151 | fn | handleKeyDown | (private) |
| 401 | fn | toggleModelDiscoverySelection | (private) |
| 425 | fn | handleApplyDiscoveredModels | (private) |

## third_party/Cli-Proxy-API-Management-Center/src/pages/AiProvidersGeminiEditPage.tsx (806 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 26 | type | LocationState | (private) |
| 40 | fn | parseIndexParam | (private) |
| 46 | fn | stripGeminiModelResourceName | (private) |
| 52 | fn | normalizeModelEntries | (private) |
| 64 | type | GeminiFormBaseline | (private) |
| 87 | fn | AiProvidersGeminiEditPage | pub |
| 146 | fn | handleKeyDown | (private) |
| 354 | fn | toggleModelDiscoverySelection | (private) |
| 378 | fn | handleApplyDiscoveredModels | (private) |

## third_party/Cli-Proxy-API-Management-Center/src/pages/AiProvidersOpenAIEditLayout.tsx (549 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 17 | type | LocationState | (private) |
| 19 | type | OpenAIEditOutletContext | pub |
| 55 | fn | parseIndexParam | (private) |
| 61 | fn | getErrorMessage | (private) |
| 67 | fn | normalizeModelEntries | (private) |
| 79 | fn | normalizeKeyHeaders | (private) |
| 91 | fn | normalizeApiKeyEntries | (private) |
| 119 | fn | areNormalizedApiKeyEntriesEqual | (private) |
| 135 | fn | AiProvidersOpenAIEditLayout | pub |

## third_party/Cli-Proxy-API-Management-Center/src/pages/AiProvidersOpenAIEditPage.tsx (698 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 24 | fn | getErrorMessage | (private) |
| 31 | fn | StatusLoadingIcon | (private) |
| 45 | fn | StatusSuccessIcon | (private) |
| 60 | fn | StatusErrorIcon | (private) |
| 75 | fn | StatusIdleIcon | (private) |
| 83 | fn | StatusIcon | (private) |
| 96 | fn | AiProvidersOpenAIEditPage | pub |
| 131 | fn | handleKeyDown | (private) |
| 361 | fn | openOpenaiModelDiscovery | (private) |
| 370 | fn | renderKeyEntries | (private) |
| 373 | fn | updateEntry | (private) |
| 381 | fn | removeEntry | (private) |
| 393 | fn | addEntry | (private) |

## third_party/Cli-Proxy-API-Management-Center/src/pages/AuthFilesPage.tsx (1104 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 69 | fn | easePower3Out | (private) |
| 70 | fn | easePower2In | (private) |
| 78 | fn | escapeWildcardSearchSegment | (private) |
| 87 | fn | AuthFilesPage | pub |
| 313 | fn | commitPageSizeInput | (private) |
| 332 | fn | handlePageSizeChange | (private) |
| 426 | fn | handleVisibilityChange | (private) |
| 431 | fn | handleWindowFocus | (private) |
| 621 | fn | updatePadding | (private) |
| 702 | fn | renderFilterTags | (private) |

## third_party/Cli-Proxy-API-Management-Center/src/pages/ConfigPage.tsx (655 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 24 | type | ConfigEditorTab | (private) |
| 28 | fn | readCommercialModeFromYaml | (private) |
| 38 | fn | ConfigPage | pub |
| 126 | fn | handleConfirmSave | (private) |
| 171 | fn | handleSave | (private) |
| 389 | fn | updatePadding | (private) |
| 408 | fn | getStatusText | (private) |
| 420 | fn | getStatusClass | (private) |
| 427 | fn | getFloatingStatusText | (private) |

## third_party/Cli-Proxy-API-Management-Center/src/pages/LogsPage.tsx (1117 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 43 | interface | ErrorLogItem | (private) |
| 65 | type | TabType | (private) |
| 67 | fn | LogsPage | pub |
| 118 | fn | loadLogs | (private) |
| 198 | fn | clearLogs | (private) |
| 221 | fn | downloadLogs | (private) |
| 227 | fn | loadErrorLogs | (private) |
| 251 | fn | downloadErrorLog | (private) |
| 376 | fn | copyLogLine | (private) |
| 385 | fn | clearLongPressTimer | (private) |
| 392 | fn | startLongPress | (private) |
| 411 | fn | cancelLongPress | (private) |
| 416 | fn | handleLongPressMove | (private) |
| 426 | fn | closeRequestLogModal | (private) |
| 431 | fn | downloadRequestLog | (private) |

## third_party/Cli-Proxy-API-Management-Center/src/pages/OAuthPage.tsx (647 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 25 | interface | ProviderState | (private) |
| 39 | interface | IFlowCookieState | (private) |
| 47 | interface | VertexImportResult | (private) |
| 54 | interface | VertexImportState | (private) |
| 63 | fn | isRecord | (private) |
| 67 | fn | getErrorMessage | (private) |
| 73 | fn | getErrorStatus | (private) |
| 88 | fn | getProviderI18nPrefix | (private) |
| 89 | fn | getAuthKey | (private) |
| 92 | fn | getIcon | (private) |
| 96 | fn | OAuthPage | pub |
| 121 | fn | updateProviderState | (private) |
| 128 | fn | startPolling | (private) |
| 174 | fn | startAuth | (private) |
| 213 | fn | copyLink | (private) |
| 222 | fn | submitCallback | (private) |
| 258 | fn | submitIflowCookie | (private) |
| 301 | fn | handleVertexFilePick | (private) |
| 305 | fn | handleVertexFileChange | (private) |
| 323 | fn | handleVertexImport | (private) |

## third_party/Cli-Proxy-API-Management-Center/src/pages/SystemPage.tsx (556 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 45 | fn | parseVersionSegments | (private) |
| 57 | fn | compareVersions | (private) |
| 71 | fn | SystemPage | pub |
| 171 | fn | fetchModels | (private) |
| 209 | fn | handleClearLoginStorage | (private) |
| 255 | fn | handleRequestLogSave | (private) |

