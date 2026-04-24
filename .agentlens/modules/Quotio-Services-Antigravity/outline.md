# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 1 large files in this module.

## Quotio/Services/Antigravity/AntigravityQuotaFetcher.swift (921 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 13 | enum | AntigravityModelGroup | (internal) |
| 29 | fn | group | (internal) |
| 50 | struct | GroupedModelQuota | (internal) |
| 111 | fn | parseISO8601Date | (private) |
| 127 | struct | ModelQuota | (internal) |
| 271 | struct | ProviderQuotaData | (internal) |
| 346 | struct | SubscriptionTier | (internal) |
| 358 | struct | PrivacyNotice | (internal) |
| 363 | struct | SubscriptionInfo | (internal) |
| 405 | struct | QuotaAPIResponse | (private) |
| 409 | struct | ModelInfo | (private) |
| 413 | struct | QuotaInfo | (private) |
| 418 | struct | TokenRefreshResponse | (private) |
| 432 | struct | AntigravityAuthFile | (internal) |
| 478 | class | AntigravityQuotaFetcher | (internal) |
| 490 | method | init | (internal) |
| 497 | fn | updateProxyConfiguration | (internal) |
| 503 | fn | clearCache | (internal) |
| 507 | fn | refreshAccessToken | (internal) |
| 512 | fn | refreshAccessTokenWithExpiry | (private) |
| 544 | fn | persistRefreshedToken | (private) |
| 561 | fn | fetchQuota | (internal) |
| 631 | fn | fetchProjectId | (private) |
| 643 | fn | fetchSubscriptionInfo | (internal) |
| 676 | fn | fetchSubscriptionInfoForAuthFile | (internal) |
| 699 | fn | fetchAllSubscriptionInfo | (internal) |
| 725 | fn | fetchQuotaForAuthFile | (internal) |
| 749 | fn | fetchQuotaAndSubscriptionForAuthFile | (internal) |
| 782 | fn | fetchAllAntigravityQuotas | (internal) |
| 825 | fn | fetchAllAntigravityData | (internal) |
| 871 | fn | fetchAllAntigravityQuotasLegacy | (internal) |
| 903 | enum | QuotaFetchError | (internal) |

