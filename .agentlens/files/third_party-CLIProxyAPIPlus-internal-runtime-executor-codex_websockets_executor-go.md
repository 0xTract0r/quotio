# third_party/CLIProxyAPIPlus/internal/runtime/executor/codex_websockets_executor.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1593
- **Language:** Go
- **Symbols:** 59
- **Public symbols:** 17

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 47 | struct | CodexWebsocketsExecutor | pub | - |
| 53 | struct | codexWebsocketSessionStore | (private) | - |
| 62 | struct | codexWebsocketSession | (private) | - |
| 82 | fn | NewCodexWebsocketsExecutor | pub | `func NewCodexWebsocketsExecutor(cfg *config.Con...` |
| 89 | struct | codexWebsocketRead | (private) | - |
| 96 | fn | setActive | (private) | `func (s *codexWebsocketSession) setActive(ch ch...` |
| 115 | fn | clearActive | (private) | `func (s *codexWebsocketSession) clearActive(ch ...` |
| 131 | fn | writeMessage | (private) | `func (s *codexWebsocketSession) writeMessage(co...` |
| 143 | fn | configureConn | (private) | `func (s *codexWebsocketSession) configureConn(c...` |
| 155 | fn | Execute | pub | `func (e *CodexWebsocketsExecutor) Execute(ctx c...` |
| 363 | fn | ExecuteStream | pub | `func (e *CodexWebsocketsExecutor) ExecuteStream...` |
| 623 | fn | dialCodexWebsocket | (private) | `func (e *CodexWebsocketsExecutor) dialCodexWebs...` |
| 639 | fn | writeCodexWebsocketMessage | (private) | `func writeCodexWebsocketMessage(sess *codexWebs...` |
| 649 | fn | buildCodexWebsocketRequestBody | (private) | `func buildCodexWebsocketRequestBody(body []byte...` |
| 666 | fn | readCodexWebsocketMessage | (private) | `func readCodexWebsocketMessage(ctx context.Cont...` |
| 700 | fn | newProxyAwareWebsocketDialer | (private) | `func newProxyAwareWebsocketDialer(cfg *config.C...` |
| 763 | fn | buildCodexResponsesWebsocketURL | (private) | `func buildCodexResponsesWebsocketURL(httpURL st...` |
| 777 | fn | applyCodexPromptCacheHeaders | (private) | `func applyCodexPromptCacheHeaders(from sdktrans...` |
| 812 | fn | applyCodexWebsocketHeaders | (private) | `func applyCodexWebsocketHeaders(ctx context.Con...` |
| 893 | fn | codexHeaderDefaults | (private) | `func codexHeaderDefaults(cfg *config.Config, au...` |
| 905 | fn | ensureHeaderWithPriority | (private) | `func ensureHeaderWithPriority(target http.Heade...` |
| 927 | fn | ensureHeaderWithConfigPrecedence | (private) | `func ensureHeaderWithConfigPrecedence(target ht...` |
| 949 | struct | statusErrWithHeaders | (private) | - |
| 954 | fn | Headers | pub | `func (e statusErrWithHeaders) Headers() http.He...` |
| 961 | fn | parseCodexWebsocketError | (private) | `func parseCodexWebsocketError(payload []byte) (...` |
| 995 | fn | parseCodexWebsocketErrorHeaders | (private) | `func parseCodexWebsocketErrorHeaders(payload []...` |
| 1025 | fn | normalizeCodexWebsocketCompletion | (private) | `func normalizeCodexWebsocketCompletion(payload ...` |
| 1035 | fn | encodeCodexWebsocketAsSSE | (private) | `func encodeCodexWebsocketAsSSE(payload []byte) ...` |
| 1045 | fn | websocketUpgradeRequestLog | (private) | `func websocketUpgradeRequestLog(info helps.Upst...` |
| 1063 | fn | recordAPIWebsocketHandshake | (private) | `func recordAPIWebsocketHandshake(ctx context.Co...` |
| 1071 | fn | websocketHandshakeBody | (private) | `func websocketHandshakeBody(resp *http.Response...` |
| 1083 | fn | closeHTTPResponseBody | (private) | `func closeHTTPResponseBody(resp *http.Response,...` |
| 1092 | fn | executionSessionIDFromOptions | (private) | `func executionSessionIDFromOptions(opts cliprox...` |
| 1110 | fn | getOrCreateSession | (private) | `func (e *CodexWebsocketsExecutor) getOrCreateSe...` |
| 1136 | fn | ensureUpstreamConn | (private) | `func (e *CodexWebsocketsExecutor) ensureUpstrea...` |
| 1182 | fn | readUpstreamLoop | (private) | `func (e *CodexWebsocketsExecutor) readUpstreamL...` |
| 1243 | fn | invalidateUpstreamConn | (private) | `func (e *CodexWebsocketsExecutor) invalidateUps...` |
| 1269 | fn | CloseExecutionSession | pub | `func (e *CodexWebsocketsExecutor) CloseExecutio...` |
| 1304 | fn | closeAllExecutionSessions | (private) | `func (e *CodexWebsocketsExecutor) closeAllExecu...` |
| 1328 | fn | closeExecutionSession | (private) | `func (e *CodexWebsocketsExecutor) closeExecutio...` |
| 1332 | fn | closeCodexWebsocketSession | (private) | `func closeCodexWebsocketSession(sess *codexWebs...` |
| 1361 | fn | codexWebsocketSessionStoreKey | (private) | `func codexWebsocketSessionStoreKey(sessionID st...` |
| 1376 | fn | codexWebsocketAuthKey | (private) | `func codexWebsocketAuthKey(auth *cliproxyauth.A...` |
| 1388 | fn | codexWebsocketTransportProfileToken | (private) | `func codexWebsocketTransportProfileToken(auth *...` |
| 1407 | fn | codexWebsocketProxyURL | (private) | `func codexWebsocketProxyURL(auth *cliproxyauth....` |
| 1414 | fn | logCodexWebsocketConnected | (private) | `func logCodexWebsocketConnected(sessionID strin...` |
| 1418 | fn | logCodexWebsocketDisconnected | (private) | `func logCodexWebsocketDisconnected(sessionID st...` |
| 1428 | fn | CloseCodexWebsocketSessionsForAuthID | pub | `func CloseCodexWebsocketSessionsForAuthID(authI...` |
| 1494 | struct | CodexAutoExecutor | pub | - |
| 1499 | fn | NewCodexAutoExecutor | pub | `func NewCodexAutoExecutor(cfg *config.Config) *...` |
| 1506 | fn | Identifier | pub | `func (e *CodexAutoExecutor) Identifier() string...` |
| 1508 | fn | PrepareRequest | pub | `func (e *CodexAutoExecutor) PrepareRequest(req ...` |
| 1515 | fn | HttpRequest | pub | `func (e *CodexAutoExecutor) HttpRequest(ctx con...` |
| 1522 | fn | Execute | pub | `func (e *CodexAutoExecutor) Execute(ctx context...` |
| 1532 | fn | ExecuteStream | pub | `func (e *CodexAutoExecutor) ExecuteStream(ctx c...` |
| 1542 | fn | Refresh | pub | `func (e *CodexAutoExecutor) Refresh(ctx context...` |
| 1549 | fn | CountTokens | pub | `func (e *CodexAutoExecutor) CountTokens(ctx con...` |
| 1556 | fn | CloseExecutionSession | pub | `func (e *CodexAutoExecutor) CloseExecutionSessi...` |
| 1563 | fn | codexWebsocketsEnabled | (private) | `func codexWebsocketsEnabled(auth *cliproxyauth....` |

