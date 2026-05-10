#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CORE_SRC="${SOURCE_ROOT}/third_party/CLIProxyAPIPlus"

ACTION="deploy"
EXECUTE=0
REMOTE_READ=0
MANIFEST_PATH=""

REMOTE_HOST="${REMOTE_HOST:-wisedata@10.1.1.201}"
DEPLOY_DIR="${DEPLOY_DIR:-/home/wisedata/deploy/cliproxyapi-plus}"
API_PORT="${API_PORT:-18317}"
SERVER_HOST_IP="${SERVER_HOST_IP:-10.1.1.201}"
SERVER_TLS_ENABLE="${SERVER_TLS_ENABLE:-1}"
SERVER_TLS_CURL_INSECURE="${SERVER_TLS_CURL_INSECURE:-1}"
CONTAINER_NAME="${CONTAINER_NAME:-cliproxyapi-plus-remote}"
IMAGE_NAME="${IMAGE_NAME:-cliproxyapi-plus:linux-server}"
IMAGE_PLATFORM="${IMAGE_PLATFORM:-linux/amd64}"
BUILD_STRATEGY="${BUILD_STRATEGY:-local-load}"
SYNC_AUTH_DIR="${SYNC_AUTH_DIR:-0}"
PRESERVE_REMOTE_MANAGEMENT_SECRET="${PRESERVE_REMOTE_MANAGEMENT_SECRET:-0}"
REMOTE_MANAGEMENT_SECRET_FILE="${REMOTE_MANAGEMENT_SECRET_FILE:-${DEPLOY_DIR}/runtime/secrets.env}"
ARTIFACT_ROOT="${ARTIFACT_ROOT:-${SOURCE_ROOT}/build/remote-deploy-safety}"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/deploy-cliproxy-linux-safe.sh [plan|deploy] [--dry-run|--execute] [--remote-read]
  ./scripts/deploy-cliproxy-linux-safe.sh rollback --manifest <manifest.env> [--dry-run|--execute]

Default action is deploy in dry-run mode. Dry-run prints the exact read-only checks,
backup, rollback-tag, deploy, version-proof, and rollback commands without restarting
the remote core.

Deploy environment:
  REMOTE_HOST              Default: wisedata@10.1.1.201
  DEPLOY_DIR               Default: /home/wisedata/deploy/cliproxyapi-plus
  SERVER_HOST_IP           Default: 10.1.1.201
  API_PORT                 Default: 18317
  MANAGEMENT_PASSWORD      Required only for --execute and auth-files/version proof checks
  PRESERVE_REMOTE_MANAGEMENT_SECRET
                            Set to 1 to keep remote runtime/secrets.env and prove auth-files
                            via remote-local curl without printing the secret
  IMAGE_NAME               Default: cliproxyapi-plus:linux-server
  BUILD_STRATEGY           Default: local-load
  SYNC_AUTH_DIR            Default: 0; safe helper never syncs auth by default
  CORE_BUILD_VERSION       Optional override for Docker build arg VERSION
  CORE_BUILD_COMMIT        Optional override for Docker build arg COMMIT
  CORE_BUILD_DATE          Optional override for Docker build arg BUILD_DATE
  SAFE_LOCAL_ARTIFACT_PROOF Set to 0 to skip local buildinfo artifact proof

Safety:
  --execute is required before any remote backup, docker tag, deploy, compose restart,
  or rollback restart. --remote-read may be used with dry-run for read-only SSH/curl
  inspection only.
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

shell_quote() {
  printf "%q" "$1"
}

run_or_print() {
  if [[ "${EXECUTE}" == "1" ]]; then
    "$@"
  else
    printf '[dry-run] '
    local arg
    for arg in "$@"; do
      if [[ -n "${MANAGEMENT_PASSWORD:-}" ]]; then
        arg="${arg//${MANAGEMENT_PASSWORD}/<MANAGEMENT_PASSWORD>}"
      fi
      printf '%q ' "${arg}"
    done
    printf '\n'
  fi
}

