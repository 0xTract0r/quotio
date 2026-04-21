# CLIProxyAPIPlus 子模块维护说明

最后更新：2026-04-21

## 当前方案

Quotio 现在通过 Git submodule 引用维护中的 `CLIProxyAPIPlus`：

- 子模块路径：`third_party/CLIProxyAPIPlus`
- 子模块远端：`git@github.com:0xTract0r/CLIProxyAPIPlus.git`
- 官方上游：`git@github.com:router-for-me/CLIProxyAPIPlus.git`
- 当前对齐基线：`0xTract0r/CLIProxyAPIPlus` 的 `main`，按需重放最小上游修复

当前收敛后的策略不是每次模型编号变化都全量合并官方 `upstream/main`，而是：

- 默认保持 Quotio 子模块 fork 主线可直接抓取父仓库记录的 gitlink
- 对模型注册这类小缺口，优先把最小补丁重放到 fork `main`
- 全量同步官方 `upstream/main` 必须作为单独任务审计冲突、运行时风险和本地定制补丁

截至 Claude Opus 4.7 热修，本次没有把官方 `upstream/main` 的其它几百个提交合入子模块 fork 主线；只保留当前 fork 主线并追加 4.7 模型注册与 Claude 前缀兜底。

当前 fork 主线仍保留 Quotio 侧运行时相关补丁，包括：

- `feat(auth): support account metadata headers`
- `fix(claude): apply saved managed headers upstream`
- `fix(management): back off release checks on rate limits`

`QUOTIO_TEST_CA_FILE` 属于历史定制能力；如果后续仍需要继续维护，必须先重新确认官方主线是否已具备等价能力，再决定是否重放。

## 真源规则

后续任何 `CLIProxyAPIPlus` 二次开发，都必须遵守下面这组规则：

- 唯一开发真源：`third_party/CLIProxyAPIPlus`
- 唯一推荐构建入口：`./scripts/manage-cliproxy-plus.sh build`
- 任何实现 worktree 都必须先初始化子模块，再开始编码
- 父仓库记录的 submodule commit 必须能从 `.gitmodules` 里配置的远端 URL 直接抓到；不要把仅存在于本地对象库、临时 branch 或仅存在于 `upstream/*` 而未同步到 `0xTract0r/CLIProxyAPIPlus` 的 commit 直接写进 gitlink

以下路径都不能再被当成开发真源：

- `/tmp/...`
- 仓库外随手克隆的临时副本
- 只有二进制、没有子模块 commit 对应关系的 patched core

`/tmp/...` 的唯一允许用途是：

- 历史核对
- 只读 diff / 证据引用

不能在 `/tmp/...` 做的事情：

- 继续实现新功能
- 生成要提交的补丁
- 构建要推广的产物
- 在方案文档里把它写成后续实现入口

## 常用命令

初始化子模块：

```bash
git submodule update --init --recursive third_party/CLIProxyAPIPlus
```

构建 patched binary：

```bash
./scripts/manage-cliproxy-plus.sh build
```

构建产物默认输出到：

```text
build/CLIProxyAPIPlus/CLIProxyAPI
```

## 维护方式

如果后续要继续改 `CLIProxyAPIPlus`：

1. 新开实现 worktree，不要在文档分支或 `master` 上直接开发
2. 初始化子模块：`git submodule update --init --recursive third_party/CLIProxyAPIPlus`
3. 先抓取 fork 与官方上游，确认当前子模块相对 `origin/main` 和 `upstream/main` 的领先/落后情况
4. 小热修优先从 fork `origin/main` 开分支，只重放必要补丁；全量上游同步必须单独审计
5. 进入 `third_party/CLIProxyAPIPlus` 子模块开发
6. 如补丁仍需长期保留，再决定是否推送到 `0xTract0r/CLIProxyAPIPlus`
7. 回到 Quotio 主仓库更新 submodule 指针
8. 提交 Quotio 里的 submodule 变更

## 最佳实践

- 方案研究可以在 docs worktree 中完成，但实现必须切换到新的实现 worktree
- 文档里如果引用 `/tmp/...`，必须明确写成“历史核对证据”，不能写成“开发入口”
- 如果子模块在当前 worktree 没有正确检出，优先修复子模块状态，不要绕开它继续在临时目录开发
- 若未来再次出现“本地领先很多、官方也在快速演进”的情况，优先评估“回到 `upstream/main` + 最小重放补丁”，而不是继续滚大 fork
- 要交给另一个 AI 接手时，优先交付：
  - 实现 worktree 路径
  - 子模块分支或基线 commit
  - submodule commit
  - 主仓库 submodule pointer
