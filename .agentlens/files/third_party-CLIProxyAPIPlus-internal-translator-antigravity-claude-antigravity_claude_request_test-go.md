# third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude/antigravity_claude_request_test.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-translator-antigravity-claude/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2438
- **Language:** Go
- **Symbols:** 68
- **Public symbols:** 62

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 14 | fn | testAnthropicNativeSignature | (private) | `func testAnthropicNativeSignature(t *testing.T)...` |
| 25 | fn | testMinimalAnthropicSignature | (private) | `func testMinimalAnthropicSignature(t *testing.T...` |
| 32 | fn | buildClaudeSignaturePayload | (private) | `func buildClaudeSignaturePayload(t *testing.T, ...` |
| 69 | fn | uint64Ptr | (private) | `func uint64Ptr(v uint64) *uint64 {` |
| 73 | fn | testNonAnthropicRawSignature | (private) | `func testNonAnthropicRawSignature(t *testing.T)...` |
| 84 | fn | testGeminiRawSignature | (private) | `func testGeminiRawSignature(t *testing.T) string {` |
| 95 | fn | TestConvertClaudeRequestToAntigravity_BasicStructure | pub | `func TestConvertClaudeRequestToAntigravity_Basi...` |
| 141 | fn | TestConvertClaudeRequestToAntigravity_RoleMapping | pub | `func TestConvertClaudeRequestToAntigravity_Role...` |
| 160 | fn | TestConvertClaudeRequestToAntigravity_ThinkingBlocks | pub | `func TestConvertClaudeRequestToAntigravity_Thin...` |
| 203 | fn | TestValidateBypassMode_AcceptsClaudeSingleAndDoubleLayer | pub | `func TestValidateBypassMode_AcceptsClaudeSingle...` |
| 224 | fn | TestValidateBypassMode_RejectsGeminiSignature | pub | `func TestValidateBypassMode_RejectsGeminiSignat...` |
| 242 | fn | TestValidateBypassMode_RejectsMissingSignature | pub | `func TestValidateBypassMode_RejectsMissingSigna...` |
| 263 | fn | TestValidateBypassMode_RejectsNonREPrefix | pub | `func TestValidateBypassMode_RejectsNonREPrefix(...` |
| 281 | fn | TestValidateBypassMode_RejectsEPrefixWrongFirstByte | pub | `func TestValidateBypassMode_RejectsEPrefixWrong...` |
| 304 | fn | TestValidateBypassMode_RejectsTopLevel12WithoutClaudeTree | pub | `func TestValidateBypassMode_RejectsTopLevel12Wi...` |
| 329 | fn | TestValidateBypassMode_NonStrictAccepts12WithoutClaudeTree | pub | `func TestValidateBypassMode_NonStrictAccepts12W...` |
| 351 | fn | TestValidateBypassMode_RejectsRPrefixInnerNotE | pub | `func TestValidateBypassMode_RejectsRPrefixInner...` |
| 371 | fn | TestValidateBypassMode_RejectsInvalidBase64 | pub | `func TestValidateBypassMode_RejectsInvalidBase6...` |
| 399 | fn | TestValidateBypassMode_RejectsPrefixStrippedToEmpty | pub | `func TestValidateBypassMode_RejectsPrefixStripp...` |
| 425 | fn | TestValidateBypassMode_HandlesMultipleHashMarks | pub | `func TestValidateBypassMode_HandlesMultipleHash...` |
| 442 | fn | TestValidateBypassMode_HandlesWhitespace | pub | `func TestValidateBypassMode_HandlesWhitespace(t...` |
| 469 | fn | TestValidateBypassMode_RejectsOversizedSignature | pub | `func TestValidateBypassMode_RejectsOversizedSig...` |
| 488 | fn | TestValidateBypassMode_StrictAcceptsSignatureBetween16KiBAnd32MiB | pub | `func TestValidateBypassMode_StrictAcceptsSignat...` |
| 515 | fn | TestResolveBypassModeSignature_TrimsWhitespace | pub | `func TestResolveBypassModeSignature_TrimsWhites...` |
| 534 | fn | TestConvertClaudeRequestToAntigravity_BypassModeNormalizesESignature | pub | `func TestConvertClaudeRequestToAntigravity_Bypa...` |
| 575 | fn | TestConvertClaudeRequestToAntigravity_BypassModePreservesShortValidSignature | pub | `func TestConvertClaudeRequestToAntigravity_Bypa...` |
| 621 | fn | TestInspectClaudeSignaturePayload_ExtractsSpecTree | pub | `func TestInspectClaudeSignaturePayload_Extracts...` |
| 643 | fn | TestInspectDoubleLayerSignature_TracksEncodingLayers | pub | `func TestInspectDoubleLayerSignature_TracksEnco...` |
| 660 | fn | TestConvertClaudeRequestToAntigravity_CacheModeDropsRawSignature | pub | `func TestConvertClaudeRequestToAntigravity_Cach...` |
| 693 | fn | TestConvertClaudeRequestToAntigravity_BypassModeDropsInvalidSignature | pub | `func TestConvertClaudeRequestToAntigravity_Bypa...` |
| 731 | fn | TestConvertClaudeRequestToAntigravity_BypassModeDropsGeminiSignature | pub | `func TestConvertClaudeRequestToAntigravity_Bypa...` |
| 765 | fn | TestConvertClaudeRequestToAntigravity_ThinkingBlockWithoutSignature | pub | `func TestConvertClaudeRequestToAntigravity_Thin...` |
| 800 | fn | TestConvertClaudeRequestToAntigravity_ToolDeclarations | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 842 | fn | TestConvertClaudeRequestToAntigravity_ToolChoice_SpecificTool | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 878 | fn | TestConvertClaudeRequestToAntigravity_ToolUse | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 924 | fn | TestConvertClaudeRequestToAntigravity_ToolUse_WithSignature | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 967 | fn | TestConvertClaudeRequestToAntigravity_ReorderThinking | pub | `func TestConvertClaudeRequestToAntigravity_Reor...` |
| 1010 | fn | TestConvertClaudeRequestToAntigravity_ReorderTextAfterFunctionCall | pub | `func TestConvertClaudeRequestToAntigravity_Reor...` |
| 1067 | fn | TestConvertClaudeRequestToAntigravity_ReorderParallelFunctionCalls | pub | `func TestConvertClaudeRequestToAntigravity_Reor...` |
| 1115 | fn | TestConvertClaudeRequestToAntigravity_ReorderThinkingAndTextBeforeFunctionCall | pub | `func TestConvertClaudeRequestToAntigravity_Reor...` |
| 1171 | fn | TestConvertClaudeRequestToAntigravity_ToolResult | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1215 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_TouluFormat | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1274 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_CustomFormat | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1314 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_Heuristic | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1343 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_RawID | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1376 | fn | TestConvertClaudeRequestToAntigravity_ThinkingConfig | pub | `func TestConvertClaudeRequestToAntigravity_Thin...` |
| 1406 | fn | TestConvertClaudeRequestToAntigravity_ImageContent | pub | `func TestConvertClaudeRequestToAntigravity_Imag...` |
| 1442 | fn | TestConvertClaudeRequestToAntigravity_GenerationConfig | pub | `func TestConvertClaudeRequestToAntigravity_Gene...` |
| 1474 | fn | TestConvertClaudeRequestToAntigravity_TrailingUnsignedThinking_Removed | pub | `func TestConvertClaudeRequestToAntigravity_Trai...` |
| 1513 | fn | TestConvertClaudeRequestToAntigravity_TrailingSignedThinking_Kept | pub | `func TestConvertClaudeRequestToAntigravity_Trai...` |
| 1550 | fn | TestConvertClaudeRequestToAntigravity_MiddleUnsignedThinking_Removed | pub | `func TestConvertClaudeRequestToAntigravity_Midd...` |
| 1591 | fn | TestConvertClaudeRequestToAntigravity_ToolAndThinking_HintInjected | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1630 | fn | TestConvertClaudeRequestToAntigravity_ToolsOnly_NoHint | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1659 | fn | TestConvertClaudeRequestToAntigravity_ThinkingOnly_NoHint | pub | `func TestConvertClaudeRequestToAntigravity_Thin...` |
| 1682 | fn | TestConvertClaudeRequestToAntigravity_ToolResultNoContent | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1724 | fn | TestConvertClaudeRequestToAntigravity_ToolResultNullContent | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1761 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithImage | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1832 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithSingleImage | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1891 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithMultipleImagesAndTexts | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1968 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithOnlyMultipleImages | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 2031 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageNotBase64 | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 2084 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageMissingData | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 2134 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageMissingMediaType | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 2184 | fn | TestConvertClaudeRequestToAntigravity_BypassMode_DropsRedactedThinkingBlocks | pub | `func TestConvertClaudeRequestToAntigravity_Bypa...` |
| 2232 | fn | TestConvertClaudeRequestToAntigravity_BypassMode_DropsWrappedRedactedThinking | pub | `func TestConvertClaudeRequestToAntigravity_Bypa...` |
| 2277 | fn | TestConvertClaudeRequestToAntigravity_BypassMode_KeepsNonEmptyThinking | pub | `func TestConvertClaudeRequestToAntigravity_Bypa...` |
| 2323 | fn | TestConvertClaudeRequestToAntigravity_BypassMode_MultiTurnRedactedThinking | pub | `func TestConvertClaudeRequestToAntigravity_Bypa...` |
| 2403 | fn | TestConvertClaudeRequestToAntigravity_ToolAndThinking_NoExistingSystem | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |

