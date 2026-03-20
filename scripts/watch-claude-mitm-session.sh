#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

DEV_BUNDLE_ID="${DEV_BUNDLE_ID:-dev.quotio.desktop.dev}"
CLIENT_PORT="${CLIENT_PORT:-$(defaults read "$DEV_BUNDLE_ID" proxyPort 2>/dev/null || echo 18417)}"
CONFIG_PATH="${CONFIG_PATH:-$HOME/Library/Application Support/Quotio-dev/config.yaml}"
PATCHED_CORE_BIN="${PATCHED_CORE_BIN:-$ROOT_DIR/build/CLIProxyAPIPlus/CLIProxyAPI}"
FALLBACK_CORE_BIN="${FALLBACK_CORE_BIN:-$HOME/Library/Application Support/Quotio-dev/CLIProxyAPI}"

MITM_DIR="${MITM_DIR:-/tmp/quotio-mitm}"
MITM_HOME="${MITM_HOME:-$MITM_DIR/home}"
MITM_VENV="${MITM_VENV:-$MITM_DIR/venv}"
MITM_PORT="${MITM_PORT:-19091}"
FLOW_FILE="${FLOW_FILE:-$MITM_DIR/flows.jsonl}"
MITM_SCRIPT="${MITM_SCRIPT:-$ROOT_DIR/scripts/anthropic-mitm-capture.py}"
WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS:-300}"
ALLOW_DIRECT_CORE_DEBUG="${ALLOW_DIRECT_CORE_DEBUG:-0}"
CLEANUP_LOG="${CLEANUP_LOG:-/tmp/watch-claude-mitm-cleanup.log}"

MITM_PID=""
MITM_OWNED_BY_SCRIPT=0
BASELINE_FLOW_COUNT=0

ORIGINAL_PROXY_URL=""
CLAUDE_AUTH_PATH=""
CONFIG_AUTH_DIR=""
CORE_PORT=""

MANAGED_MODE=0
DEV_APP_PID=""
DEV_APP_EXEC=""
DEV_APP_BUNDLE=""
DEV_APP_WAS_RUNNING=0
RELAUNCHED_APP_PID=""
AUTOSTART_PROXY_WAS_SET=0
AUTOSTART_PROXY_ORIGINAL=""
TEST_CA_ENV_WAS_SET=0
TEST_CA_ENV_ORIGINAL=""
DEBUG_TEST_CA_FILE_WAS_SET=0
DEBUG_TEST_CA_FILE_ORIGINAL=""

CURRENT_CORE_PID=""
CURRENT_CORE_BIN=""
CORE_BACKUP_FILE=""

DIRECT_CORE_PID=""
CLEANUP_ALREADY_RAN=0

log_cleanup() {
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  printf '[%s] %s\n' "$timestamp" "$*" >>"$CLEANUP_LOG"
}

require_file() {
  local path="$1"
  local label="$2"
  if [[ ! -e "$path" ]]; then
    echo "$label not found: $path" >&2
    exit 1
  fi
}

wait_for_listener() {
  local port="$1"
  local tries="${2:-60}"
  for _ in $(seq 1 "$tries"); do
    if lsof -tiTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.2
  done
  return 1
}

wait_for_port_clear() {
  local port="$1"
  local tries="${2:-60}"
  for _ in $(seq 1 "$tries"); do
    if ! lsof -tiTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.2
  done
  return 1
}

wait_for_pid_exit() {
  local pid="$1"
  local tries="${2:-60}"
  if [[ -z "$pid" ]]; then
    return 0
  fi
  for _ in $(seq 1 "$tries"); do
    if ! kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
    sleep 0.2
  done
  return 1
}

