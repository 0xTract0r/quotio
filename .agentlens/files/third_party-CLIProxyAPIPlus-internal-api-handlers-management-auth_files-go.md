# third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-api-handlers-management/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 3826
- **Language:** Go
- **Symbols:** 75
- **Public symbols:** 25

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 63 | struct | callbackForwarder | (private) | - |
| 74 | fn | extractLastRefreshTimestamp | (private) | `func extractLastRefreshTimestamp(meta map[strin...` |
| 88 | fn | parseLastRefreshValue | (private) | `func parseLastRefreshValue(v any) (time.Time, b...` |
| 127 | fn | isWebUIRequest | (private) | `func isWebUIRequest(c *gin.Context) bool {` |
| 140 | fn | startCallbackForwarder | (private) | `func startCallbackForwarder(port int, provider,...` |
| 200 | fn | stopCallbackForwarderInstance | (private) | `func stopCallbackForwarderInstance(port int, fo...` |
| 213 | fn | stopForwarderInstance | (private) | `func stopForwarderInstance(port int, forwarder ...` |
| 233 | fn | managementCallbackURL | (private) | `func (h *Handler) managementCallbackURL(path st...` |
| 247 | fn | ListAuthFiles | pub | `func (h *Handler) ListAuthFiles(c *gin.Context) {` |
| 272 | fn | GetAuthFileModels | pub | `func (h *Handler) GetAuthFileModels(c *gin.Cont...` |
| 320 | fn | listAuthFilesFromDisk | (private) | `func (h *Handler) listAuthFilesFromDisk(c *gin....` |
| 368 | fn | buildAuthFileEntry | (private) | `func (h *Handler) buildAuthFileEntry(auth *core...` |
| 477 | fn | extractCodexIDTokenClaims | (private) | `func extractCodexIDTokenClaims(auth *coreauth.A...` |
| 517 | fn | authEmail | (private) | `func authEmail(auth *coreauth.Auth) string {` |
| 537 | fn | authAttribute | (private) | `func authAttribute(auth *coreauth.Auth, key str...` |
| 544 | fn | isRuntimeOnlyAuth | (private) | `func isRuntimeOnlyAuth(auth *coreauth.Auth) bool {` |
| 551 | fn | isUnsafeAuthFileName | (private) | `func isUnsafeAuthFileName(name string) bool {` |
| 561 | fn | findAuthByNameOrID | (private) | `func (h *Handler) findAuthByNameOrID(name strin...` |
| 598 | fn | DownloadAuthFile | pub | `func (h *Handler) DownloadAuthFile(c *gin.Conte...` |
| 623 | fn | UploadAuthFile | pub | `func (h *Handler) UploadAuthFile(c *gin.Context) {` |
| 689 | fn | DeleteAuthFile | pub | `func (h *Handler) DeleteAuthFile(c *gin.Context) {` |
| 767 | fn | findAuthForDelete | (private) | `func (h *Handler) findAuthForDelete(name string...` |
| 793 | fn | authIDForPath | (private) | `func (h *Handler) authIDForPath(path string) st...` |
| 814 | fn | buildAuthFromFileData | (private) | `func (h *Handler) buildAuthFromFileData(path st...` |
| 864 | fn | registerAuthFromFile | (private) | `func (h *Handler) registerAuthFromFile(ctx cont...` |
| 929 | fn | sanitizedHeaders | (private) | `func sanitizedHeaders(headers map[string]string...` |
| 948 | fn | replaceAuthMetadataHeaders | (private) | `func replaceAuthMetadataHeaders(auth *coreauth....` |
| 977 | struct | refreshAuthFileStatusRequest | (private) | - |
| 982 | const | authStatusRefreshFailureBackoff | (private) | - |
| 985 | fn | RefreshAuthFileStatus | pub | `func (h *Handler) RefreshAuthFileStatus(c *gin....` |
| 1048 | fn | refreshAuthStatus | (private) | `func (h *Handler) refreshAuthStatus(ctx context...` |
| 1103 | fn | preserveAuthIdentity | (private) | `func preserveAuthIdentity(updated, current *cor...` |
| 1130 | fn | normalizeAuthRefreshError | (private) | `func normalizeAuthRefreshError(err error) *core...` |
| 1149 | fn | errorString | (private) | `func errorString(err error) string {` |
| 1157 | fn | PatchAuthFileStatus | pub | `func (h *Handler) PatchAuthFileStatus(c *gin.Co...` |
| 1223 | fn | PatchAuthFileFields | pub | `func (h *Handler) PatchAuthFileFields(c *gin.Co...` |
| 1326 | fn | disableAuth | (private) | `func (h *Handler) disableAuth(ctx context.Conte...` |
| 1355 | fn | deleteTokenRecord | (private) | `func (h *Handler) deleteTokenRecord(ctx context...` |
| 1366 | fn | tokenStoreWithBaseDir | (private) | `func (h *Handler) tokenStoreWithBaseDir() corea...` |
| 1383 | fn | saveTokenRecord | (private) | `func (h *Handler) saveTokenRecord(ctx context.C...` |
| 1399 | fn | gitLabBaseURLFromRequest | (private) | `func gitLabBaseURLFromRequest(c *gin.Context) s...` |
| 1411 | fn | buildGitLabAuthMetadata | (private) | `func buildGitLabAuthMetadata(baseURL, mode stri...` |
| 1438 | fn | mergeGitLabDirectAccessMetadata | (private) | `func mergeGitLabDirectAccessMetadata(metadata m...` |
| 1493 | fn | primaryGitLabEmail | (private) | `func primaryGitLabEmail(user *gitlabauth.User) ...` |
| 1503 | fn | gitLabAccountIdentifier | (private) | `func gitLabAccountIdentifier(user *gitlabauth.U...` |
| 1515 | fn | sanitizeGitLabFileName | (private) | `func sanitizeGitLabFileName(value string) string {` |
| 1547 | fn | maskGitLabToken | (private) | `func maskGitLabToken(token string) string {` |
| 1558 | fn | RequestAnthropicToken | pub | `func (h *Handler) RequestAnthropicToken(c *gin....` |
| 1703 | fn | RequestGeminiCLIToken | pub | `func (h *Handler) RequestGeminiCLIToken(c *gin....` |
| 1962 | fn | RequestCodexToken | pub | `func (h *Handler) RequestCodexToken(c *gin.Cont...` |
| 2108 | fn | RequestGitLabToken | pub | `func (h *Handler) RequestGitLabToken(c *gin.Con...` |
| 2266 | fn | RequestGitLabPATToken | pub | `func (h *Handler) RequestGitLabPATToken(c *gin....` |
| 2365 | fn | RequestAntigravityToken | pub | `func (h *Handler) RequestAntigravityToken(c *gi...` |
| 2530 | fn | RequestQwenToken | pub | `func (h *Handler) RequestQwenToken(c *gin.Conte...` |
| 2586 | fn | RequestKimiToken | pub | `func (h *Handler) RequestKimiToken(c *gin.Conte...` |
| 2663 | fn | RequestIFlowToken | pub | `func (h *Handler) RequestIFlowToken(c *gin.Cont...` |
| 2777 | fn | RequestGitHubToken | pub | `func (h *Handler) RequestGitHubToken(c *gin.Con...` |
| 2873 | fn | copilotTokenMetadata | (private) | `func copilotTokenMetadata(storage *copilot.Copi...` |
| 2888 | fn | RequestIFlowCookieToken | pub | `func (h *Handler) RequestIFlowCookieToken(c *gi...` |
| 2983 | struct | projectSelectionRequiredError | (private) | - |
| 2985 | fn | Error | pub | `func (e *projectSelectionRequiredError) Error()...` |
| 2989 | fn | ensureGeminiProjectAndOnboard | (private) | `func ensureGeminiProjectAndOnboard(ctx context....` |
| 3023 | fn | onboardAllGeminiProjects | (private) | `func onboardAllGeminiProjects(ctx context.Conte...` |
| 3057 | fn | ensureGeminiProjectsEnabled | (private) | `func ensureGeminiProjectsEnabled(ctx context.Co...` |
| 3074 | fn | performGeminiCLISetup | (private) | `func performGeminiCLISetup(ctx context.Context,...` |
| 3235 | fn | callGeminiCLI | (private) | `func callGeminiCLI(ctx context.Context, httpCli...` |
| 3284 | fn | fetchGCPProjects | (private) | `func fetchGCPProjects(ctx context.Context, http...` |
| 3313 | fn | checkCloudAPIIsEnabled | (private) | `func checkCloudAPIIsEnabled(ctx context.Context...` |
| 3373 | fn | GetAuthStatus | pub | `func (h *Handler) GetAuthStatus(c *gin.Context) {` |
| 3419 | fn | CancelOAuthSession | pub | `func (h *Handler) CancelOAuthSession(c *gin.Con...` |
| 3438 | fn | PopulateAuthContext | pub | `func PopulateAuthContext(ctx context.Context, c...` |
| 3446 | const | kiroCallbackPort | (private) | - |
| 3448 | fn | RequestKiroToken | pub | `func (h *Handler) RequestKiroToken(c *gin.Conte...` |
| 3730 | fn | generateKiroPKCE | (private) | `func generateKiroPKCE() (verifier, challenge st...` |
| 3743 | fn | RequestKiloToken | pub | `func (h *Handler) RequestKiloToken(c *gin.Conte...` |

