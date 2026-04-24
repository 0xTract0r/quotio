# third_party/CLIProxyAPIPlus/internal/api/handlers/management/api_tools.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-api-handlers-management/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1150
- **Language:** Go
- **Symbols:** 31
- **Public symbols:** 5

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 24 | const | defaultAPICallTimeout | (private) | - |
| 44 | struct | apiCallRequest | (private) | - |
| 54 | struct | apiCallResponse | (private) | - |
| 115 | fn | APICall | pub | `func (h *Handler) APICall(c *gin.Context) {` |
| 282 | fn | firstNonEmptyString | (private) | `func firstNonEmptyString(values ...*string) str...` |
| 294 | fn | tokenValueForAuth | (private) | `func tokenValueForAuth(auth *coreauth.Auth) str...` |
| 314 | fn | resolveTokenForAuth | (private) | `func (h *Handler) resolveTokenForAuth(ctx conte...` |
| 332 | fn | refreshGeminiOAuthAccessToken | (private) | `func (h *Handler) refreshGeminiOAuthAccessToken...` |
| 402 | fn | refreshAntigravityOAuthAccessToken | (private) | `func (h *Handler) refreshAntigravityOAuthAccess...` |
| 501 | fn | antigravityTokenNeedsRefresh | (private) | `func antigravityTokenNeedsRefresh(metadata map[...` |
| 522 | fn | int64Value | (private) | `func int64Value(raw any) int64 {` |
| 557 | fn | geminiOAuthMetadata | (private) | `func geminiOAuthMetadata(auth *coreauth.Auth) (...` |
| 575 | fn | stringValue | (private) | `func stringValue(metadata map[string]any, key s...` |
| 585 | fn | cloneMap | (private) | `func cloneMap(in map[string]any) map[string]any {` |
| 596 | fn | buildOAuthTokenMap | (private) | `func buildOAuthTokenMap(base map[string]any, to...` |
| 615 | fn | buildOAuthTokenFields | (private) | `func buildOAuthTokenFields(tok *oauth2.Token, m...` |
| 635 | fn | tokenValueFromMetadata | (private) | `func tokenValueFromMetadata(metadata map[string...` |
| 679 | fn | authByIndex | (private) | `func (h *Handler) authByIndex(authIndex string)...` |
| 697 | fn | apiCallTransport | (private) | `func (h *Handler) apiCallTransport(auth *coreau...` |
| 725 | fn | buildProxyTransport | (private) | `func buildProxyTransport(proxyStr string) *http...` |
| 735 | fn | headerContainsValue | (private) | `func headerContainsValue(headers map[string]str...` |
| 751 | fn | encodeJSONStringToCBOR | (private) | `func encodeJSONStringToCBOR(jsonString string) ...` |
| 760 | fn | decodeCBORBodyToTextOrJSON | (private) | `func decodeCBORBodyToTextOrJSON(raw []byte) (st...` |
| 786 | fn | cborValueToJSONCompatible | (private) | `func cborValueToJSONCompatible(value any) any {` |
| 812 | struct | QuotaDetail | pub | - |
| 824 | struct | QuotaSnapshots | pub | - |
| 831 | struct | CopilotUsageResponse | pub | - |
| 844 | struct | copilotQuotaRequest | (private) | - |
| 869 | fn | GetCopilotQuota | pub | `func (h *Handler) GetCopilotQuota(c *gin.Contex...` |
| 947 | fn | findCopilotAuth | (private) | `func (h *Handler) findCopilotAuth(authIndex str...` |
| 981 | fn | enrichCopilotTokenResponse | (private) | `func (h *Handler) enrichCopilotTokenResponse(ct...` |

## Public API

### `APICall`

```
func (h *Handler) APICall(c *gin.Context) {
```

**Line:** 115 | **Kind:** fn

### `GetCopilotQuota`

```
func (h *Handler) GetCopilotQuota(c *gin.Context) {
```

**Line:** 869 | **Kind:** fn

## Memory Markers

### 🟢 `NOTE` (line 87)

> if you need to override the HTTP Host header, set header["Host"].

