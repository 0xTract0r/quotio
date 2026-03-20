#!/bin/bash
set -euo pipefail

PROD_BIN="${PROD_BIN:-$HOME/Library/Application Support/Quotio/CLIProxyAPI}"
BACKUP_BIN="${BACKUP_BIN:-}"
EXECUTE="${EXECUTE:-0}"

require_file() {
  local path="$1"
  local label="$2"
  if [[ ! -f "$path" ]]; then
    echo "$label not found: $path" >&2
    exit 1
  fi
}

replace_file_atomically() {
  local src="$1"
  local dest="$2"
  local dest_dir
  local dest_name
  local temp_path

  dest_dir="$(dirname "$dest")"
  dest_name="$(basename "$dest")"
  temp_path="$(mktemp "${dest_dir}/.${dest_name}.rollback.XXXXXX")"
  cp "$src" "$temp_path"
  chmod 755 "$temp_path"
  mv "$temp_path" "$dest"
}

if [[ -z "$BACKUP_BIN" ]]; then
  echo "Set BACKUP_BIN=/path/to/CLIProxyAPI.<timestamp>.bak" >&2
  exit 1
fi

require_file "$PROD_BIN" "production CLIProxyAPI binary"
require_file "$BACKUP_BIN" "backup CLIProxyAPI binary"

echo "Rollback plan"
echo "  prod_bin   : $PROD_BIN"
echo "  backup_bin : $BACKUP_BIN"
echo "  execute    : $EXECUTE"
echo
echo "Note: restoring the on-disk binary alone does not affect the already running production core."
echo "You still need one controlled production proxy restart after the rollback swap."

if [[ "$EXECUTE" != "1" ]]; then
  echo
  echo "Dry-run only. To perform rollback, rerun with EXECUTE=1."
  exit 0
fi

replace_file_atomically "$BACKUP_BIN" "$PROD_BIN"

echo
echo "Rollback binary swap completed."
echo "Next step required: perform one controlled production proxy restart."
