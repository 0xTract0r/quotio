# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 7 large files in this module.

## third_party/CLIProxyAPIPlus/internal/auth/kiro/aws.go (681 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 20 | struct | PKCECodes | pub |
| 29 | struct | KiroTokenData | pub |
| 58 | struct | KiroAuthBundle | pub |
| 66 | struct | KiroUsageInfo | pub |
| 78 | struct | KiroModel | pub |
| 94 | const | KiroIDETokenFile | pub |
| 104 | fn | isTransientFileError | (private) |
| 145 | fn | LoadKiroIDETokenWithRetry | pub |
| 180 | fn | LoadKiroIDEToken | pub |
| 218 | fn | loadDeviceRegistration | (private) |
| 259 | fn | LoadKiroTokenFromPath | pub |
| 300 | fn | ListKiroTokenFiles | pub |
| 335 | fn | LoadAllKiroTokens | pub |
| 356 | struct | JWTClaims | pub |
| 367 | fn | ExtractEmailFromJWT | pub |
| 424 | fn | SanitizeEmailForFilename | pub |
| 468 | fn | ExtractIDCIdentifier | pub |
| 497 | fn | GenerateTokenFileName | pub |
| 528 | const | DefaultKiroRegion | pub |
| 533 | fn | GetCodeWhispererLegacyEndpoint | pub |
| 543 | struct | ProfileARN | pub |
| 562 | fn | ParseProfileARN | pub |
| 620 | fn | GetKiroAPIEndpoint | pub |
| 629 | fn | GetKiroAPIEndpointFromProfileArn | pub |
| 636 | fn | ExtractRegionFromProfileArn | pub |
| 646 | fn | ExtractRegionFromMetadata | pub |
| 666 | fn | buildURL | (private) |

## third_party/CLIProxyAPIPlus/internal/auth/kiro/aws_test.go (751 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 10 | fn | TestExtractEmailFromJWT | pub |
| 63 | fn | TestSanitizeEmailForFilename | pub |
| 153 | fn | createTestJWT | (private) |
| 164 | fn | TestExtractIDCIdentifier | pub |
| 217 | fn | TestGenerateTokenFileName | pub |
| 321 | fn | TestParseProfileARN | pub |
| 480 | fn | TestExtractRegionFromProfileArn | pub |
| 528 | fn | TestGetKiroAPIEndpoint | pub |
| 576 | fn | TestGetKiroAPIEndpointFromProfileArn | pub |
| 619 | fn | TestGetCodeWhispererLegacyEndpoint | pub |
| 657 | fn | TestExtractRegionFromMetadata | pub |

## third_party/CLIProxyAPIPlus/internal/auth/kiro/fingerprint_test.go (778 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 11 | fn | TestNewFingerprintManager | pub |
| 24 | fn | TestGetFingerprint_NewToken | pub |
| 57 | fn | TestGetFingerprint_SameTokenReturnsSameFingerprint | pub |
| 67 | fn | TestGetFingerprint_DifferentTokens | pub |
| 77 | fn | TestBuildUserAgent | pub |
| 92 | fn | TestGetFingerprint_OSVersionMatchesOSType | pub |
| 111 | fn | TestGenerateFromConfig_OSTypeFromRuntimeGOOS | pub |
| 138 | fn | TestFingerprintManager_ConcurrentAccess | pub |
| 166 | fn | TestKiroHashStability | pub |
| 183 | fn | TestKiroHashFormat | pub |
| 198 | fn | TestGlobalFingerprintManager | pub |
| 210 | fn | TestSetOIDCHeaders | pub |
| 245 | fn | TestBuildURL | pub |
| 324 | fn | TestBuildUserAgentFormat | pub |
| 346 | fn | TestBuildAmzUserAgentFormat | pub |
| 368 | fn | TestSetRuntimeHeaders | pub |
| 425 | fn | TestSDKVersionsAreValid | pub |
| 452 | fn | TestKiroVersionsAreValid | pub |
| 465 | fn | TestNodeVersionsAreValid | pub |
| 479 | fn | TestFingerprintManager_SetConfig | pub |
| 529 | fn | TestFingerprintManager_SetConfig_PartialFields | pub |
| 562 | fn | TestFingerprintManager_SetConfig_ClearsCache | pub |
| 585 | fn | TestGenerateAccountKey | pub |
| 648 | fn | TestGetAccountKey | pub |
| 724 | fn | TestGetAccountKey_Deterministic | pub |
| 743 | fn | TestFingerprintDeterministic | pub |

