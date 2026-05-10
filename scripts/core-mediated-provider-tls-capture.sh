#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

PROVIDER=""
AUTH_NAME=""
HOST=""
PORT="443"
CAPTURE_ENDPOINT="provider"
CAPTURE_HOST=""
CAPTURE_PORT=""
SANITIZE_PROXY_CONNECT=1
METHOD="HEAD"
PATH_VALUE="/"
MANAGEMENT_URL=""
OUT_DIR=""
IFACE=""
DURATION="20"
TRIGGER=0
EXECUTE=0
INSECURE=0
CORRELATION_ID=""

usage() {
  cat <<'USAGE'
Usage:
  scripts/core-mediated-provider-tls-capture.sh --provider <claude|codex> --auth-name <name> [options]

Purpose:
  Run a narrowly scoped sudo tcpdump capture while CLIProxyAPIPlus core triggers
  a no-Authorization provider TLS diagnostic probe. This is core-mediated:
  the outbound TLS flow is initiated by the running core, not by openssl/curl.

Required:
  --provider PROVIDER       claude or codex.
  --auth-name NAME          Auth file display name or auth ID known by core.

Options:
  --management-url URL      Core base URL, e.g. https://10.1.1.201:18317.
  --trigger                 Trigger the management diagnostic endpoint from this script.
                            Requires MANAGEMENT_PASSWORD in the environment.
  --host HOST               Override target host only if it matches provider default.
                            claude => api.anthropic.com; codex => chatgpt.com.
  --capture-endpoint KIND   provider, proxy, or runtime-egress (default: provider).
                            Use proxy when the core runtime uses an HTTP proxy and
                            provider-host pcap would otherwise be empty.
                            Use runtime-egress to capture both provider:443 and
                            proxy host:port in one attempt.
  --capture-host HOST       Proxy host/IP to capture when --capture-endpoint proxy
                            or runtime-egress.
  --capture-port PORT       Proxy port to capture when --capture-endpoint proxy
                            or runtime-egress.
  --no-sanitize-proxy       Keep raw proxy pcap packets. Not recommended when the
                            proxy URL contains credentials.
  --method METHOD           HEAD or GET for the diagnostic probe (default: HEAD).
  --path PATH               Harmless relative path for probe (default: /).
  --out-dir DIR             Capture output directory.
  --interface IFACE         tcpdump interface; defaults to default-route interface.
  --duration SEC            Capture window when --trigger is not used (default: 20).
  --correlation-id ID       Optional correlation ID; generated if omitted.
  --insecure                Pass -k to curl when triggering an HTTPS management URL.
  --execute                 Actually run tcpdump and optional endpoint trigger.
  --dry-run                 Print plan only. This is the default.
  -h, --help                Show this help.

Examples:
  # Dry-run the remote capture plan.
  scripts/core-mediated-provider-tls-capture.sh \
    --provider codex \
    --auth-name codex-a02.json \
    --management-url https://10.1.1.201:18317 \
    --trigger \
    --dry-run

  # Human/operator run on the remote core host in an approved window.
  sudo MANAGEMENT_PASSWORD='<not printed>' scripts/core-mediated-provider-tls-capture.sh \
    --provider claude \
    --auth-name claude.json \
    --management-url https://10.1.1.201:18317 \
    --trigger \
    --insecure \
    --execute

Safety boundary:
  - This script never reads auth files and never prints or saves MANAGEMENT_PASSWORD.
  - The core diagnostic endpoint must send no Authorization/Bearer/provider auth header.
  - tcpdump is scoped to provider host:443 or an explicitly supplied proxy endpoint.
  - proxy captures are sanitized by default to remove packets containing proxy auth.
  - Use only on machines/networks/accounts the operator is authorized to inspect.
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
    --provider)
      PROVIDER="${2:-}"
      shift 2
      ;;
    --auth-name|--auth_name)
      AUTH_NAME="${2:-}"
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
    --capture-endpoint|--capture_endpoint)
      CAPTURE_ENDPOINT="${2:-}"
      shift 2
      ;;
    --capture-host|--capture_host)
      CAPTURE_HOST="${2:-}"
      shift 2
      ;;
    --capture-port|--capture_port)
      CAPTURE_PORT="${2:-}"
      shift 2
      ;;
    --no-sanitize-proxy|--no_sanitize_proxy)
      SANITIZE_PROXY_CONNECT=0
      shift
      ;;
    --method)
      METHOD="${2:-}"
      shift 2
      ;;
    --path)
      PATH_VALUE="${2:-}"
      shift 2
      ;;
    --management-url|--management_url)
      MANAGEMENT_URL="${2:-}"
      shift 2
      ;;
    --out-dir|--out_dir)
      OUT_DIR="${2:-}"
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
    --correlation-id|--correlation_id)
      CORRELATION_ID="${2:-}"
      shift 2
      ;;
    --trigger)
      TRIGGER=1
      shift
      ;;
    --insecure)
      INSECURE=1
      shift
      ;;
    --execute|--run)
      EXECUTE=1
      shift
      ;;
    --dry-run)
      EXECUTE=0
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

