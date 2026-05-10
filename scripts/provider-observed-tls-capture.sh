#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

MODE="pcap-handshake"
HOST=""
PORT="443"
OUT_PATH=""
IFACE=""
DURATION="8"
ALPN="h2,http/1.1"
RUN_CAPTURE=0

usage() {
  cat <<'USAGE'
Usage:
  scripts/provider-observed-tls-capture.sh --host <provider-host> --out <capture.pcap> [options]

Purpose:
  Prepare or run a narrowly-scoped provider-host TLS evidence capture.
  The script never reads auth files, never reads tokens, and never sends
  Authorization headers. It defaults to dry-run and requires explicit --run
  before starting tcpdump or opening a TLS connection.

Modes:
  pcap-handshake  Capture tcpdump while this script performs TLS handshake only.
                  No HTTP request is sent after the TLS handshake.
  pcap-watch      Capture tcpdump for --duration only. Operator triggers any
                  separate harmless/no-token flow in another terminal.
  mitm-plan       Write a mitmproxy/trusted-CA evidence plan instead of capture.

Required:
  --host HOST     Provider hostname only, e.g. api.anthropic.com or chatgpt.com.
                  Do not pass a URL, path, token, account name, or auth header.
  --out PATH      Output pcap path for pcap modes, or markdown path for mitm-plan.

Options:
  --mode MODE         pcap-handshake | pcap-watch | mitm-plan (default: pcap-handshake)
  --port PORT         TCP port (default: 443)
  --interface IFACE   tcpdump interface. Defaults to default-route interface when detectable.
  --duration SEC      Capture window for pcap modes (default: 8)
  --alpn LIST         ALPN list for pcap-handshake openssl probe (default: h2,http/1.1)
  --run              Actually run tcpdump / write files. Without this, dry-run only.
  --dry-run          Force dry-run output.
  -h, --help         Show this help.

Examples:
  # Safe dry-run: prints the exact tcpdump and handshake commands.
  scripts/provider-observed-tls-capture.sh \
    --host api.anthropic.com \
    --out build/provider-observed-tls/anthropic-handshake.pcap

  # Handshake-only capture. Usually requires sudo for tcpdump.
  sudo scripts/provider-observed-tls-capture.sh \
    --host api.anthropic.com \
    --out build/provider-observed-tls/anthropic-handshake.pcap \
    --run

  # Watch mode: capture only; operator separately triggers a harmless no-token flow.
  sudo scripts/provider-observed-tls-capture.sh \
    --mode pcap-watch \
    --host chatgpt.com \
    --out build/provider-observed-tls/chatgpt-watch.pcap \
    --duration 15 \
    --run

Evidence boundary:
  - pcap-handshake proves only a provider-host TLS handshake with no Authorization.
  - pcap-watch can support provider-observed evidence only if the operator
    separately documents the no-token runtime flow correlated to the pcap time.
  - tcpdump pcap cannot reveal encrypted HTTP/2 SETTINGS on normal TLS 1.3.
    Use trusted MITM, provider echo, provider-side logs, or a core debug hook
    when HTTP/2 SETTINGS must be observed.
USAGE
}

die() {
  echo "error: $*" >&2
  exit 1
}

info() {
  printf '[info] %s\n' "$*"
}

shell_quote() {
  printf '%q' "$1"
}

join_command() {
  local first=1
  for arg in "$@"; do
    if [[ "${first}" == "1" ]]; then
      first=0
    else
      printf ' '
    fi
    shell_quote "${arg}"
  done
  printf '\n'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --host)
      HOST="${2:-}"
      shift 2
      ;;
    --port)
      PORT="${2:-}"
      shift 2
      ;;
    --out)
      OUT_PATH="${2:-}"
      shift 2
      ;;
    --interface)
      IFACE="${2:-}"
      shift 2
      ;;
    --duration)
      DURATION="${2:-}"
      shift 2
      ;;
    --alpn)
      ALPN="${2:-}"
      shift 2
      ;;
    --run)
      RUN_CAPTURE=1
      shift
      ;;
    --dry-run)
      RUN_CAPTURE=0
      shift
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

case "${MODE}" in
  pcap-handshake|pcap-watch|mitm-plan) ;;
  *) die "--mode must be pcap-handshake, pcap-watch, or mitm-plan" ;;
esac