## Public API

### `ListAuthFiles`

```
func (h *Handler) ListAuthFiles(c *gin.Context) {
```

**Line:** 247 | **Kind:** fn

### `GetAuthFileModels`

```
func (h *Handler) GetAuthFileModels(c *gin.Context) {
```

**Line:** 272 | **Kind:** fn

### `DownloadAuthFile`

```
func (h *Handler) DownloadAuthFile(c *gin.Context) {
```

**Line:** 598 | **Kind:** fn

### `UploadAuthFile`

```
func (h *Handler) UploadAuthFile(c *gin.Context) {
```

**Line:** 623 | **Kind:** fn

### `DeleteAuthFile`

```
func (h *Handler) DeleteAuthFile(c *gin.Context) {
```

**Line:** 689 | **Kind:** fn

### `RefreshAuthFileStatus`

```
func (h *Handler) RefreshAuthFileStatus(c *gin.Context) {
```

**Line:** 985 | **Kind:** fn

### `PatchAuthFileStatus`

```
func (h *Handler) PatchAuthFileStatus(c *gin.Context) {
```

**Line:** 1157 | **Kind:** fn

### `PatchAuthFileFields`

```
func (h *Handler) PatchAuthFileFields(c *gin.Context) {
```

**Line:** 1223 | **Kind:** fn

