# third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-api-handlers-management/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 4817
- **Language:** Go
- **Symbols:** 115
- **Public symbols:** 27

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 67 | struct | authFileManagedHeaderProjection | (private) | - |
| 75 | struct | authFileManagedHeaderHistoryEntry | (private) | - |
| 84 | struct | authFileManagedHeaderState | (private) | - |
| 90 | struct | authFileAccountSettingsStored | (private) | - |
| 98 | struct | authFileAccountSettingsView | (private) | - |
| 111 | struct | authFileAccountSettingsActivation | (private) | - |
| 118 | struct | authFileAccountSettingsResponse | (private) | - |
| 123 | struct | callbackForwarder | (private) | - |
| 136 | fn | extractLastRefreshTimestamp | (private) | `func extractLastRefreshTimestamp(meta map[strin...` |
| 150 | fn | parseLastRefreshValue | (private) | `func parseLastRefreshValue(v any) (time.Time, b...` |
| 189 | fn | isWebUIRequest | (private) | `func isWebUIRequest(c *gin.Context) bool {` |
| 202 | fn | startCallbackForwarder | (private) | `func startCallbackForwarder(port int, provider,...` |
| 262 | fn | stopCallbackForwarderInstance | (private) | `func stopCallbackForwarderInstance(port int, fo...` |
| 275 | fn | stopForwarderInstance | (private) | `func stopForwarderInstance(port int, forwarder ...` |
| 295 | fn | managementCallbackURL | (private) | `func (h *Handler) managementCallbackURL(path st...` |
| 309 | fn | ListAuthFiles | pub | `func (h *Handler) ListAuthFiles(c *gin.Context) {` |
| 335 | fn | GetAuthFileModels | pub | `func (h *Handler) GetAuthFileModels(c *gin.Cont...` |
| 383 | fn | listAuthFilesFromDisk | (private) | `func (h *Handler) listAuthFilesFromDisk(c *gin....` |
| 431 | fn | buildAuthFileEntry | (private) | `func (h *Handler) buildAuthFileEntry(auth *core...` |
| 544 | fn | extractCodexIDTokenClaims | (private) | `func extractCodexIDTokenClaims(auth *coreauth.A...` |
| 584 | fn | authEmail | (private) | `func authEmail(auth *coreauth.Auth) string {` |
| 604 | fn | authAttribute | (private) | `func authAttribute(auth *coreauth.Auth, key str...` |
| 611 | fn | isRuntimeOnlyAuth | (private) | `func isRuntimeOnlyAuth(auth *coreauth.Auth) bool {` |
| 618 | fn | isUnsafeAuthFileName | (private) | `func isUnsafeAuthFileName(name string) bool {` |
| 628 | fn | findAuthByNameOrID | (private) | `func (h *Handler) findAuthByNameOrID(name strin...` |
| 665 | fn | DownloadAuthFile | pub | `func (h *Handler) DownloadAuthFile(c *gin.Conte...` |
| 690 | fn | UploadAuthFile | pub | `func (h *Handler) UploadAuthFile(c *gin.Context) {` |
| 770 | fn | DeleteAuthFile | pub | `func (h *Handler) DeleteAuthFile(c *gin.Context) {` |
| 849 | fn | findAuthForDelete | (private) | `func (h *Handler) findAuthForDelete(name string...` |
| 875 | fn | multipartAuthFileHeaders | (private) | `func (h *Handler) multipartAuthFileHeaders(c *g...` |
| 900 | fn | storeUploadedAuthFile | (private) | `func (h *Handler) storeUploadedAuthFile(ctx con...` |
| 924 | fn | writeAuthFile | (private) | `func (h *Handler) writeAuthFile(ctx context.Con...` |
| 944 | fn | requestedAuthFileNamesForDelete | (private) | `func requestedAuthFileNamesForDelete(c *gin.Con...` |
| 985 | fn | uniqueAuthFileNames | (private) | `func uniqueAuthFileNames(names []string) []stri...` |
| 1005 | fn | deleteAuthFileByName | (private) | `func (h *Handler) deleteAuthFileByName(ctx cont...` |
| 1041 | fn | authIDForPath | (private) | `func (h *Handler) authIDForPath(path string) st...` |
| 1077 | fn | buildAuthFromFileData | (private) | `func (h *Handler) buildAuthFromFileData(path st...` |
| 1137 | fn | registerAuthFromFile | (private) | `func (h *Handler) registerAuthFromFile(ctx cont...` |
| 1148 | fn | upsertAuthRecord | (private) | `func (h *Handler) upsertAuthRecord(ctx context....` |
| 1161 | fn | replaceAuthMetadataHeaders | (private) | `func replaceAuthMetadataHeaders(auth *coreauth....` |
| 1206 | fn | overwriteAuthMetadataHeaders | (private) | `func overwriteAuthMetadataHeaders(auth *coreaut...` |
| 1236 | fn | normalizeHeaderMap | (private) | `func normalizeHeaderMap(headers map[string]stri...` |
| 1255 | fn | authProxyURL | (private) | `func authProxyURL(auth *coreauth.Auth) string {` |
| 1271 | fn | authDisplayName | (private) | `func authDisplayName(auth *coreauth.Auth) string {` |
| 1289 | fn | authNote | (private) | `func authNote(auth *coreauth.Auth) string {` |
| 1305 | fn | normalizeAccountProfileValue | (private) | `func normalizeAccountProfileValue(raw any) any {` |
| 1339 | fn | authManagedHeaderNames | (private) | `func authManagedHeaderNames(provider string) ma...` |
| 1361 | fn | authHeaderReservedForExtras | (private) | `func authHeaderReservedForExtras(provider strin...` |
| 1398 | fn | managedHeadersForAuth | (private) | `func managedHeadersForAuth(auth *coreauth.Auth,...` |
| 1402 | fn | managedHeaderProjectionForAuth | (private) | `func managedHeaderProjectionForAuth(auth *corea...` |
| 1453 | fn | mergeAccountHeaders | (private) | `func mergeAccountHeaders(managedHeaders map[str...` |
| 1470 | fn | readAccountSettingsMetadata | (private) | `func readAccountSettingsMetadata(auth *coreauth...` |
| 1497 | fn | legacyExtraHeaders | (private) | `func legacyExtraHeaders(auth *coreauth.Auth) ma...` |
| 1520 | fn | buildAuthFileAccountSettingsView | (private) | `func buildAuthFileAccountSettingsView(auth *cor...` |
| 1559 | fn | providerKey | (private) | `func providerKey(auth *coreauth.Auth) string {` |
| 1566 | fn | syncAuthManagedHeaderState | (private) | `func (h *Handler) syncAuthManagedHeaderState(ct...` |
| 1613 | fn | normalizeManagedHeaderState | (private) | `func normalizeManagedHeaderState(state *authFil...` |
| 1656 | fn | managedHeaderPolicyVersion | (private) | `func managedHeaderPolicyVersion(provider string...` |
| 1667 | fn | mergeManagedHeaderState | (private) | `func mergeManagedHeaderState(previous *authFile...` |
| 1719 | fn | diffManagedHeaderFields | (private) | `func diffManagedHeaderFields(previous map[strin...` |
| 1738 | fn | managedHeaderProjectionEquivalent | (private) | `func managedHeaderProjectionEquivalent(left *au...` |
| 1748 | fn | managedHeaderStateEquivalent | (private) | `func managedHeaderStateEquivalent(left *authFil...` |
| 1757 | fn | accountSettingsActivationSummary | (private) | `func accountSettingsActivationSummary(auth *cor...` |
| 1775 | fn | accountSettingsActivationState | (private) | `func accountSettingsActivationState(auth *corea...` |
| 1788 | fn | findAuthByName | (private) | `func findAuthByName(authManager *coreauth.Manag...` |
| 1807 | struct | refreshAuthFileStatusRequest | (private) | - |
| 1812 | const | authStatusRefreshFailureBackoff | (private) | - |
| 1815 | fn | RefreshAuthFileStatus | pub | `func (h *Handler) RefreshAuthFileStatus(c *gin....` |
| 1878 | fn | refreshAuthStatus | (private) | `func (h *Handler) refreshAuthStatus(ctx context...` |
| 1933 | fn | preserveAuthIdentity | (private) | `func preserveAuthIdentity(updated, current *cor...` |
| 1960 | fn | normalizeAuthRefreshError | (private) | `func normalizeAuthRefreshError(err error) *core...` |
| 1979 | fn | errorString | (private) | `func errorString(err error) string {` |
| 1987 | fn | PatchAuthFileStatus | pub | `func (h *Handler) PatchAuthFileStatus(c *gin.Co...` |
| 2053 | fn | PatchAuthFileFields | pub | `func (h *Handler) PatchAuthFileFields(c *gin.Co...` |
| 2181 | fn | GetAuthFileAccountSettings | pub | `func (h *Handler) GetAuthFileAccountSettings(c ...` |
| 2206 | fn | PatchAuthFileAccountSettings | pub | `func (h *Handler) PatchAuthFileAccountSettings(...` |
| 2317 | fn | disableAuth | (private) | `func (h *Handler) disableAuth(ctx context.Conte...` |
| 2346 | fn | deleteTokenRecord | (private) | `func (h *Handler) deleteTokenRecord(ctx context...` |
| 2357 | fn | tokenStoreWithBaseDir | (private) | `func (h *Handler) tokenStoreWithBaseDir() corea...` |
| 2374 | fn | saveTokenRecord | (private) | `func (h *Handler) saveTokenRecord(ctx context.C...` |
| 2390 | fn | gitLabBaseURLFromRequest | (private) | `func gitLabBaseURLFromRequest(c *gin.Context) s...` |
| 2402 | fn | buildGitLabAuthMetadata | (private) | `func buildGitLabAuthMetadata(baseURL, mode stri...` |
| 2429 | fn | mergeGitLabDirectAccessMetadata | (private) | `func mergeGitLabDirectAccessMetadata(metadata m...` |
| 2484 | fn | primaryGitLabEmail | (private) | `func primaryGitLabEmail(user *gitlabauth.User) ...` |
| 2494 | fn | gitLabAccountIdentifier | (private) | `func gitLabAccountIdentifier(user *gitlabauth.U...` |
| 2506 | fn | sanitizeGitLabFileName | (private) | `func sanitizeGitLabFileName(value string) string {` |
| 2538 | fn | maskGitLabToken | (private) | `func maskGitLabToken(token string) string {` |
| 2549 | fn | RequestAnthropicToken | pub | `func (h *Handler) RequestAnthropicToken(c *gin....` |
| 2694 | fn | RequestGeminiCLIToken | pub | `func (h *Handler) RequestGeminiCLIToken(c *gin....` |
| 2953 | fn | RequestCodexToken | pub | `func (h *Handler) RequestCodexToken(c *gin.Cont...` |
| 3099 | fn | RequestGitLabToken | pub | `func (h *Handler) RequestGitLabToken(c *gin.Con...` |
| 3257 | fn | RequestGitLabPATToken | pub | `func (h *Handler) RequestGitLabPATToken(c *gin....` |
| 3356 | fn | RequestAntigravityToken | pub | `func (h *Handler) RequestAntigravityToken(c *gi...` |
| 3521 | fn | RequestQwenToken | pub | `func (h *Handler) RequestQwenToken(c *gin.Conte...` |
| 3577 | fn | RequestKimiToken | pub | `func (h *Handler) RequestKimiToken(c *gin.Conte...` |
| 3654 | fn | RequestIFlowToken | pub | `func (h *Handler) RequestIFlowToken(c *gin.Cont...` |
| 3768 | fn | RequestGitHubToken | pub | `func (h *Handler) RequestGitHubToken(c *gin.Con...` |
| 3864 | fn | copilotTokenMetadata | (private) | `func copilotTokenMetadata(storage *copilot.Copi...` |
| 3879 | fn | RequestIFlowCookieToken | pub | `func (h *Handler) RequestIFlowCookieToken(c *gi...` |
| 3974 | struct | projectSelectionRequiredError | (private) | - |
| 3976 | fn | Error | pub | `func (e *projectSelectionRequiredError) Error()...` |
| 3980 | fn | ensureGeminiProjectAndOnboard | (private) | `func ensureGeminiProjectAndOnboard(ctx context....` |
| 4014 | fn | onboardAllGeminiProjects | (private) | `func onboardAllGeminiProjects(ctx context.Conte...` |
| 4048 | fn | ensureGeminiProjectsEnabled | (private) | `func ensureGeminiProjectsEnabled(ctx context.Co...` |
| 4065 | fn | performGeminiCLISetup | (private) | `func performGeminiCLISetup(ctx context.Context,...` |
| 4226 | fn | callGeminiCLI | (private) | `func callGeminiCLI(ctx context.Context, httpCli...` |
| 4275 | fn | fetchGCPProjects | (private) | `func fetchGCPProjects(ctx context.Context, http...` |
| 4304 | fn | checkCloudAPIIsEnabled | (private) | `func checkCloudAPIIsEnabled(ctx context.Context...` |
| 4364 | fn | GetAuthStatus | pub | `func (h *Handler) GetAuthStatus(c *gin.Context) {` |
| 4410 | fn | CancelOAuthSession | pub | `func (h *Handler) CancelOAuthSession(c *gin.Con...` |
| 4429 | fn | PopulateAuthContext | pub | `func PopulateAuthContext(ctx context.Context, c...` |
| 4437 | const | kiroCallbackPort | (private) | - |
| 4439 | fn | RequestKiroToken | pub | `func (h *Handler) RequestKiroToken(c *gin.Conte...` |
| 4721 | fn | generateKiroPKCE | (private) | `func generateKiroPKCE() (verifier, challenge st...` |
| 4734 | fn | RequestKiloToken | pub | `func (h *Handler) RequestKiloToken(c *gin.Conte...` |

