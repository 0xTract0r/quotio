#!/usr/bin/env python3
"""Generate a read-only Codex proxy fingerprint sync report.

This script fetches only allowlisted public source files, parses a small set of
header/fingerprint fields, and writes a JSON report. It never modifies runtime
configuration, never reads auth files, and never downloads or executes native
binaries.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import ssl
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT_DIR = REPO_ROOT / "build" / "codex-proxy-fingerprint"


@dataclass(frozen=True)
class SourceSpec:
    name: str
    url: str
    optional: bool = False


SOURCES = [
    SourceSpec(
        "codex_proxy_default_config",
        "https://raw.githubusercontent.com/icebear0828/codex-proxy/master/config/default.yaml",
    ),
    SourceSpec(
        "codex_proxy_fingerprint_config",
        "https://raw.githubusercontent.com/icebear0828/codex-proxy/master/config/fingerprint.yaml",
    ),
    SourceSpec(
        "codex_proxy_native_cargo",
        "https://raw.githubusercontent.com/icebear0828/codex-proxy/master/native/Cargo.toml",
    ),
    SourceSpec(
        "codex_proxy_fingerprint_manager",
        "https://raw.githubusercontent.com/icebear0828/codex-proxy/master/src/fingerprint/manager.ts",
        optional=True,
    ),
    SourceSpec(
        "official_codex_default_client",
        "https://raw.githubusercontent.com/openai/codex/main/codex-rs/login/src/auth/default_client.rs",
    ),
    SourceSpec(
        "npm_openai_codex_latest",
        "https://registry.npmjs.org/@openai%2Fcodex/latest",
    ),
]


def default_ssl_context() -> ssl.SSLContext:
    try:
        import certifi  # type: ignore

        return ssl.create_default_context(cafile=certifi.where())
    except Exception:
        return ssl.create_default_context()


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def fetch_source(source: SourceSpec, timeout: int) -> dict[str, Any]:
    request = urllib.request.Request(
        source.url,
        headers={
            "User-Agent": "Quotio-codex-proxy-fingerprint-report/1.0",
            "Accept": "application/json,text/plain,*/*",
        },
    )
    retrieved_at = utc_now()
    try:
        with urllib.request.urlopen(request, timeout=timeout, context=default_ssl_context()) as response:
            body = response.read()
            status = getattr(response, "status", None)
            content_type = response.headers.get("Content-Type", "")
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f"HTTP {exc.code} while fetching {source.url}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"network error while fetching {source.url}: {exc.reason}") from exc
    except TimeoutError as exc:
        raise RuntimeError(f"timeout after {timeout}s while fetching {source.url}") from exc

    text = body.decode("utf-8", errors="replace")
    return {
        "name": source.name,
        "source_url": source.url,
        "retrieved_at": retrieved_at,
        "status": status,
        "content_type": content_type,
        "bytes": len(body),
        "sha256": sha256_text(text),
        "text": text,
    }


def yaml_scalar(value: str) -> Any:
    value = value.strip()
    if value in {"null", "~"}:
        return None
    if value in {"true", "false"}:
        return value == "true"
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [yaml_scalar(part.strip()) for part in inner.split(",")]
    if (value.startswith('"') and value.endswith('"')) or (
        value.startswith("'") and value.endswith("'")
    ):
        return value[1:-1]
    if re.fullmatch(r"-?\d+", value):
        try:
            return int(value)
        except ValueError:
            return value
    return value


def parse_simple_yaml(text: str) -> dict[str, Any]:
    root: dict[str, Any] = {}
    stack: list[tuple[int, Any]] = [(-1, root)]
    lines = text.splitlines()
    index = 0
    while index < len(lines):
        raw = lines[index]
        index += 1
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        while stack and indent <= stack[-1][0]:
            stack.pop()
        parent = stack[-1][1]
        if stripped.startswith("- "):
            if not isinstance(parent, list):
                continue
            parent.append(yaml_scalar(stripped[2:]))
            continue
        if ":" not in stripped or not isinstance(parent, dict):
            continue
        key, value = stripped.split(":", 1)
        key = key.strip()
        value = value.strip()
        if value:
            parent[key] = yaml_scalar(value)
            continue
        next_container: Any = {}
        lookahead = index
        while lookahead < len(lines):
            next_stripped = lines[lookahead].strip()
            if not next_stripped or next_stripped.startswith("#"):
                lookahead += 1
                continue
            next_container = [] if next_stripped.startswith("- ") else {}
            break
        parent[key] = next_container
        stack.append((indent, next_container))
    return root


def parse_codex_proxy_default(text: str) -> dict[str, Any]:
    data = parse_simple_yaml(text)
    client = data.get("client") if isinstance(data.get("client"), dict) else {}
    api = data.get("api") if isinstance(data.get("api"), dict) else {}
    tls = data.get("tls") if isinstance(data.get("tls"), dict) else {}
    return {
        "base_url": api.get("base_url"),
        "originator": client.get("originator"),
        "app_version": client.get("app_version"),
        "build_number": client.get("build_number"),
        "platform": client.get("platform"),
        "arch": client.get("arch"),
        "chromium_version": client.get("chromium_version"),
        "tls_transport": tls.get("transport"),
        "tls_force_http11": tls.get("force_http11"),
    }


def parse_codex_proxy_fingerprint(text: str) -> dict[str, Any]:
    data = parse_simple_yaml(text)
    return {
        "user_agent_template": data.get("user_agent_template"),
        "auth_domains": data.get("auth_domains"),
        "auth_domain_exclusions": data.get("auth_domain_exclusions"),
        "header_order": data.get("header_order"),
        "default_headers": data.get("default_headers"),
    }


def parse_cargo_versions(text: str) -> dict[str, Any]:
    parsed: dict[str, Any] = {}
    reqwest = re.search(
        r'reqwest\s*=\s*\{[^}]*version\s*=\s*"([^"]+)"[^}]*features\s*=\s*\[([^\]]*)\]',
        text,
        flags=re.DOTALL,
    )
    if reqwest:
        parsed["reqwest_version"] = reqwest.group(1)
        parsed["reqwest_features"] = re.findall(r'"([^"]+)"', reqwest.group(2))
    rustls = re.search(r'rustls\s*=\s*"=?([^"]+)"', text)
    if rustls:
        parsed["rustls_version"] = rustls.group(1)
    return parsed


def parse_manager_hints(text: str) -> dict[str, Any]:
    raw_header_keys = sorted(set(re.findall(r'raw\["([^"]+)"\]', text)))
    exported_builders = sorted(
        set(re.findall(r"export function (build[A-Za-z0-9_]+)\(", text))
    )
    return {
        "exported_header_builders": exported_builders,
        "raw_header_keys": raw_header_keys,
        "mentions_cookie": bool(re.search(r"\bCookie\b", text)),
        "mentions_cloudflare": bool(re.search(r"cloudflare", text, re.IGNORECASE)),
    }


def parse_official_default_client(text: str) -> dict[str, Any]:
    default_originator = regex_group(
        r'pub const DEFAULT_ORIGINATOR:\s*&str\s*=\s*"([^"]+)"', text
    )
    residency_header = regex_group(
        r'pub const RESIDENCY_HEADER_NAME:\s*&str\s*=\s*"([^"]+)"', text
    )
    first_party = []
    first_party_match = re.search(
        r"pub fn is_first_party_originator\(.*?\{(.*?)\n\}",
        text,
        flags=re.DOTALL,
    )
    if first_party_match:
        first_party = re.findall(r'originator_value\s*==\s*"([^"]+)"', first_party_match.group(1))
    return {
        "default_originator": default_originator,
        "residency_header_name": residency_header,
        "first_party_originators": first_party,
    }


def parse_npm_latest(text: str) -> dict[str, Any]:
    data = json.loads(text)
    return {
        "name": data.get("name"),
        "version": data.get("version"),
        "dist_tags_source": "latest endpoint",
        "published_at": data.get("time", {}).get("modified") if isinstance(data.get("time"), dict) else None,
    }


def regex_group(pattern: str, text: str) -> str | None:
    match = re.search(pattern, text, flags=re.DOTALL)
    return match.group(1) if match else None


def build_codex_proxy_user_agent(default: dict[str, Any], fp: dict[str, Any]) -> str | None:
    template = fp.get("user_agent_template")
    if not isinstance(template, str):
        return None
    result = template
    replacements = {
        "{version}": default.get("app_version"),
        "{platform}": default.get("platform"),
        "{arch}": default.get("arch"),
    }
    for needle, replacement in replacements.items():
        result = result.replace(needle, str(replacement or ""))
    return result


def parse_local_codex_policy() -> dict[str, Any]:
    helper_path = REPO_ROOT / "third_party/CLIProxyAPIPlus/internal/runtime/executor/helps/codex_client_profile.go"
    executor_path = REPO_ROOT / "third_party/CLIProxyAPIPlus/internal/runtime/executor/codex_executor.go"
    parsed: dict[str, Any] = {
        "source_files": [
            str(helper_path.relative_to(REPO_ROOT)),
            str(executor_path.relative_to(REPO_ROOT)),
        ]
    }
    errors: list[str] = []
    try:
        helper = helper_path.read_text(encoding="utf-8")
        constants = dict(re.findall(r'(defaultCodexManaged[A-Za-z]+)\s*=\s*"([^"]+)"', helper))
        parsed.update(
            {
                "originator": constants.get("defaultCodexManagedOriginator"),
                "version": constants.get("defaultCodexManagedVersion"),
                "platform": constants.get("defaultCodexManagedPlatform"),
                "terminal": constants.get("defaultCodexManagedTerminal"),
                "first_party_originators": re.findall(
                    r'case\s+"([^"]+)"(?:,|\:)', helper
                ),
            }
        )
        if parsed.get("originator") and parsed.get("version"):
            tail = f'{parsed.get("terminal")} ({parsed.get("originator")}; {parsed.get("version")})'
            parsed["user_agent_template"] = "{originator}/{version} ({platform}) {tail}"
            parsed["computed_user_agent"] = (
                f'{parsed.get("originator")}/{parsed.get("version")} '
                f'({parsed.get("platform")}) {tail}'
            )
    except OSError as exc:
        errors.append(f"failed to read {helper_path}: {exc}")
    try:
        executor = executor_path.read_text(encoding="utf-8")
        parsed["managed_header_snapshot_order"] = re.findall(
            r'"([^"]+)"',
            regex_group(r"captureManagedHeaderSnapshot\(r\.Header,\s*\[\]string\{([^}]*)\}", executor)
            or "",
        )
        parsed["sets_connection_keep_alive"] = 'r.Header.Set("Connection", "Keep-Alive")' in executor
    except OSError as exc:
        errors.append(f"failed to read {executor_path}: {exc}")
    if errors:
        parsed["errors"] = errors
    return parsed


def diff_values(current: dict[str, Any], reference: dict[str, Any]) -> list[dict[str, Any]]:
    pairs = [
        ("originator", current.get("originator"), reference.get("originator")),
        ("version", current.get("version"), reference.get("app_version")),
        ("platform", current.get("platform"), reference.get("platform")),
        ("user_agent_template", current.get("user_agent_template"), reference.get("user_agent_template")),
        ("header_order", current.get("managed_header_snapshot_order"), reference.get("header_order")),
    ]
    diffs = []
    for field, local_value, upstream_value in pairs:
        if local_value != upstream_value:
            diffs.append(
                {
                    "field": field,
                    "local": local_value,
                    "codex_proxy": upstream_value,
                    "sync_policy": "report-only; do not auto-apply",
                }
            )
    return diffs


def build_report(fetched: dict[str, dict[str, Any]], errors: list[dict[str, Any]]) -> dict[str, Any]:
    parsed_sources: dict[str, dict[str, Any]] = {}
    source_records = []
    for name, item in fetched.items():
        text = item["text"]
        if name == "codex_proxy_default_config":
            parsed = parse_codex_proxy_default(text)
        elif name == "codex_proxy_fingerprint_config":
            parsed = parse_codex_proxy_fingerprint(text)
        elif name == "codex_proxy_native_cargo":
            parsed = parse_cargo_versions(text)
        elif name == "codex_proxy_fingerprint_manager":
            parsed = parse_manager_hints(text)
        elif name == "official_codex_default_client":
            parsed = parse_official_default_client(text)
        elif name == "npm_openai_codex_latest":
            parsed = parse_npm_latest(text)
        else:
            parsed = {}
        parsed_sources[name] = parsed
        source_records.append(
            {
                "name": name,
                "source_url": item["source_url"],
                "retrieved_at": item["retrieved_at"],
                "status": item["status"],
                "content_type": item["content_type"],
                "bytes": item["bytes"],
                "sha256": item["sha256"],
                "parsed_fields": parsed,
            }
        )

    codex_proxy_default = parsed_sources.get("codex_proxy_default_config", {})
    codex_proxy_fingerprint = parsed_sources.get("codex_proxy_fingerprint_config", {})
    local_policy = parse_local_codex_policy()
    codex_proxy = {
        **codex_proxy_default,
        **codex_proxy_fingerprint,
        "computed_user_agent": build_codex_proxy_user_agent(
            codex_proxy_default, codex_proxy_fingerprint
        ),
        "native": parsed_sources.get("codex_proxy_native_cargo", {}),
        "manager_hints": parsed_sources.get("codex_proxy_fingerprint_manager", {}),
    }

    return {
        "schema_version": 1,
        "generated_at": utc_now(),
        "mode": "read_only_report",
        "safety": {
            "modifies_configuration": False,
            "reads_auth_or_secrets": False,
            "accesses_production_runtime": False,
            "executes_upstream_scripts": False,
            "downloads_or_runs_native_binaries": False,
            "allowed_source_count": len(SOURCES),
        },
        "sources": source_records,
        "codex_proxy": codex_proxy,
        "official_codex": parsed_sources.get("official_codex_default_client", {}),
        "npm_openai_codex": parsed_sources.get("npm_openai_codex_latest", {}),
        "local_policy": local_policy,
        "diffs": diff_values(local_policy, {**codex_proxy_default, **codex_proxy_fingerprint}),
        "recommendations": [
            "Treat codex-proxy values as evidence for review, not as auto-apply configuration.",
            "Use npm latest only for version markers; do not infer stable identity or TLS fields from it.",
            "Keep raw TLS / HTTP2 parity as unverified until provider-facing capture proves it.",
        ],
        "errors": errors,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fetch allowlisted Codex/codex-proxy metadata and write a read-only JSON diff report."
    )
    parser.add_argument(
        "-o",
        "--output",
        help="Output JSON path. Defaults to build/codex-proxy-fingerprint/report-<timestamp>.json.",
    )
    parser.add_argument("--timeout", type=int, default=30, help="Per-source network timeout in seconds.")
    parser.add_argument(
        "--allow-partial",
        action="store_true",
        help="Write a report even if mandatory sources fail. Default exits non-zero on mandatory failure.",
    )
    parser.add_argument(
        "--list-sources",
        action="store_true",
        help="Print the allowlisted source URLs and exit without fetching.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.list_sources:
        for source in SOURCES:
            marker = "optional" if source.optional else "required"
            print(f"{marker}\t{source.name}\t{source.url}")
        return 0

    fetched: dict[str, dict[str, Any]] = {}
    errors: list[dict[str, Any]] = []
    for source in SOURCES:
        try:
            fetched[source.name] = fetch_source(source, args.timeout)
        except RuntimeError as exc:
            error = {
                "name": source.name,
                "source_url": source.url,
                "optional": source.optional,
                "error": str(exc),
                "retrieved_at": utc_now(),
            }
            errors.append(error)
            if not source.optional and not args.allow_partial:
                print(f"error: {error['error']}", file=sys.stderr)
                print("hint: use --allow-partial to write a partial report.", file=sys.stderr)
                return 2

    report = build_report(fetched, errors)
    if args.output:
        output_path = Path(args.output)
    else:
        stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        output_path = DEFAULT_OUTPUT_DIR / f"report-{stamp}.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(output_path)
    if errors and not args.allow_partial:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
