# third_party/CLIProxyAPIPlus/internal/runtime/executor/gemini_vertex_executor.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-runtime-executor/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1068
- **Language:** Go
- **Symbols:** 24
- **Public symbols:** 9

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 37 | fn | isImagenModel | (private) | `func isImagenModel(model string) bool {` |
| 44 | fn | getVertexAction | (private) | `func getVertexAction(model string, isStream boo...` |
| 57 | fn | convertImagenToGeminiResponse | (private) | `func convertImagenToGeminiResponse(data []byte,...` |
| 111 | fn | convertToImagenRequest | (private) | `func convertToImagenRequest(payload []byte) ([]...` |
| 173 | struct | GeminiVertexExecutor | pub | - |
| 184 | fn | NewGeminiVertexExecutor | pub | `func NewGeminiVertexExecutor(cfg *config.Config...` |
| 189 | fn | Identifier | pub | `func (e *GeminiVertexExecutor) Identifier() str...` |
| 192 | fn | PrepareRequest | pub | `func (e *GeminiVertexExecutor) PrepareRequest(r...` |
| 219 | fn | HttpRequest | pub | `func (e *GeminiVertexExecutor) HttpRequest(ctx ...` |
| 235 | fn | Execute | pub | `func (e *GeminiVertexExecutor) Execute(ctx cont...` |
| 256 | fn | ExecuteStream | pub | `func (e *GeminiVertexExecutor) ExecuteStream(ct...` |
| 277 | fn | CountTokens | pub | `func (e *GeminiVertexExecutor) CountTokens(ctx ...` |
| 295 | fn | Refresh | pub | `func (e *GeminiVertexExecutor) Refresh(_ contex...` |
| 301 | fn | executeWithServiceAccount | (private) | `func (e *GeminiVertexExecutor) executeWithServi...` |
| 427 | fn | executeWithAPIKey | (private) | `func (e *GeminiVertexExecutor) executeWithAPIKe...` |
| 532 | fn | executeStreamWithServiceAccount | (private) | `func (e *GeminiVertexExecutor) executeStreamWit...` |
| 656 | fn | executeStreamWithAPIKey | (private) | `func (e *GeminiVertexExecutor) executeStreamWit...` |
| 780 | fn | countTokensWithServiceAccount | (private) | `func (e *GeminiVertexExecutor) countTokensWithS...` |
| 864 | fn | countTokensWithAPIKey | (private) | `func (e *GeminiVertexExecutor) countTokensWithA...` |
| 948 | fn | vertexCreds | (private) | `func vertexCreds(a *cliproxyauth.Auth) (project...` |
| 988 | fn | vertexAPICreds | (private) | `func vertexAPICreds(a *cliproxyauth.Auth) (apiK...` |
| 1004 | fn | vertexBaseURL | (private) | `func vertexBaseURL(location string) string {` |
| 1014 | fn | vertexAccessToken | (private) | `func vertexAccessToken(ctx context.Context, cfg...` |
| 1031 | fn | resolveVertexConfig | (private) | `func (e *GeminiVertexExecutor) resolveVertexCon...` |

## Public API

### `NewGeminiVertexExecutor`

```
func NewGeminiVertexExecutor(cfg *config.Config) *GeminiVertexExecutor {
```

**Line:** 184 | **Kind:** fn

### `Identifier`

```
func (e *GeminiVertexExecutor) Identifier() string { return "vertex" }
```

**Line:** 189 | **Kind:** fn

### `PrepareRequest`

```
func (e *GeminiVertexExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 192 | **Kind:** fn

### `HttpRequest`

```
func (e *GeminiVertexExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 219 | **Kind:** fn

### `Execute`

```
func (e *GeminiVertexExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 235 | **Kind:** fn

### `ExecuteStream`

```
func (e *GeminiVertexExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (*cliproxyexecutor.StreamResult, error) {
```

**Line:** 256 | **Kind:** fn

### `CountTokens`

```
func (e *GeminiVertexExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 277 | **Kind:** fn

### `Refresh`

```
func (e *GeminiVertexExecutor) Refresh(_ context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 295 | **Kind:** fn

