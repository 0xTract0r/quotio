#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
INSPECT_SCRIPT="${SCRIPT_DIR}/inspect-runtime-profile.sh"
MANAGE_CORE_SCRIPT="${SCRIPT_DIR}/manage-cliproxy-plus.sh"
MANAGEMENT_UI_DIR="${ROOT_DIR}/third_party/Cli-Proxy-API-Management-Center"

PROJECT_NAME="Quotio"
SCHEME="${SCHEME:-Quotio}"
CONFIGURATION="${CONFIGURATION:-Debug}"

STAGING_ROOT="${STAGING_ROOT:-${ROOT_DIR}/build/local-replace}"
STAGING_STATIC_DIR="${STAGING_STATIC_DIR:-${STAGING_ROOT}/static}"
PROD_STAGING_APP="${PROD_STAGING_APP:-${STAGING_ROOT}/prod/Quotio.app}"
DEV_STAGING_APP="${DEV_STAGING_APP:-${STAGING_ROOT}/dev/Quotio Dev.app}"
STAGING_CORE="${STAGING_CORE:-${STAGING_ROOT}/core/CLIProxyAPI}"
STAGING_MANAGEMENT_HTML="${STAGING_MANAGEMENT_HTML:-${STAGING_STATIC_DIR}/management.html}"
CORE_BUILD_OUTPUT="${CORE_BUILD_OUTPUT:-${ROOT_DIR}/build/CLIProxyAPIPlus/CLIProxyAPI}"
PROD_DERIVED_DATA="${PROD_DERIVED_DATA:-${ROOT_DIR}/build/DerivedData-local-prod}"
DEV_DERIVED_DATA="${DEV_DERIVED_DATA:-${ROOT_DIR}/build/DerivedData-local-dev}"

TARGET="${TARGET:-prod}"
TARGET_APP_PATH="${TARGET_APP_PATH:-}"
EXECUTE="${EXECUTE:-0}"
RELAUNCH="${RELAUNCH:-1}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-45}"
FORCE_KILL="${FORCE_KILL:-0}"
VERIFY_HEALTH="${VERIFY_HEALTH:-1}"
VERIFY_MANAGEMENT="${VERIFY_MANAGEMENT:-1}"
MANAGEMENT_EXPECT_TOKENS="${MANAGEMENT_EXPECT_TOKENS:-reauth_copy_link}"
MANAGEMENT_FORBID_TOKENS="${MANAGEMENT_FORBID_TOKENS:-reauth_open_link,onOpenReauthLink,openReauthLink}"
MANAGEMENT_RECHECK_DELAY="${MANAGEMENT_RECHECK_DELAY:-15}"
REPLACE_CORE="${REPLACE_CORE:-auto}"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/replace-local-quotio-runtime.sh build-staging
  TARGET=dev ./scripts/replace-local-quotio-runtime.sh plan
  TARGET=dev EXECUTE=1 ./scripts/replace-local-quotio-runtime.sh apply
  TARGET=prod ./scripts/rollback-local-quotio-runtime.sh

Environment:
  TARGET=prod|dev        Replace production or isolated dev runtime. Default: prod
  TARGET_APP_PATH=...    Override detected target app bundle path
  REPLACE_CORE=auto|0|1  Auto-skip core replacement when hashes match. Default: auto
  EXECUTE=1              Actually perform replacement; default is dry-run
  RELAUNCH=0|1           Relaunch app after replacement. Default: 1
  WAIT_TIMEOUT=<sec>     Wait timeout for stop/start checks. Default: 45
  FORCE_KILL=0|1         Escalate to SIGKILL if graceful stop times out. Default: 0
  VERIFY_HEALTH=0|1      Curl internal /healthz after relaunch. Default: 1
  VERIFY_MANAGEMENT=0|1  Verify runtime management.html hash after replacement. Default: 1
  MANAGEMENT_EXPECT_TOKENS=a,b
                        Comma-separated tokens that must appear in served /management.html.
                        Default: reauth_copy_link
  MANAGEMENT_FORBID_TOKENS=a,b
                        Comma-separated tokens that must not appear in served /management.html.
                        Default: reauth_open_link,onOpenReauthLink,openReauthLink
  MANAGEMENT_RECHECK_DELAY=<sec>
                        Delay before rechecking served /management.html after relaunch. Default: 15

