#!/usr/bin/env bash
# Windows .exe（jpackage，自带 JRE）。Git Bash 备用；日常请用 pack-win.ps1。
# 用法：./pack/pack-win.sh
# 产物：dist/*.exe
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
cp -f "$FAT_JAR" "$JPACKAGE_INPUT/${APP_NAME}.jar"

echo "==> jpackage exe"
rm -f "$DIST"/*.exe

JPACKAGE_ARGS=(
  --type exe
  --name "$APP_NAME"
  --app-version "$APP_VERSION"
  --vendor "$VENDOR"
  --description "$DESCRIPTION"
  --dest "$DIST"
  --input "$JPACKAGE_INPUT"
  --main-jar "${APP_NAME}.jar"
  --main-class "$MAIN_CLASS"
  --win-shortcut
  --win-menu
)
while IFS= read -r opt; do
  JPACKAGE_ARGS+=(--java-options "$opt")
done < <(jpackage_java_opts)
jpackage "${JPACKAGE_ARGS[@]}"

echo "OK  dist/ 下的 .exe"
ls -1 "$DIST"/*.exe
