# third_party/CLIProxyAPIPlus/internal/runtime/executor/claude_executor_test.go

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2154
- **Language:** Go
- **Symbols:** 78
- **Public symbols:** 71

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 30 | fn | resetClaudeDeviceProfileCache | (private) | `func resetClaudeDeviceProfileCache() {` |
| 34 | fn | newClaudeHeaderTestRequest | (private) | `func newClaudeHeaderTestRequest(t *testing.T, i...` |
| 48 | fn | assertClaudeFingerprint | (private) | `func assertClaudeFingerprint(t *testing.T, head...` |
| 68 | fn | TestApplyClaudeHeaders_UsesConfiguredBaselineFingerprint | pub | `func TestApplyClaudeHeaders_UsesConfiguredBasel...` |
| 110 | fn | TestApplyClaudeHeaders_StructuredAccountSettingsKeepsManagedHeadersAuthoritative | pub | `func TestApplyClaudeHeaders_StructuredAccountSe...` |
| 160 | fn | TestApplyClaudeHeaders_TracksHighestClaudeCLIFingerprint | pub | `func TestApplyClaudeHeaders_TracksHighestClaude...` |
| 222 | fn | TestApplyClaudeHeaders_DoesNotDowngradeConfiguredBaselineOnFirstClaudeClient | pub | `func TestApplyClaudeHeaders_DoesNotDowngradeCon...` |
| 264 | fn | TestApplyClaudeHeaders_UpgradesCachedSoftwareFingerprintWhenBaselineAdvances | pub | `func TestApplyClaudeHeaders_UpgradesCachedSoftw...` |
| 316 | fn | TestApplyClaudeHeaders_LearnsOfficialFingerprintAfterCustomBaselineFallback | pub | `func TestApplyClaudeHeaders_LearnsOfficialFinge...` |
| 368 | fn | TestResolveClaudeDeviceProfile_RechecksCacheBeforeStoringCandidate | pub | `func TestResolveClaudeDeviceProfile_RechecksCac...` |
| 468 | fn | TestApplyClaudeHeaders_ThirdPartyBaselineThenOfficialUpgradeKeepsPinnedPlatform | pub | `func TestApplyClaudeHeaders_ThirdPartyBaselineT...` |
| 510 | fn | TestApplyClaudeHeaders_DisableDeviceProfileStabilization | pub | `func TestApplyClaudeHeaders_DisableDeviceProfil...` |
| 562 | fn | TestApplyClaudeHeaders_LegacyModePreservesConfiguredUserAgentOverrideForClaudeClients | pub | `func TestApplyClaudeHeaders_LegacyModePreserves...` |
| 594 | fn | TestApplyClaudeHeaders_LegacyModeFallsBackToRuntimeOSArchWhenMissing | pub | `func TestApplyClaudeHeaders_LegacyModeFallsBack...` |
| 623 | fn | TestApplyClaudeHeaders_UnsetStabilizationAlsoUsesLegacyRuntimeOSArchFallback | pub | `func TestApplyClaudeHeaders_UnsetStabilizationA...` |
| 650 | fn | TestClaudeDeviceProfileStabilizationEnabled_DefaultFalse | pub | `func TestClaudeDeviceProfileStabilizationEnable...` |
| 659 | fn | TestApplyClaudeToolPrefix | pub | `func TestApplyClaudeToolPrefix(t *testing.T) {` |
| 677 | fn | TestApplyClaudeToolPrefix_WithToolReference | pub | `func TestApplyClaudeToolPrefix_WithToolReferenc...` |
| 689 | fn | TestApplyClaudeToolPrefix_SkipsBuiltinTools | pub | `func TestApplyClaudeToolPrefix_SkipsBuiltinTool...` |
| 701 | fn | TestApplyClaudeToolPrefix_BuiltinToolSkipped | pub | `func TestApplyClaudeToolPrefix_BuiltinToolSkipp...` |
| 730 | fn | TestApplyClaudeToolPrefix_KnownBuiltinInHistoryOnly | pub | `func TestApplyClaudeToolPrefix_KnownBuiltinInHi...` |
| 751 | fn | TestApplyClaudeToolPrefix_CustomToolsPrefixed | pub | `func TestApplyClaudeToolPrefix_CustomToolsPrefi...` |
| 777 | fn | TestApplyClaudeToolPrefix_ToolChoiceBuiltin | pub | `func TestApplyClaudeToolPrefix_ToolChoiceBuilti...` |
| 792 | fn | TestApplyClaudeToolPrefix_KnownFallbackBuiltinsRemainUnprefixed | pub | `func TestApplyClaudeToolPrefix_KnownFallbackBui...` |
| 821 | fn | TestStripClaudeToolPrefixFromResponse | pub | `func TestStripClaudeToolPrefixFromResponse(t *t...` |
| 833 | fn | TestStripClaudeToolPrefixFromResponse_WithToolReference | pub | `func TestStripClaudeToolPrefixFromResponse_With...` |
| 845 | fn | TestStripClaudeToolPrefixFromStreamLine | pub | `func TestStripClaudeToolPrefixFromStreamLine(t ...` |
| 858 | fn | TestStripClaudeToolPrefixFromStreamLine_WithToolReference | pub | `func TestStripClaudeToolPrefixFromStreamLine_Wi...` |
| 871 | fn | TestApplyClaudeToolPrefix_NestedToolReference | pub | `func TestApplyClaudeToolPrefix_NestedToolRefere...` |
| 880 | fn | TestClaudeExecutor_ReusesUserIDAcrossModelsWhenCacheEnabled | pub | `func TestClaudeExecutor_ReusesUserIDAcrossModel...` |
| 946 | fn | TestClaudeExecutor_GeneratesNewUserIDByDefault | pub | `func TestClaudeExecutor_GeneratesNewUserIDByDef...` |
| 989 | fn | TestStripClaudeToolPrefixFromResponse_NestedToolReference | pub | `func TestStripClaudeToolPrefixFromResponse_Nest...` |
| 998 | fn | TestApplyClaudeToolPrefix_NestedToolReferenceWithStringContent | pub | `func TestApplyClaudeToolPrefix_NestedToolRefere...` |
| 1008 | fn | TestApplyClaudeToolPrefix_SkipsBuiltinToolReference | pub | `func TestApplyClaudeToolPrefix_SkipsBuiltinTool...` |
| 1017 | fn | TestApplyClaudeHeaders_PrefersSavedManagedHeadersOverGinHeaders | pub | `func TestApplyClaudeHeaders_PrefersSavedManaged...` |
| 1064 | fn | TestApplyClaudeHeaders_PreservesClaudeCloakingDefaultsWithoutSavedHeaders | pub | `func TestApplyClaudeHeaders_PreservesClaudeCloa...` |
| 1092 | fn | TestNormalizeCacheControlTTL_DowngradesLaterOneHourBlocks | pub | `func TestNormalizeCacheControlTTL_DowngradesLat...` |
| 1109 | fn | TestNormalizeCacheControlTTL_PreservesOriginalBytesWhenNoChange | pub | `func TestNormalizeCacheControlTTL_PreservesOrig...` |
| 1122 | fn | TestNormalizeCacheControlTTL_PreservesKeyOrderWhenModified | pub | `func TestNormalizeCacheControlTTL_PreservesKeyO...` |
| 1144 | fn | TestEnforceCacheControlLimit_StripsNonLastToolBeforeMessages | pub | `func TestEnforceCacheControlLimit_StripsNonLast...` |
| 1173 | fn | TestEnforceCacheControlLimit_PreservesKeyOrderWhenModified | pub | `func TestEnforceCacheControlLimit_PreservesKeyO...` |
| 1198 | fn | TestEnforceCacheControlLimit_ToolOnlyPayloadStillRespectsLimit | pub | `func TestEnforceCacheControlLimit_ToolOnlyPaylo...` |
| 1222 | fn | TestClaudeExecutor_CountTokens_AppliesCacheControlGuards | pub | `func TestClaudeExecutor_CountTokens_AppliesCach...` |
| 1272 | fn | hasTTLOrderingViolation | (private) | `func hasTTLOrderingViolation(payload []byte) bo...` |
| 1323 | fn | TestClaudeExecutor_Execute_InvalidGzipErrorBodyReturnsDecodeMessage | pub | `func TestClaudeExecutor_Execute_InvalidGzipErro...` |
| 1333 | fn | TestClaudeExecutor_ExecuteStream_InvalidGzipErrorBodyReturnsDecodeMessage | pub | `func TestClaudeExecutor_ExecuteStream_InvalidGz...` |
| 1343 | fn | TestClaudeExecutor_CountTokens_InvalidGzipErrorBodyReturnsDecodeMessage | pub | `func TestClaudeExecutor_CountTokens_InvalidGzip...` |
| 1353 | fn | testClaudeExecutorInvalidCompressedErrorBody | (private) | `func testClaudeExecutorInvalidCompressedErrorBody(` |
| 1386 | fn | TestEnsureModelMaxTokens_UsesRegisteredMaxCompletionTokens | pub | `func TestEnsureModelMaxTokens_UsesRegisteredMax...` |
| 1409 | fn | TestEnsureModelMaxTokens_DefaultsMissingValue | pub | `func TestEnsureModelMaxTokens_DefaultsMissingVa...` |
| 1431 | fn | TestEnsureModelMaxTokens_PreservesExplicitValue | pub | `func TestEnsureModelMaxTokens_PreservesExplicit...` |
| 1454 | fn | TestEnsureModelMaxTokens_SkipsUnregisteredModel | pub | `func TestEnsureModelMaxTokens_SkipsUnregistered...` |
| 1466 | fn | TestClaudeExecutor_ExecuteStream_SetsIdentityAcceptEncoding | pub | `func TestClaudeExecutor_ExecuteStream_SetsIdent...` |
| 1509 | fn | TestClaudeExecutor_Execute_SetsCompressedAcceptEncoding | pub | `func TestClaudeExecutor_Execute_SetsCompressedA...` |
| 1547 | fn | TestClaudeExecutor_ExecuteStream_GzipSuccessBodyDecoded | pub | `func TestClaudeExecutor_ExecuteStream_GzipSucce...` |
| 1596 | fn | TestDecodeResponseBody_MagicByteGzipNoHeader | pub | `func TestDecodeResponseBody_MagicByteGzipNoHead...` |
| 1622 | fn | TestDecodeResponseBody_MagicByteZstdNoHeader | pub | `func TestDecodeResponseBody_MagicByteZstdNoHead...` |
| 1651 | fn | TestDecodeResponseBody_PlainTextNoHeader | pub | `func TestDecodeResponseBody_PlainTextNoHeader(t...` |
| 1673 | fn | TestClaudeExecutor_ExecuteStream_GzipNoContentEncodingHeader | pub | `func TestClaudeExecutor_ExecuteStream_GzipNoCon...` |
| 1724 | fn | TestClaudeExecutor_Execute_GzipErrorBodyNoContentEncodingHeader | pub | `func TestClaudeExecutor_Execute_GzipErrorBodyNo...` |
| 1765 | fn | TestClaudeExecutor_ExecuteStream_GzipErrorBodyNoContentEncodingHeader | pub | `func TestClaudeExecutor_ExecuteStream_GzipError...` |
| 1805 | fn | TestClaudeExecutor_ExecuteStream_AcceptEncodingOverrideCannotBypassIdentity | pub | `func TestClaudeExecutor_ExecuteStream_AcceptEnc...` |
| 1842 | fn | expectedClaudeCodeStaticPrompt | (private) | `func expectedClaudeCodeStaticPrompt() string {` |
| 1852 | fn | expectedForwardedSystemReminder | (private) | `func expectedForwardedSystemReminder(text strin...` |
| 1863 | fn | TestCheckSystemInstructionsWithMode_StringSystemPreserved | pub | `func TestCheckSystemInstructionsWithMode_String...` |
| 1897 | fn | TestCheckSystemInstructionsWithMode_StringSystemStrict | pub | `func TestCheckSystemInstructionsWithMode_String...` |
| 1912 | fn | TestCheckSystemInstructionsWithMode_EmptyStringSystemIgnored | pub | `func TestCheckSystemInstructionsWithMode_EmptyS...` |
| 1927 | fn | TestCheckSystemInstructionsWithMode_ArraySystemStillWorks | pub | `func TestCheckSystemInstructionsWithMode_ArrayS...` |
| 1945 | fn | TestCheckSystemInstructionsWithMode_StringWithSpecialChars | pub | `func TestCheckSystemInstructionsWithMode_String...` |
| 1959 | fn | TestClaudeExecutor_ExperimentalCCHSigningDisabledByDefaultKeepsLegacyHeader | pub | `func TestClaudeExecutor_ExperimentalCCHSigningD...` |
| 1996 | fn | TestClaudeExecutor_ExperimentalCCHSigningOptInSignsFinalBody | pub | `func TestClaudeExecutor_ExperimentalCCHSigningO...` |
| 2047 | fn | TestApplyCloaking_PreservesConfiguredStrictModeAndSensitiveWordsWhenModeOmitted | pub | `func TestApplyCloaking_PreservesConfiguredStric...` |
| 2074 | fn | TestNormalizeClaudeTemperatureForThinking_AdaptiveCoercesToOne | pub | `func TestNormalizeClaudeTemperatureForThinking_...` |
| 2083 | fn | TestNormalizeClaudeTemperatureForThinking_EnabledCoercesToOne | pub | `func TestNormalizeClaudeTemperatureForThinking_...` |
| 2092 | fn | TestNormalizeClaudeTemperatureForThinking_NoThinkingLeavesTemperatureAlone | pub | `func TestNormalizeClaudeTemperatureForThinking_...` |
| 2101 | fn | TestNormalizeClaudeTemperatureForThinking_AfterForcedToolChoiceKeepsOriginalTemperature | pub | `func TestNormalizeClaudeTemperatureForThinking_...` |
| 2114 | fn | TestRemapOAuthToolNames_TitleCase_NoReverseNeeded | pub | `func TestRemapOAuthToolNames_TitleCase_NoRevers...` |
| 2135 | fn | TestRemapOAuthToolNames_Lowercase_ReverseApplied | pub | `func TestRemapOAuthToolNames_Lowercase_ReverseA...` |

