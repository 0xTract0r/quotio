#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

TEST_BUNDLE_ID="dev.quotio.desktop.test"
TEST_PRODUCT_NAME="Quotio Test"
TEST_APP_PATH="${PROJECT_DIR}/build/test-app/${TEST_PRODUCT_NAME}.app"
TEST_DEFAULTS_BACKUP=""
TEST_LOG_FILE="${PROJECT_DIR}/build/identity-packages-ui-smoke.log"
EXPECTED_PACKAGE_NAME="UI Smoke Package"
EXPECTED_UPDATED_HOST="updated.identity.local"
EXPECTED_UPDATED_PORT="8443"

cleanup() {
    pkill -x "${TEST_PRODUCT_NAME}" >/dev/null 2>&1 || true

    if [[ -n "${TEST_DEFAULTS_BACKUP}" && -f "${TEST_DEFAULTS_BACKUP}" ]]; then
        defaults import "${TEST_BUNDLE_ID}" "${TEST_DEFAULTS_BACKUP}" >/dev/null 2>&1 || true
        rm -f "${TEST_DEFAULTS_BACKUP}"
    else
        defaults delete "${TEST_BUNDLE_ID}" >/dev/null 2>&1 || true
    fi
}

check_accessibility_permission() {
    swift - <<'EOF'
import ApplicationServices
import Foundation

guard AXIsProcessTrusted() else {
    fputs("Accessibility permission is required for native UI smoke. Grant Terminal/osascript access in System Settings > Privacy & Security > Accessibility.\n", stderr)
    exit(1)
}
EOF
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

run_applescript_smoke() {
    TEST_PRODUCT_NAME="${TEST_PRODUCT_NAME}" EXPECTED_PACKAGE_NAME="${EXPECTED_PACKAGE_NAME}" EXPECTED_UPDATED_HOST="${EXPECTED_UPDATED_HOST}" EXPECTED_UPDATED_PORT="${EXPECTED_UPDATED_PORT}" osascript <<'EOF'
on waitForWindow(processName)
	tell application "System Events"
		tell process processName
			repeat 60 times
				if (count of windows) > 0 then return window 1
				delay 1
			end repeat
		end tell
	end tell
	error "Timed out waiting for Quotio Test window"
end waitForWindow

on clickSidebarRow(mainWindow, rowLabel)
	tell application "System Events"
		tell process (system attribute "TEST_PRODUCT_NAME")
			tell mainWindow
				repeat with sidebarRow in rows of outline 1 of scroll area 1 of splitter group 1
					if exists static text rowLabel of sidebarRow then
						select sidebarRow
						return
					end if
				end repeat
			end tell
		end tell
	end tell
	error "Sidebar row not found: " & rowLabel
end clickSidebarRow

on findButtonByTitle(mainWindow, buttonTitle)
	tell application "System Events"
		tell process (system attribute "TEST_PRODUCT_NAME")
			tell mainWindow
				repeat 30 times
					try
						return first button of entire contents whose title is buttonTitle
					end try
					delay 0.5
				end repeat
			end tell
		end tell
	end tell
	error "Button not found: " & buttonTitle
end findButtonByTitle

on findTextFieldByValue(mainWindow, fieldValue)
	tell application "System Events"
		tell process (system attribute "TEST_PRODUCT_NAME")
			tell mainWindow
				repeat 30 times
					try
						return first text field of entire contents whose value is fieldValue
					end try
					delay 0.5
				end repeat
			end tell
		end tell
	end tell
	error "Text field with value not found: " & fieldValue
end findTextFieldByValue

on waitForStaticText(mainWindow, textValue)
	tell application "System Events"
		tell process (system attribute "TEST_PRODUCT_NAME")
			tell mainWindow
				repeat 30 times
					try
						(first static text of entire contents whose value is textValue)
						return
					end try
					delay 0.5
				end repeat
			end tell
		end tell
	end tell
	error "Static text not found: " & textValue
end waitForStaticText

set processName to system attribute "TEST_PRODUCT_NAME"
set packageName to system attribute "EXPECTED_PACKAGE_NAME"
set updatedHost to system attribute "EXPECTED_UPDATED_HOST"
set updatedPort to system attribute "EXPECTED_UPDATED_PORT"

tell application processName to activate
set mainWindow to waitForWindow(processName)

my clickSidebarRow(mainWindow, "Identity Packages")
my waitForStaticText(mainWindow, packageName)
my waitForStaticText(mainWindow, "Available")

set hostField to my findTextFieldByValue(mainWindow, "fixture.identity.local")
tell application "System Events"
	tell process processName
		set value of hostField to updatedHost
	end tell
end tell

set portField to my findTextFieldByValue(mainWindow, "8080")
set saveButton to my findButtonByTitle(mainWindow, "Save")
tell application "System Events"
	tell process processName
		set value of portField to updatedPort
		click saveButton
	end tell
end tell

delay 0.5
set markBlockedButton to my findButtonByTitle(mainWindow, "Mark Blocked")
tell application "System Events"
	tell process processName
		click markBlockedButton
	end tell
end tell
my waitForStaticText(mainWindow, "Blocked")

set clearStatusButton to my findButtonByTitle(mainWindow, "Clear Local Status")
tell application "System Events"
	tell process processName
		click clearStatusButton
	end tell
end tell
my waitForStaticText(mainWindow, "Available")
EOF
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

if defaults export "${TEST_BUNDLE_ID}" - > /dev/null 2>&1; then
    TEST_DEFAULTS_BACKUP="$(mktemp "${TMPDIR:-/tmp}/quotio-ui-smoke-defaults.XXXXXX.plist")"
    defaults export "${TEST_BUNDLE_ID}" "${TEST_DEFAULTS_BACKUP}" >/dev/null 2>&1
fi

defaults delete "${TEST_BUNDLE_ID}" >/dev/null 2>&1 || true
defaults write "${TEST_BUNDLE_ID}" hasCompletedOnboarding -bool true
defaults write "${TEST_BUNDLE_ID}" operatingMode -string local
defaults write "${TEST_BUNDLE_ID}" showInDock -bool true
defaults write "${TEST_BUNDLE_ID}" appLanguage -string en
defaults write "${TEST_BUNDLE_ID}" runtimeIsolationDebugLogPath -string "${TEST_LOG_FILE}"

log_step "Checking Accessibility permission..."
check_accessibility_permission

write_identity_packages_fixture

log_step "Building isolated test app..."
"${SCRIPT_DIR}/build-test-app.sh" >/dev/null

pkill -x "${TEST_PRODUCT_NAME}" >/dev/null 2>&1 || true

log_step "Launching ${TEST_PRODUCT_NAME}..."
open -n "${TEST_APP_PATH}" --args --runtime-isolation-debug-log-path "${TEST_LOG_FILE}"

APP_STARTED="false"
for _ in $(seq 1 20); do
    if pgrep -x "${TEST_PRODUCT_NAME}" >/dev/null 2>&1; then
        APP_STARTED="true"
        break
    fi
    sleep 1
done

if [[ "${APP_STARTED}" != "true" ]]; then
    log_error "${TEST_PRODUCT_NAME} did not start"
    exit 1
fi

log_step "Driving native UI smoke path..."
if ! run_applescript_smoke >>"${TEST_LOG_FILE}" 2>&1; then
    log_error "AppleScript UI smoke failed"
    log_item "Hint: grant Accessibility permission to Terminal and /usr/bin/osascript, then rerun this script."
    tail -n 80 "${TEST_LOG_FILE}" || true
    exit 1
fi

log_step "Stopping ${TEST_PRODUCT_NAME}..."
pkill -x "${TEST_PRODUCT_NAME}" >/dev/null 2>&1 || true
sleep 2

log_step "Validating persisted identity package state..."
assert_identity_package_defaults

print_summary "Smoke Passed" \
    "Navigation" "Identity Packages" \
    "Status Path" "Available -> Blocked -> Available" \
    "Persisted Host" "${EXPECTED_UPDATED_HOST}:${EXPECTED_UPDATED_PORT}"
