# third_party/CLIProxyAPIPlus/internal/runtime/executor/codex_websockets_executor.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-runtime-executor/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1385
- **Language:** Go
- **Symbols:** 50
- **Public symbols:** 16

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 44 | struct | CodexWebsocketsExecutor | pub | - |
| 51 | struct | codexWebsocketSession | (private) | - |
| 71 | fn | NewCodexWebsocketsExecutor | pub | `func NewCodexWebsocketsExecutor(cfg *config.Con...` |
| 78 | struct | codexWebsocketRead | (private) | - |
| 85 | fn | setActive | (private) | `func (s *codexWebsocketSession) setActive(ch ch...` |
| 104 | fn | clearActive | (private) | `func (s *codexWebsocketSession) clearActive(ch ...` |
| 120 | fn | writeMessage | (private) | `func (s *codexWebsocketSession) writeMessage(co...` |
| 132 | fn | configureConn | (private) | `func (s *codexWebsocketSession) configureConn(c...` |
| 144 | fn | Execute | pub | `func (e *CodexWebsocketsExecutor) Execute(ctx c...` |
| 352 | fn | ExecuteStream | pub | `func (e *CodexWebsocketsExecutor) ExecuteStream...` |
| 610 | fn | dialCodexWebsocket | (private) | `func (e *CodexWebsocketsExecutor) dialCodexWebs...` |
| 626 | fn | writeCodexWebsocketMessage | (private) | `func writeCodexWebsocketMessage(sess *codexWebs...` |
| 636 | fn | buildCodexWebsocketRequestBody | (private) | `func buildCodexWebsocketRequestBody(body []byte...` |
| 653 | fn | readCodexWebsocketMessage | (private) | `func readCodexWebsocketMessage(ctx context.Cont...` |
| 687 | fn | newProxyAwareWebsocketDialer | (private) | `func newProxyAwareWebsocketDialer(cfg *config.C...` |
| 750 | fn | buildCodexResponsesWebsocketURL | (private) | `func buildCodexResponsesWebsocketURL(httpURL st...` |
| 764 | fn | applyCodexPromptCacheHeaders | (private) | `func applyCodexPromptCacheHeaders(from sdktrans...` |
| 800 | fn | applyCodexWebsocketHeaders | (private) | `func applyCodexWebsocketHeaders(ctx context.Con...` |
| 857 | fn | codexHeaderDefaults | (private) | `func codexHeaderDefaults(cfg *config.Config, au...` |
| 869 | fn | ensureHeaderWithPriority | (private) | `func ensureHeaderWithPriority(target http.Heade...` |
| 891 | fn | ensureHeaderWithConfigPrecedence | (private) | `func ensureHeaderWithConfigPrecedence(target ht...` |
| 913 | struct | statusErrWithHeaders | (private) | - |
| 918 | fn | Headers | pub | `func (e statusErrWithHeaders) Headers() http.He...` |
| 925 | fn | parseCodexWebsocketError | (private) | `func parseCodexWebsocketError(payload []byte) (...` |
| 959 | fn | parseCodexWebsocketErrorHeaders | (private) | `func parseCodexWebsocketErrorHeaders(payload []...` |
| 989 | fn | normalizeCodexWebsocketCompletion | (private) | `func normalizeCodexWebsocketCompletion(payload ...` |
| 999 | fn | encodeCodexWebsocketAsSSE | (private) | `func encodeCodexWebsocketAsSSE(payload []byte) ...` |
| 1009 | fn | websocketHandshakeBody | (private) | `func websocketHandshakeBody(resp *http.Response...` |
| 1021 | fn | closeHTTPResponseBody | (private) | `func closeHTTPResponseBody(resp *http.Response,...` |
| 1030 | fn | executionSessionIDFromOptions | (private) | `func executionSessionIDFromOptions(opts cliprox...` |
| 1048 | fn | getOrCreateSession | (private) | `func (e *CodexWebsocketsExecutor) getOrCreateSe...` |
| 1066 | fn | ensureUpstreamConn | (private) | `func (e *CodexWebsocketsExecutor) ensureUpstrea...` |
| 1112 | fn | readUpstreamLoop | (private) | `func (e *CodexWebsocketsExecutor) readUpstreamL...` |
| 1173 | fn | invalidateUpstreamConn | (private) | `func (e *CodexWebsocketsExecutor) invalidateUps...` |
| 1199 | fn | CloseExecutionSession | pub | `func (e *CodexWebsocketsExecutor) CloseExecutio...` |
| 1220 | fn | closeAllExecutionSessions | (private) | `func (e *CodexWebsocketsExecutor) closeAllExecu...` |
| 1240 | fn | closeExecutionSession | (private) | `func (e *CodexWebsocketsExecutor) closeExecutio...` |
| 1269 | fn | logCodexWebsocketConnected | (private) | `func logCodexWebsocketConnected(sessionID strin...` |
| 1273 | fn | logCodexWebsocketDisconnected | (private) | `func logCodexWebsocketDisconnected(sessionID st...` |
| 1286 | struct | CodexAutoExecutor | pub | - |
| 1291 | fn | NewCodexAutoExecutor | pub | `func NewCodexAutoExecutor(cfg *config.Config) *...` |
| 1298 | fn | Identifier | pub | `func (e *CodexAutoExecutor) Identifier() string...` |
| 1300 | fn | PrepareRequest | pub | `func (e *CodexAutoExecutor) PrepareRequest(req ...` |
| 1307 | fn | HttpRequest | pub | `func (e *CodexAutoExecutor) HttpRequest(ctx con...` |
| 1314 | fn | Execute | pub | `func (e *CodexAutoExecutor) Execute(ctx context...` |
| 1324 | fn | ExecuteStream | pub | `func (e *CodexAutoExecutor) ExecuteStream(ctx c...` |
| 1334 | fn | Refresh | pub | `func (e *CodexAutoExecutor) Refresh(ctx context...` |
| 1341 | fn | CountTokens | pub | `func (e *CodexAutoExecutor) CountTokens(ctx con...` |
| 1348 | fn | CloseExecutionSession | pub | `func (e *CodexAutoExecutor) CloseExecutionSessi...` |
| 1355 | fn | codexWebsocketsEnabled | (private) | `func codexWebsocketsEnabled(auth *cliproxyauth....` |

