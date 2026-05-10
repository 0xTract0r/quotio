# third_party/CLIProxyAPIPlus/internal/config/config.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-config/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2120
- **Language:** Go
- **Symbols:** 99
- **Public symbols:** 64

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 31 | struct | Config | pub | - |
| 178 | struct | ClaudeHeaderDefaults | pub | - |
| 191 | struct | CodexHeaderDefaults | pub | - |
| 200 | struct | ManagedHeaderProfileConfig | pub | - |
| 207 | struct | TLSConfig | pub | - |
| 217 | struct | PprofConfig | pub | - |
| 225 | struct | RemoteManagement | pub | - |
| 242 | struct | QuotaExceeded | pub | - |
| 256 | struct | RoutingConfig | pub | - |
| 282 | struct | OAuthModelAlias | pub | - |
| 291 | struct | AmpModelMapping | pub | - |
| 307 | struct | AmpCode | pub | - |
| 337 | struct | AmpUpstreamAPIKeyEntry | pub | - |
| 346 | struct | PayloadConfig | pub | - |
| 360 | struct | PayloadFilterRule | pub | - |
| 368 | struct | PayloadRule | pub | - |
| 377 | struct | PayloadModelRule | pub | - |
| 386 | struct | CloakConfig | pub | - |
| 409 | struct | ClaudeKey | pub | - |
| 445 | fn | GetAPIKey | pub | `func (k ClaudeKey) GetAPIKey() string { return ...` |
| 446 | fn | GetBaseURL | pub | `func (k ClaudeKey) GetBaseURL() string { return...` |
| 449 | struct | ClaudeModel | pub | - |
| 457 | fn | GetName | pub | `func (m ClaudeModel) GetName() string { return ...` |
| 458 | fn | GetAlias | pub | `func (m ClaudeModel) GetAlias() string { return...` |
| 462 | struct | CodexKey | pub | - |
| 493 | fn | GetAPIKey | pub | `func (k CodexKey) GetAPIKey() string { return k...` |
| 494 | fn | GetBaseURL | pub | `func (k CodexKey) GetBaseURL() string { return ...` |
| 497 | struct | CodexModel | pub | - |
| 505 | fn | GetName | pub | `func (m CodexModel) GetName() string { return m...` |
| 506 | fn | GetAlias | pub | `func (m CodexModel) GetAlias() string { return ...` |
| 510 | struct | GeminiKey | pub | - |
| 537 | fn | GetAPIKey | pub | `func (k GeminiKey) GetAPIKey() string { return ...` |
| 538 | fn | GetBaseURL | pub | `func (k GeminiKey) GetBaseURL() string { return...` |
| 541 | struct | GeminiModel | pub | - |
| 549 | fn | GetName | pub | `func (m GeminiModel) GetName() string { return ...` |
| 550 | fn | GetAlias | pub | `func (m GeminiModel) GetAlias() string { return...` |
| 553 | struct | KiroKey | pub | - |
| 569 | struct | KiroFingerprintConfig | pub | - |
| 585 | struct | OpenAICompatibility | pub | - |
| 610 | struct | OpenAICompatibilityAPIKey | pub | - |
| 620 | struct | OpenAICompatibilityModel | pub | - |
| 632 | fn | GetName | pub | `func (m OpenAICompatibilityModel) GetName() str...` |
| 633 | fn | GetAlias | pub | `func (m OpenAICompatibilityModel) GetAlias() st...` |
| 645 | fn | LoadConfig | pub | `func LoadConfig(configFile string) (*Config, er...` |
| 652 | fn | LoadConfigOptional | pub | `func LoadConfigOptional(configFile string, opti...` |
| 814 | fn | SanitizePayloadRules | pub | `func (cfg *Config) SanitizePayloadRules() {` |
| 822 | fn | sanitizePayloadRawRules | (private) | `func sanitizePayloadRawRules(rules []PayloadRul...` |
| 857 | fn | payloadRawString | (private) | `func payloadRawString(value any) ([]byte, bool) {` |
| 870 | fn | SanitizeCodexHeaderDefaults | pub | `func (cfg *Config) SanitizeCodexHeaderDefaults() {` |
| 880 | fn | SanitizeClaudeHeaderDefaults | pub | `func (cfg *Config) SanitizeClaudeHeaderDefaults...` |
| 892 | fn | SanitizeManagedHeaderProfile | pub | `func (cfg *Config) SanitizeManagedHeaderProfile...` |
| 910 | fn | ManagedHeaderOnlineUpdateEnabled | pub | `func ManagedHeaderOnlineUpdateEnabled(cfg *Conf...` |
| 916 | fn | ManagedHeaderProfileFetchTimeout | pub | `func ManagedHeaderProfileFetchTimeout(cfg *Conf...` |
| 926 | fn | ManagedHeaderProfileCacheTTL | pub | `func ManagedHeaderProfileCacheTTL(cfg *Config) ...` |
| 937 | fn | SanitizeKiroKeys | pub | `func (cfg *Config) SanitizeKiroKeys() {` |
| 962 | fn | SanitizeOAuthModelAlias | pub | `func (cfg *Config) SanitizeOAuthModelAlias() {` |
| 1033 | fn | SanitizeOpenAICompatibility | pub | `func (cfg *Config) SanitizeOpenAICompatibility() {` |
| 1055 | fn | SanitizeCodexKeys | pub | `func (cfg *Config) SanitizeCodexKeys() {` |
| 1075 | fn | SanitizeClaudeKeys | pub | `func (cfg *Config) SanitizeClaudeKeys() {` |
| 1089 | fn | SanitizeGeminiKeys | pub | `func (cfg *Config) SanitizeGeminiKeys() {` |
| 1117 | fn | normalizeModelPrefix | (private) | `func normalizeModelPrefix(prefix string) string {` |
| 1130 | fn | looksLikeBcrypt | (private) | `func looksLikeBcrypt(s string) bool {` |
| 1135 | fn | NormalizeHeaders | pub | `func NormalizeHeaders(headers map[string]string...` |
| 1156 | fn | NormalizeExcludedModels | pub | `func NormalizeExcludedModels(models []string) [...` |
| 1181 | fn | NormalizeOAuthExcludedModels | pub | `func NormalizeOAuthExcludedModels(entries map[s...` |
| 1204 | fn | hashSecret | (private) | `func hashSecret(secret string) (string, error) {` |
| 1215 | fn | SaveConfigPreserveComments | pub | `func SaveConfigPreserveComments(configFile stri...` |
| 1286 | fn | SaveConfigPreserveCommentsUpdateNestedScalar | pub | `func SaveConfigPreserveCommentsUpdateNestedScal...` |
| 1337 | fn | NormalizeCommentIndentation | pub | `func NormalizeCommentIndentation(data []byte) [...` |
| 1359 | fn | getOrCreateMapValue | (private) | `func getOrCreateMapValue(mapNode *yaml.Node, ke...` |
| 1381 | fn | mergeMappingPreserve | (private) | `func mergeMappingPreserve(dst, src *yaml.Node, ...` |
| 1420 | fn | mergeNodePreserve | (private) | `func mergeNodePreserve(dst, src *yaml.Node, pat...` |
| 1487 | fn | findMapKeyIndex | (private) | `func findMapKeyIndex(mapNode *yaml.Node, key st...` |
| 1500 | fn | appendPath | (private) | `func appendPath(path []string, key string) []st...` |
| 1513 | fn | isKnownDefaultValue | (private) | `func isKnownDefaultValue(path []string, node *y...` |
| 1555 | fn | pruneKnownDefaultsInNewNode | (private) | `func pruneKnownDefaultsInNewNode(path []string,...` |
| 1594 | fn | isZeroValueNode | (private) | `func isZeroValueNode(node *yaml.Node) bool {` |
| 1637 | fn | deepCopyNode | (private) | `func deepCopyNode(n *yaml.Node) *yaml.Node {` |
| 1653 | fn | copyNodeShallow | (private) | `func copyNodeShallow(dst, src *yaml.Node) {` |
| 1671 | fn | reorderSequenceForMerge | (private) | `func reorderSequenceForMerge(dst, src *yaml.Nod...` |
| 1693 | fn | matchSequenceElement | (private) | `func matchSequenceElement(original []*yaml.Node...` |
| 1736 | fn | sequenceElementIdentity | (private) | `func sequenceElementIdentity(node *yaml.Node) s...` |
| 1760 | fn | mappingScalarValue | (private) | `func mappingScalarValue(node *yaml.Node, key st...` |
| 1778 | fn | nodesStructurallyEqual | (private) | `func nodesStructurallyEqual(a, b *yaml.Node) bo...` |
| 1818 | fn | removeMapKey | (private) | `func removeMapKey(mapNode *yaml.Node, key strin...` |
| 1830 | fn | pruneMappingToGeneratedKeys | (private) | `func pruneMappingToGeneratedKeys(dstRoot, srcRo...` |
| 1873 | fn | pruneMissingMapKeys | (private) | `func pruneMissingMapKeys(dstMap, srcMap *yaml.N...` |
| 1907 | fn | normalizeCollectionNodeStyles | (private) | `func normalizeCollectionNodeStyles(node *yaml.N...` |
| 1932 | struct | legacyConfigData | (private) | - |
| 1941 | struct | legacyOpenAICompatibility | (private) | - |
| 1947 | fn | migrateLegacyGeminiKeys | (private) | `func (cfg *Config) migrateLegacyGeminiKeys(lega...` |
| 1975 | fn | migrateLegacyOpenAICompatibilityKeys | (private) | `func (cfg *Config) migrateLegacyOpenAICompatibi...` |
| 1995 | fn | mergeLegacyOpenAICompatAPIKeys | (private) | `func mergeLegacyOpenAICompatAPIKeys(entry *Open...` |
| 2023 | fn | findOpenAICompatTarget | (private) | `func findOpenAICompatTarget(entries []OpenAICom...` |
| 2051 | fn | migrateLegacyAmpConfig | (private) | `func (cfg *Config) migrateLegacyAmpConfig(legac...` |
| 2079 | fn | removeLegacyOpenAICompatAPIKeys | (private) | `func removeLegacyOpenAICompatAPIKeys(root *yaml...` |
| 2098 | fn | removeLegacyAmpKeys | (private) | `func removeLegacyAmpKeys(root *yaml.Node) {` |
| 2108 | fn | removeLegacyGenerativeLanguageKeys | (private) | `func removeLegacyGenerativeLanguageKeys(root *y...` |
| 2115 | fn | removeLegacyAuthBlock | (private) | `func removeLegacyAuthBlock(root *yaml.Node) {` |