## third_party/CLIProxyAPIPlus/internal/auth/kiro/oauth_web.go (975 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 37 | struct | webAuthSession | (private) |
| 62 | struct | OAuthWebHandler | pub |
| 69 | fn | NewOAuthWebHandler | pub |
| 76 | fn | SetTokenCallback | pub |
| 80 | fn | RegisterRoutes | pub |
| 93 | fn | generateStateID | (private) |
| 101 | fn | handleSelect | (private) |
| 105 | fn | handleStart | (private) |
| 127 | fn | startSocialAuth | (private) |
| 184 | fn | getSocialCallbackURL | (private) |
| 192 | fn | startBuilderIDAuth | (private) |
| 254 | fn | startIDCAuth | (private) |
| 324 | fn | pollForToken | (private) |
| 420 | fn | saveTokenToFile | (private) |
| 477 | fn | ssoClient | (private) |
| 481 | fn | handleCallback | (private) |
| 513 | fn | handleSocialCallback | (private) |
| 616 | fn | handleStatus | (private) |
| 655 | fn | renderStartPage | (private) |
| 676 | fn | renderSelectPage | (private) |
| 690 | fn | renderError | (private) |
| 709 | fn | renderSuccess | (private) |
| 727 | fn | CleanupExpiredSessions | pub |
| 742 | fn | GetSession | pub |
| 750 | struct | ImportTokenRequest | pub |
| 755 | fn | handleImportToken | (private) |
| 827 | fn | handleManualRefresh | (private) |
| 955 | fn | refreshTokenData | (private) |

## third_party/CLIProxyAPIPlus/internal/auth/kiro/oauth_web_templates.go (779 lines)

_No symbols extracted._

## third_party/CLIProxyAPIPlus/internal/auth/kiro/protocol_handler.go (725 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 44 | struct | ProtocolHandler | pub |
| 55 | struct | AuthCallback | pub |
| 62 | fn | NewProtocolHandler | pub |
| 71 | fn | Start | pub |
| 159 | fn | Stop | pub |
| 188 | fn | WaitForCallback | pub |
| 200 | fn | GetPort | pub |
| 205 | fn | handleCallback | (private) |
| 250 | fn | IsProtocolHandlerInstalled | pub |
| 264 | fn | InstallProtocolHandler | pub |
| 278 | fn | UninstallProtocolHandler | pub |
| 293 | fn | getLinuxDesktopPath | (private) |
| 298 | fn | getLinuxHandlerScriptPath | (private) |
| 303 | fn | isLinuxHandlerInstalled | (private) |
| 309 | fn | installLinuxHandler | (private) |
| 396 | fn | uninstallLinuxHandler | (private) |
| 413 | fn | isWindowsHandlerInstalled | (private) |
| 419 | fn | installWindowsHandler | (private) |
| 500 | fn | uninstallWindowsHandler | (private) |
| 519 | fn | getDarwinAppPath | (private) |
| 524 | fn | isDarwinHandlerInstalled | (private) |
| 530 | fn | installDarwinHandler | (private) |
| 617 | fn | uninstallDarwinHandler | (private) |
| 635 | fn | ParseKiroURI | pub |
| 658 | fn | GetHandlerInstructions | pub |
| 702 | fn | SetupProtocolHandlerIfNeeded | pub |

## third_party/CLIProxyAPIPlus/internal/auth/kiro/sso_oidc.go (1603 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 51 | struct | SSOOIDCClient | pub |
| 57 | fn | NewSSOOIDCClient | pub |
| 69 | struct | RegisterClientResponse | pub |
| 77 | struct | StartDeviceAuthResponse | pub |
| 87 | struct | CreateTokenResponse | pub |
| 95 | fn | getOIDCEndpoint | (private) |
| 103 | fn | promptInput | (private) |
| 123 | fn | promptSelect | (private) |
| 151 | fn | RegisterClientWithRegion | pub |
| 197 | fn | StartDeviceAuthorizationWithIDC | pub |
| 242 | fn | CreateTokenWithRegion | pub |
| 305 | fn | RefreshTokenWithRegion | pub |
| 366 | fn | LoginWithIDC | pub |
| 488 | struct | IDCLoginOptions | pub |
| 497 | fn | LoginWithMethodSelection | pub |
| 563 | fn | LoginWithIDCAndOptions | pub |
| 568 | fn | RegisterClient | pub |
| 612 | fn | StartDeviceAuthorization | pub |
| 655 | fn | CreateToken | pub |
| 717 | fn | RefreshToken | pub |
| 772 | fn | LoginWithBuilderID | pub |
| 893 | fn | FetchUserEmail | pub |
| 905 | fn | tryUserInfoEndpoint | (private) |
| 955 | fn | FetchProfileArn | pub |
| 963 | fn | tryListAvailableProfiles | (private) |
| 1010 | fn | tryListProfilesLegacy | (private) |
| 1070 | fn | RegisterClientForAuthCode | pub |
| 1115 | fn | RegisterClientForAuthCodeWithIDC | pub |
| 1163 | struct | AuthCodeCallbackResult | pub |
| 1170 | fn | startAuthCodeCallbackServer | (private) |
| 1248 | fn | generatePKCEForAuthCode | (private) |
| 1260 | fn | generateStateForAuthCode | (private) |
| 1269 | fn | CreateTokenWithAuthCode | pub |
| 1314 | fn | CreateTokenWithAuthCodeAndRegion | pub |
| 1363 | fn | LoginWithBuilderIDAuthCode | pub |
| 1482 | fn | LoginWithIDCAuthCode | pub |
| 1593 | fn | buildAuthorizationURL | (private) |

