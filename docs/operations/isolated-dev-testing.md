# Quotio 隔离开发测试方案

最后更新：2026-03-21

## 目标

在本机已经有一个常驻正式版 Quotio 为 AI 提供 API 能力的前提下，开发新功能时运行一个测试版 Quotio，且满足：

- 不占用正式版正在使用的端口
- 不复用正式版的 UserDefaults、Application Support、auth 目录和 Keychain
- 不把测试中的代理状态、账号状态和管理密钥写回正式版运行面
- 测试结束后可以明确回滚和清理

## 已确认的隔离规则

项目当前已经有一层运行时隔离，关键入口在：

- [`Quotio/Models/Models.swift`](../../Quotio/Models/Models.swift)
- [`Quotio/Services/KeychainHelper.swift`](../../Quotio/Services/KeychainHelper.swift)
- [`Quotio/Services/Proxy/CLIProxyManager.swift`](../../Quotio/Services/Proxy/CLIProxyManager.swift)
- [`Quotio/QuotioApp.swift`](../../Quotio/QuotioApp.swift)

只要测试版使用不同于 `dev.quotio.desktop` 的 bundle id，运行时会自动切到独立命名空间：

- `UserDefaults`：按 bundle id 分域
- `Application Support`：正式版是 `~/Library/Application Support/Quotio`，测试版会变成 `~/Library/Application Support/Quotio-<suffix>`
- `auth` 目录：正式版是 `~/.cli-proxy-api`，测试版会变成 `~/.cli-proxy-api-<suffix>`
- `Keychain`：服务名前缀是 bundle id，测试版不会复用正式版的本地管理密钥
- 默认代理端口：正式版 `18317`，非正式 bundle id 默认 `18017`
- 默认内部 CLIProxyAPI 端口：由桥接规则自动推导，测试版 `18017 -> 28017`

例如 `PRODUCT_BUNDLE_IDENTIFIER = dev.quotio.desktop.dev` 时：

- UserDefaults domain：`dev.quotio.desktop.dev`
- Application Support：`~/Library/Application Support/Quotio-dev`
- auth 目录：`~/.cli-proxy-api-dev`
- Keychain 服务：`dev.quotio.desktop.dev.local-management`
- 用户入口端口：`18017`
- 内部 CLIProxyAPI 端口：`28017`

## 仍然共享的面

下面这些不是按 Quotio bundle id 自动隔离的，开发时必须额外约束：

- CLI agent 配置文件仍是用户全局路径
  - Claude：`~/.claude/settings.json`
  - Codex：`~/.codex/config.toml`、`~/.codex/auth.json`
  - 代码位置见 [`Quotio/Models/AgentModels.swift`](../../Quotio/Models/AgentModels.swift) 和 [`Quotio/Services/AgentConfigurationService.swift`](../../Quotio/Services/AgentConfigurationService.swift)
- Cursor / Trae 等 IDE 扫描路径是外部应用全局目录，但当前主要是读，不是由 Quotio 命名空间隔离

这意味着：

- 测试版 Quotio 可以安全拥有自己的本地代理、auth、配置和管理密钥
- 但如果你在测试版里点击 “Agent Setup -> Automatic”，它仍然可能改动你真实在用的 `~/.claude` 或 `~/.codex`

## 推荐工作流

### 1. 代码隔离：每个功能一个独立 worktree

不要在正式版常驻实例所在的源码目录里直接开发新功能。推荐：

```bash
mkdir -p ../quotio.worktrees
git worktree add ../quotio.worktrees/feat-<short-name> -b feat/<short-name> HEAD
```

这样做的目的：

- 测试版编译产物、Xcode 索引和临时改动不污染当前主工作区
- 正式版常驻实例仍可继续从原目录提供 API
- 一个功能一个分支，便于回滚和验收

### 2. 运行时隔离：给测试版单独的 Local.xcconfig

在测试 worktree 中创建：

```bash
cp Config/Local.xcconfig.example Config/Local.xcconfig
```

至少保留下面这些值：

