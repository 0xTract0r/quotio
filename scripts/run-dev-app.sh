#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="Quotio"
SCHEME="${SCHEME:-Quotio}"
CONFIGURATION="${CONFIGURATION:-Debug}"
DERIVED_DATA_PATH="${PROJECT_DIR}/build/DerivedData-dev"
EXPECTED_APP_PATH="${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}/Quotio Dev.app"
DEV_EXECUTABLE_PATTERN="/Quotio Dev.app/Contents/MacOS/Quotio Dev"

if [[ ! -f "${PROJECT_DIR}/Config/Local.xcconfig" ]]; then
    echo "缺少 Config/Local.xcconfig。先执行：cp Config/Local.xcconfig.example Config/Local.xcconfig" >&2
    exit 1
fi

echo "[1/3] Building ${SCHEME} (${CONFIGURATION}) to ${DERIVED_DATA_PATH}"
xcodebuild \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    build \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

APP_PATH=""
if [[ -d "${EXPECTED_APP_PATH}" ]]; then
    APP_PATH="${EXPECTED_APP_PATH}"
else
    APP_PATH="$(find "${DERIVED_DATA_PATH}" -path "*${CONFIGURATION}/*Quotio Dev.app" -type d | head -n 1)"
fi

if [[ -z "${APP_PATH}" || ! -d "${APP_PATH}" ]]; then
    echo "未找到 Quotio Dev.app。预期路径：${EXPECTED_APP_PATH}" >&2
    exit 1
fi

echo "[2/3] Restarting existing Quotio Dev if needed"
pkill -f "${DEV_EXECUTABLE_PATTERN}" 2>/dev/null || true
sleep 1

echo "[3/3] Opening ${APP_PATH}"
open "${APP_PATH}"

echo "Dev app ready: ${APP_PATH}"
