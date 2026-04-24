# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 2 large files in this module.

## third_party/CLIProxyAPIPlus/internal/util/gemini_schema.go (785 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 16 | const | placeholderReasonDescription | (private) |
| 21 | fn | CleanJSONSchemaForAntigravity | pub |
| 27 | fn | CleanJSONSchemaForGemini | pub |
| 32 | fn | cleanJSONSchema | (private) |
| 63 | fn | removeKeywords | (private) |
| 82 | fn | removePlaceholderFields | (private) |
| 147 | fn | convertRefsToHints | (private) |
| 171 | fn | convertConstToEnum | (private) |
| 187 | fn | convertEnumValuesToStrings | (private) |
| 208 | fn | addEnumHints | (private) |
| 228 | fn | addAdditionalPropertiesHints | (private) |
| 243 | fn | moveConstraintsToDescription | (private) |
| 261 | fn | mergeAllOf | (private) |
| 296 | fn | flattenAnyOfOneOf | (private) |
| 329 | fn | selectBest | (private) |
| 356 | fn | flattenTypeArrays | (private) |
| 429 | fn | removeUnsupportedKeywords | (private) |
| 457 | fn | removeExtensionFields | (private) |
| 471 | fn | walkForExtensions | (private) |
| 498 | fn | cleanupRequiredFields | (private) |
| 530 | fn | addEmptySchemaPlaceholder | (private) |
| 593 | fn | findPaths | (private) |
| 599 | fn | findPathsByFields | (private) |
| 609 | fn | walkForFields | (private) |
| 635 | fn | sortByDepth | (private) |
| 639 | fn | trimSuffix | (private) |
| 646 | fn | joinPath | (private) |
| 653 | fn | setRawAt | (private) |
| 661 | fn | isPropertyDefinition | (private) |
| 665 | fn | descriptionPath | (private) |
| 672 | fn | appendHint | (private) |
| 685 | fn | appendHintRaw | (private) |
| 694 | fn | getStrings | (private) |
| 704 | fn | contains | (private) |
| 713 | fn | orDefault | (private) |
| 720 | fn | escapeGJSONPathKey | (private) |
| 727 | fn | unescapeGJSONPathKey | (private) |
| 744 | fn | splitGJSONPath | (private) |
| 772 | fn | mergeDescriptionRaw | (private) |

## third_party/CLIProxyAPIPlus/internal/util/gemini_schema_test.go (1048 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 12 | fn | TestCleanJSONSchemaForAntigravity_ConstToEnum | pub |
| 37 | fn | TestCleanJSONSchemaForAntigravity_TypeFlattening_Nullable | pub |
| 69 | fn | TestCleanJSONSchemaForAntigravity_ConstraintsToDescription | pub |
| 105 | fn | TestCleanJSONSchemaForAntigravity_AnyOfFlattening_SmartSelection | pub |
| 142 | fn | TestCleanJSONSchemaForAntigravity_OneOfFlattening | pub |
| 169 | fn | TestCleanJSONSchemaForAntigravity_AllOfMerging | pub |
| 201 | fn | TestCleanJSONSchemaForAntigravity_RefHandling | pub |
| 239 | fn | TestCleanJSONSchemaForAntigravity_RefHandling_DescriptionEscaping | pub |
| 280 | fn | TestCleanJSONSchemaForAntigravity_CyclicRefDefaults | pub |
| 308 | fn | TestCleanJSONSchemaForAntigravity_RequiredCleanup | pub |
| 331 | fn | TestCleanJSONSchemaForAntigravity_AllOfMerging_DotKeys | pub |
| 363 | fn | TestCleanJSONSchemaForAntigravity_PropertyNameCollision | pub |
| 398 | fn | TestCleanJSONSchemaForAntigravity_DotKeys | pub |
| 437 | fn | TestCleanJSONSchemaForAntigravity_AnyOfAlternativeHints | pub |
| 461 | fn | TestCleanJSONSchemaForAntigravity_NullableHint | pub |
| 483 | fn | TestCleanJSONSchemaForAntigravity_TypeFlattening_Nullable_DotKey | pub |
| 515 | fn | TestCleanJSONSchemaForAntigravity_EnumHint | pub |
| 537 | fn | TestCleanJSONSchemaForAntigravity_AdditionalPropertiesHint | pub |
| 553 | fn | TestCleanJSONSchemaForAntigravity_AnyOfFlattening_PreservesDescription | pub |
| 581 | fn | TestCleanJSONSchemaForAntigravity_SingleEnumNoHint | pub |
| 599 | fn | TestCleanJSONSchemaForAntigravity_MultipleNonNullTypes | pub |
| 619 | fn | compareJSON | (private) |
| 639 | fn | TestCleanJSONSchemaForAntigravity_EmptySchemaPlaceholder | pub |
| 656 | fn | TestCleanJSONSchemaForAntigravity_EmptyPropertiesPlaceholder | pub |
| 671 | fn | TestCleanJSONSchemaForAntigravity_NonEmptySchemaUnchanged | pub |
| 693 | fn | TestCleanJSONSchemaForAntigravity_NestedEmptySchema | pub |
| 718 | fn | TestCleanJSONSchemaForAntigravity_EmptySchemaWithDescription | pub |
| 740 | fn | TestCleanJSONSchemaForAntigravity_FormatFieldRemoval | pub |
| 769 | fn | TestCleanJSONSchemaForAntigravity_FormatFieldNoDescription | pub |
| 793 | fn | TestCleanJSONSchemaForAntigravity_MultipleFormats | pub |
| 822 | fn | TestCleanJSONSchemaForAntigravity_NumericEnumToString | pub |
| 852 | fn | TestCleanJSONSchemaForAntigravity_BooleanEnumToString | pub |
| 873 | fn | TestCleanJSONSchemaForGemini_RemovesGeminiUnsupportedMetadataFields | pub |
| 924 | fn | TestRemoveExtensionFields | pub |

