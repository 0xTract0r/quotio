# Memory

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

## Summary

| High 🔴 | Medium 🟡 | Low 🟢 |
| 5 | 0 | 49 |

## 🔴 High Priority

### `WARNING` (Quotio/Services/LaunchAtLoginManager.swift:97)

> if app is not in /Applications (registration may fail or be non-persistent)

### `DEPRECATED` (third_party/CLIProxyAPIPlus/internal/api/modules/modules.go:27)

> Use RouteModuleV2 for new modules. This interface is kept for

### `RULE` (third_party/CLIProxyAPIPlus/internal/auth/qwen/qwen_auth.go:257)

> OAuth RFC 8628, handle standard polling responses

### `RULE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/claude_executor.go:1762)

> Anthropic's documentation, cache prefixes are created in order: tools -> system -> messages.

### `INVARIANT` (third_party/CLIProxyAPIPlus/internal/runtime/executor/iflow_executor.go:292)

> a usage record exists even if the stream never emitted usage data.

## 🟢 Low Priority

### `NOTE` (Quotio/Services/AgentDetectionService.swift:16)

> Only checks file existence (metadata), does NOT read file content

### `NOTE` (Quotio/Services/AgentDetectionService.swift:92)

> May not work in GUI apps due to limited PATH inheritance

### `NOTE` (Quotio/Services/AgentDetectionService.swift:98)

> Only checks file existence (metadata), does NOT read file content

### `NOTE` (Quotio/Services/CLIExecutor.swift:33)

> Only checks file existence (metadata), does NOT read file content

### `NOTE` (Quotio/Services/Proxy/CLIProxyManager.swift:281)

> Bridge mode default is registered in AppDelegate.applicationDidFinishLaunching()

### `NOTE` (Quotio/Services/Proxy/CLIProxyManager.swift:478)

> Changes take effect after proxy restart (CLIProxyAPI does not support live routing API)

### `NOTE` (Quotio/Services/Proxy/CLIProxyManager.swift:1732)

> Notification is handled by AtomFeedUpdateService polling

### `NOTE` (Quotio/ViewModels/AgentSetupViewModel.swift:461)

> Actual fallback resolution happens at request time in ProxyBridge

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:408)

> checkForProxyUpgrade() is now called inside startProxy()

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:582)

> Cursor and Trae are NOT auto-refreshed - user must use "Scan for IDEs" (issue #29)

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:590)

> Cursor and Trae removed from auto-refresh to address privacy concerns (issue #29)

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:1515)

> Cursor and Trae removed from auto-refresh (issue #29)

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:1540)

> Cursor and Trae require explicit user scan (issue #29)

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:1550)

> Cursor and Trae removed - require explicit scan (issue #29)

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:1605)

> Don't call detectActiveAccount() here - already set by switch operation

### `NOTE` (third_party/CLIProxyAPIPlus/cmd/server/main.go:559)

> This config mutation is safe - auth commands exit after completion

### `NOTE` (third_party/CLIProxyAPIPlus/cmd/server/main.go:567)

> This config mutation is safe - auth commands exit after completion

### `NOTE` (third_party/CLIProxyAPIPlus/internal/cache/signature_cache_test.go:194)

> TTL expiration test is tricky to test without mocking time

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/iflow_executor.go:169)

> TranslateNonStream uses req.Model (original with suffix) to preserve

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kimi_executor.go:173)

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

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:2874)

> Duplicate content filtering was removed because it incorrectly

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:3188)

> We don't close the thinking block here - it will be closed when we see

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:3457)

> The effective input context is ~170k (200k - 30k reserved for output)

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:3511)

> Claude SSE event builders moved to internal/translator/kiro/claude/kiro_claude_stream.go

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:3579)

> This check has a design limitation - it reads from the auth object passed in,

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/kiro_executor.go:4228)

> We skip the "model decides to search" step because Claude Code already

### `NOTE` (third_party/CLIProxyAPIPlus/internal/runtime/executor/qwen_executor.go:305)

> TranslateNonStream uses req.Model (original with suffix) to preserve

### `NOTE` (third_party/CLIProxyAPIPlus/internal/store/objectstore.go:389)

> We intentionally do NOT use os.RemoveAll here.

### `NOTE` (third_party/CLIProxyAPIPlus/internal/thinking/provider/iflow/apply.go:112)

> clear_thinking is only set for GLM models when thinking is enabled.

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/claude/openai/responses/claude_openai-responses_response.go:445)

> extremely large responses may require increasing the buffer

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/codex/gemini/codex_gemini_request.go:245)

> Google official Python SDK sends snake_case fields (thinking_level/thinking_budget).

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/gemini/openai/responses/gemini_openai-responses_request.go:18)

> modelName and stream parameters are part of the fixed method signature

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/gemini/openai/responses/gemini_openai-responses_request.go:150)

> In Responses format, model outputs may appear as content items with type "output_text"

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/kiro/common/message_merge.go:13)

> Tool messages are NOT merged because each has a unique tool_call_id that must be preserved.

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/openai/gemini/openai_gemini_request.go:86)

> Google official Python SDK sends snake_case fields (thinking_level/thinking_budget).

