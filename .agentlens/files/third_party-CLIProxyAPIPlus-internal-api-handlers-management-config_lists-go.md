# third_party/CLIProxyAPIPlus/internal/api/handlers/management/config_lists.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-api-handlers-management/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1377
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
| 146 | fn | PatchGeminiKey | pub | `func (h *Handler) PatchGeminiKey(c *gin.Context) {` |
| 215 | fn | DeleteGeminiKey | pub | `func (h *Handler) DeleteGeminiKey(c *gin.Contex...` |
| 245 | fn | GetClaudeKeys | pub | `func (h *Handler) GetClaudeKeys(c *gin.Context) {` |
| 248 | fn | PutClaudeKeys | pub | `func (h *Handler) PutClaudeKeys(c *gin.Context) {` |
| 272 | fn | PatchClaudeKey | pub | `func (h *Handler) PatchClaudeKey(c *gin.Context) {` |
| 337 | fn | DeleteClaudeKey | pub | `func (h *Handler) DeleteClaudeKey(c *gin.Contex...` |
| 364 | fn | GetOpenAICompat | pub | `func (h *Handler) GetOpenAICompat(c *gin.Contex...` |
| 367 | fn | PutOpenAICompat | pub | `func (h *Handler) PutOpenAICompat(c *gin.Contex...` |
| 395 | fn | PatchOpenAICompat | pub | `func (h *Handler) PatchOpenAICompat(c *gin.Cont...` |
| 463 | fn | DeleteOpenAICompat | pub | `func (h *Handler) DeleteOpenAICompat(c *gin.Con...` |
| 490 | fn | GetVertexCompatKeys | pub | `func (h *Handler) GetVertexCompatKeys(c *gin.Co...` |
| 493 | fn | PutVertexCompatKeys | pub | `func (h *Handler) PutVertexCompatKeys(c *gin.Co...` |
| 521 | fn | PatchVertexCompatKey | pub | `func (h *Handler) PatchVertexCompatKey(c *gin.C...` |
| 602 | fn | DeleteVertexCompatKey | pub | `func (h *Handler) DeleteVertexCompatKey(c *gin....` |
| 629 | fn | GetOAuthExcludedModels | pub | `func (h *Handler) GetOAuthExcludedModels(c *gin...` |
| 633 | fn | PutOAuthExcludedModels | pub | `func (h *Handler) PutOAuthExcludedModels(c *gin...` |
| 654 | fn | PatchOAuthExcludedModels | pub | `func (h *Handler) PatchOAuthExcludedModels(c *g...` |
| 692 | fn | DeleteOAuthExcludedModels | pub | `func (h *Handler) DeleteOAuthExcludedModels(c *...` |
| 714 | fn | GetOAuthModelAlias | pub | `func (h *Handler) GetOAuthModelAlias(c *gin.Con...` |
| 718 | fn | PutOAuthModelAlias | pub | `func (h *Handler) PutOAuthModelAlias(c *gin.Con...` |
| 739 | fn | PatchOAuthModelAlias | pub | `func (h *Handler) PatchOAuthModelAlias(c *gin.C...` |
| 790 | fn | DeleteOAuthModelAlias | pub | `func (h *Handler) DeleteOAuthModelAlias(c *gin....` |
| 815 | fn | GetCodexKeys | pub | `func (h *Handler) GetCodexKeys(c *gin.Context) {` |
| 818 | fn | PutCodexKeys | pub | `func (h *Handler) PutCodexKeys(c *gin.Context) {` |
| 849 | fn | PatchCodexKey | pub | `func (h *Handler) PatchCodexKey(c *gin.Context) {` |
| 921 | fn | DeleteCodexKey | pub | `func (h *Handler) DeleteCodexKey(c *gin.Context) {` |
| 947 | fn | normalizeOpenAICompatibilityEntry | (private) | `func normalizeOpenAICompatibilityEntry(entry *c...` |
| 964 | fn | normalizedOpenAICompatibilityEntries | (private) | `func normalizedOpenAICompatibilityEntries(entri...` |
| 980 | fn | normalizeClaudeKey | (private) | `func normalizeClaudeKey(entry *config.ClaudeKey) {` |
| 1005 | fn | normalizeCodexKey | (private) | `func normalizeCodexKey(entry *config.CodexKey) {` |
| 1031 | fn | normalizeVertexCompatKey | (private) | `func normalizeVertexCompatKey(entry *config.Ver...` |
| 1057 | fn | sanitizedOAuthModelAlias | (private) | `func sanitizedOAuthModelAlias(entries map[strin...` |
| 1080 | fn | GetAmpCode | pub | `func (h *Handler) GetAmpCode(c *gin.Context) {` |
| 1089 | fn | GetAmpUpstreamURL | pub | `func (h *Handler) GetAmpUpstreamURL(c *gin.Cont...` |
| 1098 | fn | PutAmpUpstreamURL | pub | `func (h *Handler) PutAmpUpstreamURL(c *gin.Cont...` |
| 1103 | fn | DeleteAmpUpstreamURL | pub | `func (h *Handler) DeleteAmpUpstreamURL(c *gin.C...` |
| 1109 | fn | GetAmpUpstreamAPIKey | pub | `func (h *Handler) GetAmpUpstreamAPIKey(c *gin.C...` |
| 1118 | fn | PutAmpUpstreamAPIKey | pub | `func (h *Handler) PutAmpUpstreamAPIKey(c *gin.C...` |
| 1123 | fn | DeleteAmpUpstreamAPIKey | pub | `func (h *Handler) DeleteAmpUpstreamAPIKey(c *gi...` |
| 1129 | fn | GetAmpRestrictManagementToLocalhost | pub | `func (h *Handler) GetAmpRestrictManagementToLoc...` |
| 1138 | fn | PutAmpRestrictManagementToLocalhost | pub | `func (h *Handler) PutAmpRestrictManagementToLoc...` |
| 1143 | fn | GetAmpModelMappings | pub | `func (h *Handler) GetAmpModelMappings(c *gin.Co...` |
| 1152 | fn | PutAmpModelMappings | pub | `func (h *Handler) PutAmpModelMappings(c *gin.Co...` |
| 1165 | fn | PatchAmpModelMappings | pub | `func (h *Handler) PatchAmpModelMappings(c *gin....` |
| 1192 | fn | DeleteAmpModelMappings | pub | `func (h *Handler) DeleteAmpModelMappings(c *gin...` |
| 1218 | fn | GetAmpForceModelMappings | pub | `func (h *Handler) GetAmpForceModelMappings(c *g...` |
| 1227 | fn | PutAmpForceModelMappings | pub | `func (h *Handler) PutAmpForceModelMappings(c *g...` |
| 1232 | fn | GetAmpUpstreamAPIKeys | pub | `func (h *Handler) GetAmpUpstreamAPIKeys(c *gin....` |
| 1241 | fn | PutAmpUpstreamAPIKeys | pub | `func (h *Handler) PutAmpUpstreamAPIKeys(c *gin....` |
| 1257 | fn | PatchAmpUpstreamAPIKeys | pub | `func (h *Handler) PatchAmpUpstreamAPIKeys(c *gi...` |
| 1294 | fn | DeleteAmpUpstreamAPIKeys | pub | `func (h *Handler) DeleteAmpUpstreamAPIKeys(c *g...` |
| 1339 | fn | normalizeAmpUpstreamAPIKeyEntries | (private) | `func normalizeAmpUpstreamAPIKeyEntries(entries ...` |
| 1362 | fn | normalizeAPIKeysList | (private) | `func normalizeAPIKeysList(keys []string) []stri...` |

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

