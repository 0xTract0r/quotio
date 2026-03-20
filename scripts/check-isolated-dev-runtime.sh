#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INSPECT_SCRIPT="$SCRIPT_DIR/inspect-runtime-profile.sh"

PRIMARY_BUNDLE_ID="${PRIMARY_BUNDLE_ID:-dev.quotio.desktop}"
DEV_BUNDLE_ID="${DEV_BUNDLE_ID:-dev.quotio.desktop.dev}"

if [[ ! -x "$INSPECT_SCRIPT" ]]; then
  echo "inspect script not executable: $INSPECT_SCRIPT" >&2
  exit 1
fi

read_profile() {
  local bundle_id="$1"
  "$INSPECT_SCRIPT" "$bundle_id"
}

profile_value() {
  local profile="$1"
  local key="$2"
  printf '%s\n' "$profile" | awk -F= -v k="$key" '$1==k {sub($1 "=",""); print}'
}

internal_port_from_user_port() {
  local user_port="$1"
  local internal_port=$((user_port + 10000))
  if (( internal_port > 65535 )); then
    internal_port=$((49152 + user_port % 1000))
  fi
  printf '%s\n' "$internal_port"
}

listener_pid() {
  local port="$1"
  lsof -ti "tcp:$port" -sTCP:LISTEN 2>/dev/null | head -n 1 || true
}

defaults_value() {
  local domain="$1"
  local key="$2"
  defaults read "$domain" "$key" 2>/dev/null || true
}

primary_profile="$(read_profile "$PRIMARY_BUNDLE_ID")"
dev_profile="$(read_profile "$DEV_BUNDLE_ID")"

primary_default_port="$(profile_value "$primary_profile" proxy_port)"
primary_defaults_port="$(defaults_value "$PRIMARY_BUNDLE_ID" proxyPort)"
primary_port="${primary_defaults_port:-$primary_default_port}"
primary_internal_port="$(internal_port_from_user_port "$primary_port")"
primary_auth_dir="$(profile_value "$primary_profile" auth_dir)"
primary_app_support="$(profile_value "$primary_profile" application_support)"

dev_default_port="$(profile_value "$dev_profile" proxy_port)"
dev_defaults_port="$(defaults_value "$DEV_BUNDLE_ID" proxyPort)"
dev_port="${dev_defaults_port:-$dev_default_port}"
dev_internal_port="$(internal_port_from_user_port "$dev_port")"
dev_auth_dir="$(profile_value "$dev_profile" auth_dir)"
dev_app_support="$(profile_value "$dev_profile" application_support)"

echo "== Runtime Profiles =="
echo "[primary]"
echo "$primary_profile"
echo
echo "[dev]"
echo "$dev_profile"
echo

echo "== Defaults =="
echo "primary proxyPort(default): $primary_default_port"
echo "primary proxyPort(current): ${primary_defaults_port:-<unset>}"
echo "dev proxyPort(default): $dev_default_port"
echo "dev proxyPort(current): ${dev_defaults_port:-<unset>}"
echo

echo "== Paths =="
for path in "$primary_app_support" "$dev_app_support" "$primary_auth_dir" "$dev_auth_dir"; do
  if [[ -e "$path" ]]; then
    echo "exists  $path"
  else
    echo "missing $path"
  fi
done
echo

echo "== Listeners =="
for item in \
  "primary client:$primary_port" \
  "primary internal:$primary_internal_port" \
  "dev client:$dev_port" \
  "dev internal:$dev_internal_port"
do
  label="${item%%:*}"
  port="${item##*:}"
  pid="$(listener_pid "$port")"
  if [[ -n "$pid" ]]; then
    cmd="$(ps -p "$pid" -o comm= | xargs || true)"
    echo "listening $label port=$port pid=$pid cmd=$cmd"
  else
    echo "idle      $label port=$port"
  fi
done
echo

port_items=$(
  cat <<EOF
primary client:$primary_port
primary internal:$primary_internal_port
dev client:$dev_port
dev internal:$dev_internal_port
EOF
)

while IFS= read -r left; do
  [[ -n "$left" ]] || continue
  left_label="${left%%:*}"
  left_port="${left##*:}"
  while IFS= read -r right; do
    [[ -n "$right" ]] || continue
    right_label="${right%%:*}"
    right_port="${right##*:}"
    [[ "$left_label" == "$right_label" ]] && continue
    if [[ "$left_port" == "$right_port" ]]; then
      echo "ERROR: port overlap between '$left_label' and '$right_label' on $left_port" >&2
      exit 2
    fi
  done <<<"$port_items"
done <<<"$port_items"

if [[ "$primary_auth_dir" == "$dev_auth_dir" || "$primary_app_support" == "$dev_app_support" ]]; then
  echo "ERROR: runtime paths overlap" >&2
  exit 3
fi

echo "Isolation baseline looks valid."
