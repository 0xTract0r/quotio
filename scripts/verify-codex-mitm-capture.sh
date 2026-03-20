#!/bin/zsh

set -euo pipefail

CORE_PORT="${CORE_PORT:-28417}"
FLOW_FILE="${FLOW_FILE:-/tmp/quotio-mitm/openai-flows.jsonl}"
CONFIG_PATH="${CONFIG_PATH:-$HOME/Library/Application Support/Quotio-dev/config.yaml}"
MODEL="${MODEL:-gpt-5-codex}"
PROMPT="${PROMPT:-Reply with exactly: ping}"
TOKEN="${TOKEN:-}"
AUTH_DIR="${AUTH_DIR:-}"
CODEX_AUTH_FILE="${CODEX_AUTH_FILE:-}"
SKIP_TRIGGER="${SKIP_TRIGGER:-0}"

if [[ ! -f "$FLOW_FILE" ]]; then
  echo "MITM flow file not found: $FLOW_FILE" >&2
  echo "Start mitmdump first and point it at scripts/openai-mitm-capture.py." >&2
  exit 1
fi

if [[ -z "$AUTH_DIR" ]]; then
  AUTH_DIR="$(
    awk -F': ' '
      $1 == "auth-dir" {
        gsub(/"/, "", $2)
        print $2
        exit
      }
    ' "$CONFIG_PATH"
  )"
fi

EXPECTED_AUTH_PATH=""
if [[ -n "$CODEX_AUTH_FILE" ]]; then
  EXPECTED_AUTH_PATH="$(
    python3 - "$AUTH_DIR" "$CODEX_AUTH_FILE" <<'PY'
import sys
from pathlib import Path

auth_dir = Path(sys.argv[1]).expanduser()
requested = sys.argv[2].strip()
path = Path(requested).expanduser()
if not path.is_absolute():
    path = auth_dir / requested
print(path)
PY
  )"
  if [[ ! -f "$EXPECTED_AUTH_PATH" ]]; then
    echo "Expected auth file not found: $EXPECTED_AUTH_PATH" >&2
    exit 1
  fi
fi

response_file="$(mktemp -t quotio-codex-mitm-response)"

cleanup() {
  rm -f "$response_file"
}
trap cleanup EXIT

if [[ "$SKIP_TRIGGER" != "1" ]]; then
  if [[ -z "$TOKEN" ]]; then
    TOKEN="$(
      awk '
        /^api-keys:/ { in_keys=1; next }
        in_keys && $1 == "-" {
          gsub(/"/, "", $2)
          print $2
          exit
        }
        in_keys && $1 !~ /^-/ { exit }
      ' "$CONFIG_PATH"
    )"
  fi

  if [[ -z "$TOKEN" ]]; then
    echo "Cannot determine API token. Set TOKEN=... or ensure $CONFIG_PATH contains api-keys." >&2
    exit 1
  fi

  before_count="$(wc -l < "$FLOW_FILE" | tr -d ' ')"

  curl -sS -N "http://127.0.0.1:${CORE_PORT}/v1/responses" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"${MODEL}\",\"input\":\"${PROMPT}\",\"stream\":false}" \
    >"$response_file"

  after_count="$(wc -l < "$FLOW_FILE" | tr -d ' ')"
  if [[ "$after_count" -le "$before_count" ]]; then
    echo "No new MITM capture was written to $FLOW_FILE" >&2
    echo "Response preview:" >&2
    sed -n '1,40p' "$response_file" >&2
    exit 1
  fi
fi

python3 - "$FLOW_FILE" "$EXPECTED_AUTH_PATH" "$SKIP_TRIGGER" <<'PY'
import json
import sys
from datetime import datetime
from pathlib import Path

flow_path = Path(sys.argv[1])
expected_auth_path = Path(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] else None
skip_trigger = len(sys.argv) > 3 and sys.argv[3] == "1"
last_line = ""
with flow_path.open("r", encoding="utf-8") as fh:
    for line in fh:
        if line.strip():
            last_line = line

if not last_line:
    raise SystemExit("flow file is empty")

record = json.loads(last_line)
request = record["request"]
response = record["response"]
timestamp = record.get("timestamp", "")
headers = {str(key).lower(): value for key, value in request["headers"].items()}
response_headers = {str(key).lower(): value for key, value in response["headers"].items()}

expected_headers = {}
if expected_auth_path is not None and expected_auth_path.exists():
    expected_auth = json.loads(expected_auth_path.read_text(encoding="utf-8"))
    expected_headers = {
        str(key).lower(): value
        for key, value in (expected_auth.get("headers") or {}).items()
    }

def to_local_time(raw: str) -> str:
    if not raw:
        return ""
    try:
        return datetime.fromisoformat(raw).astimezone().strftime("%Y-%m-%d %H:%M:%S %z")
    except Exception:
        return raw

print("MITM captured upstream request:")
print(f"  Flow timestamp (UTC): {timestamp}")
print(f"  Flow timestamp (local): {to_local_time(timestamp)}")
print(f"  URL: {request['pretty_url']}")
print(f"  Request body prefix: {request.get('body_prefix', '')[:240].replace(chr(10), ' ')}")
for key in ["User-Agent", "Version"]:
    normalized_key = key.lower()
    actual = headers.get(normalized_key, "")
    print(f"  {key}: {actual}")
    if expected_headers:
        expected = expected_headers.get(normalized_key, "")
        marker = "MATCH" if actual == expected else "MISMATCH"
        print(f"    saved: {expected}")
        print(f"    check: {marker}")

print("MITM captured upstream response:")
print(f"  Status: {response.get('status_code')}")
print(f"  Content-Type: {response_headers.get('content-type', '')}")
print("Response body prefix (not full response):")
print(response.get("body_prefix", ""))
if skip_trigger:
    print()
    print("Note: SKIP_TRIGGER=1, this report compares the latest existing MITM flow only.")
PY

if [[ "$SKIP_TRIGGER" != "1" ]]; then
  echo
  echo "Direct core response preview:"
  sed -n '1,40p' "$response_file"
fi
