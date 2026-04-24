# third_party/CLIProxyAPIPlus/internal/usage/pricing.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1043
- **Language:** Go
- **Symbols:** 54
- **Public symbols:** 20

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 31 | const | pricingCatalogFileVersion | (private) | - |
| 61 | struct | modelPrice | (private) | - |
| 68 | struct | pricingTotals | (private) | - |
| 78 | struct | PricingModel | pub | - |
| 91 | struct | PricingSourceInfo | pub | - |
| 101 | struct | PricingOfficialSnapshot | pub | - |
| 107 | struct | DetectedPricingModel | pub | - |
| 120 | struct | PricingSnapshot | pub | - |
| 127 | struct | pricingCatalogFile | (private) | - |
| 136 | struct | pricingFetcher | (private) | - |
| 143 | struct | PricingCatalogManager | pub | - |
| 158 | struct | modelObservation | (private) | - |
| 165 | fn | NewPricingCatalogManager | pub | `func NewPricingCatalogManager() *PricingCatalog...` |
| 192 | fn | GetDefaultPricingCatalog | pub | `func GetDefaultPricingCatalog() *PricingCatalog...` |
| 197 | fn | NormalizeCanonicalModelID | pub | `func NormalizeCanonicalModelID(model string) st...` |
| 201 | fn | ConfigureDefaultPricingCatalogPersistence | pub | `func ConfigureDefaultPricingCatalogPersistence(...` |
| 210 | fn | SetHTTPClient | pub | `func (m *PricingCatalogManager) SetHTTPClient(c...` |
| 219 | fn | SetFetchers | pub | `func (m *PricingCatalogManager) SetFetchers(fet...` |
| 229 | fn | SetPersistencePath | pub | `func (m *PricingCatalogManager) SetPersistenceP...` |
| 254 | fn | SaveToPersistence | pub | `func (m *PricingCatalogManager) SaveToPersisten...` |
| 295 | fn | LoadFromPersistence | pub | `func (m *PricingCatalogManager) LoadFromPersist...` |
| 332 | fn | persistencePath | (private) | `func (m *PricingCatalogManager) persistencePath...` |
| 341 | fn | PutOverride | pub | `func (m *PricingCatalogManager) PutOverride(mod...` |
| 370 | fn | DeleteOverride | pub | `func (m *PricingCatalogManager) DeleteOverride(...` |
| 392 | fn | RefreshOfficial | pub | `func (m *PricingCatalogManager) RefreshOfficial...` |
| 468 | fn | Snapshot | pub | `func (m *PricingCatalogManager) Snapshot(observ...` |
| 519 | fn | ComputeDetailPricing | pub | `func (m *PricingCatalogManager) ComputeDetailPr...` |
| 578 | fn | effectiveModelsLocked | (private) | `func (m *PricingCatalogManager) effectiveModels...` |
| 589 | fn | lookupEffectiveModelLocked | (private) | `func (m *PricingCatalogManager) lookupEffective...` |
| 605 | fn | ensureSourceMetadataLocked | (private) | `func (m *PricingCatalogManager) ensureSourceMet...` |
| 615 | fn | rebuildAliasIndexLocked | (private) | `func (m *PricingCatalogManager) rebuildAliasInd...` |
| 647 | fn | builtinPricingModels | (private) | `func builtinPricingModels() map[string]PricingM...` |
| 661 | fn | builtinUnfinalizedModels | (private) | `func builtinUnfinalizedModels() []string {` |
| 665 | fn | builtinUnpricedModelState | (private) | `func builtinUnpricedModelState(model string) pr...` |
| 674 | fn | pricingModelFromValues | (private) | `func pricingModelFromValues(model, display stri...` |
| 688 | fn | fetchOpenAIPricing | (private) | `func fetchOpenAIPricing(ctx context.Context, cl...` |
| 696 | fn | fetchAnthropicPricing | (private) | `func fetchAnthropicPricing(ctx context.Context,...` |
| 704 | fn | fetchPricingBody | (private) | `func fetchPricingBody(ctx context.Context, clie...` |
| 727 | fn | parseOpenAIPricingHTML | (private) | `func parseOpenAIPricingHTML(body string) (map[s...` |
| 763 | fn | parseAnthropicPricingHTML | (private) | `func parseAnthropicPricingHTML(body string) (ma...` |
| 802 | fn | parsePriceFloat | (private) | `func parsePriceFloat(raw string) (float64, erro...` |
| 810 | fn | cleanupOpenAIModelLabel | (private) | `func cleanupOpenAIModelLabel(label string) stri...` |
| 816 | fn | normalizeCanonicalModelID | (private) | `func normalizeCanonicalModelID(model string) st...` |
| 920 | fn | normalizeAliasKey | (private) | `func normalizeAliasKey(model string) string {` |
| 929 | fn | aliasesForModel | (private) | `func aliasesForModel(canonical string, model Pr...` |
| 960 | fn | normalizePricingModel | (private) | `func normalizePricingModel(entry PricingModel, ...` |
| 972 | fn | canonicalizePricingModelMap | (private) | `func canonicalizePricingModelMap(input map[stri...` |
| 990 | fn | clonePricingModelMap | (private) | `func clonePricingModelMap(input map[string]Pric...` |
| 998 | fn | clonePricingSourceMap | (private) | `func clonePricingSourceMap(input map[string]Pri...` |
| 1006 | fn | sortedPricingSourcesLocked | (private) | `func sortedPricingSourcesLocked(input map[strin...` |
| 1017 | fn | usdPerMTokToMicros | (private) | `func usdPerMTokToMicros(value float64) int64 {` |
| 1024 | fn | tokensToMicros | (private) | `func tokensToMicros(tokens, rateMicrosPerMillio...` |
| 1031 | fn | microsToUSD | (private) | `func microsToUSD(micros int64) float64 {` |
| 1038 | fn | maxInt64 | (private) | `func maxInt64(a, b int64) int64 {` |

