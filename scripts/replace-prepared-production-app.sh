#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

ARTIFACT_APP="${ARTIFACT_APP:-${ROOT_DIR}/build/t073-production-ready/Quotio.app}"
TARGET_APP_PATH="${TARGET_APP_PATH:-/Applications/Quotio.app}"
BACKUP_ROOT="${BACKUP_ROOT:-${HOME}/Library/Application Support/Quotio/backups/app-replace}"
EXECUTE="${EXECUTE:-0}"
RELAUNCH="${RELAUNCH:-1}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-45}"
FORCE_KILL="${FORCE_KILL:-0}"
ROLLBACK_MANIFEST="${ROLLBACK_MANIFEST:-}"
REQUIRE_ACTIVE_RELAY="${REQUIRE_ACTIVE_RELAY:-1}"
ACTIVE_RELAY_HEALTH_URL="${ACTIVE_RELAY_HEALTH_URL:-http://127.0.0.1:18082/healthz}"
PROTECTED_RELAY_PORTS="${PROTECTED_RELAY_PORTS:-18080,18082}"

QUOTIO_LAUNCHCTL_ENV_KEYS=(
  QUOTIO_SHOW_IN_DOCK
  QUOTIO_DISABLE_UPDATE_CHECKS
  QUOTIO_SKIP_ONBOARDING
  QUOTIO_PROXY_PORT
  QUOTIO_REMOTE_EXPOSE_LOCAL_RELAY
  QUOTIO_REMOTE_VERIFY_SSL
  QUOTIO_REMOTE_ENDPOINT
  QUOTIO_OPERATING_MODE
  QUOTIO_REMOTE_MANAGEMENT_KEY_FILE
  QUOTIO_REMOTE_MANAGEMENT_KEY_STORE
  QUOTIO_KEYCHAIN_NAMESPACE
  QUOTIO_AUTH_DIR
  QUOTIO_APP_SUPPORT_DIR
  QUOTIO_REMOTE_MANAGEMENT_ENDPOINT
  QUOTIO_REMOTE_DISPLAY_NAME
  QUOTIO_REMOTE_CONFIG_ID
  QUOTIO_AUTO_START_PROXY
  QUOTIO_INITIAL_PAGE
)

usage() {
  cat <<'EOF'
Usage:
  ./scripts/replace-prepared-production-app.sh [--dry-run]
  ./scripts/replace-prepared-production-app.sh --execute
  ./scripts/replace-prepared-production-app.sh --rollback --manifest <manifest.json>

Environment:
  ARTIFACT_APP=/path/to/Quotio.app      Prepared app artifact. Default: build/t073-production-ready/Quotio.app
  TARGET_APP_PATH=/Applications/Quotio.app
  BACKUP_ROOT=...                       Backup/manifest directory. Default: ~/Library/Application Support/Quotio/backups/app-replace
  EXECUTE=0|1                           Same as --dry-run / --execute. Default: 0
  RELAUNCH=0|1                          Relaunch after replacement/rollback. Default: 1
  WAIT_TIMEOUT=<sec>                    Wait for app quit/start. Default: 45
  FORCE_KILL=0|1                        Escalate to SIGKILL if graceful quit times out. Default: 0
  REQUIRE_ACTIVE_RELAY=0|1              Require active relay health before execute. Default: 1
  ACTIVE_RELAY_HEALTH_URL=...           Health URL that must stay available. Default: http://127.0.0.1:18082/healthz
  PROTECTED_RELAY_PORTS=18080,18082      Abort if target app owns any protected relay port.

Scope:
  App bundle only. This script does not replace CLIProxyAPI core, management.html, auth files, usage data, or tokens.
  For full app+core+management runtime replacement use scripts/replace-local-quotio-runtime.sh.
EOF
}

MODE="replace"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute)
      EXECUTE=1
      shift
      ;;
    --dry-run)
      EXECUTE=0
      shift
      ;;
    --artifact)
      ARTIFACT_APP="${2:-}"
      shift 2
      ;;
    --target-app)
      TARGET_APP_PATH="${2:-}"
      shift 2
      ;;
    --backup-root)
      BACKUP_ROOT="${2:-}"
      shift 2
      ;;
    --no-relaunch)
      RELAUNCH=0
      shift
      ;;
    --force-kill)
      FORCE_KILL=1
      shift
      ;;
    --rollback)
      MODE="rollback"
      shift
      ;;
    --manifest)
      ROLLBACK_MANIFEST="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

clear_quotio_launchctl_env() {
  local key
  for key in "${QUOTIO_LAUNCHCTL_ENV_KEYS[@]}"; do
    launchctl unsetenv "$key" >/dev/null 2>&1 || true
  done
}

listener_pids_for_port() {
  local port="$1"
  lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null | sort -u || true
}

