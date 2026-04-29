# third_party/CLIProxyAPIPlus/internal/api/handlers/management/config_lists.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-api-handlers-management/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1514
- **Language:** Go
- **Symbols:** 62
- **Public symbols:** 51

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 13 | fn | putStringList | (private) | `func (h *Handler) putStringList(c *gin.Context,...` |
| 37 | fn | patchStringList | (private) | `func (h *Handler) patchStringList(c *gin.Contex...` |
| 77 | fn | deleteFromStringList | (private) | `func (h *Handler) deleteFromStringList(c *gin.C...` |
| 108 | fn | GetAPIKeys | pub | `func (h *Handler) GetAPIKeys(c *gin.Context) { ...` |
| 109 | fn | PutAPIKeys | pub | `func (h *Handler) PutAPIKeys(c *gin.Context) {` |
| 114 | fn | PatchAPIKeys | pub | `func (h *Handler) PatchAPIKeys(c *gin.Context) {` |
| 117 | fn | DeleteAPIKeys | pub | `func (h *Handler) DeleteAPIKeys(c *gin.Context) {` |
| 122 | fn | GetGeminiKeys | pub | `func (h *Handler) GetGeminiKeys(c *gin.Context) {` |
| 125 | fn | PutGeminiKeys | pub | `func (h *Handler) PutGeminiKeys(c *gin.Context) {` |
| 148 | fn | PatchGeminiKey | pub | `func (h *Handler) PatchGeminiKey(c *gin.Context) {` |
| 220 | fn | DeleteGeminiKey | pub | `func (h *Handler) DeleteGeminiKey(c *gin.Contex...` |
| 279 | fn | GetClaudeKeys | pub | `func (h *Handler) GetClaudeKeys(c *gin.Context) {` |
| 282 | fn | PutClaudeKeys | pub | `func (h *Handler) PutClaudeKeys(c *gin.Context) {` |
| 308 | fn | PatchClaudeKey | pub | `func (h *Handler) PatchClaudeKey(c *gin.Context) {` |
| 376 | fn | DeleteClaudeKey | pub | `func (h *Handler) DeleteClaudeKey(c *gin.Contex...` |
| 430 | fn | GetOpenAICompat | pub | `func (h *Handler) GetOpenAICompat(c *gin.Contex...` |
| 433 | fn | PutOpenAICompat | pub | `func (h *Handler) PutOpenAICompat(c *gin.Contex...` |
| 463 | fn | PatchOpenAICompat | pub | `func (h *Handler) PatchOpenAICompat(c *gin.Cont...` |
| 534 | fn | DeleteOpenAICompat | pub | `func (h *Handler) DeleteOpenAICompat(c *gin.Con...` |
| 563 | fn | GetVertexCompatKeys | pub | `func (h *Handler) GetVertexCompatKeys(c *gin.Co...` |
| 566 | fn | PutVertexCompatKeys | pub | `func (h *Handler) PutVertexCompatKeys(c *gin.Co...` |
| 596 | fn | PatchVertexCompatKey | pub | `func (h *Handler) PatchVertexCompatKey(c *gin.C...` |
| 680 | fn | DeleteVertexCompatKey | pub | `func (h *Handler) DeleteVertexCompatKey(c *gin....` |
| 734 | fn | GetOAuthExcludedModels | pub | `func (h *Handler) GetOAuthExcludedModels(c *gin...` |
| 738 | fn | PutOAuthExcludedModels | pub | `func (h *Handler) PutOAuthExcludedModels(c *gin...` |
| 759 | fn | PatchOAuthExcludedModels | pub | `func (h *Handler) PatchOAuthExcludedModels(c *g...` |
| 797 | fn | DeleteOAuthExcludedModels | pub | `func (h *Handler) DeleteOAuthExcludedModels(c *...` |
| 819 | fn | GetOAuthModelAlias | pub | `func (h *Handler) GetOAuthModelAlias(c *gin.Con...` |
| 823 | fn | PutOAuthModelAlias | pub | `func (h *Handler) PutOAuthModelAlias(c *gin.Con...` |
| 844 | fn | PatchOAuthModelAlias | pub | `func (h *Handler) PatchOAuthModelAlias(c *gin.C...` |
| 895 | fn | DeleteOAuthModelAlias | pub | `func (h *Handler) DeleteOAuthModelAlias(c *gin....` |
| 920 | fn | GetCodexKeys | pub | `func (h *Handler) GetCodexKeys(c *gin.Context) {` |
| 923 | fn | PutCodexKeys | pub | `func (h *Handler) PutCodexKeys(c *gin.Context) {` |
| 956 | fn | PatchCodexKey | pub | `func (h *Handler) PatchCodexKey(c *gin.Context) {` |
| 1031 | fn | DeleteCodexKey | pub | `func (h *Handler) DeleteCodexKey(c *gin.Context) {` |
| 1084 | fn | normalizeOpenAICompatibilityEntry | (private) | `func normalizeOpenAICompatibilityEntry(entry *c...` |
| 1101 | fn | normalizedOpenAICompatibilityEntries | (private) | `func normalizedOpenAICompatibilityEntries(entri...` |
| 1117 | fn | normalizeClaudeKey | (private) | `func normalizeClaudeKey(entry *config.ClaudeKey) {` |
| 1142 | fn | normalizeCodexKey | (private) | `func normalizeCodexKey(entry *config.CodexKey) {` |
| 1168 | fn | normalizeVertexCompatKey | (private) | `func normalizeVertexCompatKey(entry *config.Ver...` |
| 1194 | fn | sanitizedOAuthModelAlias | (private) | `func sanitizedOAuthModelAlias(entries map[strin...` |
| 1217 | fn | GetAmpCode | pub | `func (h *Handler) GetAmpCode(c *gin.Context) {` |
| 1226 | fn | GetAmpUpstreamURL | pub | `func (h *Handler) GetAmpUpstreamURL(c *gin.Cont...` |
| 1235 | fn | PutAmpUpstreamURL | pub | `func (h *Handler) PutAmpUpstreamURL(c *gin.Cont...` |
| 1240 | fn | DeleteAmpUpstreamURL | pub | `func (h *Handler) DeleteAmpUpstreamURL(c *gin.C...` |
| 1246 | fn | GetAmpUpstreamAPIKey | pub | `func (h *Handler) GetAmpUpstreamAPIKey(c *gin.C...` |
| 1255 | fn | PutAmpUpstreamAPIKey | pub | `func (h *Handler) PutAmpUpstreamAPIKey(c *gin.C...` |
| 1260 | fn | DeleteAmpUpstreamAPIKey | pub | `func (h *Handler) DeleteAmpUpstreamAPIKey(c *gi...` |
| 1266 | fn | GetAmpRestrictManagementToLocalhost | pub | `func (h *Handler) GetAmpRestrictManagementToLoc...` |
| 1275 | fn | PutAmpRestrictManagementToLocalhost | pub | `func (h *Handler) PutAmpRestrictManagementToLoc...` |
| 1280 | fn | GetAmpModelMappings | pub | `func (h *Handler) GetAmpModelMappings(c *gin.Co...` |
| 1289 | fn | PutAmpModelMappings | pub | `func (h *Handler) PutAmpModelMappings(c *gin.Co...` |
| 1302 | fn | PatchAmpModelMappings | pub | `func (h *Handler) PatchAmpModelMappings(c *gin....` |
| 1329 | fn | DeleteAmpModelMappings | pub | `func (h *Handler) DeleteAmpModelMappings(c *gin...` |
| 1355 | fn | GetAmpForceModelMappings | pub | `func (h *Handler) GetAmpForceModelMappings(c *g...` |
| 1364 | fn | PutAmpForceModelMappings | pub | `func (h *Handler) PutAmpForceModelMappings(c *g...` |
| 1369 | fn | GetAmpUpstreamAPIKeys | pub | `func (h *Handler) GetAmpUpstreamAPIKeys(c *gin....` |
| 1378 | fn | PutAmpUpstreamAPIKeys | pub | `func (h *Handler) PutAmpUpstreamAPIKeys(c *gin....` |
| 1394 | fn | PatchAmpUpstreamAPIKeys | pub | `func (h *Handler) PatchAmpUpstreamAPIKeys(c *gi...` |
| 1431 | fn | DeleteAmpUpstreamAPIKeys | pub | `func (h *Handler) DeleteAmpUpstreamAPIKeys(c *g...` |
| 1476 | fn | normalizeAmpUpstreamAPIKeyEntries | (private) | `func normalizeAmpUpstreamAPIKeyEntries(entries ...` |
| 1499 | fn | normalizeAPIKeysList | (private) | `func normalizeAPIKeysList(keys []string) []stri...` |