## Public API

### `TestApplyClaudeHeaders_UsesConfiguredBaselineFingerprint`

```
func TestApplyClaudeHeaders_UsesConfiguredBaselineFingerprint(t *testing.T) {
```

**Line:** 68 | **Kind:** fn

### `TestApplyClaudeHeaders_StructuredAccountSettingsKeepsManagedHeadersAuthoritative`

```
func TestApplyClaudeHeaders_StructuredAccountSettingsKeepsManagedHeadersAuthoritative(t *testing.T) {
```

**Line:** 110 | **Kind:** fn

### `TestApplyClaudeHeaders_TracksHighestClaudeCLIFingerprint`

```
func TestApplyClaudeHeaders_TracksHighestClaudeCLIFingerprint(t *testing.T) {
```

**Line:** 160 | **Kind:** fn

### `TestApplyClaudeHeaders_DoesNotDowngradeConfiguredBaselineOnFirstClaudeClient`

```
func TestApplyClaudeHeaders_DoesNotDowngradeConfiguredBaselineOnFirstClaudeClient(t *testing.T) {
```

**Line:** 222 | **Kind:** fn

### `TestApplyClaudeHeaders_UpgradesCachedSoftwareFingerprintWhenBaselineAdvances`

```
func TestApplyClaudeHeaders_UpgradesCachedSoftwareFingerprintWhenBaselineAdvances(t *testing.T) {
```

