# Linux CLIProxyAPIPlus Docker 部署记录

最后更新：2026-04-15

## 当前结论

- 目标服务器：`wisedata@10.1.1.201`
- 部署方式：本机构建 `linux/amd64` 镜像，通过 `docker load` 导入服务器，再由 `docker compose` 启动
- 当前服务地址：`http://10.1.1.201:18317`
- 当前容器名：`cliproxyapi-plus-remote`
- 当前镜像：`cliproxyapi-plus:linux-server`
- 当前镜像 ID：`sha256:d358abd4d118b6e32177b8fa7abe83266ad579553626205530d2b67a8842821b`

当前部署已经达到：

- 管理面可用
- 认证文件已迁入并可被核心识别
- Claude 与 Codex 路径都已拿到真实上游响应

当前部署的最终结论：

- 可以让用户手动把本地 Quotio 指到 `http://10.1.1.201:18317`
- 如果某个 Codex 账号返回 `403 insufficient permissions: api.model.read`，应先按账号 scope / token 权限问题处理，而不是先判定远端部署失败

## 服务器目录

- 部署根目录：`/home/wisedata/deploy/cliproxyapi-plus`
- Compose 文件：`/home/wisedata/deploy/cliproxyapi-plus/compose.yaml`
- 配置文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/config/config.yaml`
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

### 1. 管理面基础可用

已执行：

```bash
curl -fsS http://10.1.1.201:18317/healthz
curl -fsS http://10.1.1.201:18317/management.html -o /tmp/cliproxy-management.html
curl -fsS \
  -H "Authorization: Bearer <MANAGEMENT_PASSWORD>" \
  http://10.1.1.201:18317/v0/management/auth-files
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
curl -sS -i -X POST http://10.1.1.201:18317/v0/management/api-call \
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
curl -sS -i -X POST http://10.1.1.201:18317/v0/management/api-call \
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

- 现在可以把本地 Quotio 手动切到远端 `http://10.1.1.201:18317`
- management key 使用 `runtime/secrets.env` 中的 `MANAGEMENT_PASSWORD`
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
QUOTIO_SOURCE_ROOT='/Users/corylin/Project/ai/quotio' \
BUILD_STRATEGY='local-load' \
CONTAINER_DNS_SERVERS='1.1.1.1,8.8.8.8' \
SERVER_PROXY_URL='http://Clash:hBnsF3B7@10.1.1.5:7890' \
./scripts/deploy-cliproxy-linux.sh
```

补充说明：

- 如果未来服务器确实需要全局代理，再显式传：

```bash
SERVER_PROXY_URL='http://Clash:hBnsF3B7@10.1.1.5:7890'
```

- 不传 `SERVER_PROXY_URL` 时，脚本默认会把服务器侧 `proxy-url` 写成空字符串

## 管理 key 与前端页面

- 管理页 URL：`http://10.1.1.201:18317/management.html`
- management API 前缀：`http://10.1.1.201:18317/v0/management`
- 管理 key 来源：`/home/wisedata/deploy/cliproxyapi-plus/runtime/secrets.env` 里的 `MANAGEMENT_PASSWORD`
- 这项 `MANAGEMENT_PASSWORD` 是明文值，可直接用于 `Authorization: Bearer <key>`
- 它不是 `runtime/config/config.yaml` 里的 `api-keys`

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