## Public API

### `ListAuthFiles`

```
func (h *Handler) ListAuthFiles(c *gin.Context) {
```

**Line:** 309 | **Kind:** fn

### `GetAuthFileModels`

```
func (h *Handler) GetAuthFileModels(c *gin.Context) {
```

**Line:** 335 | **Kind:** fn

### `DownloadAuthFile`

```
func (h *Handler) DownloadAuthFile(c *gin.Context) {
```

**Line:** 665 | **Kind:** fn

### `UploadAuthFile`

```
func (h *Handler) UploadAuthFile(c *gin.Context) {
```

**Line:** 690 | **Kind:** fn

### `DeleteAuthFile`

```
func (h *Handler) DeleteAuthFile(c *gin.Context) {
```

**Line:** 770 | **Kind:** fn

### `RefreshAuthFileStatus`

```
func (h *Handler) RefreshAuthFileStatus(c *gin.Context) {
```

**Line:** 1815 | **Kind:** fn

### `PatchAuthFileStatus`

```
func (h *Handler) PatchAuthFileStatus(c *gin.Context) {
```

**Line:** 1987 | **Kind:** fn

### `PatchAuthFileFields`

```
func (h *Handler) PatchAuthFileFields(c *gin.Context) {
```

**Line:** 2053 | **Kind:** fn

