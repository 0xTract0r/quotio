# third_party/CLIProxyAPIPlus/internal/runtime/executor/codex_websockets_executor.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1588
- **Language:** Go
- **Symbols:** 59
- **Public symbols:** 17

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 46 | struct | CodexWebsocketsExecutor | pub | - |
| 52 | struct | codexWebsocketSessionStore | (private) | - |
| 61 | struct | codexWebsocketSession | (private) | - |
| 81 | fn | NewCodexWebsocketsExecutor | pub | `func NewCodexWebsocketsExecutor(cfg *config.Con...` |
| 88 | struct | codexWebsocketRead | (private) | - |
| 95 | fn | setActive | (private) | `func (s *codexWebsocketSession) setActive(ch ch...` |
| 114 | fn | clearActive | (private) | `func (s *codexWebsocketSession) clearActive(ch ...` |
| 130 | fn | writeMessage | (private) | `func (s *codexWebsocketSession) writeMessage(co...` |
| 142 | fn | configureConn | (private) | `func (s *codexWebsocketSession) configureConn(c...` |
| 154 | fn | Execute | pub | `func (e *CodexWebsocketsExecutor) Execute(ctx c...` |
| 362 | fn | ExecuteStream | pub | `func (e *CodexWebsocketsExecutor) ExecuteStream...` |
| 622 | fn | dialCodexWebsocket | (private) | `func (e *CodexWebsocketsExecutor) dialCodexWebs...` |
| 638 | fn | writeCodexWebsocketMessage | (private) | `func writeCodexWebsocketMessage(sess *codexWebs...` |
| 648 | fn | buildCodexWebsocketRequestBody | (private) | `func buildCodexWebsocketRequestBody(body []byte...` |
| 665 | fn | readCodexWebsocketMessage | (private) | `func readCodexWebsocketMessage(ctx context.Cont...` |
| 699 | fn | newProxyAwareWebsocketDialer | (private) | `func newProxyAwareWebsocketDialer(cfg *config.C...` |
| 762 | fn | buildCodexResponsesWebsocketURL | (private) | `func buildCodexResponsesWebsocketURL(httpURL st...` |
| 776 | fn | applyCodexPromptCacheHeaders | (private) | `func applyCodexPromptCacheHeaders(from sdktrans...` |
| 811 | fn | applyCodexWebsocketHeaders | (private) | `func applyCodexWebsocketHeaders(ctx context.Con...` |
| 892 | fn | codexHeaderDefaults | (private) | `func codexHeaderDefaults(cfg *config.Config, au...` |
| 904 | fn | ensureHeaderWithPriority | (private) | `func ensureHeaderWithPriority(target http.Heade...` |
| 926 | fn | ensureHeaderWithConfigPrecedence | (private) | `func ensureHeaderWithConfigPrecedence(target ht...` |
| 948 | struct | statusErrWithHeaders | (private) | - |
| 953 | fn | Headers | pub | `func (e statusErrWithHeaders) Headers() http.He...` |
| 960 | fn | parseCodexWebsocketError | (private) | `func parseCodexWebsocketError(payload []byte) (...` |
| 994 | fn | parseCodexWebsocketErrorHeaders | (private) | `func parseCodexWebsocketErrorHeaders(payload []...` |
| 1024 | fn | normalizeCodexWebsocketCompletion | (private) | `func normalizeCodexWebsocketCompletion(payload ...` |
| 1034 | fn | encodeCodexWebsocketAsSSE | (private) | `func encodeCodexWebsocketAsSSE(payload []byte) ...` |
| 1044 | fn | websocketUpgradeRequestLog | (private) | `func websocketUpgradeRequestLog(info helps.Upst...` |
| 1062 | fn | recordAPIWebsocketHandshake | (private) | `func recordAPIWebsocketHandshake(ctx context.Co...` |
| 1070 | fn | websocketHandshakeBody | (private) | `func websocketHandshakeBody(resp *http.Response...` |
| 1082 | fn | closeHTTPResponseBody | (private) | `func closeHTTPResponseBody(resp *http.Response,...` |
| 1091 | fn | executionSessionIDFromOptions | (private) | `func executionSessionIDFromOptions(opts cliprox...` |
| 1109 | fn | getOrCreateSession | (private) | `func (e *CodexWebsocketsExecutor) getOrCreateSe...` |
| 1135 | fn | ensureUpstreamConn | (private) | `func (e *CodexWebsocketsExecutor) ensureUpstrea...` |
| 1181 | fn | readUpstreamLoop | (private) | `func (e *CodexWebsocketsExecutor) readUpstreamL...` |
| 1242 | fn | invalidateUpstreamConn | (private) | `func (e *CodexWebsocketsExecutor) invalidateUps...` |
| 1268 | fn | CloseExecutionSession | pub | `func (e *CodexWebsocketsExecutor) CloseExecutio...` |
| 1303 | fn | closeAllExecutionSessions | (private) | `func (e *CodexWebsocketsExecutor) closeAllExecu...` |
| 1327 | fn | closeExecutionSession | (private) | `func (e *CodexWebsocketsExecutor) closeExecutio...` |
| 1331 | fn | closeCodexWebsocketSession | (private) | `func closeCodexWebsocketSession(sess *codexWebs...` |
| 1360 | fn | codexWebsocketSessionStoreKey | (private) | `func codexWebsocketSessionStoreKey(sessionID st...` |
| 1381 | fn | codexWebsocketAuthKey | (private) | `func codexWebsocketAuthKey(auth *cliproxyauth.A...` |
| 1393 | fn | codexWebsocketTransportProfileToken | (private) | `func codexWebsocketTransportProfileToken(auth *...` |
| 1397 | fn | codexWebsocketEffectiveProxyURL | (private) | `func codexWebsocketEffectiveProxyURL(cfg *confi...` |
| 1409 | fn | logCodexWebsocketConnected | (private) | `func logCodexWebsocketConnected(sessionID strin...` |
| 1413 | fn | logCodexWebsocketDisconnected | (private) | `func logCodexWebsocketDisconnected(sessionID st...` |
| 1423 | fn | CloseCodexWebsocketSessionsForAuthID | pub | `func CloseCodexWebsocketSessionsForAuthID(authI...` |
| 1489 | struct | CodexAutoExecutor | pub | - |
| 1494 | fn | NewCodexAutoExecutor | pub | `func NewCodexAutoExecutor(cfg *config.Config) *...` |
| 1501 | fn | Identifier | pub | `func (e *CodexAutoExecutor) Identifier() string...` |
| 1503 | fn | PrepareRequest | pub | `func (e *CodexAutoExecutor) PrepareRequest(req ...` |
| 1510 | fn | HttpRequest | pub | `func (e *CodexAutoExecutor) HttpRequest(ctx con...` |
| 1517 | fn | Execute | pub | `func (e *CodexAutoExecutor) Execute(ctx context...` |
| 1527 | fn | ExecuteStream | pub | `func (e *CodexAutoExecutor) ExecuteStream(ctx c...` |
| 1537 | fn | Refresh | pub | `func (e *CodexAutoExecutor) Refresh(ctx context...` |
| 1544 | fn | CountTokens | pub | `func (e *CodexAutoExecutor) CountTokens(ctx con...` |
| 1551 | fn | CloseExecutionSession | pub | `func (e *CodexAutoExecutor) CloseExecutionSessi...` |
| 1558 | fn | codexWebsocketsEnabled | (private) | `func codexWebsocketsEnabled(auth *cliproxyauth....` |

