# third_party/CLIProxyAPIPlus/internal/api/handlers/management/api_tools.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-api-handlers-management/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1273
- **Language:** Go
- **Symbols:** 34
- **Public symbols:** 5

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 25 | const | defaultAPICallTimeout | (private) | - |
| 45 | struct | apiCallRequest | (private) | - |
| 55 | struct | apiCallResponse | (private) | - |
| 116 | fn | APICall | pub | `func (h *Handler) APICall(c *gin.Context) {` |
| 283 | fn | firstNonEmptyString | (private) | `func firstNonEmptyString(values ...*string) str...` |
| 295 | fn | tokenValueForAuth | (private) | `func tokenValueForAuth(auth *coreauth.Auth) str...` |
| 315 | fn | resolveTokenForAuth | (private) | `func (h *Handler) resolveTokenForAuth(ctx conte...` |
| 333 | fn | refreshGeminiOAuthAccessToken | (private) | `func (h *Handler) refreshGeminiOAuthAccessToken...` |
| 403 | fn | refreshAntigravityOAuthAccessToken | (private) | `func (h *Handler) refreshAntigravityOAuthAccess...` |
| 502 | fn | antigravityTokenNeedsRefresh | (private) | `func antigravityTokenNeedsRefresh(metadata map[...` |
| 523 | fn | int64Value | (private) | `func int64Value(raw any) int64 {` |
| 558 | fn | geminiOAuthMetadata | (private) | `func geminiOAuthMetadata(auth *coreauth.Auth) (...` |
| 576 | fn | stringValue | (private) | `func stringValue(metadata map[string]any, key s...` |
| 586 | fn | cloneMap | (private) | `func cloneMap(in map[string]any) map[string]any {` |
| 597 | fn | buildOAuthTokenMap | (private) | `func buildOAuthTokenMap(base map[string]any, to...` |
| 616 | fn | buildOAuthTokenFields | (private) | `func buildOAuthTokenFields(tok *oauth2.Token, m...` |
| 636 | fn | tokenValueFromMetadata | (private) | `func tokenValueFromMetadata(metadata map[string...` |
| 680 | fn | authByIndex | (private) | `func (h *Handler) authByIndex(authIndex string)...` |
| 698 | fn | apiCallTransport | (private) | `func (h *Handler) apiCallTransport(auth *coreau...` |
| 731 | interface | apiKeyConfigEntry | (private) | - |
| 775 | fn | proxyURLFromAPIKeyConfig | (private) | `func proxyURLFromAPIKeyConfig(cfg *config.Confi...` |
| 812 | fn | resolveOpenAICompatAPIKeyProxyURL | (private) | `func resolveOpenAICompatAPIKeyProxyURL(cfg *con...` |
| 848 | fn | buildProxyTransport | (private) | `func buildProxyTransport(proxyStr string) *http...` |
| 858 | fn | headerContainsValue | (private) | `func headerContainsValue(headers map[string]str...` |
| 874 | fn | encodeJSONStringToCBOR | (private) | `func encodeJSONStringToCBOR(jsonString string) ...` |
| 883 | fn | decodeCBORBodyToTextOrJSON | (private) | `func decodeCBORBodyToTextOrJSON(raw []byte) (st...` |
| 909 | fn | cborValueToJSONCompatible | (private) | `func cborValueToJSONCompatible(value any) any {` |
| 935 | struct | QuotaDetail | pub | - |
| 947 | struct | QuotaSnapshots | pub | - |
| 954 | struct | CopilotUsageResponse | pub | - |
| 967 | struct | copilotQuotaRequest | (private) | - |
| 992 | fn | GetCopilotQuota | pub | `func (h *Handler) GetCopilotQuota(c *gin.Contex...` |
| 1070 | fn | findCopilotAuth | (private) | `func (h *Handler) findCopilotAuth(authIndex str...` |
| 1104 | fn | enrichCopilotTokenResponse | (private) | `func (h *Handler) enrichCopilotTokenResponse(ct...` |

## Public API

### `APICall`

```
func (h *Handler) APICall(c *gin.Context) {
```

**Line:** 116 | **Kind:** fn

### `GetCopilotQuota`

```
func (h *Handler) GetCopilotQuota(c *gin.Context) {
```

**Line:** 992 | **Kind:** fn

## Memory Markers

### 🟢 `NOTE` (line 88)

> if you need to override the HTTP Host header, set header["Host"].

