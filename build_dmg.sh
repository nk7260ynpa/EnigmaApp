#!/bin/bash
# EnigmaApp DMG 建構腳本
# 建構 Release 版本並打包為 macOS DMG 安裝檔

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="EnigmaApp"
APP_DISPLAY_NAME="Enigma Machine Simulator"
APP_BUNDLE="${SCRIPT_DIR}/build/${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS}/MacOS"
RESOURCES_DIR="${CONTENTS}/Resources"
BUILD_DIR="${SCRIPT_DIR}/build"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}"
DMG_PATH="${BUILD_DIR}/${DMG_NAME}.dmg"
DMG_TEMP="${BUILD_DIR}/dmg_staging"

echo "=== 建構 ${APP_NAME} (Release) ==="
swift build --configuration release 2>&1

echo "=== 建立 .app bundle ==="
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 複製執行檔
cp "${SCRIPT_DIR}/.build/release/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"

# 建立 Info.plist
cat > "${CONTENTS}/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.enigmaapp.EnigmaApp</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_DISPLAY_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
PLIST

# 如果有 AppIcon.icns，複製到 Resources
if [[ -f "${SCRIPT_DIR}/AppIcon.icns" ]]; then
    cp "${SCRIPT_DIR}/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"
    echo "  已加入應用程式圖示"
fi

echo "=== 建立 DMG 安裝檔 ==="
# 清理暫存
rm -rf "${DMG_TEMP}" "${DMG_PATH}"
mkdir -p "${DMG_TEMP}"

# 複製 .app 到暫存目錄
cp -R "${APP_BUNDLE}" "${DMG_TEMP}/"

# 建立 Applications 捷徑（拖放安裝用）
ln -s /Applications "${DMG_TEMP}/Applications"

# 建立 DMG
hdiutil create \
    -volname "${APP_DISPLAY_NAME}" \
    -srcfolder "${DMG_TEMP}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"

# 清理暫存
rm -rf "${DMG_TEMP}"

echo ""
echo "=== 建構完成 ==="
echo "  .app: ${APP_BUNDLE}"
echo "  .dmg: ${DMG_PATH}"
echo "  大小: $(du -h "${DMG_PATH}" | cut -f1)"
echo ""
echo "使用者可開啟 DMG 後將 ${APP_NAME} 拖入 Applications 資料夾安裝。"