assert_version_headers() {
  local label="$1"
  local headers_file="$2"
  python3 - "$label" "$headers_file" "${CORE_BUILD_VERSION}-plus" "${CORE_BUILD_COMMIT}" "${CORE_BUILD_DATE}" <<'PY'
import sys

label, headers_file, expected_version, expected_commit, expected_build_date = sys.argv[1:6]
expected = {
    "x-cpa-version": expected_version,
    "x-cpa-commit": expected_commit,
    "x-cpa-build-date": expected_build_date,
}
headers = {}
with open(headers_file, "r", encoding="utf-8", errors="replace") as fh:
    for raw_line in fh:
        line = raw_line.strip()
        if not line or ":" not in line:
            continue
        name, value = line.split(":", 1)
        headers[name.strip().lower()] = value.strip()
missing = [name for name in expected if name not in headers]
mismatched = [
    f"{name}: got {headers.get(name)!r}, want {want!r}"
    for name, want in expected.items()
    if name in headers and headers[name] != want
]
if missing or mismatched:
    details = []
    if missing:
        details.append("missing " + ", ".join(missing))
    details.extend(mismatched)
    print(f"{label} version header check failed: " + "; ".join(details), file=sys.stderr)
    sys.exit(1)
print(f"{label} version headers OK")
PY
}

ssh_or_print() {
  local command="$1"
  if [[ "${EXECUTE}" == "1" ]]; then
    ssh "${REMOTE_HOST}" "${command}"
  else
    printf '[dry-run] ssh %q %q\n' "${REMOTE_HOST}" "${command}"
  fi
}

remote_read() {
  local command="$1"
  if [[ "${EXECUTE}" == "1" || "${REMOTE_READ}" == "1" ]]; then
    ssh "${REMOTE_HOST}" "${command}"
  else
    printf '[dry-run] ssh %q %q\n' "${REMOTE_HOST}" "${command}"
  fi
}

build_metadata() {
  [[ -d "${CORE_SRC}" ]] || die "CLIProxyAPIPlus source not found: ${CORE_SRC}"

  CORE_BUILD_VERSION="${CORE_BUILD_VERSION:-$(git -C "${CORE_SRC}" describe --tags --always --dirty 2>/dev/null || echo dev)}"
  CORE_BUILD_COMMIT="${CORE_BUILD_COMMIT:-$(git -C "${CORE_SRC}" rev-parse HEAD 2>/dev/null || echo none)}"
  if [[ "${CORE_BUILD_COMMIT}" != "none" ]] && git -C "${CORE_SRC}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if ! git -C "${CORE_SRC}" diff --quiet --ignore-submodules -- 2>/dev/null || ! git -C "${CORE_SRC}" diff --cached --quiet --ignore-submodules -- 2>/dev/null; then
      case "${CORE_BUILD_COMMIT}" in
        *-dirty) ;;
        *) CORE_BUILD_COMMIT="${CORE_BUILD_COMMIT}-dirty" ;;
      esac
    fi
  fi
  CORE_BUILD_DATE="${CORE_BUILD_DATE:-$(date -u '+%Y-%m-%dT%H:%M:%SZ')}"
}

base_url() {
  if [[ "${SERVER_TLS_ENABLE}" == "1" ]]; then
    printf 'https://%s:%s' "${SERVER_HOST_IP}" "${API_PORT}"
  else
    printf 'http://%s:%s' "${SERVER_HOST_IP}" "${API_PORT}"
  fi
}

curl_args() {
  if [[ "${SERVER_TLS_ENABLE}" == "1" && "${SERVER_TLS_CURL_INSECURE}" == "1" ]]; then
    printf '%s\n' -kfsS
  else
    printf '%s\n' -fsS
  fi
}

write_manifest() {
  local stamp="$1"
  local dir="${ARTIFACT_ROOT}/${stamp}"
  mkdir -p "${dir}"
  MANIFEST_PATH="${dir}/manifest.env"
  cat >"${MANIFEST_PATH}" <<EOF
stamp=${stamp}
remote_host=${REMOTE_HOST}
deploy_dir=${DEPLOY_DIR}
container_name=${CONTAINER_NAME}
image_name=${IMAGE_NAME}
rollback_image=${IMAGE_NAME}-rollback-${stamp}
remote_backup_dir=${DEPLOY_DIR}/backups/deploy-safe-${stamp}
base_url=$(base_url)
core_build_version=${CORE_BUILD_VERSION}
core_build_commit=${CORE_BUILD_COMMIT}
core_build_date=${CORE_BUILD_DATE}
expected_x_cpa_version=${CORE_BUILD_VERSION}-plus
expected_x_cpa_commit=${CORE_BUILD_COMMIT}
expected_x_cpa_build_date=${CORE_BUILD_DATE}
sync_auth_dir=${SYNC_AUTH_DIR}
preserve_remote_management_secret=${PRESERVE_REMOTE_MANAGEMENT_SECRET}
remote_management_secret_file=${REMOTE_MANAGEMENT_SECRET_FILE}
build_strategy=${BUILD_STRATEGY}
image_platform=${IMAGE_PLATFORM}
EOF
  {
    echo "CORE_BUILD_VERSION=${CORE_BUILD_VERSION}"
    echo "CORE_BUILD_COMMIT=${CORE_BUILD_COMMIT}"
    echo "CORE_BUILD_DATE=${CORE_BUILD_DATE}"
  } >"${dir}/core-buildinfo.env"
  {
    echo "X-CPA-VERSION=${CORE_BUILD_VERSION}-plus"
    echo "X-CPA-COMMIT=${CORE_BUILD_COMMIT}"
    echo "X-CPA-BUILD-DATE=${CORE_BUILD_DATE}"
  } >"${dir}/expected-headers.env"
  echo "${MANIFEST_PATH}"
}