relay_port_summary() {
  local result=""
  local port
  IFS=',' read -r -a ports <<<"$PROTECTED_RELAY_PORTS"
  for port in "${ports[@]}"; do
    port="${port//[[:space:]]/}"
    [[ -n "$port" ]] || continue
    result+="${port}:$(listener_pids_for_port "$port" | tr '\n' ' '); "
  done
  printf '%s\n' "$result"
}

assert_active_relay_ready() {
  [[ "$REQUIRE_ACTIVE_RELAY" == "1" ]] || return 0
  curl -fsS --max-time 5 "$ACTIVE_RELAY_HEALTH_URL" >/dev/null || {
    echo "Active relay health check failed: ${ACTIVE_RELAY_HEALTH_URL}" >&2
    echo "Abort to avoid interrupting the current AI conversation. Fix the active relay first, or set REQUIRE_ACTIVE_RELAY=0 only if you know this is safe." >&2
    exit 1
  }
}

assert_target_does_not_own_protected_ports() {
  local app="$1"
  local target_pids
  local port
  local port_pid
  target_pids=" $(running_pids_for_app "$app" | tr '\n' ' ') "
  [[ -n "${target_pids// /}" ]] || return 0

  IFS=',' read -r -a ports <<<"$PROTECTED_RELAY_PORTS"
  for port in "${ports[@]}"; do
    port="${port//[[:space:]]/}"
    [[ -n "$port" ]] || continue
    while IFS= read -r port_pid; do
      [[ -n "$port_pid" ]] || continue
      if [[ "$target_pids" == *" ${port_pid} "* ]]; then
        echo "Target app owns protected relay port ${port} (pid=${port_pid})." >&2
        echo "Abort to avoid interrupting active AI traffic. Move current traffic to a different healthy relay first, or remove that port from PROTECTED_RELAY_PORTS only in a controlled window." >&2
        exit 1
      fi
    done < <(listener_pids_for_port "$port")
  done
}

require_path() {
  local path="$1"
  local label="$2"
  [[ -e "$path" ]] || {
    echo "${label} not found: ${path}" >&2
    exit 1
  }
}

require_writable_parent() {
  local path="$1"
  local label="$2"
  local parent
  parent="$(dirname "$path")"
  [[ -d "$parent" ]] || {
    echo "${label} parent directory not found: ${parent}" >&2
    exit 1
  }
  [[ -w "$parent" ]] || {
    echo "${label} parent directory is not writable: ${parent}" >&2
    echo "Do not continue blindly. Re-run from an account that can write this path, or choose TARGET_APP_PATH in a writable Applications directory." >&2
    exit 1
  }
}

ensure_writable_directory() {
  local path="$1"
  local label="$2"
  mkdir -p "$path"
  [[ -d "$path" ]] || {
    echo "${label} directory was not created: ${path}" >&2
    exit 1
  }
  [[ -w "$path" ]] || {
    echo "${label} directory is not writable: ${path}" >&2
    exit 1
  }
}

realpath_py() {
  python3 - "$1" <<'PY'
import os
import sys

print(os.path.realpath(sys.argv[1]))
PY
}

json_get() {
  python3 - "$1" "$2" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())
print(data.get(sys.argv[2], ""))
PY
}

plist_value() {
  /usr/libexec/PlistBuddy -c "Print :$2" "$1/Contents/Info.plist" 2>/dev/null || true
}

hash_file() {
  shasum -a 256 "$1" | awk '{print $1}'
}

app_executable() {
  local app="$1"
  local bundle_name
  bundle_name="$(plist_value "$app" "CFBundleExecutable")"
  if [[ -z "$bundle_name" ]]; then
    bundle_name="$(basename "$app" .app)"
  fi
  printf '%s/Contents/MacOS/%s\n' "$app" "$bundle_name"
}

running_pids_for_app() {
  local app="$1"
  local executable
  executable="$(app_executable "$app")"
  python3 - "$executable" <<'PY'
import os
import subprocess
import sys

executable = sys.argv[1]
self_pid = os.getpid()
output = subprocess.check_output(["ps", "ax", "-o", "pid=,command="], text=True)
for line in output.splitlines():
    stripped = line.strip()
    if not stripped:
        continue
    parts = stripped.split(maxsplit=1)
    if len(parts) != 2:
        continue
    try:
        pid = int(parts[0])
    except ValueError:
        continue
    if pid == self_pid:
        continue
    command = parts[1]
    if command == executable or command.startswith(executable + " "):
        print(pid)
PY
}

wait_for_app_exit() {
  local app="$1"
  local timeout="$2"
  local start
  start="$(date +%s)"
  while [[ -n "$(running_pids_for_app "$app" | tr -d '[:space:]')" ]]; do
    if (( "$(date +%s)" - start >= timeout )); then
      return 1
    fi
    sleep 1
  done
}

