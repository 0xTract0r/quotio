#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

PROD_BIN="${PROD_BIN:-$HOME/Library/Application Support/Quotio/CLIProxyAPI}"
PATCHED_BIN="${PATCHED_BIN:-$ROOT_DIR/build/CLIProxyAPIPlus/CLIProxyAPI}"
PROD_CORE_PORT="${PROD_CORE_PORT:-28317}"
PROD_CLIENT_PORT="${PROD_CLIENT_PORT:-18317}"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/Library/Application Support/Quotio/backups}"
TIMESTAMP="${TIMESTAMP:-$(date '+%Y%m%d-%H%M%S')}"
BACKUP_BIN="${BACKUP_BIN:-$BACKUP_ROOT/CLIProxyAPI.${TIMESTAMP}.bak}"
EXECUTE="${EXECUTE:-0}"

hash_file() {
  shasum -a 256 "$1" | awk '{print $1}'
}

require_file() {
  local path="$1"
  local label="$2"
  if [[ ! -f "$path" ]]; then
    echo "$label not found: $path" >&2
    exit 1
  fi
}

listener_pid() {
  local port="$1"
  local output=""
  output="$(lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null || true)"
  printf '%s\n' "$output" | sed -n '1p'
}

executable_path_for_pid() {
  local pid="$1"
  python3 - "$pid" <<'PY'
import subprocess
import sys

pid = sys.argv[1]
try:
    output = subprocess.check_output(["lsof", "-p", pid], text=True, stderr=subprocess.DEVNULL)
except Exception:
    raise SystemExit(0)

for raw in output.splitlines():
    parts = raw.split()
    if len(parts) >= 9 and parts[3] == "txt":
        print(" ".join(parts[8:]))
        raise SystemExit(0)
PY
}

replace_file_atomically() {
  local src="$1"
  local dest="$2"
  local dest_dir
  local dest_name
  local temp_path

  dest_dir="$(dirname "$dest")"
  dest_name="$(basename "$dest")"
  temp_path="$(mktemp "${dest_dir}/.${dest_name}.promote.XXXXXX")"
  cp "$src" "$temp_path"
  chmod 755 "$temp_path"
  mv "$temp_path" "$dest"
}

require_file "$PROD_BIN" "production CLIProxyAPI binary"
require_file "$PATCHED_BIN" "patched CLIProxyAPIPlus binary"

mkdir -p "$BACKUP_ROOT"

prod_core_pid="$(listener_pid "$PROD_CORE_PORT")"
prod_client_pid="$(listener_pid "$PROD_CLIENT_PORT")"
prod_core_exec=""
prod_client_exec=""
if [[ -n "$prod_core_pid" ]]; then
  prod_core_exec="$(executable_path_for_pid "$prod_core_pid")"
fi
if [[ -n "$prod_client_pid" ]]; then
  prod_client_exec="$(executable_path_for_pid "$prod_client_pid")"
fi

prod_hash="$(hash_file "$PROD_BIN")"
patched_hash="$(hash_file "$PATCHED_BIN")"

echo "Production promotion plan"
echo "  prod_bin       : $PROD_BIN"
echo "  patched_bin    : $PATCHED_BIN"
echo "  backup_bin     : $BACKUP_BIN"
echo "  prod_hash      : $prod_hash"
echo "  patched_hash   : $patched_hash"
echo "  client_port    : $PROD_CLIENT_PORT (pid=${prod_client_pid:-<none>})"
echo "  client_exec    : ${prod_client_exec:-<unknown>}"
echo "  core_port      : $PROD_CORE_PORT (pid=${prod_core_pid:-<none>})"
echo "  core_exec      : ${prod_core_exec:-<unknown>}"
echo

if [[ "$prod_hash" == "$patched_hash" ]]; then
  echo "Production binary already matches the patched build."
  exit 0
fi

cat <<EOF
Impact notes:
  1. Replacing the on-disk binary alone does NOT activate the patch for the running production core.
  2. To take effect, you must schedule one controlled production proxy restart after the file swap.
  3. Per repository safety rules, this script defaults to dry-run and does not touch production unless EXECUTE=1.

Recommended window:
  - wait until current production traffic can tolerate one proxy restart
  - keep Quotio.app running
  - replace the binary first
  - then perform exactly one controlled proxy restart from the app/UI
  - immediately run MITM verification against production

Rollback target:
  $BACKUP_BIN
EOF

if [[ "$EXECUTE" != "1" ]]; then
  echo
  echo "Dry-run only. To perform the binary swap, rerun with EXECUTE=1."
  exit 0
fi

cp "$PROD_BIN" "$BACKUP_BIN"
replace_file_atomically "$PATCHED_BIN" "$PROD_BIN"

echo
echo "Binary swap completed."
echo "  backup_created : $BACKUP_BIN"
echo "  new_prod_hash  : $(hash_file "$PROD_BIN")"
echo
echo "Next step required:"
echo "  Perform one controlled production proxy restart so Quotio loads the new binary."
echo "  This script intentionally does not stop the production core for you."
