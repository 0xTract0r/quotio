#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UI_DIR="$ROOT_DIR/third_party/Cli-Proxy-API-Management-Center"
DEFAULT_HOST="127.0.0.1"
DEFAULT_UI_PORT="4173"
ACCOUNT_NAME="local-management-key"

MODE="preview"
UI_HOST="$DEFAULT_HOST"
UI_PORT="$DEFAULT_UI_PORT"
AUTO_OPEN=1
QUOTIO_CONFIG_PATH="${QUOTIO_CONFIG_PATH:-}"
API_BASE="${API_BASE:-}"
MANAGEMENT_KEY="${MANAGEMENT_KEY:-}"
KEYCHAIN_SERVICE="${KEYCHAIN_SERVICE:-}"
RUN_NPM_CI=0
KEEP_STAGING=0

SERVER_PID=""
STAGING_DIR=""
KEY_SOURCE=""
RESOLVED_KEY=""
RESOLVED_API_BASE=""

log() {
  printf '[management-center] %s\n' "$*"
}

die() {
  printf '[management-center] ERROR: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  scripts/start-management-center.sh [options]

Options:
  --mode preview|build     启动方式。preview=构建后本地起静态服务，build=只构建不启动
  --ui-host HOST           本地静态服务监听地址，默认 127.0.0.1
  --ui-port PORT           本地静态服务端口，默认 4173
  --quotio-config PATH     指定 Quotio / CLIProxyAPI config.yaml
  --api-base URL           手工指定 Management API 基础地址，例如 http://127.0.0.1:18317
  --management-key KEY     手工指定 management key
  --keychain-service NAME  手工指定 Keychain service 名称
  --npm-ci                 启动前强制执行 npm ci
  --no-open                不自动打开浏览器
  --keep-staging           保留临时 staging 目录，便于调试
  -h, --help               显示帮助

说明：
  1. 默认优先从 Quotio Keychain 读取 local management key。
  2. 若 Keychain 未命中，则退回读取 config.yaml 中 remote-management.secret-key。
  3. 若 config 里是 bcrypt/hash（例如 $2a$...），脚本无法反推出原始密钥，此时请手工传 --management-key。
EOF
}

cleanup() {
  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  if [[ "$KEEP_STAGING" != "1" ]] && [[ -n "$STAGING_DIR" ]] && [[ -d "$STAGING_DIR" ]]; then
    rm -rf "$STAGING_DIR"
  fi
}

trap cleanup EXIT INT TERM

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

trim_quotes() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  printf '%s' "$value"
}

parse_yaml_scalar() {
  local file="$1"
  local key="$2"
  awk -F':' -v target="$key" '
    $1 == target {
      sub(/^[^:]+:[[:space:]]*/, "", $0)
      print $0
      exit
    }
  ' "$file"
}

parse_remote_secret_key() {
  local file="$1"
  awk '
    /^[[:space:]]*remote-management:[[:space:]]*$/ { in_block=1; next }
    in_block && /^[^[:space:]]/ { in_block=0 }
    in_block && /^[[:space:]]*secret-key:[[:space:]]*/ {
      sub(/^[[:space:]]*secret-key:[[:space:]]*/, "", $0)
      print $0
      exit
    }
  ' "$file"
}

is_bcrypt_value() {
  [[ "${1:-}" =~ ^\$2[aby]\$ ]]
}

choose_latest_quotio_config() {
  local preferred="$HOME/Library/Application Support/Quotio/config.yaml"
  if [[ -f "$preferred" ]]; then
    printf '%s\n' "$preferred"
    return 0
  fi

  local latest=""
  local latest_mtime=0
  while IFS= read -r -d '' candidate; do
    local mtime
    mtime="$(stat -f '%m' "$candidate" 2>/dev/null || echo 0)"
    if (( mtime > latest_mtime )); then
      latest_mtime="$mtime"
      latest="$candidate"
    fi
  done < <(find "$HOME/Library/Application Support" -maxdepth 2 -type f -name config.yaml -path '*/Quotio*/config.yaml' -print0 2>/dev/null)

  if [[ -n "$latest" ]]; then
    printf '%s\n' "$latest"
    return 0
  fi

  return 1
}