wait_for_app_start() {
  local app="$1"
  local timeout="$2"
  local start
  start="$(date +%s)"
  while [[ -z "$(running_pids_for_app "$app" | tr -d '[:space:]')" ]]; do
    if (( "$(date +%s)" - start >= timeout )); then
      return 1
    fi
    sleep 1
  done
}

quit_app() {
  local app="$1"
  local label="$2"
  local pids
  pids="$(running_pids_for_app "$app" | tr '\n' ' ')"
  [[ -n "${pids// /}" ]] || return 0

  echo "[stop] Sending SIGTERM to target ${label} pids only: ${pids}"
  for pid in $pids; do
    kill -TERM "$pid" 2>/dev/null || true
  done
  if wait_for_app_exit "$app" "$WAIT_TIMEOUT"; then
    return 0
  fi

  if [[ "$FORCE_KILL" != "1" ]]; then
    echo "${label} did not quit within ${WAIT_TIMEOUT}s. Re-run with --force-kill only in a controlled window." >&2
    exit 1
  fi

  echo "[stop] Escalating to SIGKILL for ${label}: ${pids}"
  for pid in $pids; do
    kill -KILL "$pid" 2>/dev/null || true
  done
  wait_for_app_exit "$app" 5 || true
}

validate_app_bundle() {
  local app="$1"
  local label="$2"
  require_path "$app" "$label"
  require_path "$app/Contents/Info.plist" "${label} Info.plist"
  require_path "$(app_executable "$app")" "${label} executable"

  local bundle_id
  local bundle_name
  bundle_id="$(plist_value "$app" "CFBundleIdentifier")"
  bundle_name="$(plist_value "$app" "CFBundleName")"
  if [[ "$bundle_id" != "dev.quotio.desktop" ]]; then
    echo "${label} bundle id mismatch: got=${bundle_id} expected=dev.quotio.desktop" >&2
    exit 1
  fi
  if [[ "$bundle_name" != "Quotio" ]]; then
    echo "${label} bundle name mismatch: got=${bundle_name} expected=Quotio" >&2
    exit 1
  fi
}

write_replace_manifest() {
  local manifest="$1"
  python3 - "$manifest" \
    "$ARTIFACT_APP" \
    "$TARGET_APP_PATH" \
    "$backup_app" \
    "$(app_executable "$ARTIFACT_APP")" \
    "$(app_executable "$TARGET_APP_PATH")" <<'PY'
import json
import pathlib
import subprocess
import sys
import time

manifest, artifact, target, backup, artifact_exec, target_exec = sys.argv[1:]

def sha(path):
    return subprocess.check_output(["shasum", "-a", "256", path], text=True).split()[0]

data = {
    "replaced_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "scope": "app-bundle-only",
    "artifact_app": artifact,
    "target_app": target,
    "backup_app": backup,
    "artifact_exec_sha256": sha(artifact_exec),
    "target_exec_sha256": sha(target_exec),
    "rollback_command": f"scripts/replace-prepared-production-app.sh --rollback --manifest {manifest}",
}
pathlib.Path(manifest).write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
PY
}

