# AGENTS.md - Quotio Development Guidelines

**Generated:** 2026-01-03 | **Commit:** 1995a85 | **Branch:** master

## Overview

Native macOS menu bar app (SwiftUI) for managing CLIProxyAPI - local proxy server for AI coding agents. Multi-provider OAuth, quota tracking, CLI tool configuration.

**Stack:** Swift 6, SwiftUI, macOS 15+, Xcode 16+, Sparkle (auto-update)

## First Read For AI Contributors

Before doing any feature work, do **not** assume this repository is still a vanilla upstream Quotio checkout.

Read in this order:

1. [`docs/project/AI_ONBOARDING.md`](docs/project/AI_ONBOARDING.md)
2. [`docs/project/current-fork-delta.md`](docs/project/current-fork-delta.md)
3. [`docs/README.md`](docs/README.md)
4. Then the task-specific docs under `docs/fingerprint/`, `docs/operations/`, or `docs/submodules/`

Current fork-specific realities that often get missed:

- this repo now depends on both `third_party/CLIProxyAPIPlus` and `third_party/Cli-Proxy-API-Management-Center`
- account-level `proxy_url`, managed `headers`, and upstream verification workflows have already been implemented and documented
- `Identity Package` exists, but only as a phase-1 host-side model/UI layer, not a fully enforced runtime binding system
- production runtime paths and ports on the local machine must be treated as live state, not disposable dev fixtures

## Structure

```
Quotio/
├── QuotioApp.swift           # @main entry + AppDelegate + ContentView
├── Models/                   # Enums, Codable structs, settings managers
├── Services/                 # Business logic, API clients, actors (→ AGENTS.md)
├── ViewModels/               # @Observable state (QuotaViewModel, AgentSetupViewModel)
├── Views/Components/         # Reusable UI (→ Views/AGENTS.md)
├── Views/Screens/            # Full-page views
└── Assets.xcassets/          # Icons (provider icons, menu bar icons)
Config/                       # .xcconfig files (Debug/Release/Local)
scripts/                      # Build, release, notarize (→ AGENTS.md)
docs/                         # Architecture docs
```

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Add AI provider | `Models/Models.swift` → `AIProvider` enum | Add case + computed properties |
| Add quota fetcher | `Services/*QuotaFetcher.swift` | Actor pattern, see existing fetchers |
| Add CLI agent | `Models/AgentModels.swift` → `CLIAgent` enum | + detection in `AgentDetectionService` |
| UI component | `Views/Components/` | Reuse `ProviderIcon`, `AccountRow`, `QuotaCard` |
| New screen | `Views/Screens/` | Add to `NavigationPage` enum in Models |
| OAuth flow | `ViewModels/QuotaViewModel.swift` | `startOAuth()`, poll pattern |
| Menu bar | `Services/StatusBarManager.swift` | Singleton, uses `StatusBarMenuBuilder` |

## Code Map (Key Symbols)

| Symbol | Type | Location | Role |
|--------|------|----------|------|
| `CLIProxyManager` | Class | Services/ | Proxy lifecycle, binary management, auth commands |
| `QuotaViewModel` | Class | ViewModels/ | Central state: quotas, auth, providers, logs |
| `ManagementAPIClient` | Actor | Services/ | HTTP client for CLIProxyAPI |
| `AIProvider` | Enum | Models/ | Provider definitions (13 providers) |
| `CLIAgent` | Enum | Models/ | CLI agent definitions (6 agents) |
| `StatusBarManager` | Class | Services/ | Menu bar icon and menu |
| `ProxyBridge` | Class | Services/ | TCP bridge layer for connection management |

## Build Commands

```bash
# Debug build
xcodebuild -project Quotio.xcodeproj -scheme Quotio -configuration Debug build

# Release build
./scripts/build.sh

# Full release (build + package + notarize + appcast)
./scripts/release.sh

# Check compile errors
xcodebuild -project Quotio.xcodeproj -scheme Quotio -configuration Debug build 2>&1 | head -50
```

