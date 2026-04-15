# 远端 Linux core 维护规则

最后更新：2026-04-15

这份文档只负责说明“当前运行真值在哪里、维护入口是什么、最低复验要做什么”。完整部署流水和历史记录继续看 [`linux-cliproxyapi-plus-deploy.md`](./linux-cliproxyapi-plus-deploy.md)。

## 当前运行真值

- 远端主机：`wisedata@10.1.1.201`
- 人类客户端默认集成目标：Quotio -> `https://10.1.1.201:18317`
- 管理页 URL：`https://10.1.1.201:18317/management.html`
- 管理 key 文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/secrets.env`
- 远端部署根目录：`/home/wisedata/deploy/cliproxyapi-plus`
- 远端配置文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/config/config.yaml`
- HTTPS 证书文件（启用时）：`/home/wisedata/deploy/cliproxyapi-plus/runtime/tls/server.crt`
- HTTPS 私钥文件（启用时）：`/home/wisedata/deploy/cliproxyapi-plus/runtime/tls/server.key`
- 当前线上证书指纹：`D6:3E:34:69:74:8E:23:86:88:3E:A1:9B:09:21:4A:73:62:C5:C9:8F:57:E4:26:34:76:8D:3B:84:71:04:4A:EF`
- 远端 auth 挂载目录：`/home/wisedata/deploy/cliproxyapi-plus/runtime/auth`
- 管理页静态文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/static/management.html`
- 本地源码根目录：`/Users/corylin/Project/ai/quotio`

当前线上真值已经是 HTTPS，自签名证书 SAN 包含 `IP:10.1.1.201`。客户端若尚未信任该证书链，临时 smoke 只能用 `curl -k`，长期接入则必须导入并信任该证书或改成内部 CA / 受信证书。

后续任何代码或部署变更，都应先在独立 worktree 中完成，再从该 worktree 执行远端部署；不要直接在 `master` 主工作区上改远端真值。

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
cd <当前 worktree 绝对路径>
MANAGEMENT_PASSWORD='<RAW_MANAGEMENT_PASSWORD>' \
REMOTE_HOST='wisedata@10.1.1.201' \
DEPLOY_DIR='/home/wisedata/deploy/cliproxyapi-plus' \
API_PORT='18317' \
BIND_HOST='10.1.1.201' \
SERVER_HOST_IP='10.1.1.201' \
QUOTIO_SOURCE_ROOT='<当前 worktree 绝对路径>' \
BUILD_STRATEGY='local-load' \
CONTAINER_DNS_SERVERS='1.1.1.1,8.8.8.8' \
SERVER_PROXY_URL='http://Clash:hBnsF3B7@10.1.1.5:7890' \
SERVER_TLS_ENABLE='1' \
SERVER_TLS_CERT_FILE='/abs/path/to/server.crt' \
SERVER_TLS_KEY_FILE='/abs/path/to/server.key' \
SERVER_TLS_CURL_INSECURE='1' \
./scripts/deploy-cliproxy-linux.sh
```

- 当前 live 证书只保存在远端 `runtime/tls/`；如果后续 redeploy 还想沿用这张证书，需要先把远端 `server.crt` / `server.key` 取回本地临时目录，再作为 `SERVER_TLS_CERT_FILE` / `SERVER_TLS_KEY_FILE` 传入，或重新签发一张新证书
- `SERVER_TLS_CURL_INSECURE=1` 只影响脚本内置 `curl` 验证，不会替客户端建立证书信任
- 需要完整环境变量、回滚命令或历史镜像信息时，看 [`linux-cliproxyapi-plus-deploy.md`](./linux-cliproxyapi-plus-deploy.md)

## 可选 HTTPS 规则

部署脚本的 TLS 行为是显式的，当前线上配置就是 `SERVER_TLS_ENABLE=1`：

当前最现实的证书来源仍是内部 CA 或自签名证书。只要客户端继续直接访问 `10.1.1.201`，证书 SAN 就必须包含 `IP:10.1.1.201`。

- `SERVER_TLS_ENABLE=0`
  - 强制写入 `tls.enable: false`
  - 强制写入空 `tls.cert` / `tls.key`
  - 目的是避免继承本机或旧 runtime 配置
- `SERVER_TLS_ENABLE=1`
  - 要求本地证书和私钥都存在，且路径必须是绝对路径
  - 脚本会把它们复制到远端 `runtime/tls/server.crt` 与 `runtime/tls/server.key`
  - 容器内固定路径为 `/CLIProxyAPI/tls/server.crt` 与 `/CLIProxyAPI/tls/server.key`
  - `runtime/config/config.yaml` 会显式写入 `tls.enable: true`、`tls.cert`、`tls.key`

management key 文件和取值逻辑不变；启用 HTTPS 后，变化的是：

- `BASE_URL` 当前已经是 `https://10.1.1.201:18317`
- Quotio / 浏览器 / curl 需要信任对应证书链

## 最小复验

每次远端部署后，至少确认下面几项：

1. 用当前协议的 `BASE_URL` 调 `GET /healthz` 返回 `{"status":"ok"}`
2. 用当前协议的 `BASE_URL` 调 `GET /management.html` 能打开管理页
3. 用 `runtime/secrets.env` 里的管理 key 调 `GET ${BASE_URL}/v0/management/auth-files` 成功
4. 对这次受影响的 provider / auth，至少做一次远端 provider-facing 复验

说明：

- `BASE_URL` 由部署协议决定：
  - 当前线上：`https://10.1.1.201:18317`
  - 若显式关闭 TLS：`http://10.1.1.201:18317`
- 自签名证书 smoke 可以对 `curl` 加 `-k`，但这不是长期接入方案
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
