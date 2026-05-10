#!/bin/bash

DEV_BUNDLE_ID="${DEV_BUNDLE_ID:-dev.quotio.desktop.dev}"
DEV_PRODUCT_NAME="${DEV_PRODUCT_NAME:-Quotio Dev}"
DEV_DISPLAY_NAME="${DEV_DISPLAY_NAME:-${DEV_PRODUCT_NAME}}"
DEV_APP_ICON="${DEV_APP_ICON:-AppIconDev}"
PRIMARY_BUNDLE_ID="${PRIMARY_BUNDLE_ID:-dev.quotio.desktop}"

dev_app_path() {
    local derived_data_path="$1"
    local configuration="${2:-Debug}"
    printf '%s/Build/Products/%s/%s.app\n' "${derived_data_path}" "${configuration}" "${DEV_PRODUCT_NAME}"
}

dev_app_executable_path() {
    local app_bundle="$1"
    printf '%s/Contents/MacOS/%s\n' "${app_bundle}" "${DEV_PRODUCT_NAME}"
}

build_isolated_dev_app() {
    local project_dir="$1"
    local scheme="$2"
    local configuration="$3"
    local derived_data_path="$4"

    xcodebuild \
        -project "${project_dir}/Quotio.xcodeproj" \
        -scheme "${scheme}" \
        -configuration "${configuration}" \
        -derivedDataPath "${derived_data_path}" \
        build \
        CODE_SIGN_IDENTITY="-" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        PRODUCT_BUNDLE_IDENTIFIER="${DEV_BUNDLE_ID}" \
        PRODUCT_NAME="${DEV_PRODUCT_NAME}" \
        INFOPLIST_KEY_CFBundleDisplayName="${DEV_DISPLAY_NAME}" \
        ASSETCATALOG_COMPILER_APPICON_NAME="${DEV_APP_ICON}"
}

plist_value() {
    local plist_path="$1"
    local key="$2"
    /usr/libexec/PlistBuddy -c "Print :${key}" "${plist_path}" 2>/dev/null || true
}

validate_isolated_dev_app_bundle() {
    local app_bundle="$1"
    local info_plist="${app_bundle}/Contents/Info.plist"
    local executable_path
    local bundle_id
    local bundle_name
    local display_name

    if [[ ! -d "${app_bundle}" ]]; then
        echo "Dev app bundle 不存在: ${app_bundle}" >&2
        return 1
    fi
    if [[ ! -f "${info_plist}" ]]; then
        echo "Dev app Info.plist 不存在: ${info_plist}" >&2
        return 1
    fi

    bundle_id="$(plist_value "${info_plist}" CFBundleIdentifier)"
    bundle_name="$(plist_value "${info_plist}" CFBundleName)"
    display_name="$(plist_value "${info_plist}" CFBundleDisplayName)"
    executable_path="$(dev_app_executable_path "${app_bundle}")"

    if [[ "${bundle_id}" == "${PRIMARY_BUNDLE_ID}" ]]; then
        echo "拒绝启动 primary bundle id: ${bundle_id}" >&2
        return 1
    fi
    if [[ "${bundle_id}" != "${DEV_BUNDLE_ID}" ]]; then
        echo "Dev app bundle id 不匹配: got=${bundle_id} expected=${DEV_BUNDLE_ID}" >&2
        return 1
    fi
    if [[ "${bundle_name}" != "${DEV_PRODUCT_NAME}" ]]; then
        echo "Dev app bundle name 不匹配: got=${bundle_name} expected=${DEV_PRODUCT_NAME}" >&2
        return 1
    fi
    if [[ "${display_name}" != "${DEV_DISPLAY_NAME}" ]]; then
        echo "Dev app display name 不匹配: got=${display_name} expected=${DEV_DISPLAY_NAME}" >&2
        return 1
    fi
    if [[ ! -x "${executable_path}" ]]; then
        echo "Dev app executable 不存在或不可执行: ${executable_path}" >&2
        return 1
    fi
}
