#!/usr/bin/env bash
set -euo pipefail

REMOTE_HOST="${REMOTE_HOST:?REMOTE_HOST is required, e.g. wisedata@10.1.1.201}"
MANAGEMENT_PASSWORD="${MANAGEMENT_PASSWORD:?MANAGEMENT_PASSWORD is required}"

DEPLOY_DIR="${DEPLOY_DIR:-/home/wisedata/deploy/cliproxyapi-plus}"
API_PORT="${API_PORT:-18317}"
BIND_HOST="${BIND_HOST:-}"
SERVER_HOST_IP="${SERVER_HOST_IP:-${BIND_HOST}}"
CONTAINER_NAME="${CONTAINER_NAME:-cliproxyapi-plus-remote}"
IMAGE_NAME="${IMAGE_NAME:-cliproxyapi-plus:linux-server}"
BUILD_STRATEGY="${BUILD_STRATEGY:-remote}"
IMAGE_PLATFORM="${IMAGE_PLATFORM:-linux/amd64}"
CONTAINER_UID_GID="${CONTAINER_UID_GID:-1000:1000}"
TZ_VALUE="${TZ_VALUE:-Asia/Shanghai}"
SYNC_AUTH_DIR="${SYNC_AUTH_DIR:-1}"
REMOTE_DOCKER_BUILDKIT="${REMOTE_DOCKER_BUILDKIT:-}"
REMOTE_COMPOSE_DOCKER_CLI_BUILD="${REMOTE_COMPOSE_DOCKER_CLI_BUILD:-}"
CONTAINER_DNS_SERVERS="${CONTAINER_DNS_SERVERS:-}"
SERVER_TLS_CURL_INSECURE="${SERVER_TLS_CURL_INSECURE:-0}"
ALLOW_TLS_DOWNGRADE="${ALLOW_TLS_DOWNGRADE:-0}"
SERVER_TLS_GENERATE_REMOTE="${SERVER_TLS_GENERATE_REMOTE:-0}"
SERVER_TLS_GENERATE_REMOTE_OVERWRITE="${SERVER_TLS_GENERATE_REMOTE_OVERWRITE:-0}"
SERVER_TLS_GENERATE_REMOTE_DAYS="${SERVER_TLS_GENERATE_REMOTE_DAYS:-365}"
SERVER_TLS_GENERATE_REMOTE_HOST_IP="${SERVER_TLS_GENERATE_REMOTE_HOST_IP:-${SERVER_HOST_IP}}"
SERVER_TLS_GENERATE_REMOTE_CN="${SERVER_TLS_GENERATE_REMOTE_CN:-${SERVER_TLS_GENERATE_REMOTE_HOST_IP}}"

SERVER_PROXY_URL_SET=0
if [[ "${SERVER_PROXY_URL+x}" == "x" ]]; then
  SERVER_PROXY_URL_SET=1
else
  SERVER_PROXY_URL=""
fi

SERVER_TLS_ENABLE_SET=0
if [[ "${SERVER_TLS_ENABLE+x}" == "x" ]]; then
  SERVER_TLS_ENABLE_SET=1
else
  SERVER_TLS_ENABLE=""
fi
SERVER_TLS_CERT_FILE="${SERVER_TLS_CERT_FILE-}"
SERVER_TLS_KEY_FILE="${SERVER_TLS_KEY_FILE-}"

if [[ -n "${QUOTIO_SOURCE_ROOT:-}" ]]; then
  SOURCE_ROOT="${QUOTIO_SOURCE_ROOT}"
else
  SOURCE_ROOT="$(git rev-parse --show-toplevel)"
fi

CORE_SRC="${SOURCE_ROOT}/third_party/CLIProxyAPIPlus"
MGMT_SRC="${SOURCE_ROOT}/third_party/Cli-Proxy-API-Management-Center"
REMOTE_TLS_GENERATOR_SCRIPT="${SOURCE_ROOT}/scripts/generate-cliproxy-self-signed-cert-remote.sh"
LOCAL_CONFIG_PATH="${LOCAL_CONFIG_PATH:-$HOME/Library/Application Support/Quotio/config.yaml}"
SOURCE_AUTH_DIR_PATH="${SOURCE_AUTH_DIR_PATH:-$HOME/.cli-proxy-api}"
PROXY_API_KEY="${PROXY_API_KEY:-}"

