# 当前 Fork 改动总览

最后更新：2026-04-21

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
- `scripts/replace-local-quotio-runtime.sh`

### 补充：远端模式现在以“直连远端 core”作为主语义

当前宿主侧远端连接不再默认等同于旧 experimental remote proxy。

- 用户可见主模式现在是 `remote-core`：Quotio 直接连接远端 core 的 management API，本地不需要再拉起一个本机 core
- 本地 CLI 配置会直接指向远端 core 的 client endpoint，而不是先写回本地监听再转发
- 旧 `remote` 语义只保留给历史配置迁移；维护时不要再把它当成新的产品能力入口
- `remote-core` 当前目标保留的能力包括：Providers、API Keys、Agents、Logs、quota / usage；本地专属能力如本地 core 控制、fallback、identity packages 仍只属于 `localProxy`
- 隔离 smoke 或临时调试可用 `QUOTIO_REMOTE_ENDPOINT`、`QUOTIO_REMOTE_MANAGEMENT_KEY`、`QUOTIO_REMOTE_VERIFY_SSL` 注入远端连接，避免测试 app 读取 Keychain；正常用户配置仍应走 UI 持久化配置

### 4. 多身份指纹不是停留在想法

这轮二次开发已经做过的关键能力包括：

- 账户级 `proxy_url`
- 账户级托管 `headers`
- Claude / Codex 真实上游请求验证链路
- dev / prod 运行时隔离
- 正式版迁移 / 回滚脚本

当前还需要额外记住两个容易漏掉的行为边界：

- provider 账号页现在支持“原账户就地重发 OAuth2 并替换原 oauth 文件”，不是只能新增账户；核心侧通过目标参数 `auth_name` 覆盖原 auth，并保留账户级 `prefix`、`proxy_url`、`headers`、`priority`、`note`、`disabled`
- 管理后台与 Quotio 的原位重认证现在都支持“复制链接 / 取消 / localhost callback URL 回填”；管理后台为降低多账号误触风险，不再提供直接打开认证页按钮，需要在真实登录环境里打开授权链接时先复制链接，再把 `http://localhost:1455/...` 回填到发起端完成闭环
- 重认证历史不再只能靠 auth 文件 `modified time` 猜测；core 会把事件落到 `<authDir>/.oauth-history/reauth.jsonl`，并通过只读 management API `/v0/management/oauth-reauth-history?auth_name=<name>&limit=<n>` 提供给 management 页面和 Quotio 展示
- Codex `plus` 账号的可用模型轮询必须排除 `gpt-5.3-codex-spark`，不要把它当成可正常访问的可选模型
- Codex OAuth auth 在本地正式 / 本地 dev / 远端 core 默认是独立副本；同一账号若多运行面并行 refresh，旧副本后续会出现 `invalid_grant` / `refresh_token_reused`。当前运维约束是：默认不要把本地正式最新 Codex auth 再同步到远端 / dev，也不要让多个运行面长期并行刷新同一账号
- 本地 `Quotio` / `Quotio Dev` 的 runtime 管理页真源是运行目录下的 `static/management.html`；本地替换脚本现在会把 `Cli-Proxy-API-Management-Center/dist/index.html` 一并 stage/replace，不能只看 app/core 是否更新
- 本地 runtime 若要保留这套 fork 里的管理页改动，`config.yaml` 的 `remote-management.disable-auto-update-panel` 必须为 `true`；否则 core 启动后会从官方 `router-for-me/Cli-Proxy-API-Management-Center` release 重新拉取 `management.html`，把本地刚替换进去的页面覆盖回旧版
- `scripts/replace-local-quotio-runtime.sh` 的 management 验收不能只看磁盘文件 hash；当前脚本默认还会校验 served `/management.html` 与 staged hash 一致、重启后延迟 15 秒复查一次，并用 token 门禁卡住回归：默认必须出现 `reauth_copy_link`，默认不得出现 `reauth_open_link` / `onOpenReauthLink` / `openReauthLink`
- 本地正式 / dev runtime 的替换现在会把备份清单写到 `~/Library/Application Support/Quotio*/backups/local-runtime-replace/replace.<target>.<timestamp>.txt`，并支持用 `scripts/rollback-local-quotio-runtime.sh` 按最近一次或指定 manifest 一键回滚 app/core/management
- usage 统计快照会持久化到 `~/Library/Application Support/Quotio*/.usage-statistics.json`；proxy core 启动时会自动 merge 恢复，所以“重启后历史没了”优先先排查宿主 UI 是否没有把 `requests_by_day` / `tokens_by_day` / `cost_by_day` 展示出来，而不是先假设 core 没落盘
- usage 统计现在开始带官方价格估算的 `total_cost_usd` / `cost_by_day`，并区分 `cache_read_input_tokens` 与 `cache_write_input_tokens`；`gpt-5.3-codex-spark` 这类官方价格未最终确定的模型会标成 `pricing_status=unfinalized`，不能静默按 0 美元当成“免费”
- management center 的 `/usage` 页面现在优先使用 core 返回的 request-level `cost_usd` / `pricing_status`，不再把浏览器 localStorage 里的模型价格当成唯一真源；页面下方的价格表只保留给旧快照或未内置定价模型做 fallback

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
