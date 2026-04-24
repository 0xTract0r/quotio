# third_party/CLIProxyAPIPlus/internal/registry/model_registry.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-registry/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1336
- **Language:** Go
- **Symbols:** 39
- **Public symbols:** 23

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 19 | struct | ModelInfo | pub | - |
| 67 | struct | availableModelsCacheEntry | (private) | - |
| 74 | struct | ThinkingSupport | pub | - |
| 89 | struct | ModelRegistration | pub | - |
| 108 | interface | ModelRegistryHook | pub | - |
| 114 | struct | ModelRegistry | pub | - |
| 137 | fn | GetGlobalRegistry | pub | `func GetGlobalRegistry() *ModelRegistry {` |
| 150 | fn | ensureAvailableModelsCacheLocked | (private) | `func (r *ModelRegistry) ensureAvailableModelsCa...` |
| 156 | fn | invalidateAvailableModelsCacheLocked | (private) | `func (r *ModelRegistry) invalidateAvailableMode...` |
| 164 | fn | LookupModelInfo | pub | `func LookupModelInfo(modelID string, provider ....` |
| 182 | fn | SetHook | pub | `func (r *ModelRegistry) SetHook(hook ModelRegis...` |
| 191 | const | defaultModelRegistryHookTimeout | (private) | - |
| 192 | const | modelQuotaExceededWindow | (private) | - |
| 194 | fn | triggerModelsRegistered | (private) | `func (r *ModelRegistry) triggerModelsRegistered...` |
| 212 | fn | triggerModelsUnregistered | (private) | `func (r *ModelRegistry) triggerModelsUnregister...` |
| 234 | fn | RegisterClient | pub | `func (r *ModelRegistry) RegisterClient(clientID...` |
| 449 | fn | addModelRegistration | (private) | `func (r *ModelRegistry) addModelRegistration(mo...` |
| 490 | fn | removeModelRegistration | (private) | `func (r *ModelRegistry) removeModelRegistration...` |
| 525 | fn | cloneModelInfo | (private) | `func cloneModelInfo(model *ModelInfo) *ModelInfo {` |
| 552 | fn | cloneModelInfosUnique | (private) | `func cloneModelInfosUnique(models []*ModelInfo)...` |
| 574 | fn | UnregisterClient | pub | `func (r *ModelRegistry) UnregisterClient(client...` |
| 582 | fn | unregisterClientInternal | (private) | `func (r *ModelRegistry) unregisterClientInterna...` |
| 642 | fn | SetModelQuotaExceeded | pub | `func (r *ModelRegistry) SetModelQuotaExceeded(c...` |
| 659 | fn | ClearModelQuotaExceeded | pub | `func (r *ModelRegistry) ClearModelQuotaExceeded...` |
| 676 | fn | SuspendClientModel | pub | `func (r *ModelRegistry) SuspendClientModel(clie...` |
| 708 | fn | ResumeClientModel | pub | `func (r *ModelRegistry) ResumeClientModel(clien...` |
| 730 | fn | ClientSupportsModel | pub | `func (r *ModelRegistry) ClientSupportsModel(cli...` |
| 760 | fn | GetAvailableModels | pub | `func (r *ModelRegistry) GetAvailableModels(hand...` |
| 788 | fn | buildAvailableModelsLocked | (private) | `func (r *ModelRegistry) buildAvailableModelsLoc...` |
| 837 | fn | cloneModelMaps | (private) | `func cloneModelMaps(models []map[string]any) []...` |
| 853 | fn | cloneModelMapValue | (private) | `func cloneModelMapValue(value any) any {` |
| 880 | fn | GetAvailableModelsByProvider | pub | `func (r *ModelRegistry) GetAvailableModelsByPro...` |
| 1004 | fn | GetModelCount | pub | `func (r *ModelRegistry) GetModelCount(modelID s...` |
| 1037 | fn | GetModelProviders | pub | `func (r *ModelRegistry) GetModelProviders(model...` |
| 1089 | fn | GetModelInfo | pub | `func (r *ModelRegistry) GetModelInfo(modelID, p...` |
| 1110 | fn | convertModelToMap | (private) | `func (r *ModelRegistry) convertModelToMap(model...` |
| 1235 | fn | CleanupExpiredQuotas | pub | `func (r *ModelRegistry) CleanupExpiredQuotas() {` |
| 1266 | fn | GetFirstAvailableModel | pub | `func (r *ModelRegistry) GetFirstAvailableModel(...` |
| 1303 | fn | GetModelsForClient | pub | `func (r *ModelRegistry) GetModelsForClient(clie...` |

## Public API

### `GetGlobalRegistry`

```
func GetGlobalRegistry() *ModelRegistry {
```

**Line:** 137 | **Kind:** fn

### `LookupModelInfo`

```
func LookupModelInfo(modelID string, provider ...string) *ModelInfo {
```

**Line:** 164 | **Kind:** fn

### `SetHook`

```
func (r *ModelRegistry) SetHook(hook ModelRegistryHook) {
```

**Line:** 182 | **Kind:** fn

### `RegisterClient`

```
func (r *ModelRegistry) RegisterClient(clientID, clientProvider string, models []*ModelInfo) {
```

**Line:** 234 | **Kind:** fn

### `UnregisterClient`

```
func (r *ModelRegistry) UnregisterClient(clientID string) {
```

**Line:** 574 | **Kind:** fn

### `SetModelQuotaExceeded`

```
func (r *ModelRegistry) SetModelQuotaExceeded(clientID, modelID string) {
```

**Line:** 642 | **Kind:** fn

### `ClearModelQuotaExceeded`

```
func (r *ModelRegistry) ClearModelQuotaExceeded(clientID, modelID string) {
```

**Line:** 659 | **Kind:** fn

### `SuspendClientModel`

```
func (r *ModelRegistry) SuspendClientModel(clientID, modelID, reason string) {
```

**Line:** 676 | **Kind:** fn

### `ResumeClientModel`

```
func (r *ModelRegistry) ResumeClientModel(clientID, modelID string) {
```

**Line:** 708 | **Kind:** fn

### `ClientSupportsModel`

```
func (r *ModelRegistry) ClientSupportsModel(clientID, modelID string) bool {
```

**Line:** 730 | **Kind:** fn

### `GetAvailableModels`

```
func (r *ModelRegistry) GetAvailableModels(handlerType string) []map[string]any {
```

**Line:** 760 | **Kind:** fn

### `GetAvailableModelsByProvider`

```
func (r *ModelRegistry) GetAvailableModelsByProvider(provider string) []*ModelInfo {
```

**Line:** 880 | **Kind:** fn

### `GetModelCount`

```
func (r *ModelRegistry) GetModelCount(modelID string) int {
```

**Line:** 1004 | **Kind:** fn

### `GetModelProviders`

```
func (r *ModelRegistry) GetModelProviders(modelID string) []string {
```

**Line:** 1037 | **Kind:** fn

### `GetModelInfo`

```
func (r *ModelRegistry) GetModelInfo(modelID, provider string) *ModelInfo {
```

**Line:** 1089 | **Kind:** fn

### `CleanupExpiredQuotas`

```
func (r *ModelRegistry) CleanupExpiredQuotas() {
```

**Line:** 1235 | **Kind:** fn

### `GetFirstAvailableModel`

```
func (r *ModelRegistry) GetFirstAvailableModel(handlerType string) (string, error) {
```

**Line:** 1266 | **Kind:** fn

### `GetModelsForClient`

```
func (r *ModelRegistry) GetModelsForClient(clientID string) []*ModelInfo {
```

**Line:** 1303 | **Kind:** fn

