# OAuth 账号运行身份包实现指引

最后更新：2026-04-15

## 目的

这份文档保留“身份包路线”今天仍然有用的实现入口，并替代早期那批分散的方案稿、TODO 和目标架构草稿。

如果你接下来还要继续做：

- Quotio 宿主里的 Identity Package UI / 模型
- 基于 `CLIProxyAPIPlus` 的账号级强绑定
- 迁移到别的基于 CLI Proxy API 的宿主项目

先看这份，再进入更具体的当前文档。

## 当前真实状态

### 已经存在

Quotio 主仓库里已经有一套 Identity Package 第一阶段基础设施：

- `Quotio/Models/IdentityPackageModels.swift`
- `Quotio/Services/IdentityPackageService.swift`
- `Quotio/Views/Screens/IdentityPackagesScreen.swift`
- `Quotio/Views/Components/BindIdentityPackageSheet.swift`
- `Quotio/Views/Components/ImportIdentityPackagesSheet.swift`
- `Quotio/Views/Components/GenerateIdentityPackagesSheet.swift`

它已经覆盖：

- 身份包模型
- 本地 CRUD 与导入/生成
- 账号绑定/解绑 UI
- 代理密码 `Keychain` 存储
- `draft` / `available` / `bound` / `verificationFailed` / `blocked` 这些本地状态

### 还没有完成

下面这些依然不能写成“已落地事实”：

- 普通请求链路里按 `auth_index` 真正强制选择 identity package
- 未绑定账号时阻断真实出站
- 账号级运行时 TLS / ClientHello 真正生效
- 请求级证据链完整落盘

也就是说：

- `Identity Package` 现在更像宿主侧资源模型和 UI
- 不是已经打通的核心运行时强绑定系统

## 与多身份指纹主线的关系

现在真正已经落地并且可验证的主线，是：

- 账户级 `proxy_url`
- 账户级托管 `headers`
- Claude / Codex 上游请求的真实验证

这一部分的当前真源不是早期身份包草稿，而是：

1. [multi-identity-fingerprint-summary.md](./multi-identity-fingerprint-summary.md)
2. [account-fingerprint-architecture.md](./account-fingerprint-architecture.md)
3. [claude-request-chain.md](./claude-request-chain.md)
4. [account-clienthello-transport-prd.md](./account-clienthello-transport-prd.md)
5. [../submodules/cliproxy-plus-submodule.md](../submodules/cliproxy-plus-submodule.md)

如果你是为了另一个项目复用“多账号不同上游指纹”，优先看上面这 5 份。

如果你是为了继续把 `Identity Package` 从 UI 模型推进到运行时强绑定，再继续看下面这节。

## 继续做 Identity Package 时的硬约束

1. 绑定粒度仍然是单个 OAuth 账号 / `AuthFile`
2. 一个身份包同一时间只能绑定一个账号
3. 一个账号同一时间只能绑定一个身份包
4. 不能把“全局 proxy-url 多份轮换”伪装成账号级强绑定
5. 不能把宿主 UI 的本地状态写成“运行时已生效”
6. 不能宣称 TLS 指纹已经实现，除非核心 transport 真正支持

## 续做时的推荐路径

### 路线 A：继续做宿主侧完善

适合你要先把 Quotio 侧的交互和数据承载补稳。

优先文件：

- `Quotio/ViewModels/QuotaViewModel.swift`
- `Quotio/Views/Screens/ProvidersScreen.swift`
- `Quotio/Views/Screens/IdentityPackagesScreen.swift`
- `Quotio/Services/IdentityPackageService.swift`
- `Quotio/Services/KeychainHelper.swift`
- `Quotio/Models/RequestLog.swift`
- `Quotio/Services/RequestTracker.swift`

适合继续补的内容：

- 更清晰的绑定状态提示
- 验证结果展示
- 与请求日志字段的对接预留
- 宿主侧导入/批量管理体验

### 路线 B：继续做核心侧强绑定

这才是让“身份包真的生效”的关键路径。

需要在 `CLIProxyAPIPlus` 侧补齐：

- 常规请求链路解析实际 `auth_index`
- `auth -> identity package` 绑定读取
- 按绑定包选择 proxy / headers / transport profile
- 未绑定时拒绝真实出站
- 请求级证据字段输出

当前这部分仍然依赖：

- `third_party/CLIProxyAPIPlus`
- [../submodules/cliproxy-plus-submodule.md](../submodules/cliproxy-plus-submodule.md)
- [account-clienthello-transport-prd.md](./account-clienthello-transport-prd.md)

## 不建议再看的旧稿

下面这些早期文档已经被当前文档替代，不再作为续做入口保留：

- `oauth-account-fingerprint-TODO.md`
- `oauth-account-fingerprint-binding-plan.md`
- `oauth-account-fingerprint-current-architecture.md`
- `oauth-account-fingerprint-target-architecture.md`
- `oauth-account-runtime-identity-generic-prd.md`

这些内容里仍然有价值的部分，已经折进：

- 本文
- `multi-identity-fingerprint-summary.md`
- `account-fingerprint-architecture.md`
- `account-clienthello-transport-prd.md`

## 最后判断

如果你的目标是“把这套能力迁到另一个基于 CLI Proxy API 的宿主项目”，最务实的做法是：

1. 先复用已经验证过的账户级 `proxy_url + headers + 上游 MITM 验证`
2. 再决定要不要把 Quotio 这套 `Identity Package` UI / 模型也迁过去
3. 真要做“强绑定”与“TLS 画像”，最终还是要回到核心 transport 层
