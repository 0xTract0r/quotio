# 多身份指纹与 CLIProxyAPIPlus 二次开发总览

最后整理：2026-04-12

## 目的

这份文档把当前 `docs/` 里与“多身份指纹 / 账户级代理与 UA / TLS 画像 / CLIProxyAPIPlus 二次开发”相关的内容收敛成一份总览，方便在另一个基于 CLIProxyAPI 的宿主项目中直接复用。

本文不替代已有专项文档；它的作用是回答四个问题：

1. 当前这套方案到底已经做到了什么。
2. 哪些能力目前只是 UI / 数据模型预留，还没有真正进运行时。
3. 对 `CLIProxyAPIPlus` 的二次开发，哪些补丁已经有了，哪些还要继续做。
4. 如果把这套能力迁到另一个 Mac 宿主项目，最小可复用边界是什么。

## 一句话结论

当前已经稳定落地的是：

- 账户级 `proxy_url`
- 账户级上游 HTTP headers，重点是 `User-Agent` 与 Claude / Codex 的托管头
- 基于 MITM 的真实上游验收链路

当前还没有真正落地的是：

- 账号绑定的 `identity package` 进入 `CLIProxyAPIPlus` 运行时强制执行
- 每账户独立的运行期 TLS / ClientHello transport profile
- 面向所有 provider 的统一多身份运行时框架

因此，这轮工作更准确的交付物不是“完整多身份指纹系统”，而是：

- 一个已经能跑通 Claude / Codex 账户级 HTTP 指纹的宿主项目实现
- 一套已经验证过的 `CLIProxyAPIPlus` 核心补丁与验收方法
- 一组为下一阶段 transport / TLS 改造预留好的 UI、模型和文档边界

## 迁移到另一个宿主项目时的二次开发说明

这一节不再按 Quotio 的具体页面流程写，而是按“迁移能力”来写。无论下一个宿主项目是桌面 App、CLI 配置器、Web 控制台还是混合 UI，只要底层仍然接 `CLIProxyAPI` / `CLIProxyAPIPlus`，都应满足这一节的能力约束。

### 1. 迁移目标

要迁移的不是某个具体页面，而是一套能力组合：

- 账号级出口代理
- 账号级上游 HTTP 指纹
- 本地 identity package 资源模型
- 宿主到核心的配置写回链路
- 基于真实上游请求的验收链路

这里的核心目标是：

- 让不同账号能带着不同的上游身份发请求
- 让宿主项目能管理这些身份
- 让验证基于 provider-facing 请求，而不是基于本地自报日志

### 2. 宿主项目必须承担的职责

无论 UI 长什么样，宿主层都至少要承担下面 4 类职责。

#### A. 账号配置职责

宿主必须允许用户在“账号”这个粒度上管理：

- 备注或别名
- 账号级 `proxy_url`
- 账号级上游 HTTP headers
- provider 特定可写字段，例如部分 provider 的 `user_agent`

要求：

- 这些配置不能只停留在宿主本地展示层
- 保存后必须能写回核心真正会读取的 auth 记录

#### B. 身份资源管理职责

宿主必须有一套本地资源模型，用来承载：

- 代理配置
- User-Agent 档案
- TLS 档案说明
- 本地验证状态
- 账号与身份资源的绑定关系

这套模型可以叫 `identity package`，也可以用别的名字，但语义要一样：它代表“账号的运行身份资源集合”。

#### C. 状态表达职责

宿主必须能让用户看见至少这些状态：

- 账号是否已有独立代理
- 账号是否已有独立 HTTP 指纹
- 账号是否已绑定身份资源
- 某个身份资源是否可绑定、是否被阻塞、是否验证失败

要求：

- 宿主必须把“本地档案状态”和“真实运行时已生效”区分开
- 不能把未进入运行时的 TLS 档案写成已生效事实

#### D. 验收组织职责

宿主必须提供一套可重复执行的验证路径，至少能完成：

- 将目标账号的代理临时切到 MITM
- 触发一条最小真实请求
- 读取 provider-facing 上游请求
- 把抓到的头部与该账号保存值做对比

如果宿主没有把这套验证链路组织起来，那么即使核心补丁存在，也很难低成本确认迁移是否成功。

### 3. 核心与宿主之间的契约

二次开发时，最重要的不是 UI 细节，而是宿主和核心之间的数据契约不要断。

