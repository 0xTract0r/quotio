# OAuth 账号强绑定运行身份包 TODO

最后更新：2026-03-17

## 当前阶段定位

- 当前只完成 Quotio 仓库第一阶段基础设施的一部分。
- 当前未完成真实运行时强绑定。
- 当前不能声称 TLS 指纹已经真正生效。

## 本轮已完成

### 已接入主状态

- [x] 将 `IdentityPackageService` 接入 `QuotaViewModel`
- [x] 在 `QuotaViewModel` 暴露本地身份包列表与绑定映射
- [x] 在 `refreshData()` 后对 `AuthFile` 绑定做本地校验与清理

### 已完成 Providers UI

- [x] 在 `ProvidersScreen` 按 `AuthFile` 展示身份包绑定状态
- [x] 为账号增加绑定入口
- [x] 为账号增加解绑入口
- [x] 新增 `BindIdentityPackageSheet` 作为绑定/换绑 UI

### 已完成身份包管理 UI

- [x] 在身份包页展示绑定状态与绑定账号
- [x] 支持新建身份包
- [x] 支持编辑身份包名称与本地代理字段
- [x] 支持批量导入代理 URL 生成身份包
- [x] 支持删除未绑定身份包
- [x] 为 `proxy.username` / `proxy.passwordRef` 保留模型字段与编辑入口
- [x] 代理密码写入 `Keychain`，模型只保存 `passwordRef`
- [x] 明确标注 TLS 仍为第一阶段预留，不伪装成已接入真实运行时

### 已完成基础约束

- [x] 绑定粒度保持在单个 `AuthFile`
- [x] 一个身份包同一时间只能绑定一个账号
- [x] 一个账号同一时间只能绑定一个身份包
- [x] 已绑定身份包不可直接删除，必须先解绑账号
- [x] 未在 `ProxyBridge` 中通过猜测请求内容决定绑定关系
- [x] 未大改 `AgentConfigurationService`

### 已完成接口预留

- [x] 为 `RequestLog` 预留账号绑定证据字段结构
- [x] 当前仅预留字段，不伪装成已有真实运行时证据

### 已完成验证

- [x] 运行一次 `xcodebuild -project Quotio.xcodeproj -scheme Quotio -configuration Debug build`
- [x] 结果为 `BUILD SUCCEEDED`
- [x] 运行一次 `xcodebuild -list -project Quotio.xcodeproj`
- [x] 结果确认当前只有 `Quotio` 一个 target / scheme，仓库仍没有 `Tests` / `UITests` 目录

## 本轮已验证事实

- [x] 2026-03-17 已把 auth/path 默认读取统一收口到 `AppRuntimeProfile`
  - 已确认改到 runtime profile 的代码点包括：
    - `DirectAuthFileService`
    - `ClaudeCodeQuotaFetcher`
    - `OpenAIQuotaFetcher.fetchAllCodexQuotas`
    - `CopilotQuotaFetcher` 的多处默认 `authDir`
    - `AntigravityQuotaFetcher` 的多处默认 `authDir`
    - `AntigravityAccountSwitcher.executeSwitchForEmail`
    - `AppConfig.authDir`
  - 代码搜索结果显示，Quotio 代码中的 `~/.cli-proxy-api` 默认值已只剩 `AppRuntimeProfile` 这一处中心定义
- [x] 2026-03-17 已新增可重复执行的本地 smoke：`scripts/smoke-test-runtime-isolation.sh`
  - 真实链路：构建 `Quotio Test.app` -> 写入测试专用 auth fixture -> 启动 app -> 抓启动日志 -> 断言 direct auth 扫描路径
  - 实际结果：脚本通过，日志显示 `Quotio Test.app` 扫描的是 `~/.cli-proxy-api-test`
  - 实际结果：本次 smoke 未观察到 `Quotio Test.app` 扫描正式 `~/.cli-proxy-api`
- [x] 2026-03-17 已再次运行 `xcodebuild -project Quotio.xcodeproj -scheme Quotio -configuration Debug build`
  - 结果：`BUILD SUCCEEDED`

## 当前未解决风险

- [ ] 当前没有自动化测试 target
  - 已验证事实：`xcodebuild -list -project Quotio.xcodeproj` 仍只有 `Quotio` 一个 target / scheme
  - 已验证事实：仓库仍没有 `Tests` / `UITests` 目录
  - 结论：当前自动化能力仍不等于 XCTest / XCUITest 回归
