#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_PATH="${PROJECT_DIR}/build/test-app/Quotio Test.app"

"${SCRIPT_DIR}/build-test-app.sh"

open -n "${APP_PATH}"
