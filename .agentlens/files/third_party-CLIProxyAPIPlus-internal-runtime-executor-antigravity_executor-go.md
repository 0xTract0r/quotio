# third_party/CLIProxyAPIPlus/internal/runtime/executor/antigravity_executor.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-runtime-executor/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1578
- **Language:** Go
- **Symbols:** 36
- **Public symbols:** 9

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 59 | struct | AntigravityExecutor | pub | - |
| 70 | fn | NewAntigravityExecutor | pub | `func NewAntigravityExecutor(cfg *config.Config)...` |
| 82 | fn | cloneTransportWithHTTP11 | (private) | `func cloneTransportWithHTTP11(base *http.Transp...` |
| 102 | fn | initAntigravityTransport | (private) | `func initAntigravityTransport() {` |
| 113 | fn | newAntigravityHTTPClient | (private) | `func newAntigravityHTTPClient(ctx context.Conte...` |
| 131 | fn | Identifier | pub | `func (e *AntigravityExecutor) Identifier() stri...` |
| 134 | fn | PrepareRequest | pub | `func (e *AntigravityExecutor) PrepareRequest(re...` |
| 152 | fn | HttpRequest | pub | `func (e *AntigravityExecutor) HttpRequest(ctx c...` |
| 187 | fn | Execute | pub | `func (e *AntigravityExecutor) Execute(ctx conte...` |
| 337 | fn | executeClaudeNonStream | (private) | `func (e *AntigravityExecutor) executeClaudeNonS...` |
| 541 | fn | convertStreamToNonStream | (private) | `func (e *AntigravityExecutor) convertStreamToNo...` |
| 724 | fn | ExecuteStream | pub | `func (e *AntigravityExecutor) ExecuteStream(ctx...` |
| 922 | fn | Refresh | pub | `func (e *AntigravityExecutor) Refresh(ctx conte...` |
| 934 | fn | CountTokens | pub | `func (e *AntigravityExecutor) CountTokens(ctx c...` |
| 1081 | fn | ensureAccessToken | (private) | `func (e *AntigravityExecutor) ensureAccessToken...` |
| 1103 | fn | refreshToken | (private) | `func (e *AntigravityExecutor) refreshToken(ctx ...` |
| 1181 | fn | ensureAntigravityProjectID | (private) | `func (e *AntigravityExecutor) ensureAntigravity...` |
| 1214 | fn | buildRequest | (private) | `func (e *AntigravityExecutor) buildRequest(ctx ...` |
| 1322 | fn | tokenExpiry | (private) | `func tokenExpiry(metadata map[string]any) time....` |
| 1342 | fn | metaStringValue | (private) | `func metaStringValue(metadata map[string]any, k...` |
| 1357 | fn | int64Value | (private) | `func int64Value(value any) (int64, bool) {` |
| 1380 | fn | buildBaseURL | (private) | `func buildBaseURL(auth *cliproxyauth.Auth) stri...` |
| 1387 | fn | resolveHost | (private) | `func resolveHost(base string) string {` |
| 1398 | fn | resolveUserAgent | (private) | `func resolveUserAgent(auth *cliproxyauth.Auth) ...` |
| 1414 | fn | antigravityRetryAttempts | (private) | `func antigravityRetryAttempts(auth *cliproxyaut...` |
| 1434 | fn | antigravityShouldRetryNoCapacity | (private) | `func antigravityShouldRetryNoCapacity(statusCod...` |
| 1445 | fn | antigravityNoCapacityRetryDelay | (private) | `func antigravityNoCapacityRetryDelay(attempt in...` |
| 1456 | fn | antigravityWait | (private) | `func antigravityWait(ctx context.Context, wait ...` |
| 1470 | fn | antigravityBaseURLFallbackOrder | (private) | `func antigravityBaseURLFallbackOrder(auth *clip...` |
| 1481 | fn | resolveCustomAntigravityBaseURL | (private) | `func resolveCustomAntigravityBaseURL(auth *clip...` |
| 1501 | fn | geminiToAntigravity | (private) | `func geminiToAntigravity(modelName string, payl...` |
| 1537 | fn | generateRequestID | (private) | `func generateRequestID() string {` |
| 1541 | fn | generateImageGenRequestID | (private) | `func generateImageGenRequestID() string {` |
| 1545 | fn | generateSessionID | (private) | `func generateSessionID() string {` |
| 1552 | fn | generateStableSessionID | (private) | `func generateStableSessionID(payload []byte) st...` |
| 1569 | fn | generateProjectID | (private) | `func generateProjectID() string {` |

## Public API

### `NewAntigravityExecutor`

```
func NewAntigravityExecutor(cfg *config.Config) *AntigravityExecutor {
```

**Line:** 70 | **Kind:** fn

### `Identifier`

```
func (e *AntigravityExecutor) Identifier() string { return antigravityAuthType }
```

**Line:** 131 | **Kind:** fn

### `PrepareRequest`

```
func (e *AntigravityExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 134 | **Kind:** fn

### `HttpRequest`

```
func (e *AntigravityExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 152 | **Kind:** fn

### `Execute`

```
func (e *AntigravityExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 187 | **Kind:** fn

### `ExecuteStream`

```
func (e *AntigravityExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 724 | **Kind:** fn

### `Refresh`

```
func (e *AntigravityExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 922 | **Kind:** fn

### `CountTokens`

```
func (e *AntigravityExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 934 | **Kind:** fn