Notes:
  - build-staging prepares app/core plus static/management.html under build/local-replace.
  - apply never rebuilds source artifacts; run build-staging first.
  - apply defaults to dry-run. Re-run with EXECUTE=1 when ready.
  - production apply requires TARGET_APP_PATH=/path/to/Quotio.app to avoid replacing the wrong app bundle.
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_file() {
  local path="$1"
  local label="$2"
  if [[ ! -e "$path" ]]; then
    echo "$label not found: $path" >&2
    exit 1
  fi
}

hash_file() {
  shasum -a 256 "$1" | awk '{print $1}'
}

realpath_py() {
  python3 - "$1" <<'PY'
import os
import sys

print(os.path.realpath(sys.argv[1]))
PY
}

profile_value() {
  local profile="$1"
  local key="$2"
  printf '%s\n' "$profile" | awk -F= -v k="$key" '$1==k {sub($1 "=",""); print}'
}

listener_pid() {
  local port="$1"
  lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null | head -n 1 || true
}

executable_path_for_pid() {
  local pid="$1"
  python3 - "$pid" <<'PY'
import subprocess
import sys

pid = sys.argv[1]
try:
    output = subprocess.check_output(["lsof", "-p", pid], text=True, stderr=subprocess.DEVNULL)
except Exception:
    raise SystemExit(0)

for raw in output.splitlines():
    parts = raw.split()
    if len(parts) >= 9 and parts[3] == "txt":
        print(" ".join(parts[8:]))
        raise SystemExit(0)
PY
}

bundle_path_from_executable() {
  local executable_path="$1"
  python3 - "$executable_path" <<'PY'
import sys

path = sys.argv[1]
marker = "/Contents/MacOS/"
if marker not in path:
    raise SystemExit(0)
print(path.split(marker, 1)[0])
PY
}

app_executable_path() {
  local bundle_path="$1"
  local executable_name="$2"
  local explicit_path="${bundle_path}/Contents/MacOS/${executable_name}"

  if [[ -f "$explicit_path" ]]; then
    printf '%s\n' "$explicit_path"
    return 0
  fi

  find "$bundle_path/Contents/MacOS" -maxdepth 1 -type f | head -n 1
}

require_writable_parent() {
  local path="$1"
  local label="$2"
  local parent_dir

  parent_dir="$(dirname "$path")"
  while [[ ! -d "$parent_dir" && "$parent_dir" != "/" ]]; do
    parent_dir="$(dirname "$parent_dir")"
  done
  if [[ ! -w "$parent_dir" ]]; then
    echo "${label} parent directory is not writable: ${parent_dir}" >&2
    exit 1
  fi
}

print_rollback_instructions() {
  local management_restore_line=""
  if [[ "${TARGET_MANAGEMENT_BACKUP_EXISTS:-0}" == "1" ]]; then
    management_restore_line="  cp \"${TARGET_MANAGEMENT_BACKUP}\" \"${TARGET_MANAGEMENT_PATH}\""
  else
    management_restore_line="  rm -f \"${TARGET_MANAGEMENT_PATH}\""
  fi

  if [[ "${SHOULD_REPLACE_CORE:-1}" == "1" ]]; then
    cat <<EOF
[rollback] If relaunch or follow-up verification fails, restore with:
  ditto "${TARGET_APP_BACKUP}" "${TARGET_APP_PATH_RESOLVED}"
  cp "${TARGET_CORE_BACKUP}" "${TARGET_CORE_PATH}"
${management_restore_line}
  open "${TARGET_APP_PATH_RESOLVED}"
EOF
    return 0
  fi

  cat <<EOF
[rollback] If relaunch or follow-up verification fails, restore the app with:
  ditto "${TARGET_APP_BACKUP}" "${TARGET_APP_PATH_RESOLVED}"
${management_restore_line}
  open "${TARGET_APP_PATH_RESOLVED}"
[rollback] Core was not replaced in this run.
EOF
}

copy_bundle() {
  local src="$1"
  local dest="$2"
  rm -rf "$dest"
  ditto "$src" "$dest"
}

replace_file_atomically() {
  local src="$1"
  local dest="$2"
  local dest_dir
  local dest_name
  local temp_path

  dest_dir="$(dirname "$dest")"
  dest_name="$(basename "$dest")"
  mkdir -p "$dest_dir"
  temp_path="$(mktemp "${dest_dir}/.${dest_name}.replace.XXXXXX")"
  cp "$src" "$temp_path"
  chmod 755 "$temp_path"
  mv "$temp_path" "$dest"
}

