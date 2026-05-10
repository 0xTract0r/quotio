# 账户级独立 ClientHello / 传输画像 PRD

最后更新：2026-04-30

## 1. 背景

## 0. 文档定位与开发边界

本文件是方案 PRD，不是实现分支。

- 当前实现 worktree / 分支：`.worktrees/account-centralized-runtime-source` / `feature/account-centralized-runtime-source`
- 用途：沉淀方案、明确边界、记录当前 MVP 实现与后续可执行拆解
- 本文同时包含历史 PRD 与当前实现状态；验收时以代码、测试和远端 evidence 为准

后续真正实施时，必须：

- 在新的实现 worktree 中开展开发
- 以项目内子模块 `third_party/CLIProxyAPIPlus` 作为 `CLIProxyAPIPlus` 的唯一开发真源
- 不再以 `/tmp/...` 目录作为持续开发入口

当前 Quotio 已经把“每账号独立运行身份”中的两部分落地到可验证状态：

- 每账号独立出口代理 `proxy_url`
- 每账号独立上游 HTTP 头档案 `headers`

但“每账号独立 TLS / ClientHello 画像”只完成了 MVP 级运行时接入，距离完整 provider-facing TLS 等价仍有差距。现状是：

- 账号侧 `transport_profile` 已进入 `CLIProxyAPIPlus` runtime transport 选择，HTTP client cache key 包含 `provider + authID + account + baseURLHost + proxyURL + profile`
- 即使账号没有手动填写 `transport_profile` / `tls_profile`，core 也会自动生成账号运行身份：Claude 默认 `claude_reqwest_rustls_compatible_v1`，Gemini 默认 CLI-native account isolation；Codex 默认 `codex_proxy_compatible_v1`，用于执行 Codex-Proxy-compatible Go transport approximation、隔离 HTTP client、连接池、代理 transport 和 WebSocket session；用户不需要手动生成 TLS 身份
- `runtime_identity_state` 已作为账号设置内的 core-managed 只读状态持久化，包含 `identity_id`、provider policy、source、revision、created/updated、seed/auth/account/proxy hash、profile IDs 和 history；它不保存明文 token / proxy credential
- Claude 默认 `transport_profile` / `tls_profile` 现在解析为 `claude_reqwest_rustls_compatible_v1`，参考社区 Rust `reqwest` + `rustls-tls` CLI 实现并由 Go runtime 近似执行；显式 Chrome-like preset 仍会进入 uTLS runtime transport，但只是高级 opt-in
- Codex 默认路径已迁到 `codex_proxy_compatible_v1`：managed headers 采用 Codex Desktop-like bundle，Go transport 对齐 `codex-proxy` 的 per-account/per-proxy cache、ALPN/HTTP1.1 控制与 session 隔离；`codex_rustls_native_v1` 是后续 Rust sidecar/addon 入口

这意味着：现在已经解决了“账号配置只在 UI/schema 里展示、不进 runtime”的问题，但验收口径必须继续区分“runtime builder 选中了账号级 profile”和“真实 provider-facing TLS 指纹完全等价”。后者仍需要 MITM / TLS 指纹回显等更强证据。

T057 开始把用户要求的“90% provider-edge TLS parity”收敛为项目内可执行评分；T058 后该评分只作为社区实现方案 readiness 门槛，不再作为方案设计主线：

- API 字段名为 `provider_edge_parity_score`，但它的 `claim_scope` 固定表明这是 `project-defined-provider-edge-parity-approximation-not-provider-attestation`
- `score >= 90` 只表示 controlled / core-mediated 证据足够满足本项目当前“CLI TLS 指纹策略 readiness”门槛
- 评分覆盖账号 runtime identity、managed headers 策略来源、runtime transport / TLS profile、受控 echo 返回的 TLS/HTTP2 指纹字段、账号 proxy/runtime 路径、安全边界
- 当前产品目标是“参考社区最佳实践做 CLI 运行指纹策略”；Codex、Claude、Gemini 需要按各自 CLI/runtime 分开建模，不能互相套用

## 2. 问题定义

要满足“账号级独立运行主体”，系统需要让每个账号绑定一套专属运行身份，并保证真实上游请求只使用这套身份出站。当前还缺的关键能力是：

