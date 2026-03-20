import base64
import json
import os
from datetime import datetime, timezone
from pathlib import Path

from mitmproxy import http


OUTPUT_PATH = Path(os.environ.get("QUOTIO_MITM_FLOW_FILE", "/tmp/quotio-mitm/flows.jsonl"))
TARGET_HOST = "api.anthropic.com"
TARGET_PATH = "/v1/messages"


def _trim_text(data: bytes, limit: int = 1200) -> str:
    if not data:
        return ""
    head = data[:limit]
    try:
        return head.decode("utf-8", errors="replace")
    except Exception:
        return base64.b64encode(head).decode("ascii")


def response(flow: http.HTTPFlow) -> None:
    request = flow.request
    if request.host != TARGET_HOST:
        return
    if not request.path.startswith(TARGET_PATH):
        return

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    record = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
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
    with OUTPUT_PATH.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, ensure_ascii=False) + "\n")
