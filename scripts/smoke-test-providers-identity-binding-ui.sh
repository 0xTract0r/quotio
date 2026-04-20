#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

DEV_BUNDLE_ID="${DEV_BUNDLE_ID:-dev.quotio.desktop.dev}"
DEV_PRODUCT_NAME="${DEV_PRODUCT_NAME:-Quotio Dev}"
DEV_DERIVED_DATA="${DEV_DERIVED_DATA:-${PROJECT_DIR}/build/DerivedData-dev}"
DEV_APP_PATH="${DEV_DERIVED_DATA}/Build/Products/Debug/${DEV_PRODUCT_NAME}.app"
DEV_EXECUTABLE="${DEV_APP_PATH}/Contents/MacOS/${DEV_PRODUCT_NAME}"
DEV_EXECUTABLE_PATTERN="/${DEV_PRODUCT_NAME}.app/Contents/MacOS/${DEV_PRODUCT_NAME}"
DEV_CLIENT_PORT="${DEV_CLIENT_PORT:-18017}"
DEV_MANAGEMENT_PORT="${DEV_MANAGEMENT_PORT:-28017}"
DEV_MANAGEMENT_KEY_SERVICE="${DEV_MANAGEMENT_KEY_SERVICE:-dev.quotio.desktop.local-management.dev}"
DEV_MANAGEMENT_KEY_ACCOUNT="${DEV_MANAGEMENT_KEY_ACCOUNT:-local-management-key}"
ACCOUNT_QUERY="${ACCOUNT_QUERY:-codex-cory2btc@gmail.com-pro.json}"
ACCOUNT_PROVIDER="${ACCOUNT_PROVIDER:-codex}"
SMOKE_REMARK="${SMOKE_REMARK:-UI Smoke Remark}"
TEST_LOG_FILE="${PROJECT_DIR}/build/providers-identity-binding-ui-smoke.log"
TEST_DEFAULTS_BACKUP=""
DEV_MANAGEMENT_KEY=""
DEV_APP_PID=""

cleanup() {
    if [[ -n "${DEV_APP_PID}" ]]; then
        kill "${DEV_APP_PID}" >/dev/null 2>&1 || true
        wait "${DEV_APP_PID}" 2>/dev/null || true
        DEV_APP_PID=""
    fi

    pkill -f "${DEV_EXECUTABLE_PATTERN}" >/dev/null 2>&1 || true

    if [[ -n "${TEST_DEFAULTS_BACKUP}" && -f "${TEST_DEFAULTS_BACKUP}" ]]; then
        defaults import "${DEV_BUNDLE_ID}" "${TEST_DEFAULTS_BACKUP}" >/dev/null 2>&1 || true
        rm -f "${TEST_DEFAULTS_BACKUP}"
    fi
}

resolve_management_key() {
    DEV_MANAGEMENT_KEY="$(security find-generic-password -s "${DEV_MANAGEMENT_KEY_SERVICE}" -a "${DEV_MANAGEMENT_KEY_ACCOUNT}" -w 2>/dev/null || true)"
    if [[ -z "${DEV_MANAGEMENT_KEY}" ]]; then
        log_error "Failed to resolve dev management key from Keychain service ${DEV_MANAGEMENT_KEY_SERVICE}"
        exit 1
    fi
}

wait_for_health() {
    local url="$1"
    for _ in $(seq 1 40); do
        if curl -fsS "${url}" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done

    log_error "Timed out waiting for ${url}"
    tail -n 120 "${TEST_LOG_FILE}" || true
    exit 1
}

wait_for_log_line() {
    local pattern="$1"
    local timeout_seconds="${2:-30}"

    for _ in $(seq 1 "${timeout_seconds}"); do
        if grep -Fq "${pattern}" "${TEST_LOG_FILE}" 2>/dev/null; then
            return 0
        fi
        sleep 1
    done

    log_error "Timed out waiting for log line: ${pattern}"
    tail -n 120 "${TEST_LOG_FILE}" || true
    exit 1
}

build_dev_app() {
    if [[ ! -f "${PROJECT_DIR}/Config/Local.xcconfig" ]]; then
        log_error "Missing Config/Local.xcconfig"
        exit 1
    fi

    log_step "Building ${DEV_PRODUCT_NAME}..."
    xcodebuild \
        -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME}" \
        -configuration Debug \
        -derivedDataPath "${DEV_DERIVED_DATA}" \
        build \
        CODE_SIGN_IDENTITY="-" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO >/dev/null

    if [[ ! -x "${DEV_EXECUTABLE}" ]]; then
        log_error "Dev executable not found: ${DEV_EXECUTABLE}"
        exit 1
    fi
}

