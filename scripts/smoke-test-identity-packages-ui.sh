#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

TEST_BUNDLE_ID="dev.quotio.desktop.test"
TEST_PRODUCT_NAME="Quotio Test"
TEST_APP_PATH="${PROJECT_DIR}/build/test-app/${TEST_PRODUCT_NAME}.app"
TEST_EXECUTABLE="${TEST_APP_PATH}/Contents/MacOS/${TEST_PRODUCT_NAME}"
TEST_EXECUTABLE_PATTERN="/${TEST_PRODUCT_NAME}.app/Contents/MacOS/${TEST_PRODUCT_NAME}"
TEST_DEFAULTS_BACKUP=""
TEST_LOG_FILE="${PROJECT_DIR}/build/identity-packages-ui-smoke.log"
EXPECTED_PACKAGE_NAME="UI Smoke Package"
EXPECTED_UPDATED_HOST="updated.identity.local"
EXPECTED_UPDATED_PORT="8443"
TEST_APP_PID=""
SMOKE_EMPTY_STATE_FLAG="0"
SMOKE_FIXTURE_FLOW_FLAG="0"

cleanup() {
    if [[ -n "${TEST_APP_PID}" ]]; then
        kill "${TEST_APP_PID}" >/dev/null 2>&1 || true
        wait "${TEST_APP_PID}" 2>/dev/null || true
        TEST_APP_PID=""
    fi

    pkill -f "${TEST_EXECUTABLE_PATTERN}" >/dev/null 2>&1 || true

    if [[ -n "${TEST_DEFAULTS_BACKUP}" && -f "${TEST_DEFAULTS_BACKUP}" ]]; then
        defaults import "${TEST_BUNDLE_ID}" "${TEST_DEFAULTS_BACKUP}" >/dev/null 2>&1 || true
        rm -f "${TEST_DEFAULTS_BACKUP}"
    else
        defaults delete "${TEST_BUNDLE_ID}" >/dev/null 2>&1 || true
    fi
}

configure_launch_env() {
    local stage="$1"

    case "${stage}" in
    empty)
        SMOKE_EMPTY_STATE_FLAG="1"
        SMOKE_FIXTURE_FLOW_FLAG="0"
        ;;
    fixture)
        SMOKE_EMPTY_STATE_FLAG="0"
        SMOKE_FIXTURE_FLOW_FLAG="1"
        ;;
    *)
        log_error "Unknown identity smoke stage: ${stage}"
        exit 1
        ;;
    esac
}

write_identity_packages_fixture() {
    TEST_BUNDLE_ID="${TEST_BUNDLE_ID}" EXPECTED_PACKAGE_NAME="${EXPECTED_PACKAGE_NAME}" swift - <<'EOF'
import Foundation

enum IdentityPackageStatus: String, Codable {
    case draft
    case available
    case bound
    case verificationFailed
    case blocked
}

enum IdentityProxyScheme: String, Codable {
    case http
    case https
    case socks5
}

struct IdentityProxyConfig: Codable {
    var scheme: IdentityProxyScheme
    var host: String
    var port: Int
    var username: String?
    var passwordRef: String?
}

struct UserAgentProfile: Codable {
    let id: UUID
    var name: String
    var userAgent: String
    var secChUa: String?
    var secChUaMobile: String?
    var secChUaPlatform: String?
    var acceptLanguage: String?
}

enum TLSFingerprintMode: String, Codable {
    case inherited
    case browserLike
    case customTemplate
}

struct TLSFingerprintProfile: Codable {
    let id: UUID
    var name: String
    var mode: TLSFingerprintMode
    var clientHelloTemplate: String?
    var alpn: [String]
    var sniStrategy: String?
}

struct IdentityVerificationSnapshot: Codable {
    var lastVerifiedAt: Date?
    var lastExitIPAddress: String?
    var lastEchoedUserAgent: String?
    var lastTLSDigest: String?
    var passed: Bool
    var traceId: String?
    var note: String?
}

struct BoundAccountRef: Codable {
    var authFileId: String
    var authIndex: String
    var providerRawValue: String
    var accountKey: String
    var displayName: String
}

struct RuntimeIdentityPackage: Codable {
    let id: UUID
    var name: String
    var status: IdentityPackageStatus
    var statusReason: String?
    var proxy: IdentityProxyConfig
    var uaProfile: UserAgentProfile
    var tlsProfile: TLSFingerprintProfile
    var verification: IdentityVerificationSnapshot?
    var binding: BoundAccountRef?
    var createdAt: Date
    var updatedAt: Date
}

let bundleID = ProcessInfo.processInfo.environment["TEST_BUNDLE_ID"]!
let packageName = ProcessInfo.processInfo.environment["EXPECTED_PACKAGE_NAME"]!
let defaults = UserDefaults(suiteName: bundleID)!
let now = Date()

let fixture = RuntimeIdentityPackage(
    id: UUID(),
    name: packageName,
    status: .available,
    statusReason: nil,
    proxy: IdentityProxyConfig(
        scheme: .https,
        host: "fixture.identity.local",
        port: 8080,
        username: "fixture-user",
        passwordRef: nil
    ),
    uaProfile: UserAgentProfile(
        id: UUID(),
        name: "Smoke UA",
        userAgent: "Mozilla/5.0 Quotio UI Smoke",
        secChUa: nil,
        secChUaMobile: nil,
        secChUaPlatform: "\"macOS\"",
        acceptLanguage: "en-US,en;q=0.9"
    ),
    tlsProfile: TLSFingerprintProfile(
        id: UUID(),
        name: "Smoke TLS",
        mode: .browserLike,
        clientHelloTemplate: nil,
        alpn: ["h2", "http/1.1"],
        sniStrategy: "default"
    ),
    verification: nil,
    binding: nil,
    createdAt: now,
    updatedAt: now
)

let encoder = JSONEncoder()
let data = try encoder.encode([fixture])
defaults.set(data, forKey: "identityPackages.storage")
defaults.set(Data("{}".utf8), forKey: "identityPackages.bindings")
defaults.synchronize()
EOF
}

