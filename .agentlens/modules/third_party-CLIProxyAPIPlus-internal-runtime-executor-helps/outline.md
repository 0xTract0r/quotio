# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 2 large files in this module.

## third_party/CLIProxyAPIPlus/internal/runtime/executor/helps/logging_helpers.go (592 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 31 | struct | UpstreamRequestLog | pub |
| 43 | struct | upstreamAttempt | (private) |
| 57 | fn | RecordAPIRequest | pub |
| 104 | fn | RecordAPIResponseMetadata | pub |
| 130 | fn | RecordAPIResponseError | pub |
| 155 | fn | AppendAPIResponseChunk | pub |
| 197 | fn | RecordAPIWebsocketRequest | pub |
| 229 | fn | RecordAPIWebsocketHandshake | pub |
| 252 | fn | RecordAPIWebsocketUpgradeRejection | pub |
| 267 | fn | WebsocketUpgradeRequestURL | pub |
| 286 | fn | AppendAPIWebsocketResponse | pub |
| 310 | fn | RecordAPIWebsocketError | pub |
| 331 | fn | ginContextFrom | (private) |
| 336 | fn | getAttempts | (private) |
| 348 | fn | ensureAttempt | (private) |
| 363 | fn | ensureResponseIntro | (private) |
| 373 | fn | updateAggregatedRequest | (private) |
| 384 | fn | updateAggregatedResponse | (private) |
| 408 | fn | appendAPIWebsocketTimeline | (private) |
| 432 | fn | markAPIResponseTimestamp | (private) |
| 442 | fn | writeHeaders | (private) |
| 468 | fn | formatAuthInfo | (private) |
| 504 | fn | SummarizeErrorBody | pub |
| 527 | fn | extractHTMLTitle | (private) |
| 552 | fn | extractJSONErrorMessage | (private) |
| 562 | fn | LogWithRequestID | pub |
| 574 | fn | MarkCreditsUsed | pub |
| 582 | fn | CreditsUsed | pub |

## third_party/CLIProxyAPIPlus/internal/runtime/executor/helps/usage_helpers.go (616 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 18 | struct | usageReporter | (private) |
| 29 | fn | newUsageReporter | (private) |
| 45 | fn | publish | (private) |
| 49 | fn | publishFailure | (private) |
| 53 | fn | trackFailure | (private) |
| 62 | fn | publishWithOutcome | (private) |
| 81 | fn | ensurePublished | (private) |
| 90 | fn | buildRecord | (private) |
| 108 | fn | latency | (private) |
| 119 | fn | apiKeyFromContext | (private) |
| 140 | fn | resolveUsageSource | (private) |
| 184 | fn | parseCodexUsage | (private) |
| 204 | fn | parseOpenAIUsage | (private) |
| 240 | fn | parseOpenAIStreamUsage | (private) |
| 264 | fn | parseOpenAIResponsesUsageDetail | (private) |
| 283 | fn | parseOpenAIResponsesUsage | (private) |
| 291 | fn | parseOpenAIResponsesStreamUsage | (private) |
| 303 | fn | parseClaudeUsage | (private) |
| 322 | fn | parseClaudeStreamUsage | (private) |
| 345 | fn | parseGeminiFamilyUsageDetail | (private) |
| 360 | fn | parseGeminiCLIUsage | (private) |
| 372 | fn | parseGeminiUsage | (private) |
| 384 | fn | parseGeminiStreamUsage | (private) |
| 399 | fn | parseGeminiCLIStreamUsage | (private) |
| 414 | fn | parseAntigravityUsage | (private) |
| 429 | fn | parseAntigravityStreamUsage | (private) |
| 449 | fn | rememberStopWithoutUsage | (private) |
| 457 | fn | FilterSSEUsageMetadata | pub |
| 521 | fn | StripUsageMetadataFromJSON | pub |
| 570 | fn | hasUsageMetadata | (private) |
| 583 | fn | isStopChunkWithoutUsage | (private) |
| 598 | fn | jsonPayload | (private) |