replace_bundle_atomically() {
  local src="$1"
  local dest="$2"
  local parent_dir
  local name
  local temp_path

  parent_dir="$(dirname "$dest")"
  name="$(basename "$dest")"
  temp_path="${parent_dir}/.${name}.incoming.$$"

  rm -rf "$temp_path"
  ditto "$src" "$temp_path"
  rm -rf "$dest"
  mv "$temp_path" "$dest"
}

wait_for_pid_exit() {
  local pid="$1"
  local timeout="$2"
  local start
  start="$(date +%s)"
  while kill -0 "$pid" 2>/dev/null; do
    if (( "$(date +%s)" - start >= timeout )); then
      return 1
    fi
    sleep 1
  done
}

wait_for_port_state() {
  local port="$1"
  local want_state="$2"
  local timeout="$3"
  local start
  start="$(date +%s)"
  while true; do
    local pid
    pid="$(listener_pid "$port")"
    if [[ "$want_state" == "listening" && -n "$pid" ]]; then
      return 0
    fi
    if [[ "$want_state" == "idle" && -z "$pid" ]]; then
      return 0
    fi
    if (( "$(date +%s)" - start >= timeout )); then
      return 1
    fi
    sleep 1
  done
}

verify_management_tokens() {
  local html_path="$1"
  local label="$2"

  python3 - "$html_path" "$MANAGEMENT_EXPECT_TOKENS" "$MANAGEMENT_FORBID_TOKENS" "$label" <<'PY'
import sys
from pathlib import Path

html_path, expected_raw, forbidden_raw, label = sys.argv[1:5]
text = Path(html_path).read_text(encoding="utf-8", errors="ignore")
expected = [token.strip() for token in expected_raw.split(",") if token.strip()]
forbidden = [token.strip() for token in forbidden_raw.split(",") if token.strip()]
missing = [token for token in expected if token not in text]
present = [token for token in forbidden if token in text]
if missing:
    raise SystemExit(f"{label} management.html missing required token(s): " + ", ".join(missing))
if present:
    raise SystemExit(f"{label} management.html contains forbidden token(s): " + ", ".join(present))
print(f"{label}_required_tokens_ok=" + (",".join(expected) if expected else "<none>"))
print(f"{label}_forbidden_tokens_absent=" + (",".join(forbidden) if forbidden else "<none>"))
PY
}

verify_served_management_asset() {
  local label="$1"
  local source_management_hash="$2"
  local served_management_path=""
  local served_management_hash=""

  served_management_path="$(mktemp "${TMPDIR:-/tmp}/quotio-management-served.XXXXXX.html")"
  curl -fsS "http://127.0.0.1:${TARGET_CORE_PORT}/management.html" -o "$served_management_path"
  served_management_hash="$(hash_file "$served_management_path")"

  if [[ "$source_management_hash" != "$served_management_hash" ]]; then
    rm -f "$served_management_path"
    echo "Served management asset hash mismatch after replacement (${label}): source=${source_management_hash} served=${served_management_hash}" >&2
    exit 1
  fi

  verify_management_tokens "$served_management_path" "served_${label}"
  rm -f "$served_management_path"
  echo "[verify] Served management asset matches staged source (${label})"
}

verify_management_asset() {
  local source_management_hash=""
  local target_management_hash=""

  require_file "$SOURCE_MANAGEMENT_PATH" "staged management asset"
  require_file "$TARGET_MANAGEMENT_PATH" "target management asset"

  source_management_hash="$(hash_file "$SOURCE_MANAGEMENT_PATH")"
  target_management_hash="$(hash_file "$TARGET_MANAGEMENT_PATH")"

  if [[ "$source_management_hash" != "$target_management_hash" ]]; then
    echo "Management asset hash mismatch after replacement: source=${source_management_hash} target=${target_management_hash}" >&2
    exit 1
  fi

  verify_management_tokens "$TARGET_MANAGEMENT_PATH" "disk"

  if [[ "$RELAUNCH" != "1" ]]; then
    echo "[verify] Management asset hash matches staged source"
    echo "[verify] Skipping served management check because RELAUNCH=${RELAUNCH}"
    return 0
  fi

  verify_served_management_asset "initial" "$source_management_hash"

  if ! [[ "$MANAGEMENT_RECHECK_DELAY" =~ ^[0-9]+$ ]]; then
    echo "MANAGEMENT_RECHECK_DELAY must be a non-negative integer: ${MANAGEMENT_RECHECK_DELAY}" >&2
    exit 1
  fi

  if (( MANAGEMENT_RECHECK_DELAY > 0 )); then
    echo "[verify] Waiting ${MANAGEMENT_RECHECK_DELAY}s before rechecking served management asset"
    sleep "$MANAGEMENT_RECHECK_DELAY"
    verify_served_management_asset "delayed" "$source_management_hash"
  fi

  echo "[verify] Management asset hash and tokens match staged source"
}

