# third_party/CLIProxyAPIPlus/internal/config/config.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-config/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2056
- **Language:** Go
- **Symbols:** 94
- **Public symbols:** 59

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 31 | struct | Config | pub | - |
| 175 | struct | ClaudeHeaderDefaults | pub | - |
| 188 | struct | CodexHeaderDefaults | pub | - |
| 194 | struct | TLSConfig | pub | - |
| 204 | struct | PprofConfig | pub | - |
| 212 | struct | RemoteManagement | pub | - |
| 229 | struct | QuotaExceeded | pub | - |
| 243 | struct | RoutingConfig | pub | - |
| 269 | struct | OAuthModelAlias | pub | - |
| 278 | struct | AmpModelMapping | pub | - |
| 294 | struct | AmpCode | pub | - |
| 324 | struct | AmpUpstreamAPIKeyEntry | pub | - |
| 333 | struct | PayloadConfig | pub | - |
| 347 | struct | PayloadFilterRule | pub | - |
| 355 | struct | PayloadRule | pub | - |
| 364 | struct | PayloadModelRule | pub | - |
| 373 | struct | CloakConfig | pub | - |
| 396 | struct | ClaudeKey | pub | - |
| 432 | fn | GetAPIKey | pub | `func (k ClaudeKey) GetAPIKey() string { return ...` |
| 433 | fn | GetBaseURL | pub | `func (k ClaudeKey) GetBaseURL() string { return...` |
| 436 | struct | ClaudeModel | pub | - |
| 444 | fn | GetName | pub | `func (m ClaudeModel) GetName() string { return ...` |
| 445 | fn | GetAlias | pub | `func (m ClaudeModel) GetAlias() string { return...` |
| 449 | struct | CodexKey | pub | - |
| 480 | fn | GetAPIKey | pub | `func (k CodexKey) GetAPIKey() string { return k...` |
| 481 | fn | GetBaseURL | pub | `func (k CodexKey) GetBaseURL() string { return ...` |
| 484 | struct | CodexModel | pub | - |
| 492 | fn | GetName | pub | `func (m CodexModel) GetName() string { return m...` |
| 493 | fn | GetAlias | pub | `func (m CodexModel) GetAlias() string { return ...` |
| 497 | struct | GeminiKey | pub | - |
| 524 | fn | GetAPIKey | pub | `func (k GeminiKey) GetAPIKey() string { return ...` |
| 525 | fn | GetBaseURL | pub | `func (k GeminiKey) GetBaseURL() string { return...` |
| 528 | struct | GeminiModel | pub | - |
| 536 | fn | GetName | pub | `func (m GeminiModel) GetName() string { return ...` |
| 537 | fn | GetAlias | pub | `func (m GeminiModel) GetAlias() string { return...` |
| 540 | struct | KiroKey | pub | - |
| 556 | struct | KiroFingerprintConfig | pub | - |
| 572 | struct | OpenAICompatibility | pub | - |
| 597 | struct | OpenAICompatibilityAPIKey | pub | - |
| 607 | struct | OpenAICompatibilityModel | pub | - |
| 619 | fn | GetName | pub | `func (m OpenAICompatibilityModel) GetName() str...` |
| 620 | fn | GetAlias | pub | `func (m OpenAICompatibilityModel) GetAlias() st...` |
| 632 | fn | LoadConfig | pub | `func LoadConfig(configFile string) (*Config, er...` |
| 639 | fn | LoadConfigOptional | pub | `func LoadConfigOptional(configFile string, opti...` |
| 794 | fn | SanitizePayloadRules | pub | `func (cfg *Config) SanitizePayloadRules() {` |
| 802 | fn | sanitizePayloadRawRules | (private) | `func sanitizePayloadRawRules(rules []PayloadRul...` |
| 837 | fn | payloadRawString | (private) | `func payloadRawString(value any) ([]byte, bool) {` |
| 850 | fn | SanitizeCodexHeaderDefaults | pub | `func (cfg *Config) SanitizeCodexHeaderDefaults() {` |
| 860 | fn | SanitizeClaudeHeaderDefaults | pub | `func (cfg *Config) SanitizeClaudeHeaderDefaults...` |
| 873 | fn | SanitizeKiroKeys | pub | `func (cfg *Config) SanitizeKiroKeys() {` |
| 898 | fn | SanitizeOAuthModelAlias | pub | `func (cfg *Config) SanitizeOAuthModelAlias() {` |
| 969 | fn | SanitizeOpenAICompatibility | pub | `func (cfg *Config) SanitizeOpenAICompatibility() {` |
| 991 | fn | SanitizeCodexKeys | pub | `func (cfg *Config) SanitizeCodexKeys() {` |
| 1011 | fn | SanitizeClaudeKeys | pub | `func (cfg *Config) SanitizeClaudeKeys() {` |
| 1025 | fn | SanitizeGeminiKeys | pub | `func (cfg *Config) SanitizeGeminiKeys() {` |
| 1053 | fn | normalizeModelPrefix | (private) | `func normalizeModelPrefix(prefix string) string {` |
| 1066 | fn | looksLikeBcrypt | (private) | `func looksLikeBcrypt(s string) bool {` |
| 1071 | fn | NormalizeHeaders | pub | `func NormalizeHeaders(headers map[string]string...` |
| 1092 | fn | NormalizeExcludedModels | pub | `func NormalizeExcludedModels(models []string) [...` |
| 1117 | fn | NormalizeOAuthExcludedModels | pub | `func NormalizeOAuthExcludedModels(entries map[s...` |
| 1140 | fn | hashSecret | (private) | `func hashSecret(secret string) (string, error) {` |
| 1151 | fn | SaveConfigPreserveComments | pub | `func SaveConfigPreserveComments(configFile stri...` |
| 1222 | fn | SaveConfigPreserveCommentsUpdateNestedScalar | pub | `func SaveConfigPreserveCommentsUpdateNestedScal...` |
| 1273 | fn | NormalizeCommentIndentation | pub | `func NormalizeCommentIndentation(data []byte) [...` |
| 1295 | fn | getOrCreateMapValue | (private) | `func getOrCreateMapValue(mapNode *yaml.Node, ke...` |
| 1317 | fn | mergeMappingPreserve | (private) | `func mergeMappingPreserve(dst, src *yaml.Node, ...` |
| 1356 | fn | mergeNodePreserve | (private) | `func mergeNodePreserve(dst, src *yaml.Node, pat...` |
| 1423 | fn | findMapKeyIndex | (private) | `func findMapKeyIndex(mapNode *yaml.Node, key st...` |
| 1436 | fn | appendPath | (private) | `func appendPath(path []string, key string) []st...` |
| 1449 | fn | isKnownDefaultValue | (private) | `func isKnownDefaultValue(path []string, node *y...` |
| 1491 | fn | pruneKnownDefaultsInNewNode | (private) | `func pruneKnownDefaultsInNewNode(path []string,...` |
| 1530 | fn | isZeroValueNode | (private) | `func isZeroValueNode(node *yaml.Node) bool {` |
| 1573 | fn | deepCopyNode | (private) | `func deepCopyNode(n *yaml.Node) *yaml.Node {` |
| 1589 | fn | copyNodeShallow | (private) | `func copyNodeShallow(dst, src *yaml.Node) {` |
| 1607 | fn | reorderSequenceForMerge | (private) | `func reorderSequenceForMerge(dst, src *yaml.Nod...` |
| 1629 | fn | matchSequenceElement | (private) | `func matchSequenceElement(original []*yaml.Node...` |
| 1672 | fn | sequenceElementIdentity | (private) | `func sequenceElementIdentity(node *yaml.Node) s...` |
| 1696 | fn | mappingScalarValue | (private) | `func mappingScalarValue(node *yaml.Node, key st...` |
| 1714 | fn | nodesStructurallyEqual | (private) | `func nodesStructurallyEqual(a, b *yaml.Node) bo...` |
| 1754 | fn | removeMapKey | (private) | `func removeMapKey(mapNode *yaml.Node, key strin...` |
| 1766 | fn | pruneMappingToGeneratedKeys | (private) | `func pruneMappingToGeneratedKeys(dstRoot, srcRo...` |
| 1809 | fn | pruneMissingMapKeys | (private) | `func pruneMissingMapKeys(dstMap, srcMap *yaml.N...` |
| 1843 | fn | normalizeCollectionNodeStyles | (private) | `func normalizeCollectionNodeStyles(node *yaml.N...` |
| 1868 | struct | legacyConfigData | (private) | - |
| 1877 | struct | legacyOpenAICompatibility | (private) | - |
| 1883 | fn | migrateLegacyGeminiKeys | (private) | `func (cfg *Config) migrateLegacyGeminiKeys(lega...` |
| 1911 | fn | migrateLegacyOpenAICompatibilityKeys | (private) | `func (cfg *Config) migrateLegacyOpenAICompatibi...` |
| 1931 | fn | mergeLegacyOpenAICompatAPIKeys | (private) | `func mergeLegacyOpenAICompatAPIKeys(entry *Open...` |
| 1959 | fn | findOpenAICompatTarget | (private) | `func findOpenAICompatTarget(entries []OpenAICom...` |
| 1987 | fn | migrateLegacyAmpConfig | (private) | `func (cfg *Config) migrateLegacyAmpConfig(legac...` |
| 2015 | fn | removeLegacyOpenAICompatAPIKeys | (private) | `func removeLegacyOpenAICompatAPIKeys(root *yaml...` |
| 2034 | fn | removeLegacyAmpKeys | (private) | `func removeLegacyAmpKeys(root *yaml.Node) {` |
| 2044 | fn | removeLegacyGenerativeLanguageKeys | (private) | `func removeLegacyGenerativeLanguageKeys(root *y...` |
| 2051 | fn | removeLegacyAuthBlock | (private) | `func removeLegacyAuthBlock(root *yaml.Node) {` |

