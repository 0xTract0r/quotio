# 远端 Linux core 维护规则

最后更新：2026-05-14

这份文档只负责说明“当前运行真值在哪里、维护入口是什么、最低复验要做什么”。完整部署流水和历史记录继续看 [`linux-cliproxyapi-plus-deploy.md`](./linux-cliproxyapi-plus-deploy.md)。

## 当前运行真值

> 2026-05-11 现态说明：
> 远端 `10.1.1.201` 已切到 `cpa.wisedata.co` 的 Let's Encrypt HTTPS 证书，`runtime/config/config.yaml` 中 `proxy-url` 已恢复、`tls.enable: true`，`runtime/tls/server.crt` / `server.key` 在位。
> 当前对外与人类客户端接入基线是 `https://cpa.wisedata.co:18317`。只有当未来显式执行受控 HTTP 降级时，才应再把 `http://10.1.1.201:18317` 视作临时事故地址。

- 远端主机：`wisedata@10.1.1.201`
- 人类客户端目标基线：Quotio / Claude / Codex -> `https://cpa.wisedata.co:18317`
- Quotio 接入方式：`remote-core` 直连远端 endpoint；或 `remote-relay` 保留本机 `127.0.0.1:<port>` 客户端入口并转发到远端 core
- 管理页基线 URL：`https://cpa.wisedata.co:18317/management.html`
- 管理 key 文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/secrets.env`
- 远端部署根目录：`/home/wisedata/deploy/cliproxyapi-plus`
- 远端配置文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/config/config.yaml`
- HTTPS 证书文件（启用时）：`/home/wisedata/deploy/cliproxyapi-plus/runtime/tls/server.crt`
- HTTPS 私钥文件（启用时）：`/home/wisedata/deploy/cliproxyapi-plus/runtime/tls/server.key`
- 历史线上证书指纹（恢复旧信任链时使用）：`D6:3E:34:69:74:8E:23:86:88:3E:A1:9B:09:21:4A:73:62:C5:C9:8F:57:E4:26:34:76:8D:3B:84:71:04:4A:EF`
- 远端 auth 挂载目录：`/home/wisedata/deploy/cliproxyapi-plus/runtime/auth`
- 管理页静态文件：`/home/wisedata/deploy/cliproxyapi-plus/runtime/static/management.html`
- 本地源码根目录：`/Users/corylin/Project/ai/quotio`
- 远端主机的生产网关：`10.1.1.5` OpenWRT/OpenClash。远端 core 到账号专属代理商和 provider 的出站流量会经过这台网关；不要把本地客户端显示 `DIRECT` 误读成远端上游链路没有经过 `.5`。

当前稳定基线是 HTTPS，客户端入口域名为 `cpa.wisedata.co`。本机通过 `/etc/hosts` 把该域名解析到 `10.1.1.201`；远端服务端证书由 Let's Encrypt 签发，SAN 包含 `DNS:cpa.wisedata.co`，因此正常客户端不需要 `curl -k`、`NODE_TLS_REJECT_UNAUTHORIZED=0` 或自签证书 bundle。若绕过 hosts 改用公网 DNS，必须确保 `cpa.wisedata.co` 仍能解析到目标远端地址。

### 2026-05-11 本机 Claude / Codex 直连远端状态

本机曾在 `remote-relay` 下让 Claude / Codex 继续走 `http://127.0.0.1:18317`，由本地 Quotio 转发到远端。2026-05-11 为排查本地大量 Codex 断流，先临时直连 `https://10.1.1.201:18317`，后续已签发并部署 `cpa.wisedata.co` 的 Let's Encrypt 证书，最终把本机 Claude / Codex CLI 改成直接访问远端域名入口：

