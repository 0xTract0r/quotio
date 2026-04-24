# third_party/Cli-Proxy-API-Management-Center/src/utils/usage.ts

[← Back to Module](../modules/root/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 2111
- **Language:** TypeScript
- **Symbols:** 64
- **Public symbols:** 57

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 26 | interface | KeyStatBucket | pub | - |
| 31 | interface | KeyStats | pub | - |
| 36 | interface | TokenBreakdown | pub | - |
| 46 | interface | RateStats | pub | - |
| 54 | interface | ModelPrice | pub | - |
| 60 | interface | UsageDetail | pub | - |
| 83 | interface | UsageDetailWithEndpoint | pub | - |
| 90 | interface | ApiStats | pub | - |
| 103 | interface | ModelStatsSummary | pub | - |
| 115 | type | UsageTimeRange | pub | - |
| 178 | fn | extractCacheReadTokens | pub | `export function extractCacheReadTokens(detail: ...` |
| 187 | fn | extractCacheWriteTokens | pub | `export function extractCacheWriteTokens(detail:...` |
| 195 | fn | calculateCacheMetricsFromDetails | pub | `export function calculateCacheMetricsFromDetail...` |
| 221 | interface | UsageSummary | (private) | - |
| 235 | fn | toUsageSummaryFields | (private) | `const toUsageSummaryFields = (summary: UsageSum...` |
| 242 | fn | filterUsageByTimeRange | pub | `export function filterUsageByTimeRange<T>(` |
| 349 | fn | normalizeAuthIndex | pub | `export const normalizeAuthIndex = (value: unkno...` |
| 441 | fn | normalizeUsageSourceId | pub | `export function normalizeUsageSourceId(` |
| 462 | fn | buildCandidateUsageSourceIds | pub | `export function buildCandidateUsageSourceIds(in...` |
| 489 | fn | maskUsageSensitiveValue | pub | `export function maskUsageSensitiveValue(` |
| 544 | fn | formatPerMinuteValue | pub | `export function formatPerMinuteValue(value: num...` |
| 565 | fn | formatCompactNumber | pub | `export function formatCompactNumber(value: numb...` |
| 583 | fn | formatUsd | pub | `export function formatUsd(value: number): string {` |
| 602 | fn | collectUsageDetails | pub | `export function collectUsageDetails(usageData: ...` |
| 672 | fn | collectUsageDetailsWithEndpoint | pub | `export function collectUsageDetailsWithEndpoint...` |
| 750 | fn | extractTotalTokens | pub | `export function extractTotalTokens(detail: unkn...` |
| 767 | fn | calculateLatencyStats | pub | `export function calculateLatencyStats(usageData...` |
| 774 | fn | calculateTokenBreakdown | pub | `export function calculateTokenBreakdown(usageDa...` |
| 812 | fn | calculateRecentPerMinuteRates | pub | `export function calculateRecentPerMinuteRates(` |
| 853 | fn | getModelNamesFromUsage | pub | `export function getModelNamesFromUsage(usageDat...` |
| 874 | fn | calculateCost | pub | `export function calculateCost(` |
| 915 | fn | calculateTotalCost | pub | `export function calculateTotalCost(` |
| 926 | fn | hasUsageCostSupport | pub | `export function hasUsageCostSupport(` |
| 998 | fn | loadModelPrices | pub | `export function loadModelPrices(): Record<strin...` |
| 1051 | fn | saveModelPrices | pub | `export function saveModelPrices(prices: Record<...` |
| 1065 | fn | getApiStats | pub | `export function getApiStats(` |
| 1173 | fn | getModelStats | pub | `export function getModelStats(` |
| 1278 | fn | formatHourLabel | pub | `export function formatHourLabel(date: Date): st...` |
| 1291 | fn | formatDayLabel | pub | `export function formatDayLabel(date: Date): str...` |
| 1304 | fn | buildHourlySeriesByModel | pub | `export function buildHourlySeriesByModel(` |
| 1382 | fn | buildDailySeriesByModel | pub | `export function buildDailySeriesByModel(` |
| 1433 | interface | ChartDataset | pub | - |
| 1447 | interface | ChartData | pub | - |
| 1464 | fn | clamp | (private) | `const clamp = (value: number, min: number, max:...` |
| 1480 | fn | withAlpha | (private) | `const withAlpha = (hex: string, alpha: number) ...` |
| 1489 | fn | buildAreaGradient | (private) | `const buildAreaGradient = (` |
| 1512 | fn | buildChartData | pub | `export function buildChartData(` |
| 1572 | type | StatusBlockState | pub | - |
| 1577 | interface | StatusBlockDetail | pub | - |
| 1591 | interface | StatusBarData | pub | - |
| 1603 | fn | calculateStatusBarData | pub | `export function calculateStatusBarData(` |
| 1705 | interface | ServiceHealthData | pub | - |
| 1715 | fn | calculateServiceHealthData | pub | `export function calculateServiceHealthData(usag...` |
| 1800 | fn | computeKeyStats | pub | `export function computeKeyStats(` |
| 1812 | fn | ensureBucket | (private) | `const ensureBucket = (bucket: Record<string, Ke...` |
| 1862 | fn | computeKeyStatsFromDetails | pub | `export function computeKeyStatsFromDetails(usag...` |
| 1866 | fn | ensureBucket | (private) | `const ensureBucket = (bucket: Record<string, Ke...` |
| 1900 | type | TokenCategory | pub | - |
| 1902 | interface | TokenBreakdownSeries | pub | - |
| 1911 | fn | buildHourlyTokenBreakdown | pub | `export function buildHourlyTokenBreakdown(` |
| 1977 | fn | buildDailyTokenBreakdown | pub | `export function buildDailyTokenBreakdown(usageD...` |
| 2020 | interface | CostSeries | pub | - |
| 2029 | fn | buildHourlyCostSeries | pub | `export function buildHourlyCostSeries(` |
| 2083 | fn | buildDailyCostSeries | pub | `export function buildDailyCostSeries(` |

## Public API

### `extractCacheReadTokens`

```
export function extractCacheReadTokens(detail: unknown): number {
```

**Line:** 178 | **Kind:** fn

### `extractCacheWriteTokens`

```
export function extractCacheWriteTokens(detail: unknown): number {
```

**Line:** 187 | **Kind:** fn

### `calculateCacheMetricsFromDetails`

```
export function calculateCacheMetricsFromDetails(details: UsageDetail[]) {
```

**Line:** 195 | **Kind:** fn

### `filterUsageByTimeRange`

```
export function filterUsageByTimeRange<T>(
```

**Line:** 242 | **Kind:** fn

### `normalizeAuthIndex`

```
export const normalizeAuthIndex = (value: unknown) => {
```

**Line:** 349 | **Kind:** fn

### `normalizeUsageSourceId`

```
export function normalizeUsageSourceId(
```

**Line:** 441 | **Kind:** fn

### `buildCandidateUsageSourceIds`

```
export function buildCandidateUsageSourceIds(input: {
```

**Line:** 462 | **Kind:** fn

### `maskUsageSensitiveValue`

```
export function maskUsageSensitiveValue(
```

**Line:** 489 | **Kind:** fn

### `formatPerMinuteValue`

```
export function formatPerMinuteValue(value: number): string {
```

**Line:** 544 | **Kind:** fn

### `formatCompactNumber`

```
export function formatCompactNumber(value: number): string {
```

**Line:** 565 | **Kind:** fn

### `formatUsd`

```
export function formatUsd(value: number): string {
```

**Line:** 583 | **Kind:** fn

### `collectUsageDetails`

```
export function collectUsageDetails(usageData: unknown): UsageDetail[] {
```

**Line:** 602 | **Kind:** fn

### `collectUsageDetailsWithEndpoint`

```
export function collectUsageDetailsWithEndpoint(usageData: unknown): UsageDetailWithEndpoint[] {
```

**Line:** 672 | **Kind:** fn

### `extractTotalTokens`

```
export function extractTotalTokens(detail: unknown): number {
```

**Line:** 750 | **Kind:** fn

### `calculateLatencyStats`

```
export function calculateLatencyStats(usageData: unknown): LatencyStats {
```

**Line:** 767 | **Kind:** fn

### `calculateTokenBreakdown`

```
export function calculateTokenBreakdown(usageData: unknown): TokenBreakdown {
```

**Line:** 774 | **Kind:** fn

### `calculateRecentPerMinuteRates`

```
export function calculateRecentPerMinuteRates(
```

**Line:** 812 | **Kind:** fn

### `getModelNamesFromUsage`

```
export function getModelNamesFromUsage(usageData: unknown): string[] {
```

**Line:** 853 | **Kind:** fn

### `calculateCost`

```
export function calculateCost(
```

**Line:** 874 | **Kind:** fn

### `calculateTotalCost`

```
export function calculateTotalCost(
```

**Line:** 915 | **Kind:** fn

### `hasUsageCostSupport`

```
export function hasUsageCostSupport(
```

**Line:** 926 | **Kind:** fn

### `loadModelPrices`

```
export function loadModelPrices(): Record<string, ModelPrice> {
```

**Line:** 998 | **Kind:** fn

### `saveModelPrices`

```
export function saveModelPrices(prices: Record<string, ModelPrice>): void {
```

**Line:** 1051 | **Kind:** fn

### `getApiStats`

```
export function getApiStats(
```

**Line:** 1065 | **Kind:** fn

### `getModelStats`

```
export function getModelStats(
```

**Line:** 1173 | **Kind:** fn

### `formatHourLabel`

```
export function formatHourLabel(date: Date): string {
```

**Line:** 1278 | **Kind:** fn

### `formatDayLabel`

```
export function formatDayLabel(date: Date): string {
```

**Line:** 1291 | **Kind:** fn

### `buildHourlySeriesByModel`

```
export function buildHourlySeriesByModel(
```

**Line:** 1304 | **Kind:** fn

### `buildDailySeriesByModel`

```
export function buildDailySeriesByModel(
```

**Line:** 1382 | **Kind:** fn

### `buildChartData`

```
export function buildChartData(
```

**Line:** 1512 | **Kind:** fn

### `calculateStatusBarData`

```
export function calculateStatusBarData(
```

**Line:** 1603 | **Kind:** fn

### `calculateServiceHealthData`

```
export function calculateServiceHealthData(usageDetails: UsageDetail[]): ServiceHealthData {
```

**Line:** 1715 | **Kind:** fn

### `computeKeyStats`

```
export function computeKeyStats(
```

**Line:** 1800 | **Kind:** fn

### `computeKeyStatsFromDetails`

```
export function computeKeyStatsFromDetails(usageDetails: UsageDetail[]): KeyStats {
```

**Line:** 1862 | **Kind:** fn

### `buildHourlyTokenBreakdown`

```
export function buildHourlyTokenBreakdown(
```

**Line:** 1911 | **Kind:** fn

### `buildDailyTokenBreakdown`

```
export function buildDailyTokenBreakdown(usageData: unknown): TokenBreakdownSeries {
```

**Line:** 1977 | **Kind:** fn

### `buildHourlyCostSeries`

```
export function buildHourlyCostSeries(
```

**Line:** 2029 | **Kind:** fn

### `buildDailyCostSeries`

```
export function buildDailyCostSeries(
```

**Line:** 2083 | **Kind:** fn

