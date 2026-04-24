# third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude/antigravity_claude_request_test.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-translator-antigravity-claude/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1412
- **Language:** Go
- **Symbols:** 33
- **Public symbols:** 33

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 11 | fn | TestConvertClaudeRequestToAntigravity_BasicStructure | pub | `func TestConvertClaudeRequestToAntigravity_Basi...` |
| 57 | fn | TestConvertClaudeRequestToAntigravity_RoleMapping | pub | `func TestConvertClaudeRequestToAntigravity_Role...` |
| 76 | fn | TestConvertClaudeRequestToAntigravity_ThinkingBlocks | pub | `func TestConvertClaudeRequestToAntigravity_Thin...` |
| 119 | fn | TestConvertClaudeRequestToAntigravity_ThinkingBlockWithoutSignature | pub | `func TestConvertClaudeRequestToAntigravity_Thin...` |
| 154 | fn | TestConvertClaudeRequestToAntigravity_ToolDeclarations | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 196 | fn | TestConvertClaudeRequestToAntigravity_ToolChoice_SpecificTool | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 232 | fn | TestConvertClaudeRequestToAntigravity_ToolUse | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 278 | fn | TestConvertClaudeRequestToAntigravity_ToolUse_WithSignature | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 321 | fn | TestConvertClaudeRequestToAntigravity_ReorderThinking | pub | `func TestConvertClaudeRequestToAntigravity_Reor...` |
| 364 | fn | TestConvertClaudeRequestToAntigravity_ToolResult | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 408 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_TouluFormat | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 467 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_CustomFormat | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 507 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_Heuristic | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 536 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_RawID | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 569 | fn | TestConvertClaudeRequestToAntigravity_ThinkingConfig | pub | `func TestConvertClaudeRequestToAntigravity_Thin...` |
| 599 | fn | TestConvertClaudeRequestToAntigravity_ImageContent | pub | `func TestConvertClaudeRequestToAntigravity_Imag...` |
| 635 | fn | TestConvertClaudeRequestToAntigravity_GenerationConfig | pub | `func TestConvertClaudeRequestToAntigravity_Gene...` |
| 667 | fn | TestConvertClaudeRequestToAntigravity_TrailingUnsignedThinking_Removed | pub | `func TestConvertClaudeRequestToAntigravity_Trai...` |
| 706 | fn | TestConvertClaudeRequestToAntigravity_TrailingSignedThinking_Kept | pub | `func TestConvertClaudeRequestToAntigravity_Trai...` |
| 743 | fn | TestConvertClaudeRequestToAntigravity_MiddleUnsignedThinking_Removed | pub | `func TestConvertClaudeRequestToAntigravity_Midd...` |
| 784 | fn | TestConvertClaudeRequestToAntigravity_ToolAndThinking_HintInjected | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 823 | fn | TestConvertClaudeRequestToAntigravity_ToolsOnly_NoHint | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 852 | fn | TestConvertClaudeRequestToAntigravity_ThinkingOnly_NoHint | pub | `func TestConvertClaudeRequestToAntigravity_Thin...` |
| 875 | fn | TestConvertClaudeRequestToAntigravity_ToolResultNoContent | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 917 | fn | TestConvertClaudeRequestToAntigravity_ToolResultNullContent | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 954 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithImage | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1025 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithSingleImage | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1084 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithMultipleImagesAndTexts | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1161 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithOnlyMultipleImages | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1224 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageNotBase64 | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1277 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageMissingData | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1327 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageMissingMediaType | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |
| 1377 | fn | TestConvertClaudeRequestToAntigravity_ToolAndThinking_NoExistingSystem | pub | `func TestConvertClaudeRequestToAntigravity_Tool...` |

## Public API

### `TestConvertClaudeRequestToAntigravity_BasicStructure`

```
func TestConvertClaudeRequestToAntigravity_BasicStructure(t *testing.T) {
```