terminate_pid() {
  local pid="$1"
  local label="$2"
  local tries="${3:-80}"
  if [[ -z "$pid" ]]; then
    return 0
  fi
  if ! kill -0 "$pid" 2>/dev/null; then
    return 0
  fi

  log_cleanup "terminate_pid begin pid=${pid} label=${label}"
  kill "$pid" 2>/dev/null || true
  if wait_for_pid_exit "$pid" "$tries"; then
    log_cleanup "terminate_pid graceful-exit pid=${pid} label=${label}"
    return 0
  fi

  log_cleanup "terminate_pid escalate SIGKILL pid=${pid} label=${label}"
  kill -KILL "$pid" 2>/dev/null || true
  if wait_for_pid_exit "$pid" 20; then
    log_cleanup "terminate_pid force-exit pid=${pid} label=${label}"
    return 0
  fi

  log_cleanup "terminate_pid failed pid=${pid} label=${label}"
  return 1
}

replace_file_atomically() {
  local src="$1"
  local dest="$2"
  local dest_dir
  local dest_name
  local temp_path

  dest_dir="$(dirname "$dest")"
  dest_name="$(basename "$dest")"
  temp_path="$(mktemp "${dest_dir}/.${dest_name}.quotio.XXXXXX")"

  cp "$src" "$temp_path"
  chmod 755 "$temp_path"
  mv "$temp_path" "$dest"
}

config_value() {
  local key="$1"
  python3 - "$CONFIG_PATH" "$key" <<'PY'
import sys

config_path = sys.argv[1]
target = sys.argv[2]
with open(config_path, "r", encoding="utf-8") as fh:
    for raw in fh:
        line = raw.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        key, value = line.split(":", 1)
        if key.strip() == target:
            value = value.strip().strip('"').strip("'")
            print(value)
            raise SystemExit(0)
raise SystemExit(1)
PY
}

pick_claude_auth_file() {
  python3 - "$CONFIG_AUTH_DIR" "${CLAUDE_AUTH_FILE:-}" <<'PY'
import json
import sys
from pathlib import Path

auth_dir = Path(sys.argv[1])
requested = sys.argv[2].strip()

def read_json(path: Path):
    with path.open("r", encoding="utf-8") as fh:
        return json.load(fh)

if requested:
    path = Path(requested).expanduser()
    if not path.is_absolute():
        path = auth_dir / requested
    if not path.exists():
        raise SystemExit(f"requested Claude auth file not found: {path}")
    print(path)
    raise SystemExit(0)

candidates = []
for path in sorted(auth_dir.glob("*.json")):
    try:
        data = read_json(path)
    except Exception:
        continue
    if data.get("type") != "claude":
        continue
    if data.get("disabled") is True:
        continue
    candidates.append(path)

if len(candidates) == 1:
    print(candidates[0])
    raise SystemExit(0)

if not candidates:
    raise SystemExit("no enabled Claude auth file found in auth dir")

names = "\n".join(str(path) for path in candidates)
raise SystemExit(
    "multiple Claude auth files found; set CLAUDE_AUTH_FILE to one of:\n" + names
)
PY
}

read_proxy_url() {
  python3 - "$1" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as fh:
    data = json.load(fh)
print(data.get("proxy_url", ""))
PY
}

restore_proxy_url() {
  local target="$1"
  local attempts="${2:-3}"
  local current=""
  for _ in $(seq 1 "$attempts"); do
    write_proxy_url "$CLAUDE_AUTH_PATH" "$target" >/dev/null 2>&1 || true
    current="$(read_proxy_url "$CLAUDE_AUTH_PATH" 2>/dev/null || true)"
    if [[ "$current" == "$target" ]]; then
      log_cleanup "proxy_url restored to '${target}'"
      return 0
    fi
    sleep 0.2
  done
  log_cleanup "proxy_url restore mismatch target='${target}' current='${current}'"
  return 1
}

write_proxy_url() {
  python3 - "$1" "$2" <<'PY'
import json
import sys

path = sys.argv[1]
proxy_url = sys.argv[2]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)
data["proxy_url"] = proxy_url
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, ensure_ascii=False, indent=2)
    fh.write("\n")
PY
}

