# Docs Index

`docs/` 现按主题收成 4 组，优先从这里进入，不再在根目录平铺查找。

如果你是第一次进入这个 fork 的 AI，请先读：

1. [`project/current-fork-delta.md`](./project/current-fork-delta.md)
2. [`project/project-overview-prd.md`](./project/project-overview-prd.md)

不要先把仓库理解成“原生 Quotio 未改造版”。

## `fingerprint/`

多身份、账户级指纹、UA / headers、请求链路和迁移方案。

- [`multi-identity-fingerprint-summary.md`](./fingerprint/multi-identity-fingerprint-summary.md): 多身份指纹与 CLIProxyAPIPlus 二次开发总览
- [`account-fingerprint-architecture.md`](./fingerprint/account-fingerprint-architecture.md): 当前实现、链路与边界
- [`oauth-account-fingerprint-IMPLEMENTATION-GUIDE.md`](./fingerprint/oauth-account-fingerprint-IMPLEMENTATION-GUIDE.md): 身份包路线的当前实现指引与后续续做入口

## `operations/`

开发测试、隔离运行、正式迁移与回滚操作。

- [`isolated-dev-testing.md`](./operations/isolated-dev-testing.md): Dev / Prod 隔离测试方案
- [`dev-to-production-promotion.md`](./operations/dev-to-production-promotion.md): 从开发版收口到正式版的操作说明
- [`linux-cliproxyapi-plus-deploy.md`](./operations/linux-cliproxyapi-plus-deploy.md): Linux 服务器上部署远程 `CLIProxyAPIPlus` 的实际记录与维护入口

## `submodules/`

第三方核心与管理后台子模块的维护入口。

- [`cliproxy-plus-submodule.md`](./submodules/cliproxy-plus-submodule.md): `CLIProxyAPIPlus` 子模块维护说明
- [`management-center-submodule.md`](./submodules/management-center-submodule.md): `Cli-Proxy-API-Management-Center` 子模块维护说明

## `project/`

Quotio 自身项目概览、运行边界与代码入口。

- [`current-fork-delta.md`](./project/current-fork-delta.md): 当前 fork 和原生上游相比，哪些地方已经被二次开发改过
- [`project-overview-prd.md`](./project/project-overview-prd.md): 项目 PRD

说明：
- 旧的 `codebase-summary.md` 与 `codebase-structure-architecture-code-standards.md` 已并入当前 `project-overview-prd.md`
- 更细的开发规则以仓库根目录 `AGENTS.md` 与 `.agentlens/INDEX.md` 为准
