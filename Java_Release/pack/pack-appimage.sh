#!/usr/bin/env bash
# 2/3  绿色目录：自带精简 JRE，解压即用（jpackage app-image，不是 Linux .AppImage 单文件）
# 用法：./pack/pack-appimage.sh
# 产物：dist/<APP_NAME>/（或 macOS 的 <APP_NAME>.app）以及 dist/<APP_NAME>-<version>-<os>.tar.gz
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

need jpackage
if [[ "${SKIP_JAR:-}" != 1 ]]; then
  "$PACK_DIR/pack-jar.sh"
elif [[ ! -f "$FAT_JAR" ]]; then
  "$PACK_DIR/pack-jar.sh"
fi

rm -rf "$JPACKAGE_INPUT" "$DIST/$APP_NAME" "$DIST/$APP_NAME.app"
mkdir -p "$JPACKAGE_INPUT"
cp -f "$FAT_JAR" "$JPACKAGE_INPUT/${APP_NAME}.jar"

OS="$(uname -s)"
case "$OS" in
  Linux*)             TAG="linux-x64" ;;
  Darwin*)            TAG="mac" ;;
  MINGW*|MSYS*|CYGWIN*) TAG="win-x64" ;;
  *)                  TAG="unknown" ;;
esac

echo "==> jpackage app-image"
JPACKAGE_ARGS=(
  --type app-image
  --name "$APP_NAME"
  --app-version "$APP_VERSION"
  --vendor "$VENDOR"
  --description "$DESCRIPTION"
  --dest "$DIST"
  --input "$JPACKAGE_INPUT"
  --main-jar "${APP_NAME}.jar"
  --main-class "$MAIN_CLASS"
)
while IFS= read -r opt; do
  JPACKAGE_ARGS+=(--java-options "$opt")
done < <(jpackage_java_opts)
jpackage "${JPACKAGE_ARGS[@]}"

ARCHIVE="$DIST/${APP_NAME}-${VERSION}-${TAG}.tar.gz"
rm -f "$ARCHIVE"
if [[ -d "$DIST/$APP_NAME.app" ]]; then
  tar -C "$DIST" -czf "$ARCHIVE" "$APP_NAME.app"
  echo "OK  $DIST/$APP_NAME.app"
else
  tar -C "$DIST" -czf "$ARCHIVE" "$APP_NAME"
  echo "OK  $DIST/$APP_NAME/"
  echo "启动：$DIST/$APP_NAME/bin/$APP_NAME"
fi
echo "OK  $ARCHIVE"