## Public API

### `GetAPIKey`

```
func (k ClaudeKey) GetAPIKey() string  { return k.APIKey }
```

**Line:** 432 | **Kind:** fn

### `GetBaseURL`

```
func (k ClaudeKey) GetBaseURL() string { return k.BaseURL }
```

**Line:** 433 | **Kind:** fn

### `GetName`

```
func (m ClaudeModel) GetName() string  { return m.Name }
```

**Line:** 444 | **Kind:** fn

### `GetAlias`

```
func (m ClaudeModel) GetAlias() string { return m.Alias }
```

**Line:** 445 | **Kind:** fn

### `GetAPIKey`

```
func (k CodexKey) GetAPIKey() string  { return k.APIKey }
```

**Line:** 480 | **Kind:** fn

### `GetBaseURL`

```
func (k CodexKey) GetBaseURL() string { return k.BaseURL }
```

**Line:** 481 | **Kind:** fn

### `GetName`

```
func (m CodexModel) GetName() string  { return m.Name }
```

**Line:** 492 | **Kind:** fn

### `GetAlias`

```
func (m CodexModel) GetAlias() string { return m.Alias }
```

**Line:** 493 | **Kind:** fn

### `GetAPIKey`

```
func (k GeminiKey) GetAPIKey() string  { return k.APIKey }
```

