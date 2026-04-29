# third_party/CLIProxyAPIPlus/internal/runtime/executor/github_copilot_executor.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1391
- **Language:** Go
- **Symbols:** 29
- **Public symbols:** 10

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 48 | struct | GitHubCopilotExecutor | pub | - |
| 55 | struct | cachedAPIToken | (private) | - |
| 62 | fn | NewGitHubCopilotExecutor | pub | `func NewGitHubCopilotExecutor(cfg *config.Confi...` |
| 70 | fn | Identifier | pub | `func (e *GitHubCopilotExecutor) Identifier() st...` |
| 73 | fn | PrepareRequest | pub | `func (e *GitHubCopilotExecutor) PrepareRequest(...` |
| 90 | fn | HttpRequest | pub | `func (e *GitHubCopilotExecutor) HttpRequest(ctx...` |
| 106 | fn | Execute | pub | `func (e *GitHubCopilotExecutor) Execute(ctx con...` |
| 236 | fn | ExecuteStream | pub | `func (e *GitHubCopilotExecutor) ExecuteStream(c...` |
| 408 | fn | CountTokens | pub | `func (e *GitHubCopilotExecutor) CountTokens(_ c...` |
| 414 | fn | Refresh | pub | `func (e *GitHubCopilotExecutor) Refresh(ctx con...` |
| 436 | fn | ensureAPIToken | (private) | `func (e *GitHubCopilotExecutor) ensureAPIToken(...` |
| 485 | fn | applyHeaders | (private) | `func (e *GitHubCopilotExecutor) applyHeaders(r ...` |
| 504 | fn | detectLastConversationRole | (private) | `func detectLastConversationRole(body []byte) st...` |
| 542 | fn | detectVisionContent | (private) | `func detectVisionContent(body []byte) bool {` |
| 571 | fn | normalizeModel | (private) | `func (e *GitHubCopilotExecutor) normalizeModel(...` |
| 579 | fn | useGitHubCopilotResponsesEndpoint | (private) | `func useGitHubCopilotResponsesEndpoint(sourceFo...` |
| 590 | fn | flattenAssistantContent | (private) | `func flattenAssistantContent(body []byte) []byte {` |
| 630 | fn | normalizeGitHubCopilotChatTools | (private) | `func normalizeGitHubCopilotChatTools(body []byt...` |
| 659 | fn | normalizeGitHubCopilotResponsesInput | (private) | `func normalizeGitHubCopilotResponsesInput(body ...` |
| 833 | fn | stripGitHubCopilotResponsesUnsupportedFields | (private) | `func stripGitHubCopilotResponsesUnsupportedFiel...` |
| 839 | fn | normalizeGitHubCopilotResponsesTools | (private) | `func normalizeGitHubCopilotResponsesTools(body ...` |
| 918 | fn | isGitHubCopilotResponsesBuiltinTool | (private) | `func isGitHubCopilotResponsesBuiltinTool(toolTy...` |
| 927 | fn | collectTextFromNode | (private) | `func collectTextFromNode(node gjson.Result) str...` |
| 965 | struct | githubCopilotResponsesStreamToolState | (private) | - |
| 971 | struct | githubCopilotResponsesStreamState | (private) | - |
| 984 | fn | translateGitHubCopilotResponsesNonStreamToClaude | (private) | `func translateGitHubCopilotResponsesNonStreamTo...` |
| 1077 | fn | translateGitHubCopilotResponsesStreamToClaude | (private) | `func translateGitHubCopilotResponsesStreamToCla...` |
| 1293 | fn | isHTTPSuccess | (private) | `func isHTTPSuccess(statusCode int) bool {` |
| 1307 | fn | FetchGitHubCopilotModels | pub | `func FetchGitHubCopilotModels(ctx context.Conte...` |

## Public API

### `NewGitHubCopilotExecutor`

```
func NewGitHubCopilotExecutor(cfg *config.Config) *GitHubCopilotExecutor {
```

**Line:** 62 | **Kind:** fn

### `Identifier`

```
func (e *GitHubCopilotExecutor) Identifier() string { return githubCopilotAuthType }
```

**Line:** 70 | **Kind:** fn

### `PrepareRequest`

```
func (e *GitHubCopilotExecutor) PrepareRequest(req *http.Request, auth *cliproxyauth.Auth) error {
```

**Line:** 73 | **Kind:** fn

### `HttpRequest`

```
func (e *GitHubCopilotExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 90 | **Kind:** fn

### `Execute`

```
func (e *GitHubCopilotExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 106 | **Kind:** fn

### `ExecuteStream`

```
func (e *GitHubCopilotExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 236 | **Kind:** fn

### `CountTokens`

```
func (e *GitHubCopilotExecutor) CountTokens(_ context.Context, _ *cliproxyauth.Auth, _ cliproxyexecutor.Request, _ cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 408 | **Kind:** fn

### `Refresh`

```
func (e *GitHubCopilotExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 414 | **Kind:** fn

### `FetchGitHubCopilotModels`

```
func FetchGitHubCopilotModels(ctx context.Context, auth *cliproxyauth.Auth, cfg *config.Config) []*registry.ModelInfo {
```

**Line:** 1307 | **Kind:** fn

