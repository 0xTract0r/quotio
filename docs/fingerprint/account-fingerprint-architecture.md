# 账户级请求标识架构说明

最后更新：2026-04-14

> 说明：如果你现在要快速了解“多身份指纹 / 账户级代理与 UA / TLS 画像 / CLIProxyAPIPlus 二次开发”这批工作的全貌，先读 [`multi-identity-fingerprint-summary.md`](./multi-identity-fingerprint-summary.md)。本文保留为这轮实现的架构快照与细节说明。

## 这次需求的真实目标

原始诉求是“为每个账户配置独立的 UA 信息、SSL 指纹等，并验证真实请求是否真的用了这些指纹”。

落到当前 Quotio + CLIProxyAPIPlus 这套链路，真正有业务价值的目标不是“改本地 CLI 入站 UA”，而是：

- 让不同 Claude / Codex 账号在转发到上游提供商时，带上不同的上游 HTTP 指纹
- 让这些指纹能在 Quotio UI 中生成、查看、保护性重生
- 能用独立证据证明上游真实请求用了这些值，而不是只看 CLIProxyAPI 的自报日志
- 明确区分“当前能做到的 HTTP 指纹”和“当前做不到的 per-account TLS/SSL 指纹”

## 预期需要做什么

为了满足这个需求，实际需要拆成 4 层：

1. 数据层
   - 为每个账户保存独立的“上游请求标识”档案
   - 档案至少要覆盖 `User-Agent` 与一组能稳定区分请求来源的 header
2. UI 层
   - 在账户设置页提供生成、查看、再次生成入口
   - 再次生成必须有保护，避免误触把现有标识覆盖掉
3. 运行时接入
   - Quotio 自己发的 quota / warmup / provider 请求要能吃到这些标识
   - Claude / Codex 经过 CLIProxyAPIPlus 转发到上游时，也要能把账户级 header 真正带出去
4. 验证层
   - 不能只看本地日志
   - 必须能抓到真实上游 `POST /v1/messages` 或等价请求，并核对 header / SSE

## 实际做了什么

### 已完成

- Quotio 账户设置页已经支持为账户生成、查看、保护性重生“上游请求标识”
- Claude / Codex 账户不再只处理一个 `User-Agent` 字段，而是保存一整组上游 HTTP headers
- 这些账户级 headers 已接入 Claude / Codex 的上游运行链路
- 已用 MITM 独立抓包证明 Claude 上游真实请求确实带上了保存的 header，并收到了真实 SSE 响应
- 正式版已经完成一次受控 patched core 迁移，并通过 MITM 证明 Claude 真实上游请求已经和保存的账号指纹 `MATCH`
- Codex 的正式版 MITM 验收脚本也已经落地，并按真实路由 `https://chatgpt.com/backend-api/codex/responses` 收口
- 新增了一套隔离开发测试方案，保证测试版 Quotio 不影响常驻正式版
- 新增 `watch-claude-mitm-session.sh`，把“正常开 devapp -> 启动脚本 -> 发一句话 -> 打印真实上游请求”收敛成单脚本工作流
- 新增 managed-mode 恢复链路，脚本退出后会恢复：
  - Claude 测试账号的 `proxy_url`
  - `autoStartProxy`
  - dev bundle 下的 `debugTestCAFile`
  - `18417/28417` 监听
  - 测试 core 二进制

### 没有伪装成“已完成”的部分

- 当前没有做成“所有 provider 都支持 per-account TLS/SSL 指纹”
- 当前没有做成“Claude / Codex 运行期真正可按账户自定义 TLS ClientHello”
- 目前真正稳定落地的是“per-account 上游 HTTP 指纹”

这不是偷换需求，而是结合底层链路后的技术收敛：

- 对 Claude 来说，当前最有业务意义且可验证的是上游 HTTP headers
- 对 Codex 来说，当前也主要是上游 HTTP / WS headers
- TLS 指纹是否能 per-account 生效，取决于 CLIProxyAPIPlus 对具体 provider executor 的实现边界

## 当前架构与实现落点

### Quotio 主仓库

实现分成 5 个落点：

1. 账户档案与生成
   - `AccountMetadataStore` 负责定义账户级请求标识模型、默认值与 provider 差异
   - Claude / Codex 保存的是一整组上游 HTTP headers，而不是单独一个 `User-Agent`
2. UI 交互
   - 账户设置页提供生成、查看、保护性重生
   - 重生前有二次确认，避免误触覆盖已有标识
3. 本地 auth 写回
   - 通过 `ManagementAPIClient` / `DirectAuthFileService` 把 `headers`、`proxy_url` 等写回 auth 记录
   - 这样 CLIProxyAPIPlus 在运行时可以直接读取到账户级 headers / proxy
