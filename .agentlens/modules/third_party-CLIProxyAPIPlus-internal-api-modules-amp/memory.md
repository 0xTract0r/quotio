# Memory

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

## Summary

| High 🔴 | Medium 🟡 | Low 🟢 |
| 2 | 0 | 4 |

## 🔴 High Priority

### `DEPRECATED` (third_party/CLIProxyAPIPlus/internal/api/modules/amp/amp.go:69)

> Use New with options instead.

### `SAFETY` (third_party/CLIProxyAPIPlus/internal/api/modules/amp/response_rewriter.go:89)

> cap: avoid unbounded buffering on large responses.

## 🟢 Low Priority

### `NOTE` (third_party/CLIProxyAPIPlus/internal/api/modules/amp/model_mapping.go:107)

> Detailed routing log is handled by logAmpRouting in fallback_handlers.go

### `NOTE` (third_party/CLIProxyAPIPlus/internal/api/modules/amp/proxy.go:96)

> We do NOT filter Anthropic-Beta headers in the proxy path

### `NOTE` (third_party/CLIProxyAPIPlus/internal/api/modules/amp/proxy.go:236)

> We only treat text/event-stream as streaming. Chunked transfer encoding

### `NOTE` (third_party/CLIProxyAPIPlus/internal/api/modules/amp/routes.go:327)

> Gemini handler extracts model from URL path, so fallback logic needs special handling

