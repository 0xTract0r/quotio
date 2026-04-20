#!/usr/bin/env bash
set -euo pipefail

HOST_IP="${HOST_IP:-10.1.1.201}"
COMMON_NAME="${COMMON_NAME:-${HOST_IP}}"
DAYS="${DAYS:-365}"
OUTPUT_DIR="${OUTPUT_DIR:-}"
KEY_FILE_NAME="${KEY_FILE_NAME:-server.key}"
CERT_FILE_NAME="${CERT_FILE_NAME:-server.crt}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

usage() {
  cat <<'EOF'
用法：
  HOST_IP=10.1.1.201 OUTPUT_DIR=/abs/path/to/out ./scripts/generate-cliproxy-self-signed-cert.sh

可选环境变量：
  HOST_IP        证书 SAN 里的 IP，默认 10.1.1.201
  COMMON_NAME    证书 CN，默认与 HOST_IP 相同
  DAYS           有效期天数，默认 365
  OUTPUT_DIR     输出目录；未传时自动创建到 ./build/https-recovery/<timestamp>
  KEY_FILE_NAME  私钥文件名，默认 server.key
  CERT_FILE_NAME 证书文件名，默认 server.crt
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

require_cmd openssl
require_cmd python3

if [[ ! "${DAYS}" =~ ^[0-9]+$ ]] || (( DAYS <= 0 )); then
  echo "DAYS must be a positive integer, got: ${DAYS}" >&2
  exit 1
fi

if [[ -z "${OUTPUT_DIR}" ]]; then
  timestamp="$(date '+%Y%m%d-%H%M%S')"
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  repo_root="$(cd "${script_dir}/.." && pwd)"
  OUTPUT_DIR="${repo_root}/build/https-recovery/${timestamp}"
fi

mkdir -p "${OUTPUT_DIR}"
KEY_PATH="${OUTPUT_DIR}/${KEY_FILE_NAME}"
CERT_PATH="${OUTPUT_DIR}/${CERT_FILE_NAME}"

if [[ -e "${KEY_PATH}" || -e "${CERT_PATH}" ]]; then
  echo "Refusing to overwrite existing files in ${OUTPUT_DIR}" >&2
  exit 1
fi

tmp_conf="$(mktemp)"
cleanup() {
  rm -f "${tmp_conf}"
}
trap cleanup EXIT

cat > "${tmp_conf}" <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
CN = ${COMMON_NAME}

[v3_req]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
IP.1 = ${HOST_IP}
EOF

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout "${KEY_PATH}" \
  -out "${CERT_PATH}" \
  -days "${DAYS}" \
  -config "${tmp_conf}" >/dev/null 2>&1

chmod 600 "${KEY_PATH}" "${CERT_PATH}"

echo "generated_cert=${CERT_PATH}"
echo "generated_key=${KEY_PATH}"
openssl x509 -in "${CERT_PATH}" -noout -fingerprint -sha256 -dates -subject
echo "subject_alt_name:"
openssl x509 -in "${CERT_PATH}" -noout -text | sed -n '/Subject Alternative Name/{n;p;}' | xargs
