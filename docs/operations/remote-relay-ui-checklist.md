# Remote Relay UI 验收清单

最后更新：2026-04-23

适用场景：

- 本地运行 `Quotio Dev`
- 模式切到 `remote-relay`
- 远端 core 基线为 `https://10.1.1.201:18317`

这份清单只覆盖当前已实现语义：

- 本机保留 `127.0.0.1:<port>` 客户端入口
- 账号、API Keys、Logs、usage、远端配置真源都来自远端 core
- 远端模式不再暴露本地专属 `Identity Packages`

## 预备条件

1. 启动本地 `Quotio Dev`，并确保它以 `remote-relay` 连接远端 core。
2. 确认本机 relay 监听在 `127.0.0.1:18017` 或你当前配置的 dev 端口。
3. 准备好远端 management 页面登录信息。

## Quotio Dev 页面检查

1. 打开 `Dashboard`。
   期望看到 `Remote Relay Mode`。
   期望看到本地客户端入口，例如 `http://127.0.0.1:18017/v1`。
   期望看到远端目标，例如 `Remote target: https://10.1.1.201:18317`。
   期望顶部状态是“已连接”或“运行中”。

2. 查看左侧导航。
   期望保留 `Providers`、`API Keys`、`Logs`、`Agents`、`Settings`。
   期望不要再看到 `Identity Packages`。

3. 打开 `Providers`。
   期望账户数与远端 management 返回一致。
   期望 Claude / Codex 等账户的启用/停用状态与远端一致。
   期望账户备注、邮箱、provider 类型都来自远端，不是本地 dev auth 目录的独立数据。

4. 打开 `API Keys`。
   期望数量与远端一致。
   期望显示的是远端 key 列表，不是本地新生成的一套独立 key。

5. 打开 `Logs`。
   期望能看到远端 management / core 的日志内容。
   期望日志里出现你当前联调产生的 `/v0/management/auth-files`、`/usage`、`/api-keys` 访问记录。
   已知当前远端运行面里 `/healthz` 和 `/debug` 是 `404`，看到对应 warn 不代表部署失败。

6. 打开 `Settings`。
   期望 `Remote Relay` 处于选中状态。
   期望远端服务器区域显示 `Remote Core 10.1.1.201` 或等价远端 endpoint。
   期望 `Local Relay` 区域显示本地端口、运行状态、本地 endpoint 和远端 target。

7. 打开 `Agents`。
   期望本地 CLI agents 页面仍可见。
   期望这里只检查显示，不要在验收阶段点击 `Automatic` 或重写本机真实 CLI 配置。

## 远端 Management 页面检查

1. 打开 `https://10.1.1.201:18317/management.html`。
   期望页面能正常打开并登录。

2. 查看 `Auth Files` 或等价账号页。
   期望账户数量、启用状态、备注与 Quotio `Providers` 一致。

3. 查看 `Usage` 页面。
   期望总请求数、总 token 与 Quotio Dashboard 一致。

4. 查看 `Logs` 页面。
   期望能看到来自本机 relay 触发的 management 请求。

5. 查看 `API Keys` 页面。
   期望 key 列表与 Quotio `API Keys` 页面一致。

## 同步 smoke

建议只使用已有测试账号做可回滚操作，不直接动主力账号。

1. 在远端 management 页面选一条测试账号，先记录当前状态。
2. 把该账号从“停用”改成“启用”，或从“启用”改成“停用”。
3. 回到本地 `Quotio Dev -> Providers`，点击刷新。
   期望该账号状态立即同步变化。
4. 把远端改动恢复原值。
5. 再次刷新 `Quotio Dev -> Providers`。
   期望本地 UI 跟着恢复。

如果要测“新增 / 编辑”：

1. 在远端 management 页面新增测试账号，或只改测试账号备注。
2. 回到本地 `Quotio Dev` 刷新 `Providers`。
   期望新账号出现，或备注同步变化。
3. 验证完成后删除测试账号或恢复原备注。

## 当前已知预期与边界

- `remote-relay` 当前不暴露 `Identity Packages`，这是预期，不是缺页。
- 当前远端运行面 `/healthz` 与 `/debug` 返回 `404`，不要把它当成这轮验收失败的唯一判据。
- 如果日志里出现某些 Codex 账号的 `refresh_token_reused` 或 `invalid_grant`，优先按多运行面并行 refresh 的账号问题排查，不先判定成 relay 或部署回归。
- 本地验收默认不要点击会改写真实 `~/.claude`、`~/.codex` 的自动配置按钮。
