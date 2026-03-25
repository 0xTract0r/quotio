#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

# 复用现有脚本输出风格
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/config.sh"

REAL_HOME="${HOME}"
VERIFY_PORT="${QUOTIO_VERIFY_PORT:-18027}"
INTERNAL_PORT=$((VERIFY_PORT + 10000))
RUNTIME_DIR="${QUOTIO_VERIFY_RUNTIME_DIR:-/tmp/quotio-runtime-verify}"
WAIT_SECONDS="${QUOTIO_VERIFY_WAIT_SECONDS:-40}"
UI_SETTLE_SECONDS="${QUOTIO_VERIFY_UI_SETTLE_SECONDS:-4}"
UI_IDLE_SECONDS="${QUOTIO_VERIFY_UI_IDLE_SECONDS:-8}"
KEEP_RUNTIME="${QUOTIO_VERIFY_KEEP_RUNTIME:-1}"
ENABLE_UI_SMOKE="${QUOTIO_VERIFY_UI_SMOKE:-1}"

APP_BUNDLE="${QUOTIO_VERIFY_APP_BUNDLE:-}"
CORE_BINARY="${QUOTIO_VERIFY_CORE_BINARY:-${REAL_HOME}/Library/Application Support/Quotio/CLIProxyAPI}"
MANAGEMENT_KEY=""
SUMMARY_FILE=""

find_latest_debug_app() {
    local latest_path=""
    local latest_mtime=0
    local roots=(
        "${PROJECT_DIR}/build/DerivedData"
        "${REAL_HOME}/Library/Developer/Xcode/DerivedData"
    )
    local root

    for root in "${roots[@]}"; do
        [[ -d "${root}" ]] || continue
        while IFS= read -r -d '' candidate; do
            local mtime
            mtime="$(stat -f "%m" "${candidate}" 2>/dev/null || echo 0)"
            if [[ "${mtime}" -gt "${latest_mtime}" ]]; then
                latest_mtime="${mtime}"
                latest_path="${candidate}"
            fi
        done < <(find "${root}" -path "*/Build/Products/Debug/Quotio.app" -type d -print0 2>/dev/null)
    done

    if [[ -n "${latest_path}" ]]; then
        printf '%s\n' "${latest_path}"
    fi
}

require_file() {
    local path="$1"
    local message="$2"
    if [[ ! -e "${path}" ]]; then
        log_error "${message}: ${path}"
        exit 1
    fi
}

require_command() {
    local command_name="$1"
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        log_error "缺少命令: ${command_name}"
        exit 1
    fi
}

ensure_ports_available() {
    if lsof -nP -iTCP:"${VERIFY_PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
        log_error "测试端口 ${VERIFY_PORT} 已被占用，脚本不会强杀未知进程"
        exit 1
    fi
    if lsof -nP -iTCP:"${INTERNAL_PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
        log_error "测试端口 ${INTERNAL_PORT} 已被占用，脚本不会强杀未知进程"
        exit 1
    fi
}

runtime_request() {
    local endpoint="$1"
    local output_file="$2"
    curl -sS --http1.1 \
        -H "Authorization: Bearer ${MANAGEMENT_KEY}" \
        "http://127.0.0.1:${INTERNAL_PORT}/v0/management${endpoint}" > "${output_file}"
}

wait_for_listener() {
    local port="$1"
    local timeout="${2:-30}"
    local attempt=0

    while [[ "${attempt}" -lt "${timeout}" ]]; do
        if lsof -nP -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        attempt=$((attempt + 1))
    done

    return 1
}

analyze_snapshot() {
    local file="$1"
    local label="$2"

    python3 - "${file}" "${label}" <<'PY'
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
label = sys.argv[2]
data = json.loads(path.read_text())
lines = data.get("lines") or []
debug_401 = [
    line for line in lines
    if re.search(r'/v0/management/debug.*401|401.*?/v0/management/debug', line, re.I)
]
logs_poll = [
    line for line in lines
    if "/v0/management/logs" in line and "probe=" not in line
]

print(f"{label}_latest_timestamp={data.get('latest-timestamp')}")
print(f"{label}_line_count={data.get('line-count')}")
print(f"{label}_debug_401_count={len(debug_401)}")
for line in debug_401[-5:]:
    print(f"{label}_debug_401_sample={line}")
print(f"{label}_logs_poll_count={len(logs_poll)}")
for line in logs_poll[-5:]:
    print(f"{label}_logs_poll_sample={line}")
PY
}

