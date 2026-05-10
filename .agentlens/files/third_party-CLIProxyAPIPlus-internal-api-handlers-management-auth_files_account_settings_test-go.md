# third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files_account_settings_test.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-api-handlers-management/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1420
- **Language:** Go
- **Symbols:** 16
- **Public symbols:** 15

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 20 | fn | TestGetAuthFileAccountSettings_SplitsLegacyHeadersIntoManagedAndExtra | pub | `func TestGetAuthFileAccountSettings_SplitsLegac...` |
| 88 | fn | TestPatchAuthFileAccountSettings_RewritesRuntimeSnapshotAndStoredSchema | pub | `func TestPatchAuthFileAccountSettings_RewritesR...` |
| 202 | fn | TestPatchAuthFileAccountSettings_DisablesRefreshForAccessTokenOnlyRecords | pub | `func TestPatchAuthFileAccountSettings_DisablesR...` |
| 275 | fn | TestGetAuthFileAccountSettings_PersistsCodexManagedHeaderHistoryAcrossVersionUpgrades | pub | `func TestGetAuthFileAccountSettings_PersistsCod...` |
| 484 | fn | TestGetAuthFileAccountSettings_MigratesLegacyCodexHeadersToManagedState | pub | `func TestGetAuthFileAccountSettings_MigratesLeg...` |
| 567 | fn | TestGetAuthFileAccountSettings_UsesOnlineManagedHeaderSourceAndRecordsHistory | pub | `func TestGetAuthFileAccountSettings_UsesOnlineM...` |
| 730 | fn | TestGetAuthFileAccountSettings_PersistsClaudeManagedHeaderHistoryAcrossVersionUpgrades | pub | `func TestGetAuthFileAccountSettings_PersistsCla...` |
| 907 | fn | TestGetAuthFileAccountSettings_PersistsCoreManagedRuntimeIdentity | pub | `func TestGetAuthFileAccountSettings_PersistsCor...` |
| 1031 | fn | TestPatchAuthFileAccountSettings_AppendsRuntimeIdentityHistoryOnProfileChange | pub | `func TestPatchAuthFileAccountSettings_AppendsRu...` |
| 1117 | fn | TestGetAuthFileAccountSettings_CodexSupportedTransportProfileWarnsAboutScope | pub | `func TestGetAuthFileAccountSettings_CodexSuppor...` |
| 1176 | fn | TestPatchAuthFileAccountSettings_RejectsManagedHeaderConflicts | pub | `func TestPatchAuthFileAccountSettings_RejectsMa...` |
| 1212 | fn | TestGetAuthFileAccountSettings_ClaudeTransportProfileShowsRuntimeActive | pub | `func TestGetAuthFileAccountSettings_ClaudeTrans...` |
| 1266 | fn | TestGetAuthFileAccountSettings_ClaudeTLSProfileShowsRuntimeActive | pub | `func TestGetAuthFileAccountSettings_ClaudeTLSPr...` |
| 1320 | fn | TestGetAuthFileAccountSettings_CodexTLSProfileWarnsAboutScope | pub | `func TestGetAuthFileAccountSettings_CodexTLSPro...` |
| 1372 | fn | TestGetAuthFileAccountSettings_FallsBackToDisplayNameWhenFileNameMissing | pub | `func TestGetAuthFileAccountSettings_FallsBackTo...` |
| 1413 | fn | containsString | (private) | `func containsString(values []string, want strin...` |

## Public API

### `TestGetAuthFileAccountSettings_SplitsLegacyHeadersIntoManagedAndExtra`

```
func TestGetAuthFileAccountSettings_SplitsLegacyHeadersIntoManagedAndExtra(t *testing.T) {
```

**Line:** 20 | **Kind:** fn

### `TestPatchAuthFileAccountSettings_RewritesRuntimeSnapshotAndStoredSchema`