## Public API

### `GetAPIKey`

```
func (k ClaudeKey) GetAPIKey() string  { return k.APIKey }
```

**Line:** 445 | **Kind:** fn

### `GetBaseURL`

```
func (k ClaudeKey) GetBaseURL() string { return k.BaseURL }
```

**Line:** 446 | **Kind:** fn

### `GetName`

```
func (m ClaudeModel) GetName() string  { return m.Name }
```

**Line:** 457 | **Kind:** fn

### `GetAlias`

```
func (m ClaudeModel) GetAlias() string { return m.Alias }
```

**Line:** 458 | **Kind:** fn

### `GetAPIKey`

```
func (k CodexKey) GetAPIKey() string  { return k.APIKey }
```

**Line:** 493 | **Kind:** fn

### `GetBaseURL`

```
func (k CodexKey) GetBaseURL() string { return k.BaseURL }
```

**Line:** 494 | **Kind:** fn

### `GetName`

```
func (m CodexModel) GetName() string  { return m.Name }
```

**Line:** 505 | **Kind:** fn

### `GetAlias`

```
func (m CodexModel) GetAlias() string { return m.Alias }
```

**Line:** 506 | **Kind:** fn

### `GetAPIKey`

```
func (k GeminiKey) GetAPIKey() string  { return k.APIKey }
```

