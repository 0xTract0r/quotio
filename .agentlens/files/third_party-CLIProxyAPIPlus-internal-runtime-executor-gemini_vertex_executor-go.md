# third_party/CLIProxyAPIPlus/internal/runtime/executor/gemini_vertex_executor.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1100
- **Language:** Go
- **Symbols:** 24
- **Public symbols:** 9

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 39 | fn | isImagenModel | (private) | `func isImagenModel(model string) bool {` |
| 46 | fn | getVertexAction | (private) | `func getVertexAction(model string, isStream boo...` |
| 59 | fn | convertImagenToGeminiResponse | (private) | `func convertImagenToGeminiResponse(data []byte,...` |
| 113 | fn | convertToImagenRequest | (private) | `func convertToImagenRequest(payload []byte) ([]...` |
| 175 | struct | GeminiVertexExecutor | pub | - |
| 186 | fn | NewGeminiVertexExecutor | pub | `func NewGeminiVertexExecutor(cfg *config.Config...` |
| 191 | fn | Identifier | pub | `func (e *GeminiVertexExecutor) Identifier() str...` |
| 194 | fn | PrepareRequest | pub | `func (e *GeminiVertexExecutor) PrepareRequest(r...` |
| 221 | fn | HttpRequest | pub | `func (e *GeminiVertexExecutor) HttpRequest(ctx ...` |
| 237 | fn | Execute | pub | `func (e *GeminiVertexExecutor) Execute(ctx cont...` |
| 258 | fn | ExecuteStream | pub | `func (e *GeminiVertexExecutor) ExecuteStream(ct...` |
| 279 | fn | CountTokens | pub | `func (e *GeminiVertexExecutor) CountTokens(ctx ...` |
| 297 | fn | Refresh | pub | `func (e *GeminiVertexExecutor) Refresh(_ contex...` |
| 303 | fn | executeWithServiceAccount | (private) | `func (e *GeminiVertexExecutor) executeWithServi...` |
| 434 | fn | executeWithAPIKey | (private) | `func (e *GeminiVertexExecutor) executeWithAPIKe...` |
| 544 | fn | executeStreamWithServiceAccount | (private) | `func (e *GeminiVertexExecutor) executeStreamWit...` |
| 673 | fn | executeStreamWithAPIKey | (private) | `func (e *GeminiVertexExecutor) executeStreamWit...` |
| 802 | fn | countTokensWithServiceAccount | (private) | `func (e *GeminiVertexExecutor) countTokensWithS...` |
| 891 | fn | countTokensWithAPIKey | (private) | `func (e *GeminiVertexExecutor) countTokensWithA...` |
| 980 | fn | vertexCreds | (private) | `func vertexCreds(a *cliproxyauth.Auth) (project...` |
| 1020 | fn | vertexAPICreds | (private) | `func vertexAPICreds(a *cliproxyauth.Auth) (apiK...` |
| 1036 | fn | vertexBaseURL | (private) | `func vertexBaseURL(location string) string {` |
| 1046 | fn | vertexAccessToken | (private) | `func vertexAccessToken(ctx context.Context, cfg...` |
| 1063 | fn | resolveVertexConfig | (private) | `func (e *GeminiVertexExecutor) resolveVertexCon...` |

## Public API

### `NewGeminiVertexExecutor`

```
func NewGeminiVertexExecutor(cfg *config.Config) *GeminiVertexExecutor {
```

**Line:** 186 | **Kind:** fn

### `Identifier`

```
func (e *GeminiVertexExecutor) Identifier() string { return "vertex" }
```

**Line:** 191 | **Kind:** fn

### `PrepareRequest`

```
func (e *GeminiVertexExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 194 | **Kind:** fn

### `HttpRequest`

```
func (e *GeminiVertexExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 221 | **Kind:** fn

### `Execute`

```
func (e *GeminiVertexExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 237 | **Kind:** fn

### `ExecuteStream`

```
func (e *GeminiVertexExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (*cliproxyexecutor.StreamResult, error) {
```

**Line:** 258 | **Kind:** fn

### `CountTokens`

```
func (e *GeminiVertexExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 279 | **Kind:** fn

### `Refresh`

```
func (e *GeminiVertexExecutor) Refresh(_ context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 297 | **Kind:** fn