- 把账户级 TLS / ClientHello 画像从“本地档案”变成“运行期真实 transport”
- 让该 transport 与账号、代理、HTTP 头一起组成稳定的 provider-facing 上游画像
- 提供可验证证据，证明 Anthropic 看到的是该账号自己的 transport profile，而不是共享 transport

## 3. 目标

### 3.1 产品目标

- 让每个 Claude OAuth 账号可以绑定一个独立的 runtime transport profile
- 让该 profile 在真实上游请求中控制 `ClientHello` 及其直接相关的传输画像
- 确保不同账号不会共享同一 transport / HTTP2 连接池
- 在 Quotio UI 中展示和保存该 profile，但不开放“任意 JA3 文本自由编辑”

### 3.2 工程目标

- 在不破坏现有 per-account `proxy_url` / `headers` 方案的前提下接入
- 先做 Claude Phase 1，避免一次性把所有 provider 拉进来
- 让改动集中在 `CLIProxyAPIPlus` runtime transport 层，而不是继续堆在 Quotio UI
- 具备 MITM / TLS 指纹回显式验收能力

## 4. 非目标

- Phase 1 不做所有 provider 的通用账号级 ClientHello
- Phase 1 不做任意 JA3 / JA4 字符串手工输入
- Phase 1 不追求 HTTP/3 / QUIC 画像
- Phase 1 不把 OAuth 登录链路和模型请求链路合并成同一 transport 实现
- Phase 1 不承诺“绝不被上游识别为同一运营主体”，只交付“账号级 transport 隔离能力”

## 5. 用户价值

对高并发爬虫和 Bot 风控场景，Cloudflare 一类系统会把 JA3 / JA4 等 TLS 侧信号与 HTTP 侧画像结合使用。对 Quotio 而言，做账号级独立 ClientHello 的业务价值主要体现在：

- 让账号级“出口代理 + HTTP 头 + transport”真正成套
- 降低多个账号共享同一默认 TLS 栈所带来的聚类风险
- 为后续更强的 provider-facing 画像隔离打下基础

## 6. 当前实现边界

### 6.1 Quotio 主仓库

当前已有：

- `AccountMetadataStore` 生成并保存账户级请求标识档案
- `ProvidersScreen` 提供生成、查看、重生入口
- `ManagementAPIClient` / `DirectAuthFileService` 能把账号级 `headers`、`proxy_url` 写入 auth
- 文档已明确：当前真正稳定落地的是 per-account 上游 HTTP 指纹，不是 per-account TLS 指纹

### 6.2 CLIProxyAPIPlus 运行期

当前已验证的关键边界：

- `internal/runtime/executor/proxy_helpers.go`
  - runtime `httpClientCache` 仅按 `proxyURL` 缓存
  - 若多个账号共用同一代理，就会共享 transport/连接复用
- `internal/auth/claude/utls_transport.go`
  - 已有基于 `uTLS` 的 `HelloChrome_Auto` 实现
  - 但当前用于 Claude OAuth / Anthropic auth client，不是每账号运行期 transport
- `sdk/cliproxy/rtprovider.go`
  - per-auth `RoundTripperFor` 同样仅按 `proxyURL` 缓存
- `internal/api/handlers/management/auth_files.go`
  - 已支持把 `headers` 写入 auth metadata
- `internal/watcher/synthesizer/file.go` 与 `helpers.go`
  - 已支持 metadata `headers -> auth.Attributes["header:*"]`

### 6.3 Claude / Anthropic 参考基线（2026-04-29）

Claude runtime transport 的基线必须同时看官方 contract 和高信号 transport 项目，不能把 OAuth uTLS 或某个浏览器 TLS profile 直接当成完成态。

官方资料负责定义不能偏离的协议边界：

- Anthropic API 基址与 Messages 入口：`https://platform.claude.com/docs/en/api/overview`
- Messages / Streaming：`https://platform.claude.com/docs/en/build-with-claude/working-with-messages`、`https://platform.claude.com/docs/en/build-with-claude/streaming`
- Claude Code enterprise network / proxy / CA / mTLS 边界：`https://docs.anthropic.com/en/docs/claude-code/corporate-proxy`（当前会重定向到 `https://code.claude.com/docs/en/corporate-proxy`）
- Claude Code native binary 说明：`https://code.claude.com/docs/en/getting-started`

开源项目只作为工程参考：