stop_pid() {
  local pid="$1"
  local label="$2"
  if [[ -z "$pid" ]]; then
    return 0
  fi
  if ! kill -0 "$pid" 2>/dev/null; then
    return 0
  fi

  echo "[stop] Sending SIGTERM to ${label} (pid=${pid})"
  kill -TERM "$pid" 2>/dev/null || true
  if wait_for_pid_exit "$pid" "$WAIT_TIMEOUT"; then
    return 0
  fi

  if [[ "$FORCE_KILL" != "1" ]]; then
    echo "${label} did not exit within ${WAIT_TIMEOUT}s. Re-run with FORCE_KILL=1 if you want to escalate." >&2
    return 1
  fi

  echo "[stop] Escalating to SIGKILL for ${label} (pid=${pid})"
  kill -KILL "$pid" 2>/dev/null || true
  wait_for_pid_exit "$pid" 5
}

locate_with_mdfind() {
  local bundle_id="$1"
  local source_app_real="$2"
  local path=""
  while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    [[ ! -d "$candidate" ]] && continue
    if [[ -n "$source_app_real" && "$(realpath_py "$candidate")" == "$source_app_real" ]]; then
      continue
    fi
    path="$candidate"
    break
  done < <(mdfind "kMDItemCFBundleIdentifier == \"$bundle_id\"")
  printf '%s\n' "$path"
}

resolve_target_metadata() {
  case "$TARGET" in
    prod)
      TARGET_LABEL="production"
      TARGET_BUNDLE_ID="dev.quotio.desktop"
      TARGET_PRODUCT_NAME="Quotio"
      TARGET_EXECUTABLE_NAME="Quotio"
      SOURCE_APP_PATH="$PROD_STAGING_APP"
      TARGET_FALLBACK_CANDIDATE="/Applications/Quotio.app"
      ;;
    dev)
      TARGET_LABEL="isolated-dev"
      TARGET_BUNDLE_ID="dev.quotio.desktop.dev"
      TARGET_PRODUCT_NAME="Quotio Dev"
      TARGET_EXECUTABLE_NAME="Quotio Dev"
      SOURCE_APP_PATH="$DEV_STAGING_APP"
      TARGET_FALLBACK_CANDIDATE="${ROOT_DIR}/build/DerivedData-dev/Build/Products/${CONFIGURATION}/Quotio Dev.app"
      ;;
    *)
      echo "Unsupported TARGET=${TARGET}. Use prod or dev." >&2
      exit 1
      ;;
  esac

  TARGET_PROFILE="$("$INSPECT_SCRIPT" "$TARGET_BUNDLE_ID")"
  TARGET_APP_SUPPORT="$(profile_value "$TARGET_PROFILE" application_support)"
  TARGET_AUTH_DIR="$(profile_value "$TARGET_PROFILE" auth_dir)"
  TARGET_CLIENT_PORT="$(profile_value "$TARGET_PROFILE" proxy_port)"
  TARGET_CORE_PORT="$(profile_value "$TARGET_PROFILE" internal_proxy_port)"
  TARGET_CORE_PATH="${TARGET_APP_SUPPORT}/CLIProxyAPI"
  TARGET_STATIC_DIR="${TARGET_APP_SUPPORT}/static"
  TARGET_MANAGEMENT_PATH="${TARGET_STATIC_DIR}/management.html"
  SOURCE_CORE_PATH="$STAGING_CORE"
  SOURCE_MANAGEMENT_PATH="$STAGING_MANAGEMENT_HTML"
  SOURCE_EXECUTABLE_NAME="$TARGET_EXECUTABLE_NAME"
  SOURCE_APP_REAL=""
  if [[ -d "$SOURCE_APP_PATH" ]]; then
    SOURCE_APP_REAL="$(realpath_py "$SOURCE_APP_PATH")"
  fi
}