validate_toggle_flag() {
  local name="$1"
  local value="$2"
  case "${value}" in
    0|1) ;;
    *)
      echo "${name} must be 0 or 1, got: ${value}" >&2
      exit 1
      ;;
  esac
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_cmd ssh
require_cmd rsync
require_cmd npm
require_cmd python3
require_cmd curl
if [[ "${BUILD_STRATEGY}" == "local-load" ]]; then
  require_cmd docker
fi

[[ -d "${CORE_SRC}" ]] || {
  echo "CLIProxyAPIPlus source not found: ${CORE_SRC}" >&2
  exit 1
}

[[ -d "${MGMT_SRC}" ]] || {
  echo "Management Center source not found: ${MGMT_SRC}" >&2
  exit 1
}

[[ -f "${LOCAL_CONFIG_PATH}" ]] || {
  echo "Local config not found: ${LOCAL_CONFIG_PATH}" >&2
  exit 1
}

if [[ "${SYNC_AUTH_DIR}" == "1" && ! -d "${SOURCE_AUTH_DIR_PATH}" ]]; then
  echo "Auth dir not found: ${SOURCE_AUTH_DIR_PATH}" >&2
  exit 1
fi

validate_toggle_flag "SERVER_TLS_CURL_INSECURE" "${SERVER_TLS_CURL_INSECURE}"
validate_toggle_flag "ALLOW_TLS_DOWNGRADE" "${ALLOW_TLS_DOWNGRADE}"
validate_toggle_flag "SERVER_TLS_GENERATE_REMOTE" "${SERVER_TLS_GENERATE_REMOTE}"
validate_toggle_flag "SERVER_TLS_GENERATE_REMOTE_OVERWRITE" "${SERVER_TLS_GENERATE_REMOTE_OVERWRITE}"

if [[ -n "${BIND_HOST}" ]]; then
  PORT_MAPPING="${BIND_HOST}:${API_PORT}:${API_PORT}"
else
  PORT_MAPPING="${API_PORT}:${API_PORT}"
fi

TLS_CERT_RUNTIME_NAME="tls.crt"
TLS_KEY_RUNTIME_NAME="tls.key"
TLS_CERT_CONTAINER_PATH=""
TLS_KEY_CONTAINER_PATH=""
USE_REMOTE_TLS_ASSETS=0
REMOTE_CONFIG_PRESENT=0
REMOTE_PROXY_URL=""
REMOTE_TLS_ENABLE="0"
REMOTE_TLS_CERT_PATH=""
REMOTE_TLS_KEY_PATH=""
REMOTE_TLS_CERT_PRESENT=0
REMOTE_TLS_KEY_PRESENT=0

read_remote_runtime_state() {
  REMOTE_CONFIG_PRESENT=0
  REMOTE_PROXY_URL=""
  REMOTE_TLS_ENABLE="0"
  REMOTE_TLS_CERT_PATH=""
  REMOTE_TLS_KEY_PATH=""

  local config_raw=""
  config_raw="$(ssh "${REMOTE_HOST}" "if [ -f '${DEPLOY_DIR}/runtime/config/config.yaml' ]; then cat '${DEPLOY_DIR}/runtime/config/config.yaml'; fi")"
  if [[ -n "${config_raw}" ]]; then
    REMOTE_CONFIG_PRESENT=1
    local parsed
    parsed="$(REMOTE_CONFIG_RAW="${config_raw}" python3 <<'PY'
import os
import yaml

data = yaml.safe_load(os.environ["REMOTE_CONFIG_RAW"]) or {}
tls = data.get("tls") or {}
print((data.get("proxy-url") or "").replace("\n", " "))
print("1" if tls.get("enable") else "0")
print((tls.get("cert") or "").replace("\n", " "))
print((tls.get("key") or "").replace("\n", " "))
PY
)"
    REMOTE_PROXY_URL="$(printf '%s\n' "${parsed}" | sed -n '1p')"
    REMOTE_TLS_ENABLE="$(printf '%s\n' "${parsed}" | sed -n '2p')"
    REMOTE_TLS_CERT_PATH="$(printf '%s\n' "${parsed}" | sed -n '3p')"
    REMOTE_TLS_KEY_PATH="$(printf '%s\n' "${parsed}" | sed -n '4p')"
  fi

  REMOTE_TLS_CERT_PRESENT="$(ssh "${REMOTE_HOST}" "if [ -s '${DEPLOY_DIR}/runtime/tls/server.crt' ]; then echo 1; else echo 0; fi")"
  REMOTE_TLS_KEY_PRESENT="$(ssh "${REMOTE_HOST}" "if [ -s '${DEPLOY_DIR}/runtime/tls/server.key' ]; then echo 1; else echo 0; fi")"
}

