# Repo Knowledge Map

最后更新：2026-04-24

这份文档回答一个问题：在这个仓库里，遇到某类任务时，应该先看哪里。

它是仓库级人工导航，不替代 `.agentlens`。`.agentlens` 负责代码索引；这份文档负责把“任务类型 -> 推荐入口”讲清楚。

## 什么时候更新这份文档

- 新增了长期维护入口文档、专项说明或子模块维护入口
- 推荐阅读顺序发生变化
- 新增了一个会长期存在的任务类型或运行模式，导致旧入口不够用
- 收敛时发现 AI / 人类总是在同一类任务上“不知道先看哪里”

如果只是文案润色、临时实验记录或一次性会话结论，不需要更新这里。

## 先读什么

第一次进入这个仓库，建议按这个顺序：

1. [`project/AI_ONBOARDING.md`](./project/AI_ONBOARDING.md)
2. [`project/current-fork-delta.md`](./project/current-fork-delta.md)
3. [`repo-memory-ledger.md`](./repo-memory-ledger.md)
4. [`README.md`](./README.md)
5. [`.agentlens/INDEX.md`](../.agentlens/INDEX.md)

## 按任务类型找入口

### 1. 刚接手仓库，不确定这是不是原生 Quotio

先看：

- [`project/AI_ONBOARDING.md`](./project/AI_ONBOARDING.md)
- [`project/current-fork-delta.md`](./project/current-fork-delta.md)
- [`repo-memory-ledger.md`](./repo-memory-ledger.md)

### 2. 想按代码模块定位实现入口

先看：

- [`.agentlens/INDEX.md`](../.agentlens/INDEX.md)
- [`.agentlens/AGENT.md`](../.agentlens/AGENT.md)

说明：

- `.agentlens` 是代码地图和符号索引
- 如果它和当前 `HEAD` 看起来不一致，把它当导航，不要把它当最终行为真源

### 3. 做 Quotio 宿主 UI、账号管理、菜单栏或本地配置

先看：

- [`project/project-overview-prd.md`](./project/project-overview-prd.md)
- [`fingerprint/account-fingerprint-architecture.md`](./fingerprint/account-fingerprint-architecture.md)
- [`.agentlens/INDEX.md`](../.agentlens/INDEX.md)

### 4. 做 `CLIProxyAPIPlus`、auth、模型、routing、runtime 行为

先看：

- [`submodules/cliproxy-plus-submodule.md`](./submodules/cliproxy-plus-submodule.md)
- [`project/current-fork-delta.md`](./project/current-fork-delta.md)
- [`operations/isolated-dev-testing.md`](./operations/isolated-dev-testing.md)
- [`operations/linux-cliproxyapi-plus-deploy.md`](./operations/linux-cliproxyapi-plus-deploy.md)

### 5. 做管理后台 / `management.html` / Web 管理页

先看：

- [`submodules/management-center-submodule.md`](./submodules/management-center-submodule.md)
- [`project/current-fork-delta.md`](./project/current-fork-delta.md)
- [`operations/remote-core-maintenance.md`](./operations/remote-core-maintenance.md)

### 6. 做 dev / prod 隔离、迁移、回滚、远端 core 运维

先看：

- [`operations/isolated-dev-testing.md`](./operations/isolated-dev-testing.md)
- [`operations/dev-to-production-promotion.md`](./operations/dev-to-production-promotion.md)
- [`operations/remote-core-maintenance.md`](./operations/remote-core-maintenance.md)
- [`operations/linux-cliproxyapi-plus-deploy.md`](./operations/linux-cliproxyapi-plus-deploy.md)

### 7. 做指纹、OAuth、上游请求验证或 Identity Package 相关判断

先看：

- [`fingerprint/multi-identity-fingerprint-summary.md`](./fingerprint/multi-identity-fingerprint-summary.md)
- [`fingerprint/account-fingerprint-architecture.md`](./fingerprint/account-fingerprint-architecture.md)
- [`fingerprint/claude-request-chain.md`](./fingerprint/claude-request-chain.md)
- [`fingerprint/oauth-account-fingerprint-IMPLEMENTATION-GUIDE.md`](./fingerprint/oauth-account-fingerprint-IMPLEMENTATION-GUIDE.md)

### 8. 排查“模型列表不同步”或“前端 / core / CLI picker 不一致”

先看：

- [`project/current-fork-delta.md`](./project/current-fork-delta.md)
- [`submodules/cliproxy-plus-submodule.md`](./submodules/cliproxy-plus-submodule.md)
- [`repo-memory-ledger.md`](./repo-memory-ledger.md)

记住：

- core `/v1/models`
- Quotio 宿主缓存模型
- Codex CLI TUI `/model`

这三层不是同一个东西。

### 9. 收敛文档、补仓库级知识、判断项目地图是否要更新

先看：

- [`README.md`](./README.md)
- [`project/AI_ONBOARDING.md`](./project/AI_ONBOARDING.md)
- [`repo-memory-ledger.md`](./repo-memory-ledger.md)
- 根目录 `AGENTS.md`
- [`.agentlens/INDEX.md`](../.agentlens/INDEX.md)

## 文档分层

- `project/AI_ONBOARDING.md`：60 秒首屏结论
- `project/current-fork-delta.md`：这个 fork 和原生上游有什么关键差异
- `repo-knowledge-map.md`：遇到某类任务先看哪里
- `repo-memory-ledger.md`：有哪些长期事实、边界和教训要记住
- `docs/README.md`：按主题组织的文档目录
- `.agentlens`：生成式代码地图，用来做代码导航
