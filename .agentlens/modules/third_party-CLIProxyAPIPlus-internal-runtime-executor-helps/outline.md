# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 6 large files in this module.

## third_party/CLIProxyAPIPlus/internal/runtime/executor/helps/codex_client_profile.go (572 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 33 | struct | codexVersionMarker | (private) |
| 39 | struct | CodexClientProfile | pub |
| 52 | struct | codexClientProfileCacheEntry | (private) |
| 57 | fn | DefaultCodexManagedOriginator | pub |
| 61 | fn | DefaultCodexManagedVersion | pub |
| 65 | fn | DefaultCodexManagedUserAgent | pub |
| 74 | fn | ResolveCodexClientProfile | pub |
| 131 | fn | CodexManagedHeaders | pub |
| 145 | fn | CodexManagedVersionedCapabilities | pub |
| 153 | fn | CodexManagedStableIdentity | pub |
| 159 | fn | CodexManagedRuntimeFingerprint | pub |
| 166 | fn | codexClientProfileFromAuth | (private) |
| 199 | fn | defaultCodexClientProfile | (private) |
| 234 | fn | normalizeCodexClientProfile | (private) |
| 295 | fn | alignCodexFirstPartyIdentity | (private) |
| 308 | fn | alignCodexTailIdentity | (private) |
| 327 | fn | bumpCodexVersionMarkers | (private) |
| 352 | fn | bumpCodexTailVersionMarker | (private) |
| 371 | fn | extractCodexClientProfile | (private) |
| 410 | fn | cfgCodexBetaFeatures | (private) |
| 417 | fn | parseCodexUserAgent | (private) |
| 441 | fn | buildCodexUserAgent | (private) |
| 452 | fn | isFirstPartyCodexOriginator | (private) |
| 465 | fn | parseCodexVersion | (private) |
| 489 | fn | Compare | pub |
| 522 | fn | codexClientProfileCacheKey | (private) |
| 538 | fn | startCodexClientProfileCacheCleanup | (private) |
| 555 | fn | normalizeHeaderMap | (private) |

## third_party/CLIProxyAPIPlus/internal/runtime/executor/helps/logging_helpers.go (592 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 31 | struct | UpstreamRequestLog | pub |
| 43 | struct | upstreamAttempt | (private) |
| 57 | fn | RecordAPIRequest | pub |
| 104 | fn | RecordAPIResponseMetadata | pub |
| 130 | fn | RecordAPIResponseError | pub |
| 155 | fn | AppendAPIResponseChunk | pub |
| 197 | fn | RecordAPIWebsocketRequest | pub |
| 229 | fn | RecordAPIWebsocketHandshake | pub |
| 252 | fn | RecordAPIWebsocketUpgradeRejection | pub |
| 267 | fn | WebsocketUpgradeRequestURL | pub |
| 286 | fn | AppendAPIWebsocketResponse | pub |
| 310 | fn | RecordAPIWebsocketError | pub |
| 331 | fn | ginContextFrom | (private) |
| 336 | fn | getAttempts | (private) |
| 348 | fn | ensureAttempt | (private) |
| 363 | fn | ensureResponseIntro | (private) |
| 373 | fn | updateAggregatedRequest | (private) |
| 384 | fn | updateAggregatedResponse | (private) |
| 408 | fn | appendAPIWebsocketTimeline | (private) |
| 432 | fn | markAPIResponseTimestamp | (private) |
| 442 | fn | writeHeaders | (private) |
| 468 | fn | formatAuthInfo | (private) |
| 504 | fn | SummarizeErrorBody | pub |
| 527 | fn | extractHTMLTitle | (private) |
| 552 | fn | extractJSONErrorMessage | (private) |
| 562 | fn | LogWithRequestID | pub |
| 574 | fn | MarkCreditsUsed | pub |
| 582 | fn | CreditsUsed | pub |