derive_keychain_service_from_config() {
  local config_path="$1"
  local app_dir
  app_dir="$(basename "$(dirname "$config_path")")"

  if [[ "$app_dir" == "Quotio" ]]; then
    printf 'dev.quotio.desktop.local-management\n'
    return 0
  fi

  if [[ "$app_dir" == Quotio-* ]]; then
    local suffix="${app_dir#Quotio-}"
    suffix="$(printf '%s' "$suffix" | tr '[:upper:]' '[:lower:]')"
    printf 'dev.quotio.desktop.%s.local-management\n' "$suffix"
    return 0
  fi

  return 1
}

read_keychain_value() {
  local service="$1"
  security find-generic-password -s "$service" -a "$ACCOUNT_NAME" -w 2>/dev/null || true
}

resolve_management_key() {
  local config_path="$1"
  local config_secret=""
  local derived_service=""
  local derived_key=""

  if [[ -n "$MANAGEMENT_KEY" ]]; then
    KEY_SOURCE="arg"
    RESOLVED_KEY="$MANAGEMENT_KEY"
    return 0
  fi

  if [[ -n "$config_path" ]] && [[ -f "$config_path" ]]; then
    config_secret="$(trim_quotes "$(parse_remote_secret_key "$config_path")")"
  fi

  if [[ -n "$KEYCHAIN_SERVICE" ]]; then
    derived_key="$(read_keychain_value "$KEYCHAIN_SERVICE")"
    if [[ -n "$derived_key" ]]; then
      KEY_SOURCE="keychain:$KEYCHAIN_SERVICE"
      RESOLVED_KEY="$derived_key"
      return 0
    fi
  fi

  if [[ -n "$config_path" ]] && derived_service="$(derive_keychain_service_from_config "$config_path")"; then
    derived_key="$(read_keychain_value "$derived_service")"
    if [[ -n "$derived_key" ]]; then
      KEY_SOURCE="keychain:$derived_service"
      KEYCHAIN_SERVICE="$derived_service"
      RESOLVED_KEY="$derived_key"
      return 0
    fi
  fi

  if [[ -n "$config_secret" ]] && ! is_bcrypt_value "$config_secret"; then
    KEY_SOURCE="config:$config_path"
    RESOLVED_KEY="$config_secret"
    return 0
  fi

  if [[ -n "$config_secret" ]] && is_bcrypt_value "$config_secret"; then
    die "config 中的 secret-key 是 bcrypt/hash，无法反推出原始 management key；请手工传 --management-key，或确认 Quotio Keychain 条目可读。"
  fi

  die "未能自动解析 management key；请手工传 --management-key。"
}

resolve_api_base() {
  local config_path="$1"

  if [[ -n "$API_BASE" ]]; then
    RESOLVED_API_BASE="$API_BASE"
    return 0
  fi

  [[ -f "$config_path" ]] || die "找不到 config 文件，且未显式传 --api-base。"

  local raw_host raw_port host port
  raw_host="$(trim_quotes "$(parse_yaml_scalar "$config_path" "host")")"
  raw_port="$(trim_quotes "$(parse_yaml_scalar "$config_path" "port")")"
  host="${raw_host:-127.0.0.1}"
  port="${raw_port:-8317}"

  case "$host" in
    ""|"0.0.0.0"|"::"|"[::]"|"::0")
      host="127.0.0.1"
      ;;
  esac

  RESOLVED_API_BASE="http://${host}:${port}"
}

open_url() {
  local url="$1"
  if [[ "$AUTO_OPEN" != "1" ]]; then
    return 0
  fi

  if command -v open >/dev/null 2>&1; then
    open "$url" >/dev/null 2>&1 || true
    return 0
  fi

  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url" >/dev/null 2>&1 || true
    return 0
  fi
}

