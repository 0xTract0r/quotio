# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 1 large files in this module.

## third_party/CLIProxyAPIPlus/internal/logging/request_logger.go (1274 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 33 | interface | RequestLogger | pub |
| 77 | interface | StreamingLogWriter | pub |
| 129 | struct | FileRequestLogger | pub |
| 151 | fn | NewFileRequestLogger | pub |
| 170 | fn | IsEnabled | pub |
| 179 | fn | SetEnabled | pub |
| 184 | fn | SetErrorLogsMaxFiles | pub |
| 206 | fn | LogRequest | pub |
| 212 | fn | LogRequestWithOptions | pub |
| 216 | fn | logRequest | (private) |
| 304 | fn | LogStreamingRequest | pub |
| 359 | fn | generateErrorFilename | (private) |
| 367 | fn | ensureLogsDir | (private) |
| 383 | fn | generateFilename | (private) |
| 420 | fn | sanitizeForFilename | (private) |
| 447 | fn | cleanupOldErrorLogs | (private) |
| 496 | fn | writeRequestBodyTempFile | (private) |
| 515 | fn | writeNonStreamingLog | (private) |
| 549 | fn | writeRequestInfoWithBody | (private) |
| 617 | fn | writeAPISection | (private) |
| 654 | fn | writeAPIErrorResponses | (private) |
| 677 | fn | writeResponseSection | (private) |
| 735 | fn | formatLogContent | (private) |
| 804 | fn | decompressResponse | (private) |
| 841 | fn | decompressGzip | (private) |
| 868 | fn | decompressDeflate | (private) |
| 892 | fn | decompressBrotli | (private) |
| 911 | fn | decompressZstd | (private) |
| 936 | fn | formatRequestInfo | (private) |
| 965 | struct | FileStreamingLogWriter | pub |
| 1022 | fn | WriteChunkAsync | pub |
| 1047 | fn | WriteStatus | pub |
| 1072 | fn | WriteAPIRequest | pub |
| 1087 | fn | WriteAPIResponse | pub |
| 1095 | fn | SetFirstChunkTimestamp | pub |
| 1107 | fn | Close | pub |
| 1150 | fn | asyncWriter | (private) |
| 1184 | fn | writeFinalLog | (private) |
| 1208 | fn | cleanupTempFiles | (private) |
| 1226 | struct | NoOpStreamingLogWriter | pub |
| 1232 | fn | WriteChunkAsync | pub |
| 1242 | fn | WriteStatus | pub |
| 1253 | fn | WriteAPIRequest | pub |
| 1264 | fn | WriteAPIResponse | pub |
| 1268 | fn | SetFirstChunkTimestamp | pub |
| 1274 | fn | Close | pub |

