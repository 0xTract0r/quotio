# 账户级独立 ClientHello / 传输画像 PRD

最后更新：2026-03-22

## 1. 背景

## 0. 文档定位与开发边界

本文件是方案 PRD，不是实现分支。

- 当前 worktree / 分支：`docs/account-clienthello-prd`
- 用途：沉淀方案、明确边界、给后续实现者提供可执行拆解
- 不作为后续实际开发分支

后续真正实施时，必须：

- 在新的实现 worktree 中开展开发
- 以项目内子模块 `third_party/CLIProxyAPIPlus` 作为 `CLIProxyAPIPlus` 的唯一开发真源
- 不再以 `/tmp/...` 目录作为持续开发入口

当前 Quotio 已经把“每账号独立运行身份”中的两部分落地到可验证状态：

- 每账号独立出口代理 `proxy_url`
- 每账号独立上游 HTTP 头档案 `headers`

但“每账号独立 TLS / ClientHello 画像”仍未真正进入运行期请求链路。现状是：

- Quotio 本地只保存了一份 TLS 档案说明，主要用于 UI 展示和边界提示
- Claude 运行期真正发请求时，仍走 `CLIProxyAPIPlus` 的 runtime transport
- 当前 runtime client 按 `proxyURL` 缓存，并不会按账号隔离 transport / 连接池
- Claude OAuth 路径已有 `uTLS HelloChrome_Auto`，但它不等于 Claude 模型请求阶段的账号级 ClientHello

这意味着：如果两个 Claude 账号共用同一种 runtime transport，即便它们的代理和 headers 已不同，TLS 侧仍可能高度相似，不能满足“每个 OAuth 账号都必须被视为一个独立运行主体”的高要求目标。

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
- `claude_chrome_like_mac_v3`

说明：

- Phase 1 不建议直接暴露 `safari` / `firefox` 这类跨度过大的 profile
- 先在“Chrome-like / Node-like”同一家族里做小范围变体，更容易与 Claude HTTP 头保持一致

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
2. 根据 `authID + proxyURL + transport_profile.profile_id` 构造 transport cache key
3. 为每个 key 分配独立 `RoundTripper` / `http.Client`
4. 禁止不同账号在相同 provider 上复用同一条 HTTP/2 连接

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

- 旧账户没有 `transport_profile` 时，默认使用 `provider-default`
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

### 15.2 开源方案

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

本次方案核对时使用过的已验证源码副本：

- Quotio 当前账号指纹架构  
  `docs/fingerprint/account-fingerprint-architecture.md`
- Claude 运行期 client 选择  
  `/tmp/CLIProxyAPIPlus-quotio/internal/runtime/executor/proxy_helpers.go`
- Claude OAuth `uTLS` transport  
  `/tmp/CLIProxyAPIPlus-quotio/internal/auth/claude/utls_transport.go`
- per-auth round tripper provider  
  `/tmp/CLIProxyAPIPlus-quotio/sdk/cliproxy/rtprovider.go`
- auth metadata `headers` 持久化与恢复  
  `/tmp/CLIProxyAPIPlus-quotio/internal/api/handlers/management/auth_files.go`
  `/tmp/CLIProxyAPIPlus-quotio/internal/watcher/synthesizer/helpers.go`
  `/tmp/CLIProxyAPIPlus-quotio/internal/watcher/synthesizer/file.go`

注意：

- `/tmp/CLIProxyAPIPlus-quotio/...` 仅用于本次方案阶段的历史核对和证据引用
- 后续任何真实实现、提交、验证都不应在 `/tmp/...` 下进行
- 后续实现必须改回项目内 `third_party/CLIProxyAPIPlus`

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