resolve_target_app_path() {
  local running_pid=""
  local running_exec=""
  local running_bundle=""
  local detected=""

  if [[ -n "$TARGET_APP_PATH" ]]; then
    printf '%s\n' "$TARGET_APP_PATH"
    return 0
  fi

  running_pid="$(listener_pid "$TARGET_CLIENT_PORT")"
  if [[ -n "$running_pid" ]]; then
    running_exec="$(executable_path_for_pid "$running_pid")"
    if [[ -n "$running_exec" ]]; then
      running_bundle="$(bundle_path_from_executable "$running_exec")"
      if [[ -n "$running_bundle" && -d "$running_bundle" ]]; then
        printf '%s\n' "$running_bundle"
        return 0
      fi
    fi
  fi

  if [[ -d "$TARGET_FALLBACK_CANDIDATE" ]]; then
    detected="$TARGET_FALLBACK_CANDIDATE"
  else
    detected="$(locate_with_mdfind "$TARGET_BUNDLE_ID" "$SOURCE_APP_REAL")"
  fi

  if [[ -n "$detected" ]]; then
    printf '%s\n' "$detected"
    return 0
  fi

  echo "Unable to detect target app path for TARGET=${TARGET}. Re-run with TARGET_APP_PATH=/path/to/${TARGET_PRODUCT_NAME}.app" >&2
  exit 1
}

build_staged_core() {
  echo "[build] Building CLIProxyAPIPlus core"
  "$MANAGE_CORE_SCRIPT" build
  require_file "$CORE_BUILD_OUTPUT" "core build artifact"
  mkdir -p "$(dirname "$STAGING_CORE")"
  cp "$CORE_BUILD_OUTPUT" "$STAGING_CORE"
  chmod 755 "$STAGING_CORE"
  echo "[build] Staged core: $STAGING_CORE"
}

build_staged_management_html() {
  echo "[build] Building Management Center single-file asset"
  require_cmd npm
  require_file "${MANAGEMENT_UI_DIR}/package.json" "management center package"
  if [[ ! -d "${MANAGEMENT_UI_DIR}/node_modules" ]]; then
    npm --prefix "${MANAGEMENT_UI_DIR}" ci
  fi
  npm --prefix "${MANAGEMENT_UI_DIR}" run build
  require_file "${MANAGEMENT_UI_DIR}/dist/index.html" "management center build artifact"
  mkdir -p "$STAGING_STATIC_DIR"
  cp "${MANAGEMENT_UI_DIR}/dist/index.html" "$STAGING_MANAGEMENT_HTML"
  echo "[build] Staged management asset: $STAGING_MANAGEMENT_HTML"
}

build_staged_app() {
  local bundle_id="$1"
  local product_name="$2"
  local display_name="$3"
  local icon_name="$4"
  local derived_data="$5"
  local destination="$6"

  echo "[build] Building ${product_name} -> ${destination}"
  rm -rf "$destination" "$derived_data"
  mkdir -p "$(dirname "$destination")"
  xcodebuild \
    -project "${ROOT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${derived_data}" \
    CONFIGURATION_BUILD_DIR="$(dirname "$destination")" \
    PRODUCT_BUNDLE_IDENTIFIER="${bundle_id}" \
    PRODUCT_NAME="${product_name}" \
    INFOPLIST_KEY_CFBundleDisplayName="${display_name}" \
    ASSETCATALOG_COMPILER_APPICON_NAME="${icon_name}" \
    build \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

  require_file "$destination" "${product_name} staged app"
}

write_staging_manifest() {
  local manifest_path="${STAGING_ROOT}/manifest.txt"
  local prod_exec="${PROD_STAGING_APP}/Contents/MacOS/Quotio"
  local dev_exec="${DEV_STAGING_APP}/Contents/MacOS/Quotio Dev"
  mkdir -p "$STAGING_ROOT"
  cat >"$manifest_path" <<EOF
generated_at=$(date '+%Y-%m-%d %H:%M:%S %z')
configuration=${CONFIGURATION}
core_artifact=${STAGING_CORE}
core_sha256=$(hash_file "$STAGING_CORE")
management_asset=${STAGING_MANAGEMENT_HTML}
management_sha256=$(hash_file "$STAGING_MANAGEMENT_HTML")
prod_app=${PROD_STAGING_APP}
prod_exec_sha256=$(hash_file "$prod_exec")
dev_app=${DEV_STAGING_APP}
dev_exec_sha256=$(hash_file "$dev_exec")
EOF
  echo "[build] Manifest written: $manifest_path"
}