#### 当前已经证明可行的契约

宿主写入：

- auth 的 `proxy_url`
- auth 的 `headers`
- 某些 provider 的 `user_agent`

核心读取：

- `auth.ProxyURL`
- `auth.Attributes["header:*"]`
- provider executor 中的托管头注入逻辑

这条契约已经在 Claude / Codex 场景下被证明可行。

#### 当前还没打通的契约

下面这些还不能当成现成能力复用：

- `auth_index -> identity package -> runtime transport profile`
- 账号级 TLS / ClientHello profile 注入
- 通用的 identity package management API

所以迁移时应把“HTTP 指纹链路”与“transport / TLS 链路”分两期处理。

### 4. 迁移时宿主 UI 可以自由变化，但能力不能缺

下一宿主项目不需要照抄 Quotio 的页面结构。

你可以做成：

- 账号列表 + 侧边抽屉
- 单页表单
- 分步 wizard
- 表格 + 详情面板
- CLI 交互式配置器

都可以。

但无论 UI 形式怎么变，至少要保留下面这些能力点：

- 能修改单账号代理
- 能修改或生成单账号 HTTP 指纹档案
- 能把这些值写回 auth
- 能管理本地身份资源
- 能表达账号与身份资源的绑定关系
- 能执行真实上游验收

也就是说，迁移时可以替换“交互形状”，不能删除“能力节点”。

### 5. 推荐迁移顺序

#### Phase 1: 先迁移已验证的 HTTP 指纹链路

先做：

- 单账号 `proxy_url`
- 单账号托管 HTTP headers
- 写回 auth
- MITM 验收

原因：

- 这是当前最稳定、最容易复用、也最有业务价值的部分
- Claude / Codex 已经有明确证据链

#### Phase 2: 再迁移宿主侧身份资源管理

再做：

- 本地 identity package 模型
- 绑定关系
- 可视化状态
- 批量生成 / 导入 / 本地阻塞状态

原因：

- 这一步解决的是“怎么大规模管理多身份资源”
- 但它本身不等于核心已强制执行

#### Phase 3: 最后推进核心 transport / TLS

最后做：

- 账号级 transport builder
- transport cache key 重构
- 连接池隔离
- TLS 指纹观测

原因：

- 这是技术风险最高的一层
- 也最不适合和宿主 UI 改造混在一起同时推进

### 6. 当前阶段的交付判断标准

如果要判断另一个宿主项目的迁移是否“做到了当前水平”，可以只看下面这些问题。

#### 宿主侧

- 用户是否不改 JSON 也能完成单账号代理与 HTTP 指纹配置
- 保存后是否真的写回 auth
- 宿主是否能管理本地身份资源
- 宿主是否能表达绑定状态和本地运营状态
- 宿主是否明确区分“本地档案”和“运行时生效”

#### 核心侧

- 核心是否优先读取账号级 `proxy_url`
- 核心是否能把账号级 `headers` 注入真实上游请求
- Claude / Codex 的 provider-facing 请求是否能被 MITM 抓到并对比

只要这几项成立，就说明新宿主项目至少达到了当前这轮工作的第一阶段水平。

### 7. 当前阶段明确不迁移什么

为了避免二次开发范围失控，这里明确列出当前阶段非目标：

- 不要求照搬 Quotio 的页面布局
- 不要求照搬 Quotio 的文案、控件和视觉结构
- 不要求所有 provider 一次性统一接入
- 不要求任意 JA3 / JA4 文本编辑
- 不把本地 identity package 绑定伪装成 runtime enforcement
- 不把 OAuth 阶段 uTLS 当成模型请求阶段的账号级 TLS

### 8. 对下一个 AI 的直接指令

如果下一次要让 AI 在另一个宿主项目里继续做，应该先按下面顺序理解任务：

1. 先确认宿主层能否把账号级 `proxy_url` / `headers` 写回 auth
2. 再确认底层核心是否已经支持读取这些字段并注入上游请求
3. 先完成 HTTP 指纹链路迁移
4. 再补宿主层的身份资源管理
5. 最后才讨论 TLS / ClientHello transport

不要从“重做一套页面”开始，也不要从“直接做 TLS 指纹”开始。

## 先区分两层系统

为了避免在另一个项目里重复踩坑，必须先把宿主层和核心层拆开。

### 宿主项目层

以 Quotio 为例，宿主项目负责：

