# AI Onboarding

最后更新：2026-04-24

这不是原生上游 Quotio。进入这个仓库时，先把它理解成一个已经围绕 `CLIProxyAPIPlus` 持续做过二次开发的 Quotio fork。

## 60 秒内先知道这些

- 有效架构不是只有 macOS 宿主，还包括 `third_party/CLIProxyAPIPlus` 和 `third_party/Cli-Proxy-API-Management-Center`
- `third_party/CLIProxyAPIPlus` 当前 fork remote 是 `0xTract0r/CLIProxyAPIPlus`，但它的主线 upstream 应按 `router-for-me/CLIProxyAPI` 理解；`router-for-me/CLIProxyAPIPlus` 截至 `2026-04-24` 已不可访问，只能作为历史 Plus 仓库名保留，不应再被当成当前 upstream
- 已经做过并落过文档的能力：账户级 `proxy_url`、账户级托管 `headers`、Claude / Codex 真实上游验证链路、dev / prod 运行时隔离、正式迁移 / 回滚脚本
- 远端模式现在分成 `remote-core` 和 `remote-relay`：前者直连远端 core，后者保留本机 localhost relay；两者的 Providers、API Keys、Logs、usage 真源都在远端 core
- 还没完成的能力：`Identity Package` 目前只是宿主侧模型 / 服务 / UI 的 phase-1，不等于请求已按账号强制绑定 identity，也不等于 TLS / ClientHello 已按账号真实生效
- 本机生产运行面是活状态：`~/Library/Application Support/Quotio`、`~/.cli-proxy-api`、`18317/28317` 默认都按生产对待，不要直接拿来做实验

## 先读哪些

- 所有新 AI：[`../../AGENTS.md`](../../AGENTS.md) 和 [`current-fork-delta.md`](./current-fork-delta.md)
- 想看仓库级任务路由和长期记忆：[`../repo-knowledge-map.md`](../repo-knowledge-map.md) 和 [`../repo-memory-ledger.md`](../repo-memory-ledger.md)
- 想看文档导航：[`../README.md`](../README.md)
- 想按代码模块找入口：[`../../.agentlens/INDEX.md`](../../.agentlens/INDEX.md)

这两份仓库级文档分工不同：

- `repo-knowledge-map.md` 负责回答“先看哪里”
- `repo-memory-ledger.md` 负责回答“哪些长期边界要记住”

## 按任务类型路由

- 宿主 UI / 账号管理：[`project-overview-prd.md`](./project-overview-prd.md)、[`../fingerprint/account-fingerprint-architecture.md`](../fingerprint/account-fingerprint-architecture.md)
- `remote-core` / `remote-relay` / localhost relay：[`current-fork-delta.md`](./current-fork-delta.md)、[`../operations/remote-relay-ui-checklist.md`](../operations/remote-relay-ui-checklist.md)、[`../operations/remote-core-maintenance.md`](../operations/remote-core-maintenance.md)
- proxy core / runtime / 指纹链路：[`../submodules/cliproxy-plus-submodule.md`](../submodules/cliproxy-plus-submodule.md)、[`../fingerprint/claude-request-chain.md`](../fingerprint/claude-request-chain.md)、[`../fingerprint/account-clienthello-transport-prd.md`](../fingerprint/account-clienthello-transport-prd.md)
- 管理后台 / Web 管理页：[`../submodules/management-center-submodule.md`](../submodules/management-center-submodule.md)
- dev / prod 隔离、联调、迁移、回滚：[`../operations/isolated-dev-testing.md`](../operations/isolated-dev-testing.md)、[`../operations/dev-to-production-promotion.md`](../operations/dev-to-production-promotion.md)

## 一句话结论

先假设“很多关键能力已经做过，但 Identity Package 强绑定和 TLS 账号级落地还没完成”，再开始读具体代码或文档。
