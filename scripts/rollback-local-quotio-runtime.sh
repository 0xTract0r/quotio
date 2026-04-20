#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSPECT_SCRIPT="${SCRIPT_DIR}/inspect-runtime-profile.sh"

TARGET="${TARGET:-prod}"
MANIFEST="${MANIFEST:-}"
RELAUNCH="${RELAUNCH:-1}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-45}"
FORCE_KILL="${FORCE_KILL:-0}"
VERIFY_HEALTH="${VERIFY_HEALTH:-1}"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/rollback-local-quotio-runtime.sh
  TARGET=dev ./scripts/rollback-local-quotio-runtime.sh
  MANIFEST="/abs/path/to/replace.prod.<timestamp>.txt" ./scripts/rollback-local-quotio-runtime.sh

Environment:
  TARGET=prod|dev        Roll back production or isolated dev runtime. Default: prod
  MANIFEST=...           Optional explicit replace manifest to restore from
  RELAUNCH=0|1           Relaunch app after rollback. Default: 1
  WAIT_TIMEOUT=<sec>     Wait timeout for stop/start checks. Default: 45
  FORCE_KILL=0|1         Escalate to SIGKILL if graceful stop times out. Default: 0
  VERIFY_HEALTH=0|1      Curl internal /healthz after relaunch. Default: 1

Notes:
  - If MANIFEST is omitted, the latest replace.<target>.*.txt under backups/local-runtime-replace is used.
  - The script restores app/core/management backups recorded in the selected manifest.
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_file() {
  local path="$1"
  local label="$2"
  if [[ ! -e "$path" ]]; then
    echo "$label not found: $path" >&2
    exit 1
  fi
}

profile_value() {
  local profile="$1"
  local key="$2"
  printf '%s\n' "$profile" | awk -F= -v k="$key" '$1==k {sub($1 "=",""); print}'
}

listener_pid() {
  local port="$1"
  lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null | head -n 1 || true
}

wait_for_pid_exit() {
  local pid="$1"
  local timeout="$2"
  local start
  start="$(date +%s)"
  while kill -0 "$pid" 2>/dev/null; do
    if (( "$(date +%s)" - start >= timeout )); then
      return 1
    fi
    sleep 1
  done
}

wait_for_port_state() {
  local port="$1"
  local want_state="$2"
  local timeout="$3"
  local start
  start="$(date +%s)"
  while true; do
    local pid
    pid="$(listener_pid "$port")"
    if [[ "$want_state" == "listening" && -n "$pid" ]]; then
      return 0
    fi
    if [[ "$want_state" == "idle" && -z "$pid" ]]; then
      return 0
    fi
    if (( "$(date +%s)" - start >= timeout )); then
      return 1
    fi
    sleep 1
  done
}

stop_pid() {
  local pid="$1"
  local label="$2"
  if [[ -z "$pid" ]]; then
    return 0
  fi
  if ! kill -0 "$pid" 2>/dev/null; then
    return 0
  fi

  echo "[stop] Sending SIGTERM to ${label} (pid=${pid})"
  kill -TERM "$pid" 2>/dev/null || true
  if wait_for_pid_exit "$pid" "$WAIT_TIMEOUT"; then
    return 0
  fi

  if [[ "$FORCE_KILL" != "1" ]]; then
    echo "${label} did not exit within ${WAIT_TIMEOUT}s. Re-run with FORCE_KILL=1 if you want to escalate." >&2
    return 1
  fi

  echo "[stop] Escalating to SIGKILL for ${label} (pid=${pid})"
  kill -KILL "$pid" 2>/dev/null || true
  wait_for_pid_exit "$pid" 5
}

copy_bundle() {
  local src="$1"
  local dest="$2"
  rm -rf "$dest"
  ditto "$src" "$dest"
}

replace_file_atomically() {
  local src="$1"
  local dest="$2"
  local dest_dir
  local dest_name
  local temp_path

  dest_dir="$(dirname "$dest")"
  dest_name="$(basename "$dest")"
  mkdir -p "$dest_dir"
  temp_path="$(mktemp "${dest_dir}/.${dest_name}.rollback.XXXXXX")"
  cp "$src" "$temp_path"
  chmod 755 "$temp_path"
  mv "$temp_path" "$dest"
}

