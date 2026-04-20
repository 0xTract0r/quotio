#!/usr/bin/env bash
set -euo pipefail

REMOTE_HOST="${REMOTE_HOST:-}"
DEPLOY_DIR="${DEPLOY_DIR:-/home/wisedata/deploy/cliproxyapi-plus}"
TLS_DIR="${TLS_DIR:-${DEPLOY_DIR}/runtime/tls}"
BACKUP_DIR="${BACKUP_DIR:-${DEPLOY_DIR}/backups}"
HOST_IP="${HOST_IP:-10.1.1.201}"
COMMON_NAME="${COMMON_NAME:-${HOST_IP}}"
DAYS="${DAYS:-365}"
OVERWRITE="${OVERWRITE:-0}"
OPENSSL_BIN="${OPENSSL_BIN:-/usr/bin/openssl}"
KEY_FILE_NAME="${KEY_FILE_NAME:-server.key}"
CERT_FILE_NAME="${CERT_FILE_NAME:-server.crt}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

validate_toggle_flag() {
  local name="$1"
  local value="$2"
  case "${value}" in
    0|1) ;;
    *)
      echo "${name} must be 0 or 1, got: ${value}" >&2
      exit 1
      ;;
  esac
}

usage() {
  cat <<'EOF'
用法：
  REMOTE_HOST='wisedata@10.1.1.201' \
  DEPLOY_DIR='/home/wisedata/deploy/cliproxyapi-plus' \
  HOST_IP='10.1.1.201' \
  ./scripts/generate-cliproxy-self-signed-cert-remote.sh

可选环境变量：
  TLS_DIR        远端 TLS 输出目录，默认 <DEPLOY_DIR>/runtime/tls
  BACKUP_DIR     远端备份目录，默认 <DEPLOY_DIR>/backups
  HOST_IP        证书 SAN 里的 IP，默认 10.1.1.201
  COMMON_NAME    证书 CN，默认与 HOST_IP 相同
  DAYS           有效期天数，默认 365
  OVERWRITE      是否允许覆盖已有 server.crt/server.key，默认 0
  OPENSSL_BIN    远端 openssl 路径，默认 /usr/bin/openssl
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

[[ -n "${REMOTE_HOST}" ]] || {
  echo "REMOTE_HOST is required, e.g. wisedata@10.1.1.201" >&2
  exit 1
}

require_cmd ssh
validate_toggle_flag "OVERWRITE" "${OVERWRITE}"

if [[ ! "${DAYS}" =~ ^[0-9]+$ ]] || (( DAYS <= 0 )); then
  echo "DAYS must be a positive integer, got: ${DAYS}" >&2
  exit 1
fi

if [[ -z "${HOST_IP}" ]]; then
  echo "HOST_IP must not be empty" >&2
  exit 1
fi

ssh "${REMOTE_HOST}" 'bash -s' -- \
  "${TLS_DIR}" \
  "${BACKUP_DIR}" \
  "${HOST_IP}" \
  "${COMMON_NAME}" \
  "${DAYS}" \
  "${OVERWRITE}" \
  "${OPENSSL_BIN}" \
  "${KEY_FILE_NAME}" \
  "${CERT_FILE_NAME}" <<'REMOTE'
set -euo pipefail

tls_dir="$1"
backup_dir="$2"
host_ip="$3"
common_name="$4"
days="$5"
overwrite="$6"
openssl_bin="$7"
key_file_name="$8"
cert_file_name="$9"

umask 077

if [[ ! -x "${openssl_bin}" ]]; then
  echo "Remote openssl not executable: ${openssl_bin}" >&2
  exit 1
fi

mkdir -p "${tls_dir}" "${backup_dir}"
touch "${tls_dir}/.write-test.$$"
rm -f "${tls_dir}/.write-test.$$"

cert_path="${tls_dir%/}/${cert_file_name}"
key_path="${tls_dir%/}/${key_file_name}"

if [[ -e "${cert_path}" || -e "${key_path}" ]]; then
  if [[ "${overwrite}" != "1" ]]; then
    echo "Refusing to overwrite existing remote TLS files without OVERWRITE=1" >&2
    echo "existing_cert=${cert_path}"
    echo "existing_key=${key_path}"
    exit 1
  fi

  backup_stamp="$(date '+%Y%m%d-%H%M%S')"
  backup_target="${backup_dir%/}/tls-${backup_stamp}"
  mkdir -p "${backup_target}"
  if [[ -e "${cert_path}" ]]; then
    cp -p "${cert_path}" "${backup_target}/${cert_file_name}"
  fi
  if [[ -e "${key_path}" ]]; then
    cp -p "${key_path}" "${backup_target}/${key_file_name}"
  fi
  echo "backup_dir=${backup_target}"
fi

tmp_dir="$(mktemp -d "${tls_dir%/}/.generate-cert.XXXXXX")"
cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

cat > "${tmp_dir}/openssl.cnf" <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
CN = ${common_name}

[v3_req]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
IP.1 = ${host_ip}
EOF

"${openssl_bin}" req -x509 -nodes -newkey rsa:2048 \
  -keyout "${tmp_dir}/${key_file_name}" \
  -out "${tmp_dir}/${cert_file_name}" \
  -days "${days}" \
  -config "${tmp_dir}/openssl.cnf" >/dev/null 2>&1

chmod 600 "${tmp_dir}/${key_file_name}" "${tmp_dir}/${cert_file_name}"
mv -f "${tmp_dir}/${key_file_name}" "${key_path}"
mv -f "${tmp_dir}/${cert_file_name}" "${cert_path}"

echo "generated_remote_cert=${cert_path}"
echo "generated_remote_key=${key_path}"
"${openssl_bin}" x509 -in "${cert_path}" -noout -fingerprint -sha256 -dates -subject
echo "subject_alt_name:"
"${openssl_bin}" x509 -in "${cert_path}" -noout -text | sed -n '/Subject Alternative Name/{n;p;}' | xargs
REMOTE