```
func TestPatchAuthFileAccountSettings_RewritesRuntimeSnapshotAndStoredSchema(t *testing.T) {
```

**Line:** 88 | **Kind:** fn

### `TestPatchAuthFileAccountSettings_DisablesRefreshForAccessTokenOnlyRecords`

```
func TestPatchAuthFileAccountSettings_DisablesRefreshForAccessTokenOnlyRecords(t *testing.T) {
```

**Line:** 202 | **Kind:** fn

### `TestGetAuthFileAccountSettings_PersistsCodexManagedHeaderHistoryAcrossVersionUpgrades`

```
func TestGetAuthFileAccountSettings_PersistsCodexManagedHeaderHistoryAcrossVersionUpgrades(t *testing.T) {
```

**Line:** 275 | **Kind:** fn

### `TestGetAuthFileAccountSettings_MigratesLegacyCodexHeadersToManagedState`

```
func TestGetAuthFileAccountSettings_MigratesLegacyCodexHeadersToManagedState(t *testing.T) {
```

**Line:** 484 | **Kind:** fn

### `TestGetAuthFileAccountSettings_UsesOnlineManagedHeaderSourceAndRecordsHistory`

```
func TestGetAuthFileAccountSettings_UsesOnlineManagedHeaderSourceAndRecordsHistory(t *testing.T) {
```

**Line:** 567 | **Kind:** fn

### `TestGetAuthFileAccountSettings_PersistsClaudeManagedHeaderHistoryAcrossVersionUpgrades`

```
func TestGetAuthFileAccountSettings_PersistsClaudeManagedHeaderHistoryAcrossVersionUpgrades(t *testing.T) {
```

**Line:** 730 | **Kind:** fn

### `TestGetAuthFileAccountSettings_PersistsCoreManagedRuntimeIdentity`

```
func TestGetAuthFileAccountSettings_PersistsCoreManagedRuntimeIdentity(t *testing.T) {
```

**Line:** 907 | **Kind:** fn

### `TestPatchAuthFileAccountSettings_AppendsRuntimeIdentityHistoryOnProfileChange`

```
func TestPatchAuthFileAccountSettings_AppendsRuntimeIdentityHistoryOnProfileChange(t *testing.T) {
```

**Line:** 1031 | **Kind:** fn

### `TestGetAuthFileAccountSettings_CodexSupportedTransportProfileWarnsAboutScope`

```
func TestGetAuthFileAccountSettings_CodexSupportedTransportProfileWarnsAboutScope(t *testing.T) {
```

**Line:** 1117 | **Kind:** fn

### `TestPatchAuthFileAccountSettings_RejectsManagedHeaderConflicts`

```
func TestPatchAuthFileAccountSettings_RejectsManagedHeaderConflicts(t *testing.T) {
```

**Line:** 1176 | **Kind:** fn

### `TestGetAuthFileAccountSettings_ClaudeTransportProfileShowsRuntimeActive`

```
func TestGetAuthFileAccountSettings_ClaudeTransportProfileShowsRuntimeActive(t *testing.T) {
```

**Line:** 1212 | **Kind:** fn

### `TestGetAuthFileAccountSettings_ClaudeTLSProfileShowsRuntimeActive`

```
func TestGetAuthFileAccountSettings_ClaudeTLSProfileShowsRuntimeActive(t *testing.T) {
```

**Line:** 1266 | **Kind:** fn

### `TestGetAuthFileAccountSettings_CodexTLSProfileWarnsAboutScope`

```
func TestGetAuthFileAccountSettings_CodexTLSProfileWarnsAboutScope(t *testing.T) {
```

**Line:** 1320 | **Kind:** fn

### `TestGetAuthFileAccountSettings_FallsBackToDisplayNameWhenFileNameMissing`

```
func TestGetAuthFileAccountSettings_FallsBackToDisplayNameWhenFileNameMissing(t *testing.T) {
```

**Line:** 1372 | **Kind:** fn