summarize_flow() {
  python3 - "$FLOW_FILE" "$CLAUDE_AUTH_PATH" <<'PY'
import json
import sys
from pathlib import Path

flow_path = Path(sys.argv[1])
auth_path = Path(sys.argv[2])

with auth_path.open("r", encoding="utf-8") as fh:
    auth_data = json.load(fh)
expected = auth_data.get("headers", {})

last_line = ""
with flow_path.open("r", encoding="utf-8") as fh:
    for line in fh:
        if line.strip():
            last_line = line

if not last_line:
    raise SystemExit("flow file is empty")

record = json.loads(last_line)
request = record["request"]
response = record["response"]
headers = request["headers"]
response_headers = response["headers"]

keys = [
    "User-Agent",
    "X-App",
    "X-Stainless-Package-Version",
    "X-Stainless-Runtime-Version",
    "X-Stainless-Timeout",
]

print("== Captured Upstream Request ==")
print(f"URL: {request['pretty_url']}")
for key in keys:
    actual = headers.get(key, "")
    expected_value = expected.get(key, "")
    marker = "MATCH" if actual == expected_value else "MISMATCH"
    print(f"{key}: {actual}")
    print(f"  saved: {expected_value}")
    print(f"  check: {marker}")

print("== Captured Upstream Response ==")
print(f"Status: {response.get('status_code')}")
print(f"Content-Type: {response_headers.get('Content-Type', '')}")
print("SSE prefix:")
print(response.get("body_prefix", ""))
PY
}

executable_path_for_pid() {
  local pid="$1"
  lsof -p "$pid" 2>/dev/null | awk '
    $4 == "txt" {
      path = $9
      for (i = 10; i <= NF; i++) path = path " " $i
      print path
      exit
    }
  '
}

app_pids_for_executable() {
  local exec_path="$1"
  python3 - "$exec_path" <<'PY'
import subprocess
import sys

target = sys.argv[1]
try:
    output = subprocess.check_output(
        ["ps", "-ax", "-o", "pid=,command="],
        text=True,
    )
except Exception:
    raise SystemExit(0)

for raw in output.splitlines():
    line = raw.strip()
    if not line or " " not in line:
        continue
    pid, command = line.split(None, 1)
    if command == target or command.startswith(target + " "):
        print(pid)
PY
}

wait_for_process_clear() {
  local exec_path="$1"
  local tries="${2:-60}"
  for _ in $(seq 1 "$tries"); do
    if [[ -z "$(app_pids_for_executable "$exec_path")" ]]; then
      return 0
    fi
    sleep 0.2
  done
  return 1
}

terminate_app_processes_for_exec() {
  local exec_path="$1"
  local pid
  while read -r pid; do
    [[ -z "$pid" ]] && continue
    terminate_pid "$pid" "devapp process ${exec_path}" 120 || true
  done < <(app_pids_for_executable "$exec_path")
}

bundle_path_for_executable() {
  local exec_path="$1"
  python3 - "$exec_path" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1]).resolve()
parts = path.parts
for index, part in enumerate(parts):
    if part.endswith(".app"):
        print(str(Path(*parts[:index + 1])))
        raise SystemExit(0)
raise SystemExit(1)
PY
}

capture_autostart_proxy_state() {
  if defaults read "$DEV_BUNDLE_ID" autoStartProxy >/tmp/quotio-autostart-read.log 2>&1; then
    AUTOSTART_PROXY_WAS_SET=1
    AUTOSTART_PROXY_ORIGINAL="$(cat /tmp/quotio-autostart-read.log | tr -d '\n')"
  else
    AUTOSTART_PROXY_WAS_SET=0
    AUTOSTART_PROXY_ORIGINAL=""
  fi
}

enable_autostart_proxy_temporarily() {
  defaults write "$DEV_BUNDLE_ID" autoStartProxy -bool true
}

restore_autostart_proxy_state() {
  if [[ "$AUTOSTART_PROXY_WAS_SET" == "1" ]]; then
    if [[ "$AUTOSTART_PROXY_ORIGINAL" == "1" || "$AUTOSTART_PROXY_ORIGINAL" == "true" ]]; then
      defaults write "$DEV_BUNDLE_ID" autoStartProxy -bool true
    else
      defaults write "$DEV_BUNDLE_ID" autoStartProxy -bool false
    fi
  else
    defaults delete "$DEV_BUNDLE_ID" autoStartProxy >/dev/null 2>&1 || true
  fi
}

