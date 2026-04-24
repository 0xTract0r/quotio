# AI Agent Instructions

## Fork Notice

Before trusting this generated index as the current project truth, read:

1. [`../docs/project/AI_ONBOARDING.md`](../docs/project/AI_ONBOARDING.md)
2. [`../docs/project/current-fork-delta.md`](../docs/project/current-fork-delta.md)
3. [`../AGENTS.md`](../AGENTS.md)
4. [`../docs/README.md`](../docs/README.md)

Important:

- this repo is a customized Quotio fork, not a plain upstream checkout
- `.agentlens` is useful for navigation, but fork-specific behavior may have advanced beyond the generated snapshot
- if the `Generated` timestamp or embedded `Git HEAD` is old, confirm behavior from the real files before making assumptions

## Reading Protocol

Follow this protocol to understand the codebase efficiently:

1. **Start with INDEX.md** - Get the project overview and module routing table
2. **Navigate to relevant module** - Go to `modules/{name}/MODULE.md` for the area you're working on
3. **Check memory.md before editing** - Review warnings and TODOs for that module
4. **Use outline.md for large files** - Find symbols without reading entire files
5. **Check imports.md for dependencies** - Understand module relationships before changes
6. **Review files/*.md for complex files** - Deep documentation for high-complexity files

### Documentation Structure

```
.agentlens/
├── INDEX.md              # Start here - project overview
├── AGENT.md              # This file - AI instructions
├── modules/
│   └── {module-slug}/
│       ├── MODULE.md     # Module summary and file list
│       ├── outline.md    # Symbol maps for large files
│       ├── memory.md     # Warnings and TODOs
│       └── imports.md    # Dependencies
└── files/                # Deep docs for complex files
```

## Freshness Check

**Generated:** 2026-04-24T08:02:35Z
**Git HEAD:** `e632740`

### How to verify freshness

1. Compare the Git HEAD above with current: `git rev-parse --short HEAD`
2. If they differ significantly, docs may be outdated
3. Check file modification times vs. the Generated timestamp

## Available Modules

| Module | Files | Type | Description |
| ------ | ----- | ---- | ----------- |
| `` | 271 | root | Module |
| `Quotio/Models` | 16 | implicit | Data models |
| `Quotio/Services/Antigravity` | 7 | implicit | Module |
| `Quotio/Services/QuotaFetchers` | 9 | implicit | Module |
| `Quotio/Views/Components` | 30 | implicit | UI components |
| `Quotio/Views/Onboarding` | 6 | implicit | Module |
| `Quotio/Views/Screens` | 9 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management` | 21 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/api/modules/amp` | 16 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/auth/claude` | 8 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/auth/codex` | 10 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/auth/copilot` | 5 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/auth/kiro` | 27 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/cmd` | 16 | implicit | Command-line interface |
| `third_party/CLIProxyAPIPlus/internal/config` | 7 | implicit | Configuration |
| `third_party/CLIProxyAPIPlus/internal/logging` | 7 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/misc` | 6 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/registry` | 8 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/runtime/executor` | 42 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/thinking` | 9 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude` | 5 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/antigravity/gemini` | 5 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/codex/openai/chat-completions` | 5 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude` | 9 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/openai` | 6 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/tui` | 13 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/util` | 14 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/watcher/diff` | 11 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/watcher/synthesizer` | 8 | implicit | Module |
| `third_party/CLIProxyAPIPlus/sdk/api/handlers` | 9 | implicit | Request handlers |
| `third_party/CLIProxyAPIPlus/sdk/api/handlers/openai` | 8 | implicit | Module |
| `third_party/CLIProxyAPIPlus/sdk/auth` | 20 | implicit | Authentication logic |
| `third_party/CLIProxyAPIPlus/sdk/translator` | 6 | implicit | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/common` | 6 | implicit | Utility functions |
| `third_party/Cli-Proxy-API-Management-Center/src/components/config` | 5 | implicit | Configuration |
| `third_party/Cli-Proxy-API-Management-Center/src/components/modelAlias` | 6 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/providers` | 6 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/providers/AmpcodeSection` | 2 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/providers/ClaudeSection` | 2 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/providers/CodexSection` | 2 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/providers/GeminiSection` | 2 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/providers/OpenAISection` | 2 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/providers/ProviderNav` | 2 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/providers/VertexSection` | 2 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/quota` | 6 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/ui` | 14 | implicit | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/usage` | 12 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/components/usage/hooks` | 4 | js/ts | React hooks |
| `third_party/Cli-Proxy-API-Management-Center/src/features/authFiles/components` | 9 | implicit | UI components |
| `third_party/Cli-Proxy-API-Management-Center/src/features/authFiles/hooks` | 7 | implicit | React hooks |
| `third_party/Cli-Proxy-API-Management-Center/src/hooks` | 11 | js/ts | React hooks |
| `third_party/Cli-Proxy-API-Management-Center/src/i18n` | 1 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/pages/hooks` | 5 | implicit | React hooks |
| `third_party/Cli-Proxy-API-Management-Center/src/services/api` | 16 | js/ts | API endpoints |
| `third_party/Cli-Proxy-API-Management-Center/src/stores` | 11 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/types` | 15 | js/ts | Type definitions |
| `third_party/Cli-Proxy-API-Management-Center/src/utils/quota` | 7 | js/ts | Module |
| `third_party/Cli-Proxy-API-Management-Center/src/utils/usage` | 3 | js/ts | Module |

## When Docs Seem Stale

If documentation seems outdated or inconsistent with the code:

1. **Regenerate docs:**
   ```bash
   bunx @agentlens/cli
   ```

2. **Regenerate with diff mode** (faster, only changed files):
   ```bash
   bunx @agentlens/cli --diff master
   ```

3. **Check freshness status:**
   ```bash
   bunx @agentlens/cli --check
   ```

4. **Force full regeneration** (ignore cache):
   ```bash
   bunx @agentlens/cli --force
   ```

## Quick Reference

| Metric | Value |
| ------ | ----- |
| Total files | 807 |
| Modules | 58 |
| Warnings | 9 |

---

*Generated by [agentlens](https://github.com/nguyenphutrong/agentlens)*