clear_identity_packages_fixture() {
    defaults delete "${TEST_BUNDLE_ID}" identityPackages.storage >/dev/null 2>&1 || true
    defaults delete "${TEST_BUNDLE_ID}" identityPackages.bindings >/dev/null 2>&1 || true
}

assert_identity_package_defaults() {
    TEST_BUNDLE_ID="${TEST_BUNDLE_ID}" EXPECTED_PACKAGE_NAME="${EXPECTED_PACKAGE_NAME}" EXPECTED_UPDATED_HOST="${EXPECTED_UPDATED_HOST}" EXPECTED_UPDATED_PORT="${EXPECTED_UPDATED_PORT}" swift - <<'EOF'
import Foundation

let bundleID = ProcessInfo.processInfo.environment["TEST_BUNDLE_ID"]!
let expectedName = ProcessInfo.processInfo.environment["EXPECTED_PACKAGE_NAME"]!
let expectedHost = ProcessInfo.processInfo.environment["EXPECTED_UPDATED_HOST"]!
let expectedPort = Int(ProcessInfo.processInfo.environment["EXPECTED_UPDATED_PORT"]!)!

guard let defaults = UserDefaults(suiteName: bundleID),
      let data = defaults.data(forKey: "identityPackages.storage"),
      let root = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
      let package = root.first(where: { ($0["name"] as? String) == expectedName }),
      let status = package["status"] as? String,
      let proxy = package["proxy"] as? [String: Any],
      let host = proxy["host"] as? String,
      let port = proxy["port"] as? Int else {
    fputs("Failed to decode persisted identity package fixture\n", stderr)
    exit(1)
}

guard status == "available" else {
    fputs("Expected status available, got \(status)\n", stderr)
    exit(1)
}

guard host == expectedHost else {
    fputs("Expected host \(expectedHost), got \(host)\n", stderr)
    exit(1)
}

guard port == expectedPort else {
    fputs("Expected port \(expectedPort), got \(port)\n", stderr)
    exit(1)
}
EOF
}

clear_log_file() {
    : > "${TEST_LOG_FILE}"
}

wait_for_log_line() {
    local pattern="$1"
    local timeout_seconds="${2:-30}"

    for _ in $(seq 1 "${timeout_seconds}"); do
        if grep -Fq "${pattern}" "${TEST_LOG_FILE}" 2>/dev/null; then
            return 0
        fi
        sleep 1
    done

    log_error "Timed out waiting for log line: ${pattern}"
    tail -n 120 "${TEST_LOG_FILE}" || true
    exit 1
}

