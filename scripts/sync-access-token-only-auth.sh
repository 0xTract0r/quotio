#!/usr/bin/env bash
set -euo pipefail

LOCAL_AUTH_FILE="${LOCAL_AUTH_FILE:-${1:-}}"
REMOTE_BASE_URL="${REMOTE_BASE_URL:-https://10.1.1.201:18317}"
REMOTE_AUTH_NAME="${REMOTE_AUTH_NAME:-}"
MANAGEMENT_KEY="${MANAGEMENT_KEY:-${REMOTE_MANAGEMENT_KEY:-}}"
REMOTE_HOST="${REMOTE_HOST:-wisedata@10.1.1.201}"
DEPLOY_DIR="${DEPLOY_DIR:-/home/wisedata/deploy/cliproxyapi-plus}"
OUT_DIR="${OUT_DIR:-build/access-token-only-auth-sync}"
EXECUTE="${EXECUTE:-0}"
CURL_INSECURE="${CURL_INSECURE:-1}"

if [[ -z "${LOCAL_AUTH_FILE}" ]]; then
  echo "LOCAL_AUTH_FILE is required, or pass it as the first argument" >&2
  exit 2
fi
if [[ ! -f "${LOCAL_AUTH_FILE}" ]]; then
  echo "LOCAL_AUTH_FILE not found: ${LOCAL_AUTH_FILE}" >&2
  exit 2
fi

mkdir -p "${OUT_DIR}"
chmod 700 "${OUT_DIR}" 2>/dev/null || true

if [[ -z "${REMOTE_AUTH_NAME}" ]]; then
  base_name="$(basename "${LOCAL_AUTH_FILE}")"
  base_name="${base_name%.json}"
  REMOTE_AUTH_NAME="${base_name}.access-token-only.json"
fi
if [[ "${REMOTE_AUTH_NAME}" != *.json ]]; then
  REMOTE_AUTH_NAME="${REMOTE_AUTH_NAME}.json"
fi

if [[ -z "${MANAGEMENT_KEY}" && -n "${REMOTE_HOST}" ]]; then
  MANAGEMENT_KEY="$(ssh "${REMOTE_HOST}" "set -a; . '${DEPLOY_DIR}/runtime/secrets.env' >/dev/null 2>&1; printf '%s' \"\${MANAGEMENT_PASSWORD:-}\"" 2>/dev/null || true)"
fi
if [[ -z "${MANAGEMENT_KEY}" ]]; then
  echo "MANAGEMENT_KEY is required; set MANAGEMENT_KEY or allow ssh to ${REMOTE_HOST} runtime/secrets.env" >&2
  exit 2
fi

sanitized_file="${OUT_DIR}/${REMOTE_AUTH_NAME}"
summary_file="${OUT_DIR}/summary.json"
remote_settings_file="${OUT_DIR}/remote-account-settings.json"

LOCAL_AUTH_FILE="${LOCAL_AUTH_FILE}" REMOTE_AUTH_NAME="${REMOTE_AUTH_NAME}" SANITIZED_FILE="${sanitized_file}" SUMMARY_FILE="${summary_file}" python3 <<'PY'
import json
import os
from pathlib import Path
from datetime import datetime, timezone

local_path = Path(os.environ["LOCAL_AUTH_FILE"])
remote_name = os.environ["REMOTE_AUTH_NAME"]
sanitized_path = Path(os.environ["SANITIZED_FILE"])
summary_path = Path(os.environ["SUMMARY_FILE"])

def load_json(path: Path):
    with path.open("r", encoding="utf-8") as fh:
        return json.load(fh)

def is_refresh_token_key(key: str) -> bool:
    compact = key.replace("_", "").replace("-", "").lower()
    return compact == "refreshtoken"

def strip_refresh_tokens(value):
    removed = []
    def walk(node, prefix=""):
        if isinstance(node, dict):
            for key in list(node.keys()):
                path = f"{prefix}.{key}" if prefix else key
                if is_refresh_token_key(key):
                    removed.append(path)
                    del node[key]
                    continue
                walk(node[key], path)
        elif isinstance(node, list):
            for index, item in enumerate(node):
                walk(item, f"{prefix}[{index}]")
    walk(value)
    return removed

