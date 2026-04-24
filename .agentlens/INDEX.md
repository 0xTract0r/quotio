# Project

## Fork Notice

Before using this generated index as your primary understanding of the repository, read:

1. [`../docs/project/AI_ONBOARDING.md`](../docs/project/AI_ONBOARDING.md)
2. [`../docs/project/current-fork-delta.md`](../docs/project/current-fork-delta.md)
3. [`../AGENTS.md`](../AGENTS.md)
4. [`../docs/README.md`](../docs/README.md)

Reason:

- this repository is a heavily customized Quotio fork, not a vanilla upstream checkout
- `CLIProxyAPIPlus` and `Cli-Proxy-API-Management-Center` are part of the effective architecture
- account-level proxy / managed headers / upstream verification work has already been implemented
- `Identity Package` exists but is still only phase-1 host-side work

Use `.agentlens` as a code index, not as the only source of truth for recent fork-specific behavior.

## Reading Protocol

**Start here**, then navigate to specific modules.

1. Read this INDEX for overview
2. Go to relevant `modules/{name}/MODULE.md`
3. Check module's `outline.md` for large files
4. Check module's `memory.md` for warnings

## Entry Points

- `third_party/CLIProxyAPIPlus/cmd/fetch_antigravity_models/main.go`
- `third_party/CLIProxyAPIPlus/cmd/server/main.go`
- `third_party/CLIProxyAPIPlus/examples/custom-provider/main.go`
- `third_party/CLIProxyAPIPlus/examples/http-request/main.go`
- `third_party/CLIProxyAPIPlus/examples/translator/main.go`

## ⚠️ Critical Alerts

**9** high-priority warnings across 4 modules. Check each module's `memory.md` for details.

## Modules