## Public API

### `NewCodexWebsocketsExecutor`

```
func NewCodexWebsocketsExecutor(cfg *config.Config) *CodexWebsocketsExecutor {
```

**Line:** 71 | **Kind:** fn

### `Execute`

```
func (e *CodexWebsocketsExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 144 | **Kind:** fn

### `ExecuteStream`

```
func (e *CodexWebsocketsExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 352 | **Kind:** fn

### `Headers`

```
func (e statusErrWithHeaders) Headers() http.Header {
```

**Line:** 918 | **Kind:** fn

### `CloseExecutionSession`

```
func (e *CodexWebsocketsExecutor) CloseExecutionSession(sessionID string) {
```

**Line:** 1199 | **Kind:** fn

### `NewCodexAutoExecutor`

```
func NewCodexAutoExecutor(cfg *config.Config) *CodexAutoExecutor {
```

**Line:** 1291 | **Kind:** fn

### `Identifier`

```
func (e *CodexAutoExecutor) Identifier() string { return "codex" }
```

**Line:** 1298 | **Kind:** fn

### `PrepareRequest`

```
func (e *CodexAutoExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 1300 | **Kind:** fn

### `HttpRequest`

```
func (e *CodexAutoExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 1307 | **Kind:** fn

### `Execute`

```
func (e *CodexAutoExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 1314 | **Kind:** fn

### `ExecuteStream`

```
func (e *CodexAutoExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (*cliproxyexecutor.StreamResult, error) {
```

**Line:** 1324 | **Kind:** fn

### `Refresh`

```
func (e *CodexAutoExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 1334 | **Kind:** fn

### `CountTokens`

```
func (e *CodexAutoExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 1341 | **Kind:** fn

### `CloseExecutionSession`

```
func (e *CodexAutoExecutor) CloseExecutionSession(sessionID string) {
```

**Line:** 1348 | **Kind:** fn

