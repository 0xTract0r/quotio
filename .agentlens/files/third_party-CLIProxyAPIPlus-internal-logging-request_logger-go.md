# third_party/CLIProxyAPIPlus/internal/logging/request_logger.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-logging/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1500
- **Language:** Go
- **Symbols:** 56
- **Public symbols:** 27

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 34 | interface | RequestLogger | pub | - |
| 80 | interface | StreamingLogWriter | pub | - |
| 142 | struct | FileRequestLogger | pub | - |
| 164 | fn | NewFileRequestLogger | pub | `func NewFileRequestLogger(enabled bool, logsDir...` |
| 183 | fn | IsEnabled | pub | `func (l *FileRequestLogger) IsEnabled() bool {` |
| 192 | fn | SetEnabled | pub | `func (l *FileRequestLogger) SetEnabled(enabled ...` |
| 197 | fn | SetErrorLogsMaxFiles | pub | `func (l *FileRequestLogger) SetErrorLogsMaxFile...` |
| 219 | fn | LogRequest | pub | `func (l *FileRequestLogger) LogRequest(url, met...` |
| 225 | fn | LogRequestWithOptions | pub | `func (l *FileRequestLogger) LogRequestWithOptio...` |
| 229 | fn | logRequest | (private) | `func (l *FileRequestLogger) logRequest(url, met...` |
| 319 | fn | LogStreamingRequest | pub | `func (l *FileRequestLogger) LogStreamingRequest...` |
| 374 | fn | generateErrorFilename | (private) | `func (l *FileRequestLogger) generateErrorFilena...` |
| 382 | fn | ensureLogsDir | (private) | `func (l *FileRequestLogger) ensureLogsDir() err...` |
| 398 | fn | generateFilename | (private) | `func (l *FileRequestLogger) generateFilename(ur...` |
| 435 | fn | sanitizeForFilename | (private) | `func (l *FileRequestLogger) sanitizeForFilename...` |
| 462 | fn | cleanupOldErrorLogs | (private) | `func (l *FileRequestLogger) cleanupOldErrorLogs...` |
| 511 | fn | writeRequestBodyTempFile | (private) | `func (l *FileRequestLogger) writeRequestBodyTem...` |
| 530 | fn | writeNonStreamingLog | (private) | `func (l *FileRequestLogger) writeNonStreamingLog(` |
| 581 | fn | writeRequestInfoWithBody | (private) | `func writeRequestInfoWithBody(` |
| 673 | fn | countTrailingNewlinesBytes | (private) | `func countTrailingNewlinesBytes(payload []byte)...` |
| 684 | fn | writeSectionSpacing | (private) | `func writeSectionSpacing(w io.Writer, trailingN...` |
| 693 | struct | trailingNewlineTrackingWriter | (private) | - |
| 698 | fn | Write | pub | `func (t *trailingNewlineTrackingWriter) Write(p...` |
| 712 | fn | hasSectionPayload | (private) | `func hasSectionPayload(payload []byte) bool {` |
| 716 | fn | inferDownstreamTransport | (private) | `func inferDownstreamTransport(headers map[strin...` |
| 732 | fn | inferUpstreamTransport | (private) | `func inferUpstreamTransport(apiRequest, apiResp...` |
| 747 | fn | writeAPISection | (private) | `func writeAPISection(w io.Writer, sectionHeader...` |
| 776 | fn | writeAPIErrorResponses | (private) | `func writeAPIErrorResponses(w io.Writer, apiRes...` |
| 804 | fn | writeResponseSection | (private) | `func writeResponseSection(w io.Writer, statusCo...` |
| 853 | fn | responseBodyStartsWithLeadingNewline | (private) | `func responseBodyStartsWithLeadingNewline(reade...` |
| 882 | fn | formatLogContent | (private) | `func (l *FileRequestLogger) formatLogContent(ur...` |
| 988 | fn | decompressResponse | (private) | `func (l *FileRequestLogger) decompressResponse(...` |
| 1025 | fn | decompressGzip | (private) | `func (l *FileRequestLogger) decompressGzip(data...` |
| 1052 | fn | decompressDeflate | (private) | `func (l *FileRequestLogger) decompressDeflate(d...` |
| 1076 | fn | decompressBrotli | (private) | `func (l *FileRequestLogger) decompressBrotli(da...` |
| 1095 | fn | decompressZstd | (private) | `func (l *FileRequestLogger) decompressZstd(data...` |
| 1120 | fn | formatRequestInfo | (private) | `func (l *FileRequestLogger) formatRequestInfo(u...` |
| 1159 | struct | FileStreamingLogWriter | pub | - |
| 1219 | fn | WriteChunkAsync | pub | `func (w *FileStreamingLogWriter) WriteChunkAsyn...` |
| 1244 | fn | WriteStatus | pub | `func (w *FileStreamingLogWriter) WriteStatus(st...` |
| 1269 | fn | WriteAPIRequest | pub | `func (w *FileStreamingLogWriter) WriteAPIReques...` |
| 1284 | fn | WriteAPIResponse | pub | `func (w *FileStreamingLogWriter) WriteAPIRespon...` |
| 1299 | fn | WriteAPIWebsocketTimeline | pub | `func (w *FileStreamingLogWriter) WriteAPIWebsoc...` |
| 1307 | fn | SetFirstChunkTimestamp | pub | `func (w *FileStreamingLogWriter) SetFirstChunkT...` |
| 1319 | fn | Close | pub | `func (w *FileStreamingLogWriter) Close() error {` |
| 1362 | fn | asyncWriter | (private) | `func (w *FileStreamingLogWriter) asyncWriter() {` |
| 1396 | fn | writeFinalLog | (private) | `func (w *FileStreamingLogWriter) writeFinalLog(...` |
| 1423 | fn | cleanupTempFiles | (private) | `func (w *FileStreamingLogWriter) cleanupTempFil...` |
| 1441 | struct | NoOpStreamingLogWriter | pub | - |
| 1447 | fn | WriteChunkAsync | pub | `func (w *NoOpStreamingLogWriter) WriteChunkAsyn...` |
| 1457 | fn | WriteStatus | pub | `func (w *NoOpStreamingLogWriter) WriteStatus(_ ...` |
| 1468 | fn | WriteAPIRequest | pub | `func (w *NoOpStreamingLogWriter) WriteAPIReques...` |
| 1479 | fn | WriteAPIResponse | pub | `func (w *NoOpStreamingLogWriter) WriteAPIRespon...` |
| 1490 | fn | WriteAPIWebsocketTimeline | pub | `func (w *NoOpStreamingLogWriter) WriteAPIWebsoc...` |
| 1494 | fn | SetFirstChunkTimestamp | pub | `func (w *NoOpStreamingLogWriter) SetFirstChunkT...` |
| 1500 | fn | Close | pub | `func (w *NoOpStreamingLogWriter) Close() error ...` |