- 账号列表、账号设置页、身份包页面
- 本地持久化账户级指纹档案
- 把 `proxy_url`、`headers` 写回 auth 文件或 management API
- dev app 隔离、MITM 验收脚本、正式迁移脚本

这层决定“用户怎么配置”和“如何做验证”。

### CLIProxyAPI / CLIProxyAPIPlus 核心层

核心代理负责：

- 运行时根据 auth 记录选择账号
- 读取账号级 `proxy_url`
- 读取账号级 `headers`
- 在真正的 provider-facing 上游请求里应用这些值
- 决定 transport、连接池、TLS 握手、HTTP/2 复用

这层决定“这些配置是否真的在真实上游请求里生效”。

多身份能力是否成立，最终要看核心层，不看宿主 UI 是否能展示。

## 实现附录：Quotio 当前已完成能力

### A. 宿主项目侧已完成

#### 1. 账户级指纹档案生成与保存

Quotio 已经能为账号生成并保存账户级指纹档案，入口在：

- `Quotio/Services/AccountMetadataStore.swift`
- `Quotio/Views/Screens/ProvidersScreen.swift`
- `Quotio/ViewModels/QuotaViewModel.swift`

当前档案内容包括：

- `userAgent`
- `tls` 档案说明
- `upstreamHTTP.headers`

其中最关键的是 Claude / Codex 的托管 headers：

- Claude：`User-Agent`、`X-App`、`X-Stainless-Package-Version`、`X-Stainless-Runtime-Version`、`X-Stainless-Timeout`
- Codex：`User-Agent`、`Version`

#### 2. 账户设置页已经支持最小操作闭环

当前 UI 已支持：

- 生成账户级指纹档案
- 查看当前档案
- 保护性重新生成
- 把账户级托管 headers 写回 auth
- 把账户级 `proxy_url` 写回 auth

这套能力适合直接迁移到另一个宿主项目，因为它与具体核心实现解耦得比较干净。

#### 3. Quotio 自己发出的部分请求已经吃到账户级 UA

`Quotio/Services/AccountFingerprintRuntime.swift` 已把本地保存的 UA 用到 Quotio 自己发出的部分 provider 请求上。

这代表：

- 宿主自己的 quota / warmup / provider 请求可以先做到账户级 UA
- 但这不等于 CLI 经 `CLIProxyAPIPlus` 转发时的真实上游请求也已全部完成

#### 4. identity package 页面与本地绑定模型已经有了

Quotio 已经有：

- `Quotio/Models/IdentityPackageModels.swift`
- `Quotio/Services/IdentityPackageService.swift`
- `Quotio/Views/Screens/IdentityPackagesScreen.swift`

这部分已经提供：

- package 创建
- 批量生成
- 本地绑定
- 本地验证状态记录

但这套能力目前还是宿主本地模型，不是核心运行时强制执行。

### A1. Quotio UI / ViewModel 实际改动清单

如果后续要把这套能力迁到另一个基于 CLIProxyAPI 的宿主项目，不能只迁核心补丁。Quotio 这边已经做过一整套配套 UI / ViewModel 改造；少掉这一层，用户就没法配置、查看、绑定和验证。

#### 1. 侧边导航与页面路由

关键文件：

- `Quotio/QuotioApp.swift`
- `Quotio/Models/Models.swift`

已做改动：

- 新增 `NavigationPage.identityPackages`
- 在本地代理模式下，把 `Identity Packages` 页面挂进左侧导航
- 在详情区接入 `IdentityPackagesScreen`

这一步的意义不是“多一个页面”，而是把“身份包”从零散设置项升级成一个独立资源域。

#### 2. Providers 页面增加账户级设置与绑定入口

关键文件：

- `Quotio/Views/Screens/ProvidersScreen.swift`

已做改动：

- 给账号行增加账户设置入口
- 给支持绑定的账号增加 identity package 绑定入口
- 按账号来源区分 proxy auth file / direct auth file / auto-detected account
- 在加载账号列表时，把本地 remark、有效 `proxy_url`、已绑定 identity package 一并组装到 UI 模型里

这一步解决的是“核心已经支持 auth 元数据，但宿主用户看不到、也改不到”的问题。

#### 3. 账户设置弹窗支持上游请求标识管理

关键文件：

- `Quotio/Views/Screens/ProvidersScreen.swift`
  - `AccountSettingsSheet`

