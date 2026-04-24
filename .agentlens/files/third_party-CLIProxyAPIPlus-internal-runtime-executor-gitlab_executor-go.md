# third_party/CLIProxyAPIPlus/internal/runtime/executor/gitlab_executor.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-runtime-executor/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1320
- **Language:** Go
- **Symbols:** 55
- **Public symbols:** 9

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 35 | struct | GitLabExecutor | pub | - |
| 39 | struct | gitLabPrompt | (private) | - |
| 47 | struct | gitLabOpenAIStreamState | (private) | - |
| 56 | fn | NewGitLabExecutor | pub | `func NewGitLabExecutor(cfg *config.Config) *Git...` |
| 60 | fn | Identifier | pub | `func (e *GitLabExecutor) Identifier() string { ...` |
| 62 | fn | Execute | pub | `func (e *GitLabExecutor) Execute(ctx context.Co...` |
| 105 | fn | ExecuteStream | pub | `func (e *GitLabExecutor) ExecuteStream(ctx cont...` |
| 162 | fn | Refresh | pub | `func (e *GitLabExecutor) Refresh(ctx context.Co...` |
| 209 | fn | CountTokens | pub | `func (e *GitLabExecutor) CountTokens(ctx contex...` |
| 226 | fn | HttpRequest | pub | `func (e *GitLabExecutor) HttpRequest(ctx contex...` |
| 243 | fn | translateToOpenAI | (private) | `func (e *GitLabExecutor) translateToOpenAI(req ...` |
| 248 | fn | nativeGateway | (private) | `func (e *GitLabExecutor) nativeGateway(` |
| 265 | fn | nativeGatewayHTTP | (private) | `func (e *GitLabExecutor) nativeGatewayHTTP(auth...` |
| 275 | fn | invokeText | (private) | `func (e *GitLabExecutor) invokeText(ctx context...` |
| 284 | fn | requestChat | (private) | `func (e *GitLabExecutor) requestChat(ctx contex...` |
| 295 | fn | requestCodeSuggestions | (private) | `func (e *GitLabExecutor) requestCodeSuggestions...` |
| 317 | fn | requestCodeSuggestionsStream | (private) | `func (e *GitLabExecutor) requestCodeSuggestions...` |
| 442 | fn | doJSONTextRequest | (private) | `func (e *GitLabExecutor) doJSONTextRequest(ctx ...` |
| 467 | fn | doJSONRequest | (private) | `func (e *GitLabExecutor) doJSONRequest(` |
| 529 | fn | refreshOAuthToken | (private) | `func (e *GitLabExecutor) refreshOAuthToken(ctx ...` |
| 549 | fn | buildGitLabPrompt | (private) | `func buildGitLabPrompt(payload []byte) gitLabPr...` |
| 623 | fn | openAIContentText | (private) | `func openAIContentText(content gjson.Result) st...` |
| 629 | fn | truncateGitLabPrompt | (private) | `func truncateGitLabPrompt(value string, limit i...` |
| 637 | fn | parseGitLabTextResponse | (private) | `func parseGitLabTextResponse(endpoint string, b...` |
| 660 | fn | applyGitLabRequestHeaders | (private) | `func applyGitLabRequestHeaders(req *http.Reques...` |
| 675 | fn | gitLabGatewayHeaders | (private) | `func gitLabGatewayHeaders(auth *cliproxyauth.Au...` |
| 711 | fn | cloneGitLabStreamHeaders | (private) | `func cloneGitLabStreamHeaders(headers http.Head...` |
| 720 | fn | normalizeGitLabStreamChunk | (private) | `func normalizeGitLabStreamChunk(eventName strin...` |
| 762 | fn | extractGitLabStreamText | (private) | `func extractGitLabStreamText(root gjson.Result)...` |
| 780 | fn | finalizeGitLabStream | (private) | `func finalizeGitLabStream(fallbackModel string,...` |
| 788 | fn | ensureInitialized | (private) | `func (s *gitLabOpenAIStreamState) ensureInitial...` |
| 811 | fn | emitText | (private) | `func (s *gitLabOpenAIStreamState) emitText(text...` |
| 831 | fn | finish | (private) | `func (s *gitLabOpenAIStreamState) finish(reason...` |
| 845 | fn | nextDelta | (private) | `func (s *gitLabOpenAIStreamState) nextDelta(tex...` |
| 868 | fn | buildChunk | (private) | `func (s *gitLabOpenAIStreamState) buildChunk(de...` |
| 890 | fn | shouldFallbackToCodeSuggestions | (private) | `func shouldFallbackToCodeSuggestions(err error)...` |
| 906 | fn | buildGitLabOpenAIResponse | (private) | `func buildGitLabOpenAIResponse(model, text stri...` |
| 931 | fn | buildGitLabOpenAIStream | (private) | `func buildGitLabOpenAIStream(model, text string...` |
| 976 | fn | gitLabUsage | (private) | `func gitLabUsage(model string, translatedReq []...` |
| 992 | fn | buildGitLabAnthropicGatewayAuth | (private) | `func buildGitLabAnthropicGatewayAuth(auth *clip...` |
| 1018 | fn | buildGitLabOpenAIGatewayAuth | (private) | `func buildGitLabOpenAIGatewayAuth(auth *cliprox...` |
| 1044 | fn | gitLabUsesAnthropicGateway | (private) | `func gitLabUsesAnthropicGateway(auth *cliproxya...` |
| 1058 | fn | gitLabUsesOpenAIGateway | (private) | `func gitLabUsesOpenAIGateway(auth *cliproxyauth...` |
| 1072 | fn | inferGitLabProviderFromModel | (private) | `func inferGitLabProviderFromModel(model string)...` |
| 1084 | fn | gitLabAnthropicGatewayBaseURL | (private) | `func gitLabAnthropicGatewayBaseURL(auth *clipro...` |
| 1109 | fn | gitLabOpenAIGatewayBaseURL | (private) | `func gitLabOpenAIGatewayBaseURL(auth *cliproxya...` |
| 1134 | fn | gitLabPrimaryToken | (private) | `func gitLabPrimaryToken(auth *cliproxyauth.Auth...` |
| 1144 | fn | gitLabBaseURL | (private) | `func gitLabBaseURL(auth *cliproxyauth.Auth) str...` |
| 1151 | fn | gitLabResolvedModel | (private) | `func gitLabResolvedModel(auth *cliproxyauth.Aut...` |
| 1169 | fn | gitLabMetadataString | (private) | `func gitLabMetadataString(metadata map[string]a...` |
| 1183 | fn | gitLabOAuthTokenNeedsRefresh | (private) | `func gitLabOAuthTokenNeedsRefresh(metadata map[...` |
| 1195 | fn | applyGitLabTokenMetadata | (private) | `func applyGitLabTokenMetadata(metadata map[stri...` |
| 1216 | fn | mergeGitLabDirectAccessMetadata | (private) | `func mergeGitLabDirectAccessMetadata(metadata m...` |
| 1270 | fn | gitLabAuthKind | (private) | `func gitLabAuthKind(method string) string {` |
| 1279 | fn | GitLabModelsFromAuth | pub | `func GitLabModelsFromAuth(auth *cliproxyauth.Au...` |

