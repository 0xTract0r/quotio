# Linux CLIProxyAPIPlus Docker 部署记录

最后更新：2026-04-15

## 当前结论

- 目标服务器：`wisedata@10.1.1.201`
- 部署方式：本机构建 `linux/amd64` 镜像，通过 `docker load` 导入服务器，再由 `docker compose` 启动
- 当前服务地址：`https://10.1.1.201:18317`
- 当前协议状态：已切到原生 HTTPS；当前线上证书是自签名证书
- 当前容器名：`cliproxyapi-plus-remote`
- 当前镜像：`cliproxyapi-plus:linux-server`
- 当前镜像 ID：`sha256:d358abd4d118b6e32177b8fa7abe83266ad579553626205530d2b67a8842821b`

当前部署已经达到：

- 管理面可用
- 认证文件已迁入并可被核心识别
- Claude 与 Codex 路径都已拿到真实上游响应

当前部署的最终结论：

- 可以让用户手动把本地 Quotio 指到 `https://10.1.1.201:18317`
- 如果某个 Codex 账号返回 `403 insufficient permissions: api.model.read`，应先按账号 scope / token 权限问题处理，而不是先判定远端部署失败

## 服务器目录

- 部署根目录：`/home/wisedata/deploy/cliproxyapi-plus`
- Compose 文件：`/home/wisedata/deploy/cliproxyapi-plus/compose.yaml`
- 配置文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/config/config.yaml`
- HTTPS 证书文件（启用时）：`/home/wisedata/deploy/cliproxyapi-plus/runtime/tls/server.crt`
- HTTPS 私钥文件（启用时）：`/home/wisedata/deploy/cliproxyapi-plus/runtime/tls/server.key`
- 当前线上证书指纹：`D6:3E:34:69:74:8E:23:86:88:3E:A1:9B:09:21:4A:73:62:C5:C9:8F:57:E4:26:34:76:8D:3B:84:71:04:4A:EF`
- 当前线上证书有效期：`2026-04-15` 到 `2027-04-15`
- 管理密钥环境文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/secrets.env`
- 认证文件目录：`/home/wisedata/deploy/cliproxyapi-plus/runtime/auth`
- 运行日志目录：`/home/wisedata/deploy/cliproxyapi-plus/runtime/logs`
- 管理页静态文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/static/management.html`
- 回滚备份目录：`/home/wisedata/deploy/cliproxyapi-plus/backups`

## 当前最终配置

当前服务器侧已确认的关键配置：

- 端口绑定：`10.1.1.201:18317 -> container:18317`
- 容器用户：`1000:1000`
- 容器 DNS：
  - `1.1.1.1`
  - `8.8.8.8`
- 全局 `proxy-url`：`http://Clash:hBnsF3B7@10.1.1.5:7890`
- 管理面：
  - `remote-management.allow-remote: true`
  - `remote-management.disable-control-panel: false`
  - `remote-management.disable-auto-update-panel: true`
- 持久化目录：
  - `runtime/config -> /CLIProxyAPI/config`
  - `runtime/auth -> /CLIProxyAPI/auth`
  - `runtime/logs -> /CLIProxyAPI/logs`
  - `runtime/static -> /CLIProxyAPI/static`
- HTTPS 证书容器内路径（启用时）：
  - `tls.cert -> /CLIProxyAPI/tls/server.crt`
  - `tls.key -> /CLIProxyAPI/tls/server.key`
- 安全收敛：
  - `read_only: true`
  - `tmpfs: /tmp`
  - `cap_drop: ALL`
  - `security_opt: no-new-privileges:true`
- 容器内 healthcheck：
  - 已关闭
  - 原因是当前镜像未承诺自带 `wget` / `curl`，不再用容器内探针做假阳性/假阴性判断
  - 实际可用性改由宿主机侧真实请求验证

## 本次实际验证

## 已知行为

- `GET /management.html` 能返回管理页；`HEAD /management.html` 在当前部署返回 `404`，不影响 GET。
- 不要把 `HEAD /management.html` 当成验收依据，验收只看 `GET /management.html`。

### 1. 管理面基础可用

已执行：

```bash
curl -kfsS https://10.1.1.201:18317/healthz
curl -kfsS https://10.1.1.201:18317/management.html -o /tmp/cliproxy-management.html
curl -kfsS \
  -H "Authorization: Bearer <MANAGEMENT_PASSWORD>" \
  https://10.1.1.201:18317/v0/management/auth-files
```

结果：

- `GET /healthz` 返回 `{"status":"ok"}`
- `GET /management.html` 返回单文件 HTML，当前大小 `2297466` bytes
- `HEAD /management.html` 返回 `404`
- `GET /v0/management/auth-files` 返回 4 个认证文件：
  - `claude-bcd898@gmail.com.json`
  - `codex-cory2btc@gmail.com-pro.json`
  - `codex-fatovokiroq397@gmail.com-plus.json`
  - `codex-michaelmurphym995@gmail.com-plus.json`

### 2. Claude 链路已验证能到真实上游

已执行：

