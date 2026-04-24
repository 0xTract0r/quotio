# third_party/CLIProxyAPIPlus/internal/logging/request_logger.go

[← Back to Module](../modules/third_party-CLIProxyAPIPlus-internal-logging/MODULE.md) | [← Back to INDEX](../INDEX.md)

## Overview

- **Lines:** 1274
- **Language:** Go
- **Symbols:** 46
- **Public symbols:** 24

## Symbol Table

| Line | Kind | Name | Visibility | Signature |
| ---- | ---- | ---- | ---------- | --------- |
| 33 | interface | RequestLogger | pub | - |
| 77 | interface | StreamingLogWriter | pub | - |
| 129 | struct | FileRequestLogger | pub | - |
| 151 | fn | NewFileRequestLogger | pub | `func NewFileRequestLogger(enabled bool, logsDir...` |
| 170 | fn | IsEnabled | pub | `func (l *FileRequestLogger) IsEnabled() bool {` |
| 179 | fn | SetEnabled | pub | `func (l *FileRequestLogger) SetEnabled(enabled ...` |
| 184 | fn | SetErrorLogsMaxFiles | pub | `func (l *FileRequestLogger) SetErrorLogsMaxFile...` |
| 206 | fn | LogRequest | pub | `func (l *FileRequestLogger) LogRequest(url, met...` |
| 212 | fn | LogRequestWithOptions | pub | `func (l *FileRequestLogger) LogRequestWithOptio...` |
| 216 | fn | logRequest | (private) | `func (l *FileRequestLogger) logRequest(url, met...` |
| 304 | fn | LogStreamingRequest | pub | `func (l *FileRequestLogger) LogStreamingRequest...` |
| 359 | fn | generateErrorFilename | (private) | `func (l *FileRequestLogger) generateErrorFilena...` |
| 367 | fn | ensureLogsDir | (private) | `func (l *FileRequestLogger) ensureLogsDir() err...` |
| 383 | fn | generateFilename | (private) | `func (l *FileRequestLogger) generateFilename(ur...` |
| 420 | fn | sanitizeForFilename | (private) | `func (l *FileRequestLogger) sanitizeForFilename...` |
| 447 | fn | cleanupOldErrorLogs | (private) | `func (l *FileRequestLogger) cleanupOldErrorLogs...` |
| 496 | fn | writeRequestBodyTempFile | (private) | `func (l *FileRequestLogger) writeRequestBodyTem...` |
| 515 | fn | writeNonStreamingLog | (private) | `func (l *FileRequestLogger) writeNonStreamingLog(` |
| 549 | fn | writeRequestInfoWithBody | (private) | `func writeRequestInfoWithBody(` |
| 617 | fn | writeAPISection | (private) | `func writeAPISection(w io.Writer, sectionHeader...` |
| 654 | fn | writeAPIErrorResponses | (private) | `func writeAPIErrorResponses(w io.Writer, apiRes...` |
| 677 | fn | writeResponseSection | (private) | `func writeResponseSection(w io.Writer, statusCo...` |
| 735 | fn | formatLogContent | (private) | `func (l *FileRequestLogger) formatLogContent(ur...` |
| 804 | fn | decompressResponse | (private) | `func (l *FileRequestLogger) decompressResponse(...` |
| 841 | fn | decompressGzip | (private) | `func (l *FileRequestLogger) decompressGzip(data...` |
| 868 | fn | decompressDeflate | (private) | `func (l *FileRequestLogger) decompressDeflate(d...` |
| 892 | fn | decompressBrotli | (private) | `func (l *FileRequestLogger) decompressBrotli(da...` |
| 911 | fn | decompressZstd | (private) | `func (l *FileRequestLogger) decompressZstd(data...` |
| 936 | fn | formatRequestInfo | (private) | `func (l *FileRequestLogger) formatRequestInfo(u...` |
| 965 | struct | FileStreamingLogWriter | pub | - |
| 1022 | fn | WriteChunkAsync | pub | `func (w *FileStreamingLogWriter) WriteChunkAsyn...` |
| 1047 | fn | WriteStatus | pub | `func (w *FileStreamingLogWriter) WriteStatus(st...` |
| 1072 | fn | WriteAPIRequest | pub | `func (w *FileStreamingLogWriter) WriteAPIReques...` |
| 1087 | fn | WriteAPIResponse | pub | `func (w *FileStreamingLogWriter) WriteAPIRespon...` |
| 1095 | fn | SetFirstChunkTimestamp | pub | `func (w *FileStreamingLogWriter) SetFirstChunkT...` |
| 1107 | fn | Close | pub | `func (w *FileStreamingLogWriter) Close() error {` |
| 1150 | fn | asyncWriter | (private) | `func (w *FileStreamingLogWriter) asyncWriter() {` |
| 1184 | fn | writeFinalLog | (private) | `func (w *FileStreamingLogWriter) writeFinalLog(...` |
| 1208 | fn | cleanupTempFiles | (private) | `func (w *FileStreamingLogWriter) cleanupTempFil...` |
| 1226 | struct | NoOpStreamingLogWriter | pub | - |
| 1232 | fn | WriteChunkAsync | pub | `func (w *NoOpStreamingLogWriter) WriteChunkAsyn...` |
| 1242 | fn | WriteStatus | pub | `func (w *NoOpStreamingLogWriter) WriteStatus(_ ...` |
| 1253 | fn | WriteAPIRequest | pub | `func (w *NoOpStreamingLogWriter) WriteAPIReques...` |
| 1264 | fn | WriteAPIResponse | pub | `func (w *NoOpStreamingLogWriter) WriteAPIRespon...` |
| 1268 | fn | SetFirstChunkTimestamp | pub | `func (w *NoOpStreamingLogWriter) SetFirstChunkT...` |
| 1274 | fn | Close | pub | `func (w *NoOpStreamingLogWriter) Close() error ...` |

