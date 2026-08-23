#!/usr/bin/env bash
# 被打包脚本 source。默认目录：Java 项目根（pack/ 的上一级）
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$PACK_DIR/pack.conf" ]]; then
  # shellcheck source=pack.conf
  source "$PACK_DIR/pack.conf"
fi

if [[ -n "${PROJECT_ROOT:-}" ]]; then
  ROOT="$(cd "$PROJECT_ROOT" && pwd)"
else
  ROOT="$(cd "$PACK_DIR/.." && pwd)"
fi
cd "$ROOT"

: "${APP_NAME:=MyApp}"
: "${VENDOR:=MyVendor}"
: "${DESCRIPTION:=My Java Application}"
: "${MAIN_JAVA:=src/main/java/application/Main.java}"
: "${MAIN_CLASS:=application.Main}"
: "${BUILD_TOOL:=mvn}"
: "${BUILT_JAR_REL:=target/${APP_NAME}.jar}"
: "${LINUX_PACKAGE_NAME:=myapp}"
: "${LINUX_MENU_GROUP:=Utility}"
: "${JAVA_OPTS_EXTRA:=}"

if [[ ! -f "$MAIN_JAVA" ]]; then
  echo "找不到 $MAIN_JAVA（请在 pack/pack.conf 里设置 MAIN_JAVA）" >&2
  exit 1
fi

if [[ -z "${VERSION_OVERRIDE:-}" ]]; then
  VERSION="$(sed -n 's/.*VERSION = "\([^"]*\)".*/\1/p' "$MAIN_JAVA" | head -1)"
  if [[ -z "$VERSION" ]]; then
    echo "读不到 VERSION（在 $MAIN_JAVA 写 VERSION = \"x.y.z\"，或在 pack.conf 设 VERSION_OVERRIDE）" >&2
    exit 1
  fi
else
  VERSION="$VERSION_OVERRIDE"
fi
# jpackage / deb 只要数字版本
APP_VERSION="${VERSION%%-*}"

DIST="$ROOT/dist"
JPACKAGE_INPUT="$DIST/jpackage-input"
FAT_JAR="$DIST/${APP_NAME}.jar"
BUILT_JAR="$ROOT/$BUILT_JAR_REL"

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "缺少命令：$1" >&2
    exit 1
  fi
}

jpackage_java_opts() {
  echo "-Dfile.encoding=UTF-8"
  if [[ -n "$JAVA_OPTS_EXTRA" ]]; then
    echo "$JAVA_OPTS_EXTRA"
  fi
}

echo "$APP_NAME $VERSION  (app-version $APP_VERSION)"
echo "项目目录 $ROOT"
