# 远端 Linux core 维护规则

最后更新：2026-04-15

这份文档只负责说明“当前运行真值在哪里、维护入口是什么、最低复验要做什么”。完整部署流水和历史记录继续看 [`linux-cliproxyapi-plus-deploy.md`](./linux-cliproxyapi-plus-deploy.md)。

## 当前运行真值

- 远端主机：`wisedata@10.1.1.201`
- 人类客户端默认集成目标：Quotio -> `http://10.1.1.201:18317`
- 管理页 URL：`http://10.1.1.201:18317/management.html`
- 管理 key 文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/secrets.env`
- 远端部署根目录：`/home/wisedata/deploy/cliproxyapi-plus`
- 远端配置文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/config/config.yaml`
- 远端 auth 挂载目录：`/home/wisedata/deploy/cliproxyapi-plus/runtime/auth`
- 管理页静态文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/static/management.html`
- 本地源码根目录：`/Users/corylin/Project/ai/quotio`

## 什么时候必须看这份文档

以下任务不能只在本地 Mac 验证，必须更新并复验远端 `10.1.1.201`：

- `CLIProxyAPI` / `CLIProxyAPIPlus` core 行为改动
- Docker 镜像、`compose.yaml`、runtime config 改动
- auth mount、管理页静态文件、管理接口连通性改动
- `proxy-url` / `proxy_url`、上游代理转发、provider 出站链路改动
- 准备让人类客户端继续接入 Quotio + 远端 core 的联调或验收

本地 `Quotio Dev` 或本机临时 core 只算预检，不算最终验收。

## 标准部署入口

标准方式是从本地源码根目录执行部署脚本，把更新推到远端 Docker 运行面，而不是继续维持一个本机临时 core：

```bash
cd /Users/corylin/Project/ai/quotio
MANAGEMENT_PASSWORD='<RAW_MANAGEMENT_PASSWORD>' \
REMOTE_HOST='wisedata@10.1.1.201' \
DEPLOY_DIR='/home/wisedata/deploy/cliproxyapi-plus' \
API_PORT='18317' \
BIND_HOST='10.1.1.201' \
SERVER_HOST_IP='10.1.1.201' \
QUOTIO_SOURCE_ROOT='/Users/corylin/Project/ai/quotio' \
BUILD_STRATEGY='local-load' \
./scripts/deploy-cliproxy-linux.sh
```

- 如果这次变更需要服务器侧全局代理，再显式传 `SERVER_PROXY_URL`
- 需要完整环境变量、回滚命令或历史镜像信息时，看 [`linux-cliproxyapi-plus-deploy.md`](./linux-cliproxyapi-plus-deploy.md)

## 最小复验

每次远端部署后，至少确认下面几项：

1. `GET http://10.1.1.201:18317/healthz` 返回 `{"status":"ok"}`
2. `GET http://10.1.1.201:18317/management.html` 能打开管理页
3. 用 `runtime/secrets.env` 里的管理 key 调 `GET /v0/management/auth-files` 成功
4. 对这次受影响的 provider / auth，至少做一次远端 provider-facing 复验

说明：

- 不要用 `HEAD /management.html` 当成失败判据；当前部署已知会返回 `404`，但 `GET` 正常
- 第 4 项不能只看本地 UI 或本机日志，必须以远端 management `api-call`、远端核心日志、或等价的 provider-facing 证据为准

## 先别误判成部署失败

以下情况优先按“账号 scope / 上游策略 / auth 内容”排查，而不是先判定部署坏了：

- 远端 `/healthz`、`/management.html`、`/v0/management/auth-files` 都正常
- 某个单独账号返回 provider-originated `401`、`403`、`404`、`429`
- 问题只出现在单个 auth、单个 provider、或该 auth 自带的 `proxy_url` / 托管 `headers`

更像部署或运行面问题的信号：

- 远端健康检查或管理页本身不可用
- 管理 key 无法读取 auth 列表
- 受影响请求只返回本地 `502 request failed`、超时、或根本没到真实上游
