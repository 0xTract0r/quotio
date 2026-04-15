# 当前 Fork 改动总览

最后更新：2026-04-15

如果你是第一次进入仓库的 AI，先读更短的首屏入口：[`AI_ONBOARDING.md`](./AI_ONBOARDING.md)。

## 先看这个的原因

如果你是新进入仓库的 AI，不要把这个项目理解成“原生上游 Quotio”。

当前仓库已经是持续二次开发后的状态。很多关键能力、运行边界和第三方模块接入方式，已经和最初的上游形态不同。

进入仓库后，建议阅读顺序：

1. 本文
2. 根目录 `AGENTS.md`
3. `docs/README.md`
4. 再根据任务进入具体专项文档

## 当前 fork 最关键的差异

### 1. 这不只是一个 macOS GUI

当前仓库是三层组合：

- Quotio 宿主应用
- `third_party/CLIProxyAPIPlus`
- `third_party/Cli-Proxy-API-Management-Center`

也就是说，很多功能不是只在 Swift UI 层完成，而是宿主 + proxy core + 管理后台联动。

### 2. Proxy core 的开发真源已经固定

`CLIProxyAPIPlus` 相关实现不能再按“外部临时目录”或“历史单独 clone”理解。

当前唯一真源是：

- `third_party/CLIProxyAPIPlus`

配套入口：

- `docs/submodules/cliproxy-plus-submodule.md`
- `scripts/manage-cliproxy-plus.sh`

### 3. 管理后台已经不是空白

当前仓库已经接入：

- `third_party/Cli-Proxy-API-Management-Center`

它不是独立后端；真正的管理接口还是 proxy core 暴露。

配套入口：

- `docs/submodules/management-center-submodule.md`
- `scripts/start-management-center.sh`

### 4. 多身份指纹不是停留在想法

这轮二次开发已经做过的关键能力包括：

- 账户级 `proxy_url`
- 账户级托管 `headers`
- Claude / Codex 真实上游请求验证链路
- dev / prod 运行时隔离
- 正式版迁移 / 回滚脚本

这部分当前真源：

- `docs/fingerprint/multi-identity-fingerprint-summary.md`
- `docs/fingerprint/account-fingerprint-architecture.md`
- `docs/fingerprint/claude-request-chain.md`
- `docs/fingerprint/account-clienthello-transport-prd.md`

### 5. Identity Package 已做了第一阶段，但还没变成真实强绑定

当前代码里已经存在：

- `IdentityPackageModels`
- `IdentityPackageService`
- `IdentityPackagesScreen`
- 绑定 / 导入 / 生成相关 UI

但它目前仍然主要是宿主侧模型与界面，不等于：

- 普通请求已按账号强制选择 identity package
- TLS / ClientHello 已经真实按账号生效

配套入口：

- `docs/fingerprint/oauth-account-fingerprint-IMPLEMENTATION-GUIDE.md`

### 6. 生产运行面必须按本机生产系统对待

下面这些路径和端口默认视为本机生产状态：

- `~/Library/Application Support/Quotio`
- `~/.cli-proxy-api`
- `18317/28317`

任何 proxy/core 相关任务，都应先在 dev runtime 或独立 worktree 验证，不要直接假设可以在主线或正式运行面上试验。

## 新 AI 最容易犯的误判

1. 把仓库当成原生上游 Quotio，只盯 Swift UI 层，不看子模块
2. 以为 `proxy_url` / `headers` / 备注这些 UI 字段是新加但尚未落 runtime，实际上这批能力已经做过并验证过
3. 以为 Identity Package 已经是完成态，实际上它还只是第一阶段
4. 在 `master` 或正式运行面上直接做 proxy/core 实验
5. 把 `/tmp/...` 或外部 clone 当成 `CLIProxyAPIPlus` 的继续开发真源

## 开始新功能前，最少先读哪些文档

### 做宿主 UI / 账号管理

- `docs/project/project-overview-prd.md`
- `docs/fingerprint/account-fingerprint-architecture.md`

### 做 proxy core / runtime 行为

- `docs/submodules/cliproxy-plus-submodule.md`
- `docs/fingerprint/claude-request-chain.md`
- `docs/fingerprint/account-clienthello-transport-prd.md`

### 做管理后台 / Web 管理页

- `docs/submodules/management-center-submodule.md`

### 做迁移、联调、正式收口

- `docs/operations/isolated-dev-testing.md`
- `docs/operations/dev-to-production-promotion.md`

## 一句话结论

任何新 AI 进入这个仓库时，都应该先把它理解成：

“一个已经围绕 CLIProxyAPIPlus 做过较多二次开发的 Quotio fork，而不是未改造的原生 Quotio GUI 仓库。”
