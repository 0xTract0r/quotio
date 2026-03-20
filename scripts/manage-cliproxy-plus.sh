#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/router-for-me/CLIProxyAPIPlus.git}"
BASE_COMMIT="${BASE_COMMIT:-7c2ad4c}"
GO_TOOLCHAIN_MODE="${GO_TOOLCHAIN_MODE:-auto}"
VENDOR_DIR="${ROOT_DIR}/third_party/CLIProxyAPIPlus"
BIN_DIR="${ROOT_DIR}/build/CLIProxyAPIPlus"
BIN_PATH="${BIN_DIR}/CLIProxyAPI"

usage() {
  cat <<EOF
Usage:
  $0 bootstrap
  $0 build
  $0 status
EOF
}

ensure_submodule_ready() {
  git submodule update --init --recursive "${VENDOR_DIR}"
  if [[ ! -d "${VENDOR_DIR}/.git" && ! -f "${VENDOR_DIR}/.git" ]]; then
    echo "CLIProxyAPIPlus submodule is missing: ${VENDOR_DIR}" >&2
    exit 1
  fi
}

bootstrap() {
  ensure_submodule_ready
  echo "Submodule ready at: ${VENDOR_DIR}"
  git -C "${VENDOR_DIR}" rev-parse --short HEAD
}

build() {
  bootstrap
  mkdir -p "${BIN_DIR}"
  (
    cd "${VENDOR_DIR}"
    GOTOOLCHAIN="${GO_TOOLCHAIN_MODE}" go build -o "${BIN_PATH}" ./cmd/server
  )
  echo "Built patched binary: ${BIN_PATH}"
}

status_cmd() {
  ensure_submodule_ready
  git -C "${VENDOR_DIR}" status --short
  echo "---"
  git -C "${VENDOR_DIR}" rev-parse --short HEAD
  echo "---"
  git -C "${VENDOR_DIR}" remote -v
}

COMMAND="${1:-}"

case "${COMMAND}" in
  bootstrap)
    bootstrap
    ;;
  build)
    build
    ;;
  status)
    status_cmd
    ;;
  *)
    usage
    exit 1
    ;;
esac