**Line:** 537 | **Kind:** fn

### `GetBaseURL`

```
func (k GeminiKey) GetBaseURL() string { return k.BaseURL }
```

**Line:** 538 | **Kind:** fn

### `GetName`

```
func (m GeminiModel) GetName() string  { return m.Name }
```

**Line:** 549 | **Kind:** fn

### `GetAlias`

```
func (m GeminiModel) GetAlias() string { return m.Alias }
```

**Line:** 550 | **Kind:** fn

### `GetName`

```
func (m OpenAICompatibilityModel) GetName() string  { return m.Name }
```

**Line:** 632 | **Kind:** fn

### `GetAlias`

```
func (m OpenAICompatibilityModel) GetAlias() string { return m.Alias }
```

**Line:** 633 | **Kind:** fn

### `LoadConfig`

```
func LoadConfig(configFile string) (*Config, error) {
```

**Line:** 645 | **Kind:** fn

### `LoadConfigOptional`

```
func LoadConfigOptional(configFile string, optional bool) (*Config, error) {
```

**Line:** 652 | **Kind:** fn

### `SanitizePayloadRules`

```
func (cfg *Config) SanitizePayloadRules() {
```

**Line:** 814 | **Kind:** fn

### `SanitizeCodexHeaderDefaults`

```
func (cfg *Config) SanitizeCodexHeaderDefaults() {
```