resolve_target_metadata() {
  case "$TARGET" in
    prod)
      TARGET_BUNDLE_ID="dev.quotio.desktop"
      TARGET_LABEL="production"
      TARGET_PRODUCT_NAME="Quotio"
      ;;
    dev)
      TARGET_BUNDLE_ID="dev.quotio.desktop.dev"
      TARGET_LABEL="isolated-dev"
      TARGET_PRODUCT_NAME="Quotio Dev"
      ;;
    *)
      echo "Unsupported TARGET=${TARGET}. Use prod or dev." >&2
      exit 1
      ;;
  esac

  TARGET_PROFILE="$("$INSPECT_SCRIPT" "$TARGET_BUNDLE_ID")"
  TARGET_APP_SUPPORT="$(profile_value "$TARGET_PROFILE" application_support)"
  TARGET_CLIENT_PORT="$(profile_value "$TARGET_PROFILE" proxy_port)"
  TARGET_CORE_PORT="$(profile_value "$TARGET_PROFILE" internal_proxy_port)"
  TARGET_BACKUP_ROOT="${TARGET_APP_SUPPORT}/backups/local-runtime-replace"
}

parse_manifest() {
  local manifest_path="$1"
  while IFS='=' read -r key value; do
    case "$key" in
      target_app) TARGET_APP_PATH="$value" ;;
      target_core) TARGET_CORE_PATH="$value" ;;
      target_management) TARGET_MANAGEMENT_PATH="$value" ;;
      replace_core) REPLACE_CORE="$value" ;;
      backup_app) BACKUP_APP_PATH="$value" ;;
      backup_core) BACKUP_CORE_PATH="$value" ;;
      backup_management) BACKUP_MANAGEMENT_PATH="$value" ;;
    esac
  done <"$manifest_path"
}

resolve_manifest() {
  if [[ -n "$MANIFEST" ]]; then
    printf '%s\n' "$MANIFEST"
    return 0
  fi

  local latest=""
  latest="$(find "$TARGET_BACKUP_ROOT" -maxdepth 1 -type f -name "replace.${TARGET}.*.txt" -print | sort | tail -n 1)"
  if [[ -z "$latest" ]]; then
    echo "No replace manifest found under $TARGET_BACKUP_ROOT for TARGET=${TARGET}" >&2
    exit 1
  fi
  printf '%s\n' "$latest"
}

write_rollback_manifest() {
  local timestamp="$1"
  local rollback_manifest="${TARGET_BACKUP_ROOT}/rollback.${TARGET}.${timestamp}.txt"
  cat >"$rollback_manifest" <<EOF
rolled_back_at=$(date '+%Y-%m-%d %H:%M:%S %z')
target=${TARGET}
source_replace_manifest=${SELECTED_MANIFEST}
target_app=${TARGET_APP_PATH}
target_core=${TARGET_CORE_PATH}
target_management=${TARGET_MANAGEMENT_PATH}
backup_app=${BACKUP_APP_PATH}
backup_core=${BACKUP_CORE_PATH}
backup_management=${BACKUP_MANAGEMENT_PATH}
EOF
  echo "[rollback] Manifest written: $rollback_manifest"
}

require_cmd python3
require_cmd lsof
require_cmd ditto
require_cmd curl

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

resolve_target_metadata
SELECTED_MANIFEST="$(resolve_manifest)"
require_file "$SELECTED_MANIFEST" "rollback source manifest"

TARGET_APP_PATH=""
TARGET_CORE_PATH=""
TARGET_MANAGEMENT_PATH=""
REPLACE_CORE="1"
BACKUP_APP_PATH=""
BACKUP_CORE_PATH=""
BACKUP_MANAGEMENT_PATH=""
parse_manifest "$SELECTED_MANIFEST"