## Public API

### `NewCodexWebsocketsExecutor`

```
func NewCodexWebsocketsExecutor(cfg *config.Config) *CodexWebsocketsExecutor {
```

**Line:** 82 | **Kind:** fn

### `Execute`

```
func (e *CodexWebsocketsExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 155 | **Kind:** fn

### `ExecuteStream`

```
func (e *CodexWebsocketsExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 363 | **Kind:** fn

### `Headers`

```
func (e statusErrWithHeaders) Headers() http.Header {
```

**Line:** 954 | **Kind:** fn

### `CloseExecutionSession`

```
func (e *CodexWebsocketsExecutor) CloseExecutionSession(sessionID string) {
```

**Line:** 1269 | **Kind:** fn

### `CloseCodexWebsocketSessionsForAuthID`

```
func CloseCodexWebsocketSessionsForAuthID(authID string, reason string) {
```

**Line:** 1428 | **Kind:** fn

### `NewCodexAutoExecutor`

```
func NewCodexAutoExecutor(cfg *config.Config) *CodexAutoExecutor {
```

**Line:** 1499 | **Kind:** fn

### `Identifier`

```
func (e *CodexAutoExecutor) Identifier() string { return "codex" }
```

**Line:** 1506 | **Kind:** fn

### `PrepareRequest`

```
func (e *CodexAutoExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 1508 | **Kind:** fn

### `HttpRequest`

```
func (e *CodexAutoExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 1515 | **Kind:** fn

### `Execute`

```
func (e *CodexAutoExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 1522 | **Kind:** fn

### `ExecuteStream`

```
func (e *CodexAutoExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (*cliproxyexecutor.StreamResult, error) {
```

**Line:** 1532 | **Kind:** fn

### `Refresh`

```
func (e *CodexAutoExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 1542 | **Kind:** fn

### `CountTokens`

```
func (e *CodexAutoExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 1549 | **Kind:** fn

### `CloseExecutionSession`

```
func (e *CodexAutoExecutor) CloseExecutionSession(sessionID string) {
```

**Line:** 1556 | **Kind:** fn

