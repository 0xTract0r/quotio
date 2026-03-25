#!/bin/bash
set -euo pipefail

PRIMARY_BUNDLE_ID="${PRIMARY_BUNDLE_ID:-dev.quotio.desktop}"
DEV_BUNDLE_ID="${DEV_BUNDLE_ID:-dev.quotio.desktop.dev}"
DEFAULT_PRIMARY_PORT=18317
DEFAULT_DEV_PORT=18017
WRITE_DEFAULTS=false

if [[ "${1:-}" == "--write" ]]; then
  WRITE_DEFAULTS=true
fi

defaults_value() {
  local domain="$1"
  local key="$2"
  defaults read "$domain" "$key" 2>/dev/null || true
}

internal_port_from_user_port() {
  local user_port="$1"
  local internal_port=$((user_port + 10000))
  if (( internal_port > 65535 )); then
    internal_port=$((49152 + user_port % 1000))
  fi
  printf '%s\n' "$internal_port"
}

port_in_use() {
  local port="$1"
  lsof -i "tcp:$port" -sTCP:LISTEN >/dev/null 2>&1
}

primary_current_port="$(defaults_value "$PRIMARY_BUNDLE_ID" proxyPort)"
primary_port="${primary_current_port:-$DEFAULT_PRIMARY_PORT}"
primary_internal_port="$(internal_port_from_user_port "$primary_port")"

dev_current_port="$(defaults_value "$DEV_BUNDLE_ID" proxyPort)"
if [[ -n "$dev_current_port" ]]; then
  dev_current_internal_port="$(internal_port_from_user_port "$dev_current_port")"
else
  dev_current_internal_port=""
fi

candidate_ports=""
for port in 18017 18117 18217 18417 18517 18617 18717 18817 18917 19017; do
  candidate_ports+="$port"$'\n'
done

recommended_port=""
while IFS= read -r candidate; do
  [[ -n "$candidate" ]] || continue
  candidate_internal="$(internal_port_from_user_port "$candidate")"

  [[ "$candidate" == "$primary_port" ]] && continue
  [[ "$candidate_internal" == "$primary_internal_port" ]] && continue
  [[ "$candidate" == "$primary_internal_port" ]] && continue
  [[ "$candidate_internal" == "$primary_port" ]] && continue

  if port_in_use "$candidate" || port_in_use "$candidate_internal"; then
    continue
  fi

  recommended_port="$candidate"
  break
done <<<"$candidate_ports"

if [[ -z "$recommended_port" ]]; then
  echo "No safe candidate port found." >&2
  exit 1
fi

recommended_internal_port="$(internal_port_from_user_port "$recommended_port")"

echo "primary_bundle_id=$PRIMARY_BUNDLE_ID"
echo "primary_proxy_port=$primary_port"
echo "primary_internal_port=$primary_internal_port"
echo "dev_bundle_id=$DEV_BUNDLE_ID"
echo "dev_proxy_port_current=${dev_current_port:-<unset>}"
echo "dev_internal_port_current=${dev_current_internal_port:-<unset>}"
echo "recommended_dev_proxy_port=$recommended_port"
echo "recommended_dev_internal_port=$recommended_internal_port"

if $WRITE_DEFAULTS; then
  defaults write "$DEV_BUNDLE_ID" proxyPort -int "$recommended_port"
  echo "wrote_defaults_domain=$DEV_BUNDLE_ID"
  echo "wrote_proxy_port=$recommended_port"
else
  echo "next_step=defaults write $DEV_BUNDLE_ID proxyPort -int $recommended_port"
fi
