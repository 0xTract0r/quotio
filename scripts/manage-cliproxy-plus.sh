#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/router-for-me/CLIProxyAPIPlus.git}"
BASE_COMMIT="${BASE_COMMIT:-7c2ad4c}"
GO_TOOLCHAIN_MODE="${GO_TOOLCHAIN_MODE:-auto}"
VENDOR_DIR="${ROOT_DIR}/third_party/CLIProxyAPIPlus"
WORK_DIR="${VENDOR_DIR}/work"
SRC_DIR="${WORK_DIR}/src"
BIN_DIR="${WORK_DIR}/bin"
BIN_PATH="${BIN_DIR}/CLIProxyAPI"
PATCH_FILE="${VENDOR_DIR}/patches/0001-quotio-account-fingerprint.patch"

usage() {
  cat <<EOF
Usage:
  $0 bootstrap
  $0 build
  $0 refresh-patch
EOF
}

ensure_source_checkout() {
  mkdir -p "${WORK_DIR}"
  if [[ ! -d "${SRC_DIR}/.git" ]]; then
    git clone "${UPSTREAM_URL}" "${SRC_DIR}"
  fi
}

apply_patch_if_needed() {
  if git -C "${SRC_DIR}" apply --check "${PATCH_FILE}" >/dev/null 2>&1; then
    git -C "${SRC_DIR}" apply "${PATCH_FILE}"
    echo "Applied patch: ${PATCH_FILE}"
    return 0
  fi

  if git -C "${SRC_DIR}" apply --reverse --check "${PATCH_FILE}" >/dev/null 2>&1; then
    echo "Patch already applied: ${PATCH_FILE}"
    return 0
  fi

  echo "Patch state is not cleanly applicable or reversible: ${PATCH_FILE}" >&2
  exit 1
}

bootstrap() {
  ensure_source_checkout
  git -C "${SRC_DIR}" fetch origin
  git -C "${SRC_DIR}" checkout "${BASE_COMMIT}"
  apply_patch_if_needed
  echo "Source ready at: ${SRC_DIR}"
}

build() {
  bootstrap
  mkdir -p "${BIN_DIR}"
  (
    cd "${SRC_DIR}"
    GOTOOLCHAIN="${GO_TOOLCHAIN_MODE}" go build -o "${BIN_PATH}" ./cmd/server
  )
  echo "Built patched binary: ${BIN_PATH}"
}

refresh_patch() {
  ensure_source_checkout
  git -C "${SRC_DIR}" diff > "${PATCH_FILE}"
  echo "Refreshed patch file: ${PATCH_FILE}"
}

COMMAND="${1:-}"

case "${COMMAND}" in
  bootstrap)
    bootstrap
    ;;
  build)
    build
    ;;
  refresh-patch)
    refresh_patch
    ;;
  *)
    usage
    exit 1
    ;;
esac