4. 验证脚本
   - Claude：`anthropic-mitm-capture.py`、`verify-claude-mitm-capture*.sh`
   - Codex：`openai-mitm-capture.py`、`verify-codex-mitm-capture*.sh`
5. 正式迁移与回滚
   - `promote-cliproxy-plus-production.sh`
   - `rollback-cliproxy-plus-production.sh`

### CLIProxyAPIPlus 子模块

真正让“保存的账号指纹出现在上游请求里”的核心逻辑在子模块里：

- Claude：
  - 在 `PrepareRequest` 和 `applyClaudeHeaders` 中，除了默认 cloaking 头，还会显式读取 auth 记录里的托管 headers
  - 最终再用这些保存值覆盖上游请求头
- Codex：
  - 继续沿用 `applyCodexHeaders` 路径，把 auth 记录中的 `User-Agent` / `Version` 写到上游请求
- 出站代理：
  - `newProxyAwareHTTPClient` 优先使用账号级 `auth.ProxyURL`
  - 因此把单账号 `proxy_url` 指到 MITM，就能抓到 `CLIProxyAPIPlus -> provider` 的真实上游请求

## 最终业务结果

截至当前 worktree，已经可以把这个需求收敛成下面这组可交付结果：

- 每个账户可拥有独立的“上游请求标识”
- UI 中可生成、查看、保护性重生
- Claude 正式版已验证：真实上游请求头与保存值 `MATCH`
- Codex 已具备同口径 MITM 验证工具链
- 正式迁移有明确备份、回滚、受控 restart 和验收脚本

### 1. Quotio UI / ViewModel

主要入口：

- [`Quotio/Views/Screens/ProvidersScreen.swift`](../../Quotio/Views/Screens/ProvidersScreen.swift)
- [`Quotio/ViewModels/QuotaViewModel.swift`](../../Quotio/ViewModels/QuotaViewModel.swift)

职责：

- 在账户设置页展示“上游请求标识”
- 触发生成 / 查看 / 再生成
- 把 Claude / Codex 的 header profile 保存到 auth / metadata

### 2. 本地持久化与管理 API 适配

主要文件：

- [`Quotio/Services/AccountMetadataStore.swift`](../../Quotio/Services/AccountMetadataStore.swift)
- [`Quotio/Services/DirectAuthFileService.swift`](../../Quotio/Services/DirectAuthFileService.swift)
- [`Quotio/Services/ManagementAPIClient.swift`](../../Quotio/Services/ManagementAPIClient.swift)

职责：

- 保存账户级指纹元数据
- 兼容直接读写 auth 文件与 management API
- 对 Claude / Codex 统一写入整组 `headers`

### 3. Quotio 自己的运行时请求

主要文件：

- [`Quotio/Services/AccountFingerprintRuntime.swift`](../../Quotio/Services/AccountFingerprintRuntime.swift)
- 各 provider quota fetcher / warmup service

职责：

- 把账户级指纹应用到 Quotio 自己发出的 provider 请求
- 这部分不依赖 CLIProxyAPIPlus，属于 Quotio 本地运行时

### 4. Claude / Codex 上游转发链路

生产链路可以概括为：

`CLI / IDE -> Quotio ProxyBridge -> CLIProxyAPIPlus -> provider upstream`

关键点：

- 用户真正关心的“账号可区分请求指纹”，发生在 `CLIProxyAPIPlus -> provider upstream`
- 当前已经打通的是账户级 HTTP header profile
- Claude 的真实上游校验已经通过 MITM 抓到：
  - `POST https://api.anthropic.com/v1/messages?beta=true`
  - `User-Agent`
  - `X-App`
  - `X-Stainless-*`
  - `text/event-stream` SSE 响应

### 5. managed-mode 测试 CA 注入

主要文件：

- [`Quotio/Services/Proxy/CLIProxyManager.swift`](../../Quotio/Services/Proxy/CLIProxyManager.swift)
- [`scripts/watch-claude-mitm-session.sh`](../../scripts/watch-claude-mitm-session.sh)

这次为了让 managed-mode 的 MITM 验收稳定，额外补了一层显式注入：

- 脚本临时写入 dev bundle 的 `debugTestCAFile`
- Quotio 启动 CLIProxyAPI 时会从该 defaults key 读取路径
- 然后显式注入 `QUOTIO_TEST_CA_FILE`
- 脚本退出时恢复或删除该 key

这样就不再依赖“GUI app 重启后进程环境是否完整保留”。

## 验证方式

### 已验证事实

- Claude 真实上游请求头已通过 MITM 抓包验证
- 响应不是伪造文本，而是真实 `text/event-stream` SSE
- managed-mode 的恢复链路已验证能恢复：
  - `18417`
  - `28417`
  - Claude auth `proxy_url`
  - `autoStartProxy`
  - `debugTestCAFile`