已做改动：

- 展示 remark、账户级 `proxy_url`
- 展示当前 `AccountFingerprintProfile`
- 支持生成、查看详情、保护性重新生成
- 对 Claude / Codex 展示托管上游 HTTP 头摘要
- 对 TLS 只展示边界说明，不伪装成已运行时生效
- 保存时把 profile 写回本地 metadata，并把 `proxy_url` / `headers` / `user_agent` 写回 auth

这部分是 Quotio 最关键的 UI 适配，因为它把“本地档案”和“可真正写回核心使用的 auth 字段”接起来了。

#### 4. 账号行组件增加身份包状态展示和操作入口

关键文件：

- `Quotio/Views/Components/AccountRow.swift`

已做改动：

- `AccountRowData` 增加 `identityPackage`
- `AccountRowData` 增加 `supportsIdentityBinding`
- 行内展示当前绑定包名或未绑定状态
- 增加 bind / change / unbind identity package 的按钮和菜单项

这一步让多身份能力从“只有专门页面才能看见”变成“在账号主列表里就能感知和操作”。

#### 5. 新增 identity package 管理页面

关键文件：

- `Quotio/Views/Screens/IdentityPackagesScreen.swift`

已做改动：

- 左侧列表展示所有 package
- 右侧详情支持查看与编辑：
  - 名称
  - 代理配置
  - Keychain 密码引用
  - UA profile
  - TLS profile
  - verification 状态
- 支持本地状态操作：
  - 标记 verification failed
  - 标记 blocked
  - 清除本地状态
- 支持创建、删除、保存

要点是：这里展示的不只是“代理池”，而是“账号运行身份”的完整本地资源模型。

#### 6. 新增 identity package 绑定、批量生成、导入弹窗

关键文件：

- `Quotio/Views/Components/BindIdentityPackageSheet.swift`
- `Quotio/Views/Components/GenerateIdentityPackagesSheet.swift`
- `Quotio/Views/Components/ImportIdentityPackagesSheet.swift`

已做改动：

- `BindIdentityPackageSheet`
  - 展示当前绑定
  - 只允许选择 `available` 状态 package
  - 明确提示 Phase 1 只是本地绑定，不代表核心已强制执行
- `GenerateIdentityPackagesSheet`
  - 支持批量生成本地 package 草稿
  - 自动生成默认 UA/TLS profile
- `ImportIdentityPackagesSheet`
  - 支持按代理 URL 文本或文件批量导入

这三块是迁到另一个宿主项目时最容易被漏掉的 UI，因为它们决定了用户怎么准备、批量生产和挂接多身份资源。

#### 7. ViewModel 已补齐 UI 所需状态同步

关键文件：

- `Quotio/ViewModels/QuotaViewModel.swift`

已做改动：

- 挂载 `IdentityPackageService`
- 暴露 `identityPackages`、`identityBindings`
- 暴露 package 的增删改查、导入、绑定、解绑、状态变更接口
- 增加 `updateAuthFileProxyURL`
- 增加 `updateAuthFileManagedHeaders`
- 增加 direct auth file 的对应写回逻辑
- 在刷新 auth files 后执行 `reconcileBindings`

这说明宿主层不只是“加几个 SwiftUI 页面”，而是同步补了一套面向 UI 的状态编排层。

#### 8. 运行时隔离与测试注入也属于宿主层改造

关键文件：

- `Quotio/Services/AppRuntimeProfile.swift`
- `Quotio/Services/Proxy/CLIProxyManager.swift`
- `Quotio/Services/KeychainHelper.swift`

已做改动：

- 引入 `AppRuntimeProfile`，把 bundle id、Application Support、auth 目录、默认端口、Keychain service 做命名空间隔离
- `CLIProxyManager` 支持从 `debugTestCAFile` / `QUOTIO_TEST_CA_FILE` 注入测试 CA
- `KeychainHelper` 的远程连接、本地连接、Warp、identity package proxy 密码服务名都按 runtime profile 做 namespacing

这部分的重要性在于：

- 你可以在同一台机器上同时保留正式版和测试版运行面
- 宿主项目可以安全地为 MITM 验收注入测试 CA，而不污染正式版
- identity package 的代理密码不会和另一个 bundle/runtime 混到同一个 Keychain 命名空间

#### 9. 请求日志与证据模型也做了预留

关键文件：

- `Quotio/Models/RequestLog.swift`

