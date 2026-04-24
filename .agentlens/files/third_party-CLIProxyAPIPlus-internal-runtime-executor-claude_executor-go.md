# third_party/CLIProxyAPIPlus/internal/runtime/executor/claude_executor.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-runtime-executor/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1993
- **Language:** Go
- **Symbols:** 55
- **Public symbols:** 11

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 40 | struct | ClaudeExecutor | pub | - |
| 46 | const | claudeToolPrefix | (private) | - |
| 48 | fn | NewClaudeExecutor | pub | `func NewClaudeExecutor(cfg *config.Config) *Cla...` |
| 50 | fn | Identifier | pub | `func (e *ClaudeExecutor) Identifier() string { ...` |
| 53 | fn | PrepareRequest | pub | `func (e *ClaudeExecutor) PrepareRequest(req *ht...` |
| 76 | fn | HttpRequest | pub | `func (e *ClaudeExecutor) HttpRequest(ctx contex...` |
| 91 | fn | Execute | pub | `func (e *ClaudeExecutor) Execute(ctx context.Co...` |
| 259 | fn | ExecuteStream | pub | `func (e *ClaudeExecutor) ExecuteStream(ctx cont...` |
| 455 | fn | CountTokens | pub | `func (e *ClaudeExecutor) CountTokens(ctx contex...` |
| 564 | fn | Refresh | pub | `func (e *ClaudeExecutor) Refresh(ctx context.Co...` |
| 600 | fn | extractAndRemoveBetas | (private) | `func extractAndRemoveBetas(body []byte) ([]stri...` |
| 622 | fn | disableThinkingIfToolChoiceForced | (private) | `func disableThinkingIfToolChoiceForced(body []b...` |
| 638 | struct | compositeReadCloser | (private) | - |
| 643 | fn | Close | pub | `func (c *compositeReadCloser) Close() error {` |
| 658 | struct | peekableBody | (private) | - |
| 663 | fn | Close | pub | `func (p *peekableBody) Close() error {` |
| 667 | fn | decodeResponseBody | (private) | `func decodeResponseBody(body io.ReadCloser, con...` |
| 768 | fn | mapStainlessOS | (private) | `func mapStainlessOS() string {` |
| 784 | fn | mapStainlessArch | (private) | `func mapStainlessArch() string {` |
| 797 | fn | authAttrs | (private) | `func authAttrs(auth *cliproxyauth.Auth) map[str...` |
| 812 | fn | applyClaudeManagedHeaders | (private) | `func applyClaudeManagedHeaders(r *http.Request,...` |
| 823 | fn | claudeManagedHeaderValue | (private) | `func claudeManagedHeaderValue(auth *cliproxyaut...` |
| 833 | fn | claudeManagedHeaderValueFromMetadata | (private) | `func claudeManagedHeaderValueFromMetadata(metad...` |
| 864 | fn | claudeManagedHeaderValueFromAttrs | (private) | `func claudeManagedHeaderValueFromAttrs(attrs ma...` |
| 880 | fn | applyClaudeHeaders | (private) | `func applyClaudeHeaders(r *http.Request, auth *...` |
| 992 | fn | claudeCreds | (private) | `func claudeCreds(a *cliproxyauth.Auth) (apiKey,...` |
| 1008 | fn | checkSystemInstructions | (private) | `func checkSystemInstructions(payload []byte) []...` |
| 1012 | fn | isClaudeOAuthToken | (private) | `func isClaudeOAuthToken(apiKey string) bool {` |
| 1016 | fn | applyClaudeToolPrefix | (private) | `func applyClaudeToolPrefix(body []byte, prefix ...` |
| 1103 | fn | stripClaudeToolPrefixFromResponse | (private) | `func stripClaudeToolPrefixFromResponse(body []b...` |
| 1149 | fn | stripClaudeToolPrefixFromStreamLine | (private) | `func stripClaudeToolPrefixFromStreamLine(line [...` |
| 1197 | fn | getClientUserAgent | (private) | `func getClientUserAgent(ctx context.Context) st...` |
| 1206 | fn | getCloakConfigFromAuth | (private) | `func getCloakConfigFromAuth(auth *cliproxyauth....` |
| 1232 | fn | resolveClaudeKeyCloakConfig | (private) | `func resolveClaudeKeyCloakConfig(cfg *config.Co...` |
| 1262 | fn | injectFakeUserID | (private) | `func injectFakeUserID(payload []byte, apiKey st...` |
| 1286 | fn | generateBillingHeader | (private) | `func generateBillingHeader(payload []byte) stri...` |
| 1305 | fn | checkSystemInstructionsWithMode | (private) | `func checkSystemInstructionsWithMode(payload []...` |
| 1359 | fn | applyCloaking | (private) | `func applyCloaking(ctx context.Context, cfg *co...` |
| 1430 | fn | ensureCacheControl | (private) | `func ensureCacheControl(payload []byte) []byte {` |
| 1446 | fn | countCacheControls | (private) | `func countCacheControls(payload []byte) int {` |
| 1491 | fn | parsePayloadObject | (private) | `func parsePayloadObject(payload []byte) (map[st...` |
| 1502 | fn | marshalPayloadObject | (private) | `func marshalPayloadObject(original []byte, root...` |
| 1513 | fn | asObject | (private) | `func asObject(v any) (map[string]any, bool) {` |
| 1518 | fn | asArray | (private) | `func asArray(v any) ([]any, bool) {` |
| 1523 | fn | countCacheControlsMap | (private) | `func countCacheControlsMap(root map[string]any)...` |
| 1569 | fn | normalizeTTLForBlock | (private) | `func normalizeTTLForBlock(obj map[string]any, s...` |
| 1592 | fn | findLastCacheControlIndex | (private) | `func findLastCacheControlIndex(arr []any) int {` |
| 1606 | fn | stripCacheControlExceptIndex | (private) | `func stripCacheControlExceptIndex(arr []any, pr...` |
| 1622 | fn | stripAllCacheControl | (private) | `func stripAllCacheControl(arr []any, excess *in...` |
| 1638 | fn | stripMessageCacheControl | (private) | `func stripMessageCacheControl(messages []any, e...` |
| 1678 | fn | normalizeCacheControlTTL | (private) | `func normalizeCacheControlTTL(payload []byte) [...` |
| 1749 | fn | enforceCacheControlLimit | (private) | `func enforceCacheControlLimit(payload []byte, m...` |
| 1816 | fn | injectMessagesCacheControl | (private) | `func injectMessagesCacheControl(payload []byte)...` |
| 1900 | fn | injectToolsCacheControl | (private) | `func injectToolsCacheControl(payload []byte) []...` |
| 1938 | fn | injectSystemCacheControl | (private) | `func injectSystemCacheControl(payload []byte) [...` |

