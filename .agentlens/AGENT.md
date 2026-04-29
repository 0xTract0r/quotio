# AI Agent Instructions

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

**Generated:** 2026-04-29T10:32:08Z
**Git HEAD:** `a3fb1af`

### How to verify freshness

1. Compare the Git HEAD above with current: `git rev-parse --short HEAD`
2. If they differ significantly, docs may be outdated
3. Check file modification times vs. the Generated timestamp

## Available Modules

| Module | Files | Type | Description |
| ------ | ----- | ---- | ----------- |
| `` | 281 | root | Module |
| `Quotio/Models` | 16 | implicit | Data models |
| `Quotio/Services/Antigravity` | 7 | implicit | Module |
| `Quotio/Services/QuotaFetchers` | 9 | implicit | Module |
| `Quotio/Views/Components` | 30 | implicit | UI components |
| `Quotio/Views/Onboarding` | 6 | implicit | Module |
| `Quotio/Views/Screens` | 9 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/api/handlers/management` | 28 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/api/modules/amp` | 16 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/auth/claude` | 9 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/auth/codex` | 10 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/auth/copilot` | 5 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/auth/kiro` | 27 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/cmd` | 16 | implicit | Command-line interface |
| `third_party/CLIProxyAPIPlus/internal/config` | 8 | implicit | Configuration |
| `third_party/CLIProxyAPIPlus/internal/logging` | 7 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/misc` | 7 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/registry` | 10 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/runtime/executor/helps` | 26 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/thinking` | 9 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/antigravity/claude` | 6 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/antigravity/gemini` | 5 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/claude/openai/chat-completions` | 5 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/codex/claude` | 5 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/codex/openai/chat-completions` | 5 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/claude` | 9 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/translator/kiro/openai` | 6 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/tui` | 14 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/util` | 14 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/watcher/diff` | 11 | implicit | Module |
| `third_party/CLIProxyAPIPlus/internal/watcher/synthesizer` | 8 | implicit | Module |
| `third_party/CLIProxyAPIPlus/sdk/api/handlers` | 10 | implicit | Request handlers |
| `third_party/CLIProxyAPIPlus/sdk/api/handlers/openai` | 11 | implicit | Module |
| `third_party/CLIProxyAPIPlus/sdk/auth` | 20 | implicit | Authentication logic |
| `third_party/CLIProxyAPIPlus/sdk/translator` | 8 | implicit | Module |
| `third_party/CLIProxyAPIPlus/test` | 5 | implicit | Test files |
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
| `third_party/Cli-Proxy-API-Management-Center/src/pages` | 23 | implicit | Page/view components |
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
   agentlens
   ```

2. **Regenerate with diff mode** (faster, only changed files):
   ```bash
   agentlens --diff main
   ```

3. **Check freshness status:**
   ```bash
   agentlens --check
   ```

4. **Force full regeneration** (ignore cache):
   ```bash
   agentlens --force
   ```

## Quick Reference

| Metric | Value |
| ------ | ----- |
| Total files | 859 |
| Modules | 62 |
| Warnings | 9 |

---

*Generated by [agentlens](https://github.com/nguyenphutrong/agentlens)*
