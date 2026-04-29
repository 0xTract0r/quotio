# third_party/CLIProxyAPIPlus/sdk/api/handlers/openai/openai_responses_websocket.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-sdk-api-handlers-openai/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1031
- **Language:** Go
- **Symbols:** 31
- **Public symbols:** 1

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 49 | fn | ResponsesWebsocket | pub | `func (h *OpenAIResponsesAPIHandler) ResponsesWe...` |
| 203 | fn | websocketClientAddress | (private) | `func websocketClientAddress(c *gin.Context) str...` |
| 210 | fn | websocketUpgradeHeaders | (private) | `func websocketUpgradeHeaders(req *http.Request)...` |
| 224 | fn | normalizeResponsesWebsocketRequest | (private) | `func normalizeResponsesWebsocketRequest(rawJSON...` |
| 228 | fn | normalizeResponsesWebsocketRequestWithMode | (private) | `func normalizeResponsesWebsocketRequestWithMode...` |
| 248 | fn | normalizeResponseCreateRequest | (private) | `func normalizeResponseCreateRequest(rawJSON []b...` |
| 268 | fn | normalizeResponseSubsequentRequest | (private) | `func normalizeResponseSubsequentRequest(rawJSON...` |
| 368 | fn | shouldReplaceWebsocketTranscript | (private) | `func shouldReplaceWebsocketTranscript(rawJSON [...` |
| 395 | fn | normalizeResponseTranscriptReplacement | (private) | `func normalizeResponseTranscriptReplacement(raw...` |
| 417 | fn | dedupeFunctionCallsByCallID | (private) | `func dedupeFunctionCallsByCallID(rawArray strin...` |
| 453 | fn | websocketUpstreamSupportsIncrementalInput | (private) | `func websocketUpstreamSupportsIncrementalInput(...` |
| 482 | fn | websocketUpstreamSupportsIncrementalInputForModel | (private) | `func (h *OpenAIResponsesAPIHandler) websocketUp...` |
| 551 | fn | responsesWebsocketAuthAvailableForModel | (private) | `func responsesWebsocketAuthAvailableForModel(au...` |
| 582 | fn | shouldHandleResponsesWebsocketPrewarmLocally | (private) | `func shouldHandleResponsesWebsocketPrewarmLocal...` |
| 593 | fn | writeResponsesWebsocketSyntheticPrewarm | (private) | `func writeResponsesWebsocketSyntheticPrewarm(` |
| 626 | fn | syntheticResponsesWebsocketPrewarmPayloads | (private) | `func syntheticResponsesWebsocketPrewarmPayloads...` |
| 667 | fn | mergeJSONArrayRaw | (private) | `func mergeJSONArrayRaw(existingRaw, appendRaw s...` |
| 694 | fn | normalizeJSONArrayRaw | (private) | `func normalizeJSONArrayRaw(raw []byte) string {` |
| 706 | fn | forwardResponsesWebsocket | (private) | `func (h *OpenAIResponsesAPIHandler) forwardResp...` |
| 825 | fn | responseCompletedOutputFromPayload | (private) | `func responseCompletedOutputFromPayload(payload...` |
| 833 | fn | websocketJSONPayloadsFromChunk | (private) | `func websocketJSONPayloadsFromChunk(chunk []byt...` |
| 866 | fn | writeResponsesWebsocketError | (private) | `func writeResponsesWebsocketError(conn *websock...` |
| 939 | fn | appendWebsocketEvent | (private) | `func appendWebsocketEvent(builder *strings.Buil...` |
| 957 | fn | websocketPayloadEventType | (private) | `func websocketPayloadEventType(payload []byte) ...` |
| 965 | fn | websocketPayloadPreview | (private) | `func websocketPayloadPreview(payload []byte) st...` |
| 975 | fn | setWebsocketTimelineBody | (private) | `func setWebsocketTimelineBody(c *gin.Context, b...` |
| 979 | fn | setWebsocketBody | (private) | `func setWebsocketBody(c *gin.Context, key strin...` |
| 990 | fn | writeResponsesWebsocketPayload | (private) | `func writeResponsesWebsocketPayload(conn *webso...` |
| 995 | fn | appendWebsocketTimelineDisconnect | (private) | `func appendWebsocketTimelineDisconnect(builder ...` |
| 1002 | fn | appendWebsocketTimelineEvent | (private) | `func appendWebsocketTimelineEvent(builder *stri...` |
| 1023 | fn | markAPIResponseTimestamp | (private) | `func markAPIResponseTimestamp(c *gin.Context) {` |

## Public API

### `ResponsesWebsocket`

```
func (h *OpenAIResponsesAPIHandler) ResponsesWebsocket(c *gin.Context) {
```

**Line:** 49 | **Kind:** fn

