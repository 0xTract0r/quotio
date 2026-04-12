#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

TEST_BUNDLE_ID="dev.quotio.desktop.test"
TEST_PRODUCT_NAME="Quotio Test"
TEST_APP_PATH="${PROJECT_DIR}/build/test-app/${TEST_PRODUCT_NAME}.app"
TEST_AUTH_DIR="${HOME}/.cli-proxy-api-test"
PROD_AUTH_DIR="${HOME}/.cli-proxy-api"
LOG_FILE="${PROJECT_DIR}/build/runtime-isolation-smoke.log"
TEST_AUTH_BACKUP=""
TEST_DEFAULTS_BACKUP=""
CREATED_PROD_DIR="false"
EXPECTED_SCAN="[DirectAuthFileService] Scanning direct auth files from ${TEST_AUTH_DIR}"
EXPECTED_LOAD="[DirectAuthFileService] Loaded 1 direct auth file(s) from ${TEST_AUTH_DIR}"

cleanup() {
    pkill -x "${TEST_PRODUCT_NAME}" >/dev/null 2>&1 || true

    if [[ -n "${TEST_AUTH_BACKUP}" && -d "${TEST_AUTH_BACKUP}" ]]; then
        rm -rf "${TEST_AUTH_DIR}"
        mv "${TEST_AUTH_BACKUP}" "${TEST_AUTH_DIR}"
    else
        rm -rf "${TEST_AUTH_DIR}"
    fi

    if [[ -n "${TEST_DEFAULTS_BACKUP}" && -f "${TEST_DEFAULTS_BACKUP}" ]]; then
        defaults import "${TEST_BUNDLE_ID}" "${TEST_DEFAULTS_BACKUP}" >/dev/null 2>&1 || true
        rm -f "${TEST_DEFAULTS_BACKUP}"
    else
        defaults delete "${TEST_BUNDLE_ID}" >/dev/null 2>&1 || true
    fi

    if [[ "${CREATED_PROD_DIR}" == "true" ]]; then
        rm -rf "${PROD_AUTH_DIR}"
    fi
}

regex_escape() {
    printf '%s' "$1" | sed 's/[][(){}.^$?+*|\\/]/\\&/g'
}

trap cleanup EXIT

print_header "Runtime Isolation Smoke" 50
print_summary "Smoke Configuration" \
    "Bundle ID" "${TEST_BUNDLE_ID}" \
    "App" "${TEST_APP_PATH}" \
    "Prod Auth Dir" "${PROD_AUTH_DIR}" \
    "Test Auth Dir" "${TEST_AUTH_DIR}" \
    "Log File" "${LOG_FILE}"

mkdir -p "${PROJECT_DIR}/build"
rm -f "${LOG_FILE}"

if [[ -d "${TEST_AUTH_DIR}" ]]; then
    TEST_AUTH_BACKUP="$(mktemp -d "${TMPDIR:-/tmp}/quotio-test-auth-backup.XXXXXX")"
    rm -rf "${TEST_AUTH_BACKUP}"
    mv "${TEST_AUTH_DIR}" "${TEST_AUTH_BACKUP}"
fi

if defaults export "${TEST_BUNDLE_ID}" - > /dev/null 2>&1; then
    TEST_DEFAULTS_BACKUP="$(mktemp "${TMPDIR:-/tmp}/quotio-test-defaults.XXXXXX.plist")"
    defaults export "${TEST_BUNDLE_ID}" "${TEST_DEFAULTS_BACKUP}" >/dev/null 2>&1
fi

if [[ ! -d "${PROD_AUTH_DIR}" ]]; then
    mkdir -p "${PROD_AUTH_DIR}"
    CREATED_PROD_DIR="true"
fi

mkdir -p "${TEST_AUTH_DIR}"
cat > "${TEST_AUTH_DIR}/codex-runtime-isolation-smoke.json" <<'EOF'
{
  "type": "codex",
  "email": "runtime-isolation-smoke@example.com"
}
EOF

defaults write "${TEST_BUNDLE_ID}" hasCompletedOnboarding -bool true
defaults write "${TEST_BUNDLE_ID}" operatingMode -string monitor
defaults write "${TEST_BUNDLE_ID}" showInDock -bool true
defaults write "${TEST_BUNDLE_ID}" appLanguage -string en
defaults write "${TEST_BUNDLE_ID}" runtimeIsolationDebugLogPath -string "${LOG_FILE}"

pkill -x "${TEST_PRODUCT_NAME}" >/dev/null 2>&1 || true

log_step "Building isolated test app..."
"${SCRIPT_DIR}/build-test-app.sh" >/dev/null

log_step "Launching ${TEST_PRODUCT_NAME}..."
open -n "${TEST_APP_PATH}" --args --runtime-isolation-debug-log-path "${LOG_FILE}"

APP_STARTED="false"
for _ in $(seq 1 20); do
    if pgrep -x "${TEST_PRODUCT_NAME}" >/dev/null 2>&1; then
        APP_STARTED="true"
        break
    fi
    sleep 1
done

if [[ "${APP_STARTED}" != "true" ]]; then
    log_error "${TEST_PRODUCT_NAME} did not start"
    exit 1
fi

for _ in $(seq 1 20); do
    if [[ -f "${LOG_FILE}" ]] && grep -F "${EXPECTED_SCAN}" "${LOG_FILE}" >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

log_step "Stopping ${TEST_PRODUCT_NAME}..."
pkill -x "${TEST_PRODUCT_NAME}" >/dev/null 2>&1 || true
sleep 2

PROD_SCAN_REGEX="\\[DirectAuthFileService\\] Scanning direct auth files from $(regex_escape "${PROD_AUTH_DIR}")$"

if ! grep -F "${EXPECTED_SCAN}" "${LOG_FILE}" >/dev/null 2>&1; then
    log_error "Did not observe scan of test auth directory"
    tail -n 40 "${LOG_FILE}" || true
    exit 1
fi

if ! grep -F "${EXPECTED_LOAD}" "${LOG_FILE}" >/dev/null 2>&1; then
    log_error "Did not observe expected auth file count from test auth directory"
    tail -n 40 "${LOG_FILE}" || true
    exit 1
fi

if grep -E "${PROD_SCAN_REGEX}" "${LOG_FILE}" >/dev/null 2>&1; then
    log_error "Observed scan of production auth directory"
    tail -n 40 "${LOG_FILE}" || true
    exit 1
fi

print_summary "Smoke Passed" \
    "Verified Scan Path" "${TEST_AUTH_DIR}" \
    "Rejected Scan Path" "${PROD_AUTH_DIR}" \
    "Observed Account" "runtime-isolation-smoke@example.com"
