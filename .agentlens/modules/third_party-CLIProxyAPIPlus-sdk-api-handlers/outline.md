# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 2 large files in this module.

## third_party/CLIProxyAPIPlus/sdk/api/handlers/handlers.go (911 lines)

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
| 397 | fn | StartNonStreamingKeepAlive | pub |
| 443 | fn | appendAPIResponse | (private) |
| 471 | fn | ExecuteWithAuthManager | pub |
| 517 | fn | ExecuteCountWithAuthManager | pub |
| 564 | fn | ExecuteStreamWithAuthManager | pub |
| 737 | fn | validateSSEDataJSON | (private) |
| 766 | fn | statusFromError | (private) |
| 778 | fn | getRequestDetails | (private) |
| 814 | fn | cloneBytes | (private) |
| 823 | fn | cloneHeader | (private) |
| 834 | fn | replaceHeader | (private) |
| 844 | fn | WriteErrorResponse | pub |
| 893 | fn | LoggingAPIResponseError | pub |

## third_party/CLIProxyAPIPlus/sdk/api/handlers/handlers_stream_bootstrap_test.go (609 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 15 | struct | failOnceStreamExecutor | (private) |
| 20 | fn | Identifier | pub |
| 22 | fn | Execute | pub |
| 26 | fn | ExecuteStream | pub |
| 57 | fn | Refresh | pub |
| 61 | fn | CountTokens | pub |
| 65 | fn | HttpRequest | pub |
| 73 | fn | Calls | pub |
| 79 | struct | payloadThenErrorStreamExecutor | (private) |
| 84 | fn | Identifier | pub |
| 86 | fn | Execute | pub |
| 90 | fn | ExecuteStream | pub |
| 109 | fn | Refresh | pub |
| 113 | fn | CountTokens | pub |
| 117 | fn | HttpRequest | pub |
| 125 | fn | Calls | pub |
| 131 | struct | authAwareStreamExecutor | (private) |
| 137 | struct | invalidJSONStreamExecutor | (private) |
| 139 | fn | Identifier | pub |
| 141 | fn | Execute | pub |
| 145 | fn | ExecuteStream | pub |
| 152 | fn | Refresh | pub |
| 156 | fn | CountTokens | pub |
| 160 | fn | HttpRequest | pub |
| 168 | fn | Identifier | pub |
| 170 | fn | Execute | pub |
| 174 | fn | ExecuteStream | pub |
| 208 | fn | Refresh | pub |
| 212 | fn | CountTokens | pub |
| 216 | fn | HttpRequest | pub |
| 224 | fn | Calls | pub |
| 230 | fn | AuthIDs | pub |
| 238 | fn | TestExecuteStreamWithAuthManager_RetriesBeforeFirstByte | pub |
| 304 | fn | TestExecuteStreamWithAuthManager_HeaderPassthroughDisabledByDefault | pub |
| 364 | fn | TestExecuteStreamWithAuthManager_DoesNotRetryAfterFirstByte | pub |
| 434 | fn | TestExecuteStreamWithAuthManager_PinnedAuthKeepsSameUpstream | pub |
| 506 | fn | TestExecuteStreamWithAuthManager_SelectedAuthCallbackReceivesAuthID | pub |
| 559 | fn | TestExecuteStreamWithAuthManager_ValidatesOpenAIResponsesStreamDataJSON | pub |

