# Repo Memory Ledger

最后更新：2026-04-25

这份文档只记录仓库级、长期有效、值得反复记住的事实和边界。

它回答的问题不是“先看哪里”，而是“这个仓库有哪些长期结论，忘了就容易误判”。

## 什么时候更新这份文档

- 新确认了一条会长期影响实现、验证、运维或收敛方式的事实
- 同类误判已经重复出现，或者一次代价已经足够高
- 某个 source of truth、runtime truth、验收门禁或收敛规则发生了稳定变化

不应该写进来的内容：

- 通用型 AI 提示词
- 一次性会话策略
- 还没验证的推测
- 纯代码层显而易见、可以低成本从源码恢复的细节

## 长期记忆

### 1. 这不是原生上游 Quotio

当前仓库应该被理解成一个围绕 `CLIProxyAPIPlus` 长期二次开发过的 Quotio fork，而不是“只改过一点 UI 的上游镜像”。

### 2. 有效架构是三层，不是一层

当前有效架构至少包括：

- Quotio 宿主应用
- `third_party/CLIProxyAPIPlus`
- `third_party/Cli-Proxy-API-Management-Center`

很多问题不能只在 SwiftUI 层解释。

### 3. 本机生产运行面默认按活系统对待

下面这些默认都按生产状态理解：

- `~/Library/Application Support/Quotio`
- `~/.cli-proxy-api`
- `18317/28317`

proxy/core 相关实验默认先走 dev runtime 或独立 worktree。

### 4. `CLIProxyAPIPlus` 的唯一开发真源是子模块

唯一开发真源：

- `third_party/CLIProxyAPIPlus`

`/tmp/...`、仓库外临时 clone、只有二进制没有 commit 对应关系的 patched 副本，都不能当继续开发入口；它们最多只用于只读比对。

### 5. 远端 Linux core 是 remote-core 维护的运行真源

对远端 core、Docker、auth mount、上游代理、远程部署做判断时，最终验收面不是本机猜测，而是 `10.1.1.201` 上的真实运行态与对应操作文档。

### 6. Codex auth 在不同运行面默认是独立副本

本地正式、本地 dev、远端 core 的 Codex OAuth auth 默认不是同一个文件；同一账号被多个运行面长期并行 refresh，会触发 `invalid_grant` 或 `refresh_token_reused` 一类轮换冲突。

### 7. 模型同步是分层问题，不是单点问题

排查“为什么这里看不到新模型”时，要分清三层：

- core `/v1/models`
- Quotio 宿主侧最近一次成功拉取后的缓存模型 / 配置生成
- Codex CLI TUI 自己内置的 `/model` picker

其中第三层不是前两层的镜像。TUI 里暂时没出现某个新模型，不等于 runtime 一定不可用。

### 8. 管理页的运行真源是 runtime 里实际 served 的 `management.html`

只替换磁盘文件、不看运行态 served 页面，结论不完整。并且如果没有关掉 auto-update panel，core 可能会把本地刚替换的管理页重新覆盖回旧版。

### 9. 仓库级知识入口和项目地图是分层的

- `repo-knowledge-map.md` 负责回答“遇到某类任务先看哪里”
- `repo-memory-ledger.md` 负责记录长期边界、决策和教训
- `docs/README.md` 负责按主题列文档目录
- `.agentlens` 负责代码地图与符号索引

不要把 `.agentlens` 当成 fork 运行边界的唯一真源，也不要把整套全局提示词原样复制进仓库文档。

### 10. 远端模式要把本机入口和远端真源分开理解

当前远端模式不是单一语义：

- `remote-core`：Quotio 直接连接远端 core，CLI 客户端也可以直接写远端 endpoint
- `remote-relay`：Quotio 仍连接远端 core 的 management API，但本机只保留 `127.0.0.1:<port>` relay 给 Claude / Codex / Quo 等客户端；这个 relay 只负责把请求转发到远端 core
- 这两种远端模式下，Providers、API Keys、Logs、quota / usage、远端 routing / retry / 上游代理配置都以远端 core 为真源，不应回退成“本地宿主数据”
- `remote-core` / `remote-relay` / `monitor` 启动时不应再预备本地 core runtime 或写 `local-management-key`
- 远端模式当前不暴露本地专属 `Identity Packages`，避免把宿主侧 phase-1 能力误当成远端 runtime 真源
- 对“远端 management key”的 dev-only 例外已经单独收口：显式设置 `QUOTIO_REMOTE_MANAGEMENT_KEY_STORE=file` 后，Quotio 只把远端连接 key 落到本地 JSON，并继续把本地 core 的 `local-management-key` / `config.yaml remote-management.secret-key` 留在原链路；默认关闭，不改变正式版默认行为

### 11. 账号设置正在替代远端 `Identity Package` 主流程

