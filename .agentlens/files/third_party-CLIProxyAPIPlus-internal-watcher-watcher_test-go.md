# third_party/CLIProxyAPIPlus/internal/watcher/watcher_test.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1693
- **Language:** Go
- **Symbols:** 70
- **Public symbols:** 67

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 25 | fn | TestApplyAuthExcludedModelsMeta_APIKey | pub | `func TestApplyAuthExcludedModelsMeta_APIKey(t *...` |
| 41 | fn | TestApplyAuthExcludedModelsMeta_OAuthProvider | pub | `func TestApplyAuthExcludedModelsMeta_OAuthProvi...` |
| 63 | fn | TestBuildAPIKeyClientsCounts | pub | `func TestBuildAPIKeyClientsCounts(t *testing.T) {` |
| 82 | fn | TestNormalizeAuthStripsTemporalFields | pub | `func TestNormalizeAuthStripsTemporalFields(t *t...` |
| 107 | fn | TestMatchProvider | pub | `func TestMatchProvider(t *testing.T) {` |
| 116 | fn | TestSnapshotCoreAuths_ConfigAndAuthFiles | pub | `func TestSnapshotCoreAuths_ConfigAndAuthFiles(t...` |
| 210 | fn | TestReloadConfigIfChanged_TriggersOnChangeAndSkipsUnchanged | pub | `func TestReloadConfigIfChanged_TriggersOnChange...` |
| 267 | fn | TestStartAndStopSuccess | pub | `func TestStartAndStopSuccess(t *testing.T) {` |
| 302 | fn | TestStartFailsWhenConfigMissing | pub | `func TestStartFailsWhenConfigMissing(t *testing...` |
| 324 | fn | TestDispatchRuntimeAuthUpdateEnqueuesAndUpdatesState | pub | `func TestDispatchRuntimeAuthUpdateEnqueuesAndUp...` |
| 363 | fn | TestAddOrUpdateClientSkipsUnchanged | pub | `func TestAddOrUpdateClientSkipsUnchanged(t *tes...` |
| 390 | fn | TestAddOrUpdateClientTriggersReloadAndHash | pub | `func TestAddOrUpdateClientTriggersReloadAndHash...` |
| 419 | fn | TestRemoveClientRemovesHash | pub | `func TestRemoveClientRemovesHash(t *testing.T) {` |
| 444 | fn | TestAuthFileEventsDoNotInvokeSnapshotCoreAuths | pub | `func TestAuthFileEventsDoNotInvokeSnapshotCoreA...` |
| 475 | fn | TestAuthSliceToMap | pub | `func TestAuthSliceToMap(t *testing.T) {` |
| 546 | fn | TestTriggerServerUpdateCancelsPendingTimerOnImmediate | pub | `func TestTriggerServerUpdateCancelsPendingTimer...` |
| 586 | fn | TestShouldDebounceRemove | pub | `func TestShouldDebounceRemove(t *testing.T) {` |
| 606 | fn | TestAuthFileUnchangedUsesHash | pub | `func TestAuthFileUnchangedUsesHash(t *testing.T) {` |
| 636 | fn | TestAuthFileUnchangedEmptyAndMissing | pub | `func TestAuthFileUnchangedEmptyAndMissing(t *te...` |
| 658 | fn | TestReloadClientsCachesAuthHashes | pub | `func TestReloadClientsCachesAuthHashes(t *testi...` |
| 678 | fn | TestReloadClientsLogsConfigDiffs | pub | `func TestReloadClientsLogsConfigDiffs(t *testin...` |
| 697 | fn | TestReloadClientsHandlesNilConfig | pub | `func TestReloadClientsHandlesNilConfig(t *testi...` |
| 702 | fn | TestReloadClientsFiltersProvidersWithNilCurrentAuths | pub | `func TestReloadClientsFiltersProvidersWithNilCu...` |
| 714 | fn | TestSetAuthUpdateQueueNilResetsDispatch | pub | `func TestSetAuthUpdateQueueNilResetsDispatch(t ...` |
| 727 | fn | TestPersistAsyncEarlyReturns | pub | `func TestPersistAsyncEarlyReturns(t *testing.T) {` |
| 737 | struct | errorPersister | (private) | - |
| 742 | fn | PersistConfig | pub | `func (p *errorPersister) PersistConfig(context....` |
| 747 | fn | PersistAuthFiles | pub | `func (p *errorPersister) PersistAuthFiles(conte...` |
| 752 | fn | TestPersistAsyncErrorPaths | pub | `func TestPersistAsyncErrorPaths(t *testing.T) {` |
| 766 | fn | TestStopConfigReloadTimerSafeWhenNil | pub | `func TestStopConfigReloadTimerSafeWhenNil(t *te...` |
| 776 | fn | TestHandleEventRemovesAuthFile | pub | `func TestHandleEventRemovesAuthFile(t *testing....` |
| 808 | fn | TestDispatchAuthUpdatesFlushesQueue | pub | `func TestDispatchAuthUpdatesFlushesQueue(t *tes...` |
| 833 | fn | TestDispatchLoopExitsOnContextDoneWhileSending | pub | `func TestDispatchLoopExitsOnContextDoneWhileSen...` |
| 860 | fn | TestProcessEventsHandlesEventErrorAndChannelClose | pub | `func TestProcessEventsHandlesEventErrorAndChann...` |
| 893 | fn | TestProcessEventsReturnsWhenErrorsChannelClosed | pub | `func TestProcessEventsReturnsWhenErrorsChannelC...` |
| 919 | fn | TestHandleEventIgnoresUnrelatedFiles | pub | `func TestHandleEventIgnoresUnrelatedFiles(t *te...` |
| 945 | fn | TestHandleEventConfigChangeSchedulesReload | pub | `func TestHandleEventConfigChangeSchedulesReload...` |
| 973 | fn | TestHandleEventAuthWriteTriggersUpdate | pub | `func TestHandleEventAuthWriteTriggersUpdate(t *...` |
| 1003 | fn | TestHandleEventRemoveDebounceSkips | pub | `func TestHandleEventRemoveDebounceSkips(t *test...` |
| 1033 | fn | TestHandleEventAtomicReplaceUnchangedSkips | pub | `func TestHandleEventAtomicReplaceUnchangedSkips...` |
| 1066 | fn | TestHandleEventAtomicReplaceChangedTriggersUpdate | pub | `func TestHandleEventAtomicReplaceChangedTrigger...` |
| 1100 | fn | TestHandleEventRemoveUnknownFileIgnored | pub | `func TestHandleEventRemoveUnknownFileIgnored(t ...` |
| 1127 | fn | TestHandleEventRemoveKnownFileDeletes | pub | `func TestHandleEventRemoveKnownFileDeletes(t *t...` |
| 1158 | fn | TestNormalizeAuthPathAndDebounceCleanup | pub | `func TestNormalizeAuthPathAndDebounceCleanup(t ...` |
| 1185 | fn | TestRefreshAuthStateDispatchesRuntimeAuths | pub | `func TestRefreshAuthStateDispatchesRuntimeAuths...` |
| 1214 | fn | TestAddOrUpdateClientEdgeCases | pub | `func TestAddOrUpdateClientEdgeCases(t *testing....` |
| 1245 | fn | TestLoadFileClientsWalkError | pub | `func TestLoadFileClientsWalkError(t *testing.T) {` |
| 1266 | fn | TestReloadConfigIfChangedHandlesMissingAndEmpty | pub | `func TestReloadConfigIfChangedHandlesMissingAnd...` |
| 1287 | fn | TestReloadConfigUsesMirroredAuthDir | pub | `func TestReloadConfigUsesMirroredAuthDir(t *tes...` |
| 1318 | fn | TestReloadConfigFiltersAffectedOAuthProviders | pub | `func TestReloadConfigFiltersAffectedOAuthProvid...` |
| 1384 | fn | TestReloadConfigTriggersCallbackForMaxRetryCredentialsChange | pub | `func TestReloadConfigTriggersCallbackForMaxRetr...` |
| 1445 | fn | TestStartFailsWhenAuthDirMissing | pub | `func TestStartFailsWhenAuthDirMissing(t *testin...` |
| 1468 | fn | TestDispatchRuntimeAuthUpdateReturnsFalseWithoutQueue | pub | `func TestDispatchRuntimeAuthUpdateReturnsFalseW...` |
| 1478 | fn | TestNormalizeAuthNil | pub | `func TestNormalizeAuthNil(t *testing.T) {` |
| 1485 | struct | stubStore | (private) | - |
| 1493 | fn | List | pub | `func (s *stubStore) List(context.Context) ([]*c...` |
| 1494 | fn | Save | pub | `func (s *stubStore) Save(context.Context, *core...` |
| 1497 | fn | Delete | pub | `func (s *stubStore) Delete(context.Context, str...` |
| 1498 | fn | PersistConfig | pub | `func (s *stubStore) PersistConfig(context.Conte...` |
| 1502 | fn | PersistAuthFiles | pub | `func (s *stubStore) PersistAuthFiles(_ context....` |
| 1508 | fn | AuthDir | pub | `func (s *stubStore) AuthDir() string { return s...` |
| 1510 | fn | TestNewWatcherDetectsPersisterAndAuthDir | pub | `func TestNewWatcherDetectsPersisterAndAuthDir(t...` |
| 1529 | fn | TestPersistConfigAndAuthAsyncInvokePersister | pub | `func TestPersistConfigAndAuthAsyncInvokePersist...` |
| 1553 | fn | TestScheduleConfigReloadDebounces | pub | `func TestScheduleConfigReloadDebounces(t *testi...` |
| 1582 | fn | TestPrepareAuthUpdatesLockedForceAndDelete | pub | `func TestPrepareAuthUpdatesLockedForceAndDelete...` |
| 1606 | fn | TestAuthEqualIgnoresTemporalFields | pub | `func TestAuthEqualIgnoresTemporalFields(t *test...` |
| 1615 | fn | TestDispatchLoopExitsWhenQueueNilAndContextCanceled | pub | `func TestDispatchLoopExitsWhenQueueNilAndContex...` |
| 1643 | fn | TestReloadClientsFiltersOAuthProvidersWithoutRescan | pub | `func TestReloadClientsFiltersOAuthProvidersWith...` |
| 1667 | fn | TestScheduleProcessEventsStopsOnContextDone | pub | `func TestScheduleProcessEventsStopsOnContextDon...` |
| 1691 | fn | hexString | (private) | `func hexString(data []byte) string {` |