| Module | Type | Files | Warnings | Hub |
| ------ | ---- | ----- | -------- | --- |
| [root](modules/root/MODULE.md) | root | 271 | 3 |  |
| [Quotio/Models](modules/Quotio-Models/MODULE.md) | implicit | 16 | 2 |  |
| [Quotio/Services/Antigravity](modules/Quotio-Services-Antigravity/MODULE.md) | implicit | 7 | - |  |
| [Quotio/Services/QuotaFetchers](modules/Quotio-Services-QuotaFetchers/MODULE.md) | implicit | 9 | - |  |
| [Quotio/Views/Components](modules/Quotio-Views-Components/MODULE.md) | implicit | 30 | - |  |
| [Quotio/Views/Onboarding](modules/Quotio-Views-Onboarding/MODULE.md) | implicit | 6 | - |  |
| [Quotio/Views/Screens](modules/Quotio-Views-Screens/MODULE.md) | implicit | 9 | - |  |
| [third_party/CLIProxyAPIPlus/internal/api/handlers/management](modules/third_party-CLIProxyAPIPlus-internal-api-handlers-management/MODULE.md) | implicit | 21 | - |  |
| [third_party/CLIProxyAPIPlus/internal/api/modules/amp](modules/third_party-CLIProxyAPIPlus-internal-api-modules-amp/MODULE.md) | implicit | 16 | 2 |  |
| [third_party/CLIProxyAPIPlus/internal/auth/claude](modules/third_party-CLIProxyAPIPlus-internal-auth-claude/MODULE.md) | implicit | 8 | - |  |
| [third_party/CLIProxyAPIPlus/internal/auth/codex](modules/third_party-CLIProxyAPIPlus-internal-auth-codex/MODULE.md) | implicit | 10 | - |  |
| [third_party/CLIProxyAPIPlus/internal/auth/copilot](modules/third_party-CLIProxyAPIPlus-internal-auth-copilot/MODULE.md) | implicit | 5 | - |  |
| [third_party/CLIProxyAPIPlus/internal/auth/kiro](modules/third_party-CLIProxyAPIPlus-internal-auth-kiro/MODULE.md) | implicit | 27 | - |  |
| [third_party/CLIProxyAPIPlus/internal/cmd](modules/third_party-CLIProxyAPIPlus-internal-cmd/MODULE.md) | implicit | 16 | - |  |
| [third_party/CLIProxyAPIPlus/internal/config](modules/third_party-CLIProxyAPIPlus-internal-config/MODULE.md) | implicit | 7 | - |  |
| [third_party/CLIProxyAPIPlus/internal/logging](modules/third_party-CLIProxyAPIPlus-internal-logging/MODULE.md) | implicit | 7 | - |  |
| [third_party/CLIProxyAPIPlus/internal/misc](modules/third_party-CLIProxyAPIPlus-internal-misc/MODULE.md) | implicit | 6 | - |  |
| [third_party/CLIProxyAPIPlus/internal/registry](modules/third_party-CLIProxyAPIPlus-internal-registry/MODULE.md) | implicit | 8 | - |  |
| [third_party/CLIProxyAPIPlus/internal/runtime/executor](modules/third_party-CLIProxyAPIPlus-internal-runtime-executor/MODULE.md) | implicit | 42 | 2 |  |
| [third_party/CLIProxyAPIPlus/internal/thinking](modules/third_party-CLIProxyAPIPlus-internal-thinking/MODULE.md) | implicit | 9 | - |  |
| [third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude](modules/third_party-CLIProxyAPIPlus-internal-translator-antigravity-claude/MODULE.md) | implicit | 5 | - |  |
| [third_party/CLIProxyAPIPlus/internal/translator/antigravity/gemini](modules/third_party-CLIProxyAPIPlus-internal-translator-antigravity-gemini/MODULE.md) | implicit | 5 | - |  |
| [third_party/CLIProxyAPIPlus/internal/translator/codex/openai/chat-completions](modules/third_party-CLIProxyAPIPlus-internal-translator-codex-openai-chat-completions/MODULE.md) | implicit | 5 | - |  |
| [third_party/CLIProxyAPIPlus/internal/translator/kiro/claude](modules/third_party-CLIProxyAPIPlus-internal-translator-kiro-claude/MODULE.md) | implicit | 9 | - |  |
| [third_party/CLIProxyAPIPlus/internal/translator/kiro/openai](modules/third_party-CLIProxyAPIPlus-internal-translator-kiro-openai/MODULE.md) | implicit | 6 | - |  |
| [third_party/CLIProxyAPIPlus/internal/tui](modules/third_party-CLIProxyAPIPlus-internal-tui/MODULE.md) | implicit | 13 | - |  |
| [third_party/CLIProxyAPIPlus/internal/util](modules/third_party-CLIProxyAPIPlus-internal-util/MODULE.md) | implicit | 14 | - |  |
| [third_party/CLIProxyAPIPlus/internal/watcher/diff](modules/third_party-CLIProxyAPIPlus-internal-watcher-diff/MODULE.md) | implicit | 11 | - |  |
| [third_party/CLIProxyAPIPlus/internal/watcher/synthesizer](modules/third_party-CLIProxyAPIPlus-internal-watcher-synthesizer/MODULE.md) | implicit | 8 | - |  |
| [third_party/CLIProxyAPIPlus/sdk/api/handlers](modules/third_party-CLIProxyAPIPlus-sdk-api-handlers/MODULE.md) | implicit | 9 | - |  |
| [third_party/CLIProxyAPIPlus/sdk/api/handlers/openai](modules/third_party-CLIProxyAPIPlus-sdk-api-handlers-openai/MODULE.md) | implicit | 8 | - |  |
| [third_party/CLIProxyAPIPlus/sdk/auth](modules/third_party-CLIProxyAPIPlus-sdk-auth/MODULE.md) | implicit | 20 | - |  |
| [third_party/CLIProxyAPIPlus/sdk/translator](modules/third_party-CLIProxyAPIPlus-sdk-translator/MODULE.md) | implicit | 6 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/common](modules/third_party-Cli-Proxy-API-Management-Center-src-components-common/MODULE.md) | implicit | 6 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/config](modules/third_party-Cli-Proxy-API-Management-Center-src-components-config/MODULE.md) | implicit | 5 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/modelAlias](modules/third_party-Cli-Proxy-API-Management-Center-src-components-modelAlias/MODULE.md) | js/ts | 6 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/providers](modules/third_party-Cli-Proxy-API-Management-Center-src-components-providers/MODULE.md) | js/ts | 6 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/providers/AmpcodeSection](modules/third_party-Cli-Proxy-API-Management-Center-src-components-providers-AmpcodeSection/MODULE.md) | js/ts | 2 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/providers/ClaudeSection](modules/third_party-Cli-Proxy-API-Management-Center-src-components-providers-ClaudeSection/MODULE.md) | js/ts | 2 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/providers/CodexSection](modules/third_party-Cli-Proxy-API-Management-Center-src-components-providers-CodexSection/MODULE.md) | js/ts | 2 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/providers/GeminiSection](modules/third_party-Cli-Proxy-API-Management-Center-src-components-providers-GeminiSection/MODULE.md) | js/ts | 2 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/providers/OpenAISection](modules/third_party-Cli-Proxy-API-Management-Center-src-components-providers-OpenAISection/MODULE.md) | js/ts | 2 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/providers/ProviderNav](modules/third_party-Cli-Proxy-API-Management-Center-src-components-providers-ProviderNav/MODULE.md) | js/ts | 2 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/providers/VertexSection](modules/third_party-Cli-Proxy-API-Management-Center-src-components-providers-VertexSection/MODULE.md) | js/ts | 2 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/quota](modules/third_party-Cli-Proxy-API-Management-Center-src-components-quota/MODULE.md) | js/ts | 6 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/ui](modules/third_party-Cli-Proxy-API-Management-Center-src-components-ui/MODULE.md) | implicit | 14 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/usage](modules/third_party-Cli-Proxy-API-Management-Center-src-components-usage/MODULE.md) | js/ts | 12 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/components/usage/hooks](modules/third_party-Cli-Proxy-API-Management-Center-src-components-usage-hooks/MODULE.md) | js/ts | 4 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/features/authFiles/components](modules/third_party-Cli-Proxy-API-Management-Center-src-features-authFiles-components/MODULE.md) | implicit | 9 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/features/authFiles/hooks](modules/third_party-Cli-Proxy-API-Management-Center-src-features-authFiles-hooks/MODULE.md) | implicit | 7 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/hooks](modules/third_party-Cli-Proxy-API-Management-Center-src-hooks/MODULE.md) | js/ts | 11 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/i18n](modules/third_party-Cli-Proxy-API-Management-Center-src-i18n/MODULE.md) | js/ts | 1 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/pages/hooks](modules/third_party-Cli-Proxy-API-Management-Center-src-pages-hooks/MODULE.md) | implicit | 5 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/services/api](modules/third_party-Cli-Proxy-API-Management-Center-src-services-api/MODULE.md) | js/ts | 16 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/stores](modules/third_party-Cli-Proxy-API-Management-Center-src-stores/MODULE.md) | js/ts | 11 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/types](modules/third_party-Cli-Proxy-API-Management-Center-src-types/MODULE.md) | js/ts | 15 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/utils/quota](modules/third_party-Cli-Proxy-API-Management-Center-src-utils-quota/MODULE.md) | js/ts | 7 | - |  |
| [third_party/Cli-Proxy-API-Management-Center/src/utils/usage](modules/third_party-Cli-Proxy-API-Management-Center-src-utils-usage/MODULE.md) | js/ts | 3 | - |  |

---

*Generated by [agentlens](https://github.com/nguyenphutrong/agentlens)*