## Public API

### `NewGitLabExecutor`

```
func NewGitLabExecutor(cfg *config.Config) *GitLabExecutor {
```

**Line:** 56 | **Kind:** fn

### `Identifier`

```
func (e *GitLabExecutor) Identifier() string { return gitLabProviderKey }
```

**Line:** 60 | **Kind:** fn

### `Execute`

```
func (e *GitLabExecutor) Execute(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (resp cliproxyexecutor.Response, err error) {
```

**Line:** 62 | **Kind:** fn

### `ExecuteStream`

```
func (e *GitLabExecutor) ExecuteStream(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (_ *cliproxyexecutor.StreamResult, err error) {
```

**Line:** 105 | **Kind:** fn

### `Refresh`

```
func (e *GitLabExecutor) Refresh(ctx context.Context, auth *cliproxyauth.Auth) (*cliproxyauth.Auth, error) {
```

**Line:** 162 | **Kind:** fn

### `CountTokens`

```
func (e *GitLabExecutor) CountTokens(ctx context.Context, auth *cliproxyauth.Auth, req cliproxyexecutor.Request, opts cliproxyexecutor.Options) (cliproxyexecutor.Response, error) {
```

**Line:** 209 | **Kind:** fn

### `HttpRequest`

```
func (e *GitLabExecutor) HttpRequest(ctx context.Context, auth *cliproxyauth.Auth, req *http.Request) (*http.Response, error) {
```

**Line:** 226 | **Kind:** fn

### `GitLabModelsFromAuth`

```
func GitLabModelsFromAuth(auth *cliproxyauth.Auth) []*registry.ModelInfo {
```

**Line:** 1279 | **Kind:** fn