replace_app() {
  validate_app_bundle "$ARTIFACT_APP" "artifact app"
  validate_app_bundle "$TARGET_APP_PATH" "target app"

  local artifact_real
  local target_real
  artifact_real="$(realpath_py "$ARTIFACT_APP")"
  target_real="$(realpath_py "$TARGET_APP_PATH")"
  if [[ "$artifact_real" == "$target_real" ]]; then
    echo "Artifact and target resolve to the same path: ${artifact_real}" >&2
    exit 1
  fi

  local artifact_exec
  local target_exec
  local artifact_sha
  local target_sha
  artifact_exec="$(app_executable "$ARTIFACT_APP")"
  target_exec="$(app_executable "$TARGET_APP_PATH")"
  artifact_sha="$(hash_file "$artifact_exec")"
  target_sha="$(hash_file "$target_exec")"
  timestamp="$(date '+%Y%m%d-%H%M%S')"
  backup_app="${BACKUP_ROOT}/Quotio.app.${timestamp}.bak"
  replace_manifest="${BACKUP_ROOT}/replace-app.prod.${timestamp}.json"

  echo "Production Quotio.app replacement plan"
  echo "  mode          : $([[ "$EXECUTE" == "1" ]] && echo execute || echo dry-run)"
  echo "  scope         : app bundle only; core/management/auth/usage untouched"
  echo "  artifact_app  : ${ARTIFACT_APP}"
  echo "  target_app    : ${TARGET_APP_PATH}"
  echo "  artifact_hash : ${artifact_sha}"
  echo "  target_hash   : ${target_sha}"
  echo "  backup_app    : ${backup_app}"
  echo "  manifest      : ${replace_manifest}"
  echo "  relaunch      : ${RELAUNCH}"
  echo "  running_pids  : $(running_pids_for_app "$TARGET_APP_PATH" | tr '\n' ' ')"
  echo "  active_relay  : ${ACTIVE_RELAY_HEALTH_URL} (required=${REQUIRE_ACTIVE_RELAY})"
  echo "  protected_ports: $(relay_port_summary)"

  if [[ "$EXECUTE" != "1" ]]; then
    echo
    echo "Dry-run only. To replace now:"
    echo "  ${0} --artifact \"${ARTIFACT_APP}\" --target-app \"${TARGET_APP_PATH}\" --execute"
    return 0
  fi

  assert_active_relay_ready
  assert_target_does_not_own_protected_ports "$TARGET_APP_PATH"
  require_writable_parent "$TARGET_APP_PATH" "target app"
  ensure_writable_directory "$BACKUP_ROOT" "backup root"
  echo "[backup] Saving current app bundle"
  ditto "$TARGET_APP_PATH" "$backup_app"

  quit_app "$TARGET_APP_PATH" "production Quotio"

  local temp_app
  temp_app="$(mktemp -d "$(dirname "$TARGET_APP_PATH")/.Quotio.app.replace.XXXXXX")"
  rm -rf "$temp_app"
  echo "[replace] Copying prepared app into place"
  ditto "$ARTIFACT_APP" "$temp_app"
  rm -rf "$TARGET_APP_PATH"
  mv "$temp_app" "$TARGET_APP_PATH"
  xattr -dr com.apple.quarantine "$TARGET_APP_PATH" >/dev/null 2>&1 || true
  codesign --verify --deep --strict --verbose=2 "$TARGET_APP_PATH"

  if [[ "$RELAUNCH" == "1" ]]; then
    echo "[start] Relaunching production Quotio"
    clear_quotio_launchctl_env
    open "$TARGET_APP_PATH"
    wait_for_app_start "$TARGET_APP_PATH" "$WAIT_TIMEOUT"
  fi

  write_replace_manifest "$replace_manifest"
  echo
  echo "Replacement completed."
  echo "  manifest : ${replace_manifest}"
  echo "  rollback : ${0} --rollback --manifest ${replace_manifest}"
}

rollback_app() {
  [[ -n "$ROLLBACK_MANIFEST" ]] || {
    echo "--rollback requires --manifest <manifest.json>" >&2
    exit 1
  }
  require_path "$ROLLBACK_MANIFEST" "rollback manifest"

  local backup_app
  local target_app
  backup_app="$(json_get "$ROLLBACK_MANIFEST" backup_app)"
  target_app="$(json_get "$ROLLBACK_MANIFEST" target_app)"
  require_path "$backup_app" "backup app"
  validate_app_bundle "$backup_app" "backup app"

  echo "Production Quotio.app rollback plan"
  echo "  mode       : $([[ "$EXECUTE" == "1" ]] && echo execute || echo dry-run)"
  echo "  manifest   : ${ROLLBACK_MANIFEST}"
  echo "  backup_app : ${backup_app}"
  echo "  target_app : ${target_app}"
  echo "  relaunch   : ${RELAUNCH}"
  echo "  running_pids: $(running_pids_for_app "$target_app" | tr '\n' ' ')"
  echo "  active_relay: ${ACTIVE_RELAY_HEALTH_URL} (required=${REQUIRE_ACTIVE_RELAY})"
  echo "  protected_ports: $(relay_port_summary)"

  if [[ "$EXECUTE" != "1" ]]; then
    echo
    echo "Dry-run only. To rollback now:"
    echo "  ${0} --rollback --manifest \"${ROLLBACK_MANIFEST}\" --execute"
    return 0
  fi

  assert_active_relay_ready
  assert_target_does_not_own_protected_ports "$target_app"
  require_writable_parent "$target_app" "target app"
  quit_app "$target_app" "production Quotio"
  local temp_app
  temp_app="$(mktemp -d "$(dirname "$target_app")/.Quotio.app.rollback.XXXXXX")"
  rm -rf "$temp_app"
  ditto "$backup_app" "$temp_app"
  rm -rf "$target_app"
  mv "$temp_app" "$target_app"
  xattr -dr com.apple.quarantine "$target_app" >/dev/null 2>&1 || true
  codesign --verify --deep --strict --verbose=2 "$target_app"

  if [[ "$RELAUNCH" == "1" ]]; then
    clear_quotio_launchctl_env
    open "$target_app"
    wait_for_app_start "$target_app" "$WAIT_TIMEOUT"
  fi
  echo "Rollback completed."
}

require_cmd python3
require_cmd shasum
require_cmd ditto
require_cmd codesign
require_cmd curl
require_cmd lsof
require_cmd launchctl

case "$MODE" in
  replace) replace_app ;;
  rollback) rollback_app ;;
  *) usage >&2; exit 1 ;;
esac