prepare_defaults_fixture() {
    local metadata_key="${ACCOUNT_PROVIDER}:auth:${ACCOUNT_QUERY}"

    defaults delete "${DEV_BUNDLE_ID}" identityPackages.storage >/dev/null 2>&1 || true
    defaults delete "${DEV_BUNDLE_ID}" identityPackages.bindings >/dev/null 2>&1 || true
    defaults write "${DEV_BUNDLE_ID}" hasCompletedOnboarding -bool true
    defaults write "${DEV_BUNDLE_ID}" operatingMode -string local
    defaults write "${DEV_BUNDLE_ID}" showInDock -bool true
    defaults write "${DEV_BUNDLE_ID}" appLanguage -string en
    defaults write "${DEV_BUNDLE_ID}" runtimeIsolationDebugLogPath -string "${TEST_LOG_FILE}"
    defaults write "${DEV_BUNDLE_ID}" providers.accountRemarks -dict "${metadata_key}" "${SMOKE_REMARK}"
}

launch_dev_app() {
    : > "${TEST_LOG_FILE}"

    pkill -f "${DEV_EXECUTABLE_PATTERN}" >/dev/null 2>&1 || true
    sleep 1

    log_step "Launching ${DEV_PRODUCT_NAME} with identity binding smoke hook..."
    env \
        QUOTIO_OPERATING_MODE=localProxy \
        QUOTIO_INITIAL_PAGE=providers \
        QUOTIO_AUTO_OPEN_IDENTITY_BINDING="${ACCOUNT_QUERY}" \
        QUOTIO_SHOW_IN_DOCK=1 \
        QUOTIO_SKIP_ONBOARDING=1 \
        QUOTIO_DISABLE_UPDATE_CHECKS=1 \
        QUOTIO_LOCAL_MANAGEMENT_KEY="${DEV_MANAGEMENT_KEY}" \
        QUOTIO_UI_SMOKE_PROVIDERS_IDENTITY_BINDING=1 \
        "${DEV_EXECUTABLE}" \
        --runtime-isolation-debug-log-path "${TEST_LOG_FILE}" \
        >>"${TEST_LOG_FILE}" 2>&1 &
    DEV_APP_PID="$!"

    for _ in $(seq 1 30); do
        if [[ -n "${DEV_APP_PID}" ]] && kill -0 "${DEV_APP_PID}" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done

    log_error "${DEV_PRODUCT_NAME} did not start"
    tail -n 120 "${TEST_LOG_FILE}" || true
    exit 1
}

trap cleanup EXIT

print_header "Providers Identity Binding UI Smoke" 50
print_summary "Smoke Configuration" \
    "Bundle ID" "${DEV_BUNDLE_ID}" \
    "App" "${DEV_APP_PATH}" \
    "Log File" "${TEST_LOG_FILE}" \
    "Account Query" "${ACCOUNT_QUERY}" \
    "Remark" "${SMOKE_REMARK}" \
    "Ports" "${DEV_CLIENT_PORT}/${DEV_MANAGEMENT_PORT}"

mkdir -p "${PROJECT_DIR}/build"
rm -f "${TEST_LOG_FILE}"

if defaults export "${DEV_BUNDLE_ID}" - >/dev/null 2>&1; then
    TEST_DEFAULTS_BACKUP="$(mktemp "${TMPDIR:-/tmp}/quotio-providers-identity-binding-defaults.XXXXXX.plist")"
    defaults export "${DEV_BUNDLE_ID}" "${TEST_DEFAULTS_BACKUP}" >/dev/null 2>&1
fi

log_step "Resolving dev management key..."
resolve_management_key

log_step "Preparing isolated defaults fixture..."
prepare_defaults_fixture

build_dev_app
launch_dev_app

log_step "Waiting for dev core health..."
wait_for_health "http://127.0.0.1:${DEV_CLIENT_PORT}/healthz"
wait_for_health "http://127.0.0.1:${DEV_MANAGEMENT_PORT}/healthz"

log_step "Waiting for providers identity binding smoke markers..."
wait_for_log_line "[ui-smoke] providers-identity-row-ready auth=${ACCOUNT_QUERY} "
wait_for_log_line "remark_visible=true email_secondary=true supports_binding=true"
wait_for_log_line "[ui-smoke] providers-identity-binding-ready auth=${ACCOUNT_QUERY} current=UI Smoke Bound Package"
wait_for_log_line "[ui-smoke] providers-identity-unbind-confirmation auth=${ACCOUNT_QUERY} current=UI Smoke Bound Package"
wait_for_log_line "[ui-smoke] providers-identity-unbound auth=${ACCOUNT_QUERY} rebound_visible=true"

print_summary "Smoke Passed" \
    "Remark Row" "remark shown before email" \
    "Binding Sheet" "auto-opened with smoke fixtures" \
    "Unbind Guard" "confirmation + rebind visibility verified" \
    "Target" "${ACCOUNT_QUERY}"