**Line:** 264 | **Kind:** fn

### `TestApplyClaudeHeaders_LearnsOfficialFingerprintAfterCustomBaselineFallback`

```
func TestApplyClaudeHeaders_LearnsOfficialFingerprintAfterCustomBaselineFallback(t *testing.T) {
```

**Line:** 316 | **Kind:** fn

### `TestResolveClaudeDeviceProfile_RechecksCacheBeforeStoringCandidate`

```
func TestResolveClaudeDeviceProfile_RechecksCacheBeforeStoringCandidate(t *testing.T) {
```

**Line:** 368 | **Kind:** fn

### `TestApplyClaudeHeaders_ThirdPartyBaselineThenOfficialUpgradeKeepsPinnedPlatform`

```
func TestApplyClaudeHeaders_ThirdPartyBaselineThenOfficialUpgradeKeepsPinnedPlatform(t *testing.T) {
```

**Line:** 468 | **Kind:** fn

### `TestApplyClaudeHeaders_DisableDeviceProfileStabilization`

```
func TestApplyClaudeHeaders_DisableDeviceProfileStabilization(t *testing.T) {
```

**Line:** 510 | **Kind:** fn

### `TestApplyClaudeHeaders_LegacyModePreservesConfiguredUserAgentOverrideForClaudeClients`