### `GetAuthFileAccountSettings`

```
func (h *Handler) GetAuthFileAccountSettings(c *gin.Context) {
```

**Line:** 2181 | **Kind:** fn

### `PatchAuthFileAccountSettings`

```
func (h *Handler) PatchAuthFileAccountSettings(c *gin.Context) {
```

**Line:** 2206 | **Kind:** fn

### `RequestAnthropicToken`

```
func (h *Handler) RequestAnthropicToken(c *gin.Context) {
```

**Line:** 2549 | **Kind:** fn

### `RequestGeminiCLIToken`

```
func (h *Handler) RequestGeminiCLIToken(c *gin.Context) {
```

**Line:** 2694 | **Kind:** fn

### `RequestCodexToken`

```
func (h *Handler) RequestCodexToken(c *gin.Context) {
```

**Line:** 2953 | **Kind:** fn

### `RequestGitLabToken`

```
func (h *Handler) RequestGitLabToken(c *gin.Context) {
```

**Line:** 3099 | **Kind:** fn

### `RequestGitLabPATToken`

```
func (h *Handler) RequestGitLabPATToken(c *gin.Context) {
```

**Line:** 3257 | **Kind:** fn

### `RequestAntigravityToken`

```
func (h *Handler) RequestAntigravityToken(c *gin.Context) {
```