load_manifest() {
  local manifest="$1"
  [[ -f "${manifest}" ]] || die "manifest not found: ${manifest}"
  # shellcheck disable=SC1090
  source "${manifest}"
  REMOTE_HOST="${remote_host}"
  DEPLOY_DIR="${deploy_dir}"
  CONTAINER_NAME="${container_name}"
  IMAGE_NAME="${image_name}"
  PRESERVE_REMOTE_MANAGEMENT_SECRET="${preserve_remote_management_secret:-0}"
  REMOTE_MANAGEMENT_SECRET_FILE="${remote_management_secret_file:-${DEPLOY_DIR}/runtime/secrets.env}"
}

preflight_checks() {
  local url
  url="$(base_url)"
  echo "[plan] Read-only preflight checks"
  run_or_print curl "$(curl_args)" "${url}/healthz"
  run_or_print curl "$(curl_args)" "${url}/management.html" -o /tmp/cliproxy-management.preflight.html
  if [[ -n "${MANAGEMENT_PASSWORD:-}" ]]; then
    run_or_print curl "$(curl_args)" -D /tmp/cliproxy-auth-files.preflight.headers \
      -H "Authorization: Bearer ${MANAGEMENT_PASSWORD}" \
      "${url}/v0/management/auth-files" -o /tmp/cliproxy-auth-files.preflight.json
  else
    echo "[plan] MANAGEMENT_PASSWORD not set; auth-files header proof will be skipped until execute/window."
  fi
}

remote_prepare_commands() {
  local stamp="$1"
  local rollback_image="${IMAGE_NAME}-rollback-${stamp}"
  local backup_dir="${DEPLOY_DIR}/backups/deploy-safe-${stamp}"

  echo "[plan] Remote current image proof"
  remote_read "sudo docker inspect -f 'container={{.Name}} image_id={{.Image}}' '${CONTAINER_NAME}' 2>/dev/null || true"

  echo "[plan] Remote rollback image tag"
  ssh_or_print "set -euo pipefail; image_id=\$(sudo docker inspect -f '{{.Image}}' '${CONTAINER_NAME}' 2>/dev/null || true); if [ -n \"\$image_id\" ]; then sudo docker tag \"\$image_id\" '${rollback_image}'; sudo docker image inspect '${rollback_image}' --format 'rollback_image={{.RepoTags}} image_id={{.Id}}'; else echo 'no running container image found for rollback tag' >&2; exit 1; fi"

  echo "[plan] Remote non-auth runtime backup"
  ssh_or_print "set -euo pipefail; umask 077; mkdir -p '${backup_dir}'; cd '${DEPLOY_DIR}'; tar -czf '${backup_dir}/runtime-non-auth.tgz' --ignore-failed-read --warning=no-file-changed --exclude='runtime/config/logs' --exclude='runtime/logs' compose.yaml runtime/config runtime/static runtime/tls runtime/secrets.env; printf 'backup_dir=%s\nbackup_archive=%s\n' '${backup_dir}' '${backup_dir}/runtime-non-auth.tgz'"
}

execute_deploy() {
  if [[ "${EXECUTE}" == "1" && -z "${MANAGEMENT_PASSWORD:-}" && "${PRESERVE_REMOTE_MANAGEMENT_SECRET}" != "1" ]]; then
    die "MANAGEMENT_PASSWORD is required for --execute"
  fi
  echo "[plan] Standard deploy command"
  run_or_print env \
    "REMOTE_HOST=${REMOTE_HOST}" \
    "DEPLOY_DIR=${DEPLOY_DIR}" \
    "API_PORT=${API_PORT}" \
    "SERVER_HOST_IP=${SERVER_HOST_IP}" \
    "BIND_HOST=${BIND_HOST:-${SERVER_HOST_IP}}" \
    "MANAGEMENT_PASSWORD=${MANAGEMENT_PASSWORD:-}" \
    "PRESERVE_REMOTE_MANAGEMENT_SECRET=${PRESERVE_REMOTE_MANAGEMENT_SECRET}" \
    "IMAGE_NAME=${IMAGE_NAME}" \
    "IMAGE_PLATFORM=${IMAGE_PLATFORM}" \
    "BUILD_STRATEGY=${BUILD_STRATEGY}" \
    "SYNC_AUTH_DIR=${SYNC_AUTH_DIR}" \
    "SERVER_TLS_ENABLE=${SERVER_TLS_ENABLE}" \
    "SERVER_TLS_CURL_INSECURE=${SERVER_TLS_CURL_INSECURE}" \
    "QUOTIO_SOURCE_ROOT=${SOURCE_ROOT}" \
    "CORE_BUILD_VERSION=${CORE_BUILD_VERSION}" \
    "CORE_BUILD_COMMIT=${CORE_BUILD_COMMIT}" \
    "CORE_BUILD_DATE=${CORE_BUILD_DATE}" \
    "${SCRIPT_DIR}/deploy-cliproxy-linux.sh"
}