resolve_core_replacement_mode() {
  local source_core_hash="$1"
  local target_core_hash="$2"

  case "$REPLACE_CORE" in
    1|true|TRUE|yes|YES)
      SHOULD_REPLACE_CORE=1
      CORE_REPLACE_REASON="forced by REPLACE_CORE=${REPLACE_CORE}"
      ;;
    0|false|FALSE|no|NO)
      SHOULD_REPLACE_CORE=0
      CORE_REPLACE_REASON="disabled by REPLACE_CORE=${REPLACE_CORE}"
      ;;
    auto|AUTO)
      if [[ "$source_core_hash" == "$target_core_hash" ]]; then
        SHOULD_REPLACE_CORE=0
        CORE_REPLACE_REASON="source/target core hash match"
      else
        SHOULD_REPLACE_CORE=1
        CORE_REPLACE_REASON="source/target core hash differ"
      fi
      ;;
    *)
      echo "Unsupported REPLACE_CORE=${REPLACE_CORE}. Use auto, 0, or 1." >&2
      exit 1
      ;;
  esac
}

show_plan() {
  local target_app_real=""
  local source_app_exec=""
  local target_app_exec=""
  local source_app_exec_hash=""
  local target_app_exec_hash=""
  local source_management_hash=""
  local target_management_hash="missing"

  require_file "$SOURCE_CORE_PATH" "staged core artifact"
  require_file "$SOURCE_MANAGEMENT_PATH" "staged management asset"
  require_file "$SOURCE_APP_PATH" "staged app artifact"
  require_file "$TARGET_CORE_PATH" "target core binary"
  require_file "$TARGET_APP_PATH_RESOLVED" "target app bundle"

  target_app_real="$(realpath_py "$TARGET_APP_PATH_RESOLVED")"
  if [[ -n "$SOURCE_APP_REAL" && "$SOURCE_APP_REAL" == "$target_app_real" ]]; then
    echo "Source app artifact and target app bundle resolve to the same path: $SOURCE_APP_REAL" >&2
    exit 1
  fi

  SOURCE_CORE_HASH="$(hash_file "$SOURCE_CORE_PATH")"
  TARGET_CORE_HASH="$(hash_file "$TARGET_CORE_PATH")"
  resolve_core_replacement_mode "$SOURCE_CORE_HASH" "$TARGET_CORE_HASH"
  source_app_exec="$(app_executable_path "$SOURCE_APP_PATH" "$SOURCE_EXECUTABLE_NAME")"
  target_app_exec="$(app_executable_path "$TARGET_APP_PATH_RESOLVED" "$TARGET_EXECUTABLE_NAME")"
  source_app_exec_hash="$(hash_file "$source_app_exec")"
  target_app_exec_hash="$(hash_file "$target_app_exec")"
  source_management_hash="$(hash_file "$SOURCE_MANAGEMENT_PATH")"
  if [[ -f "$TARGET_MANAGEMENT_PATH" ]]; then
    target_management_hash="$(hash_file "$TARGET_MANAGEMENT_PATH")"
  fi

  echo "Local replacement plan"
  echo "  target_label     : ${TARGET_LABEL}"
  echo "  target_bundle_id : ${TARGET_BUNDLE_ID}"
  echo "  target_app       : ${TARGET_APP_PATH_RESOLVED}"
  echo "  target_core      : ${TARGET_CORE_PATH}"
  echo "  target_management: ${TARGET_MANAGEMENT_PATH}"
  echo "  target_support   : ${TARGET_APP_SUPPORT}"
  echo "  target_auth_dir  : ${TARGET_AUTH_DIR}"
  echo "  client_port      : ${TARGET_CLIENT_PORT} (pid=$(listener_pid "$TARGET_CLIENT_PORT" || true))"
  echo "  core_port        : ${TARGET_CORE_PORT} (pid=$(listener_pid "$TARGET_CORE_PORT" || true))"
  echo "  source_app       : ${SOURCE_APP_PATH}"
  echo "  source_core      : ${SOURCE_CORE_PATH}"
  echo "  source_management: ${SOURCE_MANAGEMENT_PATH}"
  echo "  source_app_hash  : ${source_app_exec_hash}"
  echo "  target_app_hash  : ${target_app_exec_hash}"
  echo "  source_core_hash : ${SOURCE_CORE_HASH}"
  echo "  target_core_hash : ${TARGET_CORE_HASH}"
  echo "  source_mgmt_hash : ${source_management_hash}"
  echo "  target_mgmt_hash : ${target_management_hash}"
  echo "  replace_core     : ${SHOULD_REPLACE_CORE} (${CORE_REPLACE_REASON})"
  echo "  backup_root      : ${TARGET_BACKUP_ROOT}"
  echo "  backup_app       : ${TARGET_APP_BACKUP}"
  echo "  backup_core      : ${TARGET_CORE_BACKUP}"
  echo "  backup_mgmt      : ${TARGET_MANAGEMENT_BACKUP}"
  echo "  relaunch         : ${RELAUNCH}"
  echo "  verify_health    : ${VERIFY_HEALTH}"
  echo "  verify_management: ${VERIFY_MANAGEMENT}"
  echo "  mgmt_expect      : ${MANAGEMENT_EXPECT_TOKENS:-<none>}"
  echo "  mgmt_forbid      : ${MANAGEMENT_FORBID_TOKENS:-<none>}"
  echo "  mgmt_recheck_sec : ${MANAGEMENT_RECHECK_DELAY}"
}

