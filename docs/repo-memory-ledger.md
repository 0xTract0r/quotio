# Repo Memory Ledger

最后更新：2026-05-14

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

远端 core 部署不要直接绕过安全入口：先用 `scripts/deploy-cliproxy-linux-safe.sh --dry-run` 生成 manifest；进入维护窗口后再 `--execute`。这条入口默认 `SYNC_AUTH_DIR=0`，会准备 current image rollback tag、非 auth runtime backup，并把 core 的 `VERSION` / `COMMIT` / `BUILD_DATE` build args 注入 Docker 构建；dry-run 要先证明本地 artifact 已注入 buildinfo，部署后必须用 `/healthz`、`/management.html` 和 management API 响应头 `X-CPA-VERSION` / `X-CPA-COMMIT` / `X-CPA-BUILD-DATE` 证明运行二进制版本。

### 6. Codex auth 在不同运行面默认是独立副本

本地正式、本地 dev、远端 core 的 Codex OAuth auth 默认不是同一个文件；同一账号被多个运行面长期并行 refresh，会触发 `invalid_grant` 或 `refresh_token_reused` 一类轮换冲突。

### 6.1 Claude OAuth 重认证要看真实 token exchange 和 provider 请求

远端 Claude 账号重认证不能只看 management UI 显示“成功”或“等待中”。最小闭环证据必须同时包含：远端日志显示 callback 被消费、token exchange completed、目标 auth 文件更新时间变化、management `api-call` 对 Anthropic `/v1/messages` 返回 `200`，以及本地 `18317` relay 的真实 Claude 请求返回成功。

`connection not allowed by ruleset` 这类错误发生在 SOCKS CONNECT 阶段，含义是账号代理链路或上游代理规则拒绝了到 `api.anthropic.com:443` 的连接；它不是 Anthropic OAuth 返回、不是 token 保存失败，也不能直接归因为 TLS 指纹。T076 的真实成功路径是第一次 Claude OAuth token exchange 被 SOCKS ruleset 拒绝，随后同一账号路径短重试成功；日志没有出现标准 OAuth transport fallback，因此不能把 fallback 说成真实发生。

### 6.2 远端 AI 断流要先分清 `.5` 网关、账号代理和 provider 三段

远端 core 在 `10.1.1.201` 上运行时，`10.1.1.5` OpenWRT/OpenClash 是它的生产网关。任何 `.5` 上的 OpenClash 规则、selector、overlay 或 restart 都可能影响 `201 -> 账号专属 SOCKS/HTTP proxy -> provider` 的出站链路，从而表现为本地 Codex / Claude 客户端断流。

T240 的长期结论：

- 本地 Codex/Claude 看到 `stream disconnected`、`context deadline exceeded` 或 `Client.Timeout` 时，不能只看本地 relay/DIRECT；必须同时看远端 `main.log` 和对应 request log
- Codex `/v1/responses` 的 500 若 request log 显示 `p.webshare.io:<port> -> chatgpt.com/auth.openai.com` `EOF`、`connect timeout` 或 `connection reset`，优先按 `201 -> .5 -> 账号代理商 -> provider` 链路不稳排查，不要误判为 model 配置或本地 Clash 规则
- Claude 的 `connection not allowed by ruleset` 是 SOCKS CONNECT 阶段拒绝；`context canceled` 往往是下游/上游流被取消后的结果，需要结合同窗 provider-facing request log 和前后 200 判断是否持续故障
- `unknown provider for model gpt-5.1-codex-mini` 是模型配置型 502，不应和网络断流混算
- `80.174.217.1:12324` 是 Claude 账号专属代理，不应写成 Codex/Claude 共用代理

生产边界：OpenClash 已交给独立维护方处理时，本仓库 AI 会话只做只读诊断和文档沉淀，不直接修改 `.5` overlay、不 reload/restart OpenClash，也不把 selector 切换当作无风险操作。若未来必须改 `.5`，应先准备离线 diff、备份、回滚口令、影响范围和维护窗口，再由 operator 执行。

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
- 远端连接状态不要只用 `/v0/management/auth-files` 这类重接口单点判断；账号多或远端短暂抖动时它可能超时，但本地 relay 与远端 core 仍健康。Remote readiness 至少要区分 `401/403` 这类 key 错误和网络/重接口暂时失败，并用轻量 `/healthz` 兜底确认 core 存活，避免 UI 误报“远程已断开”。