## Public API

### `TestApplyAuthExcludedModelsMeta_APIKey`

```
func TestApplyAuthExcludedModelsMeta_APIKey(t *testing.T) {
```

**Line:** 25 | **Kind:** fn

### `TestApplyAuthExcludedModelsMeta_OAuthProvider`

```
func TestApplyAuthExcludedModelsMeta_OAuthProvider(t *testing.T) {
```

**Line:** 41 | **Kind:** fn

### `TestBuildAPIKeyClientsCounts`

```
func TestBuildAPIKeyClientsCounts(t *testing.T) {
```

**Line:** 63 | **Kind:** fn

### `TestNormalizeAuthStripsTemporalFields`

```
func TestNormalizeAuthStripsTemporalFields(t *testing.T) {
```

**Line:** 82 | **Kind:** fn

### `TestMatchProvider`

```
func TestMatchProvider(t *testing.T) {
```

**Line:** 107 | **Kind:** fn

### `TestSnapshotCoreAuths_ConfigAndAuthFiles`

```
func TestSnapshotCoreAuths_ConfigAndAuthFiles(t *testing.T) {
```

**Line:** 116 | **Kind:** fn

### `TestReloadConfigIfChanged_TriggersOnChangeAndSkipsUnchanged`

```
func TestReloadConfigIfChanged_TriggersOnChangeAndSkipsUnchanged(t *testing.T) {
```

