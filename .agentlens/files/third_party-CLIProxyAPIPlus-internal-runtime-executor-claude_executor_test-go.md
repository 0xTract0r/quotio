# third_party/CLIProxyAPIPlus/internal/runtime/executor/claude_executor_test.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-runtime-executor/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1141
- **Language:** Go
- **Symbols:** 44
- **Public symbols:** 42

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 22 | fn | TestApplyClaudeToolPrefix | pub | `func TestApplyClaudeToolPrefix(t *testing.T) {` |
| 40 | fn | TestApplyClaudeToolPrefix_WithToolReference | pub | `func TestApplyClaudeToolPrefix_WithToolReferenc...` |
| 52 | fn | TestApplyClaudeToolPrefix_SkipsBuiltinTools | pub | `func TestApplyClaudeToolPrefix_SkipsBuiltinTool...` |
| 64 | fn | TestApplyClaudeToolPrefix_BuiltinToolSkipped | pub | `func TestApplyClaudeToolPrefix_BuiltinToolSkipp...` |
| 93 | fn | TestApplyClaudeToolPrefix_KnownBuiltinInHistoryOnly | pub | `func TestApplyClaudeToolPrefix_KnownBuiltinInHi...` |
| 114 | fn | TestApplyClaudeToolPrefix_CustomToolsPrefixed | pub | `func TestApplyClaudeToolPrefix_CustomToolsPrefi...` |
| 140 | fn | TestApplyClaudeToolPrefix_ToolChoiceBuiltin | pub | `func TestApplyClaudeToolPrefix_ToolChoiceBuilti...` |
| 155 | fn | TestStripClaudeToolPrefixFromResponse | pub | `func TestStripClaudeToolPrefixFromResponse(t *t...` |
| 167 | fn | TestStripClaudeToolPrefixFromResponse_WithToolReference | pub | `func TestStripClaudeToolPrefixFromResponse_With...` |
| 179 | fn | TestStripClaudeToolPrefixFromStreamLine | pub | `func TestStripClaudeToolPrefixFromStreamLine(t ...` |
| 192 | fn | TestStripClaudeToolPrefixFromStreamLine_WithToolReference | pub | `func TestStripClaudeToolPrefixFromStreamLine_Wi...` |
| 205 | fn | TestApplyClaudeToolPrefix_NestedToolReference | pub | `func TestApplyClaudeToolPrefix_NestedToolRefere...` |
| 214 | fn | TestClaudeExecutor_ReusesUserIDAcrossModelsWhenCacheEnabled | pub | `func TestClaudeExecutor_ReusesUserIDAcrossModel...` |
| 282 | fn | TestClaudeExecutor_GeneratesNewUserIDByDefault | pub | `func TestClaudeExecutor_GeneratesNewUserIDByDef...` |
| 327 | fn | TestStripClaudeToolPrefixFromResponse_NestedToolReference | pub | `func TestStripClaudeToolPrefixFromResponse_Nest...` |
| 336 | fn | TestApplyClaudeToolPrefix_NestedToolReferenceWithStringContent | pub | `func TestApplyClaudeToolPrefix_NestedToolRefere...` |
| 346 | fn | TestApplyClaudeToolPrefix_SkipsBuiltinToolReference | pub | `func TestApplyClaudeToolPrefix_SkipsBuiltinTool...` |
| 355 | fn | TestApplyClaudeHeaders_PrefersSavedManagedHeadersOverGinHeaders | pub | `func TestApplyClaudeHeaders_PrefersSavedManaged...` |
| 402 | fn | TestApplyClaudeHeaders_PreservesClaudeCloakingDefaultsWithoutSavedHeaders | pub | `func TestApplyClaudeHeaders_PreservesClaudeCloa...` |
| 430 | fn | TestNormalizeCacheControlTTL_DowngradesLaterOneHourBlocks | pub | `func TestNormalizeCacheControlTTL_DowngradesLat...` |
| 447 | fn | TestNormalizeCacheControlTTL_PreservesOriginalBytesWhenNoChange | pub | `func TestNormalizeCacheControlTTL_PreservesOrig...` |
| 460 | fn | TestEnforceCacheControlLimit_StripsNonLastToolBeforeMessages | pub | `func TestEnforceCacheControlLimit_StripsNonLast...` |
| 489 | fn | TestEnforceCacheControlLimit_ToolOnlyPayloadStillRespectsLimit | pub | `func TestEnforceCacheControlLimit_ToolOnlyPaylo...` |
| 513 | fn | TestClaudeExecutor_CountTokens_AppliesCacheControlGuards | pub | `func TestClaudeExecutor_CountTokens_AppliesCach...` |
| 563 | fn | hasTTLOrderingViolation | (private) | `func hasTTLOrderingViolation(payload []byte) bo...` |
| 614 | fn | TestClaudeExecutor_Execute_InvalidGzipErrorBodyReturnsDecodeMessage | pub | `func TestClaudeExecutor_Execute_InvalidGzipErro...` |
| 624 | fn | TestClaudeExecutor_ExecuteStream_InvalidGzipErrorBodyReturnsDecodeMessage | pub | `func TestClaudeExecutor_ExecuteStream_InvalidGz...` |
| 634 | fn | TestClaudeExecutor_CountTokens_InvalidGzipErrorBodyReturnsDecodeMessage | pub | `func TestClaudeExecutor_CountTokens_InvalidGzip...` |
| 644 | fn | testClaudeExecutorInvalidCompressedErrorBody | (private) | `func testClaudeExecutorInvalidCompressedErrorBody(` |
| 680 | fn | TestClaudeExecutor_ExecuteStream_SetsIdentityAcceptEncoding | pub | `func TestClaudeExecutor_ExecuteStream_SetsIdent...` |
| 723 | fn | TestClaudeExecutor_Execute_SetsCompressedAcceptEncoding | pub | `func TestClaudeExecutor_Execute_SetsCompressedA...` |
| 761 | fn | TestClaudeExecutor_ExecuteStream_GzipSuccessBodyDecoded | pub | `func TestClaudeExecutor_ExecuteStream_GzipSucce...` |
| 810 | fn | TestDecodeResponseBody_MagicByteGzipNoHeader | pub | `func TestDecodeResponseBody_MagicByteGzipNoHead...` |
| 836 | fn | TestDecodeResponseBody_PlainTextNoHeader | pub | `func TestDecodeResponseBody_PlainTextNoHeader(t...` |
| 858 | fn | TestClaudeExecutor_ExecuteStream_GzipNoContentEncodingHeader | pub | `func TestClaudeExecutor_ExecuteStream_GzipNoCon...` |
| 908 | fn | TestClaudeExecutor_ExecuteStream_AcceptEncodingOverrideCannotBypassIdentity | pub | `func TestClaudeExecutor_ExecuteStream_AcceptEnc...` |
| 949 | fn | TestDecodeResponseBody_MagicByteZstdNoHeader | pub | `func TestDecodeResponseBody_MagicByteZstdNoHead...` |
| 980 | fn | TestClaudeExecutor_Execute_GzipErrorBodyNoContentEncodingHeader | pub | `func TestClaudeExecutor_Execute_GzipErrorBodyNo...` |
| 1021 | fn | TestClaudeExecutor_ExecuteStream_GzipErrorBodyNoContentEncodingHeader | pub | `func TestClaudeExecutor_ExecuteStream_GzipError...` |
| 1060 | fn | TestCheckSystemInstructionsWithMode_StringSystemPreserved | pub | `func TestCheckSystemInstructionsWithMode_String...` |
| 1090 | fn | TestCheckSystemInstructionsWithMode_StringSystemStrict | pub | `func TestCheckSystemInstructionsWithMode_String...` |
| 1102 | fn | TestCheckSystemInstructionsWithMode_EmptyStringSystemIgnored | pub | `func TestCheckSystemInstructionsWithMode_EmptyS...` |
| 1114 | fn | TestCheckSystemInstructionsWithMode_ArraySystemStillWorks | pub | `func TestCheckSystemInstructionsWithMode_ArrayS...` |
| 1129 | fn | TestCheckSystemInstructionsWithMode_StringWithSpecialChars | pub | `func TestCheckSystemInstructionsWithMode_String...` |

