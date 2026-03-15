# OAuth 账号强绑定运行身份包 TODO

最后更新：2026-03-16

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

## 当前未完成

### 第一阶段内仍可继续做

- [ ] 身份包状态细化与完整 UI
  - [ ] `draft`
  - [x] `available`
  - [x] `bound`
  - [ ] `verificationFailed`
  - [ ] `blocked`
- [ ] 身份包页更完整的管理交互
  - [x] 编辑
  - [x] 删除
  - [ ] 批量生成

## 当前可开始测试

- [x] 本地创建身份包
- [x] 批量导入代理 URL 生成身份包
- [x] 在身份包页编辑本地代理字段
- [x] 代理密码写入 `Keychain`，并在 UI 中显示 `passwordRef`
- [x] 在 `Providers` 页为账号绑定 / 换绑 / 解绑身份包
- [x] 在账号列表查看当前绑定状态
- [x] 已绑定身份包不会被直接删除
- [x] `xcodebuild -project Quotio.xcodeproj -scheme Quotio -configuration Debug build` 已通过，可开始手工测试第一阶段 UI 与本地状态流转

### 未来阶段但本轮未做

- [ ] 在日志或详情页展示验证结果
- [ ] 验证动作 UI 与服务层接口

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