postdeploy_checks() {
  local url
  url="$(base_url)"
  echo "[plan] Post-deploy version proof"
  run_or_print curl "$(curl_args)" -D /tmp/cliproxy-health.postdeploy.headers \
    "${url}/healthz" -o /tmp/cliproxy-health.postdeploy.json
  if [[ "${EXECUTE}" == "1" ]]; then
    assert_version_headers "healthz" /tmp/cliproxy-health.postdeploy.headers
  fi
  run_or_print curl "$(curl_args)" -D /tmp/cliproxy-management.postdeploy.headers \
    "${url}/management.html" -o /tmp/cliproxy-management.postdeploy.html
  if [[ "${EXECUTE}" == "1" ]]; then
    assert_version_headers "management.html" /tmp/cliproxy-management.postdeploy.headers
  fi
  if [[ -n "${MANAGEMENT_PASSWORD:-}" ]]; then
    run_or_print curl "$(curl_args)" -D /tmp/cliproxy-auth-files.postdeploy.headers \
      -H "Authorization: Bearer ${MANAGEMENT_PASSWORD}" \
      "${url}/v0/management/auth-files" -o /tmp/cliproxy-auth-files.postdeploy.json
    if [[ "${EXECUTE}" == "1" ]]; then
      assert_version_headers "auth-files" /tmp/cliproxy-auth-files.postdeploy.headers
    fi
  elif [[ "${PRESERVE_REMOTE_MANAGEMENT_SECRET}" == "1" ]]; then
    if [[ "${EXECUTE}" == "1" ]]; then
      ssh "${REMOTE_HOST}" "set -euo pipefail; set -a; . '${REMOTE_MANAGEMENT_SECRET_FILE}'; set +a; curl -kfsS -D /tmp/cliproxy-auth-files.postdeploy.headers -H \"Authorization: Bearer \${MANAGEMENT_PASSWORD}\" '${url}/v0/management/auth-files' -o /tmp/cliproxy-auth-files.postdeploy.json; cat /tmp/cliproxy-auth-files.postdeploy.headers" > /tmp/cliproxy-auth-files.postdeploy.headers
      assert_version_headers "auth-files" /tmp/cliproxy-auth-files.postdeploy.headers
    else
      printf '[dry-run] ssh %q %q\n' "${REMOTE_HOST}" "remote-secret auth-files version proof"
    fi
  else
    die "MANAGEMENT_PASSWORD is required for auth-files postdeploy proof unless PRESERVE_REMOTE_MANAGEMENT_SECRET=1"
  fi
  echo "[plan] Expected response headers after deploy:"
  echo "  X-CPA-VERSION: ${CORE_BUILD_VERSION}-plus"
  echo "  X-CPA-COMMIT: ${CORE_BUILD_COMMIT}"
  echo "  X-CPA-BUILD-DATE: ${CORE_BUILD_DATE}"
}

