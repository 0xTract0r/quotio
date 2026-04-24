# third_party/CLIProxyAPIPlus/internal/translator/kiro/openai/kiro_openai_request.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-translator-kiro-openai/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1009
- **Language:** Go
- **Symbols:** 37
- **Public symbols:** 18

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 24 | struct | KiroPayload | pub | - |
| 31 | struct | KiroInferenceConfig | pub | - |
| 38 | struct | KiroConversationState | pub | - |
| 48 | struct | KiroCurrentMessage | pub | - |
| 53 | struct | KiroHistoryMessage | pub | - |
| 59 | struct | KiroImage | pub | - |
| 65 | struct | KiroImageSource | pub | - |
| 70 | struct | KiroUserInputMessage | pub | - |
| 79 | struct | KiroUserInputMessageContext | pub | - |
| 85 | struct | KiroToolResult | pub | - |
| 92 | struct | KiroTextContent | pub | - |
| 97 | struct | KiroToolWrapper | pub | - |
| 102 | struct | KiroToolSpecification | pub | - |
| 109 | struct | KiroInputSchema | pub | - |
| 114 | struct | KiroAssistantResponseMessage | pub | - |
| 120 | struct | KiroToolUse | pub | - |
| 130 | fn | ConvertOpenAIRequestToKiro | pub | `func ConvertOpenAIRequestToKiro(modelName strin...` |
| 143 | fn | BuildKiroPayloadFromOpenAI | pub | `func BuildKiroPayloadFromOpenAI(openaiBody []by...` |
| 336 | fn | normalizeOrigin | (private) | `func normalizeOrigin(origin string) string {` |
| 353 | fn | extractMetadataFromMessages | (private) | `func extractMetadataFromMessages(messages gjson...` |
| 364 | fn | extractSystemPromptFromOpenAI | (private) | `func extractSystemPromptFromOpenAI(messages gjs...` |
| 392 | fn | shortenToolNameIfNeeded | (private) | `func shortenToolNameIfNeeded(name string) string {` |
| 411 | fn | ensureKiroInputSchema | (private) | `func ensureKiroInputSchema(parameters interface...` |
| 422 | fn | convertOpenAIToolsToKiro | (private) | `func convertOpenAIToolsToKiro(tools gjson.Resul...` |
| 483 | fn | processOpenAIMessages | (private) | `func processOpenAIMessages(messages gjson.Resul...` |
| 613 | const | kiroMaxHistoryMessages | (private) | - |
| 615 | fn | truncateHistoryIfNeeded | (private) | `func truncateHistoryIfNeeded(history []KiroHist...` |
| 624 | fn | filterOrphanedToolResults | (private) | `func filterOrphanedToolResults(history []KiroHi...` |
| 680 | fn | buildUserMessageFromOpenAI | (private) | `func buildUserMessageFromOpenAI(msg gjson.Resul...` |
| 735 | fn | buildAssistantMessageFromOpenAI | (private) | `func buildAssistantMessageFromOpenAI(msg gjson....` |
| 819 | fn | buildFinalContent | (private) | `func buildFinalContent(content, systemPrompt st...` |
| 850 | fn | checkThinkingModeFromOpenAI | (private) | `func checkThinkingModeFromOpenAI(openaiBody []b...` |
| 861 | fn | checkThinkingModeFromOpenAIWithHeaders | (private) | `func checkThinkingModeFromOpenAIWithHeaders(ope...` |
| 912 | fn | hasThinkingTagInBody | (private) | `func hasThinkingTagInBody(body []byte) bool {` |
| 923 | fn | extractToolChoiceHint | (private) | `func extractToolChoiceHint(openaiBody []byte) s...` |
| 962 | fn | extractResponseFormatHint | (private) | `func extractResponseFormatHint(openaiBody []byt...` |
| 993 | fn | deduplicateToolResults | (private) | `func deduplicateToolResults(toolResults []KiroT...` |

## Public API

### `ConvertOpenAIRequestToKiro`

```
func ConvertOpenAIRequestToKiro(modelName string, inputRawJSON []byte, stream bool) []byte {
```

**Line:** 130 | **Kind:** fn

### `BuildKiroPayloadFromOpenAI`

```
func BuildKiroPayloadFromOpenAI(openaiBody []byte, modelID, profileArn, origin string, isAgentic, isChatOnly bool, headers http.Header, metadata map[string]any) ([]byte, bool) {
```

**Line:** 143 | **Kind:** fn

## Memory Markers

### 🟢 `NOTE` (line 128)

> The actual payload building happens in the executor, this just passes through

### 🟢 `NOTE` (line 287)

> Kiro API doesn't actually use max_tokens for thinking budget

### 🟢 `NOTE` (line 933)

> When tool_choice is "none", we should ideally not pass tools at all