**Line:** 146 | **Kind:** fn

### `DeleteGeminiKey`

```
func (h *Handler) DeleteGeminiKey(c *gin.Context) {
```

**Line:** 215 | **Kind:** fn

### `GetClaudeKeys`

```
func (h *Handler) GetClaudeKeys(c *gin.Context) {
```

**Line:** 245 | **Kind:** fn

### `PutClaudeKeys`

```
func (h *Handler) PutClaudeKeys(c *gin.Context) {
```

**Line:** 248 | **Kind:** fn

### `PatchClaudeKey`

```
func (h *Handler) PatchClaudeKey(c *gin.Context) {
```

**Line:** 272 | **Kind:** fn

### `DeleteClaudeKey`

```
func (h *Handler) DeleteClaudeKey(c *gin.Context) {
```

**Line:** 337 | **Kind:** fn

### `GetOpenAICompat`

```
func (h *Handler) GetOpenAICompat(c *gin.Context) {
```

**Line:** 364 | **Kind:** fn

### `PutOpenAICompat`

```
func (h *Handler) PutOpenAICompat(c *gin.Context) {
```

**Line:** 367 | **Kind:** fn

### `PatchOpenAICompat`

```
func (h *Handler) PatchOpenAICompat(c *gin.Context) {
```

**Line:** 395 | **Kind:** fn

### `DeleteOpenAICompat`

```
func (h *Handler) DeleteOpenAICompat(c *gin.Context) {
```

**Line:** 463 | **Kind:** fn

### `GetVertexCompatKeys`

```
func (h *Handler) GetVertexCompatKeys(c *gin.Context) {
```

**Line:** 490 | **Kind:** fn

### `PutVertexCompatKeys`

```
func (h *Handler) PutVertexCompatKeys(c *gin.Context) {
```

**Line:** 493 | **Kind:** fn

### `PatchVertexCompatKey`

```
func (h *Handler) PatchVertexCompatKey(c *gin.Context) {
```

**Line:** 521 | **Kind:** fn

### `DeleteVertexCompatKey`

```
func (h *Handler) DeleteVertexCompatKey(c *gin.Context) {
```

**Line:** 602 | **Kind:** fn

### `GetOAuthExcludedModels`

```
func (h *Handler) GetOAuthExcludedModels(c *gin.Context) {
```

**Line:** 629 | **Kind:** fn

### `PutOAuthExcludedModels`

```
func (h *Handler) PutOAuthExcludedModels(c *gin.Context) {
```

**Line:** 633 | **Kind:** fn

### `PatchOAuthExcludedModels`

