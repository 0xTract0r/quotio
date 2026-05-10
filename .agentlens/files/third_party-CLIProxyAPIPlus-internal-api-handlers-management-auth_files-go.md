# third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-api-handlers-management/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 5359
- **Language:** Go
- **Symbols:** 138
- **Public symbols:** 27

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 67 | struct | authFileManagedHeaderProjection | (private) | - |
| 78 | struct | authFileManagedHeaderHistoryEntry | (private) | - |
| 97 | struct | authFileManagedHeaderState | (private) | - |
| 103 | struct | authFileRuntimeIdentitySnapshot | (private) | - |
| 126 | struct | authFileRuntimeIdentityHistoryEntry | (private) | - |
| 134 | struct | authFileRuntimeIdentityState | (private) | - |
| 140 | struct | authFileAccountSettingsStored | (private) | - |
| 150 | struct | authFileAccountSettingsView | (private) | - |
| 166 | struct | authFileAccountSettingsActivation | (private) | - |
| 173 | struct | authFileAccountSettingsResponse | (private) | - |
| 178 | struct | callbackForwarder | (private) | - |
| 192 | fn | extractLastRefreshTimestamp | (private) | `func extractLastRefreshTimestamp(meta map[strin...` |
| 206 | fn | parseLastRefreshValue | (private) | `func parseLastRefreshValue(v any) (time.Time, b...` |
| 245 | fn | isWebUIRequest | (private) | `func isWebUIRequest(c *gin.Context) bool {` |
| 258 | fn | startCallbackForwarder | (private) | `func startCallbackForwarder(port int, provider,...` |
| 318 | fn | stopCallbackForwarderInstance | (private) | `func stopCallbackForwarderInstance(port int, fo...` |
| 331 | fn | stopForwarderInstance | (private) | `func stopForwarderInstance(port int, forwarder ...` |
| 351 | fn | managementCallbackURL | (private) | `func (h *Handler) managementCallbackURL(path st...` |
| 365 | fn | ListAuthFiles | pub | `func (h *Handler) ListAuthFiles(c *gin.Context) {` |
| 391 | fn | GetAuthFileModels | pub | `func (h *Handler) GetAuthFileModels(c *gin.Cont...` |
| 439 | fn | listAuthFilesFromDisk | (private) | `func (h *Handler) listAuthFilesFromDisk(c *gin....` |
| 487 | fn | buildAuthFileEntry | (private) | `func (h *Handler) buildAuthFileEntry(auth *core...` |
| 600 | fn | extractCodexIDTokenClaims | (private) | `func extractCodexIDTokenClaims(auth *coreauth.A...` |
| 640 | fn | authEmail | (private) | `func authEmail(auth *coreauth.Auth) string {` |
| 660 | fn | authAttribute | (private) | `func authAttribute(auth *coreauth.Auth, key str...` |
| 667 | fn | isRuntimeOnlyAuth | (private) | `func isRuntimeOnlyAuth(auth *coreauth.Auth) bool {` |
| 674 | fn | isUnsafeAuthFileName | (private) | `func isUnsafeAuthFileName(name string) bool {` |
| 684 | fn | findAuthByNameOrID | (private) | `func (h *Handler) findAuthByNameOrID(name strin...` |
| 721 | fn | DownloadAuthFile | pub | `func (h *Handler) DownloadAuthFile(c *gin.Conte...` |
| 746 | fn | UploadAuthFile | pub | `func (h *Handler) UploadAuthFile(c *gin.Context) {` |
| 826 | fn | DeleteAuthFile | pub | `func (h *Handler) DeleteAuthFile(c *gin.Context) {` |
| 905 | fn | findAuthForDelete | (private) | `func (h *Handler) findAuthForDelete(name string...` |
| 931 | fn | multipartAuthFileHeaders | (private) | `func (h *Handler) multipartAuthFileHeaders(c *g...` |
| 956 | fn | storeUploadedAuthFile | (private) | `func (h *Handler) storeUploadedAuthFile(ctx con...` |
| 980 | fn | writeAuthFile | (private) | `func (h *Handler) writeAuthFile(ctx context.Con...` |
| 1000 | fn | requestedAuthFileNamesForDelete | (private) | `func requestedAuthFileNamesForDelete(c *gin.Con...` |
| 1041 | fn | uniqueAuthFileNames | (private) | `func uniqueAuthFileNames(names []string) []stri...` |
| 1061 | fn | deleteAuthFileByName | (private) | `func (h *Handler) deleteAuthFileByName(ctx cont...` |
| 1097 | fn | authIDForPath | (private) | `func (h *Handler) authIDForPath(path string) st...` |
| 1133 | fn | buildAuthFromFileData | (private) | `func (h *Handler) buildAuthFromFileData(path st...` |
| 1193 | fn | registerAuthFromFile | (private) | `func (h *Handler) registerAuthFromFile(ctx cont...` |
| 1204 | fn | upsertAuthRecord | (private) | `func (h *Handler) upsertAuthRecord(ctx context....` |
| 1217 | fn | replaceAuthMetadataHeaders | (private) | `func replaceAuthMetadataHeaders(auth *coreauth....` |
| 1262 | fn | overwriteAuthMetadataHeaders | (private) | `func overwriteAuthMetadataHeaders(auth *coreaut...` |
| 1292 | fn | normalizeHeaderMap | (private) | `func normalizeHeaderMap(headers map[string]stri...` |
| 1311 | fn | authProxyURL | (private) | `func authProxyURL(auth *coreauth.Auth) string {` |
| 1327 | fn | authDisplayName | (private) | `func authDisplayName(auth *coreauth.Auth) string {` |
| 1345 | fn | authNote | (private) | `func authNote(auth *coreauth.Auth) string {` |
| 1361 | fn | normalizeAccountProfileValue | (private) | `func normalizeAccountProfileValue(raw any) any {` |
| 1395 | fn | authManagedHeaderNames | (private) | `func authManagedHeaderNames(provider string) ma...` |
| 1417 | fn | authHeaderReservedForExtras | (private) | `func authHeaderReservedForExtras(provider strin...` |
| 1454 | fn | managedHeadersForAuth | (private) | `func managedHeadersForAuth(auth *coreauth.Auth,...` |
| 1458 | fn | managedHeaderProjectionForAuth | (private) | `func managedHeaderProjectionForAuth(auth *corea...` |
| 1515 | fn | mergeAccountHeaders | (private) | `func mergeAccountHeaders(managedHeaders map[str...` |
| 1532 | fn | readAccountSettingsMetadata | (private) | `func readAccountSettingsMetadata(auth *coreauth...` |
| 1560 | fn | legacyExtraHeaders | (private) | `func legacyExtraHeaders(auth *coreauth.Auth) ma...` |
| 1583 | fn | accountSettingsRefreshEnabled | (private) | `func accountSettingsRefreshEnabled(auth *coreau...` |
| 1593 | fn | refreshEnabledStorageValue | (private) | `func refreshEnabledStorageValue(enabled bool) *...` |
| 1601 | fn | applyAuthRefreshEnabledMetadata | (private) | `func applyAuthRefreshEnabledMetadata(auth *core...` |
| 1620 | fn | buildAuthFileAccountSettingsView | (private) | `func buildAuthFileAccountSettingsView(auth *cor...` |
| 1673 | fn | providerKey | (private) | `func providerKey(auth *coreauth.Auth) string {` |
| 1680 | fn | syncAuthManagedHeaderState | (private) | `func (h *Handler) syncAuthManagedHeaderState(ct...` |
| 1739 | fn | normalizeRuntimeIdentityState | (private) | `func normalizeRuntimeIdentityState(state *authF...` |
| 1767 | fn | normalizeRuntimeIdentitySnapshot | (private) | `func normalizeRuntimeIdentitySnapshot(snapshot ...` |
| 1792 | fn | mergeRuntimeIdentityState | (private) | `func mergeRuntimeIdentityState(previous *authFi...` |
| 1832 | fn | buildRuntimeIdentitySnapshot | (private) | `func buildRuntimeIdentitySnapshot(auth *coreaut...` |
| 1901 | fn | runtimeIdentityPolicyVersion | (private) | `func runtimeIdentityPolicyVersion(provider stri...` |
| 1914 | fn | runtimeIdentityAuthID | (private) | `func runtimeIdentityAuthID(auth *coreauth.Auth)...` |
| 1926 | fn | runtimeIdentityAccountKey | (private) | `func runtimeIdentityAccountKey(auth *coreauth.A...` |
| 1948 | fn | runtimeIdentityBaseURLHost | (private) | `func runtimeIdentityBaseURLHost(auth *coreauth....` |
| 1971 | fn | runtimeIdentitySnapshotEquivalentForRevision | (private) | `func runtimeIdentitySnapshotEquivalentForRevisi...` |
| 1986 | fn | runtimeIdentityStateEquivalent | (private) | `func runtimeIdentityStateEquivalent(left *authF...` |
| 1995 | fn | diffRuntimeIdentitySnapshotFields | (private) | `func diffRuntimeIdentitySnapshotFields(previous...` |
| 2029 | fn | addRuntimeIdentityChange | (private) | `func addRuntimeIdentityChange(out map[string]st...` |
| 2035 | fn | optionalSHA256 | (private) | `func optionalSHA256(value string) string {` |
| 2043 | fn | sha256Hex | (private) | `func sha256Hex(value string) string {` |
| 2048 | fn | shortHash | (private) | `func shortHash(value string, length int) string {` |
| 2056 | fn | normalizeManagedHeaderState | (private) | `func normalizeManagedHeaderState(state *authFil...` |
| 2112 | fn | managedHeaderPolicyVersion | (private) | `func managedHeaderPolicyVersion(provider string...` |
| 2123 | fn | mergeManagedHeaderState | (private) | `func mergeManagedHeaderState(previous *authFile...` |
| 2188 | fn | diffManagedHeaderProjectionFields | (private) | `func diffManagedHeaderProjectionFields(previous...` |
| 2205 | fn | addChangedManagedHeaderFields | (private) | `func addChangedManagedHeaderFields(out map[stri...` |
| 2211 | fn | diffManagedHeaderFields | (private) | `func diffManagedHeaderFields(previous map[strin...` |
| 2230 | fn | managedHeaderProjectionEquivalent | (private) | `func managedHeaderProjectionEquivalent(left *au...` |
| 2242 | fn | managedHeaderStateEquivalent | (private) | `func managedHeaderStateEquivalent(left *authFil...` |
| 2251 | fn | accountSettingsActivationSummary | (private) | `func accountSettingsActivationSummary(auth *cor...` |
| 2273 | fn | accountSettingsActivationState | (private) | `func accountSettingsActivationState(auth *corea...` |
| 2292 | fn | findAuthByName | (private) | `func findAuthByName(authManager *coreauth.Manag...` |
| 2311 | struct | refreshAuthFileStatusRequest | (private) | - |
| 2316 | const | authStatusRefreshFailureBackoff | (private) | - |
| 2319 | fn | RefreshAuthFileStatus | pub | `func (h *Handler) RefreshAuthFileStatus(c *gin....` |
| 2382 | fn | refreshAuthStatus | (private) | `func (h *Handler) refreshAuthStatus(ctx context...` |
| 2447 | fn | preserveAuthIdentity | (private) | `func preserveAuthIdentity(updated, current *cor...` |
| 2474 | fn | normalizeAuthRefreshError | (private) | `func normalizeAuthRefreshError(err error) *core...` |
| 2493 | fn | errorString | (private) | `func errorString(err error) string {` |
| 2501 | fn | PatchAuthFileStatus | pub | `func (h *Handler) PatchAuthFileStatus(c *gin.Co...` |
| 2586 | fn | PatchAuthFileFields | pub | `func (h *Handler) PatchAuthFileFields(c *gin.Co...` |
| 2714 | fn | GetAuthFileAccountSettings | pub | `func (h *Handler) GetAuthFileAccountSettings(c ...` |
| 2739 | fn | PatchAuthFileAccountSettings | pub | `func (h *Handler) PatchAuthFileAccountSettings(...` |
| 2859 | fn | disableAuth | (private) | `func (h *Handler) disableAuth(ctx context.Conte...` |
| 2888 | fn | deleteTokenRecord | (private) | `func (h *Handler) deleteTokenRecord(ctx context...` |
| 2899 | fn | tokenStoreWithBaseDir | (private) | `func (h *Handler) tokenStoreWithBaseDir() corea...` |
| 2916 | fn | saveTokenRecord | (private) | `func (h *Handler) saveTokenRecord(ctx context.C...` |
| 2932 | fn | gitLabBaseURLFromRequest | (private) | `func gitLabBaseURLFromRequest(c *gin.Context) s...` |
| 2944 | fn | buildGitLabAuthMetadata | (private) | `func buildGitLabAuthMetadata(baseURL, mode stri...` |
| 2971 | fn | mergeGitLabDirectAccessMetadata | (private) | `func mergeGitLabDirectAccessMetadata(metadata m...` |
| 3026 | fn | primaryGitLabEmail | (private) | `func primaryGitLabEmail(user *gitlabauth.User) ...` |
| 3036 | fn | gitLabAccountIdentifier | (private) | `func gitLabAccountIdentifier(user *gitlabauth.U...` |
| 3048 | fn | sanitizeGitLabFileName | (private) | `func sanitizeGitLabFileName(value string) string {` |
| 3080 | fn | maskGitLabToken | (private) | `func maskGitLabToken(token string) string {` |
| 3091 | fn | RequestAnthropicToken | pub | `func (h *Handler) RequestAnthropicToken(c *gin....` |
| 3236 | fn | RequestGeminiCLIToken | pub | `func (h *Handler) RequestGeminiCLIToken(c *gin....` |
| 3495 | fn | RequestCodexToken | pub | `func (h *Handler) RequestCodexToken(c *gin.Cont...` |
| 3641 | fn | RequestGitLabToken | pub | `func (h *Handler) RequestGitLabToken(c *gin.Con...` |
| 3799 | fn | RequestGitLabPATToken | pub | `func (h *Handler) RequestGitLabPATToken(c *gin....` |
| 3898 | fn | RequestAntigravityToken | pub | `func (h *Handler) RequestAntigravityToken(c *gi...` |
| 4063 | fn | RequestQwenToken | pub | `func (h *Handler) RequestQwenToken(c *gin.Conte...` |
| 4119 | fn | RequestKimiToken | pub | `func (h *Handler) RequestKimiToken(c *gin.Conte...` |
| 4196 | fn | RequestIFlowToken | pub | `func (h *Handler) RequestIFlowToken(c *gin.Cont...` |
| 4310 | fn | RequestGitHubToken | pub | `func (h *Handler) RequestGitHubToken(c *gin.Con...` |
| 4406 | fn | copilotTokenMetadata | (private) | `func copilotTokenMetadata(storage *copilot.Copi...` |
| 4421 | fn | RequestIFlowCookieToken | pub | `func (h *Handler) RequestIFlowCookieToken(c *gi...` |
| 4516 | struct | projectSelectionRequiredError | (private) | - |
| 4518 | fn | Error | pub | `func (e *projectSelectionRequiredError) Error()...` |
| 4522 | fn | ensureGeminiProjectAndOnboard | (private) | `func ensureGeminiProjectAndOnboard(ctx context....` |
| 4556 | fn | onboardAllGeminiProjects | (private) | `func onboardAllGeminiProjects(ctx context.Conte...` |
| 4590 | fn | ensureGeminiProjectsEnabled | (private) | `func ensureGeminiProjectsEnabled(ctx context.Co...` |
| 4607 | fn | performGeminiCLISetup | (private) | `func performGeminiCLISetup(ctx context.Context,...` |
| 4768 | fn | callGeminiCLI | (private) | `func callGeminiCLI(ctx context.Context, httpCli...` |
| 4817 | fn | fetchGCPProjects | (private) | `func fetchGCPProjects(ctx context.Context, http...` |
| 4846 | fn | checkCloudAPIIsEnabled | (private) | `func checkCloudAPIIsEnabled(ctx context.Context...` |
| 4906 | fn | GetAuthStatus | pub | `func (h *Handler) GetAuthStatus(c *gin.Context) {` |
| 4952 | fn | CancelOAuthSession | pub | `func (h *Handler) CancelOAuthSession(c *gin.Con...` |
| 4971 | fn | PopulateAuthContext | pub | `func PopulateAuthContext(ctx context.Context, c...` |
| 4979 | const | kiroCallbackPort | (private) | - |
| 4981 | fn | RequestKiroToken | pub | `func (h *Handler) RequestKiroToken(c *gin.Conte...` |
| 5263 | fn | generateKiroPKCE | (private) | `func generateKiroPKCE() (verifier, challenge st...` |
| 5276 | fn | RequestKiloToken | pub | `func (h *Handler) RequestKiloToken(c *gin.Conte...` |