sample_cpu() {
    local output_file="$1"
    : > "${output_file}"

    local round
    for round in 1 2 3 4; do
        {
            echo "round=${round}"
            lsof -nP -iTCP:"${VERIFY_PORT}" -sTCP:LISTEN -Fp 2>/dev/null | sed 's/^p//' | head -1 | while read -r app_pid; do
                [[ -n "${app_pid}" ]] && ps -p "${app_pid}" -o pid,comm,%cpu,%mem | sed 1d
            done
            lsof -nP -iTCP:"${INTERNAL_PORT}" -sTCP:LISTEN -Fp 2>/dev/null | sed 's/^p//' | head -1 | while read -r core_pid; do
                [[ -n "${core_pid}" ]] && ps -p "${core_pid}" -o pid,comm,%cpu,%mem | sed 1d
            done
        } >> "${output_file}"
        sleep 3
    done
}

cleanup_runtime() {
    local pid
    for pid in \
        $(lsof -nP -iTCP:"${VERIFY_PORT}" -sTCP:LISTEN -t 2>/dev/null || true) \
        $(lsof -nP -iTCP:"${INTERNAL_PORT}" -sTCP:LISTEN -t 2>/dev/null || true); do
        [[ -n "${pid}" ]] || continue
        kill "${pid}" 2>/dev/null || true
    done

    sleep 2

    if [[ "${KEEP_RUNTIME}" != "1" ]]; then
        rm -rf "${RUNTIME_DIR}"
    fi
}

write_summary() {
    local debug_file="$1"
    local window_file="$2"
    local ui_first_file="$3"
    local ui_idle_file="$4"
    local cpu_file="$5"

    {
        echo "runtime_dir=${RUNTIME_DIR}"
        echo "app_bundle=${APP_BUNDLE}"
        echo "core_binary=${CORE_BINARY}"
        echo "verify_port=${VERIFY_PORT}"
        echo "internal_port=${INTERNAL_PORT}"
        echo "wait_seconds=${WAIT_SECONDS}"
        echo "ui_smoke_requested=${ENABLE_UI_SMOKE}"
        echo "--- debug ---"
        cat "${debug_file}"
        echo
        echo "--- window_40s ---"
        analyze_snapshot "${window_file}" "window_40s"
        if [[ -f "${ui_first_file}" ]]; then
            echo
            echo "--- ui_window ---"
            analyze_snapshot "${ui_first_file}" "ui_window"
        fi
        if [[ -f "${ui_idle_file}" ]]; then
            echo
            echo "--- ui_idle ---"
            analyze_snapshot "${ui_idle_file}" "ui_idle"
        fi
        echo
        echo "--- cpu ---"
        cat "${cpu_file}"
    } > "${SUMMARY_FILE}"
}

