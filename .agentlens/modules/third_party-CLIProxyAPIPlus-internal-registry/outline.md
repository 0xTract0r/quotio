# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 2 large files in this module.

## third_party/CLIProxyAPIPlus/internal/registry/model_definitions.go (920 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 9 | const | codexBuiltinImageModelID | (private) |
| 12 | struct | staticModelsJSON | (private) |
| 29 | fn | GetClaudeModels | pub |
| 34 | fn | GetGeminiModels | pub |
| 39 | fn | GetGeminiVertexModels | pub |
| 44 | fn | GetGeminiCLIModels | pub |
| 49 | fn | GetAIStudioModels | pub |
| 54 | fn | GetCodexFreeModels | pub |
| 59 | fn | GetCodexTeamModels | pub |
| 64 | fn | GetCodexPlusModels | pub |
| 69 | fn | GetCodexProModels | pub |
| 74 | fn | GetKimiModels | pub |
| 79 | fn | GetAntigravityModels | pub |
| 86 | fn | WithCodexBuiltins | pub |
| 90 | fn | codexBuiltinImageModelInfo | (private) |
| 102 | fn | upsertModelInfos | (private) |
| 149 | fn | cloneModelInfos | (private) |
| 177 | fn | GetStaticModelDefinitionsByChannel | pub |
| 215 | fn | LookupStaticModelInfo | pub |
| 250 | fn | GetGitHubCopilotModels | pub |
| 580 | fn | GetKiroModels | pub |
| 862 | fn | GetAmazonQModels | pub |

## third_party/CLIProxyAPIPlus/internal/registry/model_registry.go (1336 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 19 | struct | ModelInfo | pub |
| 67 | struct | availableModelsCacheEntry | (private) |
| 74 | struct | ThinkingSupport | pub |
| 89 | struct | ModelRegistration | pub |
| 108 | interface | ModelRegistryHook | pub |
| 114 | struct | ModelRegistry | pub |
| 137 | fn | GetGlobalRegistry | pub |
| 150 | fn | ensureAvailableModelsCacheLocked | (private) |
| 156 | fn | invalidateAvailableModelsCacheLocked | (private) |
| 164 | fn | LookupModelInfo | pub |
| 182 | fn | SetHook | pub |
| 191 | const | defaultModelRegistryHookTimeout | (private) |
| 192 | const | modelQuotaExceededWindow | (private) |
| 194 | fn | triggerModelsRegistered | (private) |
| 212 | fn | triggerModelsUnregistered | (private) |
| 234 | fn | RegisterClient | pub |
| 449 | fn | addModelRegistration | (private) |
| 490 | fn | removeModelRegistration | (private) |
| 525 | fn | cloneModelInfo | (private) |
| 552 | fn | cloneModelInfosUnique | (private) |
| 574 | fn | UnregisterClient | pub |
| 582 | fn | unregisterClientInternal | (private) |
| 642 | fn | SetModelQuotaExceeded | pub |
| 659 | fn | ClearModelQuotaExceeded | pub |
| 676 | fn | SuspendClientModel | pub |
| 708 | fn | ResumeClientModel | pub |
| 730 | fn | ClientSupportsModel | pub |
| 760 | fn | GetAvailableModels | pub |
| 788 | fn | buildAvailableModelsLocked | (private) |
| 837 | fn | cloneModelMaps | (private) |
| 853 | fn | cloneModelMapValue | (private) |
| 880 | fn | GetAvailableModelsByProvider | pub |
| 1004 | fn | GetModelCount | pub |
| 1037 | fn | GetModelProviders | pub |
| 1089 | fn | GetModelInfo | pub |
| 1110 | fn | convertModelToMap | (private) |
| 1235 | fn | CleanupExpiredQuotas | pub |
| 1266 | fn | GetFirstAvailableModel | pub |
| 1303 | fn | GetModelsForClient | pub |

