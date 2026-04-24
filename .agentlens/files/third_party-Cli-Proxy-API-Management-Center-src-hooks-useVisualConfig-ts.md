# third_party/Cli-Proxy-API-Management-Center/src/hooks/useVisualConfig.ts

[← Back to Module](../modules/third_party-Cli-Proxy-API-Management-Center-src-hooks/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1121
- **Language:** TypeScript
- **Symbols:** 40
- **Public symbols:** 3

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 14 | fn | asRecord | (private) | `function asRecord(value: unknown): Record<strin...` |
| 19 | fn | extractApiKeyValue | (private) | `function extractApiKeyValue(raw: unknown): stri...` |
| 39 | fn | parseApiKeysText | (private) | `function parseApiKeysText(raw: unknown): string {` |
| 50 | fn | resolveApiKeysText | (private) | `function resolveApiKeysText(parsed: Record<stri...` |
| 67 | type | YamlDocument | (private) | - |
| 68 | type | YamlPath | (private) | - |
| 70 | fn | docHas | (private) | `function docHas(doc: YamlDocument, path: YamlPa...` |
| 74 | fn | ensureMapInDoc | (private) | `function ensureMapInDoc(doc: YamlDocument, path...` |
| 81 | fn | deleteIfMapEmpty | (private) | `function deleteIfMapEmpty(doc: YamlDocument, pa...` |
| 87 | fn | setBooleanInDoc | (private) | `function setBooleanInDoc(doc: YamlDocument, pat...` |
| 95 | fn | setStringInDoc | (private) | `function setStringInDoc(doc: YamlDocument, path...` |
| 109 | fn | setIntFromStringInDoc | (private) | `function setIntFromStringInDoc(doc: YamlDocumen...` |
| 128 | fn | getNonNegativeIntegerError | (private) | `function getNonNegativeIntegerError(value: stri...` |
| 135 | fn | getPortError | (private) | `function getPortError(value: string): 'port_ran...` |
| 143 | fn | getVisualConfigValidationErrors | pub | `export function getVisualConfigValidationErrors(` |
| 160 | fn | getPayloadParamValidationError | pub | `export function getPayloadParamValidationError(` |
| 191 | fn | hasPayloadParamValidationErrors | (private) | `function hasPayloadParamValidationErrors(rules:...` |
| 197 | fn | deepClone | (private) | `function deepClone<T>(value: T): T {` |
| 202 | fn | arePayloadModelEntriesEqual | (private) | `function arePayloadModelEntriesEqual(` |
| 217 | fn | arePayloadParamEntriesEqual | (private) | `function arePayloadParamEntriesEqual(` |
| 234 | fn | arePayloadRulesEqual | (private) | `function arePayloadRulesEqual(left: PayloadRule...` |
| 248 | fn | arePayloadFilterRulesEqual | (private) | `function arePayloadFilterRulesEqual(` |
| 268 | fn | parsePayloadParamValue | (private) | `function parsePayloadParamValue(raw: unknown): ...` |
| 289 | fn | parseRawPayloadParamValue | (private) | `function parseRawPayloadParamValue(raw: unknown...` |
| 300 | fn | parsePayloadProtocol | (private) | `function parsePayloadProtocol(raw: unknown): st...` |
| 305 | fn | deleteLegacyApiKeysProvider | (private) | `function deleteLegacyApiKeysProvider(doc: YamlD...` |
| 317 | fn | parsePayloadRules | (private) | `function parsePayloadRules(rules: unknown): Pay...` |
| 355 | fn | parsePayloadFilterRules | (private) | `function parsePayloadFilterRules(rules: unknown...` |
| 383 | fn | parseRawPayloadRules | (private) | `function parseRawPayloadRules(rules: unknown): ...` |
| 418 | fn | serializePayloadRulesForYaml | (private) | `function serializePayloadRulesForYaml(rules: Pa...` |
| 453 | fn | serializePayloadFilterRulesForYaml | (private) | `function serializePayloadFilterRulesForYaml(` |
| 475 | fn | serializeRawPayloadRulesForYaml | (private) | `function serializeRawPayloadRulesForYaml(rules:...` |
| 497 | type | VisualConfigState | (private) | - |
| 504 | type | VisualConfigAction | (private) | - |
| 518 | fn | createInitialVisualConfigState | (private) | `function createInitialVisualConfigState(): Visu...` |
| 528 | fn | mergeVisualConfigValues | (private) | `function mergeVisualConfigValues(` |
| 539 | fn | getNextDirtyFields | (private) | `function getNextDirtyFields(` |
| 546 | fn | updateDirty | (private) | `const updateDirty = (key: string, isEqual: bool...` |
| 718 | fn | visualConfigReducer | (private) | `function visualConfigReducer(` |
| 755 | fn | useVisualConfig | pub | `export function useVisualConfig() {` |

## Public API

### `getVisualConfigValidationErrors`

```
export function getVisualConfigValidationErrors(
```

**Line:** 143 | **Kind:** fn

### `getPayloadParamValidationError`

```
export function getPayloadParamValidationError(
```

**Line:** 160 | **Kind:** fn

### `useVisualConfig`

```
export function useVisualConfig() {
```

**Line:** 755 | **Kind:** fn