## Public API

### `ListAuthFiles`

```
func (h *Handler) ListAuthFiles(c *gin.Context) {
```

**Line:** 365 | **Kind:** fn

### `GetAuthFileModels`

```
func (h *Handler) GetAuthFileModels(c *gin.Context) {
```

**Line:** 391 | **Kind:** fn

### `DownloadAuthFile`

```
func (h *Handler) DownloadAuthFile(c *gin.Context) {
```

**Line:** 721 | **Kind:** fn

### `UploadAuthFile`

```
func (h *Handler) UploadAuthFile(c *gin.Context) {
```

**Line:** 746 | **Kind:** fn

### `DeleteAuthFile`

```
func (h *Handler) DeleteAuthFile(c *gin.Context) {
```

**Line:** 826 | **Kind:** fn

### `RefreshAuthFileStatus`

```
func (h *Handler) RefreshAuthFileStatus(c *gin.Context) {
```

**Line:** 2319 | **Kind:** fn

### `PatchAuthFileStatus`

```
func (h *Handler) PatchAuthFileStatus(c *gin.Context) {
```

**Line:** 2501 | **Kind:** fn

### `PatchAuthFileFields`

```
func (h *Handler) PatchAuthFileFields(c *gin.Context) {
```

**Line:** 2586 | **Kind:** fn

