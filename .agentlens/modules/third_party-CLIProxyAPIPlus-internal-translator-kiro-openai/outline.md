# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 1 large files in this module.

## third_party/CLIProxyAPIPlus/internal/translator/kiro/openai/kiro_openai_request.go (1009 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 24 | struct | KiroPayload | pub |
| 31 | struct | KiroInferenceConfig | pub |
| 38 | struct | KiroConversationState | pub |
| 48 | struct | KiroCurrentMessage | pub |
| 53 | struct | KiroHistoryMessage | pub |
| 59 | struct | KiroImage | pub |
| 65 | struct | KiroImageSource | pub |
| 70 | struct | KiroUserInputMessage | pub |
| 79 | struct | KiroUserInputMessageContext | pub |
| 85 | struct | KiroToolResult | pub |
| 92 | struct | KiroTextContent | pub |
| 97 | struct | KiroToolWrapper | pub |
| 102 | struct | KiroToolSpecification | pub |
| 109 | struct | KiroInputSchema | pub |
| 114 | struct | KiroAssistantResponseMessage | pub |
| 120 | struct | KiroToolUse | pub |
| 130 | fn | ConvertOpenAIRequestToKiro | pub |
| 143 | fn | BuildKiroPayloadFromOpenAI | pub |
| 336 | fn | normalizeOrigin | (private) |
| 353 | fn | extractMetadataFromMessages | (private) |
| 364 | fn | extractSystemPromptFromOpenAI | (private) |
| 392 | fn | shortenToolNameIfNeeded | (private) |
| 411 | fn | ensureKiroInputSchema | (private) |
| 422 | fn | convertOpenAIToolsToKiro | (private) |
| 483 | fn | processOpenAIMessages | (private) |
| 613 | const | kiroMaxHistoryMessages | (private) |
| 615 | fn | truncateHistoryIfNeeded | (private) |
| 624 | fn | filterOrphanedToolResults | (private) |
| 680 | fn | buildUserMessageFromOpenAI | (private) |
| 735 | fn | buildAssistantMessageFromOpenAI | (private) |
| 819 | fn | buildFinalContent | (private) |
| 850 | fn | checkThinkingModeFromOpenAI | (private) |
| 861 | fn | checkThinkingModeFromOpenAIWithHeaders | (private) |
| 912 | fn | hasThinkingTagInBody | (private) |
| 923 | fn | extractToolChoiceHint | (private) |
| 962 | fn | extractResponseFormatHint | (private) |
| 993 | fn | deduplicateToolResults | (private) |

