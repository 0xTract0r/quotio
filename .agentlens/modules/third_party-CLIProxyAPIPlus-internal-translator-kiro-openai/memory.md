# Memory

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

## Summary

| High 🔴 | Medium 🟡 | Low 🟢 |
| 0 | 0 | 5 |

## 🟢 Low Priority

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/kiro/openai/kiro_openai_request.go:128)

> The actual payload building happens in the executor, this just passes through

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/kiro/openai/kiro_openai_request.go:287)

> Kiro API doesn't actually use max_tokens for thinking budget

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/kiro/openai/kiro_openai_request.go:933)

> When tool_choice is "none", we should ideally not pass tools at all

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/kiro/openai/kiro_openai_stream.go:37)

> This returns raw JSON data without "data:" prefix.

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/kiro/openai/kiro_openai_stream.go:136)

> This returns raw "[DONE]" without "data:" prefix.

