#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/config.sh"

REMOTE_BASE_URL="${REMOTE_RELAY_SMOKE_BASE_URL:-https://10.1.1.201:18317}"
REMOTE_HOST="${REMOTE_RELAY_SMOKE_REMOTE_HOST:-wisedata@10.1.1.201}"
REMOTE_SECRETS_FILE="${REMOTE_RELAY_SMOKE_REMOTE_SECRETS_FILE:-/home/wisedata/deploy/cliproxyapi-plus/runtime/secrets.env}"
REMOTE_MANAGEMENT_KEY="${REMOTE_RELAY_SMOKE_MANAGEMENT_KEY:-}"
REMOTE_VERIFY_SSL="${REMOTE_RELAY_SMOKE_VERIFY_SSL:-0}"
PRIMARY_PORT="${REMOTE_RELAY_SMOKE_PORT:-18058}"
SECONDARY_PORT="${REMOTE_RELAY_SMOKE_SECONDARY_PORT:-$((PRIMARY_PORT + 1))}"
RUNTIME_DIR="${REMOTE_RELAY_SMOKE_RUNTIME_DIR:-${BUILD_DIR}/remote-relay-smoke-script}"
KEEP_RUNTIME="${REMOTE_RELAY_SMOKE_KEEP_RUNTIME:-1}"
BUILD_APP="${REMOTE_RELAY_SMOKE_BUILD_APP:-1}"
APP_BUNDLE="${REMOTE_RELAY_SMOKE_APP_BUNDLE:-}"
APP_EXECUTABLE="${REMOTE_RELAY_SMOKE_APP_EXECUTABLE:-}"
DERIVED_DATA_PATH="${REMOTE_RELAY_SMOKE_DERIVED_DATA_PATH:-${BUILD_DIR}/DerivedData-remote-relay-smoke}"
KEYCHAIN_NAMESPACE="${REMOTE_RELAY_SMOKE_KEYCHAIN_NAMESPACE:-remote-relay-smoke}"
ACCOUNT_SETTINGS_SMOKE="${REMOTE_RELAY_SMOKE_ACCOUNT_SETTINGS:-1}"
ACCOUNT_SETTINGS_WRITEBACK="${REMOTE_RELAY_SMOKE_WRITEBACK:-1}"
ACCOUNT_SETTINGS_ACCOUNT_NAME="${REMOTE_RELAY_SMOKE_ACCOUNT_NAME:-codex-quotio-dev-remote-smoke-20260422T191451@example.invalid-plus.json}"
ACCOUNT_SETTINGS_ACCOUNT_MARKER="${REMOTE_RELAY_SMOKE_ACCOUNT_MARKER:-quotio-dev-remote-smoke}"
ACCOUNT_SETTINGS_NOTE_MARKER="${REMOTE_RELAY_SMOKE_NOTE_MARKER:-QUOTIO-REMOTE-SMOKE}"
ALLOW_NON_SMOKE_ACCOUNT="${REMOTE_RELAY_SMOKE_ALLOW_NON_SMOKE_ACCOUNT:-0}"

RUNTIME_HOME="${RUNTIME_DIR}/home"
APP_SUPPORT_DIR="${RUNTIME_DIR}/app-support"
AUTH_DIR="${RUNTIME_DIR}/auth"
KEY_FILE="${APP_SUPPORT_DIR}/remote-management-keys.${KEYCHAIN_NAMESPACE}.json"
KEY_FILE_REDACTED="${APP_SUPPORT_DIR}/remote-management-keys.${KEYCHAIN_NAMESPACE}.redacted.json"
SUMMARY_FILE="${RUNTIME_DIR}/summary.json"

APP_PID=""
KEY_SOURCE=""