generate_remote_tls_assets() {
  [[ -f "${REMOTE_TLS_GENERATOR_SCRIPT}" ]] || {
    echo "Remote TLS generator script not found: ${REMOTE_TLS_GENERATOR_SCRIPT}" >&2
    exit 1
  }

  REMOTE_HOST="${REMOTE_HOST}" \
  DEPLOY_DIR="${DEPLOY_DIR}" \
  HOST_IP="${SERVER_TLS_GENERATE_REMOTE_HOST_IP}" \
  COMMON_NAME="${SERVER_TLS_GENERATE_REMOTE_CN}" \
  DAYS="${SERVER_TLS_GENERATE_REMOTE_DAYS}" \
  OVERWRITE="${SERVER_TLS_GENERATE_REMOTE_OVERWRITE}" \
  bash "${REMOTE_TLS_GENERATOR_SCRIPT}"
}

read_remote_runtime_state

if [[ "${SERVER_PROXY_URL_SET}" == "1" ]]; then
  if [[ -n "${SERVER_PROXY_URL}" ]]; then
    echo "[info] Using server proxy URL: ${SERVER_PROXY_URL}"
  else
    echo "[warn] SERVER_PROXY_URL was explicitly set empty; proxy-url will be cleared"
  fi
elif [[ "${REMOTE_CONFIG_PRESENT}" == "1" ]]; then
  SERVER_PROXY_URL="${REMOTE_PROXY_URL}"
  if [[ -n "${SERVER_PROXY_URL}" ]]; then
    echo "[info] Preserving remote proxy URL: ${SERVER_PROXY_URL}"
  else
    echo "[info] Preserving empty remote proxy-url"
  fi
else
  echo "[info] SERVER_PROXY_URL not set and no remote config found; proxy-url will be empty"
fi

if [[ "${SERVER_TLS_ENABLE_SET}" != "1" ]]; then
  if [[ -n "${SERVER_TLS_CERT_FILE}" || -n "${SERVER_TLS_KEY_FILE}" ]]; then
    SERVER_TLS_ENABLE="1"
    echo "[info] Inferred SERVER_TLS_ENABLE=1 because TLS file paths were provided"
  elif [[ "${REMOTE_CONFIG_PRESENT}" == "1" ]]; then
    SERVER_TLS_ENABLE="${REMOTE_TLS_ENABLE}"
    echo "[info] Preserving remote TLS enable=${SERVER_TLS_ENABLE}"
  else
    SERVER_TLS_ENABLE="0"
    echo "[info] SERVER_TLS_ENABLE not set and no remote config found; defaulting to HTTP"
  fi
fi

