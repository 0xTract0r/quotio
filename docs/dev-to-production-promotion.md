# 开发版转正式版操作说明

最后更新：2026-03-21

## 先区分两种“转正式版”

这件事有两个完全不同的含义，不能混在一起：

1. 代码转正式版
   - 指把开发版里已经验证通过的代码，进入正式分支、正式构建和正式发布流程
2. 运行时状态转正式版
   - 指把 `Quotio Dev` 的本地 auth、配置、端口、管理密钥、测试账号状态迁移到正式版运行面

默认只做第一种。

第二种风险高，只有你明确要迁移运行时状态时才做。

## 当前已有脚本

### 开发验证

- [`scripts/run-dev-app.sh`](../scripts/run-dev-app.sh)
  - 重编译并启动测试版 `Quotio Dev.app`
- [`scripts/check-isolated-dev-runtime.sh`](../scripts/check-isolated-dev-runtime.sh)
  - 检查测试版与正式版是否隔离
- [`scripts/watch-claude-mitm-session.sh`](../scripts/watch-claude-mitm-session.sh)
  - 抓 Claude 真实上游请求并自动恢复测试环境

### 正式构建 / 发布

- [`scripts/build.sh`](../scripts/build.sh)
  - 生成正式构建产物
- [`scripts/release.sh`](../scripts/release.sh)
  - 正式 release 流程
- [`scripts/quick-release.sh`](../scripts/quick-release.sh)
  - 交互式 release helper

## 推荐流程

### 1. 先在独立 worktree 完成收口

不要在主工作区或 `master` 上直接收尾和提交。

推荐：

```bash
mkdir -p ../quotio.worktrees
git worktree add ../quotio.worktrees/feat-account-fingerprint -b feat/account-fingerprint HEAD
```

之后所有补丁整理、验证、提交都在这个 worktree 中完成。

## 2. 先跑开发版验收

至少跑完这几步：

```bash
./scripts/run-dev-app.sh
./scripts/check-isolated-dev-runtime.sh
./scripts/watch-claude-mitm-session.sh
```

验收重点：

- 测试版不影响正式版
- Claude / Codex 账户级指纹能在 UI 中操作
- Claude MITM 能抓到真实上游请求
- 验收脚本退出后测试环境能自动恢复

## 3. 判断要不要同时升级 CLIProxyAPIPlus 依赖

这次需求里，Quotio 代码和 CLIProxyAPIPlus 补丁是联动的。

发布前要明确：

- 正式版是否仍依赖现有官方 `CLIProxyAPIPlus`
- 还是要切到你维护的 patched fork / vendored patch source

当前项目内已经有一份可持续维护入口：

- 子模块：`third_party/CLIProxyAPIPlus`
- 说明文档：[`docs/cliproxy-plus-submodule.md`](./cliproxy-plus-submodule.md)
- 构建脚本：[`scripts/manage-cliproxy-plus.sh`](../scripts/manage-cliproxy-plus.sh)

如果本机 Go 版本偏旧，`manage-cliproxy-plus.sh build` 默认会走 `GOTOOLCHAIN=auto` 自动拉起上游要求的 toolchain。

如果正式发布要依赖 patched CLIProxyAPIPlus，至少要保证：

- 使用项目内 submodule 或稳定 fork，而不是 `/tmp`
- 有明确基线 commit
- 有明确构建命令
- 有回滚路径

## 4. 正式构建

如果只是本地出正式构建产物：

```bash
./scripts/build.sh
```

如果要走完整 release：

```bash
./scripts/release.sh <version>
```

或者：

```bash
./scripts/quick-release.sh
```

## 4.0 正式版 patched core 迁移窗口

这一步和“正式构建 app”是两回事。

如果你要让正式版真正使用这次账户级 Claude/Codex 指纹补丁，除了构建产物，还必须让正式运行面的 `CLIProxyAPI` 二进制切到 patched 版本，并安排一次受控 proxy restart。

原因：

- 正式版当前运行中的 core 是一个长期存活进程
- 只替换磁盘上的 `~/Library/Application Support/Quotio/CLIProxyAPI`，不会让已经运行中的老进程立刻变成新逻辑
- 当前 Quotio 对“外部杀掉 core”不会自动无缝拉起 patched 版本，因此不能把“替换二进制”和“受控 restart”混成临场手工操作

已准备好的脚本：

