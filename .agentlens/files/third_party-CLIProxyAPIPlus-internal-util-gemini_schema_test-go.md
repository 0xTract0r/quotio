# third_party/CLIProxyAPIPlus/internal/util/gemini_schema_test.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-util/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1048
- **Language:** Go
- **Symbols:** 34
- **Public symbols:** 33

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 12 | fn | TestCleanJSONSchemaForAntigravity_ConstToEnum | pub | `func TestCleanJSONSchemaForAntigravity_ConstToE...` |
| 37 | fn | TestCleanJSONSchemaForAntigravity_TypeFlattening_Nullable | pub | `func TestCleanJSONSchemaForAntigravity_TypeFlat...` |
| 69 | fn | TestCleanJSONSchemaForAntigravity_ConstraintsToDescription | pub | `func TestCleanJSONSchemaForAntigravity_Constrai...` |
| 105 | fn | TestCleanJSONSchemaForAntigravity_AnyOfFlattening_SmartSelection | pub | `func TestCleanJSONSchemaForAntigravity_AnyOfFla...` |
| 142 | fn | TestCleanJSONSchemaForAntigravity_OneOfFlattening | pub | `func TestCleanJSONSchemaForAntigravity_OneOfFla...` |
| 169 | fn | TestCleanJSONSchemaForAntigravity_AllOfMerging | pub | `func TestCleanJSONSchemaForAntigravity_AllOfMer...` |
| 201 | fn | TestCleanJSONSchemaForAntigravity_RefHandling | pub | `func TestCleanJSONSchemaForAntigravity_RefHandl...` |
| 239 | fn | TestCleanJSONSchemaForAntigravity_RefHandling_DescriptionEscaping | pub | `func TestCleanJSONSchemaForAntigravity_RefHandl...` |
| 280 | fn | TestCleanJSONSchemaForAntigravity_CyclicRefDefaults | pub | `func TestCleanJSONSchemaForAntigravity_CyclicRe...` |
| 308 | fn | TestCleanJSONSchemaForAntigravity_RequiredCleanup | pub | `func TestCleanJSONSchemaForAntigravity_Required...` |
| 331 | fn | TestCleanJSONSchemaForAntigravity_AllOfMerging_DotKeys | pub | `func TestCleanJSONSchemaForAntigravity_AllOfMer...` |
| 363 | fn | TestCleanJSONSchemaForAntigravity_PropertyNameCollision | pub | `func TestCleanJSONSchemaForAntigravity_Property...` |
| 398 | fn | TestCleanJSONSchemaForAntigravity_DotKeys | pub | `func TestCleanJSONSchemaForAntigravity_DotKeys(...` |
| 437 | fn | TestCleanJSONSchemaForAntigravity_AnyOfAlternativeHints | pub | `func TestCleanJSONSchemaForAntigravity_AnyOfAlt...` |
| 461 | fn | TestCleanJSONSchemaForAntigravity_NullableHint | pub | `func TestCleanJSONSchemaForAntigravity_Nullable...` |
| 483 | fn | TestCleanJSONSchemaForAntigravity_TypeFlattening_Nullable_DotKey | pub | `func TestCleanJSONSchemaForAntigravity_TypeFlat...` |
| 515 | fn | TestCleanJSONSchemaForAntigravity_EnumHint | pub | `func TestCleanJSONSchemaForAntigravity_EnumHint...` |
| 537 | fn | TestCleanJSONSchemaForAntigravity_AdditionalPropertiesHint | pub | `func TestCleanJSONSchemaForAntigravity_Addition...` |
| 553 | fn | TestCleanJSONSchemaForAntigravity_AnyOfFlattening_PreservesDescription | pub | `func TestCleanJSONSchemaForAntigravity_AnyOfFla...` |
| 581 | fn | TestCleanJSONSchemaForAntigravity_SingleEnumNoHint | pub | `func TestCleanJSONSchemaForAntigravity_SingleEn...` |
| 599 | fn | TestCleanJSONSchemaForAntigravity_MultipleNonNullTypes | pub | `func TestCleanJSONSchemaForAntigravity_Multiple...` |
| 619 | fn | compareJSON | (private) | `func compareJSON(t *testing.T, expectedJSON, ac...` |
| 639 | fn | TestCleanJSONSchemaForAntigravity_EmptySchemaPlaceholder | pub | `func TestCleanJSONSchemaForAntigravity_EmptySch...` |
| 656 | fn | TestCleanJSONSchemaForAntigravity_EmptyPropertiesPlaceholder | pub | `func TestCleanJSONSchemaForAntigravity_EmptyPro...` |
| 671 | fn | TestCleanJSONSchemaForAntigravity_NonEmptySchemaUnchanged | pub | `func TestCleanJSONSchemaForAntigravity_NonEmpty...` |
| 693 | fn | TestCleanJSONSchemaForAntigravity_NestedEmptySchema | pub | `func TestCleanJSONSchemaForAntigravity_NestedEm...` |
| 718 | fn | TestCleanJSONSchemaForAntigravity_EmptySchemaWithDescription | pub | `func TestCleanJSONSchemaForAntigravity_EmptySch...` |
| 740 | fn | TestCleanJSONSchemaForAntigravity_FormatFieldRemoval | pub | `func TestCleanJSONSchemaForAntigravity_FormatFi...` |
| 769 | fn | TestCleanJSONSchemaForAntigravity_FormatFieldNoDescription | pub | `func TestCleanJSONSchemaForAntigravity_FormatFi...` |
| 793 | fn | TestCleanJSONSchemaForAntigravity_MultipleFormats | pub | `func TestCleanJSONSchemaForAntigravity_Multiple...` |
| 822 | fn | TestCleanJSONSchemaForAntigravity_NumericEnumToString | pub | `func TestCleanJSONSchemaForAntigravity_NumericE...` |
| 852 | fn | TestCleanJSONSchemaForAntigravity_BooleanEnumToString | pub | `func TestCleanJSONSchemaForAntigravity_BooleanE...` |
| 873 | fn | TestCleanJSONSchemaForGemini_RemovesGeminiUnsupportedMetadataFields | pub | `func TestCleanJSONSchemaForGemini_RemovesGemini...` |
| 924 | fn | TestRemoveExtensionFields | pub | `func TestRemoveExtensionFields(t *testing.T) {` |