def has_key(node, predicate):
    if isinstance(node, dict):
        for key, val in node.items():
            if predicate(key):
                return True
            if has_key(val, predicate):
                return True
    elif isinstance(node, list):
        return any(has_key(item, predicate) for item in node)
    return False

def find_access_token(node):
    if isinstance(node, dict):
        for key, val in node.items():
            if key == "access_token" and isinstance(val, str) and val.strip():
                return True
            if find_access_token(val):
                return True
    elif isinstance(node, list):
        return any(find_access_token(item) for item in node)
    return False

payload = load_json(local_path)
removed_paths = strip_refresh_tokens(payload)
if not find_access_token(payload):
    raise SystemExit("source auth does not contain an access_token; refusing to upload access-token-only auth")

payload["refresh_disabled"] = True
payload["refresh_enabled"] = False
payload.setdefault("note", "")
if not str(payload.get("note") or "").strip():
    payload["note"] = "access-token-only remote validation copy; refresh disabled"
settings = payload.get("account_settings")
if not isinstance(settings, dict):
    settings = {}
settings.setdefault("schema_version", 1)
settings["refresh_enabled"] = False
payload["account_settings"] = settings

sanitized_path.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
os.chmod(sanitized_path, 0o600)
summary = {
    "local_auth_file": str(local_path),
    "remote_auth_name": remote_name,
    "sanitized_file": str(sanitized_path),
    "source_has_access_token": True,
    "removed_refresh_token_paths_count": len(removed_paths),
    "removed_refresh_token_paths": removed_paths,
    "sanitized_has_refresh_token_like_key": has_key(payload, is_refresh_token_key),
    "refresh_disabled": payload.get("refresh_disabled") is True,
    "account_settings_refresh_enabled": settings.get("refresh_enabled"),
    "generated_at": datetime.now(timezone.utc).isoformat(),
}
summary_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
PY

if [[ "${EXECUTE}" != "1" ]]; then
  echo "[dry-run] sanitized auth written to ${sanitized_file}" >&2
  echo "[dry-run] summary written to ${summary_file}" >&2
  echo "[dry-run] set EXECUTE=1 to upload ${REMOTE_AUTH_NAME} to ${REMOTE_BASE_URL}" >&2
  exit 0
fi

curl_args=(-fsS)
if [[ "${CURL_INSECURE}" == "1" ]]; then
  curl_args+=(-k)
fi

upload_url="${REMOTE_BASE_URL%/}/v0/management/auth-files?name=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "${REMOTE_AUTH_NAME}")"
settings_url="${REMOTE_BASE_URL%/}/v0/management/auth-files/account-settings?name=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "${REMOTE_AUTH_NAME}")"

echo "[sync] uploading access-token-only auth as ${REMOTE_AUTH_NAME}" >&2
curl "${curl_args[@]}" \
  -X POST "${upload_url}" \
  -H "Authorization: Bearer ${MANAGEMENT_KEY}" \
  -H "Content-Type: application/json" \
  --data-binary "@${sanitized_file}" >/dev/null

echo "[sync] verifying account settings" >&2
curl "${curl_args[@]}" \
  -H "Authorization: Bearer ${MANAGEMENT_KEY}" \
  "${settings_url}" > "${remote_settings_file}"

REMOTE_SETTINGS_FILE="${remote_settings_file}" SUMMARY_FILE="${summary_file}" python3 <<'PY'
import json
import os
from pathlib import Path
summary_path = Path(os.environ["SUMMARY_FILE"])
settings_path = Path(os.environ["REMOTE_SETTINGS_FILE"])
summary = json.loads(summary_path.read_text(encoding="utf-8"))
settings = json.loads(settings_path.read_text(encoding="utf-8"))
account_settings = settings.get("account_settings") or {}
summary["remote_upload_status"] = "ok"
summary["remote_settings_file"] = str(settings_path)
summary["remote_refresh_enabled"] = account_settings.get("refresh_enabled")
summary["remote_activation_state"] = (account_settings.get("activation") or {}).get("state")
summary["remote_warnings_count"] = len(account_settings.get("warnings") or [])
summary_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
if account_settings.get("refresh_enabled") is not False:
    raise SystemExit("remote account_settings.refresh_enabled is not false")
PY

echo "[sync] done; summary: ${summary_file}" >&2