**Line:** 210 | **Kind:** fn

### `TestStartAndStopSuccess`

```
func TestStartAndStopSuccess(t *testing.T) {
```

**Line:** 267 | **Kind:** fn

### `TestStartFailsWhenConfigMissing`

```
func TestStartFailsWhenConfigMissing(t *testing.T) {
```

**Line:** 302 | **Kind:** fn

### `TestDispatchRuntimeAuthUpdateEnqueuesAndUpdatesState`

```
func TestDispatchRuntimeAuthUpdateEnqueuesAndUpdatesState(t *testing.T) {
```

**Line:** 324 | **Kind:** fn

### `TestAddOrUpdateClientSkipsUnchanged`

```
func TestAddOrUpdateClientSkipsUnchanged(t *testing.T) {
```

**Line:** 363 | **Kind:** fn

### `TestAddOrUpdateClientTriggersReloadAndHash`

```
func TestAddOrUpdateClientTriggersReloadAndHash(t *testing.T) {
```

**Line:** 390 | **Kind:** fn

### `TestRemoveClientRemovesHash`

```
func TestRemoveClientRemovesHash(t *testing.T) {
```

**Line:** 419 | **Kind:** fn

### `TestAuthFileEventsDoNotInvokeSnapshotCoreAuths`

```
func TestAuthFileEventsDoNotInvokeSnapshotCoreAuths(t *testing.T) {
```

