#!/usr/bin/env bash
# 一键：JAR + 绿色目录（jpackage app-image）+ 本平台安装包
# Linux → .deb；macOS → .dmg；Windows 请用 pack.bat
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

"$PACK_DIR/pack-jar.sh"
export SKIP_JAR=1
"$PACK_DIR/pack-appimage.sh"

OS="$(uname -s)"
case "$OS" in
  Linux)
    "$PACK_DIR/pack-deb.sh"
    ;;
  Darwin)
    "$PACK_DIR/pack-mac.sh"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    "$PACK_DIR/pack-win.sh"
    ;;
  *)
    echo "本平台没有系统安装包脚本（只出了 JAR 和绿色目录）"
    ;;
esac

echo
echo "==> 完成，产物在 $DIST"
ls -1 "$DIST" | sed 's/^/  /'
if [[ -x "$DIST/$APP_NAME/bin/${CONSOLE_LAUNCHER}" ]]; then
  echo
  echo "日常：$DIST/$APP_NAME/bin/$APP_NAME"
  echo "调试：$DIST/$APP_NAME/bin/$CONSOLE_LAUNCHER"
elif [[ -x "$DIST/${APP_NAME}.app/Contents/MacOS/${CONSOLE_LAUNCHER}" ]]; then
  echo
  echo "日常：$DIST/${APP_NAME}.app"
  echo "调试：$DIST/${APP_NAME}.app/Contents/MacOS/$CONSOLE_LAUNCHER"
fi
