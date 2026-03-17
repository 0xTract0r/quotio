#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

TEST_PRODUCT_NAME="Quotio Test"
TEST_DISPLAY_NAME="Quotio Test"
TEST_BUNDLE_ID="dev.quotio.desktop.test"
TEST_BUILD_DIR="${PROJECT_DIR}/build/test-app"
TEST_DERIVED_DATA="${PROJECT_DIR}/build/test-derived-data"
TEST_APP_PATH="${TEST_BUILD_DIR}/${TEST_PRODUCT_NAME}.app"

print_header "Quotio Test Build" 50
print_summary "Test Build Configuration" \
    "Scheme" "${SCHEME}" \
    "Bundle ID" "${TEST_BUNDLE_ID}" \
    "Product" "${TEST_PRODUCT_NAME}" \
    "Output" "${TEST_APP_PATH}" \
    "App Support" "~/Library/Application Support/Quotio-Test" \
    "Auth Dir" "~/.cli-proxy-api-test" \
    "Default Port" "9317"

rm -rf "${TEST_BUILD_DIR}" "${TEST_DERIVED_DATA}"
mkdir -p "${TEST_BUILD_DIR}"

log_step "Building isolated test app..."
xcodebuild \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration Debug \
    -derivedDataPath "${TEST_DERIVED_DATA}" \
    CONFIGURATION_BUILD_DIR="${TEST_BUILD_DIR}" \
    PRODUCT_BUNDLE_IDENTIFIER="${TEST_BUNDLE_ID}" \
    PRODUCT_NAME="${TEST_PRODUCT_NAME}" \
    INFOPLIST_KEY_CFBundleDisplayName="${TEST_DISPLAY_NAME}" \
    build

if [[ ! -d "${TEST_APP_PATH}" ]]; then
    log_failure "Test app was not produced at ${TEST_APP_PATH}"
    exit 1
fi

echo ""
print_summary "Test App Ready" \
    "App" "${TEST_APP_PATH}" \
    "Run" "open -n \"${TEST_APP_PATH}\"" \
    "Data Dir" "~/Library/Application Support/Quotio-Test" \
    "Auth Dir" "~/.cli-proxy-api-test"