```
func (h *Handler) PatchOAuthExcludedModels(c *gin.Context) {
```

**Line:** 654 | **Kind:** fn

### `DeleteOAuthExcludedModels`

```
func (h *Handler) DeleteOAuthExcludedModels(c *gin.Context) {
```

**Line:** 692 | **Kind:** fn

### `GetOAuthModelAlias`

```
func (h *Handler) GetOAuthModelAlias(c *gin.Context) {
```

**Line:** 714 | **Kind:** fn

### `PutOAuthModelAlias`

```
func (h *Handler) PutOAuthModelAlias(c *gin.Context) {
```

**Line:** 718 | **Kind:** fn

### `PatchOAuthModelAlias`

```
func (h *Handler) PatchOAuthModelAlias(c *gin.Context) {
```

**Line:** 739 | **Kind:** fn

### `DeleteOAuthModelAlias`

```
func (h *Handler) DeleteOAuthModelAlias(c *gin.Context) {
```

**Line:** 790 | **Kind:** fn

### `GetCodexKeys`

```
func (h *Handler) GetCodexKeys(c *gin.Context) {
```

**Line:** 815 | **Kind:** fn

### `PutCodexKeys`

```
func (h *Handler) PutCodexKeys(c *gin.Context) {
```

**Line:** 818 | **Kind:** fn

### `PatchCodexKey`

```
func (h *Handler) PatchCodexKey(c *gin.Context) {
```

**Line:** 849 | **Kind:** fn

### `DeleteCodexKey`

```
func (h *Handler) DeleteCodexKey(c *gin.Context) {
```

**Line:** 921 | **Kind:** fn

### `GetAmpCode`

```
func (h *Handler) GetAmpCode(c *gin.Context) {
```

**Line:** 1080 | **Kind:** fn

### `GetAmpUpstreamURL`

```
func (h *Handler) GetAmpUpstreamURL(c *gin.Context) {
```

**Line:** 1089 | **Kind:** fn

### `PutAmpUpstreamURL`

```
func (h *Handler) PutAmpUpstreamURL(c *gin.Context) {
```

**Line:** 1098 | **Kind:** fn

### `DeleteAmpUpstreamURL`

```
func (h *Handler) DeleteAmpUpstreamURL(c *gin.Context) {
```

**Line:** 1103 | **Kind:** fn

### `GetAmpUpstreamAPIKey`

```
func (h *Handler) GetAmpUpstreamAPIKey(c *gin.Context) {
```

**Line:** 1109 | **Kind:** fn

### `PutAmpUpstreamAPIKey`

```
func (h *Handler) PutAmpUpstreamAPIKey(c *gin.Context) {
```

**Line:** 1118 | **Kind:** fn

### `DeleteAmpUpstreamAPIKey`

```
func (h *Handler) DeleteAmpUpstreamAPIKey(c *gin.Context) {
```

**Line:** 1123 | **Kind:** fn

### `GetAmpRestrictManagementToLocalhost`

```
func (h *Handler) GetAmpRestrictManagementToLocalhost(c *gin.Context) {
```

**Line:** 1129 | **Kind:** fn

### `PutAmpRestrictManagementToLocalhost`

```
func (h *Handler) PutAmpRestrictManagementToLocalhost(c *gin.Context) {
```

**Line:** 1138 | **Kind:** fn

### `GetAmpModelMappings`

```
func (h *Handler) GetAmpModelMappings(c *gin.Context) {
```

**Line:** 1143 | **Kind:** fn

### `PutAmpModelMappings`

```
func (h *Handler) PutAmpModelMappings(c *gin.Context) {
```

**Line:** 1152 | **Kind:** fn

### `PatchAmpModelMappings`

```
func (h *Handler) PatchAmpModelMappings(c *gin.Context) {
```

**Line:** 1165 | **Kind:** fn

### `DeleteAmpModelMappings`

```
func (h *Handler) DeleteAmpModelMappings(c *gin.Context) {
```

**Line:** 1192 | **Kind:** fn

### `GetAmpForceModelMappings`

```
func (h *Handler) GetAmpForceModelMappings(c *gin.Context) {
```

**Line:** 1218 | **Kind:** fn

### `PutAmpForceModelMappings`

```
func (h *Handler) PutAmpForceModelMappings(c *gin.Context) {
```

**Line:** 1227 | **Kind:** fn

### `GetAmpUpstreamAPIKeys`

```
func (h *Handler) GetAmpUpstreamAPIKeys(c *gin.Context) {
```

**Line:** 1232 | **Kind:** fn

### `PutAmpUpstreamAPIKeys`

```
func (h *Handler) PutAmpUpstreamAPIKeys(c *gin.Context) {
```

**Line:** 1241 | **Kind:** fn

### `PatchAmpUpstreamAPIKeys`

```
func (h *Handler) PatchAmpUpstreamAPIKeys(c *gin.Context) {
```

**Line:** 1257 | **Kind:** fn

### `DeleteAmpUpstreamAPIKeys`

```
func (h *Handler) DeleteAmpUpstreamAPIKeys(c *gin.Context) {
```

**Line:** 1294 | **Kind:** fn