## Public API

### `GetAPIKeys`

```
func (h *Handler) GetAPIKeys(c *gin.Context) { c.JSON(200, gin.H{"api-keys": h.cfg.APIKeys}) }
```

**Line:** 108 | **Kind:** fn

### `PutAPIKeys`

```
func (h *Handler) PutAPIKeys(c *gin.Context) {
```

**Line:** 109 | **Kind:** fn

### `PatchAPIKeys`

```
func (h *Handler) PatchAPIKeys(c *gin.Context) {
```

**Line:** 114 | **Kind:** fn

### `DeleteAPIKeys`

```
func (h *Handler) DeleteAPIKeys(c *gin.Context) {
```

**Line:** 117 | **Kind:** fn

### `GetGeminiKeys`

```
func (h *Handler) GetGeminiKeys(c *gin.Context) {
```

**Line:** 122 | **Kind:** fn

### `PutGeminiKeys`

```
func (h *Handler) PutGeminiKeys(c *gin.Context) {
```

**Line:** 125 | **Kind:** fn

### `PatchGeminiKey`

```
func (h *Handler) PatchGeminiKey(c *gin.Context) {
```

**Line:** 148 | **Kind:** fn

### `DeleteGeminiKey`

```
func (h *Handler) DeleteGeminiKey(c *gin.Context) {
```

