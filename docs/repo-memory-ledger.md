# Repo Memory Ledger

最后更新：2026-04-24

这份文档只记录仓库级、长期有效、值得反复记住的事实和边界。

它回答的问题不是“先看哪里”，而是“这个仓库有哪些长期结论，忘了就容易误判”。

## 什么时候更新这份文档

- 新确认了一条会长期影响实现、验证、运维或收敛方式的事实
- 同类误判已经重复出现，或者一次代价已经足够高
- 某个 source of truth、runtime truth、验收门禁或收敛规则发生了稳定变化

不应该写进来的内容：

- 通用型 AI 提示词
- 一次性会话策略
- 还没验证的推测
- 纯代码层显而易见、可以低成本从源码恢复的细节

## 长期记忆

### 1. 这不是原生上游 Quotio

当前仓库应该被理解成一个围绕 `CLIProxyAPIPlus` 长期二次开发过的 Quotio fork，而不是“只改过一点 UI 的上游镜像”。

### 2. 有效架构是三层，不是一层

当前有效架构至少包括：

- Quotio 宿主应用
- `third_party/CLIProxyAPIPlus`
- `third_party/Cli-Proxy-API-Management-Center`

很多问题不能只在 SwiftUI 层解释。

### 3. 本机生产运行面默认按活系统对待

下面这些默认都按生产状态理解：

- `~/Library/Application Support/Quotio`
- `~/.cli-proxy-api`
- `18317/28317`

proxy/core 相关实验默认先走 dev runtime 或独立 worktree。

### 4. `CLIProxyAPIPlus` 的唯一开发真源是子模块

唯一开发真源：

- `third_party/CLIProxyAPIPlus`

`/tmp/...`、仓库外临时 clone、只有二进制没有 commit 对应关系的 patched 副本，都不能当继续开发入口；它们最多只用于只读比对。

### 5. 远端 Linux core 是 remote-core 维护的运行真源

对远端 core、Docker、auth mount、上游代理、远程部署做判断时，最终验收面不是本机猜测，而是 `10.1.1.201` 上的真实运行态与对应操作文档。

### 6. Codex auth 在不同运行面默认是独立副本

本地正式、本地 dev、远端 core 的 Codex OAuth auth 默认不是同一个文件；同一账号被多个运行面长期并行 refresh，会触发 `invalid_grant` 或 `refresh_token_reused` 一类轮换冲突。

### 7. 模型同步是分层问题，不是单点问题

排查“为什么这里看不到新模型”时，要分清三层：

- core `/v1/models`
- Quotio 宿主侧最近一次成功拉取后的缓存模型 / 配置生成
- Codex CLI TUI 自己内置的 `/model` picker

其中第三层不是前两层的镜像。TUI 里暂时没出现某个新模型，不等于 runtime 一定不可用。

### 8. 管理页的运行真源是 runtime 里实际 served 的 `management.html`

只替换磁盘文件、不看运行态 served 页面，结论不完整。并且如果没有关掉 auto-update panel，core 可能会把本地刚替换的管理页重新覆盖回旧版。

### 9. 仓库级知识入口和项目地图是分层的

- `repo-knowledge-map.md` 负责回答“遇到某类任务先看哪里”
- `repo-memory-ledger.md` 负责记录长期边界、决策和教训
- `docs/README.md` 负责按主题列文档目录
- `.agentlens` 负责代码地图与符号索引

不要把 `.agentlens` 当成 fork 运行边界的唯一真源，也不要把整套全局提示词原样复制进仓库文档。

## 收敛补充规则

### 什么时候补 `repo-knowledge-map.md`

- 文档入口、推荐阅读顺序、任务路由发生变化时
- 新增一个长期存在的任务域，但目前没人知道该先看哪里时

### 什么时候补 `repo-memory-ledger.md`

- 出现新的长期边界、易踩坑或高代价误判时
- 某条结论已经不适合只藏在一次会话或零散文档里时

### 什么时候还要补 `docs/README.md` / `AI_ONBOARDING.md`

- 当新增的仓库级文档已经变成正式入口，或首屏阅读顺序需要改变时

### 什么时候判断项目地图刷新

- 到交付边界时再判断
- 如果只是补仓库级人工入口文档，通常不需要重跑 `.agentlens`
- 如果代码结构、模块边界、代码入口或生成地图本身的路由变了，再刷新 `.agentlens`