- `icebear0828/codex-proxy`：适合借鉴 transport abstraction、native addon boundary、fingerprint 配置/提取流水线；不适合把 Codex Desktop / Cloudflare cookie / direct fallback 直接作为 Claude 默认方案
- `refraction-networking/utls`：适合借鉴 ClientHello preset / custom spec / low-level handshake 控制；但 parrot 重点覆盖 ClientHello，不等于完整 transport 画像
- `lwthiker/curl-impersonate`：适合借鉴“TLS + HTTP/2 + headers/flags 作为一个 profile 束”的方法论
- `bogdanfinn/tls-client`：适合借鉴 profile 对象化和 TLS / HTTP2 / HTTP3 一起建模的抽象；但它本质是浏览器画像库，不能原样套到 Claude API runtime
- 社区 Claude 项目多数只做标准 `httpx` / `reqwest` / `fetch` 转发和 header 处理，缺少可直接搬入的 Claude 专属 native TLS addon；其中 `ultraworkers/claw-code` 的 Rust `reqwest` + `rustls-tls` 客户端和 proxy model 是当前可借鉴的 Claude CLI 方向，因此默认 profile 使用 `claude_reqwest_rustls_compatible_v1`，但仍不能把“Codex native TLS 方案”直接改名为 Claude 方案

当前结论：

- Claude OAuth 和 Claude runtime 必须分开验收。OAuth 目标是登录 / refresh 到认证 host；runtime 目标是 `CLIProxyAPIPlus -> api.anthropic.com/v1/messages`。
- OAuth 里的 `HelloChrome_Auto` 可以作为构建能力来源，但不能宣称为“真实 Claude 官方 runtime 指纹”。
- 不能把 Codex Desktop / 浏览器 profile 原样搬进 Claude runtime，否则容易形成“Codex/Web/浏览器 TLS + Claude API/Stainless 头”的混搭画像。
- 不能只做 JA3 / ClientHello；HTTP/2 SETTINGS、ALPN、header bundle 和连接复用同样属于 provider-facing 画像。
- cache key 至少应升级为 `provider + authID + baseURLHost + proxyURL + transportProfileID`；如果 profile 支持热切换，再加入 `profileVersion`。

建议后续 `transport_profile` 最低表达这些字段：

```json
{
  "provider": "claude",
  "profile_id": "claude_utls_chrome_like_v1",
  "family": "utls",
  "client_hello_preset": "chrome_like",
  "alpn": ["h2"],
  "http2_profile": "default",
  "header_bundle_id": "claude_cli",
  "version": 1
}
```

命名必须保持中性，例如 `claude_utls_chrome_like_v1`。不要命名成 `real_claude_native`；Claude 当前按社区实现和可验证 runtime 行为推进。

## 7. 方案总览

### 7.1 核心决策

Phase 1 采用 **“账号级 transport profile 预设”**，而不是“任意 JA3 文本编辑”。

理由：

- `ClientHello` 只是 transport 画像的一部分，任意文本输入无法自然覆盖 HTTP/2 / ALPN / 连接复用等配套行为
- 任意 JA3 编辑对产品来说过于底层，也难以验证和支持
- 预设方案更适合和 `User-Agent`、`X-Stainless-*`、代理类型一起做一致性约束

### 7.2 Phase 1 交付范围

- Provider：仅 `Claude`
- Profile 模式：预设型
- 绑定粒度：每个 auth file / OAuth 账号
- 生效链路：`CLIProxyAPIPlus -> Anthropic API`
- 验证目标：真实上游 TLS/HTTP2 指纹回显，证明不同账号命中不同 transport profile

## 8. 详细需求

### 8.1 数据模型

需要把当前“展示型 TLS 档案”升级成“运行期 transport profile”。

建议新增或重构为：

```text
AccountRuntimeTransportProfile
- profileID
- family
- provider
- preset
- alpn
- http2Profile
- notes
```

建议的 profile 预设：

- `claude_chrome_like_mac_v1`
- `claude_chrome_like_mac_v2`
- `claude_utls_chrome_133`

说明：

- Phase 1 不建议直接暴露 `safari` / `firefox` 这类跨度过大的 profile
- 先在“Chrome-like / Node-like”同一家族里做小范围变体，更容易与 Claude HTTP 头保持一致
- `claude_chrome_like_mac_v3` 与 `chrome_133` 仅保留为兼容 alias；推荐名改为 `claude_utls_chrome_133`，避免误解为官方 Claude Code TLS 指纹

### 8.2 Auth 持久化

建议在 auth metadata 中新增：

