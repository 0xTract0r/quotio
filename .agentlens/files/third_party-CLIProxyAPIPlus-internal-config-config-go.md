# third_party/CLIProxyAPIPlus/internal/config/config.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-config/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1997
- **Language:** Go
- **Symbols:** 93
- **Public symbols:** 58

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 30 | struct | Config | pub | - |
| 161 | struct | ClaudeHeaderDefaults | pub | - |
| 171 | struct | CodexHeaderDefaults | pub | - |
| 177 | struct | TLSConfig | pub | - |
| 187 | struct | PprofConfig | pub | - |
| 195 | struct | RemoteManagement | pub | - |
| 211 | struct | QuotaExceeded | pub | - |
| 220 | struct | RoutingConfig | pub | - |
| 230 | struct | OAuthModelAlias | pub | - |
| 239 | struct | AmpModelMapping | pub | - |
| 255 | struct | AmpCode | pub | - |
| 285 | struct | AmpUpstreamAPIKeyEntry | pub | - |
| 294 | struct | PayloadConfig | pub | - |
| 308 | struct | PayloadFilterRule | pub | - |
| 316 | struct | PayloadRule | pub | - |
| 325 | struct | PayloadModelRule | pub | - |
| 334 | struct | CloakConfig | pub | - |
| 357 | struct | ClaudeKey | pub | - |
| 388 | fn | GetAPIKey | pub | `func (k ClaudeKey) GetAPIKey() string { return ...` |
| 389 | fn | GetBaseURL | pub | `func (k ClaudeKey) GetBaseURL() string { return...` |
| 392 | struct | ClaudeModel | pub | - |
| 400 | fn | GetName | pub | `func (m ClaudeModel) GetName() string { return ...` |
| 401 | fn | GetAlias | pub | `func (m ClaudeModel) GetAlias() string { return...` |
| 405 | struct | CodexKey | pub | - |
| 436 | fn | GetAPIKey | pub | `func (k CodexKey) GetAPIKey() string { return k...` |
| 437 | fn | GetBaseURL | pub | `func (k CodexKey) GetBaseURL() string { return ...` |
| 440 | struct | CodexModel | pub | - |
| 448 | fn | GetName | pub | `func (m CodexModel) GetName() string { return m...` |
| 449 | fn | GetAlias | pub | `func (m CodexModel) GetAlias() string { return ...` |
| 453 | struct | GeminiKey | pub | - |
| 480 | fn | GetAPIKey | pub | `func (k GeminiKey) GetAPIKey() string { return ...` |
| 481 | fn | GetBaseURL | pub | `func (k GeminiKey) GetBaseURL() string { return...` |
| 484 | struct | GeminiModel | pub | - |
| 492 | fn | GetName | pub | `func (m GeminiModel) GetName() string { return ...` |
| 493 | fn | GetAlias | pub | `func (m GeminiModel) GetAlias() string { return...` |
| 496 | struct | KiroKey | pub | - |
| 530 | struct | KiroFingerprintConfig | pub | - |
| 543 | struct | OpenAICompatibility | pub | - |
| 568 | struct | OpenAICompatibilityAPIKey | pub | - |
| 578 | struct | OpenAICompatibilityModel | pub | - |
| 586 | fn | GetName | pub | `func (m OpenAICompatibilityModel) GetName() str...` |
| 587 | fn | GetAlias | pub | `func (m OpenAICompatibilityModel) GetAlias() st...` |
| 599 | fn | LoadConfig | pub | `func LoadConfig(configFile string) (*Config, er...` |
| 606 | fn | LoadConfigOptional | pub | `func LoadConfigOptional(configFile string, opti...` |
| 758 | fn | SanitizePayloadRules | pub | `func (cfg *Config) SanitizePayloadRules() {` |
| 766 | fn | sanitizePayloadRawRules | (private) | `func sanitizePayloadRawRules(rules []PayloadRul...` |
| 801 | fn | payloadRawString | (private) | `func payloadRawString(value any) ([]byte, bool) {` |
| 814 | fn | SanitizeCodexHeaderDefaults | pub | `func (cfg *Config) SanitizeCodexHeaderDefaults() {` |
| 827 | fn | SanitizeOAuthModelAlias | pub | `func (cfg *Config) SanitizeOAuthModelAlias() {` |
| 895 | fn | SanitizeOpenAICompatibility | pub | `func (cfg *Config) SanitizeOpenAICompatibility() {` |
| 917 | fn | SanitizeCodexKeys | pub | `func (cfg *Config) SanitizeCodexKeys() {` |
| 937 | fn | SanitizeClaudeKeys | pub | `func (cfg *Config) SanitizeClaudeKeys() {` |
| 950 | fn | SanitizeKiroKeys | pub | `func (cfg *Config) SanitizeKiroKeys() {` |
| 967 | fn | SanitizeGeminiKeys | pub | `func (cfg *Config) SanitizeGeminiKeys() {` |
| 994 | fn | normalizeModelPrefix | (private) | `func normalizeModelPrefix(prefix string) string {` |
| 1007 | fn | looksLikeBcrypt | (private) | `func looksLikeBcrypt(s string) bool {` |
| 1012 | fn | NormalizeHeaders | pub | `func NormalizeHeaders(headers map[string]string...` |
| 1033 | fn | NormalizeExcludedModels | pub | `func NormalizeExcludedModels(models []string) [...` |
| 1058 | fn | NormalizeOAuthExcludedModels | pub | `func NormalizeOAuthExcludedModels(entries map[s...` |
| 1081 | fn | hashSecret | (private) | `func hashSecret(secret string) (string, error) {` |
| 1092 | fn | SaveConfigPreserveComments | pub | `func SaveConfigPreserveComments(configFile stri...` |
| 1163 | fn | SaveConfigPreserveCommentsUpdateNestedScalar | pub | `func SaveConfigPreserveCommentsUpdateNestedScal...` |
| 1214 | fn | NormalizeCommentIndentation | pub | `func NormalizeCommentIndentation(data []byte) [...` |
| 1236 | fn | getOrCreateMapValue | (private) | `func getOrCreateMapValue(mapNode *yaml.Node, ke...` |
| 1258 | fn | mergeMappingPreserve | (private) | `func mergeMappingPreserve(dst, src *yaml.Node, ...` |
| 1297 | fn | mergeNodePreserve | (private) | `func mergeNodePreserve(dst, src *yaml.Node, pat...` |
| 1364 | fn | findMapKeyIndex | (private) | `func findMapKeyIndex(mapNode *yaml.Node, key st...` |
| 1377 | fn | appendPath | (private) | `func appendPath(path []string, key string) []st...` |
| 1390 | fn | isKnownDefaultValue | (private) | `func isKnownDefaultValue(path []string, node *y...` |
| 1432 | fn | pruneKnownDefaultsInNewNode | (private) | `func pruneKnownDefaultsInNewNode(path []string,...` |
| 1471 | fn | isZeroValueNode | (private) | `func isZeroValueNode(node *yaml.Node) bool {` |
| 1514 | fn | deepCopyNode | (private) | `func deepCopyNode(n *yaml.Node) *yaml.Node {` |
| 1530 | fn | copyNodeShallow | (private) | `func copyNodeShallow(dst, src *yaml.Node) {` |
| 1548 | fn | reorderSequenceForMerge | (private) | `func reorderSequenceForMerge(dst, src *yaml.Nod...` |
| 1570 | fn | matchSequenceElement | (private) | `func matchSequenceElement(original []*yaml.Node...` |
| 1613 | fn | sequenceElementIdentity | (private) | `func sequenceElementIdentity(node *yaml.Node) s...` |
| 1637 | fn | mappingScalarValue | (private) | `func mappingScalarValue(node *yaml.Node, key st...` |
| 1655 | fn | nodesStructurallyEqual | (private) | `func nodesStructurallyEqual(a, b *yaml.Node) bo...` |
| 1695 | fn | removeMapKey | (private) | `func removeMapKey(mapNode *yaml.Node, key strin...` |
| 1707 | fn | pruneMappingToGeneratedKeys | (private) | `func pruneMappingToGeneratedKeys(dstRoot, srcRo...` |
| 1750 | fn | pruneMissingMapKeys | (private) | `func pruneMissingMapKeys(dstMap, srcMap *yaml.N...` |
| 1784 | fn | normalizeCollectionNodeStyles | (private) | `func normalizeCollectionNodeStyles(node *yaml.N...` |
| 1809 | struct | legacyConfigData | (private) | - |
| 1818 | struct | legacyOpenAICompatibility | (private) | - |
| 1824 | fn | migrateLegacyGeminiKeys | (private) | `func (cfg *Config) migrateLegacyGeminiKeys(lega...` |
| 1852 | fn | migrateLegacyOpenAICompatibilityKeys | (private) | `func (cfg *Config) migrateLegacyOpenAICompatibi...` |
| 1872 | fn | mergeLegacyOpenAICompatAPIKeys | (private) | `func mergeLegacyOpenAICompatAPIKeys(entry *Open...` |
| 1900 | fn | findOpenAICompatTarget | (private) | `func findOpenAICompatTarget(entries []OpenAICom...` |
| 1928 | fn | migrateLegacyAmpConfig | (private) | `func (cfg *Config) migrateLegacyAmpConfig(legac...` |
| 1956 | fn | removeLegacyOpenAICompatAPIKeys | (private) | `func removeLegacyOpenAICompatAPIKeys(root *yaml...` |
| 1975 | fn | removeLegacyAmpKeys | (private) | `func removeLegacyAmpKeys(root *yaml.Node) {` |
| 1985 | fn | removeLegacyGenerativeLanguageKeys | (private) | `func removeLegacyGenerativeLanguageKeys(root *y...` |
| 1992 | fn | removeLegacyAuthBlock | (private) | `func removeLegacyAuthBlock(root *yaml.Node) {` |

