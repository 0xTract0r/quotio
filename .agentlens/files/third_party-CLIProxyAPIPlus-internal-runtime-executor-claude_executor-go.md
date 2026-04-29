# third_party/CLIProxyAPIPlus/internal/runtime/executor/claude_executor.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2476
- **Language:** Go
- **Symbols:** 66
- **Public symbols:** 11

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 42 | struct | ClaudeExecutor | pub | - |
| 48 | const | claudeToolPrefix | (private) | - |
| 84 | const | defaultModelMaxTokens | (private) | - |
| 86 | fn | NewClaudeExecutor | pub | `func NewClaudeExecutor(cfg *config.Config) *Cla...` |
| 88 | fn | Identifier | pub | `func (e *ClaudeExecutor) Identifier() string { ...` |
| 91 | fn | PrepareRequest | pub | `func (e *ClaudeExecutor) PrepareRequest(req *ht...` |
| 115 | fn | HttpRequest | pub | `func (e *ClaudeExecutor) HttpRequest(ctx contex...` |
| 130 | fn | Execute | pub | `func (e *ClaudeExecutor) Execute(ctx context.Co...` |
| 312 | fn | ExecuteStream | pub | `func (e *ClaudeExecutor) ExecuteStream(ctx cont...` |
| 525 | fn | CountTokens | pub | `func (e *ClaudeExecutor) CountTokens(ctx contex...` |
| 637 | fn | Refresh | pub | `func (e *ClaudeExecutor) Refresh(ctx context.Co...` |
| 673 | fn | extractAndRemoveBetas | (private) | `func extractAndRemoveBetas(body []byte) ([]stri...` |
| 695 | fn | disableThinkingIfToolChoiceForced | (private) | `func disableThinkingIfToolChoiceForced(body []b...` |
| 714 | fn | normalizeClaudeTemperatureForThinking | (private) | `func normalizeClaudeTemperatureForThinking(body...` |
| 730 | struct | compositeReadCloser | (private) | - |
| 735 | fn | Close | pub | `func (c *compositeReadCloser) Close() error {` |
| 750 | struct | peekableBody | (private) | - |
| 755 | fn | Close | pub | `func (p *peekableBody) Close() error {` |
| 759 | fn | decodeResponseBody | (private) | `func decodeResponseBody(body io.ReadCloser, con...` |
| 860 | fn | mapStainlessOS | (private) | `func mapStainlessOS() string {` |
| 876 | fn | mapStainlessArch | (private) | `func mapStainlessArch() string {` |
| 889 | fn | authAttrs | (private) | `func authAttrs(auth *cliproxyauth.Auth) map[str...` |
| 904 | fn | applyClaudeManagedHeaders | (private) | `func applyClaudeManagedHeaders(r *http.Request,...` |
| 919 | fn | claudeManagedHeaderValue | (private) | `func claudeManagedHeaderValue(auth *cliproxyaut...` |
| 929 | fn | claudeManagedHeaderValueFromMetadata | (private) | `func claudeManagedHeaderValueFromMetadata(metad...` |
| 960 | fn | claudeManagedHeaderValueFromAttrs | (private) | `func claudeManagedHeaderValueFromAttrs(attrs ma...` |
| 976 | fn | applyClaudeHeaders | (private) | `func applyClaudeHeaders(r *http.Request, auth *...` |
| 1083 | fn | claudeCreds | (private) | `func claudeCreds(a *cliproxyauth.Auth) (apiKey,...` |
| 1099 | fn | checkSystemInstructions | (private) | `func checkSystemInstructions(payload []byte) []...` |
| 1103 | fn | isClaudeOAuthToken | (private) | `func isClaudeOAuthToken(apiKey string) bool {` |
| 1109 | fn | remapOAuthToolNames | (private) | `func remapOAuthToolNames(body []byte) ([]byte, ...` |
| 1211 | fn | reverseRemapOAuthToolNames | (private) | `func reverseRemapOAuthToolNames(body []byte) []...` |
| 1237 | fn | reverseRemapOAuthToolNamesFromStreamLine | (private) | `func reverseRemapOAuthToolNamesFromStreamLine(l...` |
| 1281 | fn | applyClaudeToolPrefix | (private) | `func applyClaudeToolPrefix(body []byte, prefix ...` |
| 1368 | fn | stripClaudeToolPrefixFromResponse | (private) | `func stripClaudeToolPrefixFromResponse(body []b...` |
| 1414 | fn | stripClaudeToolPrefixFromStreamLine | (private) | `func stripClaudeToolPrefixFromStreamLine(line [...` |
| 1462 | fn | getClientUserAgent | (private) | `func getClientUserAgent(ctx context.Context) st...` |
| 1471 | fn | getCloakConfigFromAuth | (private) | `func getCloakConfigFromAuth(auth *cliproxyauth....` |
| 1498 | fn | injectFakeUserID | (private) | `func injectFakeUserID(payload []byte, apiKey st...` |
| 1522 | const | fingerprintSalt | (private) | - |
| 1524 | fn | computeFingerprint | (private) | `func computeFingerprint(messageText, version st...` |
| 1540 | fn | generateBillingHeader | (private) | `func generateBillingHeader(payload []byte, expe...` |
| 1559 | fn | checkSystemInstructionsWithMode | (private) | `func checkSystemInstructionsWithMode(payload []...` |
| 1563 | fn | checkSystemInstructionsWithSigningMode | (private) | `func checkSystemInstructionsWithSigningMode(pay...` |
| 1629 | fn | sanitizeForwardedSystemPrompt | (private) | `func sanitizeForwardedSystemPrompt(text string)...` |
| 1638 | fn | buildTextBlock | (private) | `func buildTextBlock(text string, cacheControl m...` |
| 1652 | fn | prependToFirstUserMessage | (private) | `func prependToFirstUserMessage(payload []byte, ...` |
| 1700 | fn | applyCloaking | (private) | `func applyCloaking(ctx context.Context, cfg *co...` |
| 1771 | fn | ensureCacheControl | (private) | `func ensureCacheControl(payload []byte) []byte {` |
| 1787 | fn | ensureModelMaxTokens | (private) | `func ensureModelMaxTokens(body []byte, modelID ...` |
| 1810 | fn | countCacheControls | (private) | `func countCacheControls(payload []byte) int {` |
| 1855 | fn | parsePayloadObject | (private) | `func parsePayloadObject(payload []byte) (map[st...` |
| 1866 | fn | marshalPayloadObject | (private) | `func marshalPayloadObject(original []byte, root...` |
| 1877 | fn | asObject | (private) | `func asObject(v any) (map[string]any, bool) {` |
| 1882 | fn | asArray | (private) | `func asArray(v any) ([]any, bool) {` |
| 1887 | fn | countCacheControlsMap | (private) | `func countCacheControlsMap(root map[string]any)...` |
| 1933 | fn | normalizeTTLForBlock | (private) | `func normalizeTTLForBlock(obj map[string]any, s...` |
| 1956 | fn | findLastCacheControlIndex | (private) | `func findLastCacheControlIndex(arr []any) int {` |
| 1970 | fn | stripCacheControlExceptIndex | (private) | `func stripCacheControlExceptIndex(arr []any, pr...` |
| 1986 | fn | stripAllCacheControl | (private) | `func stripAllCacheControl(arr []any, excess *in...` |
| 2002 | fn | stripMessageCacheControl | (private) | `func stripMessageCacheControl(messages []any, e...` |
| 2042 | fn | normalizeCacheControlTTL | (private) | `func normalizeCacheControlTTL(payload []byte) [...` |
| 2130 | fn | enforceCacheControlLimit | (private) | `func enforceCacheControlLimit(payload []byte, m...` |
| 2299 | fn | injectMessagesCacheControl | (private) | `func injectMessagesCacheControl(payload []byte)...` |
| 2383 | fn | injectToolsCacheControl | (private) | `func injectToolsCacheControl(payload []byte) []...` |
| 2421 | fn | injectSystemCacheControl | (private) | `func injectSystemCacheControl(payload []byte) [...` |

