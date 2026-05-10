# third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 4646
- **Language:** Go
- **Symbols:** 60
- **Public symbols:** 11

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 94 | struct | retryConfig | (private) | - |
| 105 | fn | defaultRetryConfig | (private) | `func defaultRetryConfig() retryConfig {` |
| 130 | fn | isRetryableError | (private) | `func isRetryableError(err error) bool {` |
| 207 | fn | isRetryableHTTPStatus | (private) | `func isRetryableHTTPStatus(statusCode int) bool {` |
| 214 | fn | calculateRetryDelay | (private) | `func calculateRetryDelay(attempt int, cfg retry...` |
| 219 | fn | logRetryAttempt | (private) | `func logRetryAttempt(attempt, maxRetries int, r...` |
| 238 | fn | getKiroPooledHTTPClient | (private) | `func getKiroPooledHTTPClient() *http.Client {` |
| 281 | fn | newKiroHTTPClientWithPooling | (private) | `func newKiroHTTPClientWithPooling(ctx context.C...` |
| 318 | struct | kiroEndpointConfig | (private) | - |
| 327 | const | kiroDefaultRegion | (private) | - |
| 332 | fn | extractRegionFromProfileARN | (private) | `func extractRegionFromProfileARN(profileArn str...` |
| 353 | fn | buildKiroEndpointConfigs | (private) | `func buildKiroEndpointConfigs(region string) []...` |
| 381 | fn | resolveKiroAPIRegion | (private) | `func resolveKiroAPIRegion(auth *cliproxyauth.Au...` |
| 417 | fn | getKiroEndpointConfigs | (private) | `func getKiroEndpointConfigs(auth *cliproxyauth....` |
| 453 | struct | KiroExecutor | pub | - |
| 465 | fn | buildKiroPayloadForFormat | (private) | `func buildKiroPayloadForFormat(body []byte, mod...` |
| 482 | fn | NewKiroExecutor | pub | `func NewKiroExecutor(cfg *config.Config) *KiroE...` |
| 487 | fn | Identifier | pub | `func (e *KiroExecutor) Identifier() string { re...` |
| 490 | fn | applyDynamicFingerprint | (private) | `func applyDynamicFingerprint(req *http.Request,...` |
| 508 | fn | PrepareRequest | pub | `func (e *KiroExecutor) PrepareRequest(req *http...` |
| 532 | fn | HttpRequest | pub | `func (e *KiroExecutor) HttpRequest(ctx context....` |
| 554 | fn | getAccountKey | (private) | `func getAccountKey(auth *cliproxyauth.Auth) str...` |
| 577 | fn | getAuthValue | (private) | `func getAuthValue(auth *cliproxyauth.Auth, key ...` |
| 596 | fn | Execute | pub | `func (e *KiroExecutor) Execute(ctx context.Cont...` |
| 688 | fn | executeWithRetry | (private) | `func (e *KiroExecutor) executeWithRetry(ctx con...` |
| 1032 | fn | ExecuteStream | pub | `func (e *KiroExecutor) ExecuteStream(ctx contex...` |
| 1131 | fn | executeStreamWithRetry | (private) | `func (e *KiroExecutor) executeStreamWithRetry(c...` |
| 1444 | fn | kiroCredentials | (private) | `func kiroCredentials(auth *cliproxyauth.Auth) (...` |
| 1495 | fn | findRealThinkingEndTag | (private) | `func findRealThinkingEndTag(content string, alr...` |
| 1627 | fn | determineAgenticMode | (private) | `func determineAgenticMode(model string) (isAgen...` |
| 1638 | fn | getEffectiveProfileArnWithWarning | (private) | `func getEffectiveProfileArnWithWarning(auth *cl...` |
| 1659 | fn | mapModelToKiro | (private) | `func (e *KiroExecutor) mapModelToKiro(model str...` |
| 1759 | struct | EventStreamError | pub | - |
| 1765 | fn | Error | pub | `func (e *EventStreamError) Error() string {` |
| 1773 | struct | eventStreamMessage | (private) | - |
| 1785 | fn | parseEventStream | (private) | `func (e *KiroExecutor) parseEventStream(body io...` |
| 2269 | fn | readEventStreamMessage | (private) | `func (e *KiroExecutor) readEventStreamMessage(r...` |
| 2354 | fn | skipEventStreamHeaderValue | (private) | `func skipEventStreamHeaderValue(headers []byte,...` |
| 2404 | fn | extractEventTypeFromBytes | (private) | `func (e *KiroExecutor) extractEventTypeFromByte...` |
| 2457 | fn | streamToChannel | (private) | `func (e *KiroExecutor) streamToChannel(ctx cont...` |
| 3516 | fn | CountTokens | pub | `func (e *KiroExecutor) CountTokens(ctx context....` |
| 3561 | fn | Refresh | pub | `func (e *KiroExecutor) Refresh(ctx context.Cont...` |
| 3728 | fn | persistRefreshedAuth | (private) | `func (e *KiroExecutor) persistRefreshedAuth(aut...` |
| 3774 | fn | fetchAndSaveProfileArn | (private) | `func (e *KiroExecutor) fetchAndSaveProfileArn(c...` |
| 3821 | fn | reloadAuthFromFile | (private) | `func (e *KiroExecutor) reloadAuthFromFile(auth ...` |
| 3935 | fn | isTokenExpired | (private) | `func (e *KiroExecutor) isTokenExpired(accessTok...` |
| 4011 | fn | fetchToolDescription | (private) | `func fetchToolDescription(ctx context.Context, ...` |
| 4080 | struct | webSearchHandler | (private) | - |
| 4092 | fn | newWebSearchHandler | (private) | `func newWebSearchHandler(ctx context.Context, m...` |
| 4110 | fn | setMcpHeaders | (private) | `func (h *webSearchHandler) setMcpHeaders(req *h...` |
| 4134 | const | mcpMaxRetries | (private) | - |
| 4138 | fn | callMcpAPI | (private) | `func (h *webSearchHandler) callMcpAPI(request *...` |
| 4216 | fn | webSearchAuthAttrs | (private) | `func webSearchAuthAttrs(auth *cliproxyauth.Auth...` |
| 4223 | const | maxWebSearchIterations | (private) | - |
| 4231 | fn | handleWebSearchStream | (private) | `func (e *KiroExecutor) handleWebSearchStream(` |
| 4438 | fn | handleWebSearch | (private) | `func (e *KiroExecutor) handleWebSearch(` |
| 4531 | fn | callKiroAndBuffer | (private) | `func (e *KiroExecutor) callKiroAndBuffer(` |
| 4574 | fn | callKiroDirectStream | (private) | `func (e *KiroExecutor) callKiroDirectStream(` |
| 4605 | fn | sendFallbackText | (private) | `func (e *KiroExecutor) sendFallbackText(` |
| 4624 | fn | executeNonStreamFallback | (private) | `func (e *KiroExecutor) executeNonStreamFallback(` |

