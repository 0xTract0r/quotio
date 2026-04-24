# Memory

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

## Summary

| High 🔴 | Medium 🟡 | Low 🟢 |
| 2 | 0 | 23 |

## 🔴 High Priority

### `RULE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/claude_executor.go:1421)

> Anthropic's documentation, cache prefixes are created in order: tools -> system -> messages.

### `INVARIANT` (third_party/CLIProxyAPIPlus/internal/runtime/executor/iflow_executor.go:292)

> a usage record exists even if the stream never emitted usage data.

## 🟢 Low Priority

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/iflow_executor.go:169)

> TranslateNonStream uses req.Model (original with suffix) to preserve

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kimi_executor.go:161)

> TranslateNonStream uses req.Model (original with suffix) to preserve

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:147)

> Temporary() is deprecated but still useful for some error types

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:380)

> OIDC "region" is NOT used - it's for token refresh, not API calls

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:397)

> OIDC "region" field is NOT used for API endpoint

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:416)

> OIDC "region" is NOT used - it's for token refresh, not API calls

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:677)

> currentOrigin and kiroPayload are built inside executeWithRetry for each endpoint

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:1019)

> This code is unreachable because all paths in the inner loop

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:1117)

> currentOrigin and kiroPayload are built inside executeStreamWithRetry for each endpoint

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:1154)

> Delay is NOT applied during streaming response - only before initial request

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:1432)

> This code is unreachable because all paths in the inner loop

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:1778)

> Request building functions moved to internal/translator/kiro/claude/kiro_claude_request.go

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:2082)

> This is separate from token counts - it's AWS billing units

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:2286)

> prelude[8:12] is prelude_crc - we read it but don't validate (no CRC check per requirements)

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:2448)

> Response building functions moved to internal/translator/kiro/claude/kiro_claude_response.go

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:2467)

> Duplicate content filtering removed - it was causing legitimate repeated

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:2879)

> Duplicate content filtering was removed because it incorrectly

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:3277)

> We don't close the thinking block here - it will be closed when we see

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:3566)

> The effective input context is ~170k (200k - 30k reserved for output)

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:3628)

> Claude SSE event builders moved to internal/translator/kiro/claude/kiro_claude_stream.go

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:3696)

> This check has a design limitation - it reads from the auth object passed in,

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:4345)

> We skip the "model decides to search" step because Claude Code already

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/qwen_executor.go:305)

> TranslateNonStream uses req.Model (original with suffix) to preserve