```
func TestApplyClaudeHeaders_LegacyModePreservesConfiguredUserAgentOverrideForClaudeClients(t *testing.T) {
```

**Line:** 562 | **Kind:** fn

### `TestApplyClaudeHeaders_LegacyModeFallsBackToRuntimeOSArchWhenMissing`

```
func TestApplyClaudeHeaders_LegacyModeFallsBackToRuntimeOSArchWhenMissing(t *testing.T) {
```

**Line:** 594 | **Kind:** fn

### `TestApplyClaudeHeaders_UnsetStabilizationAlsoUsesLegacyRuntimeOSArchFallback`

```
func TestApplyClaudeHeaders_UnsetStabilizationAlsoUsesLegacyRuntimeOSArchFallback(t *testing.T) {
```

**Line:** 623 | **Kind:** fn

### `TestClaudeDeviceProfileStabilizationEnabled_DefaultFalse`

```
func TestClaudeDeviceProfileStabilizationEnabled_DefaultFalse(t *testing.T) {
```

**Line:** 650 | **Kind:** fn

### `TestApplyClaudeToolPrefix`

```
func TestApplyClaudeToolPrefix(t *testing.T) {
```

**Line:** 659 | **Kind:** fn

### `TestApplyClaudeToolPrefix_WithToolReference`