## Conventions

### Swift 6 Concurrency (CRITICAL)
```swift
// UI classes: @MainActor @Observable
@MainActor @Observable
final class StatusBarManager {
    static let shared = StatusBarManager()
    private init() {}
}

// Thread-safe services: actor
actor ManagementAPIClient { ... }

// Data crossing boundaries: Sendable
struct AuthFile: Codable, Sendable { ... }
```

### Observable Pattern
```swift
// ViewModel
@MainActor @Observable
final class QuotaViewModel { var isLoading = false }

// View injection
@Environment(QuotaViewModel.self) private var viewModel

// Binding
@Bindable var vm = viewModel
```

### Codable with snake_case
```swift
struct AuthFile: Codable, Sendable {
    let statusMessage: String?
    enum CodingKeys: String, CodingKey {
        case statusMessage = "status_message"
    }
}
```

### View Structure
```swift
struct DashboardScreen: View {
    @Environment(QuotaViewModel.self) private var viewModel
    
    // MARK: - Computed Properties
    private var isReady: Bool { ... }
    
    // MARK: - Body
    var body: some View { ... }
    
    // MARK: - Subviews
    private var headerSection: some View { ... }
}
```

## Anti-Patterns (NEVER)

| Pattern | Why Bad | Instead |
|---------|---------|---------|
| `Text("localhost:\(port)")` | Locale formats as "8.217" | `Text("localhost:" + String(port))` |
| Direct `UserDefaults` in View | Inconsistent | `@AppStorage("key")` |
| Blocking main thread | UI freeze | `Task { await ... }` |
| Force unwrap optionals | Crashes | Guard/if-let |
| Hardcoded strings | No i18n | `"key".localized()` |

## Critical Invariants

From code comments - **never violate**:
- ProxyStorageManager: **never delete current** version
- AgentConfigurationService: backups **never overwritten**
- ProxyBridge: target host **always localhost**
- CLIProxyManager: base URL **always points to CLIProxyAPI directly**

## Runtime Safety

### Production Runtime (CRITICAL)

Treat the following as live production state on the local machine:
- `~/Library/Application Support/Quotio/`
- `~/.cli-proxy-api`
- the running listeners on `18317/28317`

Never do any of the following unless the user explicitly approves that exact action in the current turn:
- replace `~/Library/Application Support/Quotio/CLIProxyAPI`
- modify production `config.yaml` for debugging
- stop, restart, or hot-swap the production core process
- restart the production app

Important:
- restarting the production core counts as a production-impacting action even if `Quotio.app` itself is not restarted
- any CLIProxyAPI / CLIProxyAPIPlus change must be verified in `Quotio Dev` first, with isolated runtime paths and ports
- required dev-first gate before any production promotion: basic Claude/Codex requests succeed, MITM verification shows expected `MATCH`, and rollback steps are prepared
- do not perform production runtime experiments from `master`; use a dedicated worktree/branch first

If the user says production traffic must not be interrupted, interpret that as a hard ban on touching the production app or production core process.

## CLIProxyAPIPlus Source Of Truth

Treat the project submodule as the only development source of truth for `CLIProxyAPIPlus`:

- canonical path: `third_party/CLIProxyAPIPlus`
- canonical build entry: `./scripts/manage-cliproxy-plus.sh build`
- canonical Quotio-side binary output: `build/CLIProxyAPIPlus/CLIProxyAPI`

Never treat any of the following as an implementation source of truth:

- `/tmp/...`
- ad-hoc cloned directories outside the repository
- previously patched standalone binaries with no matching submodule commit

Allowed use of external copies such as `/tmp/...`:

- read-only historical comparison
- emergency diff/reference when the submodule is temporarily unavailable

Disallowed use of external copies such as `/tmp/...`:

- making new code changes there
- treating them as the branch to continue from
- building release/promotable artifacts from them
- citing them in docs as the future implementation path

