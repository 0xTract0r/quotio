# 开发版转正式版操作说明

最后更新：2026-03-20

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

- [run-dev-app.sh](/Users/corylin/Project/ai/quotio/scripts/run-dev-app.sh)
  - 重编译并启动测试版 `Quotio Dev.app`
- [check-isolated-dev-runtime.sh](/Users/corylin/Project/ai/quotio/scripts/check-isolated-dev-runtime.sh)
  - 检查测试版与正式版是否隔离
- [watch-claude-mitm-session.sh](/Users/corylin/Project/ai/quotio/scripts/watch-claude-mitm-session.sh)
  - 抓 Claude 真实上游请求并自动恢复测试环境

### 正式构建 / 发布

- [build.sh](/Users/corylin/Project/ai/quotio/scripts/build.sh)
  - 生成正式构建产物
- [release.sh](/Users/corylin/Project/ai/quotio/scripts/release.sh)
  - 正式 release 流程
- [quick-release.sh](/Users/corylin/Project/ai/quotio/scripts/quick-release.sh)
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

- [third_party/CLIProxyAPIPlus/README.md](/Users/corylin/Project/ai/quotio.worktrees/feat-account-fingerprint/third_party/CLIProxyAPIPlus/README.md)
- [manage-cliproxy-plus.sh](/Users/corylin/Project/ai/quotio.worktrees/feat-account-fingerprint/scripts/manage-cliproxy-plus.sh)

如果本机 Go 版本偏旧，`manage-cliproxy-plus.sh build` 默认会走 `GOTOOLCHAIN=auto` 自动拉起上游要求的 toolchain。

如果正式发布要依赖 patched CLIProxyAPIPlus，至少要保证：

- 使用项目内 patch source 或稳定 fork，而不是 `/tmp`
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
3. 使用项目内 `third_party/CLIProxyAPIPlus` 或稳定 fork 管理 CLIProxyAPIPlus 补丁
4. 再决定是否发布到正式版