## Public API

### `NewFileRequestLogger`

```
func NewFileRequestLogger(enabled bool, logsDir string, configDir string, errorLogsMaxFiles int) *FileRequestLogger {
```

**Line:** 164 | **Kind:** fn

### `IsEnabled`

```
func (l *FileRequestLogger) IsEnabled() bool {
```

**Line:** 183 | **Kind:** fn

### `SetEnabled`

```
func (l *FileRequestLogger) SetEnabled(enabled bool) {
```

**Line:** 192 | **Kind:** fn

### `SetErrorLogsMaxFiles`

```
func (l *FileRequestLogger) SetErrorLogsMaxFiles(maxFiles int) {
```

**Line:** 197 | **Kind:** fn

### `LogRequest`

```
func (l *FileRequestLogger) LogRequest(url, method string, requestHeaders map[string][]string, body []byte, statusCode int, responseHeaders map[string][]string, response, websocketTimeline, apiRequest, apiResponse, apiWebsocketTimeline []byte, apiResponseErrors []*interfaces.ErrorMessage, requestID string, requestTimestamp, apiResponseTimestamp time.Time) error {
```

**Line:** 219 | **Kind:** fn

### `LogRequestWithOptions`

```
func (l *FileRequestLogger) LogRequestWithOptions(url, method string, requestHeaders map[string][]string, body []byte, statusCode int, responseHeaders map[string][]string, response, websocketTimeline, apiRequest, apiResponse, apiWebsocketTimeline []byte, apiResponseErrors []*interfaces.ErrorMessage, force bool, requestID string, requestTimestamp, apiResponseTimestamp time.Time) error {
```

