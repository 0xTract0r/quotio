# Vendored CLIProxyAPIPlus Patch Source

最后更新：2026-03-21

这里保存的是 Quotio 对 `CLIProxyAPIPlus` 的可持续维护入口，不是完整上游源码快照。

## 为什么现在不用 Git 子模块

当前不直接使用子模块，原因是：

- 现有改动还只存在本地补丁，没有稳定的远端 fork 可引用
- 如果子模块指向本地路径或未推送提交，其他机器无法复现
- 先把“上游基线 + 本地补丁 + 构建脚本”放进主仓库，维护成本更低

等后续有稳定 fork 后，再切成真正的子模块会更合适。

## 当前方案

- 上游仓库：`https://github.com/router-for-me/CLIProxyAPIPlus.git`
- 当前补丁基线 commit：`7c2ad4c`
- Quotio 补丁文件：
  - [0001-quotio-account-fingerprint.patch](/Users/corylin/Project/ai/quotio.worktrees/feat-account-fingerprint/third_party/CLIProxyAPIPlus/patches/0001-quotio-account-fingerprint.patch)

`work/` 目录是本地工作区和构建产物目录，默认不纳入 Git。

## 常用命令

初始化并应用补丁：

```bash
./scripts/manage-cliproxy-plus.sh bootstrap
```

构建 patched binary：

```bash
./scripts/manage-cliproxy-plus.sh build
```

默认会以 `GOTOOLCHAIN=auto` 构建；如果本机 `go` 版本低于上游 `go.mod` 要求，Go 会自动拉起对应 toolchain。

从本地工作区刷新补丁文件：

```bash
./scripts/manage-cliproxy-plus.sh refresh-patch
```

默认构建产物路径：

```text
third_party/CLIProxyAPIPlus/work/bin/CLIProxyAPI
```

## 与 Quotio 的关系

- `scripts/watch-claude-mitm-session.sh` 默认会优先使用这里构建出来的 patched binary
- 这里只维护 Quotio 当前依赖的最小补丁面，不替代上游完整开发流程