## Public API

### `NewFileRequestLogger`

```
func NewFileRequestLogger(enabled bool, logsDir string, configDir string, errorLogsMaxFiles int) *FileRequestLogger {
```

**Line:** 151 | **Kind:** fn

### `IsEnabled`

```
func (l *FileRequestLogger) IsEnabled() bool {
```

**Line:** 170 | **Kind:** fn

### `SetEnabled`

```
func (l *FileRequestLogger) SetEnabled(enabled bool) {
```

**Line:** 179 | **Kind:** fn

### `SetErrorLogsMaxFiles`

```
func (l *FileRequestLogger) SetErrorLogsMaxFiles(maxFiles int) {
```

**Line:** 184 | **Kind:** fn

### `LogRequest`

```
func (l *FileRequestLogger) LogRequest(url, method string, requestHeaders map[string][]string, body []byte, statusCode int, responseHeaders map[string][]string, response, apiRequest, apiResponse []byte, apiResponseErrors []*interfaces.ErrorMessage, requestID string, requestTimestamp, apiResponseTimestamp time.Time) error {
```

**Line:** 206 | **Kind:** fn

### `LogRequestWithOptions`

```
func (l *FileRequestLogger) LogRequestWithOptions(url, method string, requestHeaders map[string][]string, body []byte, statusCode int, responseHeaders map[string][]string, response, apiRequest, apiResponse []byte, apiResponseErrors []*interfaces.ErrorMessage, force bool, requestID string, requestTimestamp, apiResponseTimestamp time.Time) error {
```

**Line:** 212 | **Kind:** fn

### `LogStreamingRequest`

```
func (l *FileRequestLogger) LogStreamingRequest(url, method string, headers map[string][]string, body []byte, requestID string) (StreamingLogWriter, error) {
```

**Line:** 304 | **Kind:** fn

### `WriteChunkAsync`

```
func (w *FileStreamingLogWriter) WriteChunkAsync(chunk []byte) {
```

**Line:** 1022 | **Kind:** fn

### `WriteStatus`

```
func (w *FileStreamingLogWriter) WriteStatus(status int, headers map[string][]string) error {
```

**Line:** 1047 | **Kind:** fn

### `WriteAPIRequest`

```
func (w *FileStreamingLogWriter) WriteAPIRequest(apiRequest []byte) error {
```

**Line:** 1072 | **Kind:** fn

### `WriteAPIResponse`

```
func (w *FileStreamingLogWriter) WriteAPIResponse(apiResponse []byte) error {
```

**Line:** 1087 | **Kind:** fn

### `SetFirstChunkTimestamp`

```
func (w *FileStreamingLogWriter) SetFirstChunkTimestamp(timestamp time.Time) {
```

**Line:** 1095 | **Kind:** fn

### `Close`

```
func (w *FileStreamingLogWriter) Close() error {
```

**Line:** 1107 | **Kind:** fn

### `WriteChunkAsync`

```
func (w *NoOpStreamingLogWriter) WriteChunkAsync(_ []byte) {}
```

**Line:** 1232 | **Kind:** fn

### `WriteStatus`

```
func (w *NoOpStreamingLogWriter) WriteStatus(_ int, _ map[string][]string) error {
```

**Line:** 1242 | **Kind:** fn

### `WriteAPIRequest`

```
func (w *NoOpStreamingLogWriter) WriteAPIRequest(_ []byte) error {
```

**Line:** 1253 | **Kind:** fn

### `WriteAPIResponse`

```
func (w *NoOpStreamingLogWriter) WriteAPIResponse(_ []byte) error {
```

**Line:** 1264 | **Kind:** fn

### `SetFirstChunkTimestamp`

```
func (w *NoOpStreamingLogWriter) SetFirstChunkTimestamp(_ time.Time) {}
```

**Line:** 1268 | **Kind:** fn

### `Close`

```
func (w *NoOpStreamingLogWriter) Close() error { return nil }
```

**Line:** 1274 | **Kind:** fn

