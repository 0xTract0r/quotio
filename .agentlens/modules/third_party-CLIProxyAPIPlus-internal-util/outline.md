# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 2 large files in this module.

## third_party/CLIProxyAPIPlus/internal/util/gemini_schema.go (803 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 16 | const | placeholderReasonDescription | (private) |
| 21 | fn | CleanJSONSchemaForAntigravity | pub |
| 27 | fn | CleanJSONSchemaForGemini | pub |
| 32 | fn | cleanJSONSchema | (private) |
| 63 | fn | removeKeywords | (private) |
| 82 | fn | removePlaceholderFields | (private) |
| 149 | fn | convertRefsToHints | (private) |
| 174 | fn | convertConstToEnum | (private) |
| 191 | fn | convertEnumValuesToStrings | (private) |
| 214 | fn | addEnumHints | (private) |
| 234 | fn | addAdditionalPropertiesHints | (private) |
| 249 | fn | moveConstraintsToDescription | (private) |
| 267 | fn | mergeAllOf | (private) |
| 304 | fn | flattenAnyOfOneOf | (private) |
| 337 | fn | selectBest | (private) |
| 364 | fn | flattenTypeArrays | (private) |
| 439 | fn | removeUnsupportedKeywords | (private) |
| 467 | fn | removeExtensionFields | (private) |
| 481 | fn | walkForExtensions | (private) |
| 508 | fn | cleanupRequiredFields | (private) |
| 541 | fn | addEmptySchemaPlaceholder | (private) |
| 609 | fn | findPaths | (private) |
| 615 | fn | findPathsByFields | (private) |
| 625 | fn | walkForFields | (private) |
| 651 | fn | sortByDepth | (private) |
| 655 | fn | trimSuffix | (private) |
| 662 | fn | joinPath | (private) |
| 669 | fn | setRawAt | (private) |
| 677 | fn | isPropertyDefinition | (private) |
| 681 | fn | descriptionPath | (private) |
| 688 | fn | appendHint | (private) |
| 702 | fn | appendHintRaw | (private) |
| 712 | fn | getStrings | (private) |
| 722 | fn | contains | (private) |
| 731 | fn | orDefault | (private) |
| 738 | fn | escapeGJSONPathKey | (private) |
| 745 | fn | unescapeGJSONPathKey | (private) |
| 762 | fn | splitGJSONPath | (private) |
| 790 | fn | mergeDescriptionRaw | (private) |

## third_party/CLIProxyAPIPlus/internal/util/gemini_schema_test.go (1072 lines)

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
| 1051 | fn | TestCleanJSONSchemaForAntigravity_UniqueItemsStripped | pub |