```xcconfig
PRODUCT_BUNDLE_IDENTIFIER = dev.quotio.desktop.dev
PRODUCT_NAME = Quotio Dev
INFOPLIST_KEY_CFBundleDisplayName = Quotio Dev
ASSETCATALOG_COMPILER_APPICON_NAME = AppIconDev
```

要求只有一条：

- `PRODUCT_BUNDLE_IDENTIFIER` 不能等于 `dev.quotio.desktop`

如果正式版当前已经把 `proxyPort` 改成了 `18317`，测试版默认端口会撞车。先运行：

```bash
./scripts/pick-isolated-dev-port.sh
```

再按输出执行：

```bash
defaults write dev.quotio.desktop.dev proxyPort -int <recommended-port>
```

### 3. Xcode 使用用户私有 Scheme

复制 `Quotio` scheme，命名为 `Quotio Dev`，并取消 `Shared`。

目的：

- 测试版调试配置只在本机生效
- 不把开发者自己的调试 Scheme 提交进仓库

如果你只是想在终端里快速重编译并启动测试版，不想手动找 `.app` 路径，可以直接运行：

```bash
./scripts/run-dev-app.sh
```

这个脚本会：

- 固定把测试版构建到 `build/DerivedData-dev`
- 自动定位 `Quotio Dev.app`
- 只重启测试版，不会去杀正式版 `Quotio`

### 4. 首次启动后先验证 4 个隔离点

启动测试版后，先不要做业务测试，先确认它没有碰正式版：

```bash
./scripts/check-isolated-dev-runtime.sh
```

预期结果：

- 正式版继续监听 `18317`
- 测试版监听 `18017`
- 测试版内部 CLIProxyAPI 监听 `28017`
- 正式版仍使用 `~/Library/Application Support/Quotio` 和 `~/.cli-proxy-api`
- 测试版使用 `~/Library/Application Support/Quotio-dev` 和 `~/.cli-proxy-api-dev`

如果正式版已经把 `proxyPort` 改成了别的值，脚本会按当前 `defaults` 中的实际端口来报冲突，而不是死看默认值。

如果你只想预演某个 bundle id 会落到哪里，可以运行：

```bash
./scripts/inspect-runtime-profile.sh dev.quotio.desktop.dev
```

### 5. 日常功能开发测试按 3 个层级做

#### 层级 A：只测 Quotio UI / ViewModel / Management API

适用场景：

- 页面交互
- auth 文件读写
- 管理 API 调用
- 本地代理配置变更

做法：

- 只启动测试版 Quotio
- 不动真实 `~/.claude`、`~/.codex`
- 通过测试版自己的 `18317` / `28317` 做验证

这是默认测试方式，风险最低。

#### 层级 B：测 CLIProxyAPIPlus 上游真实链路

适用场景：

- 验证请求头
- 验证账号路由
- 验证上游 provider 实际行为

做法：

- 在测试版自己的 auth 目录中导入测试账号
- 用 `curl` 或专门的验证脚本直接打 `http://127.0.0.1:18317`
- 检查测试版日志目录，而不是正式版日志目录

优先用这种方式验证请求链路，不要先上真实 CLI。

如果你要证明“不是 CLIProxyAPI 自己在日志里声称带上了指纹，而是上游真的收到了”，要再做一层独立的 MITM 验证：

1. 启动 `mitmdump`

```bash
python3 -m venv /tmp/quotio-mitm/venv
/tmp/quotio-mitm/venv/bin/pip install mitmproxy
mkdir -p /tmp/quotio-mitm/home
: > /tmp/quotio-mitm/flows.jsonl
/tmp/quotio-mitm/venv/bin/mitmdump \
  --listen-host 127.0.0.1 \
  --listen-port 19091 \
  --set confdir=/tmp/quotio-mitm/home \
  -s "$(pwd)/scripts/anthropic-mitm-capture.py"
```

2. 把测试版 Claude auth 的 `proxy_url` 临时改到本机 MITM

- 测试文件：`~/.cli-proxy-api-dev/<claude-auth>.json`
- 示例：`"proxy_url": "http://127.0.0.1:19091"`
- 结束后记得恢复原值

