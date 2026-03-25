#!/bin/bash
set -euo pipefail

PRODUCTION_BUNDLE_ID="dev.quotio.desktop"
PRODUCTION_APP_SUPPORT="Quotio"
PRODUCTION_AUTH_DIR=".cli-proxy-api"
PRODUCTION_PROXY_PORT=18317

bundle_id="${1:-dev.quotio.desktop.dev}"

sanitize_suffix() {
  printf '%s' "$1" | sed -E 's/[^A-Za-z0-9._-]+/-/g'
}

if [[ "$bundle_id" == "$PRODUCTION_BUNDLE_ID" ]]; then
  namespace_suffix=""
  app_support_name="$PRODUCTION_APP_SUPPORT"
  auth_dir_name="$PRODUCTION_AUTH_DIR"
  proxy_port="$PRODUCTION_PROXY_PORT"
else
  if [[ "$bundle_id" == "$PRODUCTION_BUNDLE_ID".* ]]; then
    raw_suffix="${bundle_id#${PRODUCTION_BUNDLE_ID}.}"
  else
    raw_suffix="$bundle_id"
  fi
  namespace_suffix="$(sanitize_suffix "$raw_suffix")"
  [[ -n "$namespace_suffix" ]] || namespace_suffix="test"
  app_support_name="Quotio-$namespace_suffix"
  auth_dir_name=".cli-proxy-api-$namespace_suffix"
  proxy_port=18017
fi

internal_port=$((proxy_port + 10000))
if (( internal_port > 65535 )); then
  internal_port=$((49152 + proxy_port % 1000))
fi

printf 'bundle_id=%s\n' "$bundle_id"
printf 'is_primary=%s\n' "$([[ "$bundle_id" == "$PRODUCTION_BUNDLE_ID" ]] && echo true || echo false)"
printf 'defaults_domain=%s\n' "$bundle_id"
printf 'application_support=%s\n' "$HOME/Library/Application Support/$app_support_name"
printf 'auth_dir=%s\n' "$HOME/$auth_dir_name"
printf 'keychain_prefix=%s\n' "$bundle_id"
printf 'proxy_port=%s\n' "$proxy_port"
printf 'internal_proxy_port=%s\n' "$internal_port"