PROVIDER="$(printf '%s' "${PROVIDER}" | tr '[:upper:]' '[:lower:]' | xargs)"
AUTH_NAME="$(printf '%s' "${AUTH_NAME}" | xargs)"
METHOD="$(printf '%s' "${METHOD}" | tr '[:lower:]' '[:upper:]' | xargs)"
HOST="$(printf '%s' "${HOST}" | tr '[:upper:]' '[:lower:]' | xargs)"
CAPTURE_ENDPOINT="$(printf '%s' "${CAPTURE_ENDPOINT}" | tr '[:upper:]' '[:lower:]' | xargs)"
CAPTURE_HOST="$(printf '%s' "${CAPTURE_HOST}" | tr '[:upper:]' '[:lower:]' | xargs)"

[[ -n "${PROVIDER}" ]] || die "--provider is required"
[[ -n "${AUTH_NAME}" ]] || die "--auth-name is required"
[[ "${PORT}" =~ ^[0-9]+$ ]] || die "--port must be numeric"
[[ "${CAPTURE_ENDPOINT}" == "provider" || "${CAPTURE_ENDPOINT}" == "proxy" || "${CAPTURE_ENDPOINT}" == "runtime-egress" ]] || die "--capture-endpoint must be provider, proxy, or runtime-egress"
[[ "${DURATION}" =~ ^[0-9]+$ ]] || die "--duration must be numeric seconds"
[[ "${METHOD}" == "HEAD" || "${METHOD}" == "GET" ]] || die "--method must be HEAD or GET"
[[ "${PATH_VALUE}" == /* && "${PATH_VALUE}" != *"://"* && "${PATH_VALUE}" != *$'\n'* && "${PATH_VALUE}" != *$'\r'* ]] || die "--path must be a relative absolute path like /"

case "${PROVIDER}" in
  claude)
    DEFAULT_HOST="api.anthropic.com"
    ;;
  codex)
    DEFAULT_HOST="chatgpt.com"
    ;;
  *)
    die "--provider must be claude or codex"
    ;;
esac

if [[ -z "${HOST}" ]]; then
  HOST="${DEFAULT_HOST}"
fi
[[ "${HOST}" == "${DEFAULT_HOST}" ]] || die "--host must match ${PROVIDER} default ${DEFAULT_HOST}"
[[ "${HOST}" != *"://"* && "${HOST}" != *"/"* && "${HOST}" != *"@"* ]] || die "--host must be a hostname only"
[[ "${HOST}" =~ ^[A-Za-z0-9.-]+$ ]] || die "--host contains unsupported characters"

if [[ "${CAPTURE_ENDPOINT}" == "proxy" || "${CAPTURE_ENDPOINT}" == "runtime-egress" ]]; then
  [[ -n "${CAPTURE_HOST}" ]] || die "--capture-host is required with --capture-endpoint ${CAPTURE_ENDPOINT}"
  [[ "${CAPTURE_HOST}" != *"://"* && "${CAPTURE_HOST}" != *"/"* && "${CAPTURE_HOST}" != *"@"* ]] || die "--capture-host must be a hostname or IP only"
  [[ "${CAPTURE_HOST}" =~ ^[A-Za-z0-9.:-]+$ ]] || die "--capture-host contains unsupported characters"
  if [[ -z "${CAPTURE_PORT}" ]]; then
    die "--capture-port is required with --capture-endpoint ${CAPTURE_ENDPOINT}"
  fi
  [[ "${CAPTURE_PORT}" =~ ^[0-9]+$ ]] || die "--capture-port must be numeric"
else
  CAPTURE_HOST="${HOST}"
  CAPTURE_PORT="${PORT}"
fi

if [[ -z "${CORRELATION_ID}" ]]; then
  CORRELATION_ID="core-provider-tls-$(date -u +%Y%m%dT%H%M%SZ)-$RANDOM"
fi

if [[ -z "${OUT_DIR}" ]]; then
  OUT_DIR="build/provider-observed-tls/core-mediated/${CORRELATION_ID}"
fi

detect_interface() {
  if [[ -n "${IFACE}" ]]; then
    printf '%s\n' "${IFACE}"
    return 0
  fi
  if command -v ip >/dev/null 2>&1; then
    local linux_iface
    linux_iface="$(ip route show default 2>/dev/null | awk '{print $5; exit}')"
    if [[ -n "${linux_iface}" ]]; then
      printf '%s\n' "${linux_iface}"
      return 0
    fi
  fi
  if command -v route >/dev/null 2>&1; then
    local mac_iface
    mac_iface="$(route get default 2>/dev/null | awk '/interface:/{print $2; exit}')"
    if [[ -n "${mac_iface}" ]]; then
      printf '%s\n' "${mac_iface}"
      return 0
    fi
  fi
  printf 'any\n'
}

resolve_host_ips() {
  local host="$1"
  python3 - "$host" <<'PY'
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

sha256_file() {
  local path="$1"
  if [[ ! -f "${path}" ]]; then
    printf ''
    return 0
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${path}" | awk '{print $1}'
  else
    shasum -a 256 "${path}" | awk '{print $1}'
  fi
}

pcap_packet_count() {
  local path="$1"
  python3 - "$path" <<'PY'
import struct
import sys

path = sys.argv[1]
try:
    data = open(path, "rb").read()
except FileNotFoundError:
    print(0)
    raise SystemExit(0)
if len(data) < 24:
    print(0)
    raise SystemExit(0)
magic = data[:4]
if magic in (b"\xd4\xc3\xb2\xa1", b"\x4d\x3c\xb2\xa1"):
    endian = "<"
elif magic in (b"\xa1\xb2\xc3\xd4", b"\xa1\xb2\x3c\x4d"):
    endian = ">"
else:
    print(0)
    raise SystemExit(0)
offset = 24
count = 0
while offset + 16 <= len(data):
    _, _, incl_len, _ = struct.unpack(endian + "IIII", data[offset:offset + 16])
    offset += 16
    if offset + incl_len > len(data):
        break
    offset += incl_len
    count += 1
print(count)
PY
}

sanitize_proxy_pcap() {
  local input_path="$1"
  local output_path="$2"
  local stats_path="$3"
  local marker_path="${PCAP_SANITIZE_MARKERS_FILE:-}"
  python3 - "$input_path" "$output_path" "$stats_path" "$marker_path" <<'PY'
import json
import struct
import sys

input_path, output_path, stats_path, marker_path = sys.argv[1:5]
data = open(input_path, "rb").read()
stats = {
    "sanitized": True,
    "input_packets": 0,
    "output_packets": 0,
    "removed_packets": 0,
    "removed_packets_by_builtin_markers": 0,
    "removed_packets_by_external_markers": 0,
    "external_marker_count": 0,
    "reason": "removed packets containing proxy/auth token markers",
}
if len(data) < 24:
    open(output_path, "wb").write(data)
    open(stats_path, "w", encoding="utf-8").write(json.dumps(stats, indent=2) + "\n")
    raise SystemExit(0)

magic = data[:4]
if magic in (b"\xd4\xc3\xb2\xa1", b"\x4d\x3c\xb2\xa1"):
    endian = "<"
elif magic in (b"\xa1\xb2\xc3\xd4", b"\xa1\xb2\x3c\x4d"):
    endian = ">"
else:
    open(output_path, "wb").write(data)
    stats["sanitized"] = False
    stats["reason"] = "unsupported pcap magic; copied input unchanged"
    open(stats_path, "w", encoding="utf-8").write(json.dumps(stats, indent=2) + "\n")
    raise SystemExit(0)

markers = [
    b"proxy-authorization",
    b"authorization:",
    b"bearer ",
    b"access_token",
    b"access-token",
    b"refresh_token",
    b"refresh-token",
]
external_markers = []
if marker_path:
    try:
        with open(marker_path, "rb") as marker_file:
            for raw_line in marker_file:
                marker = raw_line.strip()
                if len(marker) >= 3:
                    external_markers.append(marker.lower())
    except FileNotFoundError:
        external_markers = []
stats["external_marker_count"] = len(external_markers)
out = bytearray(data[:24])
offset = 24
while offset + 16 <= len(data):
    header = data[offset:offset + 16]
    _, _, incl_len, _ = struct.unpack(endian + "IIII", header)
    offset += 16
    packet = data[offset:offset + incl_len]
    if len(packet) != incl_len:
        break
    offset += incl_len
    stats["input_packets"] += 1
    lowered = packet.lower()
    if any(marker in lowered for marker in markers):
        stats["removed_packets"] += 1
        stats["removed_packets_by_builtin_markers"] += 1
        continue
    if external_markers and any(marker in lowered for marker in external_markers):
        stats["removed_packets"] += 1
        stats["removed_packets_by_external_markers"] += 1
        continue
    out.extend(header)
    out.extend(packet)
    stats["output_packets"] += 1

open(output_path, "wb").write(out)
open(stats_path, "w", encoding="utf-8").write(json.dumps(stats, indent=2) + "\n")
PY
}

HOST_IPS=()
while IFS= read -r resolved_ip; do
  [[ -n "${resolved_ip}" ]] && HOST_IPS+=("${resolved_ip}")
done < <(resolve_host_ips "${HOST}")
[[ "${#HOST_IPS[@]}" -gt 0 ]] || die "could not resolve ${HOST}"

CAPTURE_IPS=()
while IFS= read -r resolved_ip; do
  [[ -n "${resolved_ip}" ]] && CAPTURE_IPS+=("${resolved_ip}")
done < <(resolve_host_ips "${CAPTURE_HOST}")
[[ "${#CAPTURE_IPS[@]}" -gt 0 ]] || die "could not resolve capture host ${CAPTURE_HOST}"

PROVIDER_FILTER_PARTS=()
for ip in "${HOST_IPS[@]}"; do
  PROVIDER_FILTER_PARTS+=("host ${ip}")
done
PROVIDER_HOST_FILTER="$(printf ' or %s' "${PROVIDER_FILTER_PARTS[@]}")"
PROVIDER_HOST_FILTER="${PROVIDER_HOST_FILTER# or }"

CAPTURE_FILTER_PARTS=()
for ip in "${CAPTURE_IPS[@]}"; do
  CAPTURE_FILTER_PARTS+=("host ${ip}")
done
CAPTURE_HOST_FILTER="$(printf ' or %s' "${CAPTURE_FILTER_PARTS[@]}")"
CAPTURE_HOST_FILTER="${CAPTURE_HOST_FILTER# or }"

case "${CAPTURE_ENDPOINT}" in
  provider)
    TCPDUMP_FILTER="tcp port ${PORT} and (${PROVIDER_HOST_FILTER})"
    ;;
  proxy)
    TCPDUMP_FILTER="tcp port ${CAPTURE_PORT} and (${CAPTURE_HOST_FILTER})"
    ;;
  runtime-egress)
    TCPDUMP_FILTER="(tcp port ${PORT} and (${PROVIDER_HOST_FILTER})) or (tcp port ${CAPTURE_PORT} and (${CAPTURE_HOST_FILTER}))"
    ;;
esac
CAPTURE_IFACE="$(detect_interface)"

PCAP_PATH="${OUT_DIR}/${PROVIDER}-${CAPTURE_ENDPOINT}-${CAPTURE_HOST}-${CORRELATION_ID}.pcap"
RAW_PCAP_PATH="${PCAP_PATH}"
SANITIZE_STATS_PATH="${OUT_DIR}/pcap-sanitize.json"
if [[ "${CAPTURE_ENDPOINT}" != "provider" && "${SANITIZE_PROXY_CONNECT}" == "1" ]]; then
  RAW_PCAP_PATH="${PCAP_PATH}.raw"
fi
MANIFEST_PATH="${OUT_DIR}/manifest.json"
REQUEST_PATH="${OUT_DIR}/probe-request.json"
RESPONSE_PATH="${OUT_DIR}/probe-response.json"
TCPDUMP_LOG="${OUT_DIR}/tcpdump.log"
SCAN_PATH="${OUT_DIR}/token-scan.txt"

TCPDUMP_CMD=("${TCPDUMP_BIN:-tcpdump}" "-i" "${CAPTURE_IFACE}" "-nn" "-s" "0" "-w" "${RAW_PCAP_PATH}" "${TCPDUMP_FILTER}")
ENDPOINT="${MANAGEMENT_URL%/}/v0/management/diagnostics/provider-tls-probe"

info "provider: ${PROVIDER}"
info "auth name: ${AUTH_NAME}"
info "target host: ${HOST}"
info "resolved IPs: ${HOST_IPS[*]}"
info "capture endpoint: ${CAPTURE_ENDPOINT}"
info "capture host: ${CAPTURE_HOST}"
info "capture port: ${CAPTURE_PORT}"
info "capture resolved IPs: ${CAPTURE_IPS[*]}"
if [[ "${CAPTURE_ENDPOINT}" != "provider" && "${SANITIZE_PROXY_CONNECT}" == "1" ]]; then
  info "proxy pcap sanitization: enabled"
fi
info "interface: ${CAPTURE_IFACE}"
info "out dir: ${OUT_DIR}"
info "correlation id: ${CORRELATION_ID}"
info "tcpdump command:"
join_command "${TCPDUMP_CMD[@]}"

if [[ "${TRIGGER}" == "1" ]]; then
  [[ -n "${MANAGEMENT_URL}" ]] || die "--management-url is required with --trigger"
  info "core diagnostic endpoint: ${ENDPOINT}"
  info "curl trigger uses MANAGEMENT_PASSWORD from env via stdin config; password is not printed or saved"
else
  info "trigger: manual. Start local/AI endpoint trigger during the capture window."
fi

if [[ "${EXECUTE}" != "1" ]]; then
  info "dry-run only; pass --execute under sudo/root to capture."
  if [[ "${TRIGGER}" == "1" ]]; then
    info "dry-run curl shape:"
    printf 'printf %s "header = \\"Authorization: Bearer <MANAGEMENT_PASSWORD>\\"" | '
    curl_preview=("curl" "-K" "-" "-sS" "-X" "POST" "${ENDPOINT}" "-H" "Content-Type: application/json" "--data-binary" "@${REQUEST_PATH}")
    if [[ "${INSECURE}" == "1" ]]; then
      curl_preview+=("-k")
    fi
    join_command "${curl_preview[@]}"
  fi
  exit 0
fi

if [[ "$(id -u)" != "0" ]]; then
  die "tcpdump capture requires sudo/root. Re-run with sudo, or use --dry-run to inspect the plan."
fi
if [[ "${TRIGGER}" == "1" && -z "${MANAGEMENT_PASSWORD:-}" ]]; then
  die "MANAGEMENT_PASSWORD environment variable is required with --trigger"
fi
command -v "${TCPDUMP_BIN:-tcpdump}" >/dev/null 2>&1 || die "tcpdump not found"
command -v curl >/dev/null 2>&1 || die "curl not found"

mkdir -p "${OUT_DIR}"

python3 - "$REQUEST_PATH" "$AUTH_NAME" "$PROVIDER" "$HOST" "$METHOD" "$PATH_VALUE" "$CORRELATION_ID" <<'PY'
import json
import sys

path, auth_name, provider, host, method, probe_path, correlation_id = sys.argv[1:]
payload = {
    "name": auth_name,
    "provider": provider,
    "target_host": host,
    "method": method,
    "path": probe_path,
    "correlation_id": correlation_id,
}
with open(path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY

START_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
info "starting tcpdump capture"
"${TCPDUMP_CMD[@]}" >"${TCPDUMP_LOG}" 2>&1 &
TCPDUMP_PID=$!

cleanup() {
  if kill -0 "${TCPDUMP_PID}" >/dev/null 2>&1; then
    kill -INT "${TCPDUMP_PID}" >/dev/null 2>&1 || true
    wait "${TCPDUMP_PID}" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

sleep 1

if [[ "${TRIGGER}" == "1" ]]; then
  info "triggering core diagnostic endpoint"
  curl_args=("-sS" "-X" "POST" "${ENDPOINT}" "-H" "Content-Type: application/json" "--data-binary" "@${REQUEST_PATH}")
  if [[ "${INSECURE}" == "1" ]]; then
    curl_args+=("-k")
  fi
  {
    printf 'header = "Authorization: Bearer %s"\n' "${MANAGEMENT_PASSWORD}"
  } | curl -K - "${curl_args[@]}" >"${RESPONSE_PATH}"
  info "probe response saved: ${RESPONSE_PATH}"
  sleep 3
else
  info "capture active for ${DURATION}s; trigger the core diagnostic endpoint from another terminal now"
  sleep "${DURATION}"
fi

cleanup
trap - EXIT
END_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

PCAP_SANITIZED=false
SANITIZED_REMOVED_PACKETS=0
SANITIZED_INPUT_PACKETS=0
SANITIZED_OUTPUT_PACKETS=0
if [[ "${CAPTURE_ENDPOINT}" != "provider" && "${SANITIZE_PROXY_CONNECT}" == "1" ]]; then
  sanitize_proxy_pcap "${RAW_PCAP_PATH}" "${PCAP_PATH}" "${SANITIZE_STATS_PATH}"
  rm -f "${RAW_PCAP_PATH}"
  PCAP_SANITIZED=true
  SANITIZED_REMOVED_PACKETS="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("removed_packets", 0))' "${SANITIZE_STATS_PATH}")"
  SANITIZED_INPUT_PACKETS="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("input_packets", 0))' "${SANITIZE_STATS_PATH}")"
  SANITIZED_OUTPUT_PACKETS="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("output_packets", 0))' "${SANITIZE_STATS_PATH}")"
fi

PCAP_SHA="$(sha256_file "${PCAP_PATH}")"
RESPONSE_SHA="$(sha256_file "${RESPONSE_PATH}")"
PCAP_PACKET_COUNT="$(pcap_packet_count "${PCAP_PATH}")"

TOKEN_SCAN_STATUS="clean"
{
  for candidate in "${REQUEST_PATH}" "${RESPONSE_PATH}" "${TCPDUMP_LOG}"; do
    [[ -f "${candidate}" ]] || continue
    if grep -Eai '(access[_-]?token|refresh[_-]?token|bearer[[:space:]]+[A-Za-z0-9._~+/-]{16,}|authorization:[[:space:]]*(bearer|basic)|proxy-authorization|sk-[A-Za-z0-9]{20,})' "${candidate}"; then
      TOKEN_SCAN_STATUS="found"
    fi
  done
  if [[ -f "${PCAP_PATH}" ]] && command -v strings >/dev/null 2>&1; then
    if strings "${PCAP_PATH}" | grep -Eai '(access[_-]?token|refresh[_-]?token|bearer[[:space:]]+[A-Za-z0-9._~+/-]{16,}|authorization:[[:space:]]*(bearer|basic)|proxy-authorization|sk-[A-Za-z0-9]{20,})'; then
      TOKEN_SCAN_STATUS="found"
    fi
    if [[ -n "${PCAP_SANITIZE_MARKERS_FILE:-}" && -f "${PCAP_SANITIZE_MARKERS_FILE}" ]]; then
      while IFS= read -r marker; do
        [[ "${#marker}" -ge 3 ]] || continue
        if strings "${PCAP_PATH}" | grep -Fq -- "${marker}"; then
          printf '<external sanitize marker found in pcap>\n'
          TOKEN_SCAN_STATUS="found"
          break
        fi
      done <"${PCAP_SANITIZE_MARKERS_FILE}"
    fi
  fi
} >"${SCAN_PATH}" || true

python3 - "$MANIFEST_PATH" "$PROVIDER" "$AUTH_NAME" "$HOST" "$PORT" "$CAPTURE_ENDPOINT" "$CAPTURE_HOST" "$CAPTURE_PORT" "$METHOD" "$PATH_VALUE" "$CORRELATION_ID" "$START_TS" "$END_TS" "$CAPTURE_IFACE" "$PCAP_PATH" "$PCAP_SHA" "$PCAP_PACKET_COUNT" "$PCAP_SANITIZED" "$SANITIZED_INPUT_PACKETS" "$SANITIZED_OUTPUT_PACKETS" "$SANITIZED_REMOVED_PACKETS" "$SANITIZE_STATS_PATH" "$REQUEST_PATH" "$RESPONSE_PATH" "$RESPONSE_SHA" "$SCAN_PATH" "$TOKEN_SCAN_STATUS" -- "${HOST_IPS[@]}" -- "${CAPTURE_IPS[@]}" <<'PY'
import hashlib
import json
import sys

args = sys.argv[1:]
first_sep = args.index("--")
second_sep = args.index("--", first_sep + 1)
fixed = args[:first_sep]
ips = args[first_sep + 1:second_sep]
capture_ips = args[second_sep + 1:]

(
    manifest_path,
    provider,
    auth_name,
    host,
    port,
    capture_endpoint,
    capture_host,
    capture_port,
    method,
    probe_path,
    correlation_id,
    start_ts,
    end_ts,
    iface,
    pcap_path,
    pcap_sha,
    pcap_packet_count,
    pcap_sanitized,
    sanitized_input_packets,
    sanitized_output_packets,
    sanitized_removed_packets,
    sanitize_stats_path,
    request_path,
    response_path,
    response_sha,
    scan_path,
    token_scan_status,
) = fixed

auth_name_hash = "sha256:" + hashlib.sha256(auth_name.encode("utf-8")).hexdigest()
pcap_sanitized_bool = pcap_sanitized.lower() == "true"
manifest = {
    "evidence_type": "core-mediated-provider-tls-pcap",
    "claim_scope": "core-outbound-tls-handshake-not-authenticated-provider-request",
    "provider": provider,
    "account_name_hash": auth_name_hash,
    "target_host": host,
    "target_port": int(port),
    "resolved_ips": ips,
    "capture_endpoint": capture_endpoint,
    "capture_host": capture_host,
    "capture_port": int(capture_port),
    "capture_resolved_ips": capture_ips,
    "proxy_tunnel_expected": capture_endpoint in ("proxy", "runtime-egress"),
    "method": method,
    "path": probe_path,
    "correlation_id": correlation_id,
    "timestamp_window": {"start": start_ts, "end": end_ts},
    "interface": iface,
    "pcap_path": pcap_path,
    "pcap_sha256": pcap_sha,
    "pcap_packet_count": int(pcap_packet_count),
    "pcap_sanitized": pcap_sanitized_bool,
    "pcap_sanitize_path": sanitize_stats_path if pcap_sanitized_bool else None,
    "pcap_sanitization": {
        "input_packets": int(sanitized_input_packets),
        "output_packets": int(sanitized_output_packets),
        "removed_packets": int(sanitized_removed_packets),
    } if pcap_sanitized_bool else None,
    "probe_request_path": request_path,
    "probe_response_path": response_path if response_sha else None,
    "probe_response_sha256": response_sha or None,
    "authorization_sent": False,
    "management_password_saved": False,
    "token_scan_status": token_scan_status,
    "token_scan_path": scan_path,
    "limitations": [
        "pcap proves a core-triggered provider-host or proxy-tunnel TLS flow only when correlated with the diagnostic response correlation_id",
        "the diagnostic probe intentionally sends no Authorization header and is not a full authenticated provider request",
        "normal pcap cannot reveal encrypted HTTP/2 SETTINGS",
        "proxy endpoint captures may require sanitized pcap because HTTP proxy authentication can be visible before CONNECT",
    ],
}
with open(manifest_path, "w", encoding="utf-8") as handle:
    json.dump(manifest, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY

info "wrote pcap: ${PCAP_PATH}"
info "wrote manifest: ${MANIFEST_PATH}"
info "wrote token scan: ${SCAN_PATH} (${TOKEN_SCAN_STATUS})"
if [[ "${TOKEN_SCAN_STATUS}" != "clean" ]]; then
  die "token-like markers found; inspect ${SCAN_PATH} before sharing artifacts"
fi
