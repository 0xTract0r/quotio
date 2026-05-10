# third_party/CLIProxyAPIPlus/internal/runtime/executor/claude_executor.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2480
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
| 131 | fn | Execute | pub | `func (e *ClaudeExecutor) Execute(ctx context.Co...` |
| 314 | fn | ExecuteStream | pub | `func (e *ClaudeExecutor) ExecuteStream(ctx cont...` |
| 528 | fn | CountTokens | pub | `func (e *ClaudeExecutor) CountTokens(ctx contex...` |
| 641 | fn | Refresh | pub | `func (e *ClaudeExecutor) Refresh(ctx context.Co...` |
| 677 | fn | extractAndRemoveBetas | (private) | `func extractAndRemoveBetas(body []byte) ([]stri...` |
| 699 | fn | disableThinkingIfToolChoiceForced | (private) | `func disableThinkingIfToolChoiceForced(body []b...` |
| 718 | fn | normalizeClaudeTemperatureForThinking | (private) | `func normalizeClaudeTemperatureForThinking(body...` |
| 734 | struct | compositeReadCloser | (private) | - |
| 739 | fn | Close | pub | `func (c *compositeReadCloser) Close() error {` |
| 754 | struct | peekableBody | (private) | - |
| 759 | fn | Close | pub | `func (p *peekableBody) Close() error {` |
| 763 | fn | decodeResponseBody | (private) | `func decodeResponseBody(body io.ReadCloser, con...` |
| 864 | fn | mapStainlessOS | (private) | `func mapStainlessOS() string {` |
| 880 | fn | mapStainlessArch | (private) | `func mapStainlessArch() string {` |
| 893 | fn | authAttrs | (private) | `func authAttrs(auth *cliproxyauth.Auth) map[str...` |
| 908 | fn | applyClaudeManagedHeaders | (private) | `func applyClaudeManagedHeaders(r *http.Request,...` |
| 923 | fn | claudeManagedHeaderValue | (private) | `func claudeManagedHeaderValue(auth *cliproxyaut...` |
| 933 | fn | claudeManagedHeaderValueFromMetadata | (private) | `func claudeManagedHeaderValueFromMetadata(metad...` |
| 964 | fn | claudeManagedHeaderValueFromAttrs | (private) | `func claudeManagedHeaderValueFromAttrs(attrs ma...` |
| 980 | fn | applyClaudeHeaders | (private) | `func applyClaudeHeaders(r *http.Request, auth *...` |
| 1087 | fn | claudeCreds | (private) | `func claudeCreds(a *cliproxyauth.Auth) (apiKey,...` |
| 1103 | fn | checkSystemInstructions | (private) | `func checkSystemInstructions(payload []byte) []...` |
| 1107 | fn | isClaudeOAuthToken | (private) | `func isClaudeOAuthToken(apiKey string) bool {` |
| 1113 | fn | remapOAuthToolNames | (private) | `func remapOAuthToolNames(body []byte) ([]byte, ...` |
| 1215 | fn | reverseRemapOAuthToolNames | (private) | `func reverseRemapOAuthToolNames(body []byte) []...` |
| 1241 | fn | reverseRemapOAuthToolNamesFromStreamLine | (private) | `func reverseRemapOAuthToolNamesFromStreamLine(l...` |
| 1285 | fn | applyClaudeToolPrefix | (private) | `func applyClaudeToolPrefix(body []byte, prefix ...` |
| 1372 | fn | stripClaudeToolPrefixFromResponse | (private) | `func stripClaudeToolPrefixFromResponse(body []b...` |
| 1418 | fn | stripClaudeToolPrefixFromStreamLine | (private) | `func stripClaudeToolPrefixFromStreamLine(line [...` |
| 1466 | fn | getClientUserAgent | (private) | `func getClientUserAgent(ctx context.Context) st...` |
| 1475 | fn | getCloakConfigFromAuth | (private) | `func getCloakConfigFromAuth(auth *cliproxyauth....` |
| 1502 | fn | injectFakeUserID | (private) | `func injectFakeUserID(payload []byte, apiKey st...` |
| 1526 | const | fingerprintSalt | (private) | - |
| 1528 | fn | computeFingerprint | (private) | `func computeFingerprint(messageText, version st...` |
| 1544 | fn | generateBillingHeader | (private) | `func generateBillingHeader(payload []byte, expe...` |
| 1563 | fn | checkSystemInstructionsWithMode | (private) | `func checkSystemInstructionsWithMode(payload []...` |
| 1567 | fn | checkSystemInstructionsWithSigningMode | (private) | `func checkSystemInstructionsWithSigningMode(pay...` |
| 1633 | fn | sanitizeForwardedSystemPrompt | (private) | `func sanitizeForwardedSystemPrompt(text string)...` |
| 1642 | fn | buildTextBlock | (private) | `func buildTextBlock(text string, cacheControl m...` |
| 1656 | fn | prependToFirstUserMessage | (private) | `func prependToFirstUserMessage(payload []byte, ...` |
| 1704 | fn | applyCloaking | (private) | `func applyCloaking(ctx context.Context, cfg *co...` |
| 1775 | fn | ensureCacheControl | (private) | `func ensureCacheControl(payload []byte) []byte {` |
| 1791 | fn | ensureModelMaxTokens | (private) | `func ensureModelMaxTokens(body []byte, modelID ...` |
| 1814 | fn | countCacheControls | (private) | `func countCacheControls(payload []byte) int {` |
| 1859 | fn | parsePayloadObject | (private) | `func parsePayloadObject(payload []byte) (map[st...` |
| 1870 | fn | marshalPayloadObject | (private) | `func marshalPayloadObject(original []byte, root...` |
| 1881 | fn | asObject | (private) | `func asObject(v any) (map[string]any, bool) {` |
| 1886 | fn | asArray | (private) | `func asArray(v any) ([]any, bool) {` |
| 1891 | fn | countCacheControlsMap | (private) | `func countCacheControlsMap(root map[string]any)...` |
| 1937 | fn | normalizeTTLForBlock | (private) | `func normalizeTTLForBlock(obj map[string]any, s...` |
| 1960 | fn | findLastCacheControlIndex | (private) | `func findLastCacheControlIndex(arr []any) int {` |
| 1974 | fn | stripCacheControlExceptIndex | (private) | `func stripCacheControlExceptIndex(arr []any, pr...` |
| 1990 | fn | stripAllCacheControl | (private) | `func stripAllCacheControl(arr []any, excess *in...` |
| 2006 | fn | stripMessageCacheControl | (private) | `func stripMessageCacheControl(messages []any, e...` |
| 2046 | fn | normalizeCacheControlTTL | (private) | `func normalizeCacheControlTTL(payload []byte) [...` |
| 2134 | fn | enforceCacheControlLimit | (private) | `func enforceCacheControlLimit(payload []byte, m...` |
| 2303 | fn | injectMessagesCacheControl | (private) | `func injectMessagesCacheControl(payload []byte)...` |
| 2387 | fn | injectToolsCacheControl | (private) | `func injectToolsCacheControl(payload []byte) []...` |
| 2425 | fn | injectSystemCacheControl | (private) | `func injectSystemCacheControl(payload []byte) [...` |

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

**Line:** 131 | **Kind:** fn

### `ExecuteStream`

```
func (e *ClaudeExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 314 | **Kind:** fn

### `CountTokens`

```
func (e *ClaudeExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 528 | **Kind:** fn

### `Refresh`

```
func (e *ClaudeExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 641 | **Kind:** fn

### `Close`

```
func (c *compositeReadCloser) Close() error {
```

**Line:** 739 | **Kind:** fn

### `Close`

```
func (p *peekableBody) Close() error {
```

**Line:** 759 | **Kind:** fn

## Memory Markers

### 🔴 `RULE` (line 1766)

> Anthropic's documentation, cache prefixes are created in order: tools -> system -> messages.