- [`scripts/promote-cliproxy-plus-production.sh`](../scripts/promote-cliproxy-plus-production.sh)
  - 默认 dry-run
  - 打印当前正式 core、patched core、哈希、备份路径和风险提示
  - 只有 `EXECUTE=1` 才会执行正式二进制替换
- [`scripts/rollback-cliproxy-plus-production.sh`](../scripts/rollback-cliproxy-plus-production.sh)
  - 默认 dry-run
  - 只有 `EXECUTE=1` 才会把指定备份换回正式路径

推荐窗口操作：

1. 先 dry-run，看路径和哈希
2. 确认当前没有不能中断的正式流量
3. 执行一次正式二进制替换
4. 由你在 app/UI 中安排一次受控 proxy restart
5. 立刻跑正式版 MITM 验收
6. 如有异常，执行 rollback 脚本并再次做一次受控 proxy restart

示例：

```bash
./scripts/promote-cliproxy-plus-production.sh

EXECUTE=1 ./scripts/promote-cliproxy-plus-production.sh

BACKUP_BIN="$HOME/Library/Application Support/Quotio/backups/CLIProxyAPI.<timestamp>.bak" \
./scripts/rollback-cliproxy-plus-production.sh
```

## 4.1 正式版指纹复验

如果要验证“正式版 app 发出的真实 Claude / Codex 上游请求，是否已经使用保存的账户级 headers”，不要只看 Quotio 自己的日志，直接复用 MITM 验收链路。

前提：

- 正式版 Quotio 正在运行
- 正式版监听端口正常：默认 `18317/28317`
- `build/CLIProxyAPIPlus/CLIProxyAPI` 已存在
- 如果正式 auth 目录里有多个 Claude / Codex 账号，必须显式传具体 auth 文件名

推荐正式版流程：不要使用会重启 app 的 managed-mode 观察脚本。

正式版更合理的做法是：

1. 启动一个独立 MITM 代理
2. 只把目标 Claude 账号的 `proxy_url` 临时改到这个 MITM
3. 正常发一句话
4. 读取 MITM 抓包并和该账号保存的 headers 对比

### 先启动 MITM

Claude：

```bash
mkdir -p /tmp/quotio-mitm/home

if [ ! -x /tmp/quotio-mitm/venv/bin/mitmdump ]; then
  python3 -m venv /tmp/quotio-mitm/venv
  /tmp/quotio-mitm/venv/bin/pip install mitmproxy
fi

/tmp/quotio-mitm/venv/bin/mitmdump \
  --listen-host 127.0.0.1 \
  --listen-port 19092 \
  --set confdir=/tmp/quotio-mitm/home \
  -s ./scripts/anthropic-mitm-capture.py
```

Codex：

```bash
mkdir -p /tmp/quotio-mitm/home
: > /tmp/quotio-mitm/openai-flows.jsonl

/tmp/quotio-mitm/venv/bin/mitmdump \
  --listen-host 127.0.0.1 \
  --listen-port 19092 \
  --set confdir=/tmp/quotio-mitm/home \
  -s ./scripts/openai-mitm-capture.py
```

然后把 `/tmp/quotio-mitm/home/mitmproxy-ca-cert.pem` 导入 macOS Keychain 并设为信任。

不做这一步，正式版核心会报 `x509: certificate is not trusted`。

### 只改一个正式版账号的代理

把目标账号的 `proxy_url` 临时改成：

```text
http://127.0.0.1:19092
```

只改这个账号，不要改全局代理。
同一时间尽量只让一个正式版目标账号指向这个 MITM，避免你读到别的账号的最新抓包。

### Claude：触发正式版请求，再读取抓包结果

正式版推荐流程是：

1. 让目标账号保持 `proxy_url=http://127.0.0.1:19092`
2. 正常在正式版 app / Claude Code 发一句话
3. 请求成功或失败后，再用脚本读取最新一条 MITM 抓包并和该账号保存值对比

推荐命令：

```bash
CLAUDE_AUTH_FILE=claude-hexiwotozu78@gmail.com.json \
./scripts/verify-claude-mitm-capture-production.sh
```

这个脚本会：

- 默认 `SKIP_TRIGGER=1`
- 不主动向正式版 `28317` 再发测试请求
- 读取正式版 `config.yaml`
- 从 MITM 抓包中读取最后一条真实上游请求
- 如果传了 `CLAUDE_AUTH_FILE`，会把抓到的头和该账号保存的 `headers` 做 `MATCH/MISMATCH` 对比

