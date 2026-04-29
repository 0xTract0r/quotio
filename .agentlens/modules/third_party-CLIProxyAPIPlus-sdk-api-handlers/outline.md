# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 2 large files in this module.

## third_party/CLIProxyAPIPlus/sdk/api/handlers/handlers.go (970 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 30 | struct | ErrorResponse | pub |
| 37 | struct | ErrorDetail | pub |
| 48 | const | idempotencyKeyMetadataKey | (private) |
| 55 | struct | pinnedAuthContextKey | (private) |
| 56 | struct | selectedAuthCallbackContextKey | (private) |
| 57 | struct | executionSessionContextKey | (private) |
| 60 | fn | WithPinnedAuthID | pub |
| 72 | fn | WithSelectedAuthIDCallback | pub |
| 83 | fn | WithExecutionSessionID | pub |
| 96 | fn | BuildErrorResponseBody | pub |
| 146 | fn | StreamingKeepAliveInterval | pub |
| 159 | fn | NonStreamingKeepAliveInterval | pub |
| 171 | fn | StreamingBootstrapRetries | pub |
| 184 | fn | PassthroughHeadersEnabled | pub |
| 188 | fn | requestExecutionMetadata | (private) |
| 214 | fn | pinnedAuthIDFromContext | (private) |
| 229 | fn | selectedAuthIDCallbackFromContext | (private) |
| 240 | fn | executionSessionIDFromContext | (private) |
| 258 | struct | BaseAPIHandler | pub |
| 275 | fn | NewBaseAPIHandlers | pub |
| 289 | fn | UpdateClients | pub |
| 299 | fn | GetAlt | pub |
| 324 | fn | GetContextWithCancel | pub |
| 398 | fn | StartNonStreamingKeepAlive | pub |
| 444 | fn | appendAPIResponse | (private) |
| 472 | fn | ExecuteWithAuthManager | pub |
| 519 | fn | ExecuteCountWithAuthManager | pub |
| 567 | fn | ExecuteStreamWithAuthManager | pub |
| 741 | fn | validateSSEDataJSON | (private) |
| 770 | fn | statusFromError | (private) |
| 782 | fn | getRequestDetails | (private) |
| 825 | fn | cloneBytes | (private) |
| 834 | fn | cloneHeader | (private) |
| 845 | fn | replaceHeader | (private) |
| 854 | fn | enrichAuthSelectionError | (private) |
| 903 | fn | WriteErrorResponse | pub |
| 952 | fn | LoggingAPIResponseError | pub |

## third_party/CLIProxyAPIPlus/sdk/api/handlers/handlers_stream_bootstrap_test.go (763 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 18 | struct | failOnceStreamExecutor | (private) |
| 23 | fn | Identifier | pub |
| 25 | fn | Execute | pub |
| 29 | fn | ExecuteStream | pub |
| 60 | fn | Refresh | pub |
| 64 | fn | CountTokens | pub |
| 68 | fn | HttpRequest | pub |
| 76 | fn | Calls | pub |
| 82 | struct | payloadThenErrorStreamExecutor | (private) |
| 87 | fn | Identifier | pub |
| 89 | fn | Execute | pub |
| 93 | fn | ExecuteStream | pub |
| 112 | fn | Refresh | pub |
| 116 | fn | CountTokens | pub |
| 120 | fn | HttpRequest | pub |
| 128 | fn | Calls | pub |
| 134 | struct | authAwareStreamExecutor | (private) |
| 140 | struct | invalidJSONStreamExecutor | (private) |
| 142 | struct | splitResponsesEventStreamExecutor | (private) |
| 144 | fn | Identifier | pub |
| 146 | fn | Execute | pub |
| 150 | fn | ExecuteStream | pub |
| 157 | fn | Refresh | pub |
| 161 | fn | CountTokens | pub |
| 165 | fn | HttpRequest | pub |
| 173 | fn | Identifier | pub |
| 175 | fn | Execute | pub |
| 179 | fn | ExecuteStream | pub |
| 187 | fn | Refresh | pub |
| 191 | fn | CountTokens | pub |
| 195 | fn | HttpRequest | pub |
| 203 | fn | Identifier | pub |
| 205 | fn | Execute | pub |
| 209 | fn | ExecuteStream | pub |
| 243 | fn | Refresh | pub |
| 247 | fn | CountTokens | pub |
| 251 | fn | HttpRequest | pub |
| 259 | fn | Calls | pub |
| 265 | fn | AuthIDs | pub |
| 273 | fn | TestExecuteStreamWithAuthManager_RetriesBeforeFirstByte | pub |
| 339 | fn | TestExecuteStreamWithAuthManager_HeaderPassthroughDisabledByDefault | pub |
| 399 | fn | TestExecuteStreamWithAuthManager_DoesNotRetryAfterFirstByte | pub |
| 469 | fn | TestExecuteStreamWithAuthManager_EnrichesBootstrapRetryAuthUnavailableError | pub |
| 539 | fn | TestExecuteStreamWithAuthManager_PinnedAuthKeepsSameUpstream | pub |
| 611 | fn | TestExecuteStreamWithAuthManager_SelectedAuthCallbackReceivesAuthID | pub |
| 664 | fn | TestExecuteStreamWithAuthManager_ValidatesOpenAIResponsesStreamDataJSON | pub |
| 716 | fn | TestExecuteStreamWithAuthManager_AllowsSplitOpenAIResponsesSSEEventLines | pub |