```
func TestApplyClaudeToolPrefix_WithToolReference(t *testing.T) {
```

**Line:** 677 | **Kind:** fn

### `TestApplyClaudeToolPrefix_SkipsBuiltinTools`

```
func TestApplyClaudeToolPrefix_SkipsBuiltinTools(t *testing.T) {
```

**Line:** 689 | **Kind:** fn

### `TestApplyClaudeToolPrefix_BuiltinToolSkipped`

```
func TestApplyClaudeToolPrefix_BuiltinToolSkipped(t *testing.T) {
```

**Line:** 701 | **Kind:** fn

### `TestApplyClaudeToolPrefix_KnownBuiltinInHistoryOnly`

```
func TestApplyClaudeToolPrefix_KnownBuiltinInHistoryOnly(t *testing.T) {
```

**Line:** 730 | **Kind:** fn

### `TestApplyClaudeToolPrefix_CustomToolsPrefixed`

```
func TestApplyClaudeToolPrefix_CustomToolsPrefixed(t *testing.T) {
```

**Line:** 751 | **Kind:** fn

### `TestApplyClaudeToolPrefix_ToolChoiceBuiltin`

```
func TestApplyClaudeToolPrefix_ToolChoiceBuiltin(t *testing.T) {
```

**Line:** 777 | **Kind:** fn

### `TestApplyClaudeToolPrefix_KnownFallbackBuiltinsRemainUnprefixed`

```
func TestApplyClaudeToolPrefix_KnownFallbackBuiltinsRemainUnprefixed(t *testing.T) {
```

**Line:** 792 | **Kind:** fn

### `TestStripClaudeToolPrefixFromResponse`

```
func TestStripClaudeToolPrefixFromResponse(t *testing.T) {
```

**Line:** 821 | **Kind:** fn