usage() {
    cat <<'EOF'
Usage:
  ./scripts/smoke-test-remote-relay.sh

Environment overrides:
  REMOTE_RELAY_SMOKE_BASE_URL            远端 core URL，默认 https://10.1.1.201:18317
  REMOTE_RELAY_SMOKE_REMOTE_HOST         读取 secrets.env 的 SSH 主机，默认 wisedata@10.1.1.201
  REMOTE_RELAY_SMOKE_REMOTE_SECRETS_FILE 远端 secrets.env 路径
  REMOTE_RELAY_SMOKE_MANAGEMENT_KEY      手工指定远端 management key；设置后不走 SSH
  REMOTE_RELAY_SMOKE_VERIFY_SSL          远端直连是否验证证书；默认 0（自签名 smoke）
  REMOTE_RELAY_SMOKE_PORT                第一阶段 relay 端口，默认 18058
  REMOTE_RELAY_SMOKE_SECONDARY_PORT      第二阶段 relay 端口，默认 PRIMARY+1
  REMOTE_RELAY_SMOKE_RUNTIME_DIR         隔离运行目录，默认 build/remote-relay-smoke-script
  REMOTE_RELAY_SMOKE_KEEP_RUNTIME        是否保留运行目录，默认 1
  REMOTE_RELAY_SMOKE_BUILD_APP           是否先 build 当前 Debug app，默认 1
  REMOTE_RELAY_SMOKE_APP_BUNDLE          手工指定 Quotio.app 路径
  REMOTE_RELAY_SMOKE_APP_EXECUTABLE      手工指定 Quotio 可执行文件路径
  REMOTE_RELAY_SMOKE_DERIVED_DATA_PATH   build 时使用的 DerivedData 路径
  REMOTE_RELAY_SMOKE_KEYCHAIN_NAMESPACE  隔离 namespace，默认 remote-relay-smoke
  REMOTE_RELAY_SMOKE_ACCOUNT_SETTINGS    是否检查 account-settings 详情，默认 1
  REMOTE_RELAY_SMOKE_WRITEBACK           是否做 smoke 账号写回闭环，默认 1
  REMOTE_RELAY_SMOKE_ACCOUNT_NAME        专用 smoke 账号文件名
  REMOTE_RELAY_SMOKE_ACCOUNT_MARKER      专用 smoke 账号名必须包含的安全标记
  REMOTE_RELAY_SMOKE_NOTE_MARKER         专用 smoke 账号备注必须包含的安全标记

行为：
  1. 直连远端检查 /healthz、/management.html、/v0/management/auth-files
  2. 第一阶段用 env key + file store 种子本地 JSON 并启动 remote-relay
  3. 第二阶段移除 env key，仅靠本地 JSON 再启动一次 remote-relay
  4. 通过本机 relay 检查 /healthz、/v0/management/auth-files、/usage、/logs
  5. 默认通过 relay 对专用 smoke 账号做 account-settings 详情读回与写回恢复闭环
EOF
}