- Codex：`~/.codex/config.toml` 的 `model_providers.cliproxyapi.base_url` 改为 `https://cpa.wisedata.co:18317/v1`
- Claude：`~/.claude/settings.json` 的 `env.ANTHROPIC_BASE_URL` 改为 `https://cpa.wisedata.co:18317`
- Claude settings 保留 `HTTP_PROXY` / `HTTPS_PROXY` 时，必须同时设置 `NO_PROXY` / `no_proxy = cpa.wisedata.co,10.1.1.201,127.0.0.1,localhost`；否则本机代理会把到远端 core 的内网流量带偏并触发 `ECONNRESET`
- Codex 若运行环境存在系统代理，也需要同等 `NO_PROXY` / `no_proxy`；当前本机已在 `~/.zshrc` 持久化该绕过
- 两者继续使用本机原有 Quotio API key / auth token，不改变远端 auth 挂载目录，也不触发远端 deploy 或重启

已验证事实：

- `curl https://cpa.wisedata.co:18317/healthz` 返回 `{"status":"ok"}`，`SSL_VERIFY_RESULT=0`
- `claude -p` 已返回 `claude-cpa-noproxy-ok`
- `codex exec` 已返回 `codex-cpa-noproxy-only-ok`

当前远端证书要点：

- `subject = /CN=cpa.wisedata.co`
- `issuer = Let's Encrypt E7`
- `SAN = DNS:cpa.wisedata.co`
- `Basic Constraints = CA:FALSE`
- `SHA256 Fingerprint = 7E:3E:A2:CF:C5:08:82:54:32:E8:F6:4F:51:23:B3:1F:C2:90:8F:12:87:1E:BC:19:D1:1B:02:F9:91:0C:44:3C`
- `notAfter = 2026-08-09 10:03:40 GMT`

风险边界：

- 这是本机 CLI 接入方式和远端 TLS 证书变更；不改变远端 auth 挂载目录
- 远端旧自签证书已备份到 `backups/tls-20260511T111422Z`
- Let’s Encrypt 手动 DNS 模式不能自动续期；下次续期会生成新的 `_acme-challenge.cpa.wisedata.co` TXT value，需要在过期前手动续期或改成 DNS API 自动续期
- 如果本机代理继续接管 `cpa.wisedata.co:18317`，Claude/Codex 仍可能失败；优先检查 `NO_PROXY` / `no_proxy`

回滚到本地 Quotio relay：

```toml
# ~/.codex/config.toml
[model_providers.cliproxyapi]
base_url = "http://127.0.0.1:18317/v1"
```

```json
// ~/.claude/settings.json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:18317"
  }
}
```

若要回滚远端证书，恢复 `backups/tls-20260511T111422Z/server.crt` 与 `server.key` 到 `runtime/tls/` 后重启远端 compose 服务；这会重新回到旧自签证书链。

另一个长期运维边界：