For any future `CLIProxyAPIPlus` implementation task:

- start from a dedicated implementation worktree, not from a docs-only branch
- initialize `third_party/CLIProxyAPIPlus` in that worktree before coding
- commit changes in the submodule first, then update the submodule pointer in the main repo
- if the submodule is missing/uninitialized, stop and fix the submodule state rather than drifting to `/tmp`

## Key Patterns

### Parallel Async Fetching
```swift
async let files = client.fetchAuthFiles()
async let stats = client.fetchUsageStats()
(self.authFiles, self.usageStats) = try await (files, stats)
```

### Mode-Aware Logic
```swift
if modeManager.isQuotaOnlyMode {
    // Direct fetch without proxy
} else {
    // Proxy mode
}
```

### Weak References (prevent retain cycles)
```swift
weak var viewModel: QuotaViewModel?
```

## Testing

No automated tests. Manual testing:
- Run with `Cmd + R`
- Verify light/dark mode
- Test menu bar integration
- Check all providers OAuth
- Validate localization

For proxy-core changes, extend manual testing with:
- validate the new core in `Quotio Dev` before any production discussion
- verify Claude/Codex request path end-to-end, not just Quotio UI logs
- use MITM or equivalent upstream capture for header/fingerprint acceptance
- keep production verification read-only unless the user explicitly schedules a promotion window

### Proxy/Fingerprint Lessons

- For account-fingerprint work, the acceptance target is the provider-facing upstream request, not the local CLI request into Quotio and not CLIProxyAPI request logs alone.
- MITM validation scripts must print enough evidence to disambiguate “latest flow” from “old flow”:
  - flow timestamp
  - provider URL
  - key upstream headers
  - request body prefix
  - clear note that response output is only a prefix, not the full reply
- Anthropic and Codex may use different real upstream domains than expected from surface API docs:
  - Claude validation currently targets `api.anthropic.com/v1/messages`
  - Codex validation must also consider `chatgpt.com/backend-api/codex/responses`
- If a validation script reads existing MITM flow files instead of triggering a new request, the script output must say so explicitly.
- When a claim depends on runtime behavior, prefer one of:
  - MITM capture of the provider-facing request
  - direct upstream request logs emitted by the core before `httpClient.Do(...)`
  Do not claim success from UI state or saved auth metadata alone.

### Production Promotion Rules

- Replacing the on-disk production `CLIProxyAPI` binary does not affect the already running production core process.
- Any production core promotion must be treated as a two-step operation:
  1. swap the on-disk binary with backup prepared
  2. perform exactly one controlled proxy restart in a user-approved window
- Promotion/rollback automation for production must default to dry-run and require an explicit execution flag.
- If the user forbids production interruption, do not improvise with process kills or manual binary swaps. Prepare scripts, backups, hashes, rollback steps, and wait for an explicit promotion window.

### Incident Retrospective

- A previous failure mode in this repository was replacing or restarting the production core during active use and breaking local AI traffic.
- Future tasks touching `CLIProxyAPI`, `CLIProxyAPIPlus`, auth routing, ports, or production verification must leave a recoverable local trail:
  - update `.ai/todos.md`
  - document backup/rollback paths
  - document the exact promotion gate and verification method

## Agent Coordination

- For this repository, subagents should default to the same model tier as the main agent for implementation, verification, architecture review, and any production-affecting judgment.
- Do not use mini/smaller models for critical code changes, acceptance decisions, release/promotion decisions, or incident handling.
- Smaller models are only acceptable for low-risk support work such as bounded file discovery or mechanical summarization, and their output must still be reviewed by the main agent before use.

## Git Workflow

**Never commit to `master`**. Branch naming:
- `feature/<name>` - New features
- `bugfix/<desc>` - Bug fixes
- `refactor/<scope>` - Refactoring
- `docs/<content>` - Documentation