```json
{
  "transport_profile": {
    "provider": "claude",
    "profile_id": "claude_chrome_like_mac_v2",
    "family": "utls",
    "alpn": ["h2"]
  }
}
```

不建议只存一个字符串 `tls_profile: xxx`，因为后续还需要表达 profile family、ALPN 和迁移版本。

### 8.3 运行期 transport 选择

Claude executor 运行期新增规则：

1. 先读取账号的 `transport_profile`
2. 根据 `provider + authID + account + baseURLHost + proxyURL + transport_profile/tls_profile` 构造 transport cache key
3. 为每个 key 分配独立 `RoundTripper` / `http.Client`
4. 禁止不同账号在相同 provider 上复用同一条 HTTP/2 连接
5. 如果 profile 内声明的 `provider` 与 auth 的真实 provider 不一致，必须 fallback 到默认 transport 并返回可见 warning，不能把 Codex profile 套到 Claude auth 上

### 8.4 UI / 配置面

Quotio 侧需要：

- 账户设置页新增“传输画像”区块
- 默认采用推荐预设，不开放自定义 JA3 字符串
- 文案明确说明：
  - 这会影响 provider-facing transport
  - 不是本地 CLI 入站头
  - 不是 OAuth 登录阶段 transport

### 8.5 验证面

验收必须覆盖：

- 不同账号经真实上游请求时，TLS 指纹或等价 transport 指纹不同
- 同一账号重复请求时，命中同一 transport profile
- 账号 A 和账号 B 不共享连接池
- 账号级代理、账号级 HTTP 头、账号级 transport profile 同时生效

## 9. 推荐技术方案

### 9.1 推荐：在 CLIProxyAPIPlus 运行期引入 `uTLS` 账号级 transport

这是 Phase 1 推荐方案。

原因：

- 仓库已经有 `uTLS` 能力和 Anthropic 专用实现，可复用概念和部分代码
- 更容易嵌进现有 Go runtime transport 架构
- 改动集中在 runtime transport，而不是再引入跨语言 sidecar

### 9.2 备选：接入 `tls-client`

适合想更快拿到更完整“浏览器画像 + HTTP/2 画像”的情况，但集成面会比纯 `uTLS` 更大。

Phase 1 不作为首选，保留为方案 B。

## 10. 具体改动点

### 10.1 Quotio 主仓库

建议改动：

- `Quotio/Services/AccountMetadataStore.swift`
  - 把当前 `AccountTLSFingerprintProfile` 升级为真正的 runtime transport profile 数据模型
  - 生成预设 profile，而不是只写“说明性 notes”
- `Quotio/Views/Screens/ProvidersScreen.swift`
  - 增加“传输画像 preset”展示与切换
  - 明确 Phase 1 仅 Claude 生效
- `Quotio/ViewModels/QuotaViewModel.swift`
  - 保存 auth 时把 `transport_profile` 一并写入
- `Quotio/Services/ManagementAPIClient.swift`
  - 增加 `setAuthFileTransportProfile(...)`
- `Quotio/Services/DirectAuthFileService.swift`
  - quota-only / fallback 模式下支持直接读写 `transport_profile`
- `docs/fingerprint/account-fingerprint-architecture.md`
  - 更新“当前边界”和“已落地范围”

### 10.2 CLIProxyAPIPlus 子模块

建议改动：

- `internal/api/handlers/management/auth_files.go`
  - `/auth-files/fields` 支持 `transport_profile`
- `internal/watcher/synthesizer/helpers.go`
  - `transport_profile` -> runtime attributes / metadata
- `internal/watcher/synthesizer/file.go`
  - OAuth auth file 恢复 runtime transport profile
- `internal/runtime/executor/proxy_helpers.go`
  - 把 cache key 从 `proxyURL` 升级为 `provider + authID + proxyURL + transportProfileID`
  - 新增 transport builder 分支
- `internal/runtime/executor/claude_executor.go`
  - 运行期请求读取 transport profile 并传给 helper
- `internal/auth/claude/utls_transport.go`
  - 抽离可复用构建逻辑，支持“账号级 profile -> uTLS RoundTripper”
- `sdk/cliproxy/rtprovider.go`
  - 同步改为按 `authID + proxyURL + profile` 维度缓存
- 新增：
  - `internal/runtime/executor/transport_profile.go`
  - `internal/runtime/executor/transport_profile_test.go`