已做改动：

- 新增 `RequestIdentityEvidence`
- 预留 `authIndex`
- 预留 `authFileId`
- 预留 `identityPackageId`
- 预留 `exitIP`
- 预留 `uaProfileId`
- 预留 `tlsProfileId`
- 预留 `verificationTraceId`

这意味着宿主项目已经开始为“账号 -> 身份包 -> 真实请求证据”留数据结构位置，虽然当前还没有把整条证据链真正写满。

#### 10. 宿主层还补了两条最小 smoke

关键文件：

- `scripts/smoke-test-identity-packages-ui.sh`
- `scripts/smoke-test-runtime-isolation.sh`

已做改动：

- `smoke-test-identity-packages-ui.sh`
  - 覆盖身份包页导航
  - 覆盖 identity package 的保存
  - 覆盖 `verificationFailed` / `blocked` / 清除状态流转
- `smoke-test-runtime-isolation.sh`
  - 验证测试 app 读取的是测试 auth 目录
  - 验证不会误扫生产 auth 目录

它们的价值不在“自动化覆盖率”，而在于把这套宿主改造收成可重复执行的回归基线。

#### 11. 为什么这些 UI 改动在迁移时也必须复制

原因很直接：

- 核心补丁只解决“理论上可以生效”
- 宿主 UI / ViewModel 解决“用户如何配置、如何避免误操作、如何保存到 auth、如何验证是否真的生效”

如果迁移到另一个项目时只搬 `CLIProxyAPIPlus` 补丁，不搬这一层，通常会缺下面几类能力：

- 用户没有入口生成或查看账户级指纹
- 用户无法按账号修改 `proxy_url` 和托管 headers
- 用户无法在账号列表里看到绑定状态
- 用户无法批量准备 identity package
- 用户无法用同一套界面完成配置与验收闭环
- 用户无法在测试版与正式版之间做安全隔离
- 用户无法给 MITM / 测试核心注入临时 CA
- 用户无法为后续“真实请求证据链”保留日志模型

### B. CLIProxyAPIPlus 核心侧已完成

#### 1. 账号级 `headers` 已能进入运行时 auth attributes

核心里与这条链路直接相关的入口已经存在：

- `internal/watcher/synthesizer/helpers.go`
- `internal/util/header_helpers.go`
- `internal/api/handlers/management/auth_files.go`

已确认的能力是：

- auth 中保存的 `headers` 可被合成为 `auth.Attributes["header:*"]`
- 运行时可把这些 `header:*` 应用到上游请求

#### 2. Claude / Codex 已经接上账户级上游头

当前与 Claude / Codex 最相关的运行时入口：

- `internal/runtime/executor/claude_executor.go`
- `internal/runtime/executor/codex_executor.go`
- `internal/runtime/executor/codex_websockets_executor.go`

已确认：

- Claude 通过 `applyClaudeHeaders(...)` 组装上游请求头
- Codex 通过 `applyCodexHeaders(...)` 组装上游请求头
- 这些链路已经可以吃到来自 auth 的托管 headers

这就是为什么 Quotio 保存到 auth 的 Claude / Codex headers 能被 MITM 实际抓到。

#### 3. 账号级代理已经进入运行时优先级

关键入口：

- `internal/runtime/executor/proxy_helpers.go`

已确认优先级：

1. `auth.ProxyURL`
2. 全局 `cfg.ProxyURL`
3. context 内的 round tripper

因此把单账号 `proxy_url` 指向 MITM，可以抓到该账号的真实上游请求。

#### 4. 当前已有 OAuth 阶段的 uTLS，但它不是运行期多身份 TLS

相关入口：

- `internal/auth/claude/utls_transport.go`

当前已确认：

- Claude OAuth / refresh 路径已有 `uTLS HelloChrome_Auto`
- 但这条链路不能直接视为“Claude 模型请求阶段已支持每账户独立 TLS 指纹”

这点必须在所有复用项目里保持口径一致。

### C. 验证与交付链路已完成

这轮工作不是只写了配置界面，还把验收手段补齐了。

已经落地的关键验证资产包括：

- `docs/operations/isolated-dev-testing.md`
- `docs/operations/dev-to-production-promotion.md`
- `scripts/watch-claude-mitm-session.sh`
- `scripts/verify-claude-mitm-capture.sh`
- `scripts/verify-claude-mitm-capture-production.sh`
- `scripts/verify-codex-mitm-capture.sh`
- `scripts/verify-codex-mitm-capture-production.sh`