## Public API

### `NewClaudeExecutor`

```
func NewClaudeExecutor(cfg *config.Config) *ClaudeExecutor { return &ClaudeExecutor{cfg: cfg} }
```

**Line:** 48 | **Kind:** fn

### `Identifier`

```
func (e *ClaudeExecutor) Identifier() string { return "claude" }
```

**Line:** 50 | **Kind:** fn

### `PrepareRequest`

```
func (e *ClaudeExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 53 | **Kind:** fn

### `HttpRequest`

```
func (e *ClaudeExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 76 | **Kind:** fn

### `Execute`

```
func (e *ClaudeExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 91 | **Kind:** fn

### `ExecuteStream`

```
func (e *ClaudeExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 259 | **Kind:** fn

### `CountTokens`

```
func (e *ClaudeExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 455 | **Kind:** fn

### `Refresh`

```
func (e *ClaudeExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 564 | **Kind:** fn

### `Close`

```
func (c *compositeReadCloser) Close() error {
```

**Line:** 643 | **Kind:** fn

### `Close`

```
func (p *peekableBody) Close() error {
```

**Line:** 663 | **Kind:** fn

## Memory Markers

### 🔴 `RULE` (line 1421)

> Anthropic's documentation, cache prefixes are created in order: tools -> system -> messages.

