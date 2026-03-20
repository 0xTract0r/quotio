import base64
import json
import os
from datetime import datetime, timezone
from pathlib import Path

from mitmproxy import http


OUTPUT_PATH = Path(os.environ.get("QUOTIO_MITM_FLOW_FILE", "/tmp/quotio-mitm/openai-flows.jsonl"))
TARGETS = (
    ("api.openai.com", ("/v1/responses", "/v1/chat/completions")),
    ("chatgpt.com", ("/backend-api/codex/responses",)),
)


def _trim_text(data: bytes, limit: int = 1200) -> str:
    if not data:
        return ""
    head = data[:limit]
    try:
        return head.decode("utf-8", errors="replace")
    except Exception:
        return base64.b64encode(head).decode("ascii")


def _format_local_timestamp(iso_utc: str) -> str:
    try:
        dt = datetime.fromisoformat(iso_utc)
        return dt.astimezone().strftime("%Y-%m-%d %H:%M:%S %z")
    except Exception:
        return iso_utc


def response(flow: http.HTTPFlow) -> None:
    request = flow.request
    if not any(
        request.host == host and any(request.path.startswith(prefix) for prefix in prefixes)
        for host, prefixes in TARGETS
    ):
        return

    timestamp = datetime.now(timezone.utc).isoformat()
    record = {
        "timestamp": timestamp,
        "request": {
            "method": request.method,
            "scheme": request.scheme,
            "host": request.host,
            "path": request.path,
            "pretty_url": request.pretty_url,
            "headers": dict(request.headers.items(multi=True)),
            "body_prefix": _trim_text(request.raw_content or b""),
        },
        "response": {
            "status_code": flow.response.status_code if flow.response else None,
            "headers": dict(flow.response.headers.items(multi=True)) if flow.response else {},
            "body_prefix": _trim_text(flow.response.raw_content or b"") if flow.response else "",
        },
    }

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT_PATH.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, ensure_ascii=False) + "\n")

    headers = {str(key).lower(): value for key, value in request.headers.items(multi=True)}
    print("== Captured OpenAI/Codex Request ==")
    print(f"timestamp_utc: {timestamp}")
    print(f"timestamp_local: {_format_local_timestamp(timestamp)}")
    print(f"url: {request.pretty_url}")
    for key in [
        "user-agent",
        "version",
        "openai-beta",
        "x-stainless-lang",
        "x-stainless-package-version",
        "x-stainless-runtime-version",
    ]:
        print(f"{key}: {headers.get(key, '')}")
    print(f"request_body_prefix: {record['request']['body_prefix'][:240].replace(chr(10), ' ')}")
    print(f"response_status: {record['response']['status_code']}")
    print(f"flow_file: {OUTPUT_PATH}")
