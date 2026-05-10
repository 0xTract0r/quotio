# third_party/CLIProxyAPIPlus/internal/runtime/executor/antigravity_executor.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2349
- **Language:** Go
- **Symbols:** 62
- **Public symbols:** 9

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 64 | struct | antigravityCreditsFailureState | (private) | - |
| 82 | struct | antigravity429Decision | (private) | - |
| 101 | struct | antigravityCreditsBalance | (private) | - |
| 108 | struct | antigravityCreditsHintRefreshState | (private) | - |
| 113 | fn | antigravityAuthHasCredits | (private) | `func antigravityAuthHasCredits(auth *cliproxyau...` |
| 145 | fn | parseMetaFloat | (private) | `func parseMetaFloat(metadata map[string]any, ke...` |
| 172 | struct | AntigravityExecutor | pub | - |
| 183 | fn | NewAntigravityExecutor | pub | `func NewAntigravityExecutor(cfg *config.Config)...` |
| 195 | fn | cloneTransportWithHTTP11 | (private) | `func cloneTransportWithHTTP11(base *http.Transp...` |
| 215 | fn | initAntigravityTransport | (private) | `func initAntigravityTransport() {` |
| 226 | fn | newAntigravityHTTPClient | (private) | `func newAntigravityHTTPClient(ctx context.Conte...` |
| 243 | fn | validateAntigravityRequestSignatures | (private) | `func validateAntigravityRequestSignatures(from ...` |
| 264 | fn | Identifier | pub | `func (e *AntigravityExecutor) Identifier() stri...` |
| 267 | fn | PrepareRequest | pub | `func (e *AntigravityExecutor) PrepareRequest(re...` |
| 285 | fn | HttpRequest | pub | `func (e *AntigravityExecutor) HttpRequest(ctx c...` |
| 319 | fn | injectEnabledCreditTypes | (private) | `func injectEnabledCreditTypes(payload []byte) [...` |
| 333 | fn | classifyAntigravity429 | (private) | `func classifyAntigravity429(body []byte) antigr...` |
| 346 | fn | decideAntigravity429 | (private) | `func decideAntigravity429(body []byte) antigrav...` |
| 404 | fn | antigravityCreditsRetryEnabled | (private) | `func antigravityCreditsRetryEnabled(cfg *config...` |
| 408 | fn | clearAntigravityCreditsFailureState | (private) | `func clearAntigravityCreditsFailureState(auth *...` |
| 414 | fn | markAntigravityCreditsPermanentlyDisabled | (private) | `func markAntigravityCreditsPermanentlyDisabled(...` |
| 438 | fn | clearAntigravityCreditsPermanentlyDisabled | (private) | `func clearAntigravityCreditsPermanentlyDisabled...` |
| 445 | fn | antigravityHasExplicitCreditsBalanceExhaustedReason | (private) | `func antigravityHasExplicitCreditsBalanceExhaus...` |
| 465 | fn | newAntigravityStatusErr | (private) | `func newAntigravityStatusErr(statusCode int, bo...` |
| 476 | fn | Execute | pub | `func (e *AntigravityExecutor) Execute(ctx conte...` |
| 681 | fn | executeClaudeNonStream | (private) | `func (e *AntigravityExecutor) executeClaudeNonS...` |
| 941 | fn | convertStreamToNonStream | (private) | `func (e *AntigravityExecutor) convertStreamToNo...` |
| 1135 | fn | ExecuteStream | pub | `func (e *AntigravityExecutor) ExecuteStream(ctx...` |
| 1390 | fn | Refresh | pub | `func (e *AntigravityExecutor) Refresh(ctx conte...` |
| 1402 | fn | CountTokens | pub | `func (e *AntigravityExecutor) CountTokens(ctx c...` |
| 1562 | fn | ensureAccessToken | (private) | `func (e *AntigravityExecutor) ensureAccessToken...` |
| 1585 | fn | maybeRefreshAntigravityCreditsHint | (private) | `func (e *AntigravityExecutor) maybeRefreshAntig...` |
| 1642 | fn | refreshToken | (private) | `func (e *AntigravityExecutor) refreshToken(ctx ...` |
| 1721 | fn | ensureAntigravityProjectID | (private) | `func (e *AntigravityExecutor) ensureAntigravity...` |
| 1754 | fn | updateAntigravityCreditsBalance | (private) | `func (e *AntigravityExecutor) updateAntigravity...` |
| 1842 | fn | buildRequest | (private) | `func (e *AntigravityExecutor) buildRequest(ctx ...` |
| 1983 | fn | antigravityRequestNeedsSchemaSanitization | (private) | `func antigravityRequestNeedsSchemaSanitization(...` |
| 1996 | fn | tokenExpiry | (private) | `func tokenExpiry(metadata map[string]any) time....` |
| 2016 | fn | metaStringValue | (private) | `func metaStringValue(metadata map[string]any, k...` |
| 2031 | fn | int64Value | (private) | `func int64Value(value any) (int64, bool) {` |
| 2054 | fn | buildBaseURL | (private) | `func buildBaseURL(auth *cliproxyauth.Auth) stri...` |
| 2061 | fn | resolveHost | (private) | `func resolveHost(base string) string {` |
| 2072 | fn | resolveUserAgent | (private) | `func resolveUserAgent(auth *cliproxyauth.Auth) ...` |
| 2088 | fn | antigravityRetryAttempts | (private) | `func antigravityRetryAttempts(auth *cliproxyaut...` |
| 2108 | fn | antigravityShouldRetryNoCapacity | (private) | `func antigravityShouldRetryNoCapacity(statusCod...` |
| 2119 | fn | antigravityShouldRetryTransientResourceExhausted429 | (private) | `func antigravityShouldRetryTransientResourceExh...` |
| 2137 | fn | antigravityShouldRetrySoftRateLimit | (private) | `func antigravityShouldRetrySoftRateLimit(status...` |
| 2144 | fn | antigravitySoftRateLimitDelay | (private) | `func antigravitySoftRateLimitDelay(attempt int)...` |
| 2155 | fn | antigravityShortCooldownKey | (private) | `func antigravityShortCooldownKey(auth *cliproxy...` |
| 2167 | fn | antigravityIsInShortCooldown | (private) | `func antigravityIsInShortCooldown(auth *cliprox...` |
| 2189 | fn | markAntigravityShortCooldown | (private) | `func markAntigravityShortCooldown(auth *cliprox...` |
| 2197 | fn | antigravityNoCapacityRetryDelay | (private) | `func antigravityNoCapacityRetryDelay(attempt in...` |
| 2208 | fn | antigravityTransient429RetryDelay | (private) | `func antigravityTransient429RetryDelay(attempt ...` |
| 2219 | fn | antigravityInstantRetryDelay | (private) | `func antigravityInstantRetryDelay(wait time.Dur...` |
| 2226 | fn | antigravityWait | (private) | `func antigravityWait(ctx context.Context, wait ...` |
| 2251 | fn | resolveCustomAntigravityBaseURL | (private) | `func resolveCustomAntigravityBaseURL(auth *clip...` |
| 2271 | fn | geminiToAntigravity | (private) | `func geminiToAntigravity(modelName string, payl...` |
| 2308 | fn | generateRequestID | (private) | `func generateRequestID() string {` |
| 2312 | fn | generateImageGenRequestID | (private) | `func generateImageGenRequestID() string {` |
| 2316 | fn | generateSessionID | (private) | `func generateSessionID() string {` |
| 2323 | fn | generateStableSessionID | (private) | `func generateStableSessionID(payload []byte) st...` |
| 2340 | fn | generateProjectID | (private) | `func generateProjectID() string {` |

## Public API

### `NewAntigravityExecutor`

```
func NewAntigravityExecutor(cfg *config.Config) *AntigravityExecutor {
```

**Line:** 183 | **Kind:** fn

### `Identifier`

```
func (e *AntigravityExecutor) Identifier() string { return antigravityAuthType }
```

**Line:** 264 | **Kind:** fn

### `PrepareRequest`

```
func (e *AntigravityExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 267 | **Kind:** fn

### `HttpRequest`

```
func (e *AntigravityExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 285 | **Kind:** fn

### `Execute`

```
func (e *AntigravityExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 476 | **Kind:** fn

### `ExecuteStream`

```
func (e *AntigravityExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 1135 | **Kind:** fn

### `Refresh`

```
func (e *AntigravityExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 1390 | **Kind:** fn

### `CountTokens`

```
func (e *AntigravityExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 1402 | **Kind:** fn

