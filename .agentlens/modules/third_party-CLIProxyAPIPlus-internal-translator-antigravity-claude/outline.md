# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 3 large files in this module.

## third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude/antigravity_claude_request.go (522 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 38 | fn | ConvertClaudeRequestToAntigravity | pub |

## third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude/antigravity_claude_request_test.go (1412 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 11 | fn | TestConvertClaudeRequestToAntigravity_BasicStructure | pub |
| 57 | fn | TestConvertClaudeRequestToAntigravity_RoleMapping | pub |
| 76 | fn | TestConvertClaudeRequestToAntigravity_ThinkingBlocks | pub |
| 119 | fn | TestConvertClaudeRequestToAntigravity_ThinkingBlockWithoutSignature | pub |
| 154 | fn | TestConvertClaudeRequestToAntigravity_ToolDeclarations | pub |
| 196 | fn | TestConvertClaudeRequestToAntigravity_ToolChoice_SpecificTool | pub |
| 232 | fn | TestConvertClaudeRequestToAntigravity_ToolUse | pub |
| 278 | fn | TestConvertClaudeRequestToAntigravity_ToolUse_WithSignature | pub |
| 321 | fn | TestConvertClaudeRequestToAntigravity_ReorderThinking | pub |
| 364 | fn | TestConvertClaudeRequestToAntigravity_ToolResult | pub |
| 408 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_TouluFormat | pub |
| 467 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_CustomFormat | pub |
| 507 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_Heuristic | pub |
| 536 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_RawID | pub |
| 569 | fn | TestConvertClaudeRequestToAntigravity_ThinkingConfig | pub |
| 599 | fn | TestConvertClaudeRequestToAntigravity_ImageContent | pub |
| 635 | fn | TestConvertClaudeRequestToAntigravity_GenerationConfig | pub |
| 667 | fn | TestConvertClaudeRequestToAntigravity_TrailingUnsignedThinking_Removed | pub |
| 706 | fn | TestConvertClaudeRequestToAntigravity_TrailingSignedThinking_Kept | pub |
| 743 | fn | TestConvertClaudeRequestToAntigravity_MiddleUnsignedThinking_Removed | pub |
| 784 | fn | TestConvertClaudeRequestToAntigravity_ToolAndThinking_HintInjected | pub |
| 823 | fn | TestConvertClaudeRequestToAntigravity_ToolsOnly_NoHint | pub |
| 852 | fn | TestConvertClaudeRequestToAntigravity_ThinkingOnly_NoHint | pub |
| 875 | fn | TestConvertClaudeRequestToAntigravity_ToolResultNoContent | pub |
| 917 | fn | TestConvertClaudeRequestToAntigravity_ToolResultNullContent | pub |
| 954 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithImage | pub |
| 1025 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithSingleImage | pub |
| 1084 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithMultipleImagesAndTexts | pub |
| 1161 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithOnlyMultipleImages | pub |
| 1224 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageNotBase64 | pub |
| 1277 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageMissingData | pub |
| 1327 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageMissingMediaType | pub |
| 1377 | fn | TestConvertClaudeRequestToAntigravity_ToolAndThinking_NoExistingSystem | pub |

## third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude/antigravity_claude_response.go (524 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 28 | struct | Params | pub |
| 67 | fn | ConvertAntigravityResponseToClaude | pub |
| 302 | fn | appendFinalEvents | (private) |
| 348 | fn | resolveStopReason | (private) |
| 373 | fn | ConvertAntigravityResponseToClaudeNonStream | pub |
| 522 | fn | ClaudeTokenCount | pub |

