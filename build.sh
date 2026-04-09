#!/bin/bash
# Сборка и установка StorageWidget
# Использование: ./build.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="StorageWidget"
SCHEME="StorageWidget"
CONFIG="Debug"
INSTALL_DIR="/Applications"

echo "=== Сборка $APP_NAME ==="
xcodebuild -project "$PROJECT_DIR/$APP_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    clean build 2>&1 | grep -E "(BUILD|error:)" | tail -10

# Находим собранный .app
BUILD_DIR=$(find ~/Library/Developer/Xcode/DerivedData/${APP_NAME}-* \
    -path "*/Build/Products/$CONFIG/$APP_NAME.app" -maxdepth 4 2>/dev/null | head -1)

if [ -z "$BUILD_DIR" ]; then
    echo "Ошибка: не найден собранный $APP_NAME.app"
    exit 1
fi

echo "=== Установка в $INSTALL_DIR ==="
rm -rf "$INSTALL_DIR/$APP_NAME.app"
cp -R "$BUILD_DIR" "$INSTALL_DIR/"

echo "=== Перезапуск виджета ==="
killall -9 widgetextensionhost 2>/dev/null || true
killall -9 chronod 2>/dev/null || true
killall Dock 2>/dev/null || true

echo "=== Запуск приложения ==="
open "$INSTALL_DIR/$APP_NAME.app"

echo ""
echo "Готово! Если виджет не обновился — удали его и добавь заново."
