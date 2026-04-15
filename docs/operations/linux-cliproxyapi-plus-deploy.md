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
- 至少一条 Claude 上游探针可达真实 provider

当前部署还没有达到：

- Codex 链路稳定可用
- 可以让用户把本地 Cursor 手动切到这台远程 core

结论先说清楚：

- 现在不要把本地 Cursor 切到 `10.1.1.201:18317`
- 等 Codex 真实上游探针从本地 `502 request failed` 变成真实上游响应后，再切

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

### 3. Codex 链路仍未达标

已执行的 Codex 探针：

```bash
curl -sS -i -X POST http://10.1.1.201:18317/v0/management/api-call \
  -H "Authorization: Bearer <MANAGEMENT_PASSWORD>" \
  -H 'Content-Type: application/json' \
  -d '{"auth_index":"33eecb5140987ec5","method":"GET","url":"https://api.openai.com/v1/models","header":{"Authorization":"Bearer $TOKEN$"}}'
```

结果：

- management API 返回 `HTTP 502`
- 返回体：`{"error":"request failed"}`

服务器日志也显示对应 `POST /v0/management/api-call` 失败：

- 有一条约 `4s` 的 `502`
- 有多条约 `30s` / `60s` 的 `502`

这说明：

- 这不是“OpenAI 上游真实返回了 401 / 403 / 404”
- 而是请求在到达上游前就失败了

## 当前已知风险点

### Codex 相关风险

当前 3 个 Codex 认证里：

- `codex-cory2btc@gmail.com-pro.json`：没有 `proxy_url`
  - 走的是对 `api.openai.com` 的直接域名访问
- `codex-fatovokiroq397@gmail.com-plus.json`：`proxy_url = socks5://...@p.webshare.io:10001`
- `codex-michaelmurphym995@gmail.com-plus.json`：`proxy_url = socks5://...@p.webshare.io:10000`

这三种路径都还存在 DNS 风险：

- 直连路径依赖 `api.openai.com` 解析
- 代理路径依赖 `p.webshare.io` 解析

### DNS 风险

当前已经显式给容器注入：

- `1.1.1.1`
- `8.8.8.8`

但容器内对外部 DNS 的直接探测仍然超时，例如：

```bash
sudo docker exec cliproxyapi-plus-remote sh -lc 'nslookup p.webshare.io 1.1.1.1'
sudo docker exec cliproxyapi-plus-remote sh -lc 'nslookup api.openai.com 1.1.1.1'
```

都出现：

```text
connection timed out; no servers could be reached
```

这说明当前更像是：

- 服务器所在网络对外部 DNS 有限制，或
- 到公开 DNS 的 UDP/53 本身不可达，或
- 宿主机当前 DNS 环境本身就无法稳定解析 `api.openai.com` / `p.webshare.io`

## 用户什么时候可以切 Cursor

### 现在不应切

下面这个条件目前不满足，因此现在不应把本地 Cursor 切到远程：

- 至少一条 Codex 真实上游探针成功到达 upstream，并返回真实上游状态码

当前 Codex 仍然是本地 `502 request failed`，所以不达标。

### 什么时候可以切

至少满足下面两条后，才建议用户手动切本地 Cursor 到远程：

1. `auth_index=33eecb5140987ec5` 或其他 Codex auth，对 `https://api.openai.com/v1/models` 的 `api-call` 不再返回本地 `502`
2. 返回的是 OpenAI 真实上游状态
   - 例如 `200`
   - 或即使不是 `200`，也至少是来自上游的真实 `401/403/404`，而不是 `{"error":"request failed"}`

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