[[ -n "${HOST}" ]] || die "--host is required"
[[ -n "${OUT_PATH}" ]] || die "--out is required"
[[ "${HOST}" != *"://"* && "${HOST}" != *"/"* && "${HOST}" != *"@"* ]] || {
  die "--host must be a hostname only; do not pass URLs, paths, usernames, or tokens"
}
[[ "${HOST}" =~ ^[A-Za-z0-9.-]+$ ]] || die "--host contains unsupported characters"
[[ "${PORT}" =~ ^[0-9]+$ ]] || die "--port must be numeric"
[[ "${DURATION}" =~ ^[0-9]+$ ]] || die "--duration must be numeric seconds"

detect_interface() {
  if [[ -n "${IFACE}" ]]; then
    printf '%s\n' "${IFACE}"
    return 0
  fi
  if command -v route >/dev/null 2>&1; then
    local mac_iface
    mac_iface="$(route get default 2>/dev/null | awk '/interface:/{print $2; exit}')"
    if [[ -n "${mac_iface}" ]]; then
      printf '%s\n' "${mac_iface}"
      return 0
    fi
  fi
  if command -v ip >/dev/null 2>&1; then
    local linux_iface
    linux_iface="$(ip route show default 2>/dev/null | awk '{print $5; exit}')"
    if [[ -n "${linux_iface}" ]]; then
      printf '%s\n' "${linux_iface}"
      return 0
    fi
  fi
  printf 'any\n'
}

resolve_host_ips() {
  python3 - "$HOST" <<'PY'
import socket
import sys

host = sys.argv[1]
seen = []
try:
    infos = socket.getaddrinfo(host, None, proto=socket.IPPROTO_TCP)
except socket.gaierror as exc:
    print(f"resolve_error={exc}", file=sys.stderr)
    sys.exit(2)

for info in infos:
    addr = info[4][0]
    if addr not in seen:
        seen.append(addr)

for addr in seen:
    print(addr)
PY
}