**Line:** 444 | **Kind:** fn

### `TestAuthSliceToMap`

```
func TestAuthSliceToMap(t *testing.T) {
```

**Line:** 475 | **Kind:** fn

### `TestTriggerServerUpdateCancelsPendingTimerOnImmediate`

```
func TestTriggerServerUpdateCancelsPendingTimerOnImmediate(t *testing.T) {
```

**Line:** 546 | **Kind:** fn

### `TestShouldDebounceRemove`

```
func TestShouldDebounceRemove(t *testing.T) {
```

**Line:** 586 | **Kind:** fn

### `TestAuthFileUnchangedUsesHash`

```
func TestAuthFileUnchangedUsesHash(t *testing.T) {
```

**Line:** 606 | **Kind:** fn

### `TestAuthFileUnchangedEmptyAndMissing`

```
func TestAuthFileUnchangedEmptyAndMissing(t *testing.T) {
```

**Line:** 636 | **Kind:** fn

### `TestReloadClientsCachesAuthHashes`

```
func TestReloadClientsCachesAuthHashes(t *testing.T) {
```

**Line:** 658 | **Kind:** fn

### `TestReloadClientsLogsConfigDiffs`

```
func TestReloadClientsLogsConfigDiffs(t *testing.T) {
```

**Line:** 678 | **Kind:** fn

### `TestReloadClientsHandlesNilConfig`

```
func TestReloadClientsHandlesNilConfig(t *testing.T) {
```

**Line:** 697 | **Kind:** fn

### `TestReloadClientsFiltersProvidersWithNilCurrentAuths`

```
func TestReloadClientsFiltersProvidersWithNilCurrentAuths(t *testing.T) {
```

**Line:** 702 | **Kind:** fn

### `TestSetAuthUpdateQueueNilResetsDispatch`

```
func TestSetAuthUpdateQueueNilResetsDispatch(t *testing.T) {
```

**Line:** 714 | **Kind:** fn

### `TestPersistAsyncEarlyReturns`

```
func TestPersistAsyncEarlyReturns(t *testing.T) {
```

**Line:** 727 | **Kind:** fn

### `PersistConfig`

```
func (p *errorPersister) PersistConfig(context.Context) error {
```

**Line:** 742 | **Kind:** fn

### `PersistAuthFiles`

```
func (p *errorPersister) PersistAuthFiles(context.Context, string, ...string) error {
```

