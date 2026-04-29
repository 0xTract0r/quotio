#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/config.sh"

REMOTE_BASE_URL="${REMOTE_RELAY_UI_SMOKE_BASE_URL:-https://10.1.1.201:18317}"
REMOTE_HOST="${REMOTE_RELAY_UI_SMOKE_REMOTE_HOST:-wisedata@10.1.1.201}"
REMOTE_SECRETS_FILE="${REMOTE_RELAY_UI_SMOKE_REMOTE_SECRETS_FILE:-/home/wisedata/deploy/cliproxyapi-plus/runtime/secrets.env}"
REMOTE_MANAGEMENT_KEY="${REMOTE_RELAY_UI_SMOKE_MANAGEMENT_KEY:-}"
REMOTE_VERIFY_SSL="${REMOTE_RELAY_UI_SMOKE_VERIFY_SSL:-0}"
CLIENT_PORT="${REMOTE_RELAY_UI_SMOKE_PORT:-18060}"
RUNTIME_DIR="${REMOTE_RELAY_UI_SMOKE_RUNTIME_DIR:-${BUILD_DIR}/remote-relay-ui-smoke}"
KEEP_RUNTIME="${REMOTE_RELAY_UI_SMOKE_KEEP_RUNTIME:-1}"
BUILD_APP="${REMOTE_RELAY_UI_SMOKE_BUILD_APP:-1}"
DERIVED_DATA_PATH="${REMOTE_RELAY_UI_SMOKE_DERIVED_DATA_PATH:-${BUILD_DIR}/DerivedData-remote-relay-ui-smoke}"
APP_BUNDLE="${REMOTE_RELAY_UI_SMOKE_APP_BUNDLE:-}"
APP_EXECUTABLE="${REMOTE_RELAY_UI_SMOKE_APP_EXECUTABLE:-}"
KEYCHAIN_NAMESPACE="${REMOTE_RELAY_UI_SMOKE_KEYCHAIN_NAMESPACE:-remote-relay-ui-smoke}"
ACCOUNT_QUERY="${REMOTE_RELAY_UI_SMOKE_ACCOUNT_QUERY:-codex-quotio-dev-remote-smoke}"

RUNTIME_HOME="${RUNTIME_DIR}/home"
APP_SUPPORT_DIR="${RUNTIME_DIR}/app-support"
AUTH_DIR="${RUNTIME_DIR}/auth"
KEY_FILE="${APP_SUPPORT_DIR}/remote-management-keys.${KEYCHAIN_NAMESPACE}.json"
TEST_LOG_FILE="${RUNTIME_DIR}/remote-relay-ui-smoke.log"
SUMMARY_FILE="${RUNTIME_DIR}/summary.json"

APP_PID=""
KEY_SOURCE=""

cleanup() {
    if [[ -n "${APP_PID}" ]]; then
        kill "${APP_PID}" >/dev/null 2>&1 || true
        wait "${APP_PID}" 2>/dev/null || true
        APP_PID=""
    fi
    rm -f "${KEY_FILE}"
    if [[ "${KEEP_RUNTIME}" != "1" ]]; then
        rm -rf "${RUNTIME_DIR}"
    fi
}
trap cleanup EXIT

require_command() {
    local command_name="$1"
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        log_error "缺少命令: ${command_name}"
        exit 1
    fi
}

resolve_remote_management_key() {
    if [[ -n "${REMOTE_MANAGEMENT_KEY}" ]]; then
        KEY_SOURCE="env"
        return 0
    fi

    log_step "通过 SSH 读取远端 management key"
    REMOTE_MANAGEMENT_KEY="$(
        ssh "${REMOTE_HOST}" "set -a; . '${REMOTE_SECRETS_FILE}'; printf '%s' \"\${MANAGEMENT_PASSWORD:-}\""
    )"
    KEY_SOURCE="ssh:${REMOTE_HOST}:${REMOTE_SECRETS_FILE}"

    if [[ -z "${REMOTE_MANAGEMENT_KEY}" ]]; then
        log_error "无法从远端 secrets.env 解析 management key"
        exit 1
    fi
}

build_debug_app_if_needed() {
    if [[ "${BUILD_APP}" != "1" ]]; then
        return 0
    fi

    log_step "构建当前 Debug app"
    xcodebuild \
        -project "${PROJECT_DIR}/Quotio.xcodeproj" \
        -scheme "Quotio" \
        -configuration "Debug" \
        -derivedDataPath "${DERIVED_DATA_PATH}" \
        build
}

resolve_app_paths() {
    if [[ -z "${APP_BUNDLE}" ]]; then
        APP_BUNDLE="${DERIVED_DATA_PATH}/Build/Products/Debug/Quotio.app"
    fi
    if [[ -z "${APP_EXECUTABLE}" ]]; then
        APP_EXECUTABLE="${APP_BUNDLE}/Contents/MacOS/Quotio"
    fi
    if [[ ! -x "${APP_EXECUTABLE}" ]]; then
        log_error "Quotio executable 不存在或不可执行: ${APP_EXECUTABLE}"
        exit 1
    fi
}