如果你明确要让脚本自己向正式版 core 触发一次请求，才手工关闭 `SKIP_TRIGGER`：

```bash
SKIP_TRIGGER=0 \
CLAUDE_AUTH_FILE=claude-hexiwotozu78@gmail.com.json \
./scripts/verify-claude-mitm-capture-production.sh
```

注意：

- `mitmdump` 终端默认只显示方法 / URL / 状态码，不会把请求头直接展开打印
- 真实请求头写在 `/tmp/quotio-mitm/flows.jsonl`
- HTTP/2 抓包里的头名通常会被规范成小写，例如 `user-agent`、`x-app`
- 验收脚本已经按大小写无关方式做比较，不要再靠肉眼读 `mitmdump` 终端输出判断

### 可选：旧的 managed-mode 自动观察脚本

如果你接受“它会临时重启正式版 app / core”，也可以用下面这个自动观察脚本：

```bash
CLAUDE_AUTH_FILE=claude-fatovokiroq397@gmail.com.json \
./scripts/watch-claude-mitm-production.sh
```

验收口径：

- 必须抓到真实上游 `POST https://api.anthropic.com/v1/messages?beta=true`
- `User-Agent`、`X-App`、`X-Stainless-*` 要与对应 auth 文件中的保存值 `MATCH`
- 响应必须是 `200`
- `Content-Type` 必须是 `text/event-stream; charset=utf-8`
- SSE 前缀里应该看到 `message_start` / `content_block_delta` / `message_stop`

脚本结束后会自动把正式版账号 `proxy_url`、`debugTestCAFile`、以及 `18317/28317` 的运行状态恢复到启动前基线。

### Codex：触发正式版请求，再读取抓包结果

Codex 当前正式链路已确认可能命中：

- `https://chatgpt.com/backend-api/codex/responses`
- 或兼容场景下的 `https://api.openai.com/v1/responses`

因此 Codex 推荐始终使用项目内的专用 capture 脚本，而不是复用 Claude 那套 flow 文件。

推荐命令：

```bash
CODEX_AUTH_FILE=codex-fatovokiroq397@gmail.com-plus.json \
./scripts/verify-codex-mitm-capture-production.sh
```

这个脚本会：

- 默认 `SKIP_TRIGGER=1`
- 不主动向正式版 `28317` 再发测试请求
- 读取 `/tmp/quotio-mitm/openai-flows.jsonl`
- 输出 `Flow timestamp`、`Request body prefix`
- 对比该账号保存的 `User-Agent` / `Version` 是否 `MATCH`

Codex 验收口径：

- `User-Agent` 为 `MATCH`
- `Version` 为 `MATCH`
- `Status` 为 `200`

补充：

- `openai-mitm-capture.py` 会直接在 `mitmdump` 终端打印时间戳、URL、`user-agent`、`version` 和请求前缀
- 如果终端没有出现 `== Captured OpenAI/Codex Request ==`，说明这次请求没有命中当前脚本捕获的真实上游路由，而不是“脚本没打印”

## 5. 正式发布前检查

至少确认这些点：

- 改动已经在非 `master` 分支提交
- 测试版验收通过
- 文档已更新
- 没把测试态路径、测试端口、测试账号或 MITM 默认值带进正式版
- 如果 release 依赖 patched CLIProxyAPIPlus，来源与版本已经可追踪

## 运行时状态是否要从开发版迁到正式版

默认不建议。

原因：

- `Quotio Dev` 与正式版的 bundle id、Application Support、auth 目录、Keychain、端口都是隔离的
- 直接复制运行时状态，容易把测试账号、测试代理或测试 key 带进正式环境

如果只是要让代码“转正式”，不需要迁移 dev 运行态。

## 如果你确实要迁移运行时状态

请至少先满足：

- 已备份正式版运行目录
- 已确认 dev 目录中没有测试专用 `proxy_url`
- 已确认没有残留 `debugTestCAFile`
- 已确认不会覆盖正式版正在使用的密钥或账号顺序

这一步当前没有一键脚本，应该按明确 checklist 手工执行，而不是隐式复用开发版目录。

## 当前建议

对这次需求，推荐的正式化路径是：

1. 在独立 worktree / 分支中整理并提交代码
2. 保留开发版 runtime 与正式版 runtime 隔离
3. 使用项目内 `third_party/CLIProxyAPIPlus` 子模块管理 CLIProxyAPIPlus 补丁
4. 再决定是否发布到正式版