3. 用项目内补丁版 CLIProxyAPIPlus 启动测试核心

说明：
- 当前为了让 Go 进程信任 mitmproxy 自签 CA，需要一个测试专用补丁版 CLIProxyAPIPlus，在 `sdk/proxyutil/proxy.go` 中支持 `QUOTIO_TEST_CA_FILE`
- 现在默认使用项目内子模块 `third_party/CLIProxyAPIPlus`
- 这是测试验收链路，不属于 Quotio 正式运行依赖

如果还没准备好补丁版 binary，先执行：

```bash
./scripts/manage-cliproxy-plus.sh build
```

启动命令：

```bash
QUOTIO_TEST_CA_FILE=/tmp/quotio-mitm/home/mitmproxy-ca-cert.pem \
./build/CLIProxyAPIPlus/CLIProxyAPI \
  -config "$HOME/Library/Application Support/Quotio-dev/config.yaml"
```

4. 对测试核心直接发起一条最小 Claude 请求，并读取 MITM 证据

```bash
./scripts/verify-claude-mitm-capture.sh
```

默认会：

- 直打 `127.0.0.1:28417/v1/messages?beta=true`
- 读取 `~/Library/Application Support/Quotio-dev/config.yaml` 里的测试 token
- 从 `/tmp/quotio-mitm/flows.jsonl` 取最后一条抓包
- 打印上游真实 `User-Agent`、`X-App`、`X-Stainless-*` 以及响应 `Content-Type`

本次实际验收通过时，MITM 已抓到：

- 上游 URL：`https://api.anthropic.com/v1/messages?beta=true`
- 请求头：`User-Agent: claude-cli/2.1.63 (external, sdk-cli)`、`X-App: cli`、`X-Stainless-Package-Version: 0.74.0`、`X-Stainless-Runtime-Version: v22.20.0`、`X-Stainless-Timeout: 600`
- 响应头：`Content-Type: text/event-stream; charset=utf-8`
- 响应体前缀：真实 SSE 事件，包含 `event: message_start`、`event: content_block_delta` 和文本 `ping`

这条链路的意义是：

- `request-log` 只能证明核心“自报”自己发了什么
- MITM 抓到的 `POST /v1/messages` 和 SSE 响应，才是独立外部证据
- 对 Claude 来说，真正可区分账号请求的关键是上游 HTTP 指纹，而不是本地 CLI 入站 UA

如果你不想手动做上面 1 到 4 步，而是想要“正常启动 devapp -> 启动一个脚本 -> 去 Claude Code 发一句话 -> 脚本自动打印真实抓包结果”，可以直接用：

```bash
./scripts/watch-claude-mitm-session.sh
```

这个脚本会自动完成：

- 启动本机 MITM
- 如果 `19091` 已经有现成 `mitmdump`，则直接复用，不会盲杀
- 把测试 Claude auth 的 `proxy_url` 临时切到 `127.0.0.1:19091`
- 默认走 managed mode：临时替换 devapp 当前使用的测试核心二进制，并重启 devapp 自己托管的核心，让 `18417 -> 28417` 桥接继续存在
- 等你在另一个终端正常用 Claude Code 发一句话
- 一旦抓到第一条真实上游请求，就打印：
  - 真实上游 URL
  - `User-Agent` / `X-App` / `X-Stainless-*`
  - 这些值与 Claude auth 文件中保存值是否一致
  - 上游 SSE 响应头和响应前缀
- 结束后自动恢复原 `proxy_url`，并恢复原测试核心

适用前提：

- `Quotio Dev.app` 已正常启动
- 测试 auth 目录里至少有一个启用中的 Claude 账号
- 本机已有项目内补丁版 `CLIProxyAPIPlus` 二进制：`build/CLIProxyAPIPlus/CLIProxyAPI`

调试补充：