capture_test_ca_env_state() {
  if [[ -n "${QUOTIO_TEST_CA_FILE+x}" && -n "${QUOTIO_TEST_CA_FILE:-}" ]]; then
    TEST_CA_ENV_WAS_SET=1
    TEST_CA_ENV_ORIGINAL="$QUOTIO_TEST_CA_FILE"
  else
    TEST_CA_ENV_WAS_SET=0
    TEST_CA_ENV_ORIGINAL=""
  fi
}

set_test_ca_env_temporarily() {
  export QUOTIO_TEST_CA_FILE="$MITM_HOME/mitmproxy-ca-cert.pem"
}

restore_test_ca_env_state() {
  if [[ "$TEST_CA_ENV_WAS_SET" == "1" ]]; then
    export QUOTIO_TEST_CA_FILE="$TEST_CA_ENV_ORIGINAL"
  else
    unset QUOTIO_TEST_CA_FILE
  fi
}

current_autostart_proxy_state() {
  defaults read "$DEV_BUNDLE_ID" autoStartProxy 2>/dev/null | tr -d '\n'
}

capture_debug_test_ca_file_state() {
  if defaults read "$DEV_BUNDLE_ID" debugTestCAFile >/tmp/quotio-debug-test-ca-read.log 2>&1; then
    DEBUG_TEST_CA_FILE_WAS_SET=1
    DEBUG_TEST_CA_FILE_ORIGINAL="$(cat /tmp/quotio-debug-test-ca-read.log | tr -d '\n')"
  else
    DEBUG_TEST_CA_FILE_WAS_SET=0
    DEBUG_TEST_CA_FILE_ORIGINAL=""
  fi
}

set_debug_test_ca_file_temporarily() {
  defaults write "$DEV_BUNDLE_ID" debugTestCAFile "$MITM_HOME/mitmproxy-ca-cert.pem"
}

restore_debug_test_ca_file_state() {
  if [[ "$DEBUG_TEST_CA_FILE_WAS_SET" == "1" ]]; then
    defaults write "$DEV_BUNDLE_ID" debugTestCAFile "$DEBUG_TEST_CA_FILE_ORIGINAL"
  else
    defaults delete "$DEV_BUNDLE_ID" debugTestCAFile >/dev/null 2>&1 || true
  fi
}

start_mitm() {
  echo "[1/6] Bootstrapping mitmproxy runtime"
  mkdir -p "$MITM_DIR" "$MITM_HOME"
  if [[ ! -x "$MITM_VENV/bin/mitmdump" ]]; then
    python3 -m venv "$MITM_VENV"
    "$MITM_VENV/bin/pip" install mitmproxy
  fi

  echo "[2/6] Starting MITM on 127.0.0.1:${MITM_PORT}"
  BASELINE_FLOW_COUNT="$(wc -l < "$FLOW_FILE" 2>/dev/null | tr -d ' ' || echo 0)"
  local existing_mitm_pid
  existing_mitm_pid="$(lsof -tiTCP:"$MITM_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
  if [[ -n "$existing_mitm_pid" ]]; then
    local existing_mitm_cmd
    existing_mitm_cmd="$(ps -p "$existing_mitm_pid" -o command= || true)"
    if [[ "$existing_mitm_cmd" != *mitmdump* ]]; then
      echo "port ${MITM_PORT} is already in use by a non-mitmdump process: ${existing_mitm_cmd}" >&2
      exit 1
    fi
    echo "Reusing existing mitmdump pid=${existing_mitm_pid}"
  else
    "$MITM_VENV/bin/mitmdump" \
      --listen-host 127.0.0.1 \
      --listen-port "$MITM_PORT" \
      --set "confdir=$MITM_HOME" \
      -s "$MITM_SCRIPT" \
      >/tmp/quotio-mitmdump.log 2>&1 &
    MITM_PID="$!"
    MITM_OWNED_BY_SCRIPT=1
  fi

  for _ in $(seq 1 50); do
    [[ -f "$MITM_HOME/mitmproxy-ca-cert.pem" ]] && break
    sleep 0.2
  done
  require_file "$MITM_HOME/mitmproxy-ca-cert.pem" "mitmproxy CA cert"
}