if [[ "${SERVER_TLS_GENERATE_REMOTE}" == "1" ]]; then
  [[ -n "${SERVER_TLS_GENERATE_REMOTE_HOST_IP}" ]] || {
    echo "SERVER_TLS_GENERATE_REMOTE=1 requires SERVER_TLS_GENERATE_REMOTE_HOST_IP or SERVER_HOST_IP" >&2
    exit 1
  }
  if [[ ! "${SERVER_TLS_GENERATE_REMOTE_DAYS}" =~ ^[0-9]+$ ]] || (( SERVER_TLS_GENERATE_REMOTE_DAYS <= 0 )); then
    echo "SERVER_TLS_GENERATE_REMOTE_DAYS must be a positive integer, got: ${SERVER_TLS_GENERATE_REMOTE_DAYS}" >&2
    exit 1
  fi
  [[ -z "${SERVER_TLS_CERT_FILE}" && -z "${SERVER_TLS_KEY_FILE}" ]] || {
    echo "SERVER_TLS_GENERATE_REMOTE=1 cannot be combined with SERVER_TLS_CERT_FILE/SERVER_TLS_KEY_FILE" >&2
    exit 1
  }
  if [[ "${SERVER_TLS_ENABLE_SET}" == "1" && "${SERVER_TLS_ENABLE}" != "1" ]]; then
    echo "SERVER_TLS_GENERATE_REMOTE=1 requires SERVER_TLS_ENABLE=1" >&2
    exit 1
  fi
  if [[ "${SERVER_TLS_ENABLE}" != "1" ]]; then
    SERVER_TLS_ENABLE="1"
    echo "[info] Inferred SERVER_TLS_ENABLE=1 because SERVER_TLS_GENERATE_REMOTE=1"
  fi
fi

validate_toggle_flag "SERVER_TLS_ENABLE" "${SERVER_TLS_ENABLE}"

if [[ "${SERVER_TLS_ENABLE}" == "0" && "${REMOTE_TLS_ENABLE}" == "1" && "${ALLOW_TLS_DOWNGRADE}" != "1" ]]; then
  echo "Refusing to downgrade remote TLS to HTTP without ALLOW_TLS_DOWNGRADE=1" >&2
  exit 1
fi

if [[ "${SERVER_TLS_GENERATE_REMOTE}" == "1" ]]; then
  echo "[info] Explicit remote TLS generation enabled; generating a self-signed cert directly on ${REMOTE_HOST}"
  generate_remote_tls_assets
  read_remote_runtime_state
fi