- 远端 core 的 Codex OAuth auth 与本地正式 / 本地 dev 默认不是同一文件，而是独立副本
- 同一 Codex 账号若在多运行面并行 refresh，一端轮换后，其它端持有的旧 refresh token 会出现 `invalid_grant` / `refresh_token_reused`
- 当前默认策略是：不要把本地正式最新 Codex auth 再同步到远端 / dev，也不要让多个运行面长期并行刷新同一账号
- 若必须用本地账号解除远端 provider-facing 验证阻塞，只允许同步 access-token-only 副本：不要上传 refresh token；在账号设置里把 `refresh_enabled=false`，或使用 `scripts/sync-access-token-only-auth.sh` 生成/上传已移除 refresh token 的临时 auth
- Claude OAuth 重新认证排障要看 token exchange 和真实 provider 请求，不能只看 UI 状态。T076 的实测故障链路是远端已收到 localhost callback，但第一次 `api.anthropic.com:443` token exchange 被 SOCKS 代理返回 `connection not allowed by ruleset`；短重试后同一账号路径成功，没有触发标准 OAuth transport fallback。这个错误应优先按代理规则 / 出口策略排查，不应误判为 callback 没提交、token 已拿到但没落盘、Anthropic 业务 4xx 或 TLS 指纹拒绝。
- T240 的实测补充：Codex `/v1/responses` 大量 500 时，request log 若显示 `p.webshare.io:<port> -> chatgpt.com/auth.openai.com` 的 `EOF`、`connect timeout` 或 `connection reset`，优先按 `201 -> 10.1.1.5 OpenClash -> 账号代理商 -> provider` 链路不稳排查；这类问题不同于 `unknown provider for model ...` 的配置型 502。Claude `connection not allowed by ruleset` 同样是 SOCKS CONNECT 阶段拒绝，不是 Anthropic API 业务响应。
- OAuth re-auth 必须保留用户字段：远端 core 已修复 `RequestCodexToken` / `saveTokenRecord` 在 OAuth re-auth 路径上覆盖 `proxy_url` / `note` / `headers` / `refresh_disabled` / `refresh_enabled` / `websockets` / `disabled` / `account_settings` 的 bug。修复后这些字段会在写入新 OAuth token 之前从同账号旧记录里 merge 回来；Codex plan-type 改名（如 `plus -> pro`）也会自动删除旧 credential 文件并把旧 in-memory entry 标记 disabled。Re-auth 后如果发现 proxy 或 managed header 等用户字段消失，应优先确认 core image 是否包含本修复，再排查其他原因。
- 管理 UI 的 `GET /v0/management/auth-files` 现在是纯 read-only fast path，不再在请求线上同步 managed-header / runtime-identity 状态；这些刷新改由 handler 内置的 `managedHeaderSyncScheduler` 背景执行（per-auth in-flight dedup + 指数退避 60s -> 10m）。所以列表慢、`ListAuthFiles slow` warning 或 managed header 一段时间内没更新，应优先看后台 goroutine 是否被 in-flight 锁或 cooldown 阻断，而不是先怀疑账号本身。
- `CodexExecutor.Refresh` / `ClaudeExecutor.Refresh` 现在在执行 OAuth refresh 前会显式检查 `auth.RefreshDisabled()`（覆盖 metadata `refresh_disabled=true` / `refresh_enabled=false` / `account_settings.refresh_enabled=false`），任何调用路径（retry-on-401、unaware path）都不会再绕过 operator 设置触发 provider refresh。

后续任何代码或部署变更，都应先在独立 worktree 中完成，再从该 worktree 执行远端部署；不要直接在 `master` 主工作区上改远端真值。

OpenClash 运行态是生产网关，不属于远端 core 部署 helper 的可随手操作范围。除非用户明确安排维护窗口，本仓库 AI 会话不要直接修改 `.5` overlay、reload/restart OpenClash 或切换全局 selector；只允许准备只读诊断、离线 diff、回滚步骤和交给 operator 执行的 runbook。

## access-token-only 远端测试账号

当远端 Codex / Claude auth 因 `token_expired`、`refresh_token_reused` 或 `auth_unavailable` 阻塞 provider-facing 验证时，可以临时导入本地 access token 副本，但必须遵守：

- 只复制 `access_token` / 必要账号元数据，不复制 `refresh_token`、`refreshToken` 或其它 refresh-token-like 字段
- 上传记录必须设置 `refresh_enabled=false` / `refresh_disabled=true`，让远端 core 不调度自动 refresh，manual status refresh 也不进入 provider refresh flow
- access token 本身通常短期有效；这个流程只用于验收“请求是否进入真实上游”和 managed headers / proxy 链路，不是长期账号托管方案
- 建议使用默认 dry-run 的脚本，先检查 summary，再显式执行：

```bash
LOCAL_AUTH_FILE='<本地 auth json>' \
REMOTE_AUTH_NAME='codex-access-token-only.json' \
REMOTE_BASE_URL='https://10.1.1.201:18317' \
EXECUTE=1 \
./scripts/sync-access-token-only-auth.sh
```

脚本会把摘要写到 `build/access-token-only-auth-sync/summary.json`，摘要只记录 refresh token 字段是否被移除，不记录 token 值。

## 什么时候必须看这份文档

以下任务不能只在本地 Mac 验证，必须更新并复验远端 `10.1.1.201`：

- `CLIProxyAPI` / `CLIProxyAPIPlus` core 行为改动
- Docker 镜像、`compose.yaml`、runtime config 改动
- auth mount、管理页静态文件、管理接口连通性改动
- `proxy-url` / `proxy_url`、上游代理转发、provider 出站链路改动
- 准备让人类客户端继续接入 Quotio + 远端 core 的联调或验收