```bash
curl -ksS -i -X POST https://10.1.1.201:18317/v0/management/api-call \
  -H "Authorization: Bearer <MANAGEMENT_PASSWORD>" \
  -H 'Content-Type: application/json' \
  -d '{"auth_index":"c27128ad6e3cecef","method":"GET","url":"https://api.anthropic.com","header":{"Authorization":"Bearer $TOKEN$"}}'
```

结果：

- management API 自身返回 `HTTP 200`
- 返回体中的上游结果是 `status_code: 404`
- 响应头来自 `api.anthropic.com` / Cloudflare

这说明：

- 当前容器并不是完全出不了网
- 至少“Claude 账号 + 当前代理配置”这一条链路能打到真实 provider

### 3. Codex 链路已验证能到真实上游

已执行的 Codex 探针：

```bash
curl -ksS -i -X POST https://10.1.1.201:18317/v0/management/api-call \
  -H "Authorization: Bearer <MANAGEMENT_PASSWORD>" \
  -H 'Content-Type: application/json' \
  -d '{"auth_index":"33eecb5140987ec5","method":"GET","url":"https://api.openai.com/v1/models","header":{"Authorization":"Bearer $TOKEN$"}}'
```

结果：

- management API 返回 `HTTP 200`
- 返回体中的上游结果是 `status_code: 403`
- 返回的错误来自 OpenAI 上游，核心信息为 `insufficient permissions: api.model.read`
- 响应头来自上游 CDN / Cloudflare

这说明：

- 当前远端全局代理链路已经能把 Codex 请求送到真实上游
- 当前阻塞点不再是“本地 `502 request failed`”
- 如果该账号继续返回 `403 insufficient permissions: api.model.read`，应优先排查账号 scope / token 权限，而不是网络或 Docker 部署

## 当前已知边界

- 远端管理面、静态前端、auth 挂载都已通过
- 当前全局 `proxy-url = http://Clash:hBnsF3B7@10.1.1.5:7890` 已在 `runtime/config/config.yaml` 生效
- Claude 探针拿到真实上游 `404/405`，Codex 探针拿到真实上游 `403 insufficient permissions: api.model.read`
- 这意味着当前“部署/代理链路是否通”的问题已经收口；剩余问题更可能是单个账号权限、auth 内容或 provider 侧策略

## 用户什么时候可以切 Quotio

### 当前准入结论

- 现在可以把本地 Quotio 手动切到远端 `https://10.1.1.201:18317`
- management key 使用 `runtime/secrets.env` 中的 `MANAGEMENT_PASSWORD`
- 当前证书是自签名；在 Quotio、浏览器或其他客户端里使用前，必须先信任这张证书或它的签发链
- 是否“业务完全可用”仍要看你正在使用的具体账号 scope

### 什么情况下不要误判成部署失败

以下情况优先按账号或上游权限问题排查：

1. 管理面通过
2. `api-call` 已返回真实上游状态码
3. 某个 Codex 账号返回的是 `403 insufficient permissions: api.model.read` 之类 provider-originated 错误

只有当请求重新退化为本地 `502 request failed`、超时、或根本没到真实上游时，才优先按部署/代理链路故障处理

## 当前部署命令

本次最终有效的部署命令：

```bash
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

补充说明：

- 如果未来服务器确实需要全局代理，再显式传：

```bash
SERVER_PROXY_URL='http://Clash:hBnsF3B7@10.1.1.5:7890'
```

- 不传 `SERVER_PROXY_URL` 时，脚本默认会把服务器侧 `proxy-url` 写成空字符串
- 当前 live 证书只保存在远端 `runtime/tls/`；如果后续 redeploy 还想沿用这张证书，需要先把远端 `server.crt` / `server.key` 取回本地临时目录，再作为 `SERVER_TLS_CERT_FILE` / `SERVER_TLS_KEY_FILE` 传入，或重新签发一张新证书

## 可选 HTTPS 开启方式

脚本已经支持 core 原生 HTTPS。当前线上已经启用 HTTPS，自签名证书位于远端 `runtime/tls/`。

当前最现实的证书来源仍是：

- 内部 CA 证书
- 自签名证书

如果客户端继续直接访问 `10.1.1.201`，证书 SAN 必须包含：

- `IP:10.1.1.201`

新增环境变量：

- `SERVER_TLS_ENABLE=0|1`
  - 默认 `0`
  - `1` 时会把本地证书和私钥打包进远端 runtime，并在 `runtime/config/config.yaml` 中显式写入 `tls.enable: true`
- `SERVER_TLS_CERT_FILE=/abs/path/to/server.crt`
- `SERVER_TLS_KEY_FILE=/abs/path/to/server.key`
- `SERVER_TLS_CURL_INSECURE=0|1`
  - 默认 `0`
  - 仅用于自签名证书的 `curl` smoke；会给脚本内置验收请求追加 `-k`
  - 它不会改变服务端证书，也不会让 Quotio / 浏览器自动信任该证书

启用 HTTPS 的最小示例：

```bash
MANAGEMENT_PASSWORD='<RAW_MANAGEMENT_PASSWORD>' \
REMOTE_HOST='wisedata@10.1.1.201' \
DEPLOY_DIR='/home/wisedata/deploy/cliproxyapi-plus' \
API_PORT='18317' \
BIND_HOST='10.1.1.201' \
SERVER_HOST_IP='10.1.1.201' \
QUOTIO_SOURCE_ROOT='<当前 worktree 绝对路径>' \
BUILD_STRATEGY='local-load' \
SERVER_PROXY_URL='http://Clash:hBnsF3B7@10.1.1.5:7890' \
SERVER_TLS_ENABLE='1' \
SERVER_TLS_CERT_FILE='/abs/path/to/server.crt' \
SERVER_TLS_KEY_FILE='/abs/path/to/server.key' \
./scripts/deploy-cliproxy-linux.sh
```

若证书是自签名，只允许在 smoke 时额外传：

```bash
SERVER_TLS_CURL_INSECURE='1'
```

脚本会把证书复制到：

- 宿主机：`runtime/tls/server.crt`、`runtime/tls/server.key`
- 容器内：`/CLIProxyAPI/tls/server.crt`、`/CLIProxyAPI/tls/server.key`

显式写入的 `tls` 配置行为：

- `SERVER_TLS_ENABLE=1`
  - `tls.enable: true`
  - `tls.cert: /CLIProxyAPI/tls/server.crt`
  - `tls.key: /CLIProxyAPI/tls/server.key`
- `SERVER_TLS_ENABLE=0`
  - `tls.enable: false`
  - `tls.cert: ""`
  - `tls.key: ""`
  - 这样可以避免意外继承本机已有 TLS 配置

## HTTP / HTTPS 验收方式

脚本内置验收会根据 `SERVER_TLS_ENABLE` 自动推导 `BASE_URL`：

- 当前线上：`https://10.1.1.201:18317`
- 如显式关闭 TLS：`http://10.1.1.201:18317`

