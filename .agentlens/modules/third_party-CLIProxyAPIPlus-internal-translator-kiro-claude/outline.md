# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 3 large files in this module.

## third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_claude_request.go (961 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 21 | const | remoteWebSearchDescription | (private) |
| 26 | struct | KiroPayload | pub |
| 33 | struct | KiroInferenceConfig | pub |
| 40 | struct | KiroConversationState | pub |
| 50 | struct | KiroCurrentMessage | pub |
| 55 | struct | KiroHistoryMessage | pub |
| 61 | struct | KiroImage | pub |
| 67 | struct | KiroImageSource | pub |
| 72 | struct | KiroUserInputMessage | pub |
| 81 | struct | KiroUserInputMessageContext | pub |
| 87 | struct | KiroToolResult | pub |
| 94 | struct | KiroTextContent | pub |
| 99 | struct | KiroToolWrapper | pub |
| 104 | struct | KiroToolSpecification | pub |
| 111 | struct | KiroInputSchema | pub |
| 116 | struct | KiroAssistantResponseMessage | pub |
| 122 | struct | KiroToolUse | pub |
| 132 | fn | ConvertClaudeRequestToKiro | pub |
| 148 | fn | BuildKiroPayload | pub |
| 332 | fn | normalizeOrigin | (private) |
| 349 | fn | extractMetadataFromMessages | (private) |
| 360 | fn | extractSystemPrompt | (private) |
| 377 | fn | checkThinkingMode | (private) |
| 404 | fn | hasThinkingTagInBody | (private) |
| 411 | fn | IsThinkingEnabledFromHeader | pub |
| 436 | fn | IsThinkingEnabled | pub |
| 446 | fn | IsThinkingEnabledWithHeaders | pub |
| 519 | fn | shortenToolNameIfNeeded | (private) |
| 538 | fn | ensureKiroInputSchema | (private) |
| 549 | fn | convertClaudeToolsToKiro | (private) |
| 612 | fn | processMessages | (private) |
| 737 | fn | buildFinalContent | (private) |
| 763 | fn | deduplicateToolResults | (private) |
| 786 | fn | extractClaudeToolChoiceHint | (private) |
| 810 | fn | BuildUserMessageStruct | pub |
| 903 | fn | BuildAssistantMessageStruct | pub |

## third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/kiro_claude_tools.go (543 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 16 | struct | ToolUseState | pub |
| 35 | fn | ParseEmbeddedToolCalls | pub |
| 141 | fn | findMatchingBracket | (private) |
| 199 | fn | RepairJSON | pub |
| 333 | fn | escapeNewlinesInStrings | (private) |
| 383 | fn | ProcessToolUseEvent | pub |
| 518 | fn | DeduplicateToolUses | pub |

## third_party/CLIProxyAPIPlus/internal/translator/kiro/claude/truncation_detector.go (537 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 14 | struct | TruncationInfo | pub |
| 79 | fn | DetectTruncation | pub |
| 153 | fn | looksLikeTruncatedJSON | (private) |
| 213 | fn | extractPartialFields | (private) |
| 247 | fn | extractParsedFieldNames | (private) |
| 270 | fn | findMissingRequiredFields | (private) |
| 288 | fn | isWriteTool | (private) |
| 293 | fn | detectContentTruncation | (private) |
| 323 | fn | buildTruncationErrorMessage | (private) |
| 357 | fn | buildMissingFieldsErrorMessage | (private) |
| 379 | fn | IsTruncated | pub |
| 385 | fn | GetTruncationSummary | pub |
| 401 | struct | SoftFailureMessage | pub |
| 418 | fn | BuildSoftFailureMessage | pub |
| 475 | fn | formatInt | (private) |
| 490 | fn | BuildSoftFailureToolResult | pub |
| 527 | fn | CreateTruncationToolResult | pub |