### 11. 账号设置正在替代远端 `Identity Package` 主流程

- 对远端账号来说，“一个账号就是一个运行身份”；结构化真源在 core 的 `account_settings`，不是 Quotio 本地 `Identity Package`
- 远端账号配置主入口在 management center；Quotio 远端模式负责摘要、状态、日志、用量和快速操作，不再承担远端身份真源
- 这轮真实生效的账号字段是 `proxy_url`、`note`、`disabled`、`managed_headers`、`extra_headers`
- `refresh_enabled` 是账号级安全开关，默认 `true`；设为 `false` 时 core 不调度自动 refresh，manual status refresh 也只返回 warning，不会调用 provider refresh flow。它主要服务 access-token-only 远端测试 / 受控迁移，不能被写成长期明文 token 方案
- `managed_headers` 由 core 按 provider/runtime 策略自动生成并只读返回，重点覆盖 Claude / Codex 这类版本敏感头；用户长期可编辑的只有 `extra_headers`
- Management Center 里自动生成的 managed 内容不能渲染成 textarea/input：`managed_headers` 应显示为“运行时实际应用”的只读 header 表格，`managed_header_state` 应显示为“核心自动升级策略状态”的摘要/字段类别/历史；只有 `extra_headers` 是用户可编辑 header 文本框
- `managed_header_state.policy_version` 里的 `claude-managed/v2` / `codex-managed/v2` 是 core 内部 managed-header 策略 ID，不是 Claude/Codex 官方客户端版本；UI 主显示应拆成“托管策略 / 策略版本 / 自动更新规则”，内部 ID 只能作为调试信息
- `managed_headers` 的真正要求不是“对外暴露几个字段”，而是 core policy 必须跟随 provider/runtime 新版本持续自动更新；如果 header 里声称的客户端版本/能力与真实运行能力失配，就应视为该方向未完成
- 截至 `2026-05-09` 的修正规则：联网只能自动更新有真实来源证明的字段。Codex 默认 `codex_proxy_compatible_v1` 会优先从 allowlist 的 `icebear0828/codex-proxy` 公共配置同步 Codex Desktop-like coherent bundle；Claude Code 的 npm package 版本只能作为 `claude-cli/<version>` UA 来源，不能凭 npm 版本推导 `X-Stainless-Package-Version` / `X-Stainless-Runtime-Version`、OS/arch、TLS ClientHello 或 HTTP/2 指纹
- 对外 `managed_header_state.current` 必须披露 `source` / `source_url` / `checked_at` / `completeness`：`community:codex-proxy` + `online-coherent-bundle` 表示已从 allowlist codex-proxy 公共配置同步成一组自洽 bundle；`online:npm` + `partial-cli-version-only` 表示只校验/升级 CLI UA 版本；`observed:first_party` 表示真实客户端请求观察；`default` 表示默认策略且未联网校验
- T058 方向纠偏：Codex 不再停留在“参考一下 `codex-proxy`”。核心默认 Codex runtime identity 已切到 `codex_proxy_compatible_v1`，managed headers 采用 `icebear0828/codex-proxy` 的 Codex Desktop-like `Originator` / UA / Chromium client hints / fetch headers 这组社区实现方案；当前 Go 实现吸收 native transport 分层、per-proxy/per-account client cache、HTTP/1.1 forcing 开关和 header bundle，但不复制 cookie replay / token-cookie 采集 / anti-detection 叙事
- `codex_rustls_native_v1` 作为显式 profile 名保留给后续 Rust sidecar/addon；当前没有 Rust sidecar 时，Codex runtime 是 Go-compatible approximation，而不是 Rust wire-level clone
- 当前对外 `managed_headers` 返回仍只是最小可观测摘要，不应被误读成完整长期 contract；版本源、升级触发和回归验证必须作为策略边界一起展示
- 截至 `2026-04-29` 的并行调研结论：主流官方/开源实现更常见的是“按字段分层 merge + 只 patch 会变的版本标记”，而不是维护一整套 `managed_headers` / fingerprint 大 blob 的历史版本库
- 对 Claude / Codex 这类版本敏感 provider，更稳的字段 owner 切法至少包括：
  - `versioned_capabilities`：CLI/SDK version、`X-Stainless-Package-Version`、Claude beta/date token 等允许自动升级的字段
  - `runtime_fingerprint`：OS/arch/runtime/terminal 等只应随真实运行环境变化的字段
  - `stable_identity`：`Originator`、`X-App`、账号/工作区身份位
