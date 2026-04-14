# Quotio 项目当前概览

最后更新：2026-04-15

## 1. 这个仓库现在是什么

Quotio 是一个原生 macOS 菜单栏应用，用来托管本地 AI 代理网关，并把账号管理、配额查看、CLI 配置、日志与运维入口收在同一个宿主里。

这份文档只保留当前仍有效的项目事实，不再重复旧的生成式代码摘要。

## 2. 当前真实范围

当前仓库不是单纯的 GUI 壳，而是三层组合：

1. Quotio 宿主应用
   - SwiftUI + AppKit
   - 负责本地界面、状态管理、代理生命周期、Keychain、CLI 配置
2. `CLIProxyAPIPlus` 子模块
   - 路径：`third_party/CLIProxyAPIPlus`
   - 负责真实请求转发、账号 auth、路由、上游 headers / proxy 接入
3. `Cli-Proxy-API-Management-Center` 子模块
   - 路径：`third_party/Cli-Proxy-API-Management-Center`
   - 负责可复用的 Web 管理后台

## 3. Quotio 当前已经覆盖的能力

- 多 provider 账号管理与 OAuth / 导入流程
- 配额查看、日志查看、API key 管理
- CLI agent 自动配置与手工配置
- 菜单栏状态与通知
- 开发版 / 正式版运行时隔离
- 账户级 `proxy_url`、`headers`、备注等本地管理
- 多身份指纹相关的宿主侧 UI、持久化与验证脚本
- Identity Package 第一阶段本地模型与页面骨架

## 4. 目前代码里确认存在的 provider 与 agent

### Providers

来自 `Quotio/Models/Models.swift` 当前 `AIProvider` 枚举：

- Gemini CLI
- Claude Code
- Codex (OpenAI)
- Qwen Code
- iFlow
- Antigravity
- Vertex AI
- Kiro
- GitHub Copilot
- Cursor
- Trae
- GLM
- Warp

### CLI Agents

来自 `Quotio/Models/AgentModels.swift` 当前 `CLIAgent` 枚举：

- Claude Code
- Codex CLI
- Gemini CLI
- Amp CLI
- OpenCode
- Factory Droid

## 5. 运行模式与运行面

当前有两层容易混淆的概念：

### App Mode

由 `AppMode` / `OperatingMode` 控制：

- `full`
- `quotaOnly`

### Runtime Profile

由 `RuntimeProfile` 控制运行时命名空间：

- 正式版默认运行面
  - `~/Library/Application Support/Quotio`
  - `~/.cli-proxy-api`
  - 端口 `18317/28317`
- 非正式 bundle id 会自动切到独立目录、独立 auth、独立 Keychain 命名空间与独立默认端口

这是本仓库后续做任何 proxy/core 改动时都必须遵守的基础边界。

## 6. 当前值得直接看的入口

如果你现在要继续开发，不要从旧 PRD 或旧摘要开始，优先看这些：

### 仓库总规则

- 根目录 `AGENTS.md`
- `.agentlens/INDEX.md`

### Quotio 主仓库

- `Quotio/Models/Models.swift`
- `Quotio/ViewModels/QuotaViewModel.swift`
- `Quotio/Views/Screens/ProvidersScreen.swift`
- `Quotio/Services/ManagementAPIClient.swift`
- `Quotio/Services/Proxy/CLIProxyManager.swift`
- `Quotio/Services/Proxy/ProxyBridge.swift`

### 多身份 / 指纹相关

- `docs/fingerprint/multi-identity-fingerprint-summary.md`
- `docs/fingerprint/account-fingerprint-architecture.md`
- `docs/fingerprint/account-clienthello-transport-prd.md`
- `docs/fingerprint/claude-request-chain.md`

### 运维与收口

- `docs/operations/isolated-dev-testing.md`
- `docs/operations/dev-to-production-promotion.md`

### 子模块维护

- `docs/submodules/cliproxy-plus-submodule.md`
- `docs/submodules/management-center-submodule.md`

## 7. 当前项目结构里最容易踩错的点

- 正式运行面是本机生产状态，不能把 `18317/28317`、`~/Library/Application Support/Quotio`、`~/.cli-proxy-api` 当测试目录
- `CLIProxyAPIPlus` 的开发真源只能是 `third_party/CLIProxyAPIPlus`
- 管理后台子模块不是单独后端；真正的管理接口还是由 proxy core 暴露
- Identity Package 相关代码虽然已经存在，但“本地 UI / 模型存在”不等于“运行时强绑定已生效”

## 8. 这份文档替代了什么

旧的：

- `codebase-summary.md`
- `codebase-structure-architecture-code-standards.md`

已经并入本文件；更细的代码规范与运行约束统一以根目录 `AGENTS.md` 为准。
- Minimal UI and resource usage
- Direct quota fetching via CLI commands
- Similar to CodexBar / ccusage

**Visible Pages:**

- Dashboard
- Quota
- Accounts (renamed from Providers)
- Settings
- About

### Mode Selection

- Users select their preferred mode during onboarding
- Mode can be changed anytime via Settings
- Switching from Full to Quota-Only automatically stops the proxy

---

## System Requirements

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Architecture** | Apple Silicon or Intel x64 | Apple Silicon |
| **Memory** | 4 GB RAM | 8 GB RAM |
| **Storage** | 100 MB available | 200 MB available |

### Software Requirements

| Requirement | Version |
|-------------|---------|
| **macOS** | 15.0 (Sequoia) or later |
| **Xcode** (for development) | 16.0+ |
| **Swift** (for development) | 6.0+ |

### Network Requirements

- Internet connection for OAuth authentication
- Localhost access for proxy server (port 8317 default)
- Access to GitHub API for binary downloads

### Optional Dependencies

- **Sparkle Framework**: Auto-updates (bundled via Swift Package Manager)
- **CLI Tools**: Required if using agent configuration features

---

## Technical Architecture Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                      Quotio (SwiftUI)                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Dashboard  │  │   Quota     │  │     Providers       │  │
│  │   Screen    │  │   Screen    │  │      Screen         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Agents    │  │  API Keys   │  │      Settings       │  │
│  │   Screen    │  │   Screen    │  │       Screen        │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    QuotaViewModel                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ CLIProxy    │  │ Management  │  │    StatusBar        │  │
│  │  Manager    │  │ APIClient   │  │     Manager         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Quota     │  │   Agent     │  │   Notification      │  │
│  │  Fetchers   │  │  Services   │  │     Manager         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    CLIProxyAPI Binary                        │
│            (Local HTTP Proxy on port 8317)                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
          ┌────────────────────────────────────┐
          │         AI Provider APIs           │
          │  (Gemini, Claude, OpenAI, etc.)    │
          └────────────────────────────────────┘
```

---

## Roadmap (Future Considerations)

1. **Automated Testing**: Implement unit and UI tests
2. **Enhanced Analytics**: Usage trends and predictions
3. **Team Features**: Shared account management
4. **Plugin System**: Custom provider integrations
5. **Cloud Sync**: Settings synchronization across devices

---

## References

- [CLIProxyAPI GitHub Repository](https://github.com/router-for-me/CLIProxyAPIPlus)
- [Sparkle Framework Documentation](https://sparkle-project.org/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