### `TestStripClaudeToolPrefixFromResponse_WithToolReference`

```
func TestStripClaudeToolPrefixFromResponse_WithToolReference(t *testing.T) {
```

**Line:** 833 | **Kind:** fn

### `TestStripClaudeToolPrefixFromStreamLine`

```
func TestStripClaudeToolPrefixFromStreamLine(t *testing.T) {
```

**Line:** 845 | **Kind:** fn

### `TestStripClaudeToolPrefixFromStreamLine_WithToolReference`

```
func TestStripClaudeToolPrefixFromStreamLine_WithToolReference(t *testing.T) {
```

**Line:** 858 | **Kind:** fn

### `TestApplyClaudeToolPrefix_NestedToolReference`

```
func TestApplyClaudeToolPrefix_NestedToolReference(t *testing.T) {
```

**Line:** 871 | **Kind:** fn

### `TestClaudeExecutor_ReusesUserIDAcrossModelsWhenCacheEnabled`

```
func TestClaudeExecutor_ReusesUserIDAcrossModelsWhenCacheEnabled(t *testing.T) {
```

**Line:** 880 | **Kind:** fn

### `TestClaudeExecutor_GeneratesNewUserIDByDefault`

```
func TestClaudeExecutor_GeneratesNewUserIDByDefault(t *testing.T) {
```

**Line:** 946 | **Kind:** fn

### `TestStripClaudeToolPrefixFromResponse_NestedToolReference`

```
func TestStripClaudeToolPrefixFromResponse_NestedToolReference(t *testing.T) {
```

**Line:** 989 | **Kind:** fn

### `TestApplyClaudeToolPrefix_NestedToolReferenceWithStringContent`

```
func TestApplyClaudeToolPrefix_NestedToolReferenceWithStringContent(t *testing.T) {
```

**Line:** 998 | **Kind:** fn

### `TestApplyClaudeToolPrefix_SkipsBuiltinToolReference`

```
func TestApplyClaudeToolPrefix_SkipsBuiltinToolReference(t *testing.T) {
```

**Line:** 1008 | **Kind:** fn

### `TestApplyClaudeHeaders_PrefersSavedManagedHeadersOverGinHeaders`

```
func TestApplyClaudeHeaders_PrefersSavedManagedHeadersOverGinHeaders(t *testing.T) {
```

**Line:** 1017 | **Kind:** fn

### `TestApplyClaudeHeaders_PreservesClaudeCloakingDefaultsWithoutSavedHeaders`

```
func TestApplyClaudeHeaders_PreservesClaudeCloakingDefaultsWithoutSavedHeaders(t *testing.T) {
```

**Line:** 1064 | **Kind:** fn

### `TestNormalizeCacheControlTTL_DowngradesLaterOneHourBlocks`

```
func TestNormalizeCacheControlTTL_DowngradesLaterOneHourBlocks(t *testing.T) {
```

**Line:** 1092 | **Kind:** fn

### `TestNormalizeCacheControlTTL_PreservesOriginalBytesWhenNoChange`

```
func TestNormalizeCacheControlTTL_PreservesOriginalBytesWhenNoChange(t *testing.T) {
```

**Line:** 1109 | **Kind:** fn

### `TestNormalizeCacheControlTTL_PreservesKeyOrderWhenModified`

```
func TestNormalizeCacheControlTTL_PreservesKeyOrderWhenModified(t *testing.T) {
```

**Line:** 1122 | **Kind:** fn

### `TestEnforceCacheControlLimit_StripsNonLastToolBeforeMessages`

```
func TestEnforceCacheControlLimit_StripsNonLastToolBeforeMessages(t *testing.T) {
```

**Line:** 1144 | **Kind:** fn

### `TestEnforceCacheControlLimit_PreservesKeyOrderWhenModified`

```
func TestEnforceCacheControlLimit_PreservesKeyOrderWhenModified(t *testing.T) {
```

**Line:** 1173 | **Kind:** fn

### `TestEnforceCacheControlLimit_ToolOnlyPayloadStillRespectsLimit`