- 自动更新默认只允许触碰 `versioned_capabilities`；`runtime_fingerprint` 与 `stable_identity` 不应在普通版本升级时一起被重写
- 历史版本必须 append-only：升级前后的 `versioned_capabilities`、changed fields、source/source_url、reason 都要保留；不要只保留一个最新快照
- 当前实现已把这条规则最小落到 core：
  - `account_settings.managed_header_state` 记录当前 projection 与 append-only history
  - Claude 继续用现有 stabilized device profile 输出 managed headers；联网 registry 版本只升级 `claude-cli/<version>` 这类版本标记，Stainless package/runtime 与 OS/arch 保持既有基线或真实观察值
  - Codex 默认 Desktop-like bundle 现在会联网拉取 allowlist 的 `codex-proxy` `config/default.yaml` 与 `config/fingerprint.yaml`，只在 `originator` / `app_version` 等关键字段形成 coherent bundle 时升级 `User-Agent` / `Version` / Chromium client hints / fetch headers；如果 codex-proxy 来源不可用，则保留本地静态 community fallback，不回退到 npm CLI 版本混搭
  - `managed_header_state` 只有在 projection 真变化时才追加 history，避免把时间戳刷新误记成版本演进
  - T060 已完成远端闭环：safe deploy manifest `build/remote-deploy-safety/20260509T083141Z/manifest.env`；远端 3 个 Codex 账号均返回 `completeness=online-coherent-bundle` / `source=community:codex-proxy` / `codex_proxy_compatible_v1`，Claude 返回 `completeness=partial-cli-version-only` / `source=online:npm` / `claude_reqwest_rustls_compatible_v1`；controlled echo runtime probe 证明托管 header policy/source/version 已进入 core-mediated 账号运行证据，但仍不是 provider 官方 attestation
