#!/usr/bin/env bash

set -euo pipefail

configuration="${1:-release}"
app_name="AppleMediaManager"
bundle_identifier="com.applemediamanager.app"
build_root="$(pwd)/.build/${configuration}"
app_root="$(pwd)/.build/${app_name}.app"
contents_root="${app_root}/Contents"
macos_root="${contents_root}/MacOS"

swift build --configuration "${configuration}"

rm -rf "${app_root}"
mkdir -p "${macos_root}"
cp "${build_root}/${app_name}" "${macos_root}/${app_name}"

cat > "${contents_root}/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Apple Media Manager</string>
    <key>CFBundleExecutable</key>
    <string>${app_name}</string>
    <key>CFBundleIdentifier</key>
    <string>${bundle_identifier}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Apple Media Manager</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "Built ${app_root}"