- [ ] 当前新增的自动化只覆盖 runtime isolation smoke，不覆盖完整原生 UI 回归
  - 已验证事实：`scripts/smoke-test-runtime-isolation.sh` 能证明测试版 direct auth 扫描路径已经切到测试 runtime profile
  - 已验证事实：`scripts/smoke-test-identity-packages-ui.sh` 已覆盖身份包页导航、保存、`blocked`/清除状态流转
  - 未验证风险：菜单栏窗口、绑定 sheet、切换账号等 UI 路径仍未做自动化验收
- [ ] 当前 smoke 主要覆盖启动期 direct auth 扫描链路，还不是对全部共享状态面的穷尽证明
  - 已做代码审查的隔离面：Bundle ID、`UserDefaults` domain、`Application Support`、Keychain service、默认本地端口、auth dir 默认值
  - 2026-03-17 补充修正：`AntigravityDeviceManager` 的本地设备档案目录已改到 `AppRuntimeProfile.appSupportDirectoryURL/antigravity-profiles`
  - 仍建议继续回归的面：运行中的 proxy / management API 回填状态、长时间使用后的跨 profile 状态污染、非 direct auth 场景下的后续回归

### 第一阶段内仍可继续做

- [x] 身份包状态细化与完整 UI
  - [x] `draft`
  - [x] `available`
  - [x] `bound`
  - [x] `verificationFailed`
  - [x] `blocked`
- [x] 身份包页更完整的管理交互
  - [x] 编辑
  - [x] 删除
  - [x] 批量生成

## 当前可开始测试

- [x] 本地创建身份包
- [x] 批量生成草稿身份包（自动生成 UA / TLS 配置）
- [x] 批量导入代理 URL 生成身份包
- [x] 在身份包页编辑本地代理字段
- [x] 代理密码写入 `Keychain`，并在 UI 中显示 `passwordRef`
- [x] 在 `Providers` 页为账号绑定 / 换绑 / 解绑身份包
- [x] 在账号列表查看当前绑定状态
- [x] 已绑定身份包不会被直接删除
- [x] 在身份包页把包标记为 `verificationFailed` / `blocked`，并可清除本地状态恢复正常可绑定状态
- [x] `xcodebuild -project Quotio.xcodeproj -scheme Quotio -configuration Debug build` 已通过，可开始手工测试第一阶段 UI 与本地状态流转

## 当前测试限制

- [x] `Quotio Test.app` 现已可用于 auth 目录隔离 smoke，但当前自动化结论只覆盖这条链路
- [ ] 在补齐更完整自动化前，不应把“已勾选 TODO”表述为“整个第一阶段已经测试没问题”
- [ ] 在原生 macOS UI 自动化能力落地前，不能声称已经完成完整 UI 层回归
- [x] `verificationFailed` / `blocked` 当前是 Quotio 本地运维状态，不代表已经完成真实运行时验证

### 未来阶段但本轮未做

- [ ] 在日志或详情页展示验证结果
- [ ] 验证动作 UI 与服务层接口
- [ ] 为原生 macOS UI 建立最小自动化验收链
  - [ ] 方案 A：补 `XCTest` / `XCUITest` target
  - [x] 方案 B（runtime isolation 基线）：已补 `scripts/smoke-test-runtime-isolation.sh`
  - [x] 方案 B（UI 路径）：已补 `scripts/smoke-test-identity-packages-ui.sh`，覆盖身份包页最小 smoke
  - [ ] 明确菜单栏窗口、身份包页、绑定 sheet 的最小验收路径

## 明确未完成且依赖 CLIProxyAPIPlus 上游

- [ ] 在真实请求链路解析实际 `auth_index`
- [ ] 按账号绑定关系在运行时选择 identity package
- [ ] 按 identity package 切换真实出站代理
- [ ] 按 identity package 注入真实 UA
- [ ] 按 identity package 切换真实 TLS profile
- [ ] 未绑定账号时拒绝真实出站
- [ ] 输出请求级证据字段
  - [ ] `auth_index`
  - [ ] `auth_file_id`
  - [ ] `identity_package_id`
  - [ ] `exit_ip`
  - [ ] `ua_profile_id`
  - [ ] `tls_profile_id`
  - [ ] `verification_trace_id`

## 当前真实状态说明

- 当前 GUI 已能维护“账号 -> 身份包”的本地绑定关系。
- 当前 GUI 已能维护和编辑身份包本地内容，并把代理密码存入 `Keychain`；模型层只保留 `passwordRef`。
- 当前绑定关系仅在 Quotio 本地模型和 UI 中成立。
- 当前还没有接通真实运行时执行层，因此不能视为“强绑定已生效”。
- 当前 TLS 指纹仍然只是数据模型与 UI 预留，不是已经落地的运行时能力。
