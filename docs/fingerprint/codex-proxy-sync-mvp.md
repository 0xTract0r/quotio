# Codex Proxy 指纹同步报告 MVP

最后更新：2026-04-30

## 定位

`scripts/sync-codex-proxy-fingerprint.py` 仍是只读同步 / 报告脚本，不直接修改运行配置。T059 之后，运行时 core 另有一条受限的自动同步路径：`managed-header-profile.online-update=true` 时，Codex 默认 `codex_proxy_compatible_v1` 会从 allowlist 的 `icebear0828/codex-proxy` 公共配置读取 coherent Desktop-like managed-header bundle，并把变化写入账号 `managed_header_state`。

默认输出位置：

```bash
python3 scripts/sync-codex-proxy-fingerprint.py
# build/codex-proxy-fingerprint/report-<timestamp>.json
```

常用参数：

```bash
python3 scripts/sync-codex-proxy-fingerprint.py --list-sources
python3 scripts/sync-codex-proxy-fingerprint.py --output build/codex-proxy-fingerprint/report.json
python3 scripts/sync-codex-proxy-fingerprint.py --allow-partial
```

## Allowlist 来源

脚本只访问以下来源：

- `icebear0828/codex-proxy` raw `config/default.yaml`
- `icebear0828/codex-proxy` raw `config/fingerprint.yaml`
- `icebear0828/codex-proxy` raw `native/Cargo.toml`
- `icebear0828/codex-proxy` raw `src/fingerprint/manager.ts`
- `openai/codex` raw `codex-rs/login/src/auth/default_client.rs`
- npm registry `@openai/codex/latest`

报告会记录每个来源的 `source_url`、`retrieved_at`、`sha256`、字节数与已解析字段。网络失败会返回清晰错误；默认必需来源失败时退出非零，`--allow-partial` 只用于生成部分证据报告。

## 报告字段

报告至少覆盖：

- `codex_proxy`：`app_version`、`build_number`、`chromium_version`、`originator`、`user_agent_template`、`header_order`、`default_headers`
- `codex_proxy.native`：`reqwest` 与 `rustls` 版本、`reqwest` features
- `codex_first_party`：Codex 第一方 originator、residency header、公开源码中可核对的客户端字段
- `npm_openai_codex`：npm latest version
- `local_policy`：当前本地 Codex managed header 策略的可安全静态读取摘要
- `diffs`：本地策略与 `codex-proxy` 公开配置之间的差异位

## 安全边界

禁止把报告输出直接当成生产配置或自动升级输入：

- 不自动修改生产配置、auth 文件或远端 runtime
- 不读取密钥、OAuth token、cookie、`~/.cli-proxy-api` 或 `~/Library/Application Support/Quotio`
- 不执行上游脚本
- 不下载、构建、安装或运行 `codex-proxy` native 二进制
- 不复制 Cloudflare cookie 绕过、anti-detection、self-update 或 ToS 自担风险逻辑

T058 后 `codex-proxy` 是 Codex 方向的主实现参考，而不是旁路材料：CLIProxyAPIPlus 默认 Codex profile 已迁到 `codex_proxy_compatible_v1`，managed headers 采用 Codex Desktop-like bundle，Go transport 吸收 per-account/per-proxy cache、ALPN/HTTP1.1 控制和 session 隔离。仍禁止搬入 cookie replay、token-cookie 采集和 anti-detection 默认能力。

T060 远端闭环已验证当前策略进入远端运行态：`10.1.1.201` safe deploy manifest 为 `build/remote-deploy-safety/20260509T083141Z/manifest.env`；远端 Codex 账号设置返回 `completeness=online-coherent-bundle`、`source=community:codex-proxy`、`policy_version=codex-managed/v2`、`runtime_profile_id=tls_profile_id=codex_proxy_compatible_v1`；controlled echo runtime probe 返回 `managed_header_policy=codex-managed/v2`、`managed_header_source=community:codex-proxy`、`managed_header_version=26.318.11754`。这仍是 core-mediated 证据，不是 provider 官方 attestation。

## 同步策略

### Core 自动同步

Core 自动同步只访问：

- `https://raw.githubusercontent.com/icebear0828/codex-proxy/master/config/default.yaml`
- `https://raw.githubusercontent.com/icebear0828/codex-proxy/master/config/fingerprint.yaml`

默认频率由 `managed-header-profile.cache-ttl-seconds` 控制，当前默认 `6 小时`；单次 fetch timeout 默认 `2 秒`，最大 `10 秒`。触发方式是 lazy sync：账号列表、账号设置读取或账号设置写入时解析策略并持久化；不是后台一直轮询。