- `extra_headers` 若与 managed / protocol-reserved headers 冲突，必须由 core API 拒绝，而不是默默覆盖
- OAuth re-auth 必须保留用户定义字段，不能由 OAuth 响应覆盖：`proxy_url` / `note` / `headers` / `refresh_disabled` / `refresh_enabled` / `websockets` / `disabled` / `account_settings`（含 `managed_header_state` / `runtime_identity_state`）/ `label` / `tags` / `extra_headers` 都由 management UI 写入，OAuth handler 只能更新 token 自身字段（`access_token` / `refresh_token` / `id_token` / `email` / `account_id` / `expired` / `last_refresh` 等）。Codex plan-type 改名（如 `plus -> pro`）导致 credential 文件名变化时，merge 完后必须删除旧文件并标记旧 in-memory 条目 disabled，避免孤儿和重复账号。
- `RefreshDisabled()` 当前覆盖 metadata `refresh_disabled=true` / `refresh_enabled=false` / `disable_refresh=true` / `auto_refresh_disabled=true` / 同名 attribute / `account_settings.{refresh_enabled=false, refresh_disabled=true, ...}` 各路径，executors（至少 Codex / Claude）在 Refresh 入口必须显式短路返回，避免 retry-on-401 等 unaware caller 绕过 operator 设置触发 provider refresh。
- `GET /v0/management/auth-files` 必须是 read-only fast path，不能在请求线上做同步 managed-header / runtime-identity 写盘或同步外呼。这条 endpoint 一旦回退成同步 sync，3 个 codex 账号 × 3 次 token refresh retry 就足以阻塞列表 21~24 秒（T260 实测）。后台 sync 必须有 per-auth in-flight dedup、成功冷却（默认 30s）、失败指数退避（60s -> 10m）和 worker timeout（默认 25s）。
- Management Center `/quota` 页面现在是远端配额观测主入口之一：页面挂载期间默认启用自动刷新，默认间隔 1 分钟，并显示上次刷新时间；实现上只刷新当前可见/当前分页的账号配额，避免打开页面后无界地批量打 provider
- Quotio 远端模式的配额自动刷新不能依赖 `NSApplication.shared.isActive`。菜单栏常驻/窗口隐藏时 app 可能不是 active，但用户配置的 1 分钟刷新仍应执行；否则 menu bar 会持续显示几分钟前的旧数据
- `transport_profile` / `tls_profile` 当前要分开讲：
  - `transport_profile` 已有真实运行态：Claude 空配置现在生成 `claude_reqwest_rustls_compatible_v1`，Gemini 空配置仍生成 CLI-native 账号运行身份；Codex 空配置现在生成 `codex_proxy_compatible_v1`，把 Codex-Proxy-like Go transport、HTTP client cache、连接池、代理 transport 和 WebSocket session pinning 提升到账号级隔离；隔离键至少包含真实 provider、auth/account、base URL host、effective proxy、profile token
  - `tls_profile` 现在有两层：Claude 默认是 `claude_reqwest_rustls_compatible_v1` 的 Go-compatible reqwest/rustls CLI 方案，Gemini 默认 CLI-native account isolation 自动生效；Codex 默认是 `codex_proxy_compatible_v1` 的 Go-compatible TLS/transport approximation；Claude 的 Chrome-like uTLS ClientHello preset 仍必须显式 opt-in，`provider-default` / 空配置不自动映射成 Chrome-like
  - Claude 当前默认 runtime profile 是 `claude_reqwest_rustls_compatible_v1`；`claude_utls_chrome_133`、旧 `claude_chrome_like_mac_v3` / `chrome_133` 只保留为高级显式 opt-in alias，不再作为推荐默认方案或官方 Claude Code 指纹名展示
  - Claude 不应直接沿用 Codex TLS 指纹值。`anthropics/claude-code`、`ultraworkers/claw-code`、`777genius/claude-code-source-code` 与 Claude proxy 项目可借鉴 Anthropic SDK client、base URL、proxy、CA/mTLS、应用层 headers 与网络边界；当前没有发现可像 `codex-proxy` 一样直接搬入 Claude Code native TLS addon 的同级项目，但 `ultraworkers/claw-code` 的 Rust `reqwest` + `rustls-tls` 客户端/proxy model 可作为 Claude CLI 默认 profile 来源
  - 当前 Claude MVP 已改为 Claude 专属 `claude_reqwest_rustls_compatible_v1`：参考 `ultraworkers/claw-code` 的 `reqwest` + `rustls-tls` 客户端/代理模型并在 Go runtime 中近似执行；Chrome-like uTLS 仅保留为高级显式 opt-in，不能把 Codex Desktop 指纹改名套到 Claude
  - `2026-05-08` T052 远端复验曾返回真实 `/v1/messages?beta=true` `401 authentication_error`；这只能说明远端账号凭据失效，不能算真实 Claude 验证完成。T053 已纠偏：只从本地当前 Claude auth 复制 access credential 到内存，移除/不上传 refresh/id credential，保留远端 proxy / managed history / transport profile 后上传到同名远端账号；复跑真实远端 core `/v1/messages?beta=true` 返回 `200`、model `claude-haiku-4-5-20251001`、输出 `OK.`。
  - T053 同时复跑 controlled echo：真实远端 Claude 账号仍显式配置旧 alias，但 runtime 规范化为 `claude_utls_chrome_133`；controlled echo 返回 JA3 / JA4 / HTTP/2 字段且 `authorization_sent=false`。Chrome-like TLS 仍只能说是历史高级 opt-in 的浏览器式 ClientHello preset，不能说成 Claude Code CLI 完整指纹；新默认应使用 `claude_reqwest_rustls_compatible_v1`。
  - T058 语义更新：核心现在会自动生成账号级 runtime identity；Claude 默认 `claude_reqwest_rustls_compatible_v1`，Codex 默认 `codex_proxy_compatible_v1`，Gemini 仍默认 CLI-native。用户不需要手工生成 TLS 身份。每份 auth/account 默认隔离 runtime HTTP client / 连接池 / 代理 transport；如果多个账号都显式选择同一个 Chrome-like preset，它们的 TLS 形态仍相同，只是连接池和账号运行态隔离。
  - T056 纠偏：`runtime_identity_state` 已持久化进账号设置，由 core 自动生成和维护，management API/UI 只读展示。它包含 `identity_id`、provider policy、source、revision、created/updated、seed/auth/account/proxy hash、profile IDs 和 history；同账号重复读取保持稳定，不同 auth/account 生成不同身份，profile/source 变化才追加历史。它仍不保存明文 token / proxy credential，也不宣称 provider-edge TLS parity。
  - T057 口径：`provider_edge_parity_score` 是项目定义的 90 分 readiness gate，不是官方 provider-edge attestation。它把“社区最佳实践驱动的 CLI TLS 指纹策略”拆成账号 runtime identity、managed headers、runtime transport/TLS profile、controlled echo TLS/HTTP2 字段、proxy/runtime path、安全边界等可审计组件；`score >= 90` 只能说满足本项目当前 controlled/core-mediated 近似标准，不能说 OpenAI / Anthropic / Google 官方 TLS 指纹已经完全一致。
  - T058 Codex 已从 `codex_cli_native_v1` 推进到 `codex_proxy_compatible_v1` 默认路径：headers 和 Go transport 行为向 `codex-proxy` 对齐；剩余边界是 Rust `reqwest/rustls` wire-level clone 尚未搬入，后续需 Rust sidecar/addon 或等价实现

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