**Line:** 870 | **Kind:** fn

### `SanitizeClaudeHeaderDefaults`

```
func (cfg *Config) SanitizeClaudeHeaderDefaults() {
```

**Line:** 880 | **Kind:** fn

### `SanitizeManagedHeaderProfile`

```
func (cfg *Config) SanitizeManagedHeaderProfile() {
```

**Line:** 892 | **Kind:** fn

### `ManagedHeaderOnlineUpdateEnabled`

```
func ManagedHeaderOnlineUpdateEnabled(cfg *Config) bool {
```

**Line:** 910 | **Kind:** fn

### `ManagedHeaderProfileFetchTimeout`

```
func ManagedHeaderProfileFetchTimeout(cfg *Config) int {
```

**Line:** 916 | **Kind:** fn

### `ManagedHeaderProfileCacheTTL`

```
func ManagedHeaderProfileCacheTTL(cfg *Config) int {
```

**Line:** 926 | **Kind:** fn

### `SanitizeKiroKeys`

```
func (cfg *Config) SanitizeKiroKeys() {
```

**Line:** 937 | **Kind:** fn

### `SanitizeOAuthModelAlias`

```
func (cfg *Config) SanitizeOAuthModelAlias() {
```

**Line:** 962 | **Kind:** fn

### `SanitizeOpenAICompatibility`

```
func (cfg *Config) SanitizeOpenAICompatibility() {
```

**Line:** 1033 | **Kind:** fn

### `SanitizeCodexKeys`

```
func (cfg *Config) SanitizeCodexKeys() {
```

**Line:** 1055 | **Kind:** fn

### `SanitizeClaudeKeys`

```
func (cfg *Config) SanitizeClaudeKeys() {
```

**Line:** 1075 | **Kind:** fn

### `SanitizeGeminiKeys`

```
func (cfg *Config) SanitizeGeminiKeys() {
```

**Line:** 1089 | **Kind:** fn

### `NormalizeHeaders`

```
func NormalizeHeaders(headers map[string]string) map[string]string {
```

**Line:** 1135 | **Kind:** fn

### `NormalizeExcludedModels`

```
func NormalizeExcludedModels(models []string) []string {
```

**Line:** 1156 | **Kind:** fn

### `NormalizeOAuthExcludedModels`

```
func NormalizeOAuthExcludedModels(entries map[string][]string) map[string][]string {
```

**Line:** 1181 | **Kind:** fn

### `SaveConfigPreserveComments`

```
func SaveConfigPreserveComments(configFile string, cfg *Config) error {
```

**Line:** 1215 | **Kind:** fn

### `SaveConfigPreserveCommentsUpdateNestedScalar`

```
func SaveConfigPreserveCommentsUpdateNestedScalar(configFile string, path []string, value string) error {
```

**Line:** 1286 | **Kind:** fn

### `NormalizeCommentIndentation`

```
func NormalizeCommentIndentation(data []byte) []byte {
```

**Line:** 1337 | **Kind:** fn

## Memory Markers

### 🟢 `NOTE` (line 158)

> This does not apply to existing per-credential model alias features under:

### 🔴 `DEPRECATED` (line 264)

> Use SessionAffinity instead for universal session support.

### 🟢 `NOTE` (line 698)

> Startup legacy key migration is intentionally disabled.

### 🟢 `NOTE` (line 794)

> Legacy migration persistence is intentionally disabled together with

