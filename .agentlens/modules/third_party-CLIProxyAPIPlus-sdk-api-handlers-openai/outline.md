# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 3 large files in this module.

## third_party/CLIProxyAPIPlus/sdk/api/handlers/openai/openai_handlers.go (860 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 29 | struct | OpenAIAPIHandler | pub |
| 41 | fn | NewOpenAIAPIHandler | pub |
| 48 | fn | HandlerType | pub |
| 53 | fn | Models | pub |
| 62 | fn | OpenAIModels | pub |
| 99 | fn | ChatCompletions | pub |
| 151 | fn | shouldTreatAsResponsesFormat | (private) |
| 171 | fn | Completions | pub |
| 202 | fn | convertCompletionsRequestToChatCompletions | (private) |
| 266 | fn | convertResponsesObjectToChatCompletion | (private) |
| 282 | fn | wrapResponsesPayloadAsCompleted | (private) |
| 294 | fn | writeConvertedResponsesChunk | (private) |
| 304 | fn | forwardResponsesAsChatStream | (private) |
| 344 | fn | convertChatCompletionsResponseToCompletions | (private) |
| 418 | fn | convertChatCompletionsStreamChunkToCompletions | (private) |
| 517 | fn | handleNonStreamingResponse | (private) |
| 533 | fn | handleNonStreamingResponseViaResponses | (private) |
| 565 | fn | handleStreamingResponse | (private) |
| 634 | fn | handleStreamingResponseViaResponses | (private) |
| 704 | fn | handleCompletionsNonStreamingResponse | (private) |
| 733 | fn | handleCompletionsStreamingResponse | (private) |
| 836 | fn | handleStreamResult | (private) |

## third_party/CLIProxyAPIPlus/sdk/api/handlers/openai/openai_responses_websocket.go (951 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 52 | fn | ResponsesWebsocket | pub |
| 206 | fn | websocketUpgradeHeaders | (private) |
| 220 | fn | normalizeResponsesWebsocketRequest | (private) |
| 224 | fn | normalizeResponsesWebsocketRequestWithMode | (private) |
| 244 | fn | normalizeResponseCreateRequest | (private) |
| 264 | fn | normalizeResponseSubsequentRequest | (private) |
| 351 | fn | websocketUpstreamSupportsIncrementalInput | (private) |
| 380 | fn | websocketUpstreamSupportsIncrementalInputForModel | (private) |
| 449 | fn | responsesWebsocketAuthAvailableForModel | (private) |
| 480 | fn | shouldHandleResponsesWebsocketPrewarmLocally | (private) |
| 491 | fn | writeResponsesWebsocketSyntheticPrewarm | (private) |
| 525 | fn | syntheticResponsesWebsocketPrewarmPayloads | (private) |
| 566 | fn | mergeJSONArrayRaw | (private) |
| 593 | fn | normalizeJSONArrayRaw | (private) |
| 605 | fn | forwardResponsesWebsocket | (private) |
| 722 | fn | responseCompletedOutputFromPayload | (private) |
| 730 | fn | websocketJSONPayloadsFromChunk | (private) |
| 763 | fn | writeResponsesWebsocketError | (private) |
| 836 | fn | appendWebsocketEvent | (private) |
| 868 | fn | appendWebsocketLogString | (private) |
| 884 | fn | appendWebsocketLogBytes | (private) |
| 907 | fn | websocketPayloadEventType | (private) |
| 915 | fn | websocketPayloadPreview | (private) |
| 932 | fn | setWebsocketRequestBody | (private) |
| 943 | fn | markAPIResponseTimestamp | (private) |

## third_party/CLIProxyAPIPlus/sdk/api/handlers/openai/openai_responses_websocket_test.go (664 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 25 | struct | websocketCaptureExecutor | (private) |
| 30 | struct | orderedWebsocketSelector | (private) |
| 36 | fn | Pick | pub |
| 60 | struct | websocketAuthCaptureExecutor | (private) |
| 65 | fn | Identifier | pub |
| 67 | fn | Execute | pub |
| 71 | fn | ExecuteStream | pub |
| 84 | fn | Refresh | pub |
| 88 | fn | CountTokens | pub |
| 92 | fn | HttpRequest | pub |
| 96 | fn | AuthIDs | pub |
| 102 | fn | Identifier | pub |
| 104 | fn | Execute | pub |
| 108 | fn | ExecuteStream | pub |
| 117 | fn | Refresh | pub |
| 121 | fn | CountTokens | pub |
| 125 | fn | HttpRequest | pub |
| 129 | fn | TestNormalizeResponsesWebsocketRequestCreate | pub |
| 150 | fn | TestNormalizeResponsesWebsocketRequestCreateWithHistory | pub |
| 184 | fn | TestNormalizeResponsesWebsocketRequestWithPreviousResponseIDIncremental | pub |
| 220 | fn | TestNormalizeResponsesWebsocketRequestWithPreviousResponseIDMergedWhenIncrementalDisabled | pub |
| 250 | fn | TestNormalizeResponsesWebsocketRequestAppend | pub |
| 278 | fn | TestNormalizeResponsesWebsocketRequestAppendWithoutCreate | pub |
| 290 | fn | TestWebsocketJSONPayloadsFromChunk | pub |
| 302 | fn | TestWebsocketJSONPayloadsFromPlainJSONChunk | pub |
| 314 | fn | TestResponseCompletedOutputFromPayload | pub |
| 327 | fn | TestAppendWebsocketEvent | pub |
| 342 | fn | TestAppendWebsocketEventTruncatesAtLimit | pub |
| 357 | fn | TestAppendWebsocketEventNoGrowthAfterLimit | pub |
| 369 | fn | TestSetWebsocketRequestBody | pub |
| 393 | fn | TestForwardResponsesWebsocketPreservesCompletedEvent | pub |
| 469 | fn | TestWebsocketUpstreamSupportsIncrementalInputForModel | pub |
| 492 | fn | TestResponsesWebsocketPrewarmHandledLocallyForSSEUpstream | pub |
| 596 | fn | TestResponsesWebsocketPinsOnlyWebsocketCapableAuth | pub |