prepare_auth() {
  echo "[3/6] Pointing Claude auth to local MITM"
  write_proxy_url "$CLAUDE_AUTH_PATH" "http://127.0.0.1:${MITM_PORT}"
}

setup_managed_mode() {
  MANAGED_MODE=1
  if [[ "$DEV_APP_WAS_RUNNING" != "1" || -z "$DEV_APP_PID" ]]; then
    echo "devapp client port ${CLIENT_PORT} is not listening. Start devapp first, or rerun with ALLOW_DIRECT_CORE_DEBUG=1 for direct-core debugging." >&2
    exit 1
  fi
  CURRENT_CORE_PID="$(lsof -tiTCP:"$CORE_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
  if [[ -n "$CURRENT_CORE_PID" ]]; then
    CURRENT_CORE_BIN="$(executable_path_for_pid "$CURRENT_CORE_PID")"
  fi
  if [[ -z "$CURRENT_CORE_BIN" ]]; then
    CURRENT_CORE_BIN="$FALLBACK_CORE_BIN"
  fi
  require_file "$CURRENT_CORE_BIN" "managed dev core binary"

  CORE_BACKUP_FILE="$(mktemp -t quotio-dev-core-backup)"
  cp "$CURRENT_CORE_BIN" "$CORE_BACKUP_FILE"

  echo "[4/6] Restarting devapp with patched managed core"
  capture_autostart_proxy_state
  capture_test_ca_env_state
  capture_debug_test_ca_file_state
  log_cleanup "captured autoStartProxy original='${AUTOSTART_PROXY_ORIGINAL:-<unset>}' was_set=${AUTOSTART_PROXY_WAS_SET}"
  log_cleanup "captured QUOTIO_TEST_CA_FILE original='${TEST_CA_ENV_ORIGINAL:-<unset>}' was_set=${TEST_CA_ENV_WAS_SET}"
  log_cleanup "captured debugTestCAFile original='${DEBUG_TEST_CA_FILE_ORIGINAL:-<unset>}' was_set=${DEBUG_TEST_CA_FILE_WAS_SET}"
  enable_autostart_proxy_temporarily
  set_test_ca_env_temporarily
  set_debug_test_ca_file_temporarily
  log_cleanup "autoStartProxy temporarily enabled current='$(current_autostart_proxy_state || true)'"
  log_cleanup "QUOTIO_TEST_CA_FILE temporarily set current='${QUOTIO_TEST_CA_FILE:-<unset>}'"
  log_cleanup "debugTestCAFile temporarily set current='$(defaults read "$DEV_BUNDLE_ID" debugTestCAFile 2>/dev/null | tr -d '\n' || true)'"
  terminate_pid "$DEV_APP_PID" "managed-mode devapp restart" 120 || true
  wait_for_port_clear "$CLIENT_PORT" 80 || true
  if [[ -n "$CURRENT_CORE_PID" ]]; then
    terminate_pid "$CURRENT_CORE_PID" "managed-mode existing core" 80 || true
  fi
  local lingering_core_pid
  lingering_core_pid="$(lsof -tiTCP:"$CORE_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
  if [[ -n "$lingering_core_pid" ]]; then
    terminate_pid "$lingering_core_pid" "managed-mode lingering core" 40 || true
  fi
  wait_for_port_clear "$CORE_PORT" 80 || true

  replace_file_atomically "$PATCHED_CORE_BIN" "$CURRENT_CORE_BIN"

  nohup "$DEV_APP_EXEC" >/tmp/quotio-devapp-mitm.log 2>&1 &
  RELAUNCHED_APP_PID="$!"

  if ! wait_for_listener "$CLIENT_PORT" 120; then
    echo "devapp failed to restore client listener on ${CLIENT_PORT}" >&2
    echo "See /tmp/quotio-devapp-mitm.log" >&2
    exit 1
  fi
  if ! wait_for_listener "$CORE_PORT" 120; then
    echo "managed dev core failed to restore internal listener on ${CORE_PORT}" >&2
    echo "See /tmp/quotio-devapp-mitm.log" >&2
    exit 1
  fi
}

