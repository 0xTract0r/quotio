#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export CORE_PORT="${CORE_PORT:-28317}"
export CONFIG_PATH="${CONFIG_PATH:-$HOME/Library/Application Support/Quotio/config.yaml}"
export FLOW_FILE="${FLOW_FILE:-/tmp/quotio-mitm/openai-flows.jsonl}"
export SKIP_TRIGGER="${SKIP_TRIGGER:-1}"

exec "${SCRIPT_DIR}/verify-codex-mitm-capture.sh"