## Public API

### `NewPricingCatalogManager`

```
func NewPricingCatalogManager() *PricingCatalogManager {
```

**Line:** 165 | **Kind:** fn

### `GetDefaultPricingCatalog`

```
func GetDefaultPricingCatalog() *PricingCatalogManager {
```

**Line:** 192 | **Kind:** fn

### `NormalizeCanonicalModelID`

```
func NormalizeCanonicalModelID(model string) string {
```

**Line:** 197 | **Kind:** fn

### `ConfigureDefaultPricingCatalogPersistence`

```
func ConfigureDefaultPricingCatalogPersistence(path string) error {
```

**Line:** 201 | **Kind:** fn

### `SetHTTPClient`

```
func (m *PricingCatalogManager) SetHTTPClient(client *http.Client) {
```

**Line:** 210 | **Kind:** fn

### `SetFetchers`

```
func (m *PricingCatalogManager) SetFetchers(fetchers []pricingFetcher) {
```

**Line:** 219 | **Kind:** fn

### `SetPersistencePath`

```
func (m *PricingCatalogManager) SetPersistencePath(path string) error {
```

**Line:** 229 | **Kind:** fn

### `SaveToPersistence`

```
func (m *PricingCatalogManager) SaveToPersistence() error {
```

**Line:** 254 | **Kind:** fn

### `LoadFromPersistence`

```
func (m *PricingCatalogManager) LoadFromPersistence() error {
```

**Line:** 295 | **Kind:** fn

### `PutOverride`

```
func (m *PricingCatalogManager) PutOverride(model string, override PricingModel) (PricingModel, error) {
```

**Line:** 341 | **Kind:** fn

### `DeleteOverride`

```
func (m *PricingCatalogManager) DeleteOverride(model string) bool {
```

**Line:** 370 | **Kind:** fn

### `RefreshOfficial`

```
func (m *PricingCatalogManager) RefreshOfficial(ctx context.Context) error {
```

**Line:** 392 | **Kind:** fn

### `Snapshot`

```
func (m *PricingCatalogManager) Snapshot(observations []modelObservation) PricingSnapshot {
```

**Line:** 468 | **Kind:** fn

### `ComputeDetailPricing`

```
func (m *PricingCatalogManager) ComputeDetailPricing(model string, tokens TokenStats) pricingTotals {
```

**Line:** 519 | **Kind:** fn

