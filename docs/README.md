# Docs Index

`docs/` 现按主题收成 4 组，优先从这里进入，不再在根目录平铺查找。

## `fingerprint/`

多身份、账户级指纹、UA / headers、请求链路和迁移方案。

- [`multi-identity-fingerprint-summary.md`](./fingerprint/multi-identity-fingerprint-summary.md): 多身份指纹与 CLIProxyAPIPlus 二次开发总览
- [`account-fingerprint-architecture.md`](./fingerprint/account-fingerprint-architecture.md): 当前实现、链路与边界
- [`oauth-account-fingerprint-IMPLEMENTATION-GUIDE.md`](./fingerprint/oauth-account-fingerprint-IMPLEMENTATION-GUIDE.md): 面向执行型 AI 的实现入口

## `operations/`

开发测试、隔离运行、正式迁移与回滚操作。

- [`isolated-dev-testing.md`](./operations/isolated-dev-testing.md): Dev / Prod 隔离测试方案
- [`dev-to-production-promotion.md`](./operations/dev-to-production-promotion.md): 从开发版收口到正式版的操作说明

## `submodules/`

第三方核心与管理后台子模块的维护入口。

- [`cliproxy-plus-submodule.md`](./submodules/cliproxy-plus-submodule.md): `CLIProxyAPIPlus` 子模块维护说明
- [`management-center-submodule.md`](./submodules/management-center-submodule.md): `Cli-Proxy-API-Management-Center` 子模块维护说明

## `project/`

Quotio 自身项目概览、代码结构和基础架构说明。

- [`project-overview-prd.md`](./project/project-overview-prd.md): 项目 PRD
- [`codebase-summary.md`](./project/codebase-summary.md): 代码库摘要
- [`codebase-structure-architecture-code-standards.md`](./project/codebase-structure-architecture-code-standards.md): 结构与代码规范