只有当 `originator` / `app_version` 等关键字段能组成 coherent bundle 时，core 才升级 Codex Desktop-like `User-Agent` / `Version` / Chromium client hints / fetch headers。公共来源不可用时保留本地静态 `community:codex-proxy` fallback，不把 npm `@openai/codex` CLI 版本混进 Desktop-like UA。

`managed_header_state.current` 会返回：

- `source=community:codex-proxy`
- `checked_at=<UTC time>`（在线同步成功时）
- `completeness=online-coherent-bundle`

真实变化会进入 `managed_header_state.history`，保留升级前后的 `versioned_capabilities`、`stable_identity`、`runtime_fingerprint`、source 和 changed fields。

### 报告脚本

允许同步：

- 公开版本号与 app metadata
- header 名称、顺序、默认值等可审阅策略数据
- native 依赖版本提示
- 官方 Codex 默认 originator 这类第一方源码事实

不能仅凭 npm 版本或 `codex-proxy` 配置推导：

- `Originator` / User-Agent product 的稳定身份变化
- 平台、终端、OS / arch 等 runtime fingerprint
- raw TLS / JA3 / JA4 / HTTP2 SETTINGS parity
- residency、beta、cookie 或 Cloudflare 相关绕过能力

如果要从报告进入更大范围实现变更，必须另开实现任务和专用 worktree，先做本地 dev / 远端 provider-facing 验证，再讨论生产推广。

## TLS 证据类型

`third_party/CLIProxyAPIPlus/cmd/tls_transport_probe` 现在区分三类证据：

- `echo-host`：请求真实到达 TLS echo 服务，可读取 echo 服务返回的 TLS / JA3 / JA4 / HTTP2 字段，但 `provider_host_claim=not-claimed`，不能证明 provider host 或 provider SNI。
- `synthetic-provider-sni`：本地启动临时 TLS 捕获 listener，核心侧复用同一 runtime transport / TLS profile builder，并把请求 URL / SNI 设置为 provider host（例如 `api.anthropic.com`、`chatgpt.com`）；捕获本地 ClientHello、JA3、JA4、ALPN 和 HTTP2 SETTINGS，不需要 root / tcpdump / MITM，也不读取 token。本地 diagnostic JA4 只能说明当前 builder 在本地捕获器中会发出什么，不是权威 canonical provider-observed JA4。
- `provider-observed`：真实 provider-facing 网络侧观测，仍只能由受控 MITM、pcap/tcpdump、provider echo、provider-side 日志或等价一手证据产生；本地 synthetic capture 不能冒充这一类。

Provider-observed TLS 的执行门槛和安全 helper 见 `docs/fingerprint/provider-observed-tls-evidence.md`。当前结论是：不 root / 不 MITM / 不发送 Authorization 的条件下，只能安全做到 provider-host handshake-only 或 dry-run 计划；这仍不能证明账号 runtime 请求的 provider-observed HTTP/2 SETTINGS 或完整 TLS parity。

生成本地 provider-SNI 证据示例：

```bash
cd third_party/CLIProxyAPIPlus
GOTOOLCHAIN=auto go run ./cmd/tls_transport_probe -mode provider-sni -out ../../build/t029-raw-tls
```

该命令会生成类似：

- `build/t029-raw-tls/provider-sni-claude-utls.json`
- `build/t029-raw-tls/provider-sni-codex-go.json`

这类证据能证明“当前 core transport/profile builder 在 provider SNI 下会发出怎样的本地 ClientHello 与 HTTP2 SETTINGS”；不能证明 provider 已实际观测到同一 JA3 / JA4，也不能证明 Codex Desktop rustls native parity。

## Claude 边界

当前没有找到可像 `codex-proxy` 一样直接搬入 Claude Code runtime TLS/native addon 的同级项目；但 `ultraworkers/claw-code` 提供了 Claude CLI 方向的 Rust `reqwest` + `rustls-tls` 客户端和 proxy model，可作为 Claude 默认 profile 的社区来源。不要把 Codex Desktop / Web / Rust native 指纹改名后套到 Claude runtime。

## 未覆盖风险

本 MVP 只输出静态来源报告，不能证明：

- `codex-proxy` 当前 header 在真实上游仍被接受
- Quotio / CLIProxyAPIPlus 与 Codex Desktop raw TLS 完全等价
- provider-facing 请求已使用报告中的字段
- 未来 `codex-proxy` 或 `openai/codex` 文件路径不会调整