## Public API

### `TestApplyClaudeToolPrefix`

```
func TestApplyClaudeToolPrefix(t *testing.T) {
```

**Line:** 22 | **Kind:** fn

### `TestApplyClaudeToolPrefix_WithToolReference`

```
func TestApplyClaudeToolPrefix_WithToolReference(t *testing.T) {
```

**Line:** 40 | **Kind:** fn

### `TestApplyClaudeToolPrefix_SkipsBuiltinTools`

```
func TestApplyClaudeToolPrefix_SkipsBuiltinTools(t *testing.T) {
```

**Line:** 52 | **Kind:** fn

### `TestApplyClaudeToolPrefix_BuiltinToolSkipped`

```
func TestApplyClaudeToolPrefix_BuiltinToolSkipped(t *testing.T) {
```

**Line:** 64 | **Kind:** fn

### `TestApplyClaudeToolPrefix_KnownBuiltinInHistoryOnly`

```
func TestApplyClaudeToolPrefix_KnownBuiltinInHistoryOnly(t *testing.T) {
```

**Line:** 93 | **Kind:** fn

### `TestApplyClaudeToolPrefix_CustomToolsPrefixed`

```
func TestApplyClaudeToolPrefix_CustomToolsPrefixed(t *testing.T) {
```

**Line:** 114 | **Kind:** fn

