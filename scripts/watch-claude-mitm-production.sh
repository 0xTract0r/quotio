#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export DEV_BUNDLE_ID="${DEV_BUNDLE_ID:-dev.quotio.desktop}"
export CLIENT_PORT="${CLIENT_PORT:-$(defaults read "$DEV_BUNDLE_ID" proxyPort 2>/dev/null || echo 18317)}"
export CONFIG_PATH="${CONFIG_PATH:-$HOME/Library/Application Support/Quotio/config.yaml}"
export FALLBACK_CORE_BIN="${FALLBACK_CORE_BIN:-$HOME/Library/Application Support/Quotio/CLIProxyAPI}"
export MITM_PORT="${MITM_PORT:-19092}"

exec "${SCRIPT_DIR}/watch-claude-mitm-session.sh"
