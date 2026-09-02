#!/usr/bin/env bash
# Windows .exe（jpackage）。Git Bash 备用；日常请用 pack-win.bat。
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) ;;
  *)
    echo ".exe 只能在 Windows 上打（jpackage 不能跨平台打包）" >&2
    exit 1
    ;;
esac

need jpackage
if [[ "${SKIP_JAR:-}" != 1 ]]; then
  "$PACK_DIR/pack-jar.sh"
elif [[ ! -f "$FAT_JAR" ]]; then
  "$PACK_DIR/pack-jar.sh"
fi

rm -rf "$JPACKAGE_INPUT"
mkdir -p "$JPACKAGE_INPUT"
cp -f "$FAT_JAR" "$JPACKAGE_INPUT/$JP_MAIN_JAR"

echo "==> jpackage exe"
rm -f "$DIST"/*.exe

ICON_JP=()
if [[ -f "$ICON_ICO" ]]; then
  ICON_JP=(--icon "$ICON_ICO")
else
  echo "警告：找不到 $ICON_ICO，.exe 将用默认 Java 图标" >&2
fi

if [[ ! -f "$JP_CONSOLE_PROPS" ]]; then
  echo "缺少 $JP_CONSOLE_PROPS" >&2
  exit 1
fi

jpackage \
  --type exe \
  --name "$APP_NAME" \
  --app-version "$APP_VERSION" \
  --vendor "$VENDOR" \
  --description "$APP_DESCRIPTION" \
  --dest "$DIST" \
  --input "$JPACKAGE_INPUT" \
  --main-jar "$JP_MAIN_JAR" \
  --main-class "$MAIN_CLASS" \
  --add-modules "$JP_MODULES" \
  --add-launcher "${CONSOLE_LAUNCHER}=${JP_CONSOLE_PROPS}" \
  --win-shortcut \
  --win-menu \
  "${ICON_JP[@]}" \
  --java-options "$JAVA_OPTIONS"

echo "OK  dist/ 下的 .exe"
ls -1 "$DIST"/*.exe