本地 `Quotio Dev` 或本机临时 core 只算预检，不算最终验收。若验收对象是 `remote-relay`，还必须确认本机监听端口只作为 relay，账号、token、logs、usage 与管理配置均从远端 core 拉取。

## 标准部署入口（安全 helper 优先）

标准方式是从当前 writer worktree 执行默认 dry-run 的安全 helper。它只在显式传 `--execute` 时才会触发远端备份、current image rollback tag、Docker build/load、`docker compose up -d` 和远端 core 重启；默认 `SYNC_AUTH_DIR=0`，不会同步本地 auth 目录，也不会读取或写入 refresh token。

先生成部署计划和本地 manifest：

```bash
cd <当前 worktree 绝对路径>
./scripts/deploy-cliproxy-linux-safe.sh --dry-run
```

可选只读预检当前远端容器镜像 ID（仍不会重启或备份）：

```bash
./scripts/deploy-cliproxy-linux-safe.sh --dry-run --remote-read
```

确认维护窗口后再执行：

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
SERVER_TLS_CURL_INSECURE='1' \
./scripts/deploy-cliproxy-linux-safe.sh --execute
```

如果本机不应读取管理 key，可保留远端现有 `runtime/secrets.env`，让 helper 在远端本机用该文件完成 `/v0/management/auth-files` 版本证明：

```bash
cd <当前 worktree 绝对路径>
PRESERVE_REMOTE_MANAGEMENT_SECRET='1' \
REMOTE_HOST='wisedata@10.1.1.201' \
DEPLOY_DIR='/home/wisedata/deploy/cliproxyapi-plus' \
API_PORT='18317' \
BIND_HOST='10.1.1.201' \
SERVER_HOST_IP='10.1.1.201' \
QUOTIO_SOURCE_ROOT='<当前 worktree 绝对路径>' \
BUILD_STRATEGY='local-load' \
CONTAINER_DNS_SERVERS='1.1.1.1,8.8.8.8' \
SERVER_TLS_ENABLE='1' \
SERVER_TLS_CURL_INSECURE='1' \
./scripts/deploy-cliproxy-linux-safe.sh --execute
```

- helper 会生成 `build/remote-deploy-safety/<timestamp>/manifest.env`，记录 `CORE_BUILD_VERSION`、`CORE_BUILD_COMMIT`、`CORE_BUILD_DATE`、expected `X-CPA-*` headers、rollback image tag、远端非 auth runtime 备份目录和 rollback 命令
- helper 会把 `VERSION` / `COMMIT` / `BUILD_DATE` build args 传给 `scripts/deploy-cliproxy-linux.sh`，dry-run 会先构建本地 version-proof artifact 校验 buildinfo 注入；真正执行后，`/healthz`、`/management.html` 和 `/v0/management/auth-files` 都必须返回匹配 manifest 的 `X-CPA-VERSION` / `X-CPA-COMMIT` / `X-CPA-BUILD-DATE`，否则部署脚本会失败并应按 manifest rollback
- helper 的 runtime backup 默认只打包 `compose.yaml`、`runtime/config`、`runtime/static`、`runtime/tls` 与 `runtime/secrets.env`，不打包 `runtime/auth`；部署默认 `SYNC_AUTH_DIR=0`，远端 auth 挂载目录应保持原地不变
- `PRESERVE_REMOTE_MANAGEMENT_SECRET=1` 会保护远端 `runtime/secrets.env` 不被 rsync 覆盖；适用于本机不落管理 key 的维护场景
- 如果需要回滚，优先使用本次 manifest 里打印的命令；回滚也默认 dry-run，只有显式 `--execute` 才会恢复非 auth runtime 备份、把 rollback image tag 重新标成当前 image 并 `docker compose up -d`

```bash
./scripts/deploy-cliproxy-linux-safe.sh rollback \
  --manifest build/remote-deploy-safety/<timestamp>/manifest.env \
  --execute
