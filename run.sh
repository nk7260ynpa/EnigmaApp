#!/bin/bash
# EnigmaApp 啟動腳本
# 建構 Swift Package 並包裝為 macOS .app bundle 執行

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="EnigmaApp"
APP_BUNDLE="${SCRIPT_DIR}/${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS}/MacOS"

echo "=== 建構 ${APP_NAME} ==="
swift build --configuration release 2>&1

echo "=== 建立 .app bundle ==="
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"

# 複製執行檔
cp "${SCRIPT_DIR}/.build/release/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"

# 建立 Info.plist
cat > "${CONTENTS}/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>EnigmaApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.enigmaapp.EnigmaApp</string>
    <key>CFBundleName</key>
    <string>EnigmaApp</string>
    <key>CFBundleDisplayName</key>
    <string>Enigma Machine Simulator</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
PLIST

echo "=== 啟動 ${APP_NAME} ==="
open "${APP_BUNDLE}"
