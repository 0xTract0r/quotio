# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 1 large files in this module.

## third_party/Cli-Proxy-API-Management-Center/src/hooks/useVisualConfig.ts (1121 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 14 | fn | asRecord | (private) |
| 19 | fn | extractApiKeyValue | (private) |
| 39 | fn | parseApiKeysText | (private) |
| 50 | fn | resolveApiKeysText | (private) |
| 67 | type | YamlDocument | (private) |
| 68 | type | YamlPath | (private) |
| 70 | fn | docHas | (private) |
| 74 | fn | ensureMapInDoc | (private) |
| 81 | fn | deleteIfMapEmpty | (private) |
| 87 | fn | setBooleanInDoc | (private) |
| 95 | fn | setStringInDoc | (private) |
| 109 | fn | setIntFromStringInDoc | (private) |
| 128 | fn | getNonNegativeIntegerError | (private) |
| 135 | fn | getPortError | (private) |
| 143 | fn | getVisualConfigValidationErrors | pub |
| 160 | fn | getPayloadParamValidationError | pub |
| 191 | fn | hasPayloadParamValidationErrors | (private) |
| 197 | fn | deepClone | (private) |
| 202 | fn | arePayloadModelEntriesEqual | (private) |
| 217 | fn | arePayloadParamEntriesEqual | (private) |
| 234 | fn | arePayloadRulesEqual | (private) |
| 248 | fn | arePayloadFilterRulesEqual | (private) |
| 268 | fn | parsePayloadParamValue | (private) |
| 289 | fn | parseRawPayloadParamValue | (private) |
| 300 | fn | parsePayloadProtocol | (private) |
| 305 | fn | deleteLegacyApiKeysProvider | (private) |
| 317 | fn | parsePayloadRules | (private) |
| 355 | fn | parsePayloadFilterRules | (private) |
| 383 | fn | parseRawPayloadRules | (private) |
| 418 | fn | serializePayloadRulesForYaml | (private) |
| 453 | fn | serializePayloadFilterRulesForYaml | (private) |
| 475 | fn | serializeRawPayloadRulesForYaml | (private) |
| 497 | type | VisualConfigState | (private) |
| 504 | type | VisualConfigAction | (private) |
| 518 | fn | createInitialVisualConfigState | (private) |
| 528 | fn | mergeVisualConfigValues | (private) |
| 539 | fn | getNextDirtyFields | (private) |
| 546 | fn | updateDirty | (private) |
| 718 | fn | visualConfigReducer | (private) |
| 755 | fn | useVisualConfig | pub |