local_artifact_proof() {
  local manifest="$1"
  local dir
  dir="$(cd "$(dirname "${manifest}")" && pwd)"
  if [[ "${SAFE_LOCAL_ARTIFACT_PROOF:-1}" == "0" ]]; then
    echo "[plan] Local artifact buildinfo proof skipped by SAFE_LOCAL_ARTIFACT_PROOF=0"
    return
  fi

  require_cmd go
  local binary="${dir}/CLIProxyAPIPlus.version-proof"
  local output="${dir}/local-artifact-version.txt"
  local expected_line="CLIProxyAPI Version: ${CORE_BUILD_VERSION}-plus, Commit: ${CORE_BUILD_COMMIT}, BuiltAt: ${CORE_BUILD_DATE}"
  echo "[plan] Local artifact buildinfo proof"
  (
    cd "${CORE_SRC}"
    GOTOOLCHAIN="${GOTOOLCHAIN:-auto}" go build \
      -ldflags="-s -w -X 'main.Version=${CORE_BUILD_VERSION}-plus' -X 'main.Commit=${CORE_BUILD_COMMIT}' -X 'main.BuildDate=${CORE_BUILD_DATE}'" \
      -o "${binary}" ./cmd/server/
  )
  "${binary}" -h >"${output}" 2>&1 || true
  if ! grep -Fqx "${expected_line}" "${output}"; then
    echo "error: local artifact buildinfo proof failed; expected first-line metadata not found" >&2
    echo "expected: ${expected_line}" >&2
    echo "output: ${output}" >&2
    sed -n '1,5p' "${output}" >&2
    exit 1
  fi
  echo "[plan] Local artifact buildinfo OK: ${expected_line}"
}

deploy_plan() {
  require_cmd git
  require_cmd date
  build_metadata

  local stamp
  stamp="$(date -u '+%Y%m%dT%H%M%SZ')"
  local manifest
  manifest="$(write_manifest "${stamp}")"

  echo "[plan] Mode: $([[ "${EXECUTE}" == "1" ]] && echo execute || echo dry-run)"
  echo "[plan] Manifest: ${manifest}"
  echo "[plan] Remote: ${REMOTE_HOST}:${DEPLOY_DIR}"
  echo "[plan] Image: ${IMAGE_NAME}"
  echo "[plan] Build args: VERSION=${CORE_BUILD_VERSION} COMMIT=${CORE_BUILD_COMMIT} BUILD_DATE=${CORE_BUILD_DATE}"
  echo "[plan] Expected headers: X-CPA-VERSION=${CORE_BUILD_VERSION}-plus X-CPA-COMMIT=${CORE_BUILD_COMMIT} X-CPA-BUILD-DATE=${CORE_BUILD_DATE}"
  echo "[plan] Auth sync: SYNC_AUTH_DIR=${SYNC_AUTH_DIR} (safe default is 0)"
  if [[ "${SYNC_AUTH_DIR}" != "0" ]]; then
    die "safe helper refuses SYNC_AUTH_DIR=${SYNC_AUTH_DIR}; use SYNC_AUTH_DIR=0 to avoid auth token writes"
  fi

  local_artifact_proof "${manifest}"
  preflight_checks
  remote_prepare_commands "${stamp}"
  execute_deploy
  postdeploy_checks

  echo "[plan] Rollback command:"
  echo "  ./scripts/deploy-cliproxy-linux-safe.sh rollback --manifest $(shell_quote "${manifest}") --execute"
  if [[ "${EXECUTE}" != "1" ]]; then
    echo "[dry-run] No remote deployment, restart, backup, or docker tag was performed."
  fi
}

rollback_plan() {
  [[ -n "${MANIFEST_PATH}" ]] || die "rollback requires --manifest <manifest.env>"
  load_manifest "${MANIFEST_PATH}"

  echo "[rollback] Mode: $([[ "${EXECUTE}" == "1" ]] && echo execute || echo dry-run)"
  echo "[rollback] Manifest: ${MANIFEST_PATH}"
  echo "[rollback] Remote backup: ${remote_backup_dir}"
  echo "[rollback] Rollback image: ${rollback_image}"
  ssh_or_print "set -euo pipefail; cd '${DEPLOY_DIR}'; test -f '${remote_backup_dir}/runtime-non-auth.tgz'; tar -xzf '${remote_backup_dir}/runtime-non-auth.tgz' -C '${DEPLOY_DIR}'; sudo docker image inspect '${rollback_image}' >/dev/null; sudo docker tag '${rollback_image}' '${IMAGE_NAME}'; sudo docker compose up -d"
  echo "[rollback] Post-rollback health check:"
  run_or_print curl "$(curl_args)" "$(base_url)/healthz"
  if [[ "${EXECUTE}" != "1" ]]; then
    echo "[dry-run] No remote rollback or restart was performed."
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    plan|deploy|rollback)
      ACTION="$1"
      shift
      ;;
    --dry-run)
      EXECUTE=0
      shift
      ;;
    --execute)
      EXECUTE=1
      shift
      ;;
    --remote-read)
      REMOTE_READ=1
      shift
      ;;
    --manifest)
      MANIFEST_PATH="${2:-}"
      [[ -n "${MANIFEST_PATH}" ]] || die "--manifest requires a path"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

case "${ACTION}" in
  plan|deploy) deploy_plan ;;
  rollback) rollback_plan ;;
  *) die "unknown action: ${ACTION}" ;;
esac
