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

1. 进入子模块目录开发
2. 在 `0xTract0r/CLIProxyAPIPlus` 中提交并推送
3. 回到 Quotio 主仓库更新 submodule 指针
4. 提交 Quotio 里的 submodule 变更

不要再把新的补丁工作副本放到 `/tmp` 里作为真源。