```
func TestEnforceCacheControlLimit_ToolOnlyPayloadStillRespectsLimit(t *testing.T) {
```

**Line:** 1198 | **Kind:** fn

### `TestClaudeExecutor_CountTokens_AppliesCacheControlGuards`

```
func TestClaudeExecutor_CountTokens_AppliesCacheControlGuards(t *testing.T) {
```

**Line:** 1222 | **Kind:** fn

### `TestClaudeExecutor_Execute_InvalidGzipErrorBodyReturnsDecodeMessage`

```
func TestClaudeExecutor_Execute_InvalidGzipErrorBodyReturnsDecodeMessage(t *testing.T) {
```

**Line:** 1323 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_InvalidGzipErrorBodyReturnsDecodeMessage`

```
func TestClaudeExecutor_ExecuteStream_InvalidGzipErrorBodyReturnsDecodeMessage(t *testing.T) {
```

**Line:** 1333 | **Kind:** fn

### `TestClaudeExecutor_CountTokens_InvalidGzipErrorBodyReturnsDecodeMessage`

```
func TestClaudeExecutor_CountTokens_InvalidGzipErrorBodyReturnsDecodeMessage(t *testing.T) {
```

**Line:** 1343 | **Kind:** fn

### `TestEnsureModelMaxTokens_UsesRegisteredMaxCompletionTokens`

```
func TestEnsureModelMaxTokens_UsesRegisteredMaxCompletionTokens(t *testing.T) {
```

**Line:** 1386 | **Kind:** fn

### `TestEnsureModelMaxTokens_DefaultsMissingValue`

```
func TestEnsureModelMaxTokens_DefaultsMissingValue(t *testing.T) {
```

**Line:** 1409 | **Kind:** fn

### `TestEnsureModelMaxTokens_PreservesExplicitValue`

```
func TestEnsureModelMaxTokens_PreservesExplicitValue(t *testing.T) {
```

**Line:** 1431 | **Kind:** fn

### `TestEnsureModelMaxTokens_SkipsUnregisteredModel`

```
func TestEnsureModelMaxTokens_SkipsUnregisteredModel(t *testing.T) {
```

**Line:** 1454 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_SetsIdentityAcceptEncoding`

```
func TestClaudeExecutor_ExecuteStream_SetsIdentityAcceptEncoding(t *testing.T) {
```

**Line:** 1466 | **Kind:** fn

### `TestClaudeExecutor_Execute_SetsCompressedAcceptEncoding`

```
func TestClaudeExecutor_Execute_SetsCompressedAcceptEncoding(t *testing.T) {
```

**Line:** 1509 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_GzipSuccessBodyDecoded`

```
func TestClaudeExecutor_ExecuteStream_GzipSuccessBodyDecoded(t *testing.T) {
```

**Line:** 1547 | **Kind:** fn

### `TestDecodeResponseBody_MagicByteGzipNoHeader`

```
func TestDecodeResponseBody_MagicByteGzipNoHeader(t *testing.T) {
```

**Line:** 1596 | **Kind:** fn

### `TestDecodeResponseBody_MagicByteZstdNoHeader`

```
func TestDecodeResponseBody_MagicByteZstdNoHeader(t *testing.T) {
```

**Line:** 1622 | **Kind:** fn

### `TestDecodeResponseBody_PlainTextNoHeader`

```
func TestDecodeResponseBody_PlainTextNoHeader(t *testing.T) {
```

**Line:** 1651 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_GzipNoContentEncodingHeader`

```
func TestClaudeExecutor_ExecuteStream_GzipNoContentEncodingHeader(t *testing.T) {
```

**Line:** 1673 | **Kind:** fn

### `TestClaudeExecutor_Execute_GzipErrorBodyNoContentEncodingHeader`

```
func TestClaudeExecutor_Execute_GzipErrorBodyNoContentEncodingHeader(t *testing.T) {
```

**Line:** 1724 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_GzipErrorBodyNoContentEncodingHeader`

```
func TestClaudeExecutor_ExecuteStream_GzipErrorBodyNoContentEncodingHeader(t *testing.T) {
```

**Line:** 1765 | **Kind:** fn

### `TestClaudeExecutor_ExecuteStream_AcceptEncodingOverrideCannotBypassIdentity`

```
func TestClaudeExecutor_ExecuteStream_AcceptEncodingOverrideCannotBypassIdentity(t *testing.T) {
```

**Line:** 1805 | **Kind:** fn

### `TestCheckSystemInstructionsWithMode_StringSystemPreserved`

```
func TestCheckSystemInstructionsWithMode_StringSystemPreserved(t *testing.T) {
```

**Line:** 1863 | **Kind:** fn

### `TestCheckSystemInstructionsWithMode_StringSystemStrict`

```
func TestCheckSystemInstructionsWithMode_StringSystemStrict(t *testing.T) {
```

**Line:** 1897 | **Kind:** fn

### `TestCheckSystemInstructionsWithMode_EmptyStringSystemIgnored`

```
func TestCheckSystemInstructionsWithMode_EmptyStringSystemIgnored(t *testing.T) {
```

**Line:** 1912 | **Kind:** fn

### `TestCheckSystemInstructionsWithMode_ArraySystemStillWorks`

```
func TestCheckSystemInstructionsWithMode_ArraySystemStillWorks(t *testing.T) {
```

**Line:** 1927 | **Kind:** fn

### `TestCheckSystemInstructionsWithMode_StringWithSpecialChars`

```
func TestCheckSystemInstructionsWithMode_StringWithSpecialChars(t *testing.T) {
```

**Line:** 1945 | **Kind:** fn

### `TestClaudeExecutor_ExperimentalCCHSigningDisabledByDefaultKeepsLegacyHeader`

```
func TestClaudeExecutor_ExperimentalCCHSigningDisabledByDefaultKeepsLegacyHeader(t *testing.T) {
```

**Line:** 1959 | **Kind:** fn

### `TestClaudeExecutor_ExperimentalCCHSigningOptInSignsFinalBody`

```
func TestClaudeExecutor_ExperimentalCCHSigningOptInSignsFinalBody(t *testing.T) {
```

**Line:** 1996 | **Kind:** fn

### `TestApplyCloaking_PreservesConfiguredStrictModeAndSensitiveWordsWhenModeOmitted`

```
func TestApplyCloaking_PreservesConfiguredStrictModeAndSensitiveWordsWhenModeOmitted(t *testing.T) {
```

**Line:** 2047 | **Kind:** fn

### `TestNormalizeClaudeTemperatureForThinking_AdaptiveCoercesToOne`

```
func TestNormalizeClaudeTemperatureForThinking_AdaptiveCoercesToOne(t *testing.T) {
```

**Line:** 2074 | **Kind:** fn

### `TestNormalizeClaudeTemperatureForThinking_EnabledCoercesToOne`

```
func TestNormalizeClaudeTemperatureForThinking_EnabledCoercesToOne(t *testing.T) {
```

**Line:** 2083 | **Kind:** fn

### `TestNormalizeClaudeTemperatureForThinking_NoThinkingLeavesTemperatureAlone`

```
func TestNormalizeClaudeTemperatureForThinking_NoThinkingLeavesTemperatureAlone(t *testing.T) {
```

**Line:** 2092 | **Kind:** fn

### `TestNormalizeClaudeTemperatureForThinking_AfterForcedToolChoiceKeepsOriginalTemperature`

```
func TestNormalizeClaudeTemperatureForThinking_AfterForcedToolChoiceKeepsOriginalTemperature(t *testing.T) {
```

**Line:** 2101 | **Kind:** fn

### `TestRemapOAuthToolNames_TitleCase_NoReverseNeeded`

```
func TestRemapOAuthToolNames_TitleCase_NoReverseNeeded(t *testing.T) {
```

**Line:** 2114 | **Kind:** fn

### `TestRemapOAuthToolNames_Lowercase_ReverseApplied`

```
func TestRemapOAuthToolNames_Lowercase_ReverseApplied(t *testing.T) {
```

**Line:** 2135 | **Kind:** fn

