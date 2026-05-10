#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/config.sh"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/dev-app-utils.sh"

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
LOG_WAIT_SECONDS="${REMOTE_RELAY_UI_SMOKE_LOG_WAIT_SECONDS:-75}"
SMOKE_INITIAL_PAGE="${REMOTE_RELAY_UI_SMOKE_INITIAL_PAGE:-providers}"
SMOKE_REMOTE_CODEX_QUOTA="${REMOTE_RELAY_UI_SMOKE_REMOTE_CODEX_QUOTA:-0}"
SMOKE_REFRESH_CADENCE="${REMOTE_RELAY_UI_SMOKE_REFRESH_CADENCE:-}"
SMOKE_EXPECT_QUOTA_REFRESH_COUNT="${REMOTE_RELAY_UI_SMOKE_EXPECT_QUOTA_REFRESH_COUNT:-1}"
SMOKE_REQUIRE_ACCOUNT_SETTINGS="${REMOTE_RELAY_UI_SMOKE_REQUIRE_ACCOUNT_SETTINGS:-1}"

case "${RUNTIME_DIR}" in
    /*) ;;
    *) RUNTIME_DIR="${PROJECT_DIR}/${RUNTIME_DIR}" ;;
esac

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

    log_step "构建隔离 Debug Dev app"
    build_isolated_dev_app "${PROJECT_DIR}" "Quotio" "Debug" "${DERIVED_DATA_PATH}"
}

resolve_app_paths() {
    if [[ -z "${APP_BUNDLE}" && -n "${APP_EXECUTABLE}" ]]; then
        APP_BUNDLE="$(cd "$(dirname "${APP_EXECUTABLE}")/../.." && pwd)"
    fi
    if [[ -z "${APP_BUNDLE}" ]]; then
        APP_BUNDLE="$(dev_app_path "${DERIVED_DATA_PATH}" "Debug")"
    fi
    APP_BUNDLE="$(cd "${APP_BUNDLE}" && pwd)"
    if [[ -z "${APP_EXECUTABLE}" ]]; then
        APP_EXECUTABLE="$(dev_app_executable_path "${APP_BUNDLE}")"
    fi
    if ! validate_isolated_dev_app_bundle "${APP_BUNDLE}"; then
        log_error "Refusing to launch a non-isolated Dev app"
        exit 1
    fi
    if [[ "${APP_EXECUTABLE}" != "$(dev_app_executable_path "${APP_BUNDLE}")" ]]; then
        log_error "Dev app executable path does not match validated bundle: ${APP_EXECUTABLE}"
        exit 1
    fi
    if [[ ! -x "${APP_EXECUTABLE}" ]]; then
        log_error "${DEV_PRODUCT_NAME} executable 不存在或不可执行: ${APP_EXECUTABLE}"
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

wait_for_log_count() {
    local pattern="$1"
    local expected_count="$2"
    local timeout_seconds="${3:-45}"
    for _ in $(seq 1 "${timeout_seconds}"); do
        local count
        count="$(grep -Fc "${pattern}" "${TEST_LOG_FILE}" 2>/dev/null || true)"
        if [[ "${count}" -ge "${expected_count}" ]]; then
            return 0
        fi
        sleep 1
    done
    log_error "Timed out waiting for ${expected_count} occurrences of log line: ${pattern}"
    tail -n 260 "${TEST_LOG_FILE}" || true
    exit 1
}

write_smoke_user_defaults() {
    if [[ -z "${SMOKE_REFRESH_CADENCE}" ]]; then
        return 0
    fi

    mkdir -p "${RUNTIME_HOME}/Library/Preferences"
    python3 - "${RUNTIME_HOME}/Library/Preferences/${DEV_BUNDLE_ID}.plist" "${SMOKE_REFRESH_CADENCE}" <<'PY'
import pathlib
import plistlib
import sys

plist_path = pathlib.Path(sys.argv[1])
refresh_cadence = sys.argv[2]

payload = {}
if plist_path.exists():
    with plist_path.open("rb") as fh:
        payload = plistlib.load(fh)

payload["refreshCadence"] = refresh_cadence
with plist_path.open("wb") as fh:
    plistlib.dump(payload, fh)
PY
}

find_app_pid() {
    ps -axo pid=,command= | awk -v executable="${APP_EXECUTABLE}" 'index($0, executable) > 0 { print $1; exit }' || true
}

wait_for_app_pid() {
    for _ in $(seq 1 20); do
        APP_PID="$(find_app_pid)"
        if [[ -n "${APP_PID}" ]]; then
            return 0
        fi
        sleep 0.5
    done
    log_error "${DEV_PRODUCT_NAME} did not start from ${APP_BUNDLE}"
    tail -n 120 "${TEST_LOG_FILE}" || true
    exit 1
}

launch_app() {
    : > "${TEST_LOG_FILE}"
    log_step "启动 remote-relay UI smoke（port=${CLIENT_PORT}）"
    open \
        -n "${APP_BUNDLE}" \
        --stdout "${TEST_LOG_FILE}" \
        --stderr "${TEST_LOG_FILE}" \
        --env "HOME=${RUNTIME_HOME}" \
        --env "CFFIXED_USER_HOME=${RUNTIME_HOME}" \
        --env "QUOTIO_APP_SUPPORT_DIR=${APP_SUPPORT_DIR}" \
        --env "QUOTIO_AUTH_DIR=${AUTH_DIR}" \
        --env "QUOTIO_KEYCHAIN_NAMESPACE=${KEYCHAIN_NAMESPACE}" \
        --env "QUOTIO_REMOTE_MANAGEMENT_KEY_STORE=file" \
        --env "QUOTIO_REMOTE_MANAGEMENT_KEY_FILE=${KEY_FILE}" \
        --env "QUOTIO_REMOTE_MANAGEMENT_KEY=${REMOTE_MANAGEMENT_KEY}" \
        --env "QUOTIO_OPERATING_MODE=remote-relay" \
        --env "QUOTIO_REMOTE_ENDPOINT=${REMOTE_BASE_URL}" \
        --env "QUOTIO_REMOTE_VERIFY_SSL=${REMOTE_VERIFY_SSL}" \
        --env "QUOTIO_REMOTE_EXPOSE_LOCAL_RELAY=1" \
        --env "QUOTIO_PROXY_PORT=${CLIENT_PORT}" \
        --env "QUOTIO_INITIAL_PAGE=${SMOKE_INITIAL_PAGE}" \
        --env "QUOTIO_AUTO_OPEN_ACCOUNT_SETTINGS=${ACCOUNT_QUERY}" \
        --env "QUOTIO_UI_SMOKE_PROVIDERS_REMOTE_ACCOUNT_SETTINGS=1" \
        --env "QUOTIO_UI_SMOKE_REMOTE_CODEX_QUOTA=${SMOKE_REMOTE_CODEX_QUOTA}" \
        --env "QUOTIO_SKIP_ONBOARDING=1" \
        --env "QUOTIO_DISABLE_UPDATE_CHECKS=1" \
        --env "QUOTIO_SHOW_IN_DOCK=1" \
        --args --runtime-isolation-debug-log-path "${TEST_LOG_FILE}"
    wait_for_app_pid
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
    "remote_codex_quota_complete": "[ui-smoke] remote-codex-quota-complete" in log_text,
    "remote_claude_quota_complete": "[ui-smoke] remote-claude-quota-complete" in log_text,
}
quota_complete_counts = {
    "codex": log_text.count("[ui-smoke] remote-codex-quota-complete"),
    "claude": log_text.count("[ui-smoke] remote-claude-quota-complete"),
}
quota_lines = [
    line for line in log_text.splitlines()
    if "[ui-smoke] remote-codex-quota" in line or "[ui-smoke] remote-claude-quota" in line
]
pathlib.Path(summary_path).write_text(json.dumps({
    "remote_base_url": remote_base_url,
    "client_port": int(client_port),
    "account_query": account_query,
    "key_source": key_source,
    "app_executable": app_executable,
    "log_file": log_path,
    "markers": markers,
    "quota_complete_counts": quota_complete_counts,
    "quota_smoke_lines": quota_lines[-20:],
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
    write_smoke_user_defaults
    build_debug_app_if_needed
    resolve_app_paths
    launch_app
    wait_for_health "http://127.0.0.1:${CLIENT_PORT}/healthz"
    if [[ "${SMOKE_REQUIRE_ACCOUNT_SETTINGS}" == "1" ]]; then
        wait_for_log_line "[ui-smoke] providers-remote-account-settings-auto-open" "${LOG_WAIT_SECONDS}"
        wait_for_log_line "[ui-smoke] providers-remote-account-settings-loaded" "${LOG_WAIT_SECONDS}"
    fi
    if [[ "${SMOKE_REMOTE_CODEX_QUOTA}" == "1" ]]; then
        wait_for_log_line "[ui-smoke] remote-codex-quota-complete" "${LOG_WAIT_SECONDS}"
        wait_for_log_line "[ui-smoke] remote-claude-quota-complete" "${LOG_WAIT_SECONDS}"
        if [[ "${SMOKE_EXPECT_QUOTA_REFRESH_COUNT}" -gt 1 ]]; then
            wait_for_log_count "[ui-smoke] remote-codex-quota-complete" "${SMOKE_EXPECT_QUOTA_REFRESH_COUNT}" "${LOG_WAIT_SECONDS}"
            wait_for_log_count "[ui-smoke] remote-claude-quota-complete" "${SMOKE_EXPECT_QUOTA_REFRESH_COUNT}" "${LOG_WAIT_SECONDS}"
        fi
    fi
    write_summary
    log_success "remote-relay UI smoke 完成"
    echo "  * Summary: ${SUMMARY_FILE}"
}

main "$@"