main() {
    require_command xcodebuild
    require_command curl
    require_command python3
    require_command uuidgen
    require_command open
    require_command lsof

    if [[ -z "${APP_BUNDLE}" ]]; then
        APP_BUNDLE="$(find_latest_debug_app)"
    fi

    require_file "${APP_BUNDLE}" "未找到 Debug app"
    require_file "${CORE_BINARY}" "未找到生产 core 二进制，无法复制到隔离运行时"
    ensure_ports_available

    start_timer
    log_step "准备隔离运行时目录"

    rm -rf "${RUNTIME_DIR}"
    mkdir -p "${RUNTIME_DIR}/Library/Application Support/Quotio" "${RUNTIME_DIR}/.cli-proxy-api"
    cp "${CORE_BINARY}" "${RUNTIME_DIR}/Library/Application Support/Quotio/CLIProxyAPI"
    chmod +x "${RUNTIME_DIR}/Library/Application Support/Quotio/CLIProxyAPI"

    MANAGEMENT_KEY="runtime-verify-$(uuidgen)"
    printf '%s\n' "${MANAGEMENT_KEY}" > "${RUNTIME_DIR}/management-key.txt"
    SUMMARY_FILE="${RUNTIME_DIR}/summary.txt"

    trap cleanup_runtime EXIT

    log_info "隔离运行时: ${RUNTIME_DIR}"
    log_info "Debug app: ${APP_BUNDLE}"
    log_info "测试端口: ${VERIFY_PORT}/${INTERNAL_PORT}"

    log_step "启动隔离 Debug 实例"
    env \
        HOME="${RUNTIME_DIR}" \
        CFFIXED_USER_HOME="${RUNTIME_DIR}" \
        QUOTIO_APP_SUPPORT_DIR="${RUNTIME_DIR}/Library/Application Support/Quotio" \
        QUOTIO_AUTH_DIR="${RUNTIME_DIR}/.cli-proxy-api" \
        QUOTIO_LOCAL_MANAGEMENT_KEY="${MANAGEMENT_KEY}" \
        QUOTIO_KEYCHAIN_NAMESPACE="runtime-verify" \
        QUOTIO_OPERATING_MODE="local" \
        QUOTIO_SKIP_ONBOARDING="1" \
        QUOTIO_AUTO_START_PROXY="1" \
        QUOTIO_PROXY_ONLY_TEST_MODE="1" \
        QUOTIO_DISABLE_UPDATE_CHECKS="1" \
        QUOTIO_PROXY_PORT="${VERIFY_PORT}" \
        QUOTIO_SHOW_IN_DOCK="1" \
        open -n "${APP_BUNDLE}"

    if ! wait_for_listener "${VERIFY_PORT}" 30; then
        log_error "外层端口 ${VERIFY_PORT} 未在 30 秒内监听"
        exit 1
    fi
    if ! wait_for_listener "${INTERNAL_PORT}" 30; then
        log_error "内层端口 ${INTERNAL_PORT} 未在 30 秒内监听"
        exit 1
    fi

    log_step "检查管理接口并开启隔离日志"
    runtime_request "/debug" "${RUNTIME_DIR}/debug.json"
    curl -sS --http1.1 \
        -H "Authorization: Bearer ${MANAGEMENT_KEY}" \
        -H "Content-Type: application/json" \
        -X PUT \
        -d '{"value":true}' \
        "http://127.0.0.1:${INTERNAL_PORT}/v0/management/logging-to-file" > "${RUNTIME_DIR}/logging-to-file.json"
    sleep 3

    local baseline_file="${RUNTIME_DIR}/baseline.json"
    local window_file="${RUNTIME_DIR}/window-40s.json"
    local ui_first_file="${RUNTIME_DIR}/ui-window.json"
    local ui_idle_file="${RUNTIME_DIR}/ui-idle.json"
    local cpu_file="${RUNTIME_DIR}/cpu.txt"

    runtime_request "/logs?probe=baseline" "${baseline_file}"

    local baseline_ts
    baseline_ts="$(python3 - "${baseline_file}" <<'PY'
import json, sys
print(json.load(open(sys.argv[1])).get("latest-timestamp") or 0)
PY
)"

    log_step "静置 ${WAIT_SECONDS} 秒，观察 401 与日志轮询"
    sleep "${WAIT_SECONDS}"
    runtime_request "/logs?after=${baseline_ts}&probe=window40" "${window_file}"

    local ui_smoke_status="skipped"
    if [[ "${ENABLE_UI_SMOKE}" == "1" ]]; then
        log_step "尝试执行最小 Logs 页烟雾测试"
        if osascript <<'APPLESCRIPT' >/dev/null 2>&1
tell application "Quotio"
  activate
end tell

tell application "System Events"
  tell process "Quotio"
    tell window 1
      tell group 1
        tell splitter group 1
          tell group 1
            tell scroll area 1
              tell outline 1
                select row 8
                click row 8
              end tell
            end tell
          end tell
        end tell
      end tell
    end tell
  end tell
end tell
APPLESCRIPT
        then
            ui_smoke_status="executed"
            sleep "${UI_SETTLE_SECONDS}"

            local ui_baseline_ts
            ui_baseline_ts="$(python3 - "${window_file}" <<'PY'
import json, sys
print(json.load(open(sys.argv[1])).get("latest-timestamp") or 0)
PY
)"

            runtime_request "/logs?after=${ui_baseline_ts}&probe=ui-window" "${ui_first_file}"

            local ui_idle_baseline_ts
            ui_idle_baseline_ts="$(python3 - "${ui_first_file}" <<'PY'
import json, sys
print(json.load(open(sys.argv[1])).get("latest-timestamp") or 0)
PY
)"

            sleep "${UI_IDLE_SECONDS}"
            runtime_request "/logs?after=${ui_idle_baseline_ts}&probe=ui-idle" "${ui_idle_file}"
        else
            ui_smoke_status="blocked_by_accessibility"
            log_warn "UI 烟雾测试未执行：当前会话没有辅助功能权限"
        fi
    fi

    log_step "采样空闲 CPU"
    sample_cpu "${cpu_file}"

    write_summary "${RUNTIME_DIR}/debug.json" "${window_file}" "${ui_first_file}" "${ui_idle_file}" "${cpu_file}"

    echo
    log_info "验证完成"
    echo "summary_file=${SUMMARY_FILE}"
    echo "ui_smoke_status=${ui_smoke_status}"
    cat "${SUMMARY_FILE}"
    echo
    log_info "总耗时: $(get_total_duration)"
}

main "$@"