require_command() {
    local command_name="$1"
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        log_error "缺少命令: ${command_name}"
        exit 1
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

find_latest_debug_app_bundle() {
    local latest_path=""
    local latest_mtime=0
    local roots=(
        "${PROJECT_DIR}/build/DerivedData"
        "${PROJECT_DIR}/build/DerivedData-account-centralized-runtime-source"
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

    APP_BUNDLE="${DERIVED_DATA_PATH}/Build/Products/Debug/Quotio.app"
}

resolve_app_executable() {
    if [[ -n "${APP_EXECUTABLE}" ]]; then
        require_file "${APP_EXECUTABLE}" "找不到指定的 Quotio 可执行文件"
        return 0
    fi

    build_debug_app_if_needed

    if [[ -z "${APP_BUNDLE}" ]]; then
        APP_BUNDLE="$(find_latest_debug_app_bundle)"
    fi

    if [[ -z "${APP_BUNDLE}" ]]; then
        log_error "未找到 Debug Quotio.app；可先运行 xcodebuild，或设置 REMOTE_RELAY_SMOKE_BUILD_APP=1"
        exit 1
    fi

    APP_EXECUTABLE="${APP_BUNDLE}/Contents/MacOS/Quotio"
    require_file "${APP_EXECUTABLE}" "Quotio.app 内缺少可执行文件"
}

strip_wrapping_quotes() {
    python3 - "$1" <<'PY'
import sys
value = sys.argv[1].strip()
if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
    value = value[1:-1]
print(value, end="")
PY
}

resolve_remote_management_key() {
    if [[ -n "${REMOTE_MANAGEMENT_KEY}" ]]; then
        KEY_SOURCE="env"
        return 0
    fi

    log_step "通过 SSH 读取远端 management key"
    local raw_key
    raw_key="$(ssh -o BatchMode=yes "${REMOTE_HOST}" "grep '^MANAGEMENT_PASSWORD=' '${REMOTE_SECRETS_FILE}' | tail -n 1 | cut -d= -f2-")"
    REMOTE_MANAGEMENT_KEY="$(strip_wrapping_quotes "${raw_key}")"
    if [[ -z "${REMOTE_MANAGEMENT_KEY}" ]]; then
        log_error "无法从远端 secrets.env 解析 management key"
        exit 1
    fi
    KEY_SOURCE="ssh:${REMOTE_HOST}"
}

curl_remote() {
    local path="$1"
    local output_file="$2"
    local args=(-fsS)
    if [[ "${REMOTE_VERIFY_SSL}" != "1" ]]; then
        args+=(-k)
    fi
    curl "${args[@]}" "${REMOTE_BASE_URL}${path}" -o "${output_file}"
}

curl_remote_auth() {
    local path="$1"
    local output_file="$2"
    local args=(-fsS)
    if [[ "${REMOTE_VERIFY_SSL}" != "1" ]]; then
        args+=(-k)
    fi
    curl "${args[@]}" \
        -H "X-Management-Key: ${REMOTE_MANAGEMENT_KEY}" \
        "${REMOTE_BASE_URL}${path}" -o "${output_file}"
}

curl_relay_auth() {
    local port="$1"
    local path="$2"
    local output_file="$3"
    curl -fsS \
        -H "X-Management-Key: ${REMOTE_MANAGEMENT_KEY}" \
        "http://127.0.0.1:${port}${path}" -o "${output_file}"
}

wait_for_relay_listener() {
    local port="$1"
    local timeout="${2:-45}"
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

wait_for_relay_endpoint() {
    local port="$1"
    local path="$2"
    local output_file="$3"
    local timeout="${4:-45}"
    local attempt=0
    while [[ "${attempt}" -lt "${timeout}" ]]; do
        if curl -fsS -H "X-Management-Key: ${REMOTE_MANAGEMENT_KEY}" \
            "http://127.0.0.1:${port}${path}" > "${output_file}" 2>/dev/null; then
            return 0
        fi
        sleep 1
        attempt=$((attempt + 1))
    done
    return 1
}

wait_for_relay_healthz() {
    local port="$1"
    local output_file="$2"
    local timeout="${3:-45}"
    local attempt=0
    while [[ "${attempt}" -lt "${timeout}" ]]; do
        if curl -fsS "http://127.0.0.1:${port}/healthz" > "${output_file}" 2>/dev/null; then
            return 0
        fi
        sleep 1
        attempt=$((attempt + 1))
    done
    return 1
}

ensure_ports_available() {
    local ports=("$@")
    local port
    for port in "${ports[@]}"; do
        if lsof -nP -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1; then
            log_error "测试端口 ${port} 已被占用，脚本不会强杀未知进程"
            exit 1
        fi
    done
}

prepare_runtime_dir() {
    rm -rf "${RUNTIME_DIR}"
    mkdir -p "${RUNTIME_HOME}" "${APP_SUPPORT_DIR}" "${AUTH_DIR}"
}

stop_current_app() {
    if [[ -n "${APP_PID}" ]] && kill -0 "${APP_PID}" >/dev/null 2>&1; then
        kill "${APP_PID}" >/dev/null 2>&1 || true
        wait "${APP_PID}" 2>/dev/null || true
    fi
    APP_PID=""
}

cleanup() {
    stop_current_app

    if [[ -f "${KEY_FILE}" ]]; then
        create_redacted_key_artifact
        rm -f "${KEY_FILE}"
    fi

    if [[ "${KEEP_RUNTIME}" != "1" ]]; then
        rm -rf "${RUNTIME_DIR}"
    fi
}

create_redacted_key_artifact() {
    if [[ ! -f "${KEY_FILE}" ]]; then
        return 1
    fi

    python3 - "${KEY_FILE}" "${KEY_FILE_REDACTED}" <<'PY'
import json
import pathlib
import sys

source = pathlib.Path(sys.argv[1])
target = pathlib.Path(sys.argv[2])
data = json.loads(source.read_text())
for entry in (data.get("entries") or {}).values():
    if "management_key" in entry:
        entry["management_key"] = "<redacted>"
target.write_text(json.dumps(data, ensure_ascii=False, indent=2))
PY
}

write_summary() {
    local direct_auth="${RUNTIME_DIR}/direct-auth-files.json"
    local relay1_auth="${RUNTIME_DIR}/stage1/relay-auth-files.json"
    local relay2_auth="${RUNTIME_DIR}/stage2/relay-auth-files.json"
    local relay1_usage="${RUNTIME_DIR}/stage1/relay-usage.json"
    local relay2_usage="${RUNTIME_DIR}/stage2/relay-usage.json"
    local relay1_logs="${RUNTIME_DIR}/stage1/relay-logs.json"
    local relay2_logs="${RUNTIME_DIR}/stage2/relay-logs.json"
    local direct_healthz="${RUNTIME_DIR}/direct-healthz.json"
    local relay1_healthz="${RUNTIME_DIR}/stage1/relay-healthz.json"
    local relay2_healthz="${RUNTIME_DIR}/stage2/relay-healthz.json"
    local management_html="${RUNTIME_DIR}/direct-management.html"
    local stage1_log="${RUNTIME_DIR}/stage1/app.log"
    local stage2_log="${RUNTIME_DIR}/stage2/app.log"
    local stage1_lsof="${RUNTIME_DIR}/stage1/lsof.txt"
    local stage2_lsof="${RUNTIME_DIR}/stage2/lsof.txt"
    local stage1_key_file="${RUNTIME_DIR}/stage1/remote-management-keys.${KEYCHAIN_NAMESPACE}.redacted.json"
    local stage2_key_file="${RUNTIME_DIR}/stage2/remote-management-keys.${KEYCHAIN_NAMESPACE}.redacted.json"
    local account_settings_summary="${RUNTIME_DIR}/account-settings/summary.json"

    python3 - \
        "${SUMMARY_FILE}" \
        "${REMOTE_BASE_URL}" \
        "${KEY_SOURCE}" \
        "${APP_EXECUTABLE}" \
        "${KEY_FILE}" \
        "${KEY_FILE_REDACTED}" \
        "${direct_healthz}" \
        "${management_html}" \
        "${direct_auth}" \
        "${relay1_healthz}" \
        "${relay1_auth}" \
        "${relay1_usage}" \
        "${relay1_logs}" \
        "${stage1_log}" \
        "${stage1_lsof}" \
        "${relay2_healthz}" \
        "${relay2_auth}" \
        "${relay2_usage}" \
        "${relay2_logs}" \
        "${stage2_log}" \
        "${stage2_lsof}" \
        "${stage1_key_file}" \
        "${stage2_key_file}" \
        "${account_settings_summary}" \
        "${PRIMARY_PORT}" \
        "${SECONDARY_PORT}" <<'PY'
import json
import pathlib
import plistlib
import sys

(
    summary_path,
    remote_base_url,
    key_source,
    app_executable,
    source_key_file,
    redacted_key_file,
    direct_healthz_path,
    management_html_path,
    direct_auth_path,
    relay1_healthz_path,
    relay1_auth_path,
    relay1_usage_path,
    relay1_logs_path,
    stage1_log_path,
    stage1_lsof_path,
    relay2_healthz_path,
    relay2_auth_path,
    relay2_usage_path,
    relay2_logs_path,
    stage2_log_path,
    stage2_lsof_path,
    stage1_key_file_path,
    stage2_key_file_path,
    account_settings_summary_path,
    primary_port,
    secondary_port,
) = sys.argv[1:]

def read_json(path: str):
    return json.loads(pathlib.Path(path).read_text())

def tail_lines(path: str, limit: int = 20):
    lines = pathlib.Path(path).read_text(errors="ignore").splitlines()
    return lines[-limit:]

def auth_summary(path: str):
    data = read_json(path)
    files = data.get("files") or []
    return {
        "files_count": len(files),
        "files": files,
    }

VOLATILE_AUTH_FILE_KEYS = {
    "modtime",
    "status",
    "status_message",
    "unavailable",
    "updated_at",
}

def stable_auth_projection(files):
    projected = []
    for item in files:
        projected.append({
            key: value
            for key, value in item.items()
            if key not in VOLATILE_AUTH_FILE_KEYS
        })
    return sorted(projected, key=lambda item: item.get("name") or item.get("id") or "")

def exact_auth_match(left_files, right_files):
    return left_files == right_files

def contract_auth_match(left_files, right_files):
    return stable_auth_projection(left_files) == stable_auth_projection(right_files)

def volatile_auth_differences(left_files, right_files):
    left_index = {
        (item.get("name") or item.get("id") or f"index:{index}"): item
        for index, item in enumerate(left_files)
    }
    right_index = {
        (item.get("name") or item.get("id") or f"index:{index}"): item
        for index, item in enumerate(right_files)
    }
    differences = []
    for name in sorted(set(left_index) & set(right_index)):
        left_item = left_index[name]
        right_item = right_index[name]
        fields = {}
        for key in sorted(VOLATILE_AUTH_FILE_KEYS):
            if left_item.get(key) != right_item.get(key):
                fields[key] = {
                    "left": left_item.get(key),
                    "right": right_item.get(key),
                }
        if fields:
            differences.append({
                "name": name,
                "fields": fields,
            })
    return differences

def usage_summary(path: str):
    data = read_json(path)
    return {
        "keys": sorted(data.keys()),
        "request_count": data.get("request_count"),
        "total_requests": data.get("total_requests"),
    }

def logs_summary(path: str):
    data = read_json(path)
    return {
        "line_count": data.get("line-count"),
        "latest_timestamp": data.get("latest-timestamp"),
        "sample_lines": (data.get("lines") or [])[-5:],
    }

def app_summary(executable_path: str):
    executable = pathlib.Path(executable_path)
    bundle_path = executable.parent.parent.parent
    info_plist = bundle_path / "Contents/Info.plist"
    bundle_identifier = None
    if info_plist.exists():
        with info_plist.open("rb") as handle:
            bundle_identifier = plistlib.load(handle).get("CFBundleIdentifier")
    return {
        "bundle_path": str(bundle_path),
        "bundle_name": bundle_path.name,
        "bundle_identifier": bundle_identifier,
    }

def key_file_summary(path: str):
    target = pathlib.Path(path)
    if not target.exists():
        return None
    data = json.loads(target.read_text())
    entries = data.get("entries") or {}
    return {
        "path": str(target),
        "entries_count": len(entries),
        "entry_ids": sorted(entries.keys()),
        "has_runtime_remote_override": "runtime-remote-override" in entries,
    }

def optional_json(path: str):
    target = pathlib.Path(path)
    if not target.exists():
        return None
    return json.loads(target.read_text())

direct_auth = auth_summary(direct_auth_path)
relay1_auth = auth_summary(relay1_auth_path)
relay2_auth = auth_summary(relay2_auth_path)
relay1_exact_match = exact_auth_match(direct_auth["files"], relay1_auth["files"])
relay2_exact_match = exact_auth_match(direct_auth["files"], relay2_auth["files"])
relay1_contract_match = contract_auth_match(direct_auth["files"], relay1_auth["files"])
relay2_contract_match = contract_auth_match(direct_auth["files"], relay2_auth["files"])
relay1_volatile_differences = volatile_auth_differences(direct_auth["files"], relay1_auth["files"])
relay2_volatile_differences = volatile_auth_differences(direct_auth["files"], relay2_auth["files"])

summary = {
    "remote_base_url": remote_base_url,
    "key_source": key_source,
    "app_executable": app_executable,
    "app": app_summary(app_executable),
    "direct": {
        "healthz": read_json(direct_healthz_path),
        "management_html_bytes": pathlib.Path(management_html_path).stat().st_size,
        "auth_files": direct_auth,
    },
    "stage1_seed_with_env": {
        "local_port": int(primary_port),
        "inline_management_key_present": True,
        "relay_healthz": read_json(relay1_healthz_path),
        "auth_files": relay1_auth,
        "usage": usage_summary(relay1_usage_path),
        "logs": logs_summary(relay1_logs_path),
        "key_file": key_file_summary(stage1_key_file_path),
        "remote_relay_started": any("Remote relay started" in line for line in tail_lines(stage1_log_path, 50)),
        "app_log_tail": tail_lines(stage1_log_path),
        "listener": pathlib.Path(stage1_lsof_path).read_text(errors="ignore").splitlines(),
    },
    "stage2_file_only": {
        "local_port": int(secondary_port),
        "inline_management_key_present": False,
        "relay_healthz": read_json(relay2_healthz_path),
        "auth_files": relay2_auth,
        "usage": usage_summary(relay2_usage_path),
        "logs": logs_summary(relay2_logs_path),
        "key_file": key_file_summary(stage2_key_file_path),
        "remote_relay_started": any("Remote relay started" in line for line in tail_lines(stage2_log_path, 50)),
        "app_log_tail": tail_lines(stage2_log_path),
        "listener": pathlib.Path(stage2_lsof_path).read_text(errors="ignore").splitlines(),
    },
    "comparisons": {
        "direct_vs_stage1_auth_files_match": relay1_contract_match,
        "direct_vs_stage2_auth_files_match": relay2_contract_match,
        "direct_vs_stage1_auth_files_exact_match": relay1_exact_match,
        "direct_vs_stage2_auth_files_exact_match": relay2_exact_match,
        "stage1_volatile_auth_differences": relay1_volatile_differences,
        "stage2_volatile_auth_differences": relay2_volatile_differences,
    },
    "account_settings_smoke": optional_json(account_settings_summary_path),
    "secret_artifacts_cleaned": (
        not pathlib.Path(source_key_file).exists()
        and pathlib.Path(redacted_key_file).exists()
    ),
    "redacted_key_file": redacted_key_file if pathlib.Path(redacted_key_file).exists() else None,
}

pathlib.Path(summary_path).write_text(json.dumps(summary, ensure_ascii=False, indent=2))
PY
}

run_stage() {
    local stage_name="$1"
    local port="$2"
    local include_env_key="$3"
    local keep_running="${4:-0}"
    local stage_dir="${RUNTIME_DIR}/${stage_name}"
    mkdir -p "${stage_dir}"

    local env_args=(
        HOME="${RUNTIME_HOME}"
        CFFIXED_USER_HOME="${RUNTIME_HOME}"
        QUOTIO_APP_SUPPORT_DIR="${APP_SUPPORT_DIR}"
        QUOTIO_AUTH_DIR="${AUTH_DIR}"
        QUOTIO_KEYCHAIN_NAMESPACE="${KEYCHAIN_NAMESPACE}"
        QUOTIO_REMOTE_MANAGEMENT_KEY_STORE="file"
        QUOTIO_REMOTE_MANAGEMENT_KEY_FILE="${KEY_FILE}"
        QUOTIO_OPERATING_MODE="remote-relay"
        QUOTIO_REMOTE_ENDPOINT="${REMOTE_BASE_URL}"
        QUOTIO_REMOTE_VERIFY_SSL="${REMOTE_VERIFY_SSL}"
        QUOTIO_REMOTE_EXPOSE_LOCAL_RELAY="1"
        QUOTIO_PROXY_PORT="${port}"
        QUOTIO_SKIP_ONBOARDING="1"
        QUOTIO_DISABLE_UPDATE_CHECKS="1"
        QUOTIO_SHOW_IN_DOCK="0"
    )

    if [[ "${include_env_key}" == "1" ]]; then
        env_args+=(QUOTIO_REMOTE_MANAGEMENT_KEY="${REMOTE_MANAGEMENT_KEY}")
    fi

    log_step "启动 ${stage_name}（port=${port}）"
    env "${env_args[@]}" "${APP_EXECUTABLE}" > "${stage_dir}/app.log" 2>&1 &
    APP_PID="$!"

    if ! wait_for_relay_listener "${port}" 45; then
        log_error "${stage_name} 未在端口 ${port} 监听"
        exit 1
    fi

    if ! wait_for_relay_healthz "${port}" "${stage_dir}/relay-healthz.json" 45; then
        log_error "${stage_name} relay /healthz 检查失败"
        exit 1
    fi

    if ! wait_for_relay_endpoint "${port}" "/v0/management/auth-files" "${stage_dir}/relay-auth-files.json" 45; then
        log_error "${stage_name} relay /auth-files 检查失败"
        exit 1
    fi

    curl -fsS -H "X-Management-Key: ${REMOTE_MANAGEMENT_KEY}" \
        "http://127.0.0.1:${port}/v0/management/usage" > "${stage_dir}/relay-usage.json"
    curl -fsS -H "X-Management-Key: ${REMOTE_MANAGEMENT_KEY}" \
        "http://127.0.0.1:${port}/v0/management/logs" > "${stage_dir}/relay-logs.json"
    lsof -nP -iTCP:"${port}" -sTCP:LISTEN > "${stage_dir}/lsof.txt" || true

    if [[ "${keep_running}" != "1" ]]; then
        stop_current_app
    fi
}

run_account_settings_smoke() {
    local port="$1"
    local smoke_dir="${RUNTIME_DIR}/account-settings"
    mkdir -p "${smoke_dir}"

    if [[ "${ACCOUNT_SETTINGS_SMOKE}" != "1" ]]; then
        python3 - "${smoke_dir}/summary.json" <<'PY'
import json
import pathlib
import sys

pathlib.Path(sys.argv[1]).write_text(json.dumps({"skipped": True, "reason": "REMOTE_RELAY_SMOKE_ACCOUNT_SETTINGS != 1"}, ensure_ascii=False, indent=2))
PY
        return 0
    fi

    log_step "检查 account-settings 详情与写回闭环"
    python3 - \
        "${REMOTE_BASE_URL}" \
        "${REMOTE_VERIFY_SSL}" \
        "${REMOTE_MANAGEMENT_KEY}" \
        "${port}" \
        "${ACCOUNT_SETTINGS_ACCOUNT_NAME}" \
        "${ACCOUNT_SETTINGS_ACCOUNT_MARKER}" \
        "${ACCOUNT_SETTINGS_NOTE_MARKER}" \
        "${ALLOW_NON_SMOKE_ACCOUNT}" \
        "${ACCOUNT_SETTINGS_WRITEBACK}" \
        "${smoke_dir}" <<'PY'
import json
import pathlib
import ssl
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

(
    remote_base_url,
    remote_verify_ssl,
    management_key,
    relay_port,
    account_name,
    account_marker,
    note_marker,
    allow_non_smoke_account,
    writeback_enabled,
    smoke_dir,
) = sys.argv[1:]

smoke_path = pathlib.Path(smoke_dir)
smoke_path.mkdir(parents=True, exist_ok=True)
relay_base_url = f"http://127.0.0.1:{relay_port}"

def write_json(name, payload):
    path = smoke_path / name
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2))
    return str(path)

def request_json(base_url, method, path, payload=None):
    url = base_url.rstrip("/") + path
    data = None
    headers = {"X-Management-Key": management_key}
    if payload is not None:
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    context = None
    if url.startswith("https://") and remote_verify_ssl != "1":
        context = ssl._create_unverified_context()
    try:
        with urllib.request.urlopen(request, timeout=60, context=context) as response:
            body = response.read().decode("utf-8")
            return json.loads(body)
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {url} failed with {exc.code}: {body}") from exc

def detail_path(name):
    return "/v0/management/auth-files/account-settings?name=" + urllib.parse.quote(name, safe="")

def settings(response):
    return response.get("account_settings") or response

def setting_fields(response):
    value = settings(response)
    activation = value.get("activation") or {}
    return {
        "name": response.get("name"),
        "proxy_url": value.get("proxy_url") or "",
        "note": value.get("note") or "",
        "disabled": bool(value.get("disabled")),
        "extra_headers": value.get("extra_headers") or {},
        "transport_profile": value.get("transport_profile"),
        "tls_profile": value.get("tls_profile"),
        "managed_headers_count": len(value.get("managed_headers") or {}),
        "managed_header_state_present": bool(value.get("managed_header_state")),
        "activation_effective": bool(activation.get("effective")),
        "activation_state": activation.get("state") or "",
        "warnings": value.get("warnings") or [],
    }

def artifact_fields(fields):
    summarized = dict(fields)
    summarized["extra_headers"] = {
        "count": len(fields.get("extra_headers") or {}),
        "values_redacted": True,
    }
    return summarized

def write_settings_artifact(name, response):
    return write_json(name, {
        "artifact": "account-settings-field-summary",
        "name": response.get("name"),
        "account_settings": artifact_fields(setting_fields(response)),
    })

def patch_payload(base_fields, note, disabled):
    return {
        "name": account_name,
        "proxy_url": base_fields["proxy_url"],
        "note": note,
        "disabled": disabled,
        "extra_headers": base_fields["extra_headers"],
        "transport_profile": base_fields["transport_profile"],
        "tls_profile": base_fields["tls_profile"],
    }

def compare(label, direct_response, relay_response, expected_note=None, expected_disabled=None, expected_effective=None):
    direct_fields = setting_fields(direct_response)
    relay_fields = setting_fields(relay_response)
    mismatches = []
    for key in ("name", "proxy_url", "note", "disabled", "extra_headers", "transport_profile", "tls_profile", "activation_effective"):
        if direct_fields.get(key) != relay_fields.get(key):
            mismatches.append(key)
    if expected_note is not None and direct_fields["note"] != expected_note:
        mismatches.append("direct_note_expected")
    if expected_note is not None and relay_fields["note"] != expected_note:
        mismatches.append("relay_note_expected")
    if expected_disabled is not None and direct_fields["disabled"] != expected_disabled:
        mismatches.append("direct_disabled_expected")
    if expected_disabled is not None and relay_fields["disabled"] != expected_disabled:
        mismatches.append("relay_disabled_expected")
    if expected_effective is not None and direct_fields["activation_effective"] != expected_effective:
        mismatches.append("direct_effective_expected")
    if expected_effective is not None and relay_fields["activation_effective"] != expected_effective:
        mismatches.append("relay_effective_expected")
    if mismatches:
        raise AssertionError(f"{label} mismatch: {', '.join(mismatches)}")
    return {
        "direct": artifact_fields(direct_fields),
        "relay": artifact_fields(relay_fields),
    }

if allow_non_smoke_account != "1" and account_marker and account_marker not in account_name:
    raise SystemExit(f"refusing to write non-smoke account {account_name!r}; set REMOTE_RELAY_SMOKE_ALLOW_NON_SMOKE_ACCOUNT=1 to override")

summary = {
    "target_name": account_name,
    "account_name": account_name,
    "writeback_enabled": writeback_enabled == "1",
    "guards": {
        "account_marker": account_marker,
        "note_marker": note_marker,
        "allow_non_smoke_account": allow_non_smoke_account == "1",
    },
    "artifact_sensitivity": {
        "remote_management_key_file_is_redacted": True,
        "account_settings_artifacts_are_field_summaries": True,
        "extra_header_values_are_redacted": True,
        "note": "stage1 briefly writes the remote management key to the isolated file store before redacting and deleting the cleartext file; account-settings artifacts keep only field summaries and redact extra header values",
    },
    "paths": {},
    "checks": {},
    "comparisons": {},
}

before_direct = request_json(remote_base_url, "GET", detail_path(account_name))
before_relay = request_json(relay_base_url, "GET", detail_path(account_name))
summary["paths"]["before_direct"] = write_settings_artifact("before-direct.json", before_direct)
summary["paths"]["before_relay"] = write_settings_artifact("before-relay.json", before_relay)
before_check = compare("before", before_direct, before_relay)
summary["checks"]["before"] = before_check
original = setting_fields(before_direct)
summary["baseline"] = {
    "note": original.get("note"),
    "disabled": original.get("disabled"),
    "proxy_url": original.get("proxy_url"),
    "extra_headers": artifact_fields(original)["extra_headers"],
    "transport_profile": original.get("transport_profile"),
    "tls_profile": original.get("tls_profile"),
}
summary["detail_contract"] = {
    "top_level_name_correct": original.get("name") == account_name,
    "managed_headers_count": original.get("managed_headers_count", 0),
    "managed_header_state_present": original.get("managed_header_state_present", False),
    "warnings": original.get("warnings", []),
}
if allow_non_smoke_account != "1" and note_marker and note_marker.upper() not in original["note"].upper():
    raise SystemExit(f"refusing to write account with non-smoke note {original['note']!r}")

restore_attempted = False
restore_error = None
operation_error = None
post_restore_error = None
try:
    if writeback_enabled != "1":
        summary["skipped_writeback_reason"] = "REMOTE_RELAY_SMOKE_WRITEBACK != 1"
    else:
        smoke_note = f"QUOTIO-REMOTE-RELAY-SMOKE-{int(time.time())}"
        after_note_response = request_json(relay_base_url, "PATCH", "/v0/management/auth-files/account-settings", patch_payload(original, smoke_note, False))
        summary["paths"]["patch_note_response"] = write_settings_artifact("patch-note-response.json", after_note_response)
        after_note_direct = request_json(remote_base_url, "GET", detail_path(account_name))
        after_note_relay = request_json(relay_base_url, "GET", detail_path(account_name))
        summary["paths"]["after_note_direct"] = write_settings_artifact("after-note-direct.json", after_note_direct)
        summary["paths"]["after_note_relay"] = write_settings_artifact("after-note-relay.json", after_note_relay)
        summary["checks"]["after_note"] = compare("after_note", after_note_direct, after_note_relay, smoke_note, False, True)

        after_disable_response = request_json(relay_base_url, "PATCH", "/v0/management/auth-files/account-settings", patch_payload(original, smoke_note, True))
        summary["paths"]["patch_disable_response"] = write_settings_artifact("patch-disable-response.json", after_disable_response)
        after_disable_direct = request_json(remote_base_url, "GET", detail_path(account_name))
        after_disable_relay = request_json(relay_base_url, "GET", detail_path(account_name))
        summary["paths"]["after_disable_direct"] = write_settings_artifact("after-disable-direct.json", after_disable_direct)
        summary["paths"]["after_disable_relay"] = write_settings_artifact("after-disable-relay.json", after_disable_relay)
        summary["checks"]["after_disable"] = compare("after_disable", after_disable_direct, after_disable_relay, smoke_note, True, False)
except Exception as exc:
    operation_error = str(exc)
    summary["operation_error"] = operation_error
finally:
    if writeback_enabled == "1":
        restore_attempted = True
        try:
            restore_response = request_json(relay_base_url, "PATCH", "/v0/management/auth-files/account-settings", patch_payload(original, original["note"], original["disabled"]))
            summary["restore_method"] = "relay"
            summary["paths"]["patch_restore_response"] = write_settings_artifact("patch-restore-response.json", restore_response)
        except Exception as exc:
            summary["restore_relay_error"] = str(exc)
            try:
                restore_response = request_json(remote_base_url, "PATCH", "/v0/management/auth-files/account-settings", patch_payload(original, original["note"], original["disabled"]))
                summary["restore_method"] = "remote_direct_fallback"
                summary["paths"]["patch_restore_response"] = write_settings_artifact("patch-restore-response.json", restore_response)
            except Exception as fallback_exc:
                restore_error = f"relay restore failed: {exc}; direct restore failed: {fallback_exc}"

try:
    after_restore_direct = request_json(remote_base_url, "GET", detail_path(account_name))
    after_restore_relay = request_json(relay_base_url, "GET", detail_path(account_name))
    summary["paths"]["after_restore_direct"] = write_settings_artifact("after-restore-direct.json", after_restore_direct)
    summary["paths"]["after_restore_relay"] = write_settings_artifact("after-restore-relay.json", after_restore_relay)
    summary["checks"]["after_restore"] = compare(
        "after_restore",
        after_restore_direct,
        after_restore_relay,
        original["note"],
        original["disabled"],
        not original["disabled"],
    )
    restore_fields = setting_fields(after_restore_direct)
    for key in ("proxy_url", "extra_headers", "transport_profile", "tls_profile"):
        if restore_fields.get(key) != original.get(key):
            raise AssertionError(f"after_restore {key} changed")
except Exception as exc:
    post_restore_error = str(exc)
    summary["post_restore_error"] = post_restore_error

summary["restore_attempted"] = restore_attempted
summary["restore_error"] = restore_error
after_restore_check = summary["checks"].get("after_restore", {})
after_restore_direct_fields = after_restore_check.get("direct", {})
summary["restored"] = (
    restore_error is None
    and post_restore_error is None
    and after_restore_direct_fields.get("note") == original["note"]
    and after_restore_direct_fields.get("disabled") == original["disabled"]
)
summary["comparisons"]["direct_vs_relay_match"] = all(
    "relay" in value and value.get("direct") == value.get("relay")
    for value in summary["checks"].values()
)
summary["comparisons"]["restored_equals_baseline"] = summary["restored"]
write_json("summary.json", summary)
if operation_error:
    raise RuntimeError(f"account-settings smoke failed after restore attempt: {operation_error}")
if restore_error:
    raise RuntimeError(f"restore failed: {restore_error}")
if post_restore_error:
    raise RuntimeError(f"post-restore verification failed: {post_restore_error}")
PY
}

validate_seed_file_created() {
    if [[ ! -f "${KEY_FILE}" ]]; then
        log_error "第一阶段结束后未生成远端 key JSON: ${KEY_FILE}"
        exit 1
    fi
}

main() {
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        usage
        exit 0
    fi

    require_command curl
    require_command lsof
    require_command python3
    if [[ -z "${REMOTE_MANAGEMENT_KEY}" ]]; then
        require_command ssh
    fi
    if [[ "${BUILD_APP}" == "1" ]]; then
        require_command xcodebuild
    fi

    start_timer
    resolve_app_executable
    resolve_remote_management_key
    ensure_ports_available "${PRIMARY_PORT}" "${SECONDARY_PORT}"
    prepare_runtime_dir
    trap cleanup EXIT

    log_info "远端 core: ${REMOTE_BASE_URL}"
    log_info "Quotio executable: ${APP_EXECUTABLE}"
    log_info "隔离目录: ${RUNTIME_DIR}"

    log_step "直连远端 core 做最小检查"
    curl_remote "/healthz" "${RUNTIME_DIR}/direct-healthz.json"
    curl_remote "/management.html" "${RUNTIME_DIR}/direct-management.html"
    curl_remote_auth "/v0/management/auth-files" "${RUNTIME_DIR}/direct-auth-files.json"

    run_stage "stage1" "${PRIMARY_PORT}" "1"
    validate_seed_file_created
    create_redacted_key_artifact
    cp "${KEY_FILE_REDACTED}" "${RUNTIME_DIR}/stage1/remote-management-keys.${KEYCHAIN_NAMESPACE}.redacted.json"
    run_stage "stage2" "${SECONDARY_PORT}" "0" "1"
    run_account_settings_smoke "${SECONDARY_PORT}"
    stop_current_app

    create_redacted_key_artifact
    cp "${KEY_FILE_REDACTED}" "${RUNTIME_DIR}/stage2/remote-management-keys.${KEYCHAIN_NAMESPACE}.redacted.json"
    rm -f "${KEY_FILE}"
    write_summary

    log_success "remote-relay smoke 完成"
    log_item "Summary: ${SUMMARY_FILE}"
    log_item "Duration: $(get_total_duration)"
}

main "$@"