if [[ "${SERVER_TLS_ENABLE}" == "1" ]]; then
  if [[ -n "${SERVER_TLS_CERT_FILE}" || -n "${SERVER_TLS_KEY_FILE}" ]]; then
    [[ -n "${SERVER_TLS_CERT_FILE}" ]] || {
      echo "SERVER_TLS_CERT_FILE is required when SERVER_TLS_ENABLE=1" >&2
      exit 1
    }
    [[ -n "${SERVER_TLS_KEY_FILE}" ]] || {
      echo "SERVER_TLS_KEY_FILE is required when SERVER_TLS_ENABLE=1" >&2
      exit 1
    }
    [[ "${SERVER_TLS_CERT_FILE}" = /* ]] || {
      echo "SERVER_TLS_CERT_FILE must be an absolute path: ${SERVER_TLS_CERT_FILE}" >&2
      exit 1
    }
    [[ "${SERVER_TLS_KEY_FILE}" = /* ]] || {
      echo "SERVER_TLS_KEY_FILE must be an absolute path: ${SERVER_TLS_KEY_FILE}" >&2
      exit 1
    }
    [[ -f "${SERVER_TLS_CERT_FILE}" ]] || {
      echo "TLS certificate file not found: ${SERVER_TLS_CERT_FILE}" >&2
      exit 1
    }
    [[ -f "${SERVER_TLS_KEY_FILE}" ]] || {
      echo "TLS private key file not found: ${SERVER_TLS_KEY_FILE}" >&2
      exit 1
    }
  elif [[ "${REMOTE_TLS_CERT_PRESENT}" == "1" && "${REMOTE_TLS_KEY_PRESENT}" == "1" ]]; then
    USE_REMOTE_TLS_ASSETS=1
    echo "[info] Preserving remote TLS certificate/key in place at ${DEPLOY_DIR}/runtime/tls"
  else
    echo "SERVER_TLS_ENABLE=1 but no local TLS files were provided and no reusable remote TLS files exist" >&2
    exit 1
  fi
  TLS_CERT_CONTAINER_PATH="/CLIProxyAPI/tls/server.crt"
  TLS_KEY_CONTAINER_PATH="/CLIProxyAPI/tls/server.key"
  echo "[info] HTTPS enabled; runtime cert/key will be mounted from runtime/tls"
else
  echo "[info] HTTPS disabled; service will remain on HTTP"
fi

BASE_SCHEME="http"
if [[ "${SERVER_TLS_ENABLE}" == "1" ]]; then
  BASE_SCHEME="https"
fi
BASE_URL="${BASE_SCHEME}://${SERVER_HOST_IP}:${API_PORT}"

CURL_ARGS=(-fsS)
if [[ "${SERVER_TLS_ENABLE}" == "1" && "${SERVER_TLS_CURL_INSECURE}" == "1" ]]; then
  CURL_ARGS+=(-k)
  echo "[info] curl smoke verification will use -k (self-signed mode)"
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "[1/6] Building Management Center single-file asset"
npm --prefix "${MGMT_SRC}" ci
npm --prefix "${MGMT_SRC}" run build

mkdir -p \
  "${TMP_DIR}/source" \
  "${TMP_DIR}/runtime/config" \
  "${TMP_DIR}/runtime/logs" \
  "${TMP_DIR}/runtime/static" \
  "${TMP_DIR}/runtime/tls"

echo "[2/6] Preparing deployment bundle"
rsync -a --delete --exclude '.git' --exclude 'node_modules' \
  "${CORE_SRC}/" "${TMP_DIR}/source/CLIProxyAPIPlus/"
cp "${MGMT_SRC}/dist/index.html" "${TMP_DIR}/runtime/static/management.html"

if [[ "${SERVER_TLS_ENABLE}" == "1" ]]; then
  if [[ "${USE_REMOTE_TLS_ASSETS}" == "1" ]]; then
    ssh "${REMOTE_HOST}" "cat '${DEPLOY_DIR}/runtime/tls/server.crt'" > "${TMP_DIR}/runtime/tls/server.crt"
    ssh "${REMOTE_HOST}" "cat '${DEPLOY_DIR}/runtime/tls/server.key'" > "${TMP_DIR}/runtime/tls/server.key"
    chmod 600 "${TMP_DIR}/runtime/tls/server.crt" "${TMP_DIR}/runtime/tls/server.key"
  else
    cp "${SERVER_TLS_CERT_FILE}" "${TMP_DIR}/runtime/tls/server.crt"
    cp "${SERVER_TLS_KEY_FILE}" "${TMP_DIR}/runtime/tls/server.key"
    chmod 600 "${TMP_DIR}/runtime/tls/server.crt" "${TMP_DIR}/runtime/tls/server.key"
  fi
fi

if [[ "${SYNC_AUTH_DIR}" == "1" ]]; then
  mkdir -p "${TMP_DIR}/runtime/auth"
  rsync -a --delete \
    --include '*/' \
    --include '*.json' \
    --exclude '*' \
    "${SOURCE_AUTH_DIR_PATH}/" "${TMP_DIR}/runtime/auth/"
fi

export LOCAL_CONFIG_PATH
export OUTPUT_CONFIG_PATH="${TMP_DIR}/runtime/config/config.yaml"
export PROXY_API_KEY
export API_PORT
export SERVER_PROXY_URL
export SERVER_TLS_ENABLE
export SERVER_TLS_CERT_CONTAINER_PATH="${TLS_CERT_CONTAINER_PATH}"
export SERVER_TLS_KEY_CONTAINER_PATH="${TLS_KEY_CONTAINER_PATH}"
python3 <<'PY'
import os
import pathlib
import yaml

config_path = pathlib.Path(os.environ["LOCAL_CONFIG_PATH"]).expanduser()
output_path = pathlib.Path(os.environ["OUTPUT_CONFIG_PATH"])
api_port = int(os.environ["API_PORT"])
override_api_key = os.environ.get("PROXY_API_KEY", "").strip()
server_proxy_url = os.environ.get("SERVER_PROXY_URL", "").strip()
server_tls_enable = os.environ.get("SERVER_TLS_ENABLE", "").strip() == "1"
tls_cert_container_path = os.environ.get("SERVER_TLS_CERT_CONTAINER_PATH", "").strip()
tls_key_container_path = os.environ.get("SERVER_TLS_KEY_CONTAINER_PATH", "").strip()

with config_path.open("r", encoding="utf-8") as f:
    data = yaml.safe_load(f) or {}

data["host"] = ""
data["port"] = api_port
data["auth-dir"] = "/CLIProxyAPI/auth"
data["proxy-url"] = server_proxy_url
data["tls"] = {
    "enable": server_tls_enable,
    "cert": tls_cert_container_path if server_tls_enable else "",
    "key": tls_key_container_path if server_tls_enable else "",
}

remote = dict(data.get("remote-management") or {})
remote["allow-remote"] = True
remote["secret-key"] = ""
remote["disable-control-panel"] = False
remote["disable-auto-update-panel"] = True
data["remote-management"] = remote

pprof = dict(data.get("pprof") or {})
pprof["enable"] = False
pprof["addr"] = "127.0.0.1:8316"
data["pprof"] = pprof

data["logging-to-file"] = True
data["logs-max-total-size-mb"] = max(int(data.get("logs-max-total-size-mb") or 0), 512)
data["usage-statistics-enabled"] = True

if override_api_key:
    data["api-keys"] = [override_api_key]

output_path.parent.mkdir(parents=True, exist_ok=True)
with output_path.open("w", encoding="utf-8") as f:
    yaml.safe_dump(data, f, allow_unicode=False, sort_keys=False)
PY

cat > "${TMP_DIR}/runtime/secrets.env" <<EOF
MANAGEMENT_PASSWORD=${MANAGEMENT_PASSWORD}
EOF

if [[ "${BUILD_STRATEGY}" == "local-load" ]]; then
  BUILD_BLOCK=""
else
  BUILD_BLOCK=$'    build:\n      context: ./source/CLIProxyAPIPlus\n      dockerfile: Dockerfile'
fi

DNS_BLOCK=""
if [[ -n "${CONTAINER_DNS_SERVERS}" ]]; then
  IFS=',' read -r -a dns_servers <<< "${CONTAINER_DNS_SERVERS}"
  DNS_BLOCK=$'    dns:\n'
  for dns_server in "${dns_servers[@]}"; do
    dns_server="$(printf '%s' "${dns_server}" | xargs)"
    if [[ -n "${dns_server}" ]]; then
      DNS_BLOCK+="      - ${dns_server}"$'\n'
    fi
  done
  if [[ "${DNS_BLOCK}" == $'    dns:\n' ]]; then
    DNS_BLOCK=""
  fi
fi

cat > "${TMP_DIR}/compose.yaml" <<EOF
services:
  cliproxyapi:
    container_name: ${CONTAINER_NAME}
    image: ${IMAGE_NAME}
${BUILD_BLOCK}
    command: ["./CLIProxyAPIPlus", "-config", "/CLIProxyAPI/config/config.yaml"]
    env_file:
      - ./runtime/secrets.env
    environment:
      TZ: ${TZ_VALUE}
      MANAGEMENT_STATIC_PATH: /CLIProxyAPI/static
    user: "${CONTAINER_UID_GID}"
${DNS_BLOCK}    ports:
      - "${PORT_MAPPING}"
    volumes:
      - ./runtime/config:/CLIProxyAPI/config
      - ./runtime/auth:/CLIProxyAPI/auth
      - ./runtime/logs:/CLIProxyAPI/logs
      - ./runtime/static:/CLIProxyAPI/static
      - ./runtime/tls:/CLIProxyAPI/tls:ro
    read_only: true
    tmpfs:
      - /tmp:size=64m,mode=1777
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    healthcheck:
      disable: true
    restart: unless-stopped
    stop_grace_period: 20s
    logging:
      driver: json-file
      options:
        max-size: "20m"
        max-file: "5"
EOF

echo "[3/6] Syncing bundle to ${REMOTE_HOST}:${DEPLOY_DIR}"
ssh "${REMOTE_HOST}" "mkdir -p '${DEPLOY_DIR}'"
RSYNC_ARGS=(-az --delete)
if [[ "${SYNC_AUTH_DIR}" != "1" ]]; then
  RSYNC_ARGS+=(--filter='P runtime/auth/' --filter='P runtime/auth/***')
fi
RSYNC_ARGS+=(--filter='P backups/' --filter='P backups/***')
if [[ -z "${SERVER_TLS_CERT_FILE}" && -z "${SERVER_TLS_KEY_FILE}" ]]; then
  RSYNC_ARGS+=(--filter='P runtime/tls/' --filter='P runtime/tls/***')
fi
RSYNC_ARGS+=(
  --filter='P runtime/config/.usage-statistics.json'
  --filter='P runtime/config/.usage-statistics.json.tmp'
)
rsync "${RSYNC_ARGS[@]}" "${TMP_DIR}/" "${REMOTE_HOST}:${DEPLOY_DIR}/"

REMOTE_COMPOSE_CMD="sudo docker compose"
if [[ -n "${REMOTE_DOCKER_BUILDKIT}" || -n "${REMOTE_COMPOSE_DOCKER_CLI_BUILD}" ]]; then
  REMOTE_COMPOSE_CMD="sudo env"
  if [[ -n "${REMOTE_DOCKER_BUILDKIT}" ]]; then
    REMOTE_COMPOSE_CMD+=" DOCKER_BUILDKIT=${REMOTE_DOCKER_BUILDKIT}"
  fi
  if [[ -n "${REMOTE_COMPOSE_DOCKER_CLI_BUILD}" ]]; then
    REMOTE_COMPOSE_CMD+=" COMPOSE_DOCKER_CLI_BUILD=${REMOTE_COMPOSE_DOCKER_CLI_BUILD}"
  fi
  REMOTE_COMPOSE_CMD+=" docker compose"
fi

if [[ "${BUILD_STRATEGY}" == "local-load" ]]; then
  echo "[4/6] Building local image ${IMAGE_NAME} (${IMAGE_PLATFORM})"
  docker buildx build \
    --platform "${IMAGE_PLATFORM}" \
    --load \
    -t "${IMAGE_NAME}" \
    "${TMP_DIR}/source/CLIProxyAPIPlus"

  echo "[5/6] Loading image on remote host"
  docker save "${IMAGE_NAME}" | ssh "${REMOTE_HOST}" "sudo docker load"

  echo "[6/6] Starting container from loaded image"
  ssh "${REMOTE_HOST}" "cd '${DEPLOY_DIR}' && ${REMOTE_COMPOSE_CMD} up -d"
else
  echo "[4/6] Building and starting container"
  ssh "${REMOTE_HOST}" "cd '${DEPLOY_DIR}' && ${REMOTE_COMPOSE_CMD} up -d --build"
fi

echo "[verify] Waiting for health check"
for _ in $(seq 1 30); do
  if curl "${CURL_ARGS[@]}" "${BASE_URL}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "[verify] Verifying deployment at ${BASE_URL}"
curl "${CURL_ARGS[@]}" "${BASE_URL}/healthz"
echo
curl "${CURL_ARGS[@]}" "${BASE_URL}/management.html" -o /tmp/cliproxy-management.html
wc -c /tmp/cliproxy-management.html
sed -n '1,3p' /tmp/cliproxy-management.html
echo
curl "${CURL_ARGS[@]}" \
  -H "Authorization: Bearer ${MANAGEMENT_PASSWORD}" \
  "${BASE_URL}/v0/management/auth-files" | \
  python3 -c 'import json,sys; data=json.load(sys.stdin); items=data.get("files") or data.get("auth-files") or data.get("auth_files") or []; print("auth_files=", len(items)); print([item.get("name") for item in items])'
echo
ssh "${REMOTE_HOST}" "cd '${DEPLOY_DIR}' && sudo docker compose ps"
