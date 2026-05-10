# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 2 large files in this module.

## third_party/CLIProxyAPIPlus/internal/watcher/synthesizer/config_test.go (617 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 11 | fn | TestNewConfigSynthesizer | pub |
| 18 | fn | TestConfigSynthesizer_Synthesize_NilContext | pub |
| 29 | fn | TestConfigSynthesizer_Synthesize_NilConfig | pub |
| 45 | fn | TestConfigSynthesizer_GeminiKeys | pub |
| 157 | fn | TestConfigSynthesizer_ClaudeKeys | pub |
| 202 | fn | TestConfigSynthesizer_ClaudeKeys_SkipsEmptyAndHeaders | pub |
| 228 | fn | TestConfigSynthesizer_CodexKeys | pub |
| 268 | fn | TestConfigSynthesizer_CodexKeys_SkipsEmptyAndHeaders | pub |
| 294 | fn | TestConfigSynthesizer_OpenAICompat | pub |
| 372 | fn | TestConfigSynthesizer_VertexCompat | pub |
| 407 | fn | TestConfigSynthesizer_VertexCompat_SkipsEmptyAndHeaders | pub |
| 442 | fn | TestConfigSynthesizer_OpenAICompat_WithModelsHash | pub |
| 479 | fn | TestConfigSynthesizer_OpenAICompat_FallbackWithModels | pub |
| 514 | fn | TestConfigSynthesizer_VertexCompat_WithModels | pub |
| 545 | fn | TestConfigSynthesizer_IDStability | pub |
| 574 | fn | TestConfigSynthesizer_AllProviders | pub |

## third_party/CLIProxyAPIPlus/internal/watcher/synthesizer/file_test.go (960 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 15 | fn | TestNewFileSynthesizer | pub |
| 22 | fn | TestFileSynthesizer_Synthesize_NilContext | pub |
| 33 | fn | TestFileSynthesizer_Synthesize_EmptyAuthDir | pub |
| 50 | fn | TestFileSynthesizer_Synthesize_NonExistentDir | pub |
| 67 | fn | TestFileSynthesizer_Synthesize_ValidAuthFile | pub |
| 134 | fn | TestFileSynthesizer_Synthesize_GeminiProviderMapping | pub |
| 169 | fn | TestFileSynthesizer_Synthesize_SkipsInvalidFiles | pub |
| 202 | fn | TestFileSynthesizer_Synthesize_SkipsDirectories | pub |
| 233 | fn | TestFileSynthesizer_Synthesize_RelativeID | pub |
| 268 | fn | TestFileSynthesizer_Synthesize_PrefixValidation | pub |
| 313 | fn | TestFileSynthesizer_Synthesize_PriorityParsing | pub |
| 385 | fn | TestFileSynthesizer_Synthesize_OAuthExcludedModelsMerged | pub |
| 424 | fn | TestSynthesizeGeminiVirtualAuths_NilInputs | pub |
| 438 | fn | TestSynthesizeGeminiVirtualAuths_SingleProject | pub |
| 457 | fn | TestSynthesizeGeminiVirtualAuths_MultiProject | pub |
| 538 | fn | TestSynthesizeGeminiVirtualAuths_EmptyProviderAndLabel | pub |
| 569 | fn | TestSynthesizeGeminiVirtualAuths_NilPrimaryAttributes | pub |
| 597 | fn | TestSplitGeminiProjectIDs | pub |
| 656 | fn | TestFileSynthesizer_Synthesize_MultiProjectGemini | pub |
| 716 | fn | TestBuildGeminiVirtualID | pub |
| 765 | fn | TestSynthesizeGeminiVirtualAuths_NotePropagated | pub |
| 800 | fn | TestSynthesizeGeminiVirtualAuths_NoteAbsentWhenEmpty | pub |
| 830 | fn | TestFileSynthesizer_Synthesize_NoteParsing | pub |
| 912 | fn | TestFileSynthesizer_Synthesize_MultiProjectGeminiWithNote | pub |