### 13. OAuth executor `Refresh` 必须把 `auth.ProxyURL` 传到底层 auth client，不能 fallback 到全局 `cfg.ProxyURL`

- 适用范围：`internal/runtime/executor/{claude,qwen,iflow,codex,kiro,gitlab,github_copilot}_executor.go` 的 `Refresh`（含 IFlow 的 `refreshCookieBased` / `refreshOAuthBased`；Kiro 的 SSO OIDC IDC/Builder-ID 路径 **和** social-auth Google/GitHub 路径；GitLab 的 OAuth refresh + 后续 `FetchDirectAccess`；GitHub Copilot 的 `Refresh` **和** `ensureAPIToken`，后者会在 cache miss 时随每次业务请求触发 token exchange）；以及 `sdk/auth/kiro.go` 的 `KiroAuthenticator.Refresh`。在已经持有特定账号 `auth` 上下文的 token refresh / cookie refresh / token-exchange / profile-discovery 路径里，构造底层 auth client（`NewClaudeAuth*`、`NewQwenAuth*`、`NewIFlowAuth*`、`NewCodexAuth*`、`NewSSOOIDCClient*`、`NewKiroOAuth*`、`NewAuthClient*` (gitlab)、`NewCopilotAuth*`）必须显式传 `auth.ProxyURL`，使用对应的 `WithProxyURL` ctor；不能只传 `e.cfg`。
- 反例症状（已生产观察过）：远端 Claude 账号配置了账号级 SOCKS5 `proxy_url`，但 executor `Refresh` 走全局 OpenClash 代理 → 自动 refresh 静默失败（manager 日志里 `core auth auto-refresh started` 循环仍在跑）→ 用户每 8 小时必须手动重新 OAuth。Copilot 的危害更严重：`ensureAPIToken` 在每次业务请求 cache miss 时都会重新走 token-exchange，缺失 `auth.ProxyURL` 会让该账号几乎所有业务请求的 token 阶段都泄露到全局代理。
- 修复模板（已落地）：
  - `claude_executor.go` `Refresh` → `claudeauth.NewClaudeAuthWithProxyURL(e.cfg, auth.ProxyURL)`
  - `qwen_executor.go` `Refresh` → `qwenauth.NewQwenAuthWithProxyURL(e.cfg, auth.ProxyURL)`
  - `iflow_executor.go` `refreshCookieBased` / `refreshOAuthBased` → `iflowauth.NewIFlowAuthWithProxyURL(e.cfg, auth.ProxyURL)`
  - `kiro_executor.go` `Refresh` 与 `fetchAndSaveProfileArn` → `kiroauth.NewSSOOIDCClientWithProxyURL(e.cfg, auth.ProxyURL)`；social-auth fallback → `kiroauth.NewKiroOAuthWithProxyURL(e.cfg, auth.ProxyURL)`；`sdk/auth/kiro.go` `KiroAuthenticator.Refresh` 同款替换
  - `gitlab_executor.go` `Refresh` → `gitlab.NewAuthClientWithProxyURL(e.cfg, auth.ProxyURL)`（同时覆盖后续 `FetchDirectAccess`）
  - `github_copilot_executor.go` `Refresh` / `ensureAPIToken` / `FetchGitHubCopilotModels` → `copilotauth.NewCopilotAuthWithProxyURL(e.cfg, auth.ProxyURL)`（含 cache-miss 路径，所以不只是定期 refresh 触发）
  - 参考已正确实现的 `codex_executor.go` `Refresh` → `codexauth.NewCodexAuthWithProxyURL(e.cfg, auth.ProxyURL)`