### `GetAuthFileAccountSettings`

```
func (h *Handler) GetAuthFileAccountSettings(c *gin.Context) {
```

**Line:** 2714 | **Kind:** fn

### `PatchAuthFileAccountSettings`

```
func (h *Handler) PatchAuthFileAccountSettings(c *gin.Context) {
```

**Line:** 2739 | **Kind:** fn

### `RequestAnthropicToken`

```
func (h *Handler) RequestAnthropicToken(c *gin.Context) {
```

**Line:** 3091 | **Kind:** fn

### `RequestGeminiCLIToken`

```
func (h *Handler) RequestGeminiCLIToken(c *gin.Context) {
```

**Line:** 3236 | **Kind:** fn

### `RequestCodexToken`

```
func (h *Handler) RequestCodexToken(c *gin.Context) {
```

**Line:** 3495 | **Kind:** fn

### `RequestGitLabToken`

```
func (h *Handler) RequestGitLabToken(c *gin.Context) {
```

**Line:** 3641 | **Kind:** fn

### `RequestGitLabPATToken`

```
func (h *Handler) RequestGitLabPATToken(c *gin.Context) {
```

**Line:** 3799 | **Kind:** fn

### `RequestAntigravityToken`

```
func (h *Handler) RequestAntigravityToken(c *gin.Context) {
```