## Public API

### `NewCodexWebsocketsExecutor`

```
func NewCodexWebsocketsExecutor(cfg *config.Config) *CodexWebsocketsExecutor {
```

**Line:** 81 | **Kind:** fn

### `Execute`

```
func (e *CodexWebsocketsExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 154 | **Kind:** fn

### `ExecuteStream`

```
func (e *CodexWebsocketsExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 362 | **Kind:** fn

### `Headers`

```
func (e statusErrWithHeaders) Headers() http.Header {
```

**Line:** 953 | **Kind:** fn

### `CloseExecutionSession`

```
func (e *CodexWebsocketsExecutor) CloseExecutionSession(sessionID string) {
```

**Line:** 1268 | **Kind:** fn

### `CloseCodexWebsocketSessionsForAuthID`

```
func CloseCodexWebsocketSessionsForAuthID(authID string, reason string) {
```

**Line:** 1423 | **Kind:** fn

### `NewCodexAutoExecutor`

```
func NewCodexAutoExecutor(cfg *config.Config) *CodexAutoExecutor {
```

**Line:** 1494 | **Kind:** fn

### `Identifier`

```
func (e *CodexAutoExecutor) Identifier() string { return "codex" }
```

**Line:** 1501 | **Kind:** fn

### `PrepareRequest`

```
func (e *CodexAutoExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 1503 | **Kind:** fn

### `HttpRequest`

```
func (e *CodexAutoExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 1510 | **Kind:** fn

### `Execute`

```
func (e *CodexAutoExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 1517 | **Kind:** fn

### `ExecuteStream`

```
func (e *CodexAutoExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (*cliproxyexecutor.StreamResult, error) {
```

**Line:** 1527 | **Kind:** fn

### `Refresh`

```
func (e *CodexAutoExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 1537 | **Kind:** fn

### `CountTokens`

```
func (e *CodexAutoExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 1544 | **Kind:** fn

### `CloseExecutionSession`

```
func (e *CodexAutoExecutor) CloseExecutionSession(sessionID string) {
```

**Line:** 1551 | **Kind:** fn