当前正确验收口径是：

- 验收目标是 provider-facing 上游请求
- 不能只看本地 CLI 入站头
- 不能只看 CLIProxyAPI 请求日志
- 要优先看 MITM 或等价的上游观测

## 当前明确还没完成的部分

### 1. identity package 还没有真正进入核心运行时绑定

当前已经有 package 模型和 UI，但还没有把下面这条链路接通：

- `auth_index / authFile -> identity package -> proxy / headers / transport profile`

这意味着：

- package 现在主要还是宿主本地资源管理模型
- 不是核心层的强制出站策略
- “未绑定 package 禁止真实出站”还没有真正实现

### 2. 每账户独立 TLS / ClientHello transport 还没实现

当前 TLS 相关状态是：

- 宿主里有 `TLSFingerprintProfile` / `AccountTLSFingerprintProfile`
- 文档里已经定义了目标和验收方式
- 但运行期还没有按账号构建独立 transport profile

还没做的核心工作包括：

- 在 `CLIProxyAPIPlus` 运行期引入账号级 transport builder
- 让 transport cache key 不再只按 `proxy_url`
- 让两个账号即使共用代理，也不会共用同一 transport / 连接池
- 做真实 TLS 指纹观测，而不只是 header 观测

### 3. 统一的 management API 还没补齐

目标架构文档里提到的这些接口目前还没有成为真实稳定能力：

- `GET /identity-packages`
- `PUT /identity-packages`
- `GET /identity-bindings`
- `PUT /identity-bindings`
- `POST /identity-bindings/verify`
- `GET /identity-verifications`

所以当前 package 与 binding 仍然主要是宿主本地状态，不是核心统一管理能力。

### 4. 通用多 provider 框架还没形成

当前真正跑通并有较强证据链的，主要还是：

- Claude
- Codex

其他 provider 的情况不一致：

- 有些只能稳定控制 `user_agent`
- 有些有内建动态指纹
- 有些目前只有本地档案，没有真正的运行时写入口

因此不能把“多身份指纹”写成一套已经统一覆盖所有 provider 的事实。

## 对另一个宿主项目，哪些能力可以直接复用

如果你要在另一个基于 CLIProxyAPI 的 Mac 宿主项目里继续做，这里建议按“宿主可复用”和“核心必须复用”两块看。

### 宿主侧可直接复用

可以直接复用的思路：

- 账户级指纹档案生成器
- Claude / Codex 托管 headers 的字段约定
- 账户设置页上的生成 / 查看 / 保护性重生交互
- `proxy_url` / `headers` 写回 auth 的逻辑
- dev/prod 隔离思路
- MITM 验收方法

对应的 Quotio 参考实现：

- `Quotio/Services/AccountMetadataStore.swift`
- `Quotio/ViewModels/QuotaViewModel.swift`
- `Quotio/Services/ManagementAPIClient.swift`
- `Quotio/Services/DirectAuthFileService.swift`
- `docs/operations/isolated-dev-testing.md`
- `docs/operations/dev-to-production-promotion.md`

### 核心侧必须复用或继续补齐

如果另一个宿主项目底层仍然是 `CLIProxyAPIPlus`，真正必须延续的核心补丁是：

- auth `headers` -> runtime `header:*`
- Claude / Codex executor 读取并应用这些托管 headers
- `auth.ProxyURL` 优先于全局代理
- MITM 验收仍然对准 provider-facing 请求

如果底层不是同一个核心，而是“另一套基于 CLIProxyAPI 思路的代理核”，那至少也要补齐同等能力：

- 账户级 auth 元数据
- 运行时可读取的托管 header 注入点
- 账号级代理选择
- 可观测的上游验收能力

否则宿主 UI 即使照抄，也只是展示层复用，不会真的生效。

## 下一阶段推荐开发顺序

如果要在另一个项目继续补“缺的部分”，推荐顺序如下。

### 第一阶段：先把已验证的 HTTP 指纹链路复制过去

目标：

- 先拿到账户级 `proxy_url`
- 再拿到账户级托管 headers
- 用 MITM 证明真实上游请求已经区分账号

这是最容易复用、风险最低、业务价值也最高的一层。

### 第二阶段：再把宿主里的 identity package 与核心绑定关系打通