说明：

- 上面这些改动的真实落点都应位于项目子模块 `third_party/CLIProxyAPIPlus`
- 如果当前文档 worktree 没有把子模块完整检出，后续实现者应先在新的实现 worktree 中初始化子模块，再开始编码

## 11. 运行期设计细节

### 11.1 Cache Key

当前：

```text
cacheKey = proxyURL
```

建议改为：

```text
cacheKey = provider + "|" + authID + "|" + proxyURL + "|" + transportProfileID
```

这样可以保证：

- 同代理不同账号不再共享 transport
- 同账号不同 profile 不会串
- 同账号同 profile 仍可复用连接池

### 11.2 Profile 与 HTTP 头一致性

账号级 `transport_profile` 不应与现有 header profile 独立漂移。

建议：

- `transport_profile` 只提供少量和 Claude 头风格兼容的预设
- 当 profile 变化时，允许联动推荐新的 `User-Agent` / `X-Stainless-*`
- 但 Phase 1 不强制同时改 header，避免迁移太重

### 11.3 代理兼容

必须明确支持：

- 账号级 `socks5://...`
- 账号级 `http://...`
- 全局代理回退

并验证：

- `uTLS` transport 经 SOCKS5 代理建链正常
- `uTLS` transport 经 HTTP CONNECT 代理建链正常

## 12. 验证方案

### 12.1 必做验证

- Go 单测
  - metadata 读写
  - auth synthesizer 恢复
  - transport cache key
  - 不同账号不共享连接
- Dev app 手工验收
  - Claude 真实请求成功
  - 不同账号真实请求命中不同 transport profile
- MITM / TLS 指纹观测
  - 最少捕获 JA3/JA4 或等价 ClientHello 差异
  - 同时保留上游 `POST /v1/messages` 头和 SSE 证据

### 12.2 建议工具

- 现有 MITM 脚本链路继续保留，用于 header / request 证据
- 新增 TLS 指纹回显服务或本地指纹探针
- request log 只能作为辅助证据，不能代替真实 TLS 观测

## 13. 迁移策略

### 13.1 数据迁移

- 旧账户没有 `transport_profile` 时，由 core 自动生成并持久化账号级 runtime identity：Claude / Gemini 默认 `*_cli_native_v1`，Codex 默认 `codex_proxy_compatible_v1`；这会进入账号级 transport/cache/session 隔离
- 首次读取 / 写入账号设置时，core 会维护 `runtime_identity_state.current`；后续 profile/source/provider 语义变化会追加 `runtime_identity_state.history`，同账号重复读取不会刷新 revision 或制造空历史
- 已保存的 `tls` 档案不删除，迁移成新的 `transport_profile` 默认值

### 13.2 发布顺序

1. 先在 `Quotio Dev` 验证 Claude
2. 完成多账号 MITM / TLS 指纹观测
3. 确认回滚方案
4. 再讨论正式版推广

## 14. 风险

- `uTLS` / transport 改造后，可能影响 Anthropic 请求稳定性
- 若只改 TLS，不改连接池隔离，会出现“看似有 profile，实际仍共享连接”
- 若 TLS 画像与 HTTP 头风格冲突，反而更显眼
- 真实 TLS 指纹验证比 header 验证更难，测试成本会上升

## 15. 开源参考与来源

### 15.1 行业/官方资料

- Cloudflare JA3 / JA4 指纹说明
  https://developers.cloudflare.com/bots/additional-configurations/ja3-ja4-fingerprint/
- Cloudflare JA4 Signals 介绍
  https://blog.cloudflare.com/ja4-signals/
- Anthropic 关于位置判断使用 `IP address and other signals` 的说明
  https://privacy.claude.com/en/articles/11186740-does-claude-use-my-location
- Claude Code enterprise network / proxy / CA / mTLS
  https://docs.anthropic.com/en/docs/claude-code/corporate-proxy
- Claude Messages / Streaming API
  https://platform.claude.com/docs/en/build-with-claude/working-with-messages
  https://platform.claude.com/docs/en/build-with-claude/streaming

### 15.2 开源方案

- `icebear0828/codex-proxy`
  https://github.com/icebear0828/codex-proxy
  参考点：Rust N-API native transport、`reqwest 0.12.28` / `rustls 0.23.36` 版本基线、fingerprint 配置化、headers/UA 分层；排除点：Cloudflare cookie capture/replay、direct fallback、未经本项目 provider-facing 验证的 Desktop 完全仿真声明。
