# Outline

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

Symbol maps for 1 large files in this module.

## third_party/CLIProxyAPIPlus/internal/logging/request_logger.go (1500 lines)

| Line | Kind | Name | Visibility |
| ---- | ---- | ---- | ---------- |
| 34 | interface | RequestLogger | pub |
| 80 | interface | StreamingLogWriter | pub |
| 142 | struct | FileRequestLogger | pub |
| 164 | fn | NewFileRequestLogger | pub |
| 183 | fn | IsEnabled | pub |
| 192 | fn | SetEnabled | pub |
| 197 | fn | SetErrorLogsMaxFiles | pub |
| 219 | fn | LogRequest | pub |
| 225 | fn | LogRequestWithOptions | pub |
| 229 | fn | logRequest | (private) |
| 319 | fn | LogStreamingRequest | pub |
| 374 | fn | generateErrorFilename | (private) |
| 382 | fn | ensureLogsDir | (private) |
| 398 | fn | generateFilename | (private) |
| 435 | fn | sanitizeForFilename | (private) |
| 462 | fn | cleanupOldErrorLogs | (private) |
| 511 | fn | writeRequestBodyTempFile | (private) |
| 530 | fn | writeNonStreamingLog | (private) |
| 581 | fn | writeRequestInfoWithBody | (private) |
| 673 | fn | countTrailingNewlinesBytes | (private) |
| 684 | fn | writeSectionSpacing | (private) |
| 693 | struct | trailingNewlineTrackingWriter | (private) |
| 698 | fn | Write | pub |
| 712 | fn | hasSectionPayload | (private) |
| 716 | fn | inferDownstreamTransport | (private) |
| 732 | fn | inferUpstreamTransport | (private) |
| 747 | fn | writeAPISection | (private) |
| 776 | fn | writeAPIErrorResponses | (private) |
| 804 | fn | writeResponseSection | (private) |
| 853 | fn | responseBodyStartsWithLeadingNewline | (private) |
| 882 | fn | formatLogContent | (private) |
| 988 | fn | decompressResponse | (private) |
| 1025 | fn | decompressGzip | (private) |
| 1052 | fn | decompressDeflate | (private) |
| 1076 | fn | decompressBrotli | (private) |
| 1095 | fn | decompressZstd | (private) |
| 1120 | fn | formatRequestInfo | (private) |
| 1159 | struct | FileStreamingLogWriter | pub |
| 1219 | fn | WriteChunkAsync | pub |
| 1244 | fn | WriteStatus | pub |
| 1269 | fn | WriteAPIRequest | pub |
| 1284 | fn | WriteAPIResponse | pub |
| 1299 | fn | WriteAPIWebsocketTimeline | pub |
| 1307 | fn | SetFirstChunkTimestamp | pub |
| 1319 | fn | Close | pub |
| 1362 | fn | asyncWriter | (private) |
| 1396 | fn | writeFinalLog | (private) |
| 1423 | fn | cleanupTempFiles | (private) |
| 1441 | struct | NoOpStreamingLogWriter | pub |
| 1447 | fn | WriteChunkAsync | pub |
| 1457 | fn | WriteStatus | pub |
| 1468 | fn | WriteAPIRequest | pub |
| 1479 | fn | WriteAPIResponse | pub |
| 1490 | fn | WriteAPIWebsocketTimeline | pub |
| 1494 | fn | SetFirstChunkTimestamp | pub |
| 1500 | fn | Close | pub |