参考文档：

- [`isolated-dev-testing.md`](../operations/isolated-dev-testing.md)

### 当前最靠谱的验收口径

- 不再以 CLIProxyAPI request log 作为唯一证据
- 以 MITM 抓到的真实上游 `POST /v1/messages` + SSE 为准
- 对 Codex，则以 MITM 抓到的真实 `chatgpt.com/backend-api/codex/responses` 或 `api.openai.com` 真实上游请求为准

### 为什么 MITM 证据有效

这里抓到的不是 Quotio UI 的本地请求头，也不是从响应里“回显”出来的请求头。

有效性链路是：

1. Quotio 客户端只会把 CLI/IDE 请求转到本地 `18317/28317`
2. `ProxyBridge` 目标永远是本地 `CLIProxyAPI`
3. `CLIProxyAPIPlus` executor 在真正 `httpClient.Do(...)` 之前组装上游请求头
4. executor 出站时优先使用账号级 `proxy_url`
5. MITM 代理正是挂在这个账号级 `proxy_url` 上

因此 MITM 抓到的是 `CLIProxyAPIPlus -> provider` 的真实上游 HTTP 请求头。

## 当前边界与风险

### 已落地的范围

- Claude / Codex 账户级 HTTP 指纹
- Quotio 本地请求的账户级 HTTP 指纹
- 账户设置页可生成 / 查看 / 保护性重生

### 明确的边界

- 不是所有 provider 都支持同一套 per-account 指纹模型
- 运行期 TLS 指纹不等于 OAuth 登录链路里的 uTLS 指纹
- 当前不能把“每账户 SSL 指纹”写成一个已经完全交付的事实

## CLIProxyAPIPlus 源码该放在哪里

当前已经把“长期维护入口”迁入本项目：

- 子模块路径：`third_party/CLIProxyAPIPlus`
- 维护说明：[`cliproxy-plus-submodule.md`](../submodules/cliproxy-plus-submodule.md)
- 构建脚本：[`scripts/manage-cliproxy-plus.sh`](../../scripts/manage-cliproxy-plus.sh)

### 结论

当前采用的是 Git submodule 方案。

当前维护策略以 [`cliproxy-plus-submodule.md`](../submodules/cliproxy-plus-submodule.md) 为准：

- 子模块真源：`third_party/CLIProxyAPIPlus`
- 当前 fork remote：`git@github.com:0xTract0r/CLIProxyAPIPlus.git`
- 当前主线 upstream：`git@github.com:router-for-me/CLIProxyAPI.git`
- 已关闭历史 Plus 仓库：`git@github.com:router-for-me/CLIProxyAPIPlus.git`
- 当前维护基线：以 `0xTract0r/CLIProxyAPIPlus` 已公开提交链承载 Plus/社区补丁，以 `router-for-me/CLIProxyAPI` 作为主线演进参考

### 不建议继续放在 `/tmp` 的原因

- `/tmp` 不是可持续真源
- 机器重启、清理临时目录后容易丢
- 无法稳定记录“补丁基线、引用版本、回滚点”
- 新会话无法低成本恢复上下文

### 项目级规则

后续任何 `CLIProxyAPIPlus` 实现都应遵守：

- 开发真源固定为 `third_party/CLIProxyAPIPlus`
- 方案 worktree 和实现 worktree 分离；文档分支不继续承接实现
- 如果当前 worktree 子模块未初始化，先修复子模块状态，不要绕到 `/tmp/...` 继续开发
- `/tmp/...` 仅允许作为历史核对证据，不允许作为提交、构建、推广的真实来源

### 当前已经补齐的管理面

- 固定路径：`third_party/CLIProxyAPIPlus`
- 当前 fork remote：`0xTract0r/CLIProxyAPIPlus`
- 当前主线 upstream：`router-for-me/CLIProxyAPI`
- 已关闭历史 Plus 仓库：`router-for-me/CLIProxyAPIPlus`
- 当前对齐策略：Plus/社区补丁维护在 fork；主线通用能力参考 `CLIProxyAPI`，按需审计后重放到 Plus fork
- 重建命令：`./scripts/manage-cliproxy-plus.sh build`
- 联调脚本：`scripts/watch-claude-mitm-session.sh`

## 给后续维护者的结论

这次需求已经从“抽象指纹”收敛成“账户级上游 HTTP 指纹 + 可证明的真实链路接入”。

如果后续要继续往“每账户 TLS 指纹”推进，正确入口不是再改 Quotio UI，而是继续研究并改造 CLIProxyAPIPlus 对 Claude / Codex 运行时 transport / dialer / TLS 握手的实现边界。

实施时还应遵守一条额外约束：

- 不要在当前文档 worktree 上继续实现；应新开实现 worktree，并以项目子模块为唯一开发真源