apply_replacement() {
  local app_pid=""
  local core_pid=""
  local target_app_exec=""

  app_pid="$(listener_pid "$TARGET_CLIENT_PORT")"
  core_pid="$(listener_pid "$TARGET_CORE_PORT")"

  mkdir -p "$TARGET_BACKUP_ROOT"

  show_plan

  if [[ "$EXECUTE" != "1" ]]; then
    echo
    echo "Dry-run only. Re-run with EXECUTE=1 to replace the local runtime."
    if [[ "$TARGET" == "prod" && -z "$TARGET_APP_PATH" ]]; then
      echo "Production apply requires TARGET_APP_PATH=/path/to/Quotio.app to avoid replacing the wrong app bundle."
    fi
    return 0
  fi

  if [[ "$TARGET" == "prod" && -z "$TARGET_APP_PATH" ]]; then
    echo "Production apply requires TARGET_APP_PATH=/path/to/Quotio.app. Run plan first, confirm target_app, then re-run apply with TARGET_APP_PATH set explicitly." >&2
    exit 1
  fi

  require_writable_parent "$TARGET_APP_PATH_RESOLVED" "target app bundle"
  require_writable_parent "$TARGET_BACKUP_ROOT" "backup root"
  require_writable_parent "$TARGET_MANAGEMENT_PATH" "target management asset"
  if [[ "$SHOULD_REPLACE_CORE" == "1" ]]; then
    require_writable_parent "$TARGET_CORE_PATH" "target core binary"
  fi

  echo
  if [[ "$SHOULD_REPLACE_CORE" == "1" ]]; then
    echo "[backup] Saving current app bundle, core binary, and management asset"
  else
    echo "[backup] Saving current app bundle and management asset"
  fi
  copy_bundle "$TARGET_APP_PATH_RESOLVED" "$TARGET_APP_BACKUP"
  if [[ "$SHOULD_REPLACE_CORE" == "1" ]]; then
    cp "$TARGET_CORE_PATH" "$TARGET_CORE_BACKUP"
  fi
  TARGET_MANAGEMENT_BACKUP_EXISTS=0
  if [[ -f "$TARGET_MANAGEMENT_PATH" ]]; then
    cp "$TARGET_MANAGEMENT_PATH" "$TARGET_MANAGEMENT_BACKUP"
    TARGET_MANAGEMENT_BACKUP_EXISTS=1
  fi
  print_rollback_instructions

  if [[ -n "$app_pid" ]]; then
    stop_pid "$app_pid" "${TARGET_LABEL} app"
  fi
  if ! wait_for_port_state "$TARGET_CLIENT_PORT" idle "$WAIT_TIMEOUT"; then
    echo "Client port ${TARGET_CLIENT_PORT} did not become idle." >&2
    exit 1
  fi

  if [[ "$SHOULD_REPLACE_CORE" == "1" ]]; then
    core_pid="$(listener_pid "$TARGET_CORE_PORT")"
    if [[ -n "$core_pid" ]]; then
      stop_pid "$core_pid" "${TARGET_LABEL} core"
    fi
    if ! wait_for_port_state "$TARGET_CORE_PORT" idle "$WAIT_TIMEOUT"; then
      echo "Core port ${TARGET_CORE_PORT} did not become idle." >&2
      exit 1
    fi
  fi

  if [[ "$SHOULD_REPLACE_CORE" == "1" ]]; then
    echo "[replace] Updating core binary"
    replace_file_atomically "$SOURCE_CORE_PATH" "$TARGET_CORE_PATH"
  else
    echo "[replace] Skipping core binary (${CORE_REPLACE_REASON})"
  fi

  echo "[replace] Updating management asset"
  replace_file_atomically "$SOURCE_MANAGEMENT_PATH" "$TARGET_MANAGEMENT_PATH"

  echo "[replace] Updating app bundle"
  replace_bundle_atomically "$SOURCE_APP_PATH" "$TARGET_APP_PATH_RESOLVED"

  target_app_exec="$(app_executable_path "$TARGET_APP_PATH_RESOLVED" "$TARGET_EXECUTABLE_NAME")"

  cat >"$TARGET_REPLACE_MANIFEST" <<EOF
replaced_at=$(date '+%Y-%m-%d %H:%M:%S %z')
target=${TARGET}
target_app=${TARGET_APP_PATH_RESOLVED}
target_core=${TARGET_CORE_PATH}
target_management=${TARGET_MANAGEMENT_PATH}
replace_core=${SHOULD_REPLACE_CORE}
replace_core_reason=${CORE_REPLACE_REASON}
backup_app=${TARGET_APP_BACKUP}
backup_core=${TARGET_CORE_BACKUP}
backup_management=${TARGET_MANAGEMENT_BACKUP}
source_app=${SOURCE_APP_PATH}
source_core=${SOURCE_CORE_PATH}
source_management=${SOURCE_MANAGEMENT_PATH}
app_exec_sha256=$(hash_file "$target_app_exec")
core_sha256=$(hash_file "$TARGET_CORE_PATH")
management_sha256=$(hash_file "$TARGET_MANAGEMENT_PATH")
EOF

  echo "[replace] Manifest written: $TARGET_REPLACE_MANIFEST"

  if [[ "$RELAUNCH" == "1" ]]; then
    echo "[start] Relaunching ${TARGET_PRODUCT_NAME}"
    open "$TARGET_APP_PATH_RESOLVED"
    wait_for_port_state "$TARGET_CLIENT_PORT" listening "$WAIT_TIMEOUT"
    wait_for_port_state "$TARGET_CORE_PORT" listening "$WAIT_TIMEOUT"
    if [[ "$VERIFY_HEALTH" == "1" ]]; then
      curl -fsS "http://127.0.0.1:${TARGET_CORE_PORT}/healthz" >/dev/null
      echo "[verify] Internal core healthz is ready on ${TARGET_CORE_PORT}"
    fi
  fi

  if [[ "$VERIFY_MANAGEMENT" == "1" ]]; then
    verify_management_asset
  fi

  echo
  echo "Replacement completed."
  echo "  app_backup  : ${TARGET_APP_BACKUP}"
  echo "  core_backup : ${TARGET_CORE_BACKUP}"
  echo "  mgmt_backup : ${TARGET_MANAGEMENT_BACKUP}"
  echo "  rollback    : TARGET=${TARGET} MANIFEST=\"${TARGET_REPLACE_MANIFEST}\" ./scripts/rollback-local-quotio-runtime.sh"
}