**Line:** 220 | **Kind:** fn

### `GetClaudeKeys`

```
func (h *Handler) GetClaudeKeys(c *gin.Context) {
```

**Line:** 279 | **Kind:** fn

### `PutClaudeKeys`

```
func (h *Handler) PutClaudeKeys(c *gin.Context) {
```

**Line:** 282 | **Kind:** fn

### `PatchClaudeKey`

```
func (h *Handler) PatchClaudeKey(c *gin.Context) {
```

**Line:** 308 | **Kind:** fn

### `DeleteClaudeKey`

```
func (h *Handler) DeleteClaudeKey(c *gin.Context) {
```

**Line:** 376 | **Kind:** fn

### `GetOpenAICompat`

```
func (h *Handler) GetOpenAICompat(c *gin.Context) {
```

**Line:** 430 | **Kind:** fn

### `PutOpenAICompat`

```
func (h *Handler) PutOpenAICompat(c *gin.Context) {
```

**Line:** 433 | **Kind:** fn

### `PatchOpenAICompat`

```
func (h *Handler) PatchOpenAICompat(c *gin.Context) {
```

**Line:** 463 | **Kind:** fn

### `DeleteOpenAICompat`

```
func (h *Handler) DeleteOpenAICompat(c *gin.Context) {
```

**Line:** 534 | **Kind:** fn

### `GetVertexCompatKeys`

```
func (h *Handler) GetVertexCompatKeys(c *gin.Context) {
```

**Line:** 563 | **Kind:** fn

### `PutVertexCompatKeys`

```
func (h *Handler) PutVertexCompatKeys(c *gin.Context) {
```

**Line:** 566 | **Kind:** fn

### `PatchVertexCompatKey`

```
func (h *Handler) PatchVertexCompatKey(c *gin.Context) {
```

**Line:** 596 | **Kind:** fn

### `DeleteVertexCompatKey`

```
func (h *Handler) DeleteVertexCompatKey(c *gin.Context) {
```

**Line:** 680 | **Kind:** fn

### `GetOAuthExcludedModels`

```
func (h *Handler) GetOAuthExcludedModels(c *gin.Context) {
```

**Line:** 734 | **Kind:** fn

### `PutOAuthExcludedModels`

```
func (h *Handler) PutOAuthExcludedModels(c *gin.Context) {
```

**Line:** 738 | **Kind:** fn

### `PatchOAuthExcludedModels`

```
func (h *Handler) PatchOAuthExcludedModels(c *gin.Context) {
```

**Line:** 759 | **Kind:** fn

### `DeleteOAuthExcludedModels`

```
func (h *Handler) DeleteOAuthExcludedModels(c *gin.Context) {
```

**Line:** 797 | **Kind:** fn

### `GetOAuthModelAlias`

```
func (h *Handler) GetOAuthModelAlias(c *gin.Context) {
```

**Line:** 819 | **Kind:** fn

### `PutOAuthModelAlias`

```
func (h *Handler) PutOAuthModelAlias(c *gin.Context) {
```

**Line:** 823 | **Kind:** fn

### `PatchOAuthModelAlias`

