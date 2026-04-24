# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 2 large files in this module.

## third_party/CLIProxyAPIPlus/internal/registry/model_definitions.go (863 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 10 | struct | staticModelsJSON | (private) |
| 27 | fn | GetClaudeModels | pub |
| 32 | fn | GetGeminiModels | pub |
| 37 | fn | GetGeminiVertexModels | pub |
| 42 | fn | GetGeminiCLIModels | pub |
| 47 | fn | GetAIStudioModels | pub |
| 52 | fn | GetCodexFreeModels | pub |
| 57 | fn | GetCodexTeamModels | pub |
| 62 | fn | GetCodexPlusModels | pub |
| 67 | fn | GetCodexProModels | pub |
| 72 | fn | GetQwenModels | pub |
| 77 | fn | GetIFlowModels | pub |
| 82 | fn | GetKimiModels | pub |
| 87 | fn | GetAntigravityModels | pub |
| 92 | fn | cloneModelInfos | (private) |
| 120 | fn | GetStaticModelDefinitionsByChannel | pub |
| 158 | fn | LookupStaticModelInfo | pub |
| 193 | fn | GetGitHubCopilotModels | pub |
| 523 | fn | GetKiroModels | pub |
| 805 | fn | GetAmazonQModels | pub |

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