目标：

- 不只是“有 package 页面”
- 而是让 package 真正驱动 auth 的运行时选择
- 明确 package 到 auth 的单向绑定规则和失败策略

### 第三阶段：最后做运行期 transport / TLS profile

这一阶段应直接落在核心里，而不是继续堆宿主页面：

- 账号级 uTLS / transport builder
- transport cache key 重构
- 多账号连接池隔离
- TLS 指纹观测工具

只有这一步完成，才可以把 UI 文案从“TLS 档案”升级为“已实际生效的 TLS 画像”。

## 关键参考提交

下面这些本地提交适合作为后续迁移和复用时的参考索引。

### 宿主项目侧

- `f3b7a09 feat: add phase 1 oauth identity package binding ui`
  - 引入 `IdentityPackageModels`、`IdentityPackageService`、绑定 UI 和独立页面
  - 代表“identity package 本地模型和页面骨架”正式落地

- `035c77d feat: checkpoint oauth account fingerprint groundwork`
  - 把账号指纹方案拆成当前架构、目标架构、实现指南和绑定计划
  - 代表“多身份指纹从想法进入明确设计边界”

- `c07a20f feat: add identity package import and keychain support`
  - 补齐导入能力与 Keychain 密码引用
  - 代表“package 不再只是静态页面，而是可导入、可持久化”

- `6e116f9 feat: isolate test app runtime profile`
  - 引入 `AppRuntimeProfile` 和测试版运行时隔离脚本
  - 代表“dev app 和正式版分离运行面”正式成形

- `52303a9 feat: add runtime identity package generation UI and enhance identity package management`
  - 补齐批量生成、页面增强与 smoke 脚本
  - 代表“identity package 管理闭环”在宿主层基本成型

### 核心链路与文档边界

- `bff19ac docs(claude): document request chain and fingerprint boundary`
  - 把 Claude 请求链路、HTTP 指纹边界、TLS 边界写清楚
  - 这是后续判断“什么已经生效、什么还没生效”的关键文档节点

- `c3344b0 docs(cliproxy): codify source-of-truth and clienthello plan`
  - 新增 `account-clienthello-transport-prd`
  - 固化 `CLIProxyAPIPlus` 子模块真源规则
  - 代表“下一阶段该去改核心 transport，而不是继续堆 UI”

- `83eee16 fix(claude): restore ready state after expired cooldown`
  - 小范围核心修复，更新 `CLIProxyAPIPlus` 子模块指针
  - 说明这批 work 不只是文档和 UI，也持续影响核心运行行为

### 收口节点

- `9902110 merge(feature): fold oauth account fingerprint work into master`
  - 把多身份指纹、identity package、测试隔离、相关文档和脚本整体收口到本地 `master`
  - 如果要整体复盘这批工作，从这个提交往前看最省时间

## 目前最值得继续看的专项文档

如果需要继续深挖，建议按下面顺序读：

1. `docs/fingerprint/account-fingerprint-architecture.md`
   - 当前这轮工作最贴近实际落地状态的架构快照
2. `docs/fingerprint/claude-request-chain.md`
   - Claude 请求链路和边界最清楚
3. `docs/fingerprint/account-clienthello-transport-prd.md`
   - 下一阶段 TLS / ClientHello 改造主文档
4. `docs/fingerprint/oauth-account-fingerprint-IMPLEMENTATION-GUIDE.md`
   - Identity Package 路线的当前实现入口与续做边界
5. `docs/submodules/cliproxy-plus-submodule.md`
   - 后续继续改核心时的真源规则

## 给后续二次开发者的最终判断

如果你要把这套能力迁到另一个项目，最务实的判断是：

- 现在已经证明“多账号不同 HTTP 指纹”是可做且可验收的
- 现在还没有证明“多账号不同运行期 TLS 指纹”已经完成
- 真正可复用的核心资产在 `CLIProxyAPIPlus` 二次开发，不在 UI 本身
- 真正需要继续补的缺口也仍然在 `CLIProxyAPIPlus` 运行时 transport，而不是宿主页面

所以，下一步的最佳策略不是重做一套新的指纹 UI，而是：

1. 先把现有宿主侧账号指纹管理能力迁过去
2. 复用当前核心补丁，把 HTTP 指纹链路先跑通
3. 以 `account-clienthello-transport-prd` 为目标，继续做 transport / TLS 阶段