ensure_ui_ready() {
  [[ -d "$UI_DIR" ]] || die "子模块目录不存在：$UI_DIR"
  [[ -f "$UI_DIR/package.json" ]] || die "Management Center 子模块未初始化完整：$UI_DIR/package.json 缺失"

  if [[ "$RUN_NPM_CI" == "1" || ! -d "$UI_DIR/node_modules" ]]; then
    log "安装前端依赖"
    npm --prefix "$UI_DIR" ci
  fi
}

build_ui() {
  log "构建 Management Center"
  npm --prefix "$UI_DIR" run build
}

stage_preview_files() {
  local api_base="$1"
  local management_key="$2"
  local build_dir="$UI_DIR/dist"
  [[ -f "$build_dir/index.html" ]] || die "构建产物缺失：$build_dir/index.html"

  STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/management-center-preview.XXXXXX")"
  cp "$build_dir/index.html" "$STAGING_DIR/index.html"
  cp "$build_dir/index.html" "$STAGING_DIR/management.html"

  local api_base_json key_json
  api_base_json="$(printf '%s' "$api_base" | json_escape)"
  key_json="$(printf '%s' "$management_key" | json_escape)"

  cat > "$STAGING_DIR/bootstrap.html" <<EOF
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Management Center Bootstrap</title>
  </head>
  <body>
    <p>Bootstrapping Management Center...</p>
    <script>
      localStorage.setItem('apiBase', ${api_base_json});
      localStorage.setItem('managementKey', ${key_json});
      localStorage.setItem('isLoggedIn', 'true');
      window.location.replace('/management.html');
    </script>
  </body>
</html>
EOF
}

start_preview_server() {
  local url="http://${UI_HOST}:${UI_PORT}/bootstrap.html"
  log "本地预览目录：$STAGING_DIR"
  log "启动地址：$url"
  python3 -m http.server "$UI_PORT" --bind "$UI_HOST" --directory "$STAGING_DIR" &
  SERVER_PID="$!"
  sleep 1
  open_url "$url"
  wait "$SERVER_PID"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --ui-host)
      UI_HOST="${2:-}"
      shift 2
      ;;
    --ui-port)
      UI_PORT="${2:-}"
      shift 2
      ;;
    --quotio-config)
      QUOTIO_CONFIG_PATH="${2:-}"
      shift 2
      ;;
    --api-base)
      API_BASE="${2:-}"
      shift 2
      ;;
    --management-key)
      MANAGEMENT_KEY="${2:-}"
      shift 2
      ;;
    --keychain-service)
      KEYCHAIN_SERVICE="${2:-}"
      shift 2
      ;;
    --npm-ci)
      RUN_NPM_CI=1
      shift
      ;;
    --no-open)
      AUTO_OPEN=0
      shift
      ;;
    --keep-staging)
      KEEP_STAGING=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "未知参数：$1"
      ;;
  esac
done

case "$MODE" in
  preview|build)
    ;;
  *)
    die "--mode 只支持 preview 或 build"
    ;;
esac

if [[ -z "$QUOTIO_CONFIG_PATH" ]]; then
  QUOTIO_CONFIG_PATH="$(choose_latest_quotio_config || true)"
fi

if [[ -n "$QUOTIO_CONFIG_PATH" && ! -f "$QUOTIO_CONFIG_PATH" ]]; then
  die "指定的 Quotio config 不存在：$QUOTIO_CONFIG_PATH"
fi

resolve_management_key "${QUOTIO_CONFIG_PATH:-}"
resolve_api_base "${QUOTIO_CONFIG_PATH:-}"

log "UI 目录：$UI_DIR"
if [[ -n "$QUOTIO_CONFIG_PATH" ]]; then
  log "Quotio config：$QUOTIO_CONFIG_PATH"
fi
log "Management API：$RESOLVED_API_BASE"
log "Management key 来源：$KEY_SOURCE"
if [[ -n "$KEYCHAIN_SERVICE" ]]; then
  log "Keychain service：$KEYCHAIN_SERVICE"
fi

ensure_ui_ready
build_ui

if [[ "$MODE" == "build" ]]; then
  log "构建完成：$UI_DIR/dist/index.html"
  exit 0
fi

stage_preview_files "$RESOLVED_API_BASE" "$RESOLVED_KEY"
start_preview_server