**Line:** 11 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_RoleMapping`

```
func TestConvertClaudeRequestToAntigravity_RoleMapping(t *testing.T) {
```

**Line:** 57 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ThinkingBlocks`

```
func TestConvertClaudeRequestToAntigravity_ThinkingBlocks(t *testing.T) {
```

**Line:** 76 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ThinkingBlockWithoutSignature`

```
func TestConvertClaudeRequestToAntigravity_ThinkingBlockWithoutSignature(t *testing.T) {
```

**Line:** 119 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolDeclarations`

```
func TestConvertClaudeRequestToAntigravity_ToolDeclarations(t *testing.T) {
```

**Line:** 154 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolChoice_SpecificTool`

```
func TestConvertClaudeRequestToAntigravity_ToolChoice_SpecificTool(t *testing.T) {
```

**Line:** 196 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolUse`

```
func TestConvertClaudeRequestToAntigravity_ToolUse(t *testing.T) {
```

**Line:** 232 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolUse_WithSignature`

```
func TestConvertClaudeRequestToAntigravity_ToolUse_WithSignature(t *testing.T) {
```

**Line:** 278 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ReorderThinking`

```
func TestConvertClaudeRequestToAntigravity_ReorderThinking(t *testing.T) {
```

**Line:** 321 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResult`

```
func TestConvertClaudeRequestToAntigravity_ToolResult(t *testing.T) {
```

**Line:** 364 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultName_TouluFormat`

```
func TestConvertClaudeRequestToAntigravity_ToolResultName_TouluFormat(t *testing.T) {
```

**Line:** 408 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultName_CustomFormat`

```
func TestConvertClaudeRequestToAntigravity_ToolResultName_CustomFormat(t *testing.T) {
```

**Line:** 467 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_Heuristic`

```
func TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_Heuristic(t *testing.T) {
```

**Line:** 507 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_RawID`

```
func TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_RawID(t *testing.T) {
```

**Line:** 536 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ThinkingConfig`

```
func TestConvertClaudeRequestToAntigravity_ThinkingConfig(t *testing.T) {
```

**Line:** 569 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ImageContent`

```
func TestConvertClaudeRequestToAntigravity_ImageContent(t *testing.T) {
```

**Line:** 599 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_GenerationConfig`

```
func TestConvertClaudeRequestToAntigravity_GenerationConfig(t *testing.T) {
```

**Line:** 635 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_TrailingUnsignedThinking_Removed`

```
func TestConvertClaudeRequestToAntigravity_TrailingUnsignedThinking_Removed(t *testing.T) {
```

**Line:** 667 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_TrailingSignedThinking_Kept`

```
func TestConvertClaudeRequestToAntigravity_TrailingSignedThinking_Kept(t *testing.T) {
```

**Line:** 706 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_MiddleUnsignedThinking_Removed`

```
func TestConvertClaudeRequestToAntigravity_MiddleUnsignedThinking_Removed(t *testing.T) {
```

**Line:** 743 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolAndThinking_HintInjected`

```
func TestConvertClaudeRequestToAntigravity_ToolAndThinking_HintInjected(t *testing.T) {
```

**Line:** 784 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolsOnly_NoHint`

```
func TestConvertClaudeRequestToAntigravity_ToolsOnly_NoHint(t *testing.T) {
```

**Line:** 823 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ThinkingOnly_NoHint`

```
func TestConvertClaudeRequestToAntigravity_ThinkingOnly_NoHint(t *testing.T) {
```

**Line:** 852 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultNoContent`

```
func TestConvertClaudeRequestToAntigravity_ToolResultNoContent(t *testing.T) {
```

**Line:** 875 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultNullContent`

```
func TestConvertClaudeRequestToAntigravity_ToolResultNullContent(t *testing.T) {
```

**Line:** 917 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultWithImage`

```
func TestConvertClaudeRequestToAntigravity_ToolResultWithImage(t *testing.T) {
```

**Line:** 954 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultWithSingleImage`

```
func TestConvertClaudeRequestToAntigravity_ToolResultWithSingleImage(t *testing.T) {
```

**Line:** 1025 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultWithMultipleImagesAndTexts`

```
func TestConvertClaudeRequestToAntigravity_ToolResultWithMultipleImagesAndTexts(t *testing.T) {
```

**Line:** 1084 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultWithOnlyMultipleImages`

```
func TestConvertClaudeRequestToAntigravity_ToolResultWithOnlyMultipleImages(t *testing.T) {
```

**Line:** 1161 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultImageNotBase64`

```
func TestConvertClaudeRequestToAntigravity_ToolResultImageNotBase64(t *testing.T) {
```

**Line:** 1224 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultImageMissingData`

```
func TestConvertClaudeRequestToAntigravity_ToolResultImageMissingData(t *testing.T) {
```

**Line:** 1277 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolResultImageMissingMediaType`

```
func TestConvertClaudeRequestToAntigravity_ToolResultImageMissingMediaType(t *testing.T) {
```

**Line:** 1327 | **Kind:** fn

### `TestConvertClaudeRequestToAntigravity_ToolAndThinking_NoExistingSystem`

```
func TestConvertClaudeRequestToAntigravity_ToolAndThinking_NoExistingSystem(t *testing.T) {
```

**Line:** 1377 | **Kind:** fn

## Memory Markers

### 🟢 `NOTE` (line 570)

> This test requires the model to be registered in the registry

### 🟡 `FIXME` (line 876)

> repro: tool_result with no content field produces invalid JSON

### 🟡 `FIXME` (line 918)

> repro: tool_result with null content produces invalid JSON