require_cmd xcodebuild
require_cmd python3
require_cmd shasum
require_cmd lsof
require_cmd ditto
require_cmd curl

COMMAND="${1:-}"

case "$COMMAND" in
  build-staging)
    build_staged_core
    build_staged_management_html
    build_staged_app "dev.quotio.desktop" "Quotio" "Quotio" "AppIcon" "$PROD_DERIVED_DATA" "$PROD_STAGING_APP"
    build_staged_app "dev.quotio.desktop.dev" "Quotio Dev" "Quotio Dev" "AppIconDev" "$DEV_DERIVED_DATA" "$DEV_STAGING_APP"
    write_staging_manifest
    ;;
  plan|apply)
    resolve_target_metadata
    TARGET_APP_PATH_RESOLVED="$(resolve_target_app_path)"
    TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
    TARGET_BACKUP_ROOT="${TARGET_APP_SUPPORT}/backups/local-runtime-replace"
    TARGET_APP_BACKUP="${TARGET_BACKUP_ROOT}/$(basename "$TARGET_APP_PATH_RESOLVED").${TIMESTAMP}.bak"
    TARGET_CORE_BACKUP="${TARGET_BACKUP_ROOT}/CLIProxyAPI.${TIMESTAMP}.bak"
    TARGET_MANAGEMENT_BACKUP="${TARGET_BACKUP_ROOT}/management.html.${TIMESTAMP}.bak"
    TARGET_REPLACE_MANIFEST="${TARGET_BACKUP_ROOT}/replace.${TARGET}.${TIMESTAMP}.txt"
    apply_replacement
    ;;
  *)
    usage
    exit 1
    ;;
esac