手工 `curl` 验收时也应按同样规则处理：

```bash
BASE_URL='https://10.1.1.201:18317'
curl -fsS -k "${BASE_URL}/healthz"
curl -fsS -k "${BASE_URL}/management.html" -o /tmp/cliproxy-management.html
curl -fsS -k \
  -H "Authorization: Bearer <MANAGEMENT_PASSWORD>" \
  "${BASE_URL}/v0/management/auth-files"
```

注意：

- `-k` 只适用于自签名 smoke；长期接入的 Quotio、浏览器和其他客户端应改为信任该证书或使用受信 CA 证书
- management key 不因为 HTTPS 改变；变化的是 URL scheme 和客户端对证书链的信任要求
- `HEAD /management.html` 依然不能作为验收依据

## 管理 key 与前端页面

- 管理页 URL：`https://10.1.1.201:18317/management.html`
- management API 前缀：`https://10.1.1.201:18317/v0/management`
- 管理 key 来源：`/home/wisedata/deploy/cliproxyapi-plus/runtime/secrets.env` 里的 `MANAGEMENT_PASSWORD`
- 这项 `MANAGEMENT_PASSWORD` 是明文值，可直接用于 `Authorization: Bearer <key>`
- 它不是 `runtime/config/config.yaml` 里的 `api-keys`
- 当前线上已经启用 HTTPS；management key 本身不变，变化的是 URL scheme 和客户端对证书链的信任要求

## 日常维护命令

启动：

```bash
ssh wisedata@10.1.1.201 'cd /home/wisedata/deploy/cliproxyapi-plus && sudo docker compose up -d'
```

停止：

```bash
ssh wisedata@10.1.1.201 'cd /home/wisedata/deploy/cliproxyapi-plus && sudo docker compose stop'
```

重启：

```bash
ssh wisedata@10.1.1.201 'cd /home/wisedata/deploy/cliproxyapi-plus && sudo docker compose restart'
```

查看容器状态：

```bash
ssh wisedata@10.1.1.201 'cd /home/wisedata/deploy/cliproxyapi-plus && sudo docker compose ps'
```

查看 Docker 日志：

```bash
ssh wisedata@10.1.1.201 'cd /home/wisedata/deploy/cliproxyapi-plus && sudo docker compose logs -f cliproxyapi'
```

查看文件日志：

```bash
ssh wisedata@10.1.1.201 'tail -f /home/wisedata/deploy/cliproxyapi-plus/runtime/logs/main.log'
```

## 当前回滚基线

本次部署后已准备：

- 回滚镜像 tag：`cliproxyapi-plus:rollback-20260415T092232Z`
- 运行目录备份：`/home/wisedata/deploy/cliproxyapi-plus/backups/runtime-20260415T092232Z.tgz`

回滚命令：

```bash
ssh wisedata@10.1.1.201 '
  cd /home/wisedata/deploy/cliproxyapi-plus &&
  sudo docker compose down &&
  rm -rf runtime &&
  mkdir -p runtime &&
  tar -C . -xzf backups/runtime-20260415T092232Z.tgz &&
  sudo docker image tag cliproxyapi-plus:rollback-20260415T092232Z cliproxyapi-plus:linux-server &&
  sudo docker compose up -d
'
```
