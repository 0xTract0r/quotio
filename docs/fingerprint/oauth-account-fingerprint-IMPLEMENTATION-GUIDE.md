# OAuth 账号强绑定身份包 IMPLEMENTATION GUIDE

## 目的

这是给执行型 AI 使用的单入口文档。

如果你要在 Quotio 中继续实现“OAuth 账号强绑定运行身份包”能力，请先读这份文件，再按本文指定顺序阅读附属文档并开始编码。

不要直接从分散的需求文档自行总结实现范围。

## 一句话目标

在 Quotio 中引入“运行身份包”这一新领域对象，使每个 OAuth 账号都能绑定且只能绑定一套专属身份包；身份包至少包含代理、UA、TLS 指纹信息，并为后续运行时强绑定和验证能力预留稳定的数据结构、UI 入口和服务层接口。

## 当前阶段

当前阶段是：

- 第一阶段基础设施建设

当前阶段不是：

- 真实出站执行层改造完成
- CLIProxyAPIPlus 运行时强绑定已经打通
- TLS 指纹能力已经真正生效

## 当前仓库内已经完成的内容

本仓库中已存在以下初始基础：

- 身份包模型：
  - `Quotio/Models/IdentityPackageModels.swift`
- 身份包本地服务：
  - `Quotio/Services/IdentityPackageService.swift`
- 身份包页面骨架：
  - `Quotio/Views/Screens/IdentityPackagesScreen.swift`
- 左侧导航入口已接入：
  - `Quotio/QuotioApp.swift`
- 导航枚举已扩展：
  - `Quotio/Models/Models.swift`

这些是第一阶段的起点，不要重复造概念。

## 必读顺序

继续编码前，按下面顺序读：

1. 本文件
2. [oauth-account-fingerprint-target-architecture.md](./oauth-account-fingerprint-target-architecture.md)
3. [oauth-account-fingerprint-current-architecture.md](./oauth-account-fingerprint-current-architecture.md)

只有在你需要理解产品语义、UI 权衡时，再读：

4. [oauth-account-fingerprint-binding-plan.md](./oauth-account-fingerprint-binding-plan.md)

## 硬约束

这些约束不能被实现时偷偷弱化：

1. 绑定粒度是单个 OAuth 账号 / AuthFile，不是 provider 级。
2. 一个身份包同一时间只能绑定一个账号。
3. 一个账号同一时间只能绑定一个身份包。
4. 未绑定账号在最终目标架构中必须禁止真实出站。
5. 不能用“全局 proxy-url 多份轮换”伪装成账号级强绑定。
6. 不能宣称 TLS 指纹已经实现，除非运行时执行层真的支持。
7. 本仓库当前可以先做 UI、模型、服务、日志字段和接口预留，但不能伪装成已经具备真实强绑定能力。

## 本轮推荐实现范围

如果要继续在本仓库里编码，优先顺序如下：

### Priority 1

- 把 `IdentityPackageService` 接入 `QuotaViewModel`
- 在 `ProvidersScreen` 中展示账号当前绑定状态
- 增加绑定 / 解绑 UI 入口

### Priority 2

- 为身份包补充导入代理和编辑能力
- 为代理密码接 Keychain 存储
- 在页面中区分：
  - draft
  - available
  - bound
  - verificationFailed
  - blocked

### Priority 3

- 扩展 `RequestLog` 和 `RequestTracker` 的字段，为未来证据链预留结构
- 在 `LogsScreen` 或身份包详情页预留验证结果展示

## 本轮不应该做的事情

下面这些事情如果没有额外明确授权，不要在这一轮尝试：

- 不要大改 `AgentConfigurationService`
- 不要把账号级绑定逻辑塞进 CLI 配置文件
- 不要在 `ProxyBridge` 里靠猜测请求内容来决定账号绑定
- 不要把“验证通过”做成纯 UI 假数据
- 不要引入新第三方依赖，除非现有项目确实无法满足

## 推荐改动文件

下一轮编码最可能涉及：

- `Quotio/ViewModels/QuotaViewModel.swift`
- `Quotio/Views/Screens/ProvidersScreen.swift`
- `Quotio/Views/Components/AccountRow.swift`
- `Quotio/Services/KeychainHelper.swift`
- `Quotio/Models/RequestLog.swift`
- `Quotio/Services/RequestTracker.swift`

## 外部依赖边界

这个需求最终要成立，必须依赖 `CLIProxyAPIPlus` 上游支持以下能力：

- 常规请求链路解析实际 `auth_index`
- 按账号绑定关系选择 identity package
- 按 identity package 切换 proxy / UA / TLS profile
- 输出请求级证据字段

所以本仓库当前阶段的职责是：

- 把数据模型和 UI 先固定
- 把与上游代理对接的接口形状预留好

不是：

- 单独在 GUI 层完成全部运行时绑定

## 成功标准

对于当前阶段，成功标准是：

1. 身份包模型稳定
2. 身份包和账号之间可绑定、可解绑、可展示
3. UI 上能明确看出哪些账号未绑定
4. 代码结构为未来与 CLIProxyAPIPlus 集成留出清晰接口
5. 不破坏当前 OAuth、quota、agent setup 主链路

## 推荐工作方式

这个需求当前更适合由一个主 AI 持续推进，不适合一开始拆给多个 AI 并行乱改。

原因：

- 模型、UI、日志、上游接口边界高度耦合
- 如果多个 AI 同时写，极易出现概念漂移和假实现

只有在以下前提都稳定后，才适合拆分并行：

- 数据模型已锁定
- 绑定规则已锁定
- 上游 CLIProxyAPIPlus 接口契约已锁定

## 开工方式

继续编码时，请按下面顺序执行：

1. 先读取本文件和 `target-architecture`
2. 审查当前已存在的 `IdentityPackageModels.swift` 与 `IdentityPackageService.swift`
3. 先把账号绑定状态接到 `QuotaViewModel`
4. 再做 `ProvidersScreen` 绑定 UI
5. 每一步都保持可编译
6. 修改后至少运行一次 Debug build

## 备注

如果你在编码过程中发现某个需求必须依赖 `CLIProxyAPIPlus` 新接口，而本仓库暂时没有，请：

- 在代码中只做接口预留
- 在结果中明确标注“此能力依赖上游代理”

不要在本地 GUI 层编造一个看似完成但实际上无法运行的方案。