relaunch_devapp_normally() {
  if [[ "$DEV_APP_WAS_RUNNING" != "1" ]]; then
    return 0
  fi

  log_cleanup "relaunch_devapp_normally begin bundle='${DEV_APP_BUNDLE}' exec='${DEV_APP_EXEC}'"

  if [[ -n "$DEV_APP_EXEC" ]]; then
    terminate_app_processes_for_exec "$DEV_APP_EXEC"
    wait_for_process_clear "$DEV_APP_EXEC" 80 || true
  fi

  if [[ -n "$DEV_APP_BUNDLE" && -d "$DEV_APP_BUNDLE" ]]; then
    if open -n -a "$DEV_APP_BUNDLE" >>"$CLEANUP_LOG" 2>&1; then
      log_cleanup "open -n -a succeeded"
    else
      log_cleanup "open -n -a failed"
    fi
  fi

  if wait_for_listener "$CLIENT_PORT" 150; then
    log_cleanup "client listener restored on ${CLIENT_PORT} via app bundle"
    return 0
  fi

  if [[ -n "$DEV_APP_EXEC" && -x "$DEV_APP_EXEC" ]]; then
    nohup "$DEV_APP_EXEC" >/tmp/quotio-devapp-normal.log 2>&1 &
    log_cleanup "fallback direct exec pid=$!"
    if wait_for_listener "$CLIENT_PORT" 150; then
      log_cleanup "client listener restored on ${CLIENT_PORT} via direct exec"
      return 0
    fi
  fi

  log_cleanup "client listener NOT restored on ${CLIENT_PORT}"
  return 1
}

restore_direct_core_baseline() {
  local live_client_pid=""
  local live_core_pid=""

  log_cleanup "restore_direct_core_baseline begin dev_app_was_running=${DEV_APP_WAS_RUNNING} current_core_bin='${CURRENT_CORE_BIN:-}'"

  live_client_pid="$(lsof -tiTCP:"$CLIENT_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
  live_core_pid="$(lsof -tiTCP:"$CORE_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"

  if [[ "$DEV_APP_WAS_RUNNING" == "1" ]]; then
    if [[ -z "$live_client_pid" || -z "$live_core_pid" ]]; then
      relaunch_devapp_normally || true
    fi
    return 0
  fi

  if [[ -n "$live_core_pid" ]]; then
    log_cleanup "direct-core baseline already has core listener pid=${live_core_pid}"
    return 0
  fi

  if [[ -n "$CURRENT_CORE_BIN" && -x "$CURRENT_CORE_BIN" ]]; then
    nohup "$CURRENT_CORE_BIN" -config "$CONFIG_PATH" >/tmp/quotio-original-core.log 2>&1 &
    log_cleanup "restarted original core from ${CURRENT_CORE_BIN}"
  elif [[ -x "$FALLBACK_CORE_BIN" ]]; then
    nohup "$FALLBACK_CORE_BIN" -config "$CONFIG_PATH" >/tmp/quotio-original-core.log 2>&1 &
    log_cleanup "restarted fallback core from ${FALLBACK_CORE_BIN}"
  else
    log_cleanup "no baseline core binary available for direct-core restore"
  fi
}

setup_direct_core_mode() {
  echo "[4/6] Replacing dev core on 127.0.0.1:${CORE_PORT}"
  CURRENT_CORE_PID="$(lsof -tiTCP:"$CORE_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
  if [[ -n "$CURRENT_CORE_PID" ]]; then
    CURRENT_CORE_BIN="$(executable_path_for_pid "$CURRENT_CORE_PID")"
  fi
  if [[ -z "$CURRENT_CORE_BIN" && -x "$FALLBACK_CORE_BIN" ]]; then
    CURRENT_CORE_BIN="$FALLBACK_CORE_BIN"
  fi
  if [[ -n "$CURRENT_CORE_PID" ]]; then
    kill "$CURRENT_CORE_PID" 2>/dev/null || true
    wait_for_port_clear "$CORE_PORT" 80 || true
  fi

  QUOTIO_TEST_CA_FILE="$MITM_HOME/mitmproxy-ca-cert.pem" \
    "$PATCHED_CORE_BIN" -config "$CONFIG_PATH" \
    >/tmp/quotio-patched-core.log 2>&1 &
  DIRECT_CORE_PID="$!"

  if ! wait_for_listener "$CORE_PORT" 120; then
    echo "patched core failed to listen on ${CORE_PORT}" >&2
    echo "See /tmp/quotio-patched-core.log" >&2
    exit 1
  fi
}