require_file "$BACKUP_APP_PATH" "app backup"
if [[ "$REPLACE_CORE" == "1" ]]; then
  require_file "$BACKUP_CORE_PATH" "core backup"
fi

echo "Rollback plan"
echo "  target_label      : ${TARGET_LABEL}"
echo "  replace_manifest  : ${SELECTED_MANIFEST}"
echo "  target_app        : ${TARGET_APP_PATH}"
echo "  target_core       : ${TARGET_CORE_PATH}"
echo "  target_management : ${TARGET_MANAGEMENT_PATH}"
echo "  backup_app        : ${BACKUP_APP_PATH}"
echo "  backup_core       : ${BACKUP_CORE_PATH:-<skipped>}"
echo "  backup_management : ${BACKUP_MANAGEMENT_PATH:-<remove target>}"
echo "  relaunch          : ${RELAUNCH}"
echo "  verify_health     : ${VERIFY_HEALTH}"

app_pid="$(listener_pid "$TARGET_CLIENT_PORT")"
core_pid="$(listener_pid "$TARGET_CORE_PORT")"

if [[ -n "$app_pid" ]]; then
  stop_pid "$app_pid" "${TARGET_LABEL} app"
fi
if ! wait_for_port_state "$TARGET_CLIENT_PORT" idle "$WAIT_TIMEOUT"; then
  echo "Client port ${TARGET_CLIENT_PORT} did not become idle." >&2
  exit 1
fi

core_pid="$(listener_pid "$TARGET_CORE_PORT")"
if [[ -n "$core_pid" ]]; then
  stop_pid "$core_pid" "${TARGET_LABEL} core"
fi
if ! wait_for_port_state "$TARGET_CORE_PORT" idle "$WAIT_TIMEOUT"; then
  echo "Core port ${TARGET_CORE_PORT} did not become idle." >&2
  exit 1
fi

echo "[rollback] Restoring app bundle"
copy_bundle "$BACKUP_APP_PATH" "$TARGET_APP_PATH"

if [[ "$REPLACE_CORE" == "1" ]]; then
  echo "[rollback] Restoring core binary"
  replace_file_atomically "$BACKUP_CORE_PATH" "$TARGET_CORE_PATH"
else
  echo "[rollback] Skipping core binary restore (replace_core=${REPLACE_CORE})"
fi

if [[ -n "$BACKUP_MANAGEMENT_PATH" && -f "$BACKUP_MANAGEMENT_PATH" ]]; then
  echo "[rollback] Restoring management asset"
  replace_file_atomically "$BACKUP_MANAGEMENT_PATH" "$TARGET_MANAGEMENT_PATH"
else
  echo "[rollback] Removing management asset because no backup was recorded"
  rm -f "$TARGET_MANAGEMENT_PATH"
fi

timestamp="$(date '+%Y%m%d-%H%M%S')"
write_rollback_manifest "$timestamp"

if [[ "$RELAUNCH" == "1" ]]; then
  echo "[start] Relaunching ${TARGET_PRODUCT_NAME}"
  open "$TARGET_APP_PATH"
  wait_for_port_state "$TARGET_CLIENT_PORT" listening "$WAIT_TIMEOUT"
  wait_for_port_state "$TARGET_CORE_PORT" listening "$WAIT_TIMEOUT"
  if [[ "$VERIFY_HEALTH" == "1" ]]; then
    curl -fsS "http://127.0.0.1:${TARGET_CORE_PORT}/healthz" >/dev/null
    echo "[verify] Internal core healthz is ready on ${TARGET_CORE_PORT}"
  fi
fi

echo
echo "Rollback completed."
echo "  restored_app  : ${BACKUP_APP_PATH}"
if [[ "$REPLACE_CORE" == "1" ]]; then
  echo "  restored_core : ${BACKUP_CORE_PATH}"
fi
if [[ -n "$BACKUP_MANAGEMENT_PATH" && -f "$BACKUP_MANAGEMENT_PATH" ]]; then
  echo "  restored_mgmt : ${BACKUP_MANAGEMENT_PATH}"
fi
