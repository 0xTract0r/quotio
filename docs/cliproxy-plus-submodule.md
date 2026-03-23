# CLIProxyAPIPlus 子模块维护说明

最后更新：2026-03-21

## 当前方案

Quotio 现在通过 Git submodule 引用维护中的 `CLIProxyAPIPlus`：

- 子模块路径：`third_party/CLIProxyAPIPlus`
- 子模块远端：`git@github.com:0xTract0r/CLIProxyAPIPlus.git`
- 当前跟踪分支：`quotio/account-fingerprint`

这个分支包含 Quotio 当前需要的补丁，包括：

- auth file `headers` 落到运行时上游 header
- `QUOTIO_TEST_CA_FILE` 测试 CA 注入支持

## 真源规则

后续任何 `CLIProxyAPIPlus` 二次开发，都必须遵守下面这组规则：

- 唯一开发真源：`third_party/CLIProxyAPIPlus`
- 唯一推荐构建入口：`./scripts/manage-cliproxy-plus.sh build`
- 任何实现 worktree 都必须先初始化子模块，再开始编码

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
3. 进入 `third_party/CLIProxyAPIPlus` 子模块开发
4. 在 `0xTract0r/CLIProxyAPIPlus` 中提交并推送
5. 回到 Quotio 主仓库更新 submodule 指针
6. 提交 Quotio 里的 submodule 变更

## 最佳实践

- 方案研究可以在 docs worktree 中完成，但实现必须切换到新的实现 worktree
- 文档里如果引用 `/tmp/...`，必须明确写成“历史核对证据”，不能写成“开发入口”
- 如果子模块在当前 worktree 没有正确检出，优先修复子模块状态，不要绕开它继续在临时目录开发
- 要交给另一个 AI 接手时，优先交付：
  - 实现 worktree 路径
  - 子模块分支
  - submodule commit
  - 主仓库 submodule pointer