## third_party/CLIProxyAPIPlus/internal/runtime/executor/helps/tls_evidence_capture.go (845 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 31 | struct | SyntheticProviderSNIEvidence | pub |
| 51 | struct | ClientHelloEvidence | pub |
| 66 | struct | FingerprintEvidence | pub |
| 73 | struct | ALPNEvidence | pub |
| 78 | struct | HTTP2SettingsEvidence | pub |
| 85 | struct | HTTP2Setting | pub |
| 91 | fn | CaptureSyntheticProviderSNIEvidence | pub |
| 186 | fn | BuildTLSEvidenceProbeRoundTripperForLocalAddress | pub |
| 231 | struct | localAddrDialer | (private) |
| 235 | fn | Dial | pub |
| 241 | struct | localCaptureResult | (private) |
| 248 | fn | serveLocalTLSEvidenceCapture | (private) |
| 293 | fn | serveHTTP2Capture | (private) |
| 319 | fn | serveHTTP1Once | (private) |
| 329 | struct | bufferedConn | (private) |
| 334 | fn | Read | pub |
| 338 | struct | plaintextCaptureConn | (private) |
| 343 | fn | Read | pub |
| 351 | struct | http2SettingsCapture | (private) |
| 358 | fn | feed | (private) |
| 397 | fn | evidence | (private) |
| 410 | fn | http2SettingName | (private) |
| 431 | fn | peekClientHello | (private) |
| 447 | fn | parseClientHello | (private) |
| 544 | fn | parseSNIExtension | (private) |
| 569 | fn | parseALPNExtension | (private) |
| 592 | fn | parseSupportedVersions | (private) |
| 607 | fn | parseUint16Vector | (private) |
| 628 | fn | parseUint8Vector | (private) |
| 639 | fn | buildJA3Evidence | (private) |
| 655 | fn | buildJA4Evidence | (private) |
| 679 | fn | ja3Version | (private) |
| 683 | fn | ja3Values | (private) |
| 688 | fn | hexStringsToDecimalStrings | (private) |
| 704 | fn | ja4Version | (private) |
| 719 | fn | ja4ALPN | (private) |
| 738 | fn | tlsVersionNumber | (private) |
| 753 | fn | highestTLSVersionString | (private) |
| 769 | fn | tlsVersionString | (private) |
| 784 | fn | uint16HexStringsWithoutGREASE | (private) |
| 795 | fn | uint8HexStrings | (private) |
| 803 | fn | isGREASE | (private) |
| 807 | fn | shortSHA256 | (private) |
| 812 | fn | sha256HexLocal | (private) |
| 817 | fn | selfSignedCertificate | (private) |
| 843 | fn | MarshalSyntheticProviderSNIEvidence | pub |

## third_party/CLIProxyAPIPlus/internal/runtime/executor/helps/transport_profile.go (688 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 18 | struct | RuntimeTransportProfile | pub |
| 35 | struct | runtimeTransportHostContextKey | (private) |
| 37 | fn | WithRuntimeTransportHost | pub |
| 48 | fn | WithRuntimeTransportHostFromRequest | pub |
| 58 | fn | RuntimeTransportHostFromContext | pub |
| 68 | fn | ResolveRuntimeTransportProfile | pub |
| 151 | fn | coreManagedRuntimeTransportProfile | (private) |
| 177 | fn | normalizeCoreManagedRuntimeProvider | (private) |
| 186 | fn | canonicalRuntimeProfileID | (private) |
| 194 | fn | canonicalClaudeRuntimeProfileID | (private) |
| 203 | fn | codexTLSProfileForcesHTTP11 | (private) |
| 208 | fn | IsRuntimeTransportProfileEnforced | pub |
| 213 | fn | IsRuntimeTLSProfileEnforced | pub |
| 218 | fn | IsRuntimeProfileEnforced | pub |
| 223 | fn | RuntimeTransportProfileStatus | pub |
| 238 | fn | RuntimeTransportProfileCacheKey | pub |
| 242 | fn | RuntimeTransportProfileCacheKeyForHost | pub |
| 270 | fn | RuntimeTransportProfileToken | pub |
| 278 | fn | BuildRuntimeTransportRoundTripper | pub |
| 309 | fn | SupportsRuntime | pub |
| 313 | fn | SupportsTransportRuntime | pub |
| 367 | fn | SupportsTLSRuntime | pub |
| 415 | fn | isCLINativeProfile | (private) |
| 433 | fn | cacheToken | (private) |
| 442 | fn | runtimeTransportStatus | (private) |
| 469 | fn | runtimeTLSStatus | (private) |
| 496 | fn | runtimeTransportAccountKey | (private) |
| 518 | fn | runtimeTransportBaseURLHost | (private) |
| 540 | fn | normalizeRuntimeTransportBaseURLHost | (private) |
| 555 | fn | NewCodexTransportRoundTripperForProfile | pub |
| 587 | fn | normalizeBool | (private) |
| 607 | fn | containsStringFold | (private) |
| 616 | fn | normalizeObject | (private) |
| 648 | fn | firstNonEmptyString | (private) |
| 659 | fn | normalizeStringSlice | (private) |

