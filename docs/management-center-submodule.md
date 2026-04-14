# Cli-Proxy-API-Management-Center 子模块维护说明

最后更新：2026-04-14

## 当前方案

Quotio 现在额外通过 Git submodule 引入网页端管理后台项目 `Cli-Proxy-API-Management-Center`：

- 子模块路径：`third_party/Cli-Proxy-API-Management-Center`
- 子模块 `origin`：`git@github.com:0xTract0r/Cli-Proxy-API-Management-Center.git`
- 子模块 `upstream`：`git@github.com:router-for-me/Cli-Proxy-API-Management-Center.git`
- 当前跟踪分支：`main`

这个子模块的定位不是替代 Quotio，而是补齐另一条可复用的管理后台路线：

- `CLIProxyAPIPlus`：代理核心、鉴权、路由、账号调度、上游请求转发
- `Cli-Proxy-API-Management-Center`：网页端管理后台、配置页、认证文件页、日志/管理视图
- `Quotio`：原生 macOS 菜单栏与本地桌面产品壳

后续如果要迁移到非 macOS 项目，优先复用的通常是：

1. `CLIProxyAPIPlus` 的核心能力
2. `Cli-Proxy-API-Management-Center` 的网页端管理层

而不是直接照搬 Quotio 的原生 UI。

## 真源规则

后续任何 `Cli-Proxy-API-Management-Center` 二次开发，都必须遵守下面这组规则：

- 唯一 Quotio 内开发真源：`third_party/Cli-Proxy-API-Management-Center`
- 子模块默认推送目标：`origin`，也就是 `0xTract0r` fork
- 官方仓库只作为 `upstream` 用于对齐、比较和择机同步

以下路径都不能被当成开发真源：

- `~/Project/ai/Cli-Proxy-API-Management-Center` 这种仓库外独立克隆
- `/tmp/...`
- 任意没有子模块 commit 对应关系的临时副本

这些外部副本允许的用途只有：

- 只读参考
- 历史 diff
- 与子模块当前状态做对比

## 维护方式

如果后续要继续改网页端管理后台：

1. 新开 Quotio 实现 worktree，不要在 `master` 上直接改
2. 初始化子模块：`git submodule update --init --recursive third_party/Cli-Proxy-API-Management-Center`
3. 确认 remotes：
   - `origin` 应指向 `git@github.com:0xTract0r/Cli-Proxy-API-Management-Center.git`
   - `upstream` 应指向 `git@github.com:router-for-me/Cli-Proxy-API-Management-Center.git`
4. 在子模块目录内开发并提交网页端改动
5. 先把网页端改动推到 fork，再回 Quotio 更新 submodule 指针
6. 最后提交 Quotio 主仓库里的 `.gitmodules` 或 submodule pointer 变更

## 常用命令

初始化子模块：

```bash
git submodule update --init --recursive third_party/Cli-Proxy-API-Management-Center
```

检查远端：

```bash
git -C third_party/Cli-Proxy-API-Management-Center remote -v
```

补上 `upstream`：

```bash
git -C third_party/Cli-Proxy-API-Management-Center remote add upstream \
  git@github.com:router-for-me/Cli-Proxy-API-Management-Center.git
```

拉取官方更新：

```bash
git -C third_party/Cli-Proxy-API-Management-Center fetch upstream
```

前端构建验证：

```bash
npm --prefix third_party/Cli-Proxy-API-Management-Center ci
npm --prefix third_party/Cli-Proxy-API-Management-Center run build
```

本地启动网页端并自动注入 Quotio 本地 management key：

```bash
./scripts/start-management-center.sh
```

如果需要显式指定 Quotio config：

```bash
./scripts/start-management-center.sh \
  --quotio-config "$HOME/Library/Application Support/Quotio/config.yaml"
```

如果服务端配置里已经把 `remote-management.secret-key` 改成 bcrypt/hash，无法从配置文件反推出原始密钥；此时请手工传：

```bash
./scripts/start-management-center.sh \
  --api-base http://127.0.0.1:18317 \
  --management-key '<RAW_MANAGEMENT_KEY>'
```

## 启动脚本规则

`scripts/start-management-center.sh` 的管理密钥解析优先级如下：

1. `--management-key` / 环境变量 `MANAGEMENT_KEY`
2. 按 Quotio `config.yaml` 路径推导出的 Keychain service 中的 `local-management-key`
3. `config.yaml` 里的 `remote-management.secret-key` 明文值

注意：

- `Cli-Proxy-API-Management-Center` 浏览器侧保存的 `enc::v1::...` 只是可逆混淆，不是强加密，不应作为真正的管理密钥真源。
- Quotio 本地模式下，真正更稳定的真源是 Keychain；脚本优先读 Keychain，读不到才退回 config。
- 脚本默认会构建前端、生成临时 `bootstrap.html`，写入同源 `localStorage` 后自动跳到 `/management.html`，从而跳过手工登录。
- 这个临时 `bootstrap.html` 会短暂包含原始 management key，因此脚本默认只绑定 `127.0.0.1`，并在进程退出时自动删除 staging 目录；不要把它暴露到公网，也不要在不可信机器上保留 `--keep-staging` 产物。

## 与 Quotio 的关系

从 Quotio 视角看，这个子模块主要承担两个价值：

- 作为网页端后台参考实现，方便后续把多身份、认证文件、请求配置、日志管理迁移到 Linux/Server/Web 场景
- 作为和 `CLIProxyAPIPlus` 配套的 UI 层基线，避免后续在新项目里只复用核心、却遗漏管理后台交互层

如果后续文档要继续整理“网页端应该如何承接多身份指纹能力”，优先在这个子模块基础上写，而不是继续围绕 Quotio 原生窗口交互写。