- `openai/codex`
  https://github.com/openai/codex
  参考点：官方 Codex 客户端的 `originator`、`User-Agent`、residency header、`reqwest` / `rustls` 依赖基线；这是 Codex 方向的第一方来源，不等于 Claude 方向来源。
- `777genius/claude-code-source-code-full`
  https://github.com/777genius/claude-code-source-code-full
  参考点：Anthropic SDK client、应用层 `User-Agent` / headers、base URL、proxy、CA/mTLS 配置边界；排除点：不能把应用层 `fingerprint.ts` 或客户端源码片段当成 JA3 / JA4 / HTTP2 SETTINGS 证据。
- `ultraworkers/claw-code`
  https://github.com/ultraworkers/claw-code
  参考点：Anthropic base URL、Rust/reqwest 客户端和 proxy 配置方式；排除点：未提供可复用的 Claude provider-edge TLS fingerprint 基线。
- `anthropics/claude-code` 与 Claude Code 官方文档
  https://github.com/anthropics/claude-code
  https://code.claude.com/docs/en/corporate-proxy
  参考点：企业代理、CA、mTLS 和网络边界；排除点：未公开官方 Claude Code JA3 / JA4 / HTTP2 SETTINGS 基线。
- `uTLS`  
  https://github.com/refraction-networking/utls
- `tls-client`  
  https://github.com/bogdanfinn/tls-client
- `surf`  
  https://github.com/enetx/surf
- `spoofed-round-tripper`  
  https://github.com/juzeon/spoofed-round-tripper
- `curl-impersonate`  
  https://github.com/lwthiker/curl-impersonate

### 15.3 本项目开发真源与已验证核对入口

开发真源：

- Quotio 主仓库
- `third_party/CLIProxyAPIPlus` 子模块

本次实现核对入口：

- Quotio 当前账号指纹架构  
  `docs/fingerprint/account-fingerprint-architecture.md`
- Claude 运行期 client 选择  
  `third_party/CLIProxyAPIPlus/internal/runtime/executor/helps/proxy_helpers.go`
- Claude OAuth `uTLS` transport  
  `third_party/CLIProxyAPIPlus/internal/auth/claude/utls_transport.go`
- per-auth round tripper provider  
  `third_party/CLIProxyAPIPlus/sdk/cliproxy/rtprovider.go`
- auth metadata `headers` 持久化与恢复  
  `third_party/CLIProxyAPIPlus/internal/api/handlers/management/auth_files.go`
  `third_party/CLIProxyAPIPlus/internal/watcher/synthesizer/helpers.go`
  `third_party/CLIProxyAPIPlus/internal/watcher/synthesizer/file.go`

注意：

- 后续任何真实实现、提交、验证都必须继续使用项目内 `third_party/CLIProxyAPIPlus`
- `/tmp/...` 仅允许历史比较，不是开发或构建真源

### 15.4 Claude / Codex 指纹来源分界

- Codex 方向按 `icebear0828/codex-proxy` 社区实现迁入：Desktop-like managed headers、native transport 分层、per-account/per-proxy client cache、ALPN/HTTP1.1 开关和 provider-facing 验证方法已经成为本项目 Codex 方案来源。
- Claude 方向已核对 `anthropics/claude-code`、`ultraworkers/claw-code`、`777genius/claude-code-source-code` 与 Claude proxy 项目：没有发现可像 `codex-proxy` 一样直接搬入的 Claude native TLS addon。
- 因此 Claude 不能复用 Codex TLS 指纹值；当前默认采用 `claude_reqwest_rustls_compatible_v1`，参考 `ultraworkers/claw-code` 的 Rust `reqwest` + `rustls-tls` 客户端和 proxy model，并复用本项目账号级 transport 抽象、profile cache key、provider-facing 验证机制。
- `claude_utls_chrome_133`、旧 `claude_chrome_like_mac_v3` / `chrome_133` 只作为兼容 alias 和高级显式 opt-in。Chrome-like uTLS 不是 `provider-default`，也不是 Claude Code CLI 完整指纹仿真。
- T048 追加了 Claude access-token-only 隔离本地 core 与远端 core 验证：历史验证时使用旧 alias `claude_chrome_like_mac_v3`，等价解析为当前 canonical `claude_utls_chrome_133`；controlled echo 返回 JA3 / JA4 / HTTP/2 指纹字段，同一 core 的真实 `/v1/messages?beta=true` 返回 `OK` / `OK.`。这关闭运行时 enforcement，不关闭 Anthropic provider-edge TLS parity。
- T054 追加 core-managed account runtime identity：不同 auth file / account / base URL / proxy / profile 不共享 runtime HTTP client。Claude 在 T058 改为 `claude_reqwest_rustls_compatible_v1` 默认 profile，Gemini 保持 CLI-native，Codex 在 T058 改为 Codex-Proxy-compatible 默认 profile。Chrome-like uTLS 仍只在用户显式选择 `claude_utls_chrome_133` 或兼容 alias 时启用。
- T056 纠偏补齐持久化账号运行身份：`runtime_identity_state` 由 core 自动维护并只读返回给 management UI，记录 identity revision 和历史变化。它解决的是“账号 TLS 身份自动生成 / 隔离 / 可审计”。
- T058 Codex MVP 已改为 `codex_proxy_compatible_v1`：headers 和 Go transport 行为按 `codex-proxy` 社区实现对齐；Rust `reqwest/rustls` wire-level clone 仍需后续 sidecar/addon。