## Public API

### `TestConvertClaudeRequestToAntigravity_BasicStructure`

```
func TestConvertClaudeRequestToAntigravity_BasicStructure(t *testing.T) {
```

**Line:** 95 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_RoleMapping`

```
func TestConvertClaudeRequestToAntigravity_RoleMapping(t *testing.T) {
```

**Line:** 141 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ThinkingBlocks`

```
func TestConvertClaudeRequestToAntigravity_ThinkingBlocks(t *testing.T) {
```

**Line:** 160 | **Kind:** fn

### `TestValidateBypassMode_AcceptsClaudeSingleAndDoubleLayer`

```
func TestValidateBypassMode_AcceptsClaudeSingleAndDoubleLayer(t *testing.T) {
```

**Line:** 203 | **Kind:** fn

### `TestValidateBypassMode_RejectsGeminiSignature`

```
func TestValidateBypassMode_RejectsGeminiSignature(t *testing.T) {
```

**Line:** 224 | **Kind:** fn

### `TestValidateBypassMode_RejectsMissingSignature`

```
func TestValidateBypassMode_RejectsMissingSignature(t *testing.T) {
```

**Line:** 242 | **Kind:** fn

### `TestValidateBypassMode_RejectsNonREPrefix`

```
func TestValidateBypassMode_RejectsNonREPrefix(t *testing.T) {
```

**Line:** 263 | **Kind:** fn

### `TestValidateBypassMode_RejectsEPrefixWrongFirstByte`

```
func TestValidateBypassMode_RejectsEPrefixWrongFirstByte(t *testing.T) {
```

**Line:** 281 | **Kind:** fn

### `TestValidateBypassMode_RejectsTopLevel12WithoutClaudeTree`

```
func TestValidateBypassMode_RejectsTopLevel12WithoutClaudeTree(t *testing.T) {
```

**Line:** 304 | **Kind:** fn

### `TestValidateBypassMode_NonStrictAccepts12WithoutClaudeTree`

```
func TestValidateBypassMode_NonStrictAccepts12WithoutClaudeTree(t *testing.T) {
```

**Line:** 329 | **Kind:** fn

### `TestValidateBypassMode_RejectsRPrefixInnerNotE`

```
func TestValidateBypassMode_RejectsRPrefixInnerNotE(t *testing.T) {
```

**Line:** 351 | **Kind:** fn

### `TestValidateBypassMode_RejectsInvalidBase64`

```
func TestValidateBypassMode_RejectsInvalidBase64(t *testing.T) {
```

**Line:** 371 | **Kind:** fn

### `TestValidateBypassMode_RejectsPrefixStrippedToEmpty`

```
func TestValidateBypassMode_RejectsPrefixStrippedToEmpty(t *testing.T) {
```

**Line:** 399 | **Kind:** fn

### `TestValidateBypassMode_HandlesMultipleHashMarks`

```
func TestValidateBypassMode_HandlesMultipleHashMarks(t *testing.T) {
```

**Line:** 425 | **Kind:** fn

### `TestValidateBypassMode_HandlesWhitespace`

```
func TestValidateBypassMode_HandlesWhitespace(t *testing.T) {
```

**Line:** 442 | **Kind:** fn

### `TestValidateBypassMode_RejectsOversizedSignature`

```
func TestValidateBypassMode_RejectsOversizedSignature(t *testing.T) {
```

**Line:** 469 | **Kind:** fn

### `TestValidateBypassMode_StrictAcceptsSignatureBetween16KiBAnd32MiB`

```
func TestValidateBypassMode_StrictAcceptsSignatureBetween16KiBAnd32MiB(t *testing.T) {
```

**Line:** 488 | **Kind:** fn

### `TestResolveBypassModeSignature_TrimsWhitespace`

```
func TestResolveBypassModeSignature_TrimsWhitespace(t *testing.T) {
```

**Line:** 515 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_BypassModeNormalizesESignature`

```
func TestConvertClaudeRequestToAntigravity_BypassModeNormalizesESignature(t *testing.T) {
```

**Line:** 534 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_BypassModePreservesShortValidSignature`

```
func TestConvertClaudeRequestToAntigravity_BypassModePreservesShortValidSignature(t *testing.T) {
```

**Line:** 575 | **Kind:** fn

### `TestInspectClaudeSignaturePayload_ExtractsSpecTree`

```
func TestInspectClaudeSignaturePayload_ExtractsSpecTree(t *testing.T) {
```

**Line:** 621 | **Kind:** fn

### `TestInspectDoubleLayerSignature_TracksEncodingLayers`

```
func TestInspectDoubleLayerSignature_TracksEncodingLayers(t *testing.T) {
```

**Line:** 643 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_CacheModeDropsRawSignature`

```
func TestConvertClaudeRequestToAntigravity_CacheModeDropsRawSignature(t *testing.T) {
```

**Line:** 660 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_BypassModeDropsInvalidSignature`

```
func TestConvertClaudeRequestToAntigravity_BypassModeDropsInvalidSignature(t *testing.T) {
```

**Line:** 693 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_BypassModeDropsGeminiSignature`

```
func TestConvertClaudeRequestToAntigravity_BypassModeDropsGeminiSignature(t *testing.T) {
```

**Line:** 731 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ThinkingBlockWithoutSignature`

```
func TestConvertClaudeRequestToAntigravity_ThinkingBlockWithoutSignature(t *testing.T) {
```

**Line:** 765 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolDeclarations`

```
func TestConvertClaudeRequestToAntigravity_ToolDeclarations(t *testing.T) {
```

**Line:** 800 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolChoice_SpecificTool`

```
func TestConvertClaudeRequestToAntigravity_ToolChoice_SpecificTool(t *testing.T) {
```

**Line:** 842 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolUse`

```
func TestConvertClaudeRequestToAntigravity_ToolUse(t *testing.T) {
```

**Line:** 878 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolUse_WithSignature`

```
func TestConvertClaudeRequestToAntigravity_ToolUse_WithSignature(t *testing.T) {
```

**Line:** 924 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ReorderThinking`

```
func TestConvertClaudeRequestToAntigravity_ReorderThinking(t *testing.T) {
```

**Line:** 967 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ReorderTextAfterFunctionCall`

```
func TestConvertClaudeRequestToAntigravity_ReorderTextAfterFunctionCall(t *testing.T) {
```

**Line:** 1010 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ReorderParallelFunctionCalls`

```
func TestConvertClaudeRequestToAntigravity_ReorderParallelFunctionCalls(t *testing.T) {
```

**Line:** 1067 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ReorderThinkingAndTextBeforeFunctionCall`

```
func TestConvertClaudeRequestToAntigravity_ReorderThinkingAndTextBeforeFunctionCall(t *testing.T) {
```

**Line:** 1115 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResult`

```
func TestConvertClaudeRequestToAntigravity_ToolResult(t *testing.T) {
```

**Line:** 1171 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultName_TouluFormat`

```
func TestConvertClaudeRequestToAntigravity_ToolResultName_TouluFormat(t *testing.T) {
```

**Line:** 1215 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultName_CustomFormat`

```
func TestConvertClaudeRequestToAntigravity_ToolResultName_CustomFormat(t *testing.T) {
```

**Line:** 1274 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_Heuristic`

```
func TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_Heuristic(t *testing.T) {
```

**Line:** 1314 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_RawID`

```
func TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_RawID(t *testing.T) {
```

**Line:** 1343 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ThinkingConfig`

```
func TestConvertClaudeRequestToAntigravity_ThinkingConfig(t *testing.T) {
```

**Line:** 1376 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ImageContent`

```
func TestConvertClaudeRequestToAntigravity_ImageContent(t *testing.T) {
```

**Line:** 1406 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_GenerationConfig`

```
func TestConvertClaudeRequestToAntigravity_GenerationConfig(t *testing.T) {
```

**Line:** 1442 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_TrailingUnsignedThinking_Removed`

```
func TestConvertClaudeRequestToAntigravity_TrailingUnsignedThinking_Removed(t *testing.T) {
```

**Line:** 1474 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_TrailingSignedThinking_Kept`

```
func TestConvertClaudeRequestToAntigravity_TrailingSignedThinking_Kept(t *testing.T) {
```

**Line:** 1513 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_MiddleUnsignedThinking_Removed`

```
func TestConvertClaudeRequestToAntigravity_MiddleUnsignedThinking_Removed(t *testing.T) {
```

**Line:** 1550 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolAndThinking_HintInjected`

```
func TestConvertClaudeRequestToAntigravity_ToolAndThinking_HintInjected(t *testing.T) {
```

**Line:** 1591 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolsOnly_NoHint`

```
func TestConvertClaudeRequestToAntigravity_ToolsOnly_NoHint(t *testing.T) {
```

**Line:** 1630 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ThinkingOnly_NoHint`

```
func TestConvertClaudeRequestToAntigravity_ThinkingOnly_NoHint(t *testing.T) {
```

**Line:** 1659 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultNoContent`

```
func TestConvertClaudeRequestToAntigravity_ToolResultNoContent(t *testing.T) {
```

**Line:** 1682 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultNullContent`

```
func TestConvertClaudeRequestToAntigravity_ToolResultNullContent(t *testing.T) {
```

**Line:** 1724 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultWithImage`

```
func TestConvertClaudeRequestToAntigravity_ToolResultWithImage(t *testing.T) {
```

**Line:** 1761 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultWithSingleImage`

```
func TestConvertClaudeRequestToAntigravity_ToolResultWithSingleImage(t *testing.T) {
```

**Line:** 1832 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultWithMultipleImagesAndTexts`

```
func TestConvertClaudeRequestToAntigravity_ToolResultWithMultipleImagesAndTexts(t *testing.T) {
```

**Line:** 1891 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultWithOnlyMultipleImages`

```
func TestConvertClaudeRequestToAntigravity_ToolResultWithOnlyMultipleImages(t *testing.T) {
```

**Line:** 1968 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultImageNotBase64`

```
func TestConvertClaudeRequestToAntigravity_ToolResultImageNotBase64(t *testing.T) {
```

**Line:** 2031 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultImageMissingData`

```
func TestConvertClaudeRequestToAntigravity_ToolResultImageMissingData(t *testing.T) {
```

**Line:** 2084 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultImageMissingMediaType`

```
func TestConvertClaudeRequestToAntigravity_ToolResultImageMissingMediaType(t *testing.T) {
```

**Line:** 2134 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_BypassMode_DropsRedactedThinkingBlocks`

```
func TestConvertClaudeRequestToAntigravity_BypassMode_DropsRedactedThinkingBlocks(t *testing.T) {
```

**Line:** 2184 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_BypassMode_DropsWrappedRedactedThinking`

```
func TestConvertClaudeRequestToAntigravity_BypassMode_DropsWrappedRedactedThinking(t *testing.T) {
```

**Line:** 2232 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_BypassMode_KeepsNonEmptyThinking`

```
func TestConvertClaudeRequestToAntigravity_BypassMode_KeepsNonEmptyThinking(t *testing.T) {
```

**Line:** 2277 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_BypassMode_MultiTurnRedactedThinking`

```
func TestConvertClaudeRequestToAntigravity_BypassMode_MultiTurnRedactedThinking(t *testing.T) {
```

**Line:** 2323 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolAndThinking_NoExistingSystem`

```
func TestConvertClaudeRequestToAntigravity_ToolAndThinking_NoExistingSystem(t *testing.T) {
```

**Line:** 2403 | **Kind:** fn

## Memory Markers

### 🟡 `FIXME` (line 1011)

> text part after tool_use in an assistant message causes Antigravity

### 🟢 `NOTE` (line 1377)

> This test requires the model to be registered in the registry

### 🟡 `FIXME` (line 1683)

> repro: tool_result with no content field produces invalid JSON

### 🟡 `FIXME` (line 1725)

> repro: tool_result with null content produces invalid JSON