```

`scripts/deploy-cliproxy-linux.sh` 仍是底层部署实现，但不要在生产维护窗口直接绕过 safe helper，除非你已经手工准备同等的 current image rollback tag、非 auth runtime backup、pre/post health checks 和 `X-CPA-*` 版本证明。

- 现在底层脚本在未显式传 `SERVER_PROXY_URL` / `SERVER_TLS_ENABLE` 时，会优先保留远端当前 `config.yaml` 里的 `proxy-url` 与 TLS 模式，不再静默写空
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
4. 保存 `/healthz`、`/management.html` 和 `GET ${BASE_URL}/v0/management/auth-files` 的响应头，确认 `X-CPA-COMMIT` 等于本次 manifest 里的 `core_build_commit`，`X-CPA-VERSION` 等于 `core_build_version` 加 `-plus`，`X-CPA-BUILD-DATE` 等于本次 manifest 里的 `core_build_date`
5. 对这次受影响的 provider / auth，至少做一次远端 provider-facing 复验

若排查的是 Codex/Claude 断流而不是部署变更，最小证据顺序是：

1. 本地客户端日志只用于确认用户侧症状，例如 `stream disconnected`、`context deadline exceeded`、`Client.Timeout`
2. 远端 `runtime/logs/main.log` 用 5 分钟桶聚合 `/v1/responses`、`/v1/messages?beta=true`、`/v1/chat/completions` 的 `200/500/502`
3. 对 500/502 的 request log 只抽取 `URL`、`Timestamp`、`Error`、`Status` 和 error JSON，不 dump request body，避免暴露 token 或把大上下文写进报告
4. 看到 `unknown provider for model ...` 时归为模型配置问题；看到 SOCKS `EOF`、`connect timeout`、`connection reset`、`connection not allowed by ruleset` 时归为账号代理 / `.5` 网关 / 代理商链路问题
5. 以同窗后续是否大量恢复 `200` 判断是否仍在持续故障，不要把单次 `context canceled` 直接升级成 outage

若验收对象是 Quotio `remote-relay`，还要额外确认：

- 本机只监听 `127.0.0.1:<localPort>`，不监听 `0.0.0.0`
- `GET http://127.0.0.1:<localPort>/healthz` 能经 relay 返回远端 core 的健康结果
- 经本机 relay 调 `/v0/management/auth-files`、`/v0/management/usage`、`/v0/management/logs` 能读到远端数据；不要把本地 request history 当成 remote-relay 日志真源
- 若 UI 显示“远程已断开”，先同时验证轻量 `/healthz` 和带 management key 的 `/v0/management/auth-files` / `/usage`。不要因为 `/auth-files` 单次超时就判定远端 core 宕机；只有 `401/403` 才优先按 management key 错误处理。
- 若这轮改动涉及账号中心化 / 账号设置，还要经 relay 复验 `/v0/management/auth-files/account-settings` 的详情读回；若声称写回链路正常，至少对专用 smoke 账号完成一次“修改备注 / 停用 / 恢复”闭环，并同时核对 relay 与远端直连结果
- 隔离 smoke 日志中不应出现 `local-management-key` Keychain 读写弹框或系统交互；Keychain legacy migration 默认关闭

说明：

- `BASE_URL` 由部署协议决定：
  - 默认稳定基线：`https://10.1.1.201:18317`
  - 若显式关闭 TLS：`http://10.1.1.201:18317`
- 自签名证书 smoke 可以对 `curl` 加 `-k`，但这不是长期接入方案
- 当前仓库已提供 `./scripts/smoke-test-remote-relay.sh`，会默认 build 当前 worktree 的隔离 Debug app，并完成 `stage1(env seed) -> stage2(file-only)` 两阶段 relay smoke；默认还会对专用 smoke 账号复验 `/v0/management/auth-files/account-settings` 详情，并执行“修改备注 / 停用 / 恢复原字段”的写回闭环。实际变更覆盖 `note/disabled`，`proxy_url`、`extra_headers`、`transport_profile`、`tls_profile` 覆盖“不被污染、随恢复 payload 保持原值”；结果汇总在 `build/remote-relay-smoke-script/summary.json`
- 这条脚本不替代 management center 浏览器 smoke；若要验证远端 `management.html`，自签 TLS 仍需显式信任证书或在 Playwright/manual browser smoke 中使用 `ignoreHTTPSErrors`
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