### `TestApplyClaudeToolPrefix_ToolChoiceBuiltin`

```
func TestApplyClaudeToolPrefix_ToolChoiceBuiltin(t *testing.T) {
```

**Line:** 140 | **Kind:** fn

### `TestStripClaudeToolPrefixFromResponse`

```
func TestStripClaudeToolPrefixFromResponse(t *testing.T) {
```

**Line:** 155 | **Kind:** fn

### `TestStripClaudeToolPrefixFromResponse_WithToolReference`

```
func TestStripClaudeToolPrefixFromResponse_WithToolReference(t *testing.T) {
```

**Line:** 167 | **Kind:** fn

### `TestStripClaudeToolPrefixFromStreamLine`

```
func TestStripClaudeToolPrefixFromStreamLine(t *testing.T) {
```

**Line:** 179 | **Kind:** fn

### `TestStripClaudeToolPrefixFromStreamLine_WithToolReference`

```
func TestStripClaudeToolPrefixFromStreamLine_WithToolReference(t *testing.T) {
```

**Line:** 192 | **Kind:** fn

### `TestApplyClaudeToolPrefix_NestedToolReference`

```
func TestApplyClaudeToolPrefix_NestedToolReference(t *testing.T) {
```

**Line:** 205 | **Kind:** fn

### `TestClaudeExecutor_ReusesUserIDAcrossModelsWhenCacheEnabled`

```
func TestClaudeExecutor_ReusesUserIDAcrossModelsWhenCacheEnabled(t *testing.T) {
```

**Line:** 214 | **Kind:** fn

### `TestClaudeExecutor_GeneratesNewUserIDByDefault`

```
func TestClaudeExecutor_GeneratesNewUserIDByDefault(t *testing.T) {
```

**Line:** 282 | **Kind:** fn

### `TestStripClaudeToolPrefixFromResponse_NestedToolReference`

```
func TestStripClaudeToolPrefixFromResponse_NestedToolReference(t *testing.T) {
```

**Line:** 327 | **Kind:** fn

### `TestApplyClaudeToolPrefix_NestedToolReferenceWithStringContent`

```
func TestApplyClaudeToolPrefix_NestedToolReferenceWithStringContent(t *testing.T) {
```

**Line:** 336 | **Kind:** fn

### `TestApplyClaudeToolPrefix_SkipsBuiltinToolReference`

```
func TestApplyClaudeToolPrefix_SkipsBuiltinToolReference(t *testing.T) {
```

**Line:** 346 | **Kind:** fn

### `TestApplyClaudeHeaders_PrefersSavedManagedHeadersOverGinHeaders`

```
func TestApplyClaudeHeaders_PrefersSavedManagedHeadersOverGinHeaders(t *testing.T) {
```

**Line:** 355 | **Kind:** fn

### `TestApplyClaudeHeaders_PreservesClaudeCloakingDefaultsWithoutSavedHeaders`

```
func TestApplyClaudeHeaders_PreservesClaudeCloakingDefaultsWithoutSavedHeaders(t *testing.T) {
```

**Line:** 402 | **Kind:** fn

### `TestNormalizeCacheControlTTL_DowngradesLaterOneHourBlocks`

```
func TestNormalizeCacheControlTTL_DowngradesLaterOneHourBlocks(t *testing.T) {
```

**Line:** 430 | **Kind:** fn

### `TestNormalizeCacheControlTTL_PreservesOriginalBytesWhenNoChange`

```
func TestNormalizeCacheControlTTL_PreservesOriginalBytesWhenNoChange(t *testing.T) {
```

**Line:** 447 | **Kind:** fn

### `TestEnforceCacheControlLimit_StripsNonLastToolBeforeMessages`

```
func TestEnforceCacheControlLimit_StripsNonLastToolBeforeMessages(t *testing.T) {
```

**Line:** 460 | **Kind:** fn

### `TestEnforceCacheControlLimit_ToolOnlyPayloadStillRespectsLimit`