**Line:** 524 | **Kind:** fn

### `GetBaseURL`

```
func (k GeminiKey) GetBaseURL() string { return k.BaseURL }
```

**Line:** 525 | **Kind:** fn

### `GetName`

```
func (m GeminiModel) GetName() string  { return m.Name }
```

**Line:** 536 | **Kind:** fn

### `GetAlias`

```
func (m GeminiModel) GetAlias() string { return m.Alias }
```

**Line:** 537 | **Kind:** fn

### `GetName`

```
func (m OpenAICompatibilityModel) GetName() string  { return m.Name }
```

**Line:** 619 | **Kind:** fn

### `GetAlias`

```
func (m OpenAICompatibilityModel) GetAlias() string { return m.Alias }
```

**Line:** 620 | **Kind:** fn

### `LoadConfig`

```
func LoadConfig(configFile string) (*Config, error) {
```

**Line:** 632 | **Kind:** fn

### `LoadConfigOptional`

```
func LoadConfigOptional(configFile string, optional bool) (*Config, error) {
```

**Line:** 639 | **Kind:** fn

### `SanitizePayloadRules`

```
func (cfg *Config) SanitizePayloadRules() {
```

**Line:** 794 | **Kind:** fn

### `SanitizeCodexHeaderDefaults`

```
func (cfg *Config) SanitizeCodexHeaderDefaults() {
```

**Line:** 850 | **Kind:** fn

### `SanitizeClaudeHeaderDefaults`

```
func (cfg *Config) SanitizeClaudeHeaderDefaults() {
```

**Line:** 860 | **Kind:** fn

### `SanitizeKiroKeys`

```
func (cfg *Config) SanitizeKiroKeys() {
```

**Line:** 873 | **Kind:** fn

### `SanitizeOAuthModelAlias`

```
func (cfg *Config) SanitizeOAuthModelAlias() {
```

**Line:** 898 | **Kind:** fn

### `SanitizeOpenAICompatibility`

```
func (cfg *Config) SanitizeOpenAICompatibility() {
```

**Line:** 969 | **Kind:** fn

### `SanitizeCodexKeys`

```
func (cfg *Config) SanitizeCodexKeys() {
```

**Line:** 991 | **Kind:** fn

### `SanitizeClaudeKeys`

```
func (cfg *Config) SanitizeClaudeKeys() {
```

**Line:** 1011 | **Kind:** fn

### `SanitizeGeminiKeys`

```
func (cfg *Config) SanitizeGeminiKeys() {
```

**Line:** 1025 | **Kind:** fn

### `NormalizeHeaders`

```
func NormalizeHeaders(headers map[string]string) map[string]string {
```

**Line:** 1071 | **Kind:** fn

### `NormalizeExcludedModels`

```
func NormalizeExcludedModels(models []string) []string {
```

**Line:** 1092 | **Kind:** fn

### `NormalizeOAuthExcludedModels`

```
func NormalizeOAuthExcludedModels(entries map[string][]string) map[string][]string {
```

**Line:** 1117 | **Kind:** fn

### `SaveConfigPreserveComments`

```
func SaveConfigPreserveComments(configFile string, cfg *Config) error {
```

**Line:** 1151 | **Kind:** fn

### `SaveConfigPreserveCommentsUpdateNestedScalar`

```
func SaveConfigPreserveCommentsUpdateNestedScalar(configFile string, path []string, value string) error {
```

**Line:** 1222 | **Kind:** fn

### `NormalizeCommentIndentation`

```
func NormalizeCommentIndentation(data []byte) []byte {
```

**Line:** 1273 | **Kind:** fn

## Memory Markers

### 🟢 `NOTE` (line 155)

> This does not apply to existing per-credential model alias features under:

### 🔴 `DEPRECATED` (line 251)

> Use SessionAffinity instead for universal session support.

### 🟢 `NOTE` (line 681)

> Startup legacy key migration is intentionally disabled.

### 🟢 `NOTE` (line 774)

> Legacy migration persistence is intentionally disabled together with

