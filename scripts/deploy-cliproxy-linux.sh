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
SERVER_PROXY_URL="${SERVER_PROXY_URL:-}"
CONTAINER_DNS_SERVERS="${CONTAINER_DNS_SERVERS:-}"

if [[ -n "${QUOTIO_SOURCE_ROOT:-}" ]]; then
  SOURCE_ROOT="${QUOTIO_SOURCE_ROOT}"
else
  SOURCE_ROOT="$(git rev-parse --show-toplevel)"
fi

CORE_SRC="${SOURCE_ROOT}/third_party/CLIProxyAPIPlus"
MGMT_SRC="${SOURCE_ROOT}/third_party/Cli-Proxy-API-Management-Center"
LOCAL_CONFIG_PATH="${LOCAL_CONFIG_PATH:-$HOME/Library/Application Support/Quotio/config.yaml}"
SOURCE_AUTH_DIR_PATH="${SOURCE_AUTH_DIR_PATH:-$HOME/.cli-proxy-api}"
PROXY_API_KEY="${PROXY_API_KEY:-}"

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

if [[ -n "${BIND_HOST}" ]]; then
  PORT_MAPPING="${BIND_HOST}:${API_PORT}:${API_PORT}"
else
  PORT_MAPPING="${API_PORT}:${API_PORT}"
fi

if [[ -n "${SERVER_PROXY_URL}" ]]; then
  echo "[info] Using server proxy URL: ${SERVER_PROXY_URL}"
else
  echo "[info] SERVER_PROXY_URL not set; proxy-url will be empty"
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
  "${TMP_DIR}/runtime/auth" \
  "${TMP_DIR}/runtime/config" \
  "${TMP_DIR}/runtime/logs" \
  "${TMP_DIR}/runtime/static"

echo "[2/6] Preparing deployment bundle"
rsync -a --delete --exclude '.git' --exclude 'node_modules' \
  "${CORE_SRC}/" "${TMP_DIR}/source/CLIProxyAPIPlus/"
cp "${MGMT_SRC}/dist/index.html" "${TMP_DIR}/runtime/static/management.html"

if [[ "${SYNC_AUTH_DIR}" == "1" ]]; then
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
python3 <<'PY'
import os
import pathlib
import yaml

config_path = pathlib.Path(os.environ["LOCAL_CONFIG_PATH"]).expanduser()
output_path = pathlib.Path(os.environ["OUTPUT_CONFIG_PATH"])
api_port = int(os.environ["API_PORT"])
override_api_key = os.environ.get("PROXY_API_KEY", "").strip()
server_proxy_url = os.environ.get("SERVER_PROXY_URL", "").strip()

with config_path.open("r", encoding="utf-8") as f:
    data = yaml.safe_load(f) or {}

data["host"] = ""
data["port"] = api_port
data["auth-dir"] = "/CLIProxyAPI/auth"
data["proxy-url"] = server_proxy_url

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
rsync -az --delete "${TMP_DIR}/" "${REMOTE_HOST}:${DEPLOY_DIR}/"

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
  ssh "${REMOTE_HOST}" "cd '${DEPLOY_DIR}' && sudo docker compose up -d"
else
  echo "[4/6] Building and starting container"
  ssh "${REMOTE_HOST}" "cd '${DEPLOY_DIR}' && sudo docker compose up -d --build"
fi

echo "[verify] Waiting for health check"
for _ in $(seq 1 30); do
  if curl -fsS "http://${SERVER_HOST_IP}:${API_PORT}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "[verify] Verifying deployment"
curl -fsS "http://${SERVER_HOST_IP}:${API_PORT}/healthz"
echo
curl -fsS "http://${SERVER_HOST_IP}:${API_PORT}/management.html" -o /tmp/cliproxy-management.html
wc -c /tmp/cliproxy-management.html
sed -n '1,3p' /tmp/cliproxy-management.html
echo
curl -fsS \
  -H "Authorization: Bearer ${MANAGEMENT_PASSWORD}" \
  "http://${SERVER_HOST_IP}:${API_PORT}/v0/management/auth-files" | \
  python3 -c 'import json,sys; data=json.load(sys.stdin); items=data.get("files") or data.get("auth-files") or data.get("auth_files") or []; print("auth_files=", len(items)); print([item.get("name") for item in items])'
echo
ssh "${REMOTE_HOST}" "cd '${DEPLOY_DIR}' && sudo docker compose ps"