```
func TestEnforceCacheControlLimit_ToolOnlyPayloadStillRespectsLimit(t *testing.T) {
```

**Line:** 489 | **Kind:** fn

### `TestClaudeExecutor_CountTokens_AppliesCacheControlGuards`

```
func TestClaudeExecutor_CountTokens_AppliesCacheControlGuards(t *testing.T) {
```

**Line:** 513 | **Kind:** fn

### `TestClaudeExecutor_Execute_InvalidGzipErrorBodyReturnsDecodeMessage`

```
func TestClaudeExecutor_Execute_InvalidGzipErrorBodyReturnsDecodeMessage(t *testing.T) {
```

**Line:** 614 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_InvalidGzipErrorBodyReturnsDecodeMessage`

```
func TestClaudeExecutor_ExecuteStream_InvalidGzipErrorBodyReturnsDecodeMessage(t *testing.T) {
```

**Line:** 624 | **Kind:** fn

### `TestClaudeExecutor_CountTokens_InvalidGzipErrorBodyReturnsDecodeMessage`

```
func TestClaudeExecutor_CountTokens_InvalidGzipErrorBodyReturnsDecodeMessage(t *testing.T) {
```

**Line:** 634 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_SetsIdentityAcceptEncoding`

```
func TestClaudeExecutor_ExecuteStream_SetsIdentityAcceptEncoding(t *testing.T) {
```

**Line:** 680 | **Kind:** fn

### `TestClaudeExecutor_Execute_SetsCompressedAcceptEncoding`

```
func TestClaudeExecutor_Execute_SetsCompressedAcceptEncoding(t *testing.T) {
```

**Line:** 723 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_GzipSuccessBodyDecoded`

```
func TestClaudeExecutor_ExecuteStream_GzipSuccessBodyDecoded(t *testing.T) {
```

**Line:** 761 | **Kind:** fn

### `TestDecodeResponseBody_MagicByteGzipNoHeader`

```
func TestDecodeResponseBody_MagicByteGzipNoHeader(t *testing.T) {
```

**Line:** 810 | **Kind:** fn

### `TestDecodeResponseBody_PlainTextNoHeader`

```
func TestDecodeResponseBody_PlainTextNoHeader(t *testing.T) {
```

**Line:** 836 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_GzipNoContentEncodingHeader`

```
func TestClaudeExecutor_ExecuteStream_GzipNoContentEncodingHeader(t *testing.T) {
```

**Line:** 858 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_AcceptEncodingOverrideCannotBypassIdentity`

```
func TestClaudeExecutor_ExecuteStream_AcceptEncodingOverrideCannotBypassIdentity(t *testing.T) {
```

**Line:** 908 | **Kind:** fn

### `TestDecodeResponseBody_MagicByteZstdNoHeader`

```
func TestDecodeResponseBody_MagicByteZstdNoHeader(t *testing.T) {
```

**Line:** 949 | **Kind:** fn

### `TestClaudeExecutor_Execute_GzipErrorBodyNoContentEncodingHeader`

```
func TestClaudeExecutor_Execute_GzipErrorBodyNoContentEncodingHeader(t *testing.T) {
```

**Line:** 980 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_GzipErrorBodyNoContentEncodingHeader`

```
func TestClaudeExecutor_ExecuteStream_GzipErrorBodyNoContentEncodingHeader(t *testing.T) {
```

**Line:** 1021 | **Kind:** fn

### `TestCheckSystemInstructionsWithMode_StringSystemPreserved`

```
func TestCheckSystemInstructionsWithMode_StringSystemPreserved(t *testing.T) {
```

**Line:** 1060 | **Kind:** fn

### `TestCheckSystemInstructionsWithMode_StringSystemStrict`

```
func TestCheckSystemInstructionsWithMode_StringSystemStrict(t *testing.T) {
```

**Line:** 1090 | **Kind:** fn

### `TestCheckSystemInstructionsWithMode_EmptyStringSystemIgnored`

```
func TestCheckSystemInstructionsWithMode_EmptyStringSystemIgnored(t *testing.T) {
```

**Line:** 1102 | **Kind:** fn

### `TestCheckSystemInstructionsWithMode_ArraySystemStillWorks`

```
func TestCheckSystemInstructionsWithMode_ArraySystemStillWorks(t *testing.T) {
```

**Line:** 1114 | **Kind:** fn

### `TestCheckSystemInstructionsWithMode_StringWithSpecialChars`

```
func TestCheckSystemInstructionsWithMode_StringWithSpecialChars(t *testing.T) {
```

**Line:** 1129 | **Kind:** fn