- 默认要求 devapp 客户端端口当前正在监听；如果没启动，它会直接报错，不会假装继续
- 脚本运行时会短暂重启 devapp，使它改为托管补丁版核心；抓包结束后再恢复正常测试核心
- 如果抓包成功但你怀疑恢复不完整，优先看 `/tmp/watch-claude-mitm-cleanup.log`；这里会记录 `proxy_url` 恢复、`autoStartProxy` 恢复、devapp/core 重启和最终 `18417/28417` 监听结果
- managed mode 会临时写入 dev bundle 的 `debugTestCAFile` defaults key，把 MITM CA 路径显式传给 Quotio 启动的 CLIProxyAPI；脚本退出时会恢复或删除这个键
- 只有在你明确传 `ALLOW_DIRECT_CORE_DEBUG=1` 时，才会跳过 devapp，直接针对 `28417` 做底层调试；脚本运行期间 `18417` 可能短暂不可用，但如果启动脚本前 `Quotio Dev` 已在监听，cleanup 会按基线把 `18417/28417` 一并恢复
- 如果你不是用真实 Claude Code，而是手工 `curl` devapp bridge 端口做本地复现，优先使用 `http://localhost:18417`，不要硬写 `http://127.0.0.1:18417`；当前 macOS 下 `ProxyBridge` 可能只在 IPv6 `localhost/::1` 侧稳定可达

#### 层级 C：测真实 Claude / Codex CLI

这是风险最高的一层，默认不要直接让测试版改你的全局 CLI 配置。

推荐做法有两种，优先第一种：

1. 临时 shell 覆盖
   - 在单独终端里临时设置 base URL / token，只让这一条测试命令指向测试版 Quotio
   - 不改全局 shell profile，不改正式版正在依赖的环境
2. 一次性测试 HOME
   - 用临时 `HOME` 目录运行 Claude / Codex
   - 让 `~/.claude`、`~/.codex` 写到临时目录，不碰真实用户目录

不推荐的做法：

- 在测试版 app 中直接执行会改写 `~/.claude`、`~/.codex` 的自动配置，然后忘记恢复

如果必须验证“Agent Setup 自动配置”功能，至少先确认：

- 该功能只在专门测试窗口执行
- 测试前已有备份
- 测试结束后要恢复原始配置

## 推荐日常操作顺序

每次开发新功能时，按下面顺序：

1. 新建功能 worktree
2. 在该 worktree 中使用 `Local.xcconfig` 的测试 bundle id
3. 启动测试版 Quotio
   - 可以直接运行 `./scripts/run-dev-app.sh`
4. 先做隔离检查：端口、目录、Keychain、日志路径
5. 优先做层级 A / B 测试
6. 只有在必须验证 CLI 集成时，才做层级 C
7. 测试结束后退出测试版，不动正式版

## 最小验收清单

一次功能测试开始前，至少确认：

- 正式版 Quotio 仍在原端口提供服务
- 测试版是不同 bundle id
- 测试版使用自己的 auth 目录
- 测试版日志写到自己的 Application Support
- 本次测试不会改全局 `~/.claude` / `~/.codex`，或者已经准备好恢复方案

## 清理方式

功能测试结束后：

```bash
rm -rf ~/Library/Application\\ Support/Quotio-dev
rm -rf ~/.cli-proxy-api-dev
```

仅在确认不再需要测试版状态时再删。

若只是结束当天开发，通常只需要：

- 退出测试版 app
- 保留测试目录，方便下次继续
- 继续让正式版常驻提供 API

## 当前结论

当前项目已经具备“测试版 Quotio 与正式版 Quotio 同机并存”的基础能力，前提是：

- 测试版必须使用不同 bundle id
- 测试必须优先走独立 worktree
- 不要让测试版自动改写你真实在用的 CLI agent 全局配置

如果后续要进一步降低误操作风险，下一步建议是补一个“开发测试模式”开关，直接在 UI 上禁用 Agent Setup 的自动写全局配置能力。

## 相关文档

- [`account-fingerprint-architecture.md`](../fingerprint/account-fingerprint-architecture.md)
- [`dev-to-production-promotion.md`](./dev-to-production-promotion.md)