## Public API

### `GetAPIKey`

```
func (k ClaudeKey) GetAPIKey() string  { return k.APIKey }
```

**Line:** 388 | **Kind:** fn

### `GetBaseURL`

```
func (k ClaudeKey) GetBaseURL() string { return k.BaseURL }
```

**Line:** 389 | **Kind:** fn

### `GetName`

```
func (m ClaudeModel) GetName() string  { return m.Name }
```

**Line:** 400 | **Kind:** fn

### `GetAlias`

```
func (m ClaudeModel) GetAlias() string { return m.Alias }
```

**Line:** 401 | **Kind:** fn

### `GetAPIKey`

```
func (k CodexKey) GetAPIKey() string  { return k.APIKey }
```

**Line:** 436 | **Kind:** fn

### `GetBaseURL`

```
func (k CodexKey) GetBaseURL() string { return k.BaseURL }
```

**Line:** 437 | **Kind:** fn

### `GetName`

```
func (m CodexModel) GetName() string  { return m.Name }
```

**Line:** 448 | **Kind:** fn

### `GetAlias`

```
func (m CodexModel) GetAlias() string { return m.Alias }
```

**Line:** 449 | **Kind:** fn

### `GetAPIKey`

```
func (k GeminiKey) GetAPIKey() string  { return k.APIKey }
```