## Public API

### `NewClaudeExecutor`

```
func NewClaudeExecutor(cfg *config.Config) *ClaudeExecutor { return &ClaudeExecutor{cfg: cfg} }
```

**Line:** 86 | **Kind:** fn

### `Identifier`

```
func (e *ClaudeExecutor) Identifier() string { return "claude" }
```

**Line:** 88 | **Kind:** fn

### `PrepareRequest`

```
func (e *ClaudeExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 91 | **Kind:** fn

### `HttpRequest`

```
func (e *ClaudeExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 115 | **Kind:** fn

### `Execute`

```
func (e *ClaudeExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 130 | **Kind:** fn

### `ExecuteStream`

```
func (e *ClaudeExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 312 | **Kind:** fn

### `CountTokens`

```
func (e *ClaudeExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 525 | **Kind:** fn

### `Refresh`

```
func (e *ClaudeExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 637 | **Kind:** fn

### `Close`

```
func (c *compositeReadCloser) Close() error {
```

**Line:** 735 | **Kind:** fn

### `Close`

```
func (p *peekableBody) Close() error {
```

**Line:** 755 | **Kind:** fn

## Memory Markers

### 🔴 `RULE` (line 1762)

> Anthropic's documentation, cache prefixes are created in order: tools -> system -> messages.