## Public API

### `NewKiroExecutor`

```
func NewKiroExecutor(cfg *config.Config) *KiroExecutor {
```

**Line:** 482 | **Kind:** fn

### `Identifier`

```
func (e *KiroExecutor) Identifier() string { return "kiro" }
```

**Line:** 487 | **Kind:** fn

### `PrepareRequest`

```
func (e *KiroExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 508 | **Kind:** fn

### `HttpRequest`

```
func (e *KiroExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 532 | **Kind:** fn

### `Execute`

```
func (e *KiroExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 596 | **Kind:** fn

### `ExecuteStream`

```
func (e *KiroExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 1032 | **Kind:** fn

### `Error`

```
func (e *EventStreamError) Error() string {
```

**Line:** 1765 | **Kind:** fn

### `CountTokens`

```
func (e *KiroExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 3516 | **Kind:** fn

### `Refresh`

```
func (e *KiroExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 3561 | **Kind:** fn

## Memory Markers

### 🟢 `NOTE` (line 147)

> Temporary() is deprecated but still useful for some error types

### 🟢 `NOTE` (line 380)

> OIDC "region" is NOT used - it's for token refresh, not API calls

### 🟢 `NOTE` (line 397)

> OIDC "region" field is NOT used for API endpoint

### 🟢 `NOTE` (line 416)

> OIDC "region" is NOT used - it's for token refresh, not API calls

### 🟢 `NOTE` (line 677)

> currentOrigin and kiroPayload are built inside executeWithRetry for each endpoint

### 🟢 `NOTE` (line 1019)

> This code is unreachable because all paths in the inner loop

### 🟢 `NOTE` (line 1117)

> currentOrigin and kiroPayload are built inside executeStreamWithRetry for each endpoint

### 🟢 `NOTE` (line 1154)

> Delay is NOT applied during streaming response - only before initial request

### 🟢 `NOTE` (line 1432)

> This code is unreachable because all paths in the inner loop

### 🟢 `NOTE` (line 1778)

> Request building functions moved to internal/translator/kiro/claude/kiro_claude_request.go

### 🟢 `NOTE` (line 2082)

> This is separate from token counts - it's AWS billing units

### 🟢 `NOTE` (line 2286)

> prelude[8:12] is prelude_crc - we read it but don't validate (no CRC check per requirements)

### 🟢 `NOTE` (line 2448)

> Response building functions moved to internal/translator/kiro/claude/kiro_claude_response.go

### 🟢 `NOTE` (line 2467)

> Duplicate content filtering removed - it was causing legitimate repeated

### 🟢 `NOTE` (line 2874)

> Duplicate content filtering was removed because it incorrectly

### 🟢 `NOTE` (line 3188)

> We don't close the thinking block here - it will be closed when we see

### 🟢 `NOTE` (line 3457)

> The effective input context is ~170k (200k - 30k reserved for output)

### 🟢 `NOTE` (line 3511)

> Claude SSE event builders moved to internal/translator/kiro/claude/kiro_claude_stream.go

### 🟢 `NOTE` (line 3579)

> This check has a design limitation - it reads from the auth object passed in,

### 🟢 `NOTE` (line 4228)

> We skip the "model decides to search" step because Claude Code already