**Line:** 3898 | **Kind:** fn

### `RequestQwenToken`

```
func (h *Handler) RequestQwenToken(c *gin.Context) {
```

**Line:** 4063 | **Kind:** fn

### `RequestKimiToken`

```
func (h *Handler) RequestKimiToken(c *gin.Context) {
```

**Line:** 4119 | **Kind:** fn

### `RequestIFlowToken`

```
func (h *Handler) RequestIFlowToken(c *gin.Context) {
```

**Line:** 4196 | **Kind:** fn

### `RequestGitHubToken`

```
func (h *Handler) RequestGitHubToken(c *gin.Context) {
```

**Line:** 4310 | **Kind:** fn

### `RequestIFlowCookieToken`

```
func (h *Handler) RequestIFlowCookieToken(c *gin.Context) {
```

**Line:** 4421 | **Kind:** fn

### `Error`

```
func (e *projectSelectionRequiredError) Error() string {
```

**Line:** 4518 | **Kind:** fn

### `GetAuthStatus`

```
func (h *Handler) GetAuthStatus(c *gin.Context) {
```

**Line:** 4906 | **Kind:** fn

### `CancelOAuthSession`

```
func (h *Handler) CancelOAuthSession(c *gin.Context) {
```

**Line:** 4952 | **Kind:** fn

### `PopulateAuthContext`

```
func PopulateAuthContext(ctx context.Context, c *gin.Context) context.Context {
```

**Line:** 4971 | **Kind:** fn

### `RequestKiroToken`

```
func (h *Handler) RequestKiroToken(c *gin.Context) {
```

**Line:** 4981 | **Kind:** fn

### `RequestKiloToken`

```
func (h *Handler) RequestKiloToken(c *gin.Context) {
```

**Line:** 5276 | **Kind:** fn

