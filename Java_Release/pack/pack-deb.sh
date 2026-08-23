#!/usr/bin/env bash
# 3/3  Linux .deb（jpackage，自带 JRE）
# 用法：./pack/pack-deb.sh
# 产物：dist/*.deb
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo ".deb 只能在 Linux 上打" >&2
  exit 1
fi

need jpackage
need fakeroot
need dpkg-deb

if [[ "${SKIP_JAR:-}" != 1 ]]; then
  "$PACK_DIR/pack-jar.sh"
elif [[ ! -f "$FAT_JAR" ]]; then
  "$PACK_DIR/pack-jar.sh"
fi

rm -rf "$JPACKAGE_INPUT"
mkdir -p "$JPACKAGE_INPUT"
cp -f "$FAT_JAR" "$JPACKAGE_INPUT/${APP_NAME}.jar"

echo "==> jpackage deb"
rm -f "$DIST"/"${LINUX_PACKAGE_NAME}"_*.deb "$DIST"/"${APP_NAME}"-*.deb

JPACKAGE_ARGS=(
  --type deb
  --name "$APP_NAME"
  --linux-package-name "$LINUX_PACKAGE_NAME"
  --app-version "$APP_VERSION"
  --vendor "$VENDOR"
  --description "$DESCRIPTION"
  --dest "$DIST"
  --input "$JPACKAGE_INPUT"
  --main-jar "${APP_NAME}.jar"
  --main-class "$MAIN_CLASS"
  --linux-shortcut
  --linux-menu-group "$LINUX_MENU_GROUP"
)
while IFS= read -r opt; do
  JPACKAGE_ARGS+=(--java-options "$opt")
done < <(jpackage_java_opts)
jpackage "${JPACKAGE_ARGS[@]}"

echo "OK  dist/ 下的 .deb"
ls -1 "$DIST"/*.deb
echo "安装：sudo dpkg -i dist/${LINUX_PACKAGE_NAME}_*.deb"