cleanup() {
  local exit_code="$?"
  if [[ "$CLEANUP_ALREADY_RAN" == "1" ]]; then
    exit "$exit_code"
  fi
  CLEANUP_ALREADY_RAN=1
  trap - EXIT INT TERM
  set +e
  log_cleanup "cleanup begin exit_code=${exit_code} managed_mode=${MANAGED_MODE} direct_core_pid=${DIRECT_CORE_PID:-<empty>}"
  log_cleanup "cleanup pre-state client_listener='$(lsof -tiTCP:"$CLIENT_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)' core_listener='$(lsof -tiTCP:"$CORE_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)' proxy_url='$(read_proxy_url "$CLAUDE_AUTH_PATH" 2>/dev/null || true)' autoStartProxy='$(current_autostart_proxy_state || true)'"

  if [[ -n "$CLAUDE_AUTH_PATH" && -f "$CLAUDE_AUTH_PATH" ]]; then
    restore_proxy_url "$ORIGINAL_PROXY_URL" 5 || true
  fi

  if [[ -n "$DIRECT_CORE_PID" ]] && kill -0 "$DIRECT_CORE_PID" 2>/dev/null; then
    terminate_pid "$DIRECT_CORE_PID" "direct-core patched core" 40 || true
    wait "$DIRECT_CORE_PID" 2>/dev/null || true
  fi

  if [[ "$MANAGED_MODE" == "1" ]]; then
    local live_app_pid
    local live_core_pid
    local lingering_core_pid
    live_app_pid="$(lsof -tiTCP:"$CLIENT_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
    if [[ -n "$live_app_pid" ]]; then
      terminate_pid "$live_app_pid" "cleanup live devapp" 120 || true
      wait_for_port_clear "$CLIENT_PORT" 80 || true
    fi
    if [[ -n "$DEV_APP_EXEC" ]]; then
      terminate_app_processes_for_exec "$DEV_APP_EXEC"
      wait_for_process_clear "$DEV_APP_EXEC" 80 || true
    fi
    live_core_pid="$(lsof -tiTCP:"$CORE_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
    if [[ -n "$live_core_pid" ]]; then
      terminate_pid "$live_core_pid" "cleanup live core" 40 || true
    fi
    lingering_core_pid="$(lsof -tiTCP:"$CORE_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
    if [[ -n "$lingering_core_pid" ]]; then
      terminate_pid "$lingering_core_pid" "cleanup lingering core" 40 || true
    fi
    wait_for_port_clear "$CORE_PORT" 80 || true

    if [[ -n "$CORE_BACKUP_FILE" && -f "$CORE_BACKUP_FILE" && -n "$CURRENT_CORE_BIN" ]]; then
      replace_file_atomically "$CORE_BACKUP_FILE" "$CURRENT_CORE_BIN" >/dev/null 2>&1 || true
      rm -f "$CORE_BACKUP_FILE" >/dev/null 2>&1 || true
      log_cleanup "restored managed core binary to ${CURRENT_CORE_BIN}"
    fi

    relaunch_devapp_normally || true
    restore_test_ca_env_state
    log_cleanup "QUOTIO_TEST_CA_FILE restored current='${QUOTIO_TEST_CA_FILE:-<unset>}'"
    restore_debug_test_ca_file_state
    log_cleanup "debugTestCAFile restored current='$(defaults read "$DEV_BUNDLE_ID" debugTestCAFile 2>/dev/null | tr -d '\n' || true)'"
    restore_autostart_proxy_state
    log_cleanup "autoStartProxy restored current='$(current_autostart_proxy_state || true)'"
  else
    restore_direct_core_baseline
  fi

  if [[ "$MITM_OWNED_BY_SCRIPT" == "1" && -n "$MITM_PID" ]] && kill -0 "$MITM_PID" 2>/dev/null; then
    terminate_pid "$MITM_PID" "owned mitmdump" 40 || true
    wait "$MITM_PID" 2>/dev/null || true
  fi

  log_cleanup "cleanup end client_listener='$(lsof -tiTCP:"$CLIENT_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)' core_listener='$(lsof -tiTCP:"$CORE_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)' proxy_url='$(read_proxy_url "$CLAUDE_AUTH_PATH" 2>/dev/null || true)' autoStartProxy='$(current_autostart_proxy_state || true)'"

  exit "$exit_code"
}