```
func (h *Handler) PatchOAuthModelAlias(c *gin.Context) {
```

**Line:** 844 | **Kind:** fn

### `DeleteOAuthModelAlias`

```
func (h *Handler) DeleteOAuthModelAlias(c *gin.Context) {
```

**Line:** 895 | **Kind:** fn

### `GetCodexKeys`

```
func (h *Handler) GetCodexKeys(c *gin.Context) {
```

**Line:** 920 | **Kind:** fn

### `PutCodexKeys`

```
func (h *Handler) PutCodexKeys(c *gin.Context) {
```

**Line:** 923 | **Kind:** fn

### `PatchCodexKey`

```
func (h *Handler) PatchCodexKey(c *gin.Context) {
```

**Line:** 956 | **Kind:** fn

### `DeleteCodexKey`

```
func (h *Handler) DeleteCodexKey(c *gin.Context) {
```

**Line:** 1031 | **Kind:** fn

### `GetAmpCode`

```
func (h *Handler) GetAmpCode(c *gin.Context) {
```

**Line:** 1217 | **Kind:** fn

### `GetAmpUpstreamURL`

```
func (h *Handler) GetAmpUpstreamURL(c *gin.Context) {
```

**Line:** 1226 | **Kind:** fn

### `PutAmpUpstreamURL`

```
func (h *Handler) PutAmpUpstreamURL(c *gin.Context) {
```

**Line:** 1235 | **Kind:** fn

### `DeleteAmpUpstreamURL`

```
func (h *Handler) DeleteAmpUpstreamURL(c *gin.Context) {
```

**Line:** 1240 | **Kind:** fn

### `GetAmpUpstreamAPIKey`

```
func (h *Handler) GetAmpUpstreamAPIKey(c *gin.Context) {
```

**Line:** 1246 | **Kind:** fn

### `PutAmpUpstreamAPIKey`

```
func (h *Handler) PutAmpUpstreamAPIKey(c *gin.Context) {
```

**Line:** 1255 | **Kind:** fn

### `DeleteAmpUpstreamAPIKey`

```
func (h *Handler) DeleteAmpUpstreamAPIKey(c *gin.Context) {
```

**Line:** 1260 | **Kind:** fn

### `GetAmpRestrictManagementToLocalhost`

```
func (h *Handler) GetAmpRestrictManagementToLocalhost(c *gin.Context) {
```

**Line:** 1266 | **Kind:** fn

### `PutAmpRestrictManagementToLocalhost`

```
func (h *Handler) PutAmpRestrictManagementToLocalhost(c *gin.Context) {
```

**Line:** 1275 | **Kind:** fn

### `GetAmpModelMappings`

```
func (h *Handler) GetAmpModelMappings(c *gin.Context) {
```

**Line:** 1280 | **Kind:** fn

### `PutAmpModelMappings`

```
func (h *Handler) PutAmpModelMappings(c *gin.Context) {
```

**Line:** 1289 | **Kind:** fn

### `PatchAmpModelMappings`

```
func (h *Handler) PatchAmpModelMappings(c *gin.Context) {
```

**Line:** 1302 | **Kind:** fn

### `DeleteAmpModelMappings`

```
func (h *Handler) DeleteAmpModelMappings(c *gin.Context) {
```

**Line:** 1329 | **Kind:** fn

### `GetAmpForceModelMappings`

```
func (h *Handler) GetAmpForceModelMappings(c *gin.Context) {
```

**Line:** 1355 | **Kind:** fn

### `PutAmpForceModelMappings`

```
func (h *Handler) PutAmpForceModelMappings(c *gin.Context) {
```

**Line:** 1364 | **Kind:** fn

### `GetAmpUpstreamAPIKeys`

```
func (h *Handler) GetAmpUpstreamAPIKeys(c *gin.Context) {
```

**Line:** 1369 | **Kind:** fn

### `PutAmpUpstreamAPIKeys`

```
func (h *Handler) PutAmpUpstreamAPIKeys(c *gin.Context) {
```

**Line:** 1378 | **Kind:** fn

### `PatchAmpUpstreamAPIKeys`

```
func (h *Handler) PatchAmpUpstreamAPIKeys(c *gin.Context) {
```

**Line:** 1394 | **Kind:** fn

### `DeleteAmpUpstreamAPIKeys`

```
func (h *Handler) DeleteAmpUpstreamAPIKeys(c *gin.Context) {
```

**Line:** 1431 | **Kind:** fn

