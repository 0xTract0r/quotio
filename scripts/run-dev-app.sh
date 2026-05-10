#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="Quotio"
SCHEME="${SCHEME:-Quotio}"
CONFIGURATION="${CONFIGURATION:-Debug}"
DERIVED_DATA_PATH="${PROJECT_DIR}/build/DerivedData-dev"

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/dev-app-utils.sh"

EXPECTED_APP_PATH="$(dev_app_path "${DERIVED_DATA_PATH}" "${CONFIGURATION}")"
DEV_EXECUTABLE_PATTERN="/${DEV_PRODUCT_NAME}.app/Contents/MacOS/${DEV_PRODUCT_NAME}"

echo "[1/3] Building ${SCHEME} (${CONFIGURATION}) to ${DERIVED_DATA_PATH}"
build_isolated_dev_app "${PROJECT_DIR}" "${SCHEME}" "${CONFIGURATION}" "${DERIVED_DATA_PATH}"

APP_PATH=""
if [[ -d "${EXPECTED_APP_PATH}" ]]; then
    APP_PATH="${EXPECTED_APP_PATH}"
else
    APP_PATH="$(find "${DERIVED_DATA_PATH}" -path "*${CONFIGURATION}/*Quotio Dev.app" -type d | head -n 1)"
fi

if [[ -z "${APP_PATH}" || ! -d "${APP_PATH}" ]]; then
    echo "未找到 ${DEV_PRODUCT_NAME}.app。预期路径：${EXPECTED_APP_PATH}" >&2
    exit 1
fi

validate_isolated_dev_app_bundle "${APP_PATH}"

echo "[2/3] Restarting existing Quotio Dev if needed"
pkill -f "${DEV_EXECUTABLE_PATTERN}" 2>/dev/null || true
sleep 1

echo "[3/3] Opening ${APP_PATH}"
open "${APP_PATH}"

echo "Dev app ready: ${APP_PATH}"
