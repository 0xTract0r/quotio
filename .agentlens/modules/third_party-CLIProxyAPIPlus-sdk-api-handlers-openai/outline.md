# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 4 large files in this module.

## third_party/CLIProxyAPIPlus/sdk/api/handlers/openai/openai_handlers.go (864 lines)

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
| 306 | fn | forwardResponsesAsChatStream | (private) |
| 348 | fn | convertChatCompletionsResponseToCompletions | (private) |
| 422 | fn | convertChatCompletionsStreamChunkToCompletions | (private) |
| 521 | fn | handleNonStreamingResponse | (private) |
| 537 | fn | handleNonStreamingResponseViaResponses | (private) |
| 569 | fn | handleStreamingResponse | (private) |
| 638 | fn | handleStreamingResponseViaResponses | (private) |
| 708 | fn | handleCompletionsNonStreamingResponse | (private) |
| 737 | fn | handleCompletionsStreamingResponse | (private) |
| 840 | fn | handleStreamResult | (private) |

## third_party/CLIProxyAPIPlus/sdk/api/handlers/openai/openai_images_handlers.go (896 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 29 | struct | imageCallResult | (private) |
| 38 | struct | sseFrameAccumulator | (private) |
| 42 | fn | AddChunk | pub |
| 75 | fn | Flush | pub |
| 102 | fn | mimeTypeFromOutputFormat | (private) |
| 121 | fn | multipartFileToDataURL | (private) |
| 149 | fn | parseIntField | (private) |
| 161 | fn | parseBoolField | (private) |
| 176 | fn | ImagesGenerations | pub |
| 255 | fn | ImagesEdits | pub |
| 274 | fn | imagesEditsFromMultipart | (private) |
| 394 | fn | imagesEditsFromJSON | (private) |
| 500 | fn | buildImagesResponsesRequest | (private) |
| 526 | fn | collectImagesFromResponses | (private) |
| 550 | fn | collectImagesFromResponsesStream | (private) |
| 621 | fn | extractImagesFromResponsesCompleted | (private) |
| 663 | fn | buildImagesAPIResponse | (private) |
| 706 | fn | streamImagesFromResponses | (private) |
| 773 | fn | forwardImagesStream | (private) |

## third_party/CLIProxyAPIPlus/sdk/api/handlers/openai/openai_responses_websocket.go (1031 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 49 | fn | ResponsesWebsocket | pub |
| 203 | fn | websocketClientAddress | (private) |
| 210 | fn | websocketUpgradeHeaders | (private) |
| 224 | fn | normalizeResponsesWebsocketRequest | (private) |
| 228 | fn | normalizeResponsesWebsocketRequestWithMode | (private) |
| 248 | fn | normalizeResponseCreateRequest | (private) |
| 268 | fn | normalizeResponseSubsequentRequest | (private) |
| 368 | fn | shouldReplaceWebsocketTranscript | (private) |
| 395 | fn | normalizeResponseTranscriptReplacement | (private) |
| 417 | fn | dedupeFunctionCallsByCallID | (private) |
| 453 | fn | websocketUpstreamSupportsIncrementalInput | (private) |
| 482 | fn | websocketUpstreamSupportsIncrementalInputForModel | (private) |
| 551 | fn | responsesWebsocketAuthAvailableForModel | (private) |
| 582 | fn | shouldHandleResponsesWebsocketPrewarmLocally | (private) |
| 593 | fn | writeResponsesWebsocketSyntheticPrewarm | (private) |
| 626 | fn | syntheticResponsesWebsocketPrewarmPayloads | (private) |
| 667 | fn | mergeJSONArrayRaw | (private) |
| 694 | fn | normalizeJSONArrayRaw | (private) |
| 706 | fn | forwardResponsesWebsocket | (private) |
| 825 | fn | responseCompletedOutputFromPayload | (private) |
| 833 | fn | websocketJSONPayloadsFromChunk | (private) |
| 866 | fn | writeResponsesWebsocketError | (private) |
| 939 | fn | appendWebsocketEvent | (private) |
| 957 | fn | websocketPayloadEventType | (private) |
| 965 | fn | websocketPayloadPreview | (private) |
| 975 | fn | setWebsocketTimelineBody | (private) |
| 979 | fn | setWebsocketBody | (private) |
| 990 | fn | writeResponsesWebsocketPayload | (private) |
| 995 | fn | appendWebsocketTimelineDisconnect | (private) |
| 1002 | fn | appendWebsocketTimelineEvent | (private) |
| 1023 | fn | markAPIResponseTimestamp | (private) |

