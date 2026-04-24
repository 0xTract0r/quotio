# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 1 large files in this module.

## Quotio/Services/QuotaFetchers/KiroQuotaFetcher.swift (668 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 13 | struct | KiroUsageResponse | (internal) |
| 50 | struct | KiroTokenResponse | (internal) |
| 62 | class | KiroQuotaFetcher | (internal) |
| 68 | fn | socialTokenEndpoint | (private) |
| 73 | fn | idcTokenEndpoint | (private) |
| 78 | fn | usageEndpoint | (private) |
| 87 | method | init | (internal) |
| 94 | fn | updateProxyConfiguration | (internal) |
| 100 | fn | fetchAllQuotas | (internal) |
| 141 | fn | refreshAllTokensIfNeeded | (internal) |
| 176 | fn | shouldRefreshToken | (private) |
| 210 | fn | fetchQuota | (private) |
| 270 | fn | parseExpiryDate | (private) |
| 286 | fn | fetchUsageAPI | (private) |
| 366 | fn | refreshTokenWithExpiry | (private) |
| 390 | fn | refreshSocialTokenWithExpiry | (private) |
| 439 | fn | refreshIdCTokenWithExpiry | (private) |
| 525 | fn | syncToKiroIDEAuthFile | (private) |
| 557 | fn | persistRefreshedToken | (private) |
| 590 | fn | convertToQuotaData | (private) |