**Line:** 225 | **Kind:** fn

### `LogStreamingRequest`

```
func (l *FileRequestLogger) LogStreamingRequest(url, method string, headers map[string][]string, body []byte, requestID string) (StreamingLogWriter, error) {
```

**Line:** 319 | **Kind:** fn

### `Write`

```
func (t *trailingNewlineTrackingWriter) Write(payload []byte) (int, error) {
```

**Line:** 698 | **Kind:** fn

### `WriteChunkAsync`

```
func (w *FileStreamingLogWriter) WriteChunkAsync(chunk []byte) {
```

**Line:** 1219 | **Kind:** fn

### `WriteStatus`

```
func (w *FileStreamingLogWriter) WriteStatus(status int, headers map[string][]string) error {
```

**Line:** 1244 | **Kind:** fn

### `WriteAPIRequest`

```
func (w *FileStreamingLogWriter) WriteAPIRequest(apiRequest []byte) error {
```

**Line:** 1269 | **Kind:** fn

### `WriteAPIResponse`

```
func (w *FileStreamingLogWriter) WriteAPIResponse(apiResponse []byte) error {
```

**Line:** 1284 | **Kind:** fn

### `WriteAPIWebsocketTimeline`

```
func (w *FileStreamingLogWriter) WriteAPIWebsocketTimeline(apiWebsocketTimeline []byte) error {
```

**Line:** 1299 | **Kind:** fn

### `SetFirstChunkTimestamp`

```
func (w *FileStreamingLogWriter) SetFirstChunkTimestamp(timestamp time.Time) {
```

**Line:** 1307 | **Kind:** fn

### `Close`

```
func (w *FileStreamingLogWriter) Close() error {
```

**Line:** 1319 | **Kind:** fn

### `WriteChunkAsync`

```
func (w *NoOpStreamingLogWriter) WriteChunkAsync(_ []byte) {}
```

**Line:** 1447 | **Kind:** fn

### `WriteStatus`

```
func (w *NoOpStreamingLogWriter) WriteStatus(_ int, _ map[string][]string) error {
```

**Line:** 1457 | **Kind:** fn

### `WriteAPIRequest`

```
func (w *NoOpStreamingLogWriter) WriteAPIRequest(_ []byte) error {
```

**Line:** 1468 | **Kind:** fn

### `WriteAPIResponse`

```
func (w *NoOpStreamingLogWriter) WriteAPIResponse(_ []byte) error {
```

**Line:** 1479 | **Kind:** fn

### `WriteAPIWebsocketTimeline`

```
func (w *NoOpStreamingLogWriter) WriteAPIWebsocketTimeline(_ []byte) error {
```

**Line:** 1490 | **Kind:** fn

### `SetFirstChunkTimestamp`

```
func (w *NoOpStreamingLogWriter) SetFirstChunkTimestamp(_ time.Time) {}
```

**Line:** 1494 | **Kind:** fn

### `Close`

```
func (w *NoOpStreamingLogWriter) Close() error { return nil }
```

**Line:** 1500 | **Kind:** fn