**Line:** 747 | **Kind:** fn

### `TestPersistAsyncErrorPaths`

```
func TestPersistAsyncErrorPaths(t *testing.T) {
```

**Line:** 752 | **Kind:** fn

### `TestStopConfigReloadTimerSafeWhenNil`

```
func TestStopConfigReloadTimerSafeWhenNil(t *testing.T) {
```

**Line:** 766 | **Kind:** fn

### `TestHandleEventRemovesAuthFile`

```
func TestHandleEventRemovesAuthFile(t *testing.T) {
```

**Line:** 776 | **Kind:** fn

### `TestDispatchAuthUpdatesFlushesQueue`

```
func TestDispatchAuthUpdatesFlushesQueue(t *testing.T) {
```

**Line:** 808 | **Kind:** fn

### `TestDispatchLoopExitsOnContextDoneWhileSending`

```
func TestDispatchLoopExitsOnContextDoneWhileSending(t *testing.T) {
```

**Line:** 833 | **Kind:** fn

### `TestProcessEventsHandlesEventErrorAndChannelClose`

```
func TestProcessEventsHandlesEventErrorAndChannelClose(t *testing.T) {
```

**Line:** 860 | **Kind:** fn

### `TestProcessEventsReturnsWhenErrorsChannelClosed`

```
func TestProcessEventsReturnsWhenErrorsChannelClosed(t *testing.T) {
```

**Line:** 893 | **Kind:** fn

### `TestHandleEventIgnoresUnrelatedFiles`

```
func TestHandleEventIgnoresUnrelatedFiles(t *testing.T) {
```

**Line:** 919 | **Kind:** fn

### `TestHandleEventConfigChangeSchedulesReload`

```
func TestHandleEventConfigChangeSchedulesReload(t *testing.T) {
```

**Line:** 945 | **Kind:** fn

### `TestHandleEventAuthWriteTriggersUpdate`

```
func TestHandleEventAuthWriteTriggersUpdate(t *testing.T) {
```

**Line:** 973 | **Kind:** fn

### `TestHandleEventRemoveDebounceSkips`

```
func TestHandleEventRemoveDebounceSkips(t *testing.T) {
```

**Line:** 1003 | **Kind:** fn

### `TestHandleEventAtomicReplaceUnchangedSkips`

```
func TestHandleEventAtomicReplaceUnchangedSkips(t *testing.T) {
```

**Line:** 1033 | **Kind:** fn

### `TestHandleEventAtomicReplaceChangedTriggersUpdate`

```
func TestHandleEventAtomicReplaceChangedTriggersUpdate(t *testing.T) {
```

**Line:** 1066 | **Kind:** fn

### `TestHandleEventRemoveUnknownFileIgnored`

```
func TestHandleEventRemoveUnknownFileIgnored(t *testing.T) {
```

**Line:** 1100 | **Kind:** fn

### `TestHandleEventRemoveKnownFileDeletes`

```
func TestHandleEventRemoveKnownFileDeletes(t *testing.T) {
```

**Line:** 1127 | **Kind:** fn

### `TestNormalizeAuthPathAndDebounceCleanup`

```
func TestNormalizeAuthPathAndDebounceCleanup(t *testing.T) {
```

**Line:** 1158 | **Kind:** fn

### `TestRefreshAuthStateDispatchesRuntimeAuths`

```
func TestRefreshAuthStateDispatchesRuntimeAuths(t *testing.T) {
```

**Line:** 1185 | **Kind:** fn

### `TestAddOrUpdateClientEdgeCases`

```
func TestAddOrUpdateClientEdgeCases(t *testing.T) {
```

**Line:** 1214 | **Kind:** fn

### `TestLoadFileClientsWalkError`

```
func TestLoadFileClientsWalkError(t *testing.T) {
```

**Line:** 1245 | **Kind:** fn

### `TestReloadConfigIfChangedHandlesMissingAndEmpty`

```
func TestReloadConfigIfChangedHandlesMissingAndEmpty(t *testing.T) {
```

