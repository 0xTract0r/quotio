#!/bin/zsh

set -euo pipefail

CORE_PORT="${CORE_PORT:-28417}"
FLOW_FILE="${FLOW_FILE:-/tmp/quotio-mitm/flows.jsonl}"
CONFIG_PATH="${CONFIG_PATH:-$HOME/Library/Application Support/Quotio-dev/config.yaml}"
MODEL="${MODEL:-claude-haiku-4-5-20251001}"
PROMPT="${PROMPT:-Reply with exactly: ping}"
TOKEN="${TOKEN:-}"

if [[ ! -f "$FLOW_FILE" ]]; then
  echo "MITM flow file not found: $FLOW_FILE" >&2
  echo "Start mitmdump first and point it at scripts/anthropic-mitm-capture.py." >&2
  exit 1
fi

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
response_file="$(mktemp -t quotio-claude-mitm-response)"

cleanup() {
  rm -f "$response_file"
}
trap cleanup EXIT

curl -sS -N "http://127.0.0.1:${CORE_PORT}/v1/messages?beta=true" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d "{\"model\":\"${MODEL}\",\"max_tokens\":16,\"stream\":true,\"messages\":[{\"role\":\"user\",\"content\":\"${PROMPT}\"}]}" \
  >"$response_file"

after_count="$(wc -l < "$FLOW_FILE" | tr -d ' ')"
if [[ "$after_count" -le "$before_count" ]]; then
  echo "No new MITM capture was written to $FLOW_FILE" >&2
  echo "Response preview:" >&2
  sed -n '1,20p' "$response_file" >&2
  exit 1
fi

python3 - "$FLOW_FILE" <<'PY'
import json
import sys
from pathlib import Path

flow_path = Path(sys.argv[1])
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
headers = request["headers"]
response_headers = response["headers"]

print("MITM captured upstream request:")
print(f"  URL: {request['pretty_url']}")
print(f"  User-Agent: {headers.get('User-Agent', '')}")
print(f"  X-App: {headers.get('X-App', '')}")
print(f"  X-Stainless-Package-Version: {headers.get('X-Stainless-Package-Version', '')}")
print(f"  X-Stainless-Runtime-Version: {headers.get('X-Stainless-Runtime-Version', '')}")
print(f"  X-Stainless-Timeout: {headers.get('X-Stainless-Timeout', '')}")
print("MITM captured upstream response:")
print(f"  Status: {response.get('status_code')}")
print(f"  Content-Type: {response_headers.get('Content-Type', '')}")
print("Response body prefix:")
print(response.get("body_prefix", ""))
PY

echo
echo "Direct core response preview:"
sed -n '1,20p' "$response_file"
