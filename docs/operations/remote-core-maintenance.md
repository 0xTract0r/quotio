# 远端 Linux core 维护规则

最后更新：2026-04-21

这份文档只负责说明“当前运行真值在哪里、维护入口是什么、最低复验要做什么”。完整部署流水和历史记录继续看 [`linux-cliproxyapi-plus-deploy.md`](./linux-cliproxyapi-plus-deploy.md)。

## 当前运行真值

> 2026-04-21 现态说明：
> 远端 `10.1.1.201` 已恢复到 HTTPS 基线，`runtime/config/config.yaml` 中 `proxy-url` 已恢复、`tls.enable: true`，`runtime/tls/server.crt` / `server.key` 在位。
> 当前对外与人类客户端接入基线重新回到 `https://10.1.1.201:18317`。只有当未来显式执行受控 HTTP 降级时，才应再把 `http://10.1.1.201:18317` 视作临时事故地址。

- 远端主机：`wisedata@10.1.1.201`
- 人类客户端目标基线：Quotio -> `https://10.1.1.201:18317`
- 管理页基线 URL：`https://10.1.1.201:18317/management.html`
- 管理 key 文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/secrets.env`
- 远端部署根目录：`/home/wisedata/deploy/cliproxyapi-plus`
- 远端配置文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/config/config.yaml`
- HTTPS 证书文件（启用时）：`/home/wisedata/deploy/cliproxyapi-plus/runtime/tls/server.crt`
- HTTPS 私钥文件（启用时）：`/home/wisedata/deploy/cliproxyapi-plus/runtime/tls/server.key`
- 历史线上证书指纹（恢复旧信任链时使用）：`D6:3E:34:69:74:8E:23:86:88:3E:A1:9B:09:21:4A:73:62:C5:C9:8F:57:E4:26:34:76:8D:3B:84:71:04:4A:EF`
- 远端 auth 挂载目录：`/home/wisedata/deploy/cliproxyapi-plus/runtime/auth`
- 管理页静态文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/static/management.html`
- 本地源码根目录：`/Users/corylin/Project/ai/quotio`

当前稳定基线是 HTTPS，自签名证书 SAN 包含 `IP:10.1.1.201`。客户端若尚未信任该证书链，临时 smoke 可以用 `curl -k`，长期接入仍必须导入并信任该证书或改成内部 CA / 受信证书。

另一个长期运维边界：

- 远端 core 的 Codex OAuth auth 与本地正式 / 本地 dev 默认不是同一文件，而是独立副本
- 同一 Codex 账号若在多运行面并行 refresh，一端轮换后，其它端持有的旧 refresh token 会出现 `invalid_grant` / `refresh_token_reused`
- 当前默认策略是：不要把本地正式最新 Codex auth 再同步到远端 / dev，也不要让多个运行面长期并行刷新同一账号

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

- 现在脚本在未显式传 `SERVER_PROXY_URL` / `SERVER_TLS_ENABLE` 时，会优先保留远端当前 `config.yaml` 里的 `proxy-url` 与 TLS 模式，不再静默写空
- 如果远端当前已经是 HTTPS，且你显式想降级到 HTTP，必须额外传 `ALLOW_TLS_DOWNGRADE='1'`
- 若远端 `runtime/tls/` 里仍有 `server.crt` / `server.key`，脚本在 `SERVER_TLS_ENABLE` 未显式覆盖时会继续复用它们，且默认不会改写这些文件
- 若远端 `runtime/tls/` 已经为空，脚本会拒绝继续保持 HTTPS 的 redeploy；这时只能二选一：找回旧证书/私钥，或重新签发一张新证书
- 如果决定走“重新签发新证书”这条路，可以先在当前 worktree 本机执行：

```bash
HOST_IP='10.1.1.201' \
OUTPUT_DIR='<当前 worktree>/build/https-recovery/<timestamp>' \
./scripts/generate-cliproxy-self-signed-cert.sh
```

  然后把生成的 `server.crt` / `server.key` 路径传给 `SERVER_TLS_CERT_FILE` / `SERVER_TLS_KEY_FILE`
- 若你明确要让远端主机直接生成一张新的自签名证书，则必须显式传：

```bash
SERVER_TLS_ENABLE='1' \
SERVER_TLS_GENERATE_REMOTE='1'
```

  补充规则：
  - 默认仍推荐先本地生成，再把绝对路径传给 deploy；远端直生只作为维护窗口内的快捷恢复路径
  - 远端直生入口脚本是 `scripts/generate-cliproxy-self-signed-cert-remote.sh`
  - `SERVER_TLS_GENERATE_REMOTE='1'` 不会与本地 `SERVER_TLS_CERT_FILE` / `SERVER_TLS_KEY_FILE` 混用；两者同时传会直接失败
  - 若远端已有旧 `server.crt/server.key`，只有再额外传 `SERVER_TLS_GENERATE_REMOTE_OVERWRITE='1'` 才允许覆盖；覆盖前旧文件会备份到 `${DEPLOY_DIR}/backups/tls-<timestamp>/`
  - SAN IP 默认复用 `SERVER_HOST_IP`，当前远端恢复场景下应保持 `10.1.1.201`
- `SERVER_TLS_CURL_INSECURE=1` 只影响脚本内置 `curl` 验证，不会替客户端建立证书信任
- 需要完整环境变量、回滚命令或历史镜像信息时，看 [`linux-cliproxyapi-plus-deploy.md`](./linux-cliproxyapi-plus-deploy.md)

## 可选 HTTPS 规则

部署脚本的 TLS 行为现在分为“保留远端真值”和“显式覆盖”两类：

当前最现实的证书来源仍是内部 CA 或自签名证书。只要客户端继续直接访问 `10.1.1.201`，证书 SAN 就必须包含 `IP:10.1.1.201`。

- `SERVER_TLS_ENABLE` 未传
  - 若远端已有 `runtime/config/config.yaml`，脚本会保留远端 `tls.enable`
  - 若远端当前是 HTTPS，且 `runtime/tls/server.crt` / `server.key` 仍存在，脚本会继续复用
  - 若远端当前是 HTTPS 但证书文件已丢失，脚本会直接失败，避免静默降级
- `SERVER_TLS_ENABLE=0`
  - 强制写入 `tls.enable: false`
  - 强制写入空 `tls.cert` / `tls.key`
  - 若远端当前是 HTTPS，必须额外传 `ALLOW_TLS_DOWNGRADE=1`
- `SERVER_TLS_ENABLE=1`
  - 若传了本地证书和私钥，要求它们都存在且路径必须是绝对路径
  - 若未传本地证书/私钥，但远端 `runtime/tls/` 里已有 `server.crt` / `server.key`，脚本会直接复用，且默认不改写远端 TLS 文件
  - 若显式传 `SERVER_TLS_GENERATE_REMOTE=1`，脚本会在远端调用 `/usr/bin/openssl` 直接生成新的 `runtime/tls/server.crt` / `server.key`
  - 否则部署失败，不会偷偷切成 HTTP
  - 容器内固定路径为 `/CLIProxyAPI/tls/server.crt` 与 `/CLIProxyAPI/tls/server.key`
  - `runtime/config/config.yaml` 会显式写入 `tls.enable: true`、`tls.cert`、`tls.key`

远端直生的风险与回滚：

- 风险：这会直接改变线上证书指纹；已有信任链会失效，客户端需要重新信任新证书
- 风险：helper 只生成证书，不单独重启服务；真正让 HTTPS 生效仍要进入一次受控 deploy/restart
- 回滚：如覆盖了旧证书，先从 `${DEPLOY_DIR}/backups/tls-<timestamp>/` 恢复旧 `server.crt/server.key`
- 回滚：若保留了本地已知正确证书，也可回退到“本地生成/本地提供绝对路径”的 deploy 路线
- 与本地生成方式的关系：远端直生不会把新私钥回传到本地；若需要审计留档或多机复用，优先走本地生成

management key 文件和取值逻辑不变；启用 HTTPS 后，变化的是：

- 稳定 HTTPS 基线 `BASE_URL` 是 `https://10.1.1.201:18317`
- Quotio / 浏览器 / curl 需要信任对应证书链

## 最小复验

每次远端部署后，至少确认下面几项：

1. 用当前协议的 `BASE_URL` 调 `GET /healthz` 返回 `{"status":"ok"}`
2. 用当前协议的 `BASE_URL` 调 `GET /management.html` 能打开管理页
3. 用 `runtime/secrets.env` 里的管理 key 调 `GET ${BASE_URL}/v0/management/auth-files` 成功
4. 对这次受影响的 provider / auth，至少做一次远端 provider-facing 复验

说明：

- `BASE_URL` 由部署协议决定：
  - 默认稳定基线：`https://10.1.1.201:18317`
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