**Line:** 1266 | **Kind:** fn

### `TestReloadConfigUsesMirroredAuthDir`

```
func TestReloadConfigUsesMirroredAuthDir(t *testing.T) {
```

**Line:** 1287 | **Kind:** fn

### `TestReloadConfigFiltersAffectedOAuthProviders`

```
func TestReloadConfigFiltersAffectedOAuthProviders(t *testing.T) {
```

**Line:** 1318 | **Kind:** fn

### `TestReloadConfigTriggersCallbackForMaxRetryCredentialsChange`

```
func TestReloadConfigTriggersCallbackForMaxRetryCredentialsChange(t *testing.T) {
```

**Line:** 1384 | **Kind:** fn

### `TestStartFailsWhenAuthDirMissing`

```
func TestStartFailsWhenAuthDirMissing(t *testing.T) {
```

**Line:** 1445 | **Kind:** fn

### `TestDispatchRuntimeAuthUpdateReturnsFalseWithoutQueue`

```
func TestDispatchRuntimeAuthUpdateReturnsFalseWithoutQueue(t *testing.T) {
```

**Line:** 1468 | **Kind:** fn

### `TestNormalizeAuthNil`

```
func TestNormalizeAuthNil(t *testing.T) {
```

**Line:** 1478 | **Kind:** fn

### `List`

```
func (s *stubStore) List(context.Context) ([]*coreauth.Auth, error) { return nil, nil }
```

**Line:** 1493 | **Kind:** fn

### `Save`

```
func (s *stubStore) Save(context.Context, *coreauth.Auth) (string, error) {
```

**Line:** 1494 | **Kind:** fn

### `Delete`

```
func (s *stubStore) Delete(context.Context, string) error { return nil }
```

**Line:** 1497 | **Kind:** fn

### `PersistConfig`

```
func (s *stubStore) PersistConfig(context.Context) error {
```

**Line:** 1498 | **Kind:** fn

### `PersistAuthFiles`

```
func (s *stubStore) PersistAuthFiles(_ context.Context, message string, paths ...string) error {
```

**Line:** 1502 | **Kind:** fn

### `AuthDir`

```
func (s *stubStore) AuthDir() string { return s.authDir }
```

**Line:** 1508 | **Kind:** fn

### `TestNewWatcherDetectsPersisterAndAuthDir`

```
func TestNewWatcherDetectsPersisterAndAuthDir(t *testing.T) {
```

**Line:** 1510 | **Kind:** fn

### `TestPersistConfigAndAuthAsyncInvokePersister`

```
func TestPersistConfigAndAuthAsyncInvokePersister(t *testing.T) {
```

**Line:** 1529 | **Kind:** fn

### `TestScheduleConfigReloadDebounces`

```
func TestScheduleConfigReloadDebounces(t *testing.T) {
```

**Line:** 1553 | **Kind:** fn

### `TestPrepareAuthUpdatesLockedForceAndDelete`

```
func TestPrepareAuthUpdatesLockedForceAndDelete(t *testing.T) {
```

**Line:** 1582 | **Kind:** fn

### `TestAuthEqualIgnoresTemporalFields`

```
func TestAuthEqualIgnoresTemporalFields(t *testing.T) {
```

**Line:** 1606 | **Kind:** fn

### `TestDispatchLoopExitsWhenQueueNilAndContextCanceled`

```
func TestDispatchLoopExitsWhenQueueNilAndContextCanceled(t *testing.T) {
```

**Line:** 1615 | **Kind:** fn

### `TestReloadClientsFiltersOAuthProvidersWithoutRescan`

```
func TestReloadClientsFiltersOAuthProvidersWithoutRescan(t *testing.T) {
```

**Line:** 1643 | **Kind:** fn

### `TestScheduleProcessEventsStopsOnContextDone`

```
func TestScheduleProcessEventsStopsOnContextDone(t *testing.T) {
```

**Line:** 1667 | **Kind:** fn