## Public API

### `TestCleanJSONSchemaForAntigravity_ConstToEnum`

```
func TestCleanJSONSchemaForAntigravity_ConstToEnum(t *testing.T) {
```

**Line:** 12 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_TypeFlattening_Nullable`

```
func TestCleanJSONSchemaForAntigravity_TypeFlattening_Nullable(t *testing.T) {
```

**Line:** 37 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_ConstraintsToDescription`

```
func TestCleanJSONSchemaForAntigravity_ConstraintsToDescription(t *testing.T) {
```

**Line:** 69 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_AnyOfFlattening_SmartSelection`

```
func TestCleanJSONSchemaForAntigravity_AnyOfFlattening_SmartSelection(t *testing.T) {
```

**Line:** 105 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_OneOfFlattening`

```
func TestCleanJSONSchemaForAntigravity_OneOfFlattening(t *testing.T) {
```

**Line:** 142 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_AllOfMerging`

```
func TestCleanJSONSchemaForAntigravity_AllOfMerging(t *testing.T) {
```

**Line:** 169 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_RefHandling`

```
func TestCleanJSONSchemaForAntigravity_RefHandling(t *testing.T) {
```

**Line:** 201 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_RefHandling_DescriptionEscaping`

```
func TestCleanJSONSchemaForAntigravity_RefHandling_DescriptionEscaping(t *testing.T) {
```

**Line:** 239 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_CyclicRefDefaults`

```
func TestCleanJSONSchemaForAntigravity_CyclicRefDefaults(t *testing.T) {
```

**Line:** 280 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_RequiredCleanup`

```
func TestCleanJSONSchemaForAntigravity_RequiredCleanup(t *testing.T) {
```

**Line:** 308 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_AllOfMerging_DotKeys`

```
func TestCleanJSONSchemaForAntigravity_AllOfMerging_DotKeys(t *testing.T) {
```

**Line:** 331 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_PropertyNameCollision`

```
func TestCleanJSONSchemaForAntigravity_PropertyNameCollision(t *testing.T) {
```

**Line:** 363 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_DotKeys`

```
func TestCleanJSONSchemaForAntigravity_DotKeys(t *testing.T) {
```

**Line:** 398 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_AnyOfAlternativeHints`

```
func TestCleanJSONSchemaForAntigravity_AnyOfAlternativeHints(t *testing.T) {
```

**Line:** 437 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_NullableHint`

```
func TestCleanJSONSchemaForAntigravity_NullableHint(t *testing.T) {
```

**Line:** 461 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_TypeFlattening_Nullable_DotKey`

```
func TestCleanJSONSchemaForAntigravity_TypeFlattening_Nullable_DotKey(t *testing.T) {
```

**Line:** 483 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_EnumHint`

```
func TestCleanJSONSchemaForAntigravity_EnumHint(t *testing.T) {
```

**Line:** 515 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_AdditionalPropertiesHint`

```
func TestCleanJSONSchemaForAntigravity_AdditionalPropertiesHint(t *testing.T) {
```

**Line:** 537 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_AnyOfFlattening_PreservesDescription`

```
func TestCleanJSONSchemaForAntigravity_AnyOfFlattening_PreservesDescription(t *testing.T) {
```

**Line:** 553 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_SingleEnumNoHint`

```
func TestCleanJSONSchemaForAntigravity_SingleEnumNoHint(t *testing.T) {
```

**Line:** 581 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_MultipleNonNullTypes`

```
func TestCleanJSONSchemaForAntigravity_MultipleNonNullTypes(t *testing.T) {
```

**Line:** 599 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_EmptySchemaPlaceholder`

```
func TestCleanJSONSchemaForAntigravity_EmptySchemaPlaceholder(t *testing.T) {
```

**Line:** 639 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_EmptyPropertiesPlaceholder`

```
func TestCleanJSONSchemaForAntigravity_EmptyPropertiesPlaceholder(t *testing.T) {
```

**Line:** 656 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_NonEmptySchemaUnchanged`

```
func TestCleanJSONSchemaForAntigravity_NonEmptySchemaUnchanged(t *testing.T) {
```

**Line:** 671 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_NestedEmptySchema`

```
func TestCleanJSONSchemaForAntigravity_NestedEmptySchema(t *testing.T) {
```

**Line:** 693 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_EmptySchemaWithDescription`

```
func TestCleanJSONSchemaForAntigravity_EmptySchemaWithDescription(t *testing.T) {
```

**Line:** 718 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_FormatFieldRemoval`

```
func TestCleanJSONSchemaForAntigravity_FormatFieldRemoval(t *testing.T) {
```

**Line:** 740 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_FormatFieldNoDescription`

```
func TestCleanJSONSchemaForAntigravity_FormatFieldNoDescription(t *testing.T) {
```

**Line:** 769 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_MultipleFormats`

```
func TestCleanJSONSchemaForAntigravity_MultipleFormats(t *testing.T) {
```

**Line:** 793 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_NumericEnumToString`

```
func TestCleanJSONSchemaForAntigravity_NumericEnumToString(t *testing.T) {
```

**Line:** 822 | **Kind:** fn

### `TestCleanJSONSchemaForAntigravity_BooleanEnumToString`

```
func TestCleanJSONSchemaForAntigravity_BooleanEnumToString(t *testing.T) {
```

**Line:** 852 | **Kind:** fn

### `TestCleanJSONSchemaForGemini_RemovesGeminiUnsupportedMetadataFields`

```
func TestCleanJSONSchemaForGemini_RemovesGeminiUnsupportedMetadataFields(t *testing.T) {
```

**Line:** 873 | **Kind:** fn

### `TestRemoveExtensionFields`

```
func TestRemoveExtensionFields(t *testing.T) {
```

**Line:** 924 | **Kind:** fn

