# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 3 large files in this module.

## third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude/antigravity_claude_request.go (567 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 20 | fn | resolveThinkingSignature | (private) |
| 27 | fn | resolveCacheModeSignature | (private) |
| 52 | fn | resolveBypassModeSignature | (private) |
| 63 | fn | hasResolvedThinkingSignature | (private) |
| 88 | fn | ConvertClaudeRequestToAntigravity | pub |

## third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude/antigravity_claude_request_test.go (2438 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 14 | fn | testAnthropicNativeSignature | (private) |
| 25 | fn | testMinimalAnthropicSignature | (private) |
| 32 | fn | buildClaudeSignaturePayload | (private) |
| 69 | fn | uint64Ptr | (private) |
| 73 | fn | testNonAnthropicRawSignature | (private) |
| 84 | fn | testGeminiRawSignature | (private) |
| 95 | fn | TestConvertClaudeRequestToAntigravity_BasicStructure | pub |
| 141 | fn | TestConvertClaudeRequestToAntigravity_RoleMapping | pub |
| 160 | fn | TestConvertClaudeRequestToAntigravity_ThinkingBlocks | pub |
| 203 | fn | TestValidateBypassMode_AcceptsClaudeSingleAndDoubleLayer | pub |
| 224 | fn | TestValidateBypassMode_RejectsGeminiSignature | pub |
| 242 | fn | TestValidateBypassMode_RejectsMissingSignature | pub |
| 263 | fn | TestValidateBypassMode_RejectsNonREPrefix | pub |
| 281 | fn | TestValidateBypassMode_RejectsEPrefixWrongFirstByte | pub |
| 304 | fn | TestValidateBypassMode_RejectsTopLevel12WithoutClaudeTree | pub |
| 329 | fn | TestValidateBypassMode_NonStrictAccepts12WithoutClaudeTree | pub |
| 351 | fn | TestValidateBypassMode_RejectsRPrefixInnerNotE | pub |
| 371 | fn | TestValidateBypassMode_RejectsInvalidBase64 | pub |
| 399 | fn | TestValidateBypassMode_RejectsPrefixStrippedToEmpty | pub |
| 425 | fn | TestValidateBypassMode_HandlesMultipleHashMarks | pub |
| 442 | fn | TestValidateBypassMode_HandlesWhitespace | pub |
| 469 | fn | TestValidateBypassMode_RejectsOversizedSignature | pub |
| 488 | fn | TestValidateBypassMode_StrictAcceptsSignatureBetween16KiBAnd32MiB | pub |
| 515 | fn | TestResolveBypassModeSignature_TrimsWhitespace | pub |
| 534 | fn | TestConvertClaudeRequestToAntigravity_BypassModeNormalizesESignature | pub |
| 575 | fn | TestConvertClaudeRequestToAntigravity_BypassModePreservesShortValidSignature | pub |
| 621 | fn | TestInspectClaudeSignaturePayload_ExtractsSpecTree | pub |
| 643 | fn | TestInspectDoubleLayerSignature_TracksEncodingLayers | pub |
| 660 | fn | TestConvertClaudeRequestToAntigravity_CacheModeDropsRawSignature | pub |
| 693 | fn | TestConvertClaudeRequestToAntigravity_BypassModeDropsInvalidSignature | pub |
| 731 | fn | TestConvertClaudeRequestToAntigravity_BypassModeDropsGeminiSignature | pub |
| 765 | fn | TestConvertClaudeRequestToAntigravity_ThinkingBlockWithoutSignature | pub |
| 800 | fn | TestConvertClaudeRequestToAntigravity_ToolDeclarations | pub |
| 842 | fn | TestConvertClaudeRequestToAntigravity_ToolChoice_SpecificTool | pub |
| 878 | fn | TestConvertClaudeRequestToAntigravity_ToolUse | pub |
| 924 | fn | TestConvertClaudeRequestToAntigravity_ToolUse_WithSignature | pub |
| 967 | fn | TestConvertClaudeRequestToAntigravity_ReorderThinking | pub |
| 1010 | fn | TestConvertClaudeRequestToAntigravity_ReorderTextAfterFunctionCall | pub |
| 1067 | fn | TestConvertClaudeRequestToAntigravity_ReorderParallelFunctionCalls | pub |
| 1115 | fn | TestConvertClaudeRequestToAntigravity_ReorderThinkingAndTextBeforeFunctionCall | pub |
| 1171 | fn | TestConvertClaudeRequestToAntigravity_ToolResult | pub |
| 1215 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_TouluFormat | pub |
| 1274 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_CustomFormat | pub |
| 1314 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_Heuristic | pub |
| 1343 | fn | TestConvertClaudeRequestToAntigravity_ToolResultName_NoMatchingToolUse_RawID | pub |
| 1376 | fn | TestConvertClaudeRequestToAntigravity_ThinkingConfig | pub |
| 1406 | fn | TestConvertClaudeRequestToAntigravity_ImageContent | pub |
| 1442 | fn | TestConvertClaudeRequestToAntigravity_GenerationConfig | pub |
| 1474 | fn | TestConvertClaudeRequestToAntigravity_TrailingUnsignedThinking_Removed | pub |
| 1513 | fn | TestConvertClaudeRequestToAntigravity_TrailingSignedThinking_Kept | pub |
| 1550 | fn | TestConvertClaudeRequestToAntigravity_MiddleUnsignedThinking_Removed | pub |
| 1591 | fn | TestConvertClaudeRequestToAntigravity_ToolAndThinking_HintInjected | pub |
| 1630 | fn | TestConvertClaudeRequestToAntigravity_ToolsOnly_NoHint | pub |
| 1659 | fn | TestConvertClaudeRequestToAntigravity_ThinkingOnly_NoHint | pub |
| 1682 | fn | TestConvertClaudeRequestToAntigravity_ToolResultNoContent | pub |
| 1724 | fn | TestConvertClaudeRequestToAntigravity_ToolResultNullContent | pub |
| 1761 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithImage | pub |
| 1832 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithSingleImage | pub |
| 1891 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithMultipleImagesAndTexts | pub |
| 1968 | fn | TestConvertClaudeRequestToAntigravity_ToolResultWithOnlyMultipleImages | pub |
| 2031 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageNotBase64 | pub |
| 2084 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageMissingData | pub |
| 2134 | fn | TestConvertClaudeRequestToAntigravity_ToolResultImageMissingMediaType | pub |
| 2184 | fn | TestConvertClaudeRequestToAntigravity_BypassMode_DropsRedactedThinkingBlocks | pub |
| 2232 | fn | TestConvertClaudeRequestToAntigravity_BypassMode_DropsWrappedRedactedThinking | pub |
| 2277 | fn | TestConvertClaudeRequestToAntigravity_BypassMode_KeepsNonEmptyThinking | pub |
| 2323 | fn | TestConvertClaudeRequestToAntigravity_BypassMode_MultiTurnRedactedThinking | pub |
| 2403 | fn | TestConvertClaudeRequestToAntigravity_ToolAndThinking_NoExistingSystem | pub |

## third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude/antigravity_claude_response.go (552 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 29 | fn | decodeSignature | (private) |
| 44 | fn | formatClaudeSignatureValue | (private) |
| 57 | struct | Params | pub |
| 100 | fn | ConvertAntigravityResponseToClaude | pub |
| 333 | fn | appendFinalEvents | (private) |
| 375 | fn | resolveStopReason | (private) |
| 400 | fn | ConvertAntigravityResponseToClaudeNonStream | pub |
| 550 | fn | ClaudeTokenCount | pub |