**Line:** 480 | **Kind:** fn

### `GetBaseURL`

```
func (k GeminiKey) GetBaseURL() string { return k.BaseURL }
```

**Line:** 481 | **Kind:** fn

### `GetName`

```
func (m GeminiModel) GetName() string  { return m.Name }
```

**Line:** 492 | **Kind:** fn

### `GetAlias`

```
func (m GeminiModel) GetAlias() string { return m.Alias }
```

**Line:** 493 | **Kind:** fn

### `GetName`

```
func (m OpenAICompatibilityModel) GetName() string  { return m.Name }
```

**Line:** 586 | **Kind:** fn

### `GetAlias`

```
func (m OpenAICompatibilityModel) GetAlias() string { return m.Alias }
```

**Line:** 587 | **Kind:** fn

### `LoadConfig`

```
func LoadConfig(configFile string) (*Config, error) {
```

**Line:** 599 | **Kind:** fn

### `LoadConfigOptional`

```
func LoadConfigOptional(configFile string, optional bool) (*Config, error) {
```

**Line:** 606 | **Kind:** fn

### `SanitizePayloadRules`

```
func (cfg *Config) SanitizePayloadRules() {
```

**Line:** 758 | **Kind:** fn

### `SanitizeCodexHeaderDefaults`

```
func (cfg *Config) SanitizeCodexHeaderDefaults() {
```

**Line:** 814 | **Kind:** fn

### `SanitizeOAuthModelAlias`

```
func (cfg *Config) SanitizeOAuthModelAlias() {
```

**Line:** 827 | **Kind:** fn

### `SanitizeOpenAICompatibility`

```
func (cfg *Config) SanitizeOpenAICompatibility() {
```

**Line:** 895 | **Kind:** fn

### `SanitizeCodexKeys`

```
func (cfg *Config) SanitizeCodexKeys() {
```

**Line:** 917 | **Kind:** fn

### `SanitizeClaudeKeys`

```
func (cfg *Config) SanitizeClaudeKeys() {
```

**Line:** 937 | **Kind:** fn

### `SanitizeKiroKeys`

```
func (cfg *Config) SanitizeKiroKeys() {
```

**Line:** 950 | **Kind:** fn

### `SanitizeGeminiKeys`

```
func (cfg *Config) SanitizeGeminiKeys() {
```

**Line:** 967 | **Kind:** fn

### `NormalizeHeaders`

```
func NormalizeHeaders(headers map[string]string) map[string]string {
```

**Line:** 1012 | **Kind:** fn

### `NormalizeExcludedModels`

```
func NormalizeExcludedModels(models []string) []string {
```

**Line:** 1033 | **Kind:** fn

### `NormalizeOAuthExcludedModels`

```
func NormalizeOAuthExcludedModels(entries map[string][]string) map[string][]string {
```

**Line:** 1058 | **Kind:** fn

### `SaveConfigPreserveComments`

```
func SaveConfigPreserveComments(configFile string, cfg *Config) error {
```

**Line:** 1092 | **Kind:** fn

### `SaveConfigPreserveCommentsUpdateNestedScalar`

```
func SaveConfigPreserveCommentsUpdateNestedScalar(configFile string, path []string, value string) error {
```

**Line:** 1163 | **Kind:** fn

### `NormalizeCommentIndentation`

```
func NormalizeCommentIndentation(data []byte) []byte {
```

**Line:** 1214 | **Kind:** fn

## Memory Markers

### 🟢 `NOTE` (line 144)

> This does not apply to existing per-credential model alias features under:

### 🟢 `NOTE` (line 648)

> Startup legacy key migration is intentionally disabled.

### 🟢 `NOTE` (line 738)

> Legacy migration persistence is intentionally disabled together with

