# Memory

[← Back to MODULE](MODULE.md) | [← Back to INDEX](../../INDEX.md)

## Summary

| High 🔴 | Medium 🟡 | Low 🟢 |
| 3 | 0 | 26 |

## 🔴 High Priority

### `WARNING` (Quotio/Services/LaunchAtLoginManager.swift:97)

> if app is not in /Applications (registration may fail or be non-persistent)

### `DEPRECATED` (third_party/CLIProxyAPIPlus/internal/api/modules/modules.go:27)

> Use RouteModuleV2 for new modules. This interface is kept for

### `RULE` (third_party/CLIProxyAPIPlus/internal/auth/qwen/qwen_auth.go:257)

> OAuth RFC 8628, handle standard polling responses

## 🟢 Low Priority

### `NOTE` (Quotio/Services/AgentDetectionService.swift:16)

> Only checks file existence (metadata), does NOT read file content

### `NOTE` (Quotio/Services/AgentDetectionService.swift:92)

> May not work in GUI apps due to limited PATH inheritance

### `NOTE` (Quotio/Services/AgentDetectionService.swift:98)

> Only checks file existence (metadata), does NOT read file content

### `NOTE` (Quotio/Services/CLIExecutor.swift:33)

> Only checks file existence (metadata), does NOT read file content

### `NOTE` (Quotio/Services/Proxy/CLIProxyManager.swift:278)

> Bridge mode default is registered in AppDelegate.applicationDidFinishLaunching()

### `NOTE` (Quotio/Services/Proxy/CLIProxyManager.swift:396)

> Changes take effect after proxy restart (CLIProxyAPI does not support live routing API)

### `NOTE` (Quotio/Services/Proxy/CLIProxyManager.swift:1589)

> Notification is handled by AtomFeedUpdateService polling

### `NOTE` (Quotio/ViewModels/AgentSetupViewModel.swift:461)

> Actual fallback resolution happens at request time in ProxyBridge

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:405)

> checkForProxyUpgrade() is now called inside startProxy()

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:558)

> Cursor and Trae are NOT auto-refreshed - user must use "Scan for IDEs" (issue #29)

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:566)

> Cursor and Trae removed from auto-refresh to address privacy concerns (issue #29)

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:1462)

> Cursor and Trae removed from auto-refresh (issue #29)

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:1487)

> Cursor and Trae require explicit user scan (issue #29)

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:1497)

> Cursor and Trae removed - require explicit scan (issue #29)

### `NOTE` (Quotio/ViewModels/QuotaViewModel.swift:1552)

> Don't call detectActiveAccount() here - already set by switch operation

### `NOTE` (third_party/CLIProxyAPIPlus/cmd/server/main.go:559)

> This config mutation is safe - auth commands exit after completion

### `NOTE` (third_party/CLIProxyAPIPlus/cmd/server/main.go:567)

> This config mutation is safe - auth commands exit after completion

### `NOTE` (third_party/CLIProxyAPIPlus/internal/cache/signature_cache_test.go:190)

> TTL expiration test is tricky to test without mocking time

### `NOTE` (third_party/CLIProxyAPIPlus/internal/store/objectstore.go:389)

> We intentionally do NOT use os.RemoveAll here.

### `NOTE` (third_party/CLIProxyAPIPlus/internal/thinking/provider/iflow/apply.go:112)

> clear_thinking is only set for GLM models when thinking is enabled.

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/claude/openai/responses/claude_openai-responses_response.go:444)

> extremely large responses may require increasing the buffer

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/codex/gemini/codex_gemini_request.go:245)

> Google official Python SDK sends snake_case fields (thinking_level/thinking_budget).

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/gemini/openai/responses/gemini_openai-responses_request.go:17)

> modelName and stream parameters are part of the fixed method signature

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/gemini/openai/responses/gemini_openai-responses_request.go:151)

> In Responses format, model outputs may appear as content items with type "output_text"

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/kiro/common/message_merge.go:13)

> Tool messages are NOT merged because each has a unique tool_call_id that must be preserved.

### `NOTE` (third_party/CLIProxyAPIPlus/internal/translator/openai/gemini/openai_gemini_request.go:86)

> Google official Python SDK sends snake_case fields (thinking_level/thinking_budget).