wait_for_health() {
    local url="$1"
    for _ in $(seq 1 45); do
        if curl -fsS "${url}" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done
    log_error "Timed out waiting for ${url}"
    tail -n 160 "${TEST_LOG_FILE}" || true
    exit 1
}

wait_for_log_line() {
    local pattern="$1"
    local timeout_seconds="${2:-45}"
    for _ in $(seq 1 "${timeout_seconds}"); do
        if grep -Fq "${pattern}" "${TEST_LOG_FILE}" 2>/dev/null; then
            return 0
        fi
        sleep 1
    done
    log_error "Timed out waiting for log line: ${pattern}"
    tail -n 200 "${TEST_LOG_FILE}" || true
    exit 1
}

launch_app() {
    : > "${TEST_LOG_FILE}"
    log_step "启动 remote-relay UI smoke（port=${CLIENT_PORT}）"
    env \
        HOME="${RUNTIME_HOME}" \
        CFFIXED_USER_HOME="${RUNTIME_HOME}" \
        QUOTIO_APP_SUPPORT_DIR="${APP_SUPPORT_DIR}" \
        QUOTIO_AUTH_DIR="${AUTH_DIR}" \
        QUOTIO_KEYCHAIN_NAMESPACE="${KEYCHAIN_NAMESPACE}" \
        QUOTIO_REMOTE_MANAGEMENT_KEY_STORE="file" \
        QUOTIO_REMOTE_MANAGEMENT_KEY_FILE="${KEY_FILE}" \
        QUOTIO_REMOTE_MANAGEMENT_KEY="${REMOTE_MANAGEMENT_KEY}" \
        QUOTIO_OPERATING_MODE="remote-relay" \
        QUOTIO_REMOTE_ENDPOINT="${REMOTE_BASE_URL}" \
        QUOTIO_REMOTE_VERIFY_SSL="${REMOTE_VERIFY_SSL}" \
        QUOTIO_REMOTE_EXPOSE_LOCAL_RELAY="1" \
        QUOTIO_PROXY_PORT="${CLIENT_PORT}" \
        QUOTIO_INITIAL_PAGE="providers" \
        QUOTIO_AUTO_OPEN_ACCOUNT_SETTINGS="${ACCOUNT_QUERY}" \
        QUOTIO_UI_SMOKE_PROVIDERS_REMOTE_ACCOUNT_SETTINGS="1" \
        QUOTIO_SKIP_ONBOARDING="1" \
        QUOTIO_DISABLE_UPDATE_CHECKS="1" \
        QUOTIO_SHOW_IN_DOCK="1" \
        "${APP_EXECUTABLE}" \
        --runtime-isolation-debug-log-path "${TEST_LOG_FILE}" \
        >>"${TEST_LOG_FILE}" 2>&1 &
    APP_PID="$!"
}

write_summary() {
    python3 - \
        "${SUMMARY_FILE}" \
        "${TEST_LOG_FILE}" \
        "${REMOTE_BASE_URL}" \
        "${CLIENT_PORT}" \
        "${ACCOUNT_QUERY}" \
        "${KEY_SOURCE}" \
        "${APP_EXECUTABLE}" <<'PY'
import json
import pathlib
import sys

summary_path, log_path, remote_base_url, client_port, account_query, key_source, app_executable = sys.argv[1:]
log_text = pathlib.Path(log_path).read_text(errors="replace") if pathlib.Path(log_path).exists() else ""
markers = {
    "remote_relay_started": "Remote relay started" in log_text,
    "auto_opened": "[ui-smoke] providers-remote-account-settings-auto-open" in log_text,
    "settings_loaded": "[ui-smoke] providers-remote-account-settings-loaded" in log_text,
    "load_error": "[ui-smoke] providers-remote-account-settings-load-error" in log_text,
}
pathlib.Path(summary_path).write_text(json.dumps({
    "remote_base_url": remote_base_url,
    "client_port": int(client_port),
    "account_query": account_query,
    "key_source": key_source,
    "app_executable": app_executable,
    "log_file": log_path,
    "markers": markers,
}, ensure_ascii=False, indent=2))
PY
}

main() {
    require_command ssh
    require_command curl
    require_command xcodebuild
    require_command python3

    mkdir -p "${RUNTIME_DIR}" "${RUNTIME_HOME}" "${APP_SUPPORT_DIR}" "${AUTH_DIR}"
    resolve_remote_management_key
    build_debug_app_if_needed
    resolve_app_paths
    launch_app
    wait_for_health "http://127.0.0.1:${CLIENT_PORT}/healthz"
    wait_for_log_line "[ui-smoke] providers-remote-account-settings-auto-open"
    wait_for_log_line "[ui-smoke] providers-remote-account-settings-loaded"
    write_summary
    log_success "remote-relay UI smoke 完成"
    echo "  * Summary: ${SUMMARY_FILE}"
}

main "$@"
