# CLIProxyAPIPlus 子模块维护说明

最后更新：2026-04-24

## 当前方案

Quotio 现在通过 Git submodule 引用维护中的 `CLIProxyAPIPlus`：

- 子模块路径：`third_party/CLIProxyAPIPlus`
- 当前 fork / 子模块远端：`git@github.com:0xTract0r/CLIProxyAPIPlus.git`
- 当前主线 upstream：`git@github.com:router-for-me/CLIProxyAPI.git`
- 已关闭的历史 Plus 仓库：`git@github.com:router-for-me/CLIProxyAPIPlus.git`
- 当前 gitlink 可抓取基线：以 `0xTract0r/CLIProxyAPIPlus` 已公开提交链为准
- 当前对齐方式：`0xTract0r/CLIProxyAPIPlus` 作为可发布 fork，按独立同步任务审计并吸收 `upstream/main`

截至 `2026-04-24`：

- `router-for-me/CLIProxyAPIPlus` 在本地匿名 HTTP / API 与 `git ls-remote` 视角下都返回 `404 / Not Found`
- `router-for-me/CLIProxyAPI` 仍正常公开可访问
- `third_party/CLIProxyAPIPlus/README.md` 明确写明：`CLIProxyAPIPlus` 是 `CLIProxyAPI` 的 Plus 版本；非第三方 provider 相关改动应提交到 `CLIProxyAPI`
- GitHub API 中 `0xTract0r/CLIProxyAPIPlus` 的 `parent/source` 也都指向 `router-for-me/CLIProxyAPI`

因此这里要明确区分三件事：

- `origin` / fork remote：`0xTract0r/CLIProxyAPIPlus`
- 主线 upstream：`router-for-me/CLIProxyAPI`
- 已关闭历史仓库：`router-for-me/CLIProxyAPIPlus`

当前收敛后的策略不是每次模型编号变化都去追已关闭的 `router-for-me/CLIProxyAPIPlus`，而是：

- 默认保持 Quotio 子模块 fork 主线可直接抓取父仓库记录的 gitlink
- 对第三方 provider / Plus 特有补丁，优先在 fork `origin/main` 上维护
- 对非第三方 provider 的通用主线演进，优先参考 `router-for-me/CLIProxyAPI` 的 `main`
- 如需把主线新能力带回 Plus fork，应作为单独任务审计冲突、运行时风险和本地定制补丁，再决定如何重放到 fork

截至 Claude Opus 4.7 热修，本次没有把主线 `router-for-me/CLIProxyAPI` 的后续几百个提交系统性重放到当前 Plus fork；只保留当前 fork 主线并追加 4.7 模型注册与 Claude 前缀兜底。

当前 fork 主线仍保留 Quotio 侧运行时相关补丁，包括：

- `feat(auth): support account metadata headers`
- `fix(claude): apply saved managed headers upstream`
- `fix(management): back off release checks on rate limits`

`QUOTIO_TEST_CA_FILE` 属于历史定制能力；如果后续仍需要继续维护，必须先重新确认官方主线是否已具备等价能力，再决定是否重放。

当前还需要记住一条和模型同步相关的运行边界：

- core 启动后和每 3 小时会尝试刷新远端 models catalog，不再只依赖 embedded `internal/registry/models/models.json`
- 这轮补丁后，models refresh 会沿用当前 `proxy_url` 的 transport；如果远端返回的是“缺 section 的不完整 catalog”，core 会把缺失 section 用 embedded catalog 补齐，而不是把本地已有 provider 整段清空
- Quotio 宿主侧不会在远端拉取失败后立刻退回纯静态全集，而是优先使用“最近一次成功拉取”的缓存模型列表；这能避免前端/配置生成回退到过时模型

## 真源规则

后续任何 `CLIProxyAPIPlus` 二次开发，都必须遵守下面这组规则：

- 唯一开发真源：`third_party/CLIProxyAPIPlus`
- 唯一推荐构建入口：`./scripts/manage-cliproxy-plus.sh build`
- 任何实现 worktree 都必须先初始化子模块，再开始编码
- 父仓库记录的 submodule commit 必须能从 `.gitmodules` 里配置的 fork URL 直接抓到；不要把仅存在于本地对象库、临时 branch 或只存在于主线 `router-for-me/CLIProxyAPI` 而未同步到 `0xTract0r/CLIProxyAPIPlus` 的 commit 直接写进 gitlink
- 默认 remote 语义：
  - `origin = 0xTract0r/CLIProxyAPIPlus`
  - `upstream = router-for-me/CLIProxyAPI`

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
3. 先抓取 fork 与主线 upstream，确认当前子模块相对 `origin/main` 和 `router-for-me/CLIProxyAPI main` 的领先/落后情况
4. 小热修优先从 fork `origin/main` 开分支；若要吸收主线演进，按“主线 diff 审计 -> 选择性重放到 Plus fork”处理，不直接把已关闭的 `router-for-me/CLIProxyAPIPlus` 当 upstream
5. 进入 `third_party/CLIProxyAPIPlus` 子模块开发
6. 如补丁仍需长期保留，再决定是否推送到 `0xTract0r/CLIProxyAPIPlus`
7. 回到 Quotio 主仓库更新 submodule 指针
8. 提交 Quotio 里的 submodule 变更

## 最佳实践

- 方案研究可以在 docs worktree 中完成，但实现必须切换到新的实现 worktree
- 文档里如果引用 `/tmp/...`，必须明确写成“历史核对证据”，不能写成“开发入口”
- 如果子模块在当前 worktree 没有正确检出，优先修复子模块状态，不要绕开它继续在临时目录开发
- 建议本地把 `upstream` remote 指向 `router-for-me/CLIProxyAPI`；若仍需保留已关闭 Plus 仓库名作历史记忆，另起诸如 `legacy-plus` 之类的 remote 名称，不要继续让 `upstream` 指向失效仓库
- 要交给另一个 AI 接手时，优先交付：
  - 实现 worktree 路径
  - 子模块分支或基线 commit
  - submodule commit
  - 主仓库 submodule pointer