- 例外：OAuth 起始 URL 生成 / 设备码 / 首次登录路径（管理 API `RequestQwenToken` / `RequestIFlowToken` / Kiro 管理面 `aws` 设备码 `RegisterClient` / SDK `Login` / `cmd/iflow_cookie.go` / `newClaudeOAuthAuth(nil)` fallback）尚未持有账号 `auth` 上下文，保持使用 `cfg.ProxyURL` 是预期行为。
- 新增同类 provider 的 OAuth 实现时，默认按这条规则走，并附最小 regression test：在 auth 包验证 `WithProxyURL` 的 override 优先级和空 override 回退 cfg.ProxyURL 的双向行为，在 executor 包验证 `Refresh` 实际通过 `auth.ProxyURL` 路由（local httptest 当作 HTTP proxy 接收 CONNECT 即可）。

#### 13.1 Provider apply helpers 必须显式注入 `account_settings.headers` / `extra_headers`

- 适用范围：每个 provider executor 的 outbound `applyXxxHeaders(req, ..., auth)` helper（PrepareRequest / Execute / ExecuteStream 共用入口）。helper 在写完硬编码 UA / Authorization / Accept 等 header 之后，必须显式调用一次 `util.ApplyCustomHeadersFromAttrs(req, auth.Attributes)`，否则账号设置里写入的 `header:<name>` 属性会在持久化和管理 UI 都正常往返、但**永远不会出现在真实 outbound 请求上**。
- 当前已落地：Codex / Claude / Kimi / Kilo / Gemini / Gemini Vertex / Gemini CLI / Antigravity / AIStudio / Codex websockets / Claude legacy device profile / IFlow / Qwen / GitHub Copilot（注：Claude / Codex 还会在 custom header 后用 managed-header snapshot 恢复 UA / Originator 等关键 header；其它 provider 默认允许 custom header 覆盖硬编码默认值，与 codex 行为一致）。
- 反例：IFlow / Qwen / GitHub Copilot 的 `applyXxxHeaders` 此前不接受 `auth` 参数，account 级 `extra_headers` / `account_settings.headers` 仅在 management UI 与配置盘上有效，业务请求 outbound 时被完全忽略。新增 provider 时默认让 helper 接受 `auth` 并在末尾调用 `ApplyCustomHeadersFromAttrs`，并补一个测试：构造一个含 `header:X-Custom-Foo:bar` 的 attribute，调用 apply helper，断言 outbound request header 出现该字段。

### 14. 本机 CLI 直连远端 HTTPS 时，域名证书和代理绕过都要对齐

- 2026-05-11 为排查本地 Codex 断流，本机 Claude / Codex CLI 已从本地 `127.0.0.1:18317` relay 改成直连远端 `https://cpa.wisedata.co:18317`
- `cpa.wisedata.co` 由本机 `/etc/hosts` 指到 `10.1.1.201`，远端 core 使用 Let’s Encrypt E7 签发的 `DNS:cpa.wisedata.co` 证书；正常客户端不再需要 `NODE_TLS_REJECT_UNAUTHORIZED=0`、`NODE_EXTRA_CA_CERTS` 或 `SSL_CERT_FILE`
- 如果 Claude / Codex 所在环境配置了 `HTTP_PROXY` / `HTTPS_PROXY`，必须同步设置 `NO_PROXY` / `no_proxy` 覆盖 `cpa.wisedata.co,10.1.1.201,127.0.0.1,localhost`；否则内网 core 流量会被代理带偏，表现为 `ECONNRESET` 或 Codex `stream disconnected before completion`
- Let’s Encrypt 手动 DNS 模式证书需要续期维护；下次续期会生成新的 `_acme-challenge.cpa.wisedata.co` TXT value，不能复用本轮 value
- 详细配置、证书指纹、验证命令和回滚步骤见 `docs/operations/remote-core-maintenance.md`

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