### `RequestAnthropicToken`

```
func (h *Handler) RequestAnthropicToken(c *gin.Context) {
```

**Line:** 1558 | **Kind:** fn

### `RequestGeminiCLIToken`

```
func (h *Handler) RequestGeminiCLIToken(c *gin.Context) {
```

**Line:** 1703 | **Kind:** fn

### `RequestCodexToken`

```
func (h *Handler) RequestCodexToken(c *gin.Context) {
```

**Line:** 1962 | **Kind:** fn

### `RequestGitLabToken`

```
func (h *Handler) RequestGitLabToken(c *gin.Context) {
```

**Line:** 2108 | **Kind:** fn

### `RequestGitLabPATToken`

```
func (h *Handler) RequestGitLabPATToken(c *gin.Context) {
```

**Line:** 2266 | **Kind:** fn

### `RequestAntigravityToken`

```
func (h *Handler) RequestAntigravityToken(c *gin.Context) {
```

**Line:** 2365 | **Kind:** fn

### `RequestQwenToken`

```
func (h *Handler) RequestQwenToken(c *gin.Context) {
```

**Line:** 2530 | **Kind:** fn

### `RequestKimiToken`

```
func (h *Handler) RequestKimiToken(c *gin.Context) {
```

**Line:** 2586 | **Kind:** fn

### `RequestIFlowToken`

```
func (h *Handler) RequestIFlowToken(c *gin.Context) {
```

**Line:** 2663 | **Kind:** fn

### `RequestGitHubToken`

```
func (h *Handler) RequestGitHubToken(c *gin.Context) {
```

**Line:** 2777 | **Kind:** fn

### `RequestIFlowCookieToken`

```
func (h *Handler) RequestIFlowCookieToken(c *gin.Context) {
```

**Line:** 2888 | **Kind:** fn

### `Error`

```
func (e *projectSelectionRequiredError) Error() string {
```

**Line:** 2985 | **Kind:** fn

### `GetAuthStatus`

```
func (h *Handler) GetAuthStatus(c *gin.Context) {
```

**Line:** 3373 | **Kind:** fn

### `CancelOAuthSession`

```
func (h *Handler) CancelOAuthSession(c *gin.Context) {
```

**Line:** 3419 | **Kind:** fn

### `PopulateAuthContext`

```
func PopulateAuthContext(ctx context.Context, c *gin.Context) context.Context {
```

**Line:** 3438 | **Kind:** fn

### `RequestKiroToken`

```
func (h *Handler) RequestKiroToken(c *gin.Context) {
```

**Line:** 3448 | **Kind:** fn

### `RequestKiloToken`

```
func (h *Handler) RequestKiloToken(c *gin.Context) {
```

**Line:** 3743 | **Kind:** fn

