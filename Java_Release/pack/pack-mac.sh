#!/usr/bin/env bash
# macOS .dmg（jpackage，自带 JRE）。必须在 Mac 上跑。
# 用法：./pack/pack-mac.sh
# 产物：dist/*.dmg
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo ".dmg 只能在 macOS 上打（jpackage 不能跨平台打包）" >&2
  exit 1
fi

need jpackage
if [[ "${SKIP_JAR:-}" != 1 ]]; then
  "$PACK_DIR/pack-jar.sh"
elif [[ ! -f "$FAT_JAR" ]]; then
  "$PACK_DIR/pack-jar.sh"
fi

rm -rf "$JPACKAGE_INPUT"
mkdir -p "$JPACKAGE_INPUT"
cp -f "$FAT_JAR" "$JPACKAGE_INPUT/${APP_NAME}.jar"

echo "==> jpackage dmg"
rm -f "$DIST"/*.dmg

JPACKAGE_ARGS=(
  --type dmg
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

echo "OK  dist/ 下的 .dmg"
ls -1 "$DIST"/*.dmg
echo "未签名。本机打开若被拦，可右键打开或去系统设置放行。"