## third_party/CLIProxyAPIPlus/sdk/api/handlers/openai/openai_responses_websocket_test.go (1402 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 26 | struct | websocketCaptureExecutor | (private) |
| 31 | struct | websocketCompactionCaptureExecutor | (private) |
| 37 | struct | orderedWebsocketSelector | (private) |
| 43 | fn | Pick | pub |
| 67 | struct | websocketAuthCaptureExecutor | (private) |
| 72 | fn | Identifier | pub |
| 74 | fn | Execute | pub |
| 78 | fn | ExecuteStream | pub |
| 91 | fn | Refresh | pub |
| 95 | fn | CountTokens | pub |
| 99 | fn | HttpRequest | pub |
| 103 | fn | AuthIDs | pub |
| 109 | fn | Identifier | pub |
| 111 | fn | Execute | pub |
| 115 | fn | ExecuteStream | pub |
| 124 | fn | Refresh | pub |
| 128 | fn | CountTokens | pub |
| 132 | fn | HttpRequest | pub |
| 136 | fn | Identifier | pub |
| 138 | fn | Execute | pub |
| 148 | fn | ExecuteStream | pub |
| 170 | fn | Refresh | pub |
| 174 | fn | CountTokens | pub |
| 178 | fn | HttpRequest | pub |
| 182 | fn | TestNormalizeResponsesWebsocketRequestCreate | pub |
| 203 | fn | TestNormalizeResponsesWebsocketRequestCreateWithHistory | pub |
| 237 | fn | TestNormalizeResponsesWebsocketRequestWithPreviousResponseIDIncremental | pub |
| 273 | fn | TestNormalizeResponsesWebsocketRequestWithPreviousResponseIDMergedWhenIncrementalDisabled | pub |
| 303 | fn | TestNormalizeResponsesWebsocketRequestAppend | pub |
| 331 | fn | TestNormalizeResponsesWebsocketRequestAppendWithoutCreate | pub |
| 343 | fn | TestWebsocketJSONPayloadsFromChunk | pub |
| 355 | fn | TestWebsocketJSONPayloadsFromPlainJSONChunk | pub |
| 367 | fn | TestResponseCompletedOutputFromPayload | pub |
| 380 | fn | TestAppendWebsocketEvent | pub |
| 395 | fn | TestAppendWebsocketTimelineEvent | pub |
| 413 | fn | TestSetWebsocketTimelineBody | pub |
| 437 | fn | TestRepairResponsesWebsocketToolCallsInsertsCachedOutput | pub |
| 465 | fn | TestRepairResponsesWebsocketToolCallsDropsOrphanFunctionCall | pub |
| 481 | fn | TestRepairResponsesWebsocketToolCallsInsertsCachedCallForOrphanOutput | pub |
| 506 | fn | TestRepairResponsesWebsocketToolCallsDropsOrphanOutputWhenCallMissing | pub |
| 523 | fn | TestRepairResponsesWebsocketToolCallsInsertsCachedCustomToolOutput | pub |
| 551 | fn | TestRepairResponsesWebsocketToolCallsDropsOrphanCustomToolCall | pub |
| 567 | fn | TestRepairResponsesWebsocketToolCallsInsertsCachedCustomToolCallForOrphanOutput | pub |
| 592 | fn | TestRepairResponsesWebsocketToolCallsDropsOrphanCustomToolOutputWhenCallMissing | pub |
| 609 | fn | TestRecordResponsesWebsocketToolCallsFromPayloadWithCache | pub |
| 625 | fn | TestRecordResponsesWebsocketCustomToolCallsFromCompletedPayloadWithCache | pub |
| 641 | fn | TestRecordResponsesWebsocketCustomToolCallsFromOutputItemDoneWithCache | pub |
| 657 | fn | TestForwardResponsesWebsocketPreservesCompletedEvent | pub |
| 737 | fn | TestForwardResponsesWebsocketLogsAttemptedResponseOnWriteFailure | pub |
| 802 | fn | TestResponsesWebsocketTimelineRecordsDisconnectEvent | pub |
| 847 | fn | TestWebsocketUpstreamSupportsIncrementalInputForModel | pub |
| 870 | fn | TestResponsesWebsocketPrewarmHandledLocallyForSSEUpstream | pub |
| 974 | fn | TestWebsocketClientAddressUsesGinClientIP | pub |
| 993 | fn | TestWebsocketClientAddressReturnsEmptyForNilContext | pub |
| 999 | fn | TestResponsesWebsocketPinsOnlyWebsocketCapableAuth | pub |
| 1069 | fn | TestNormalizeResponsesWebsocketRequestTreatsTranscriptReplacementAsReset | pub |
| 1095 | fn | TestNormalizeResponsesWebsocketRequestDoesNotTreatDeveloperMessageAsReplacement | pub |
| 1121 | fn | TestNormalizeResponsesWebsocketRequestDropsDuplicateFunctionCallsByCallID | pub |
| 1144 | fn | TestNormalizeResponsesWebsocketRequestTreatsCustomToolTranscriptReplacementAsReset | pub |
| 1172 | fn | TestNormalizeResponsesWebsocketRequestDropsDuplicateCustomToolCallsByCallID | pub |
| 1195 | fn | TestResponsesWebsocketCompactionResetsTurnStateOnCustomToolTranscriptReplacement | pub |
| 1299 | fn | TestResponsesWebsocketCompactionResetsTurnStateOnTranscriptReplacement | pub |