write_mitm_plan() {
  mkdir -p "$(dirname "${OUT_PATH}")"
  cat >"${OUT_PATH}" <<EOF
# Provider-observed TLS MITM evidence plan

- Host: \`${HOST}\`
- Port: \`${PORT}\`
- Generated by: \`${SCRIPT_NAME} --mode mitm-plan\`
- Token boundary: do not read, print, paste, or forward Authorization / refresh tokens.

## Preconditions

1. Use an isolated dev runtime only; do not point production Quotio or production CLIProxyAPIPlus at the MITM proxy.
2. Install and trust a test-only mitmproxy CA for the isolated runtime process only.
3. Trigger only a no-Authorization TLS handshake or a harmless no-token endpoint. Do not send a valid provider request with production account credentials.
4. Record start/end timestamps, provider host, proxy port, runtime build/commit, and the exact command that generated traffic.

## Minimum evidence to collect

- mitmproxy flow export or equivalent trace, with request Authorization redacted or absent.
- Runtime stdout/log line proving the selected transport/profile and provider host for the same timestamp.
- If HTTP/2 SETTINGS parity is required, capture it from a TLS-terminating proxy, provider echo, provider-side log, or core debug hook; plain pcap alone cannot decrypt HTTP/2 SETTINGS.

## Claim boundary

- This plan can produce provider-observed evidence only after the isolated runtime is configured to route through the trusted MITM and the captured flow is correlated with runtime logs.
- A plain pcap or app-layer provider response alone must not be described as canonical provider-observed JA3/JA4 + HTTP2 SETTINGS.
EOF
  info "wrote MITM plan: ${OUT_PATH}"
}

if [[ "${MODE}" == "mitm-plan" ]]; then
  if [[ "${RUN_CAPTURE}" == "1" ]]; then
    write_mitm_plan
  else
    info "dry-run: would write MITM plan to ${OUT_PATH}"
  fi
  exit 0
fi

TCPDUMP_BIN="${TCPDUMP_BIN:-tcpdump}"
OPENSSL_BIN="${OPENSSL_BIN:-openssl}"
CAPTURE_IFACE="$(detect_interface)"

HOST_IPS=()
while IFS= read -r resolved_ip; do
  [[ -n "${resolved_ip}" ]] && HOST_IPS+=("${resolved_ip}")
done < <(resolve_host_ips)
[[ "${#HOST_IPS[@]}" -gt 0 ]] || die "could not resolve ${HOST}"

FILTER_PARTS=()
for ip in "${HOST_IPS[@]}"; do
  FILTER_PARTS+=("host ${ip}")
done
HOST_FILTER="$(printf ' or %s' "${FILTER_PARTS[@]}")"
HOST_FILTER="${HOST_FILTER# or }"
TCPDUMP_FILTER="tcp port ${PORT} and (${HOST_FILTER})"

TCPDUMP_CMD=("${TCPDUMP_BIN}" "-i" "${CAPTURE_IFACE}" "-nn" "-s" "0" "-w" "${OUT_PATH}" "${TCPDUMP_FILTER}")
OPENSSL_LOG="${OUT_PATH}.openssl.txt"
OPENSSL_CMD=("${OPENSSL_BIN}" "s_client" "-connect" "${HOST}:${PORT}" "-servername" "${HOST}" "-alpn" "${ALPN}" "-brief")

info "mode: ${MODE}"
info "host: ${HOST}"
info "resolved IPs: ${HOST_IPS[*]}"
info "interface: ${CAPTURE_IFACE}"
info "tcpdump command:"
join_command "${TCPDUMP_CMD[@]}"

if [[ "${MODE}" == "pcap-handshake" ]]; then
  info "handshake command:"
  printf "printf '' | "
  join_command "${OPENSSL_CMD[@]}"
fi

if [[ "${RUN_CAPTURE}" != "1" ]]; then
  info "dry-run only; pass --run to execute. tcpdump usually requires sudo/root."
  exit 0
fi

command -v "${TCPDUMP_BIN}" >/dev/null 2>&1 || die "tcpdump not found"
if [[ "${MODE}" == "pcap-handshake" ]]; then
  command -v "${OPENSSL_BIN}" >/dev/null 2>&1 || die "openssl not found"
fi
if [[ "$(id -u)" != "0" && "${TCPDUMP_ALLOW_UNPRIVILEGED:-0}" != "1" ]]; then
  die "tcpdump capture usually requires root. Re-run with sudo, or use --dry-run to print the exact command."
fi

mkdir -p "$(dirname "${OUT_PATH}")"

info "starting tcpdump capture"
"${TCPDUMP_CMD[@]}" &
TCPDUMP_PID=$!

cleanup() {
  if kill -0 "${TCPDUMP_PID}" >/dev/null 2>&1; then
    kill -INT "${TCPDUMP_PID}" >/dev/null 2>&1 || true
    wait "${TCPDUMP_PID}" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

sleep 1

if [[ "${MODE}" == "pcap-handshake" ]]; then
  info "running TLS handshake only; no HTTP request or Authorization header is sent"
  set +e
  printf '' | "${OPENSSL_CMD[@]}" >"${OPENSSL_LOG}" 2>&1
  OPENSSL_STATUS=$?
  set -e
  info "openssl exit status: ${OPENSSL_STATUS}; log: ${OPENSSL_LOG}"
  sleep 2
else
  info "pcap-watch active for ${DURATION}s; trigger only a harmless no-token flow if needed"
  sleep "${DURATION}"
fi

cleanup
trap - EXIT

SUMMARY_PATH="${OUT_PATH}.summary.json"
python3 - "$SUMMARY_PATH" "$MODE" "$HOST" "$PORT" "$OUT_PATH" "$OPENSSL_LOG" "$CAPTURE_IFACE" "${HOST_IPS[@]}" <<'PY'
import json
import sys
from datetime import datetime, timezone

summary_path, mode, host, port, pcap_path, openssl_log, iface, *ips = sys.argv[1:]
summary = {
    "evidence_type": "provider-host-handshake-pcap" if mode == "pcap-handshake" else "provider-host-pcap-watch",
    "provider_observed_claim": "limited: provider host can observe the TLS handshake, but this is not an authenticated account runtime request",
    "host": host,
    "port": int(port),
    "interface": iface,
    "resolved_ips": ips,
    "pcap_path": pcap_path,
    "openssl_log": openssl_log if mode == "pcap-handshake" else None,
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "token_boundary": "no auth files read; no Authorization header sent by this script",
    "limitations": [
        "pcap-handshake does not prove the Quotio/CLIProxyAPIPlus account runtime path",
        "tcpdump pcap cannot reveal encrypted HTTP/2 SETTINGS on normal TLS 1.3",
        "pcap-watch requires external timestamp/runtime-log correlation before claiming provider-observed evidence",
    ],
}
with open(summary_path, "w", encoding="utf-8") as handle:
    json.dump(summary, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY

info "wrote pcap: ${OUT_PATH}"
info "wrote summary: ${SUMMARY_PATH}"