- 对远端账号来说，“一个账号就是一个运行身份”；结构化真源在 core 的 `account_settings`，不是 Quotio 本地 `Identity Package`
- 远端账号配置主入口在 management center；Quotio 远端模式负责摘要、状态、日志、用量和快速操作，不再承担远端身份真源
- 这轮真实生效的账号字段是 `proxy_url`、`note`、`disabled`、`managed_headers`、`extra_headers`
- `managed_headers` 由 core 按 provider/runtime 策略自动生成并只读返回，重点覆盖 Claude / Codex 这类版本敏感头；用户长期可编辑的只有 `extra_headers`
- `managed_headers` 的真正要求不是“对外暴露几个字段”，而是 core policy 必须跟随 provider/runtime 新版本持续自动更新；如果 header 里声称的客户端版本/能力与真实运行能力失配，就应视为该方向未完成
- 当前对外 `managed_headers` 返回仍只是最小可观测摘要，不应被误读成完整长期 contract；在版本源、升级触发和回归验证被单独固化前，不要把这层字段列表当成策略边界
- 截至 `2026-04-25` 的并行调研结论：主流官方/开源实现更常见的是“按字段分层 merge + 只 patch 会变的版本标记”，而不是维护一整套 `managed_headers` / fingerprint 大 blob 的历史版本库
- 对 Claude / Codex 这类版本敏感 provider，更稳的字段 owner 切法至少包括：
  - `versioned_capabilities`：CLI/SDK version、`X-Stainless-Package-Version`、Claude beta/date token 等允许自动升级的字段
  - `runtime_fingerprint`：OS/arch/runtime/terminal 等只应随真实运行环境变化的字段
  - `stable_identity`：`Originator`、`X-App`、账号/工作区身份位
- 自动更新默认只允许触碰 `versioned_capabilities`；`runtime_fingerprint` 与 `stable_identity` 不应在普通版本升级时一起被重写
- 如果后续要补“历史版本”，优先做 append-only `patch_history`，记录 policy version、changed fields、原因与证据，而不是只保留一个最新快照
- 当前实现已把这条规则最小落到 core：
  - `account_settings.managed_header_state` 记录当前 projection 与 append-only history
  - Claude 继续用现有 stabilized device profile 输出 managed headers
  - Codex 现在会缓存/解析第一方 profile，并在后续升级时只 bump version markers；平台/终端尾巴这类稳定指纹默认钉住
  - `managed_header_state` 只有在 projection 真变化时才追加 history，避免把时间戳刷新误记成版本演进
- `extra_headers` 若与 managed / protocol-reserved headers 冲突，必须由 core API 拒绝，而不是默默覆盖
- `transport_profile` / `tls_profile` 当前要分开讲：
  - `tls_profile` 仍只允许作为 schema / API / UI 预留字段存在；不要把它描述成“已完成账号级 runtime enforcement”
  - `transport_profile` 已有部分真实运行态：
    - Claude 预设会进入 uTLS runtime transport
    - Codex 支持的 managed preset 会把 HTTP transport cache 与 websocket session 提升到账号级隔离
  - 但 Codex 这条目前只做到“account-scoped transport isolation”，不是 `codex-proxy` 那种 Rust `reqwest/rustls` 级别的 Desktop TLS 完全仿真；对外必须明确保留这条边界

### 12. 本机 `local-load` deploy 若报 Docker `_ping 500`，先查 `vpnkitCIDR` 与 VPN 路由冲突

- 在这台开发机上，`BUILD_STRATEGY=local-load` 一度持续失败，表现为：
  - `docker version` / `docker info` 卡住或返回 `_ping 500`
  - Docker Desktop 日志反复出现 `still dialing 192.168.65.7:2375 ... no route to host`
- 这不是仓库代码回归；根因是 Docker Desktop 的默认 `vpnkitCIDR=192.168.65.0/24` 与当前 VPN 路由冲突，`route -n get 192.168.65.7` 会落到 `utun`
- 当前已验证可行的最小修复：
  - 先备份 `~/Library/Group Containers/group.com.docker/settings-store.json`
  - 先备份 `~/Library/Group Containers/group.com.docker/settings.json`
  - 把两份配置里的 `vpnkitCIDR` 从 `192.168.65.0/24` 改到未冲突网段（当前验证值：`172.31.255.0/24`）
  - 重启 Docker Desktop，再复验 `docker version`
- 这条记忆的用途是避免再次把“本机 Docker Desktop 内部网段冲突”误判成远端 deploy 脚本或 core 代码问题

## 收敛补充规则

### 什么时候补 `repo-knowledge-map.md`

- 文档入口、推荐阅读顺序、任务路由发生变化时
- 新增一个长期存在的任务域，但目前没人知道该先看哪里时

### 什么时候补 `repo-memory-ledger.md`

- 出现新的长期边界、易踩坑或高代价误判时
- 某条结论已经不适合只藏在一次会话或零散文档里时

### 什么时候还要补 `docs/README.md` / `AI_ONBOARDING.md`

- 当新增的仓库级文档已经变成正式入口，或首屏阅读顺序需要改变时

### 什么时候判断项目地图刷新

- 到交付边界时再判断
- 如果只是补仓库级人工入口文档，通常不需要重跑 `.agentlens`
- 如果代码结构、模块边界、代码入口或生成地图本身的路由变了，再刷新 `.agentlens`
