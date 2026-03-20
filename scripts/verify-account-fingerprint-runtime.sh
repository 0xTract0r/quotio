#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
PORT="${PORT:-18761}"
SERVER_LOG="$TMP_DIR/server.log"
SERVER_PID=""

cleanup() {
  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

cat >"$TMP_DIR/echo_server.py" <<'PY'
import json
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        payload = json.dumps({
            "path": self.path,
            "headers": {k: v for k, v in self.headers.items()},
        }).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format, *args):
        return


HTTPServer(("127.0.0.1", int(__import__("os").environ["PORT"])), Handler).serve_forever()
PY

PORT="$PORT" python3 "$TMP_DIR/echo_server.py" >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!
sleep 1

cat >"$TMP_DIR/verify.swift" <<'SWIFT'
import Foundation
import Darwin

@main
struct FingerprintRuntimeVerifier {
    static func main() async throws {
        guard CommandLine.arguments.count >= 3 else {
            fputs("usage: verify <port> <metadata-key>\n", stderr)
            exit(2)
        }

        let port = CommandLine.arguments[1]
        let metadataKey = CommandLine.arguments[2]
        let expectedUA = "quotio-verify/1.0 \(UUID().uuidString.prefix(8))"

        let payload = [
            metadataKey: [
                "userAgent": [
                    "value": expectedUA
                ]
            ]
        ]
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        UserDefaults.standard.set(data, forKey: "providers.accountFingerprints")

        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/echo")!)
        request.httpMethod = "GET"
        AccountFingerprintRuntime.applyUserAgent(
            to: &request,
            metadataKey: metadataKey,
            fallback: "fallback-ua/0.1"
        )

        let (responseData, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any]
        let headers = json?["headers"] as? [String: String]
        let actualUA = headers?["User-Agent"] ?? headers?["User-agent"] ?? ""

        guard actualUA == expectedUA else {
            fputs("Expected User-Agent \(expectedUA), got \(actualUA)\n", stderr)
            exit(1)
        }

        print("verified metadataKey=\(metadataKey)")
        print("userAgent=\(actualUA)")
    }
}
SWIFT

xcrun swiftc \
  "$ROOT_DIR/Quotio/Services/AccountFingerprintRuntime.swift" \
  "$TMP_DIR/verify.swift" \
  -o "$TMP_DIR/verify-account-fingerprint"

"$TMP_DIR/verify-account-fingerprint" "$PORT" "verify:account:fingerprint"