handle_interrupt() {
  exit 130
}

handle_terminate() {
  exit 143
}

trap cleanup EXIT
trap handle_interrupt INT
trap handle_terminate TERM

require_file "$CONFIG_PATH" "dev config"
require_file "$PATCHED_CORE_BIN" "patched dev core"
require_file "$MITM_SCRIPT" "mitm capture script"

{
  printf '\n=== watch-claude-mitm-session %s ===\n' "$(date '+%Y-%m-%d %H:%M:%S')"
} >>"$CLEANUP_LOG"

DEV_APP_PID="$(lsof -tiTCP:"$CLIENT_PORT" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
if [[ -n "$DEV_APP_PID" ]]; then
  DEV_APP_EXEC="$(executable_path_for_pid "$DEV_APP_PID")"
  if [[ -n "$DEV_APP_EXEC" && -x "$DEV_APP_EXEC" ]]; then
    DEV_APP_BUNDLE="$(bundle_path_for_executable "$DEV_APP_EXEC" 2>/dev/null || true)"
    DEV_APP_WAS_RUNNING=1
  fi
fi

CORE_PORT="$(config_value port)"
CONFIG_AUTH_DIR="$(config_value auth-dir)"
CLAUDE_AUTH_PATH="$(pick_claude_auth_file)"
ORIGINAL_PROXY_URL="$(read_proxy_url "$CLAUDE_AUTH_PATH")"

start_mitm
prepare_auth

if [[ "$ALLOW_DIRECT_CORE_DEBUG" == "1" ]]; then
  setup_direct_core_mode
else
  setup_managed_mode
fi

echo "[5/6] Ready"
echo "Dev app client port: ${CLIENT_PORT}"
echo "Claude auth file: ${CLAUDE_AUTH_PATH}"
echo "Saved proxy_url: ${ORIGINAL_PROXY_URL:-<empty>}"
echo
echo "现在去 Claude Code 正常发一句话。"
if [[ "$ALLOW_DIRECT_CORE_DEBUG" == "1" ]]; then
  echo "当前是 direct-core 调试模式；如果你平时没有把 Claude Code 指向 devapp，可先直接对 core ${CORE_PORT} 触发请求。"
else
  echo "当前是 managed mode；18417 应该继续由 devapp 监听。"
fi
echo
echo "脚本会等待最多 ${WAIT_TIMEOUT_SECONDS} 秒，捕获到第一条真实上游请求后自动打印结果并恢复现场。"
echo "注意：脚本只会恢复到你启动它之前的 proxy_url 状态；如果你启动前测试账号已经在 MITM 态，它不会替你改回正式代理。"

echo "[6/6] Waiting for first upstream Claude request..."
deadline=$((SECONDS + WAIT_TIMEOUT_SECONDS))
while (( SECONDS < deadline )); do
  current_flow_count="$(wc -l < "$FLOW_FILE" 2>/dev/null | tr -d ' ' || echo 0)"
  if [[ "$current_flow_count" -gt "$BASELINE_FLOW_COUNT" ]]; then
    summarize_flow
    exit 0
  fi
  sleep 1
done

echo "Timed out after ${WAIT_TIMEOUT_SECONDS}s without seeing a captured upstream request." >&2
echo "Troubleshooting logs: /tmp/quotio-mitmdump.log /tmp/quotio-devapp-mitm.log /tmp/quotio-patched-core.log" >&2
exit 1