## 16. 最终建议

建议确认后按以下顺序实施：

1. 只做 `Claude Phase 1`
2. 采用 `uTLS` 账号级 transport profile 预设方案
3. 先完成 `auth metadata + runtime transport + cache key` 三件套
4. 只有在真实 TLS 指纹观测跑通后，才把 UI 文案从“档案”升级为“已实际生效”

这条路径能最小化风险，同时保证最终交付的是“真实上游 transport 隔离能力”，而不是新的展示型配置项。

## 17. 实施清单

### 17.1 Milestone A: 核心运行期能力

- `CLIProxyAPIPlus` 新增 `transport_profile` metadata 持久化
- `CLIProxyAPIPlus` runtime transport cache key 改为账号级
- `Claude` executor 按账号选择 transport profile
- 新增账号级 `uTLS` RoundTripper builder

验收标准：

- 两个 Claude 账号即使共用同一 `proxy_url`，也不会共享同一 transport cache key
- 同一账号重复请求仍可复用自己的 transport / 连接

### 17.2 Milestone B: Quotio 配置与 UI

- `Quotio` 增加 transport profile 数据模型
- `ProvidersScreen` 展示和切换 Claude transport preset
- `ManagementAPIClient` / `DirectAuthFileService` 能写入 `transport_profile`
- 文案明确“Phase 1 仅 Claude 生效”

验收标准：

- 新增/编辑 Claude 账号时，profile 能持久化到 auth metadata
- 旧账户没有 profile 时能自动回落到默认 preset

### 17.3 Milestone C: 验证与回归

- 新增 transport profile 单元测试
- Dev app 真实 Claude 请求通过
- TLS 指纹观测工具能区分不同账号 profile
- 保持现有 header / proxy / SSE 验收链路不回退

验收标准：

- 实际观测能看到不同账号的 TLS/等价 transport 差异
- 现有 `proxy_url` 和 `headers` 功能不受影响

## 18. 给实施者的建议顺序

建议另一个 AI 按下面顺序工作，不要并行乱改：

1. 新开实现 worktree，不要在当前 `docs/account-clienthello-prd` 文档分支上开发
2. 先在实现 worktree 初始化 `third_party/CLIProxyAPIPlus` 子模块
3. 先只改 `CLIProxyAPIPlus` 子模块
4. 跑最小 Go 单测，确认 `transport_profile` metadata 和 cache key 逻辑成立
5. 再回到 Quotio 主仓库补 UI / 持久化
6. 最后跑 Dev app + MITM + TLS 指纹观测

## 19. 推荐 first patch

如果要把第一轮实现压到最小，可先只做下面这些：

- `internal/api/handlers/management/auth_files.go`
  - 支持 `transport_profile`
- `internal/watcher/synthesizer/helpers.go`
  - 恢复 `transport_profile`
- `internal/runtime/executor/proxy_helpers.go`
  - cache key 升级
- `internal/auth/claude/utls_transport.go`
  - 暴露 profile-aware builder
- `internal/runtime/executor/claude_executor.go`
  - 挂上新的 transport selector

这样第一轮就能先证明“运行期账号级 ClientHello”可行，再决定 UI 怎么跟。