launch_test_app() {
    local stage="$1"

    : > "${TEST_LOG_FILE}"
    pkill -f "${TEST_EXECUTABLE_PATTERN}" >/dev/null 2>&1 || true
    sleep 1

    configure_launch_env "${stage}"

    log_step "Launching ${TEST_PRODUCT_NAME} (${stage})..."
    env \
        QUOTIO_OPERATING_MODE=localProxy \
        QUOTIO_INITIAL_PAGE=identityPackages \
        QUOTIO_SHOW_IN_DOCK=1 \
        QUOTIO_SKIP_ONBOARDING=1 \
        QUOTIO_DISABLE_UPDATE_CHECKS=1 \
        QUOTIO_UI_SMOKE_IDENTITY_EMPTY_STATE="${SMOKE_EMPTY_STATE_FLAG}" \
        QUOTIO_UI_SMOKE_IDENTITY_FIXTURE_FLOW="${SMOKE_FIXTURE_FLOW_FLAG}" \
        "${TEST_EXECUTABLE}" \
        --runtime-isolation-debug-log-path "${TEST_LOG_FILE}" \
        >>"${TEST_LOG_FILE}" 2>&1 &
    TEST_APP_PID="$!"

    for _ in $(seq 1 30); do
        if [[ -n "${TEST_APP_PID}" ]] && kill -0 "${TEST_APP_PID}" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done

    log_error "${TEST_PRODUCT_NAME} did not start"
    tail -n 120 "${TEST_LOG_FILE}" || true
    exit 1
}

stop_test_app() {
    log_step "Stopping ${TEST_PRODUCT_NAME}..."
    if [[ -n "${TEST_APP_PID}" ]]; then
        kill "${TEST_APP_PID}" >/dev/null 2>&1 || true
        wait "${TEST_APP_PID}" 2>/dev/null || true
        TEST_APP_PID=""
    fi
    pkill -f "${TEST_EXECUTABLE_PATTERN}" >/dev/null 2>&1 || true
    sleep 1
}

trap cleanup EXIT

print_header "Identity Packages UI Smoke" 50
print_summary "Smoke Configuration" \
    "Bundle ID" "${TEST_BUNDLE_ID}" \
    "App" "${TEST_APP_PATH}" \
    "Log File" "${TEST_LOG_FILE}" \
    "Package" "${EXPECTED_PACKAGE_NAME}" \
    "Updated Host" "${EXPECTED_UPDATED_HOST}:${EXPECTED_UPDATED_PORT}"

mkdir -p "${PROJECT_DIR}/build"
rm -f "${TEST_LOG_FILE}"

if defaults export "${TEST_BUNDLE_ID}" - >/dev/null 2>&1; then
    TEST_DEFAULTS_BACKUP="$(mktemp "${TMPDIR:-/tmp}/quotio-ui-smoke-defaults.XXXXXX.plist")"
    defaults export "${TEST_BUNDLE_ID}" "${TEST_DEFAULTS_BACKUP}" >/dev/null 2>&1
fi

defaults delete "${TEST_BUNDLE_ID}" >/dev/null 2>&1 || true
defaults write "${TEST_BUNDLE_ID}" hasCompletedOnboarding -bool true
defaults write "${TEST_BUNDLE_ID}" operatingMode -string local
defaults write "${TEST_BUNDLE_ID}" showInDock -bool true
defaults write "${TEST_BUNDLE_ID}" appLanguage -string en
defaults write "${TEST_BUNDLE_ID}" runtimeIsolationDebugLogPath -string "${TEST_LOG_FILE}"

log_step "Building isolated test app..."
"${SCRIPT_DIR}/build-test-app.sh" >/dev/null

log_step "Running empty-state smoke..."
clear_identity_packages_fixture
clear_log_file
launch_test_app empty
wait_for_log_line "[ui-smoke] identity-empty-state-ready"
stop_test_app

log_step "Preparing fixture-backed smoke..."
write_identity_packages_fixture
clear_log_file
launch_test_app fixture
wait_for_log_line "[ui-smoke] identity-fixture-ready"
wait_for_log_line "[ui-smoke] identity-fixture-saved"
wait_for_log_line "[ui-smoke] identity-fixture-blocked"
wait_for_log_line "[ui-smoke] identity-fixture-cleared"
stop_test_app

log_step "Validating persisted identity package state..."
assert_identity_package_defaults

print_summary "Smoke Passed" \
    "Empty State" "logged" \
    "Fixture Flow" "ready -> saved -> blocked -> cleared" \
    "Persisted Host" "${EXPECTED_UPDATED_HOST}:${EXPECTED_UPDATED_PORT}"