Additional guardrails:
- If the current checkout is `master`, do not start implementation there. Create or reuse a dedicated worktree/branch first unless the task is read-only.
- Do not require a fresh worktree for every tiny change. Small, low-risk edits such as a narrowly scoped doc wording fix or typo fix may stay in the current non-`master` task branch when no parallel work is happening.
- Default to creating or reusing a dedicated worktree before any non-trivial code change, long-running task, proxy/core change, submodule/dependency change, runtime-isolation change, or mixed AI/human collaboration.
- Once a task already has a dedicated worktree, continue that task only in the same worktree until it is merged or explicitly abandoned.
- Any proxy-core change, submodule change, auth/keychain/port change, release-flow change, or production-adjacent debugging must start in a dedicated worktree.
- Do not continue feature implementation on `master` once a dedicated worktree/branch exists for the task.
- Do not combine runtime experimentation on the production app with uncommitted feature work in `master`.
- A docs-only worktree/branch is not a valid place to continue implementation. If a task moves from planning to coding, open a new implementation worktree and keep the docs branch read-only.

## Dependencies

- **Sparkle** - Auto-update (SPM)

## Config Files

| File | Purpose |
|------|---------|
| `Config/Debug.xcconfig` | Debug build settings |
| `Config/Release.xcconfig` | Release build settings |
| `Config/Local.xcconfig` | Developer overrides (gitignored) |
| `Quotio/Info.plist` | App metadata, URL schemes |
| `Quotio/Quotio.entitlements` | Sandbox disabled, network enabled |

# Agentmap Integration

This project uses **agentlens** for AI-optimized documentation.
`agentlens` is a code-to-doc indexer: it scans the repository and generates a navigable map under `.agentlens/`, including module summaries, symbol outlines, import maps, and memory notes. Treat it as a routing layer that helps you avoid re-reading the whole repo for every task, not as a substitute for checking the target files you are about to change.

## Reading Protocol

Follow this order to understand the codebase efficiently:

1. **Start here**: `.agentlens/INDEX.md` - Project overview and module routing
2. **AI instructions**: `.agentlens/AGENT.md` - How to use the documentation
3. **Module details**: `.agentlens/modules/{module}/MODULE.md` - File lists and entry points
4. **Before editing**: Check `.agentlens/modules/{module}/memory.md` for warnings/TODOs

For new feature work, you normally do **not** need to rescan the entire codebase:
- Use `.agentlens` to route to the relevant module first
- Read only the target files and nearby dependencies for the feature you are changing
- Still verify the current implementation in code if the generated docs look older than `HEAD`

## Documentation Structure

```
.agentlens/
├── INDEX.md              # Start here - global routing table
├── AGENT.md              # AI agent instructions
├── modules/
│   └── {module-slug}/
│       ├── MODULE.md     # Module summary
│       ├── outline.md    # Symbol maps for large files
│       ├── memory.md     # Warnings, TODOs, business rules
│       └── imports.md    # Dependencies
└── files/                # Deep docs for complex files
```

## During Development

- Use `.agentlens/modules/{module}/outline.md` to find symbols in large files
- Check `.agentlens/modules/{module}/imports.md` for dependencies
- For complex files, see `.agentlens/files/{file-slug}.md`
- If `.agentlens` freshness is uncertain, treat it as an index and confirm behavior from the actual source before editing

## Commands

| Task | Command |
|------|---------|
| Regenerate docs | `agentlens` |
| Fast update (changed only) | `agentlens --diff main` |
| Check if stale | `agentlens --check` |
| Force full regen | `agentlens --force` |

## Key Patterns

- **Module boundaries**: `mod.rs` (Rust), `index.ts` (TS), `__init__.py` (Python)
- **Large files**: >500 lines, have symbol outlines
- **Complex files**: >30 symbols, have L2 deep docs
- **Hub files**: Imported by 3+ files, marked with 🔗
- **Memory markers**: TODO, FIXME, WARNING, SAFETY, RULE

---
*Generated by [agentlens](https://github.com/nguyenphutrong/agentlens)*