## third_party/CLIProxyAPIPlus/internal/runtime/executor/helps/transport_profile_test.go (679 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 12 | fn | TestIsRuntimeTransportProfileEnforced_ClaudePreset | pub |
| 30 | fn | TestIsRuntimeTransportProfileEnforced_CodexPreset | pub |
| 49 | fn | TestIsRuntimeTLSProfileEnforced_ClaudePreset | pub |
| 77 | fn | TestRuntimeTransportProfile_ClaudeChrome133AliasesCanonicalize | pub |
| 117 | fn | TestRuntimeTransportProfile_ClaudeProviderDefaultDoesNotOptIntoChromeLikeUTLS | pub |
| 158 | fn | TestRuntimeTransportProfile_CoreManagedAccountIdentityForEmptyCLIProvider | pub |
| 195 | fn | TestRuntimeTransportProfile_CoreManagedCacheKeyIsAccountIsolated | pub |
| 224 | fn | TestResolveClaudeClientHelloID_DoesNotTreatProviderDefaultAsChrome | pub |
| 235 | fn | TestIsRuntimeTLSProfileEnforced_CodexHTTP11Preset | pub |
| 274 | fn | TestRuntimeTLSProfile_CodexH2PresetDoesNotForceHTTP11 | pub |
| 311 | fn | TestRuntimeTLSProfile_ClaudePresetDoesNotForceHTTP11 | pub |
| 336 | fn | TestRuntimeTransportProfileCacheKey_IncludesAuthAndProfile | pub |
| 362 | fn | TestRuntimeTransportProfileCacheKey_IncludesAccount | pub |
| 398 | fn | TestRuntimeTransportProfileCacheKey_IncludesBaseURLHost | pub |
| 428 | fn | TestRuntimeTransportProfileCacheKey_IncludesTLSProfile | pub |
| 456 | fn | TestRuntimeTransportProfileRejectsProviderMismatch | pub |
| 496 | fn | TestNewProxyAwareHTTPClient_IsolatesSameProxyDifferentAccount | pub |
| 539 | fn | TestRuntimeTransportProfileStatus_ProviderSpecificPresets | pub |
| 591 | fn | TestRuntimeTransportProfileStatus_UnknownProfileFallsBack | pub |
| 615 | fn | TestNewProxyAwareHTTPClient_UsesProfileScopedTransportCache | pub |
| 649 | fn | TestNewProxyAwareHTTPClient_UsesCodexProfileScopedTransportCache | pub |

## third_party/CLIProxyAPIPlus/internal/runtime/executor/helps/usage_helpers.go (616 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 18 | struct | usageReporter | (private) |
| 29 | fn | newUsageReporter | (private) |
| 45 | fn | publish | (private) |
| 49 | fn | publishFailure | (private) |
| 53 | fn | trackFailure | (private) |
| 62 | fn | publishWithOutcome | (private) |
| 81 | fn | ensurePublished | (private) |
| 90 | fn | buildRecord | (private) |
| 108 | fn | latency | (private) |
| 119 | fn | apiKeyFromContext | (private) |
| 140 | fn | resolveUsageSource | (private) |
| 184 | fn | parseCodexUsage | (private) |
| 204 | fn | parseOpenAIUsage | (private) |
| 240 | fn | parseOpenAIStreamUsage | (private) |
| 264 | fn | parseOpenAIResponsesUsageDetail | (private) |
| 283 | fn | parseOpenAIResponsesUsage | (private) |
| 291 | fn | parseOpenAIResponsesStreamUsage | (private) |
| 303 | fn | parseClaudeUsage | (private) |
| 322 | fn | parseClaudeStreamUsage | (private) |
| 345 | fn | parseGeminiFamilyUsageDetail | (private) |
| 360 | fn | parseGeminiCLIUsage | (private) |
| 372 | fn | parseGeminiUsage | (private) |
| 384 | fn | parseGeminiStreamUsage | (private) |
| 399 | fn | parseGeminiCLIStreamUsage | (private) |
| 414 | fn | parseAntigravityUsage | (private) |
| 429 | fn | parseAntigravityStreamUsage | (private) |
| 449 | fn | rememberStopWithoutUsage | (private) |
| 457 | fn | FilterSSEUsageMetadata | pub |
| 521 | fn | StripUsageMetadataFromJSON | pub |
| 570 | fn | hasUsageMetadata | (private) |
| 583 | fn | isStopChunkWithoutUsage | (private) |
| 598 | fn | jsonPayload | (private) |