**Line:** 3356 | **Kind:** fn

### `RequestQwenToken`

```
func (h *Handler) RequestQwenToken(c *gin.Context) {
```

**Line:** 3521 | **Kind:** fn

### `RequestKimiToken`

```
func (h *Handler) RequestKimiToken(c *gin.Context) {
```

**Line:** 3577 | **Kind:** fn

### `RequestIFlowToken`

```
func (h *Handler) RequestIFlowToken(c *gin.Context) {
```

**Line:** 3654 | **Kind:** fn

### `RequestGitHubToken`

```
func (h *Handler) RequestGitHubToken(c *gin.Context) {
```

**Line:** 3768 | **Kind:** fn

### `RequestIFlowCookieToken`

```
func (h *Handler) RequestIFlowCookieToken(c *gin.Context) {
```

**Line:** 3879 | **Kind:** fn

### `Error`

```
func (e *projectSelectionRequiredError) Error() string {
```

**Line:** 3976 | **Kind:** fn

### `GetAuthStatus`

```
func (h *Handler) GetAuthStatus(c *gin.Context) {
```

**Line:** 4364 | **Kind:** fn

### `CancelOAuthSession`

```
func (h *Handler) CancelOAuthSession(c *gin.Context) {
```

**Line:** 4410 | **Kind:** fn

### `PopulateAuthContext`

```
func PopulateAuthContext(ctx context.Context, c *gin.Context) context.Context {
```

**Line:** 4429 | **Kind:** fn

### `RequestKiroToken`

```
func (h *Handler) RequestKiroToken(c *gin.Context) {
```

**Line:** 4439 | **Kind:** fn

### `RequestKiloToken`

```
func (h *Handler) RequestKiloToken(c *gin.Context) {
```

**Line:** 4734 | **Kind:** fn

