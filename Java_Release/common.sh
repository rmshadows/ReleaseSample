#!/usr/bin/env bash
# 被打包脚本 source。项目根 = 本文件夹的上一级（文件夹叫 pack / pack2 都行）。
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$PACK_DIR/.." && pwd)"
cd "$ROOT"

CONF="$PACK_DIR/app.conf"
if [[ ! -f "$CONF" ]]; then
  echo "找不到 $CONF" >&2
  echo "请复制 $PACK_DIR/app.conf.example 为 app.conf 并填写 APP_NAME / MAIN_CLASS / MAVEN_JAR" >&2
  exit 1
fi

APP_NAME=""
MAIN_CLASS=""
MAVEN_JAR=""
VENDOR=""
APP_DESCRIPTION=""
VERSION=""
VERSION_JAVA=""
LINUX_PKG_NAME=""
ICON_PNG="other/icon.png"
ICON_ICO="other/icon.ico"
ICON_ICNS="other/icon.icns"
JP_MODULES="java.base,java.desktop,java.datatransfer,java.prefs,jdk.charsets"
JAVA_OPTIONS="-Dfile.encoding=UTF-8"
MENU_GROUP="Utility"

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%$'\r'}"
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line//[[:space:]]/}" ]] && continue
  if [[ "$line" != *=* ]]; then
    echo "app.conf 无法解析：$line" >&2
    exit 1
  fi
  key="${line%%=*}"
  val="${line#*=}"
  key="${key%"${key##*[![:space:]]}"}"
  key="${key#"${key%%[![:space:]]*}"}"
  case "$key" in
    APP_NAME|MAIN_CLASS|MAVEN_JAR|VENDOR|APP_DESCRIPTION|VERSION|VERSION_JAVA|LINUX_PKG_NAME|ICON_PNG|ICON_ICO|ICON_ICNS|JP_MODULES|JAVA_OPTIONS|MENU_GROUP)
      printf -v "$key" '%s' "$val"
      ;;
    *)
      echo "app.conf 未知项：$key" >&2
      exit 1
      ;;
  esac
done < "$CONF"

if [[ -z "$APP_NAME" || -z "$MAIN_CLASS" || -z "$MAVEN_JAR" ]]; then
  echo "app.conf 必填：APP_NAME、MAIN_CLASS、MAVEN_JAR" >&2
  exit 1
fi
if [[ "$APP_NAME" == *" "* ]]; then
  echo "APP_NAME 不要含空格（jpackage --name 会出问题）" >&2
  exit 1
fi

abs_under_root() {
  local p="$1"
  if [[ -z "$p" ]]; then
    echo ""
    return
  fi
  if [[ "$p" = /* ]]; then
    echo "$p"
  else
    echo "$ROOT/$p"
  fi
}

read_version_from_java() {
  sed -n 's/.*VERSION = "\([^"]*\)".*/\1/p' "$1" | head -1
}

read_version_from_pom() {
  if [[ ! -f "$ROOT/pom.xml" ]]; then
    return
  fi
  awk '
    /<parent>/ { p=1 }
    /<\/parent>/ { p=0; next }
    p { next }
    /<version>/ {
      sub(/.*<version>/, "")
      sub(/<\/version>.*/, "")
      gsub(/^[ \t]+|[ \t]+$/, "")
      print
      exit
    }
  ' "$ROOT/pom.xml"
}

if [[ -z "$VERSION" && -n "$VERSION_JAVA" ]]; then
  VFILE="$(abs_under_root "$VERSION_JAVA")"
  if [[ ! -f "$VFILE" ]]; then
    echo "找不到 VERSION_JAVA：$VFILE" >&2
    exit 1
  fi
  VERSION="$(read_version_from_java "$VFILE")"
fi
if [[ -z "$VERSION" ]]; then
  VERSION="$(read_version_from_pom || true)"
fi
if [[ -z "$VERSION" ]]; then
  echo "读不到版本：请在 app.conf 写 VERSION=，或 VERSION_JAVA=，或保证 pom.xml 有项目 <version>" >&2
  exit 1
fi

APP_VERSION="${VERSION%%-*}"
if [[ -z "$VENDOR" ]]; then
  VENDOR="$APP_NAME"
fi
if [[ -z "$APP_DESCRIPTION" ]]; then
  APP_DESCRIPTION="$APP_NAME"
fi
if [[ -z "$LINUX_PKG_NAME" ]]; then
  LINUX_PKG_NAME="$(printf '%s' "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9+-.')"
fi

DIST="$ROOT/dist"
JPACKAGE_INPUT="$DIST/jpackage-input"
FAT_JAR="$DIST/${APP_NAME}_${VERSION}.jar"
MAVEN_JAR="$(abs_under_root "$MAVEN_JAR")"
ICON_PNG="$(abs_under_root "$ICON_PNG")"
ICON_ICO="$(abs_under_root "$ICON_ICO")"
ICON_ICNS="$(abs_under_root "$ICON_ICNS")"
JP_MAIN_JAR="${APP_NAME}.jar"
CONSOLE_LAUNCHER="${APP_NAME}-console"
DESKTOP_TEMPLATE="$PACK_DIR/jpackage-resources/app.desktop"
CONTROL_COMPAT="$PACK_DIR/jpackage-resources/control"

case "$(uname -s)" in
  Darwin*) JP_CONSOLE_PROPS="$PACK_DIR/mac-console.properties" ;;
  *)       JP_CONSOLE_PROPS="$PACK_DIR/linux-console.properties" ;;
esac

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "缺少命令：$1" >&2
    exit 1
  fi
}

fill_desktop() {
  local dest="$1"
  sed \
    -e "s#@APP_NAME@#${APP_NAME}#g" \
    -e "s#@APP_DESCRIPTION@#${APP_DESCRIPTION}#g" \
    -e "s#@LINUX_PKG_NAME@#${LINUX_PKG_NAME}#g" \
    -e "s#@MENU_GROUP@#${MENU_GROUP}#g" \
    "$DESKTOP_TEMPLATE" > "$dest"
}

echo "$APP_NAME $VERSION  (app-version $APP_VERSION)"
echo "项目目录 $ROOT"
echo "配置 $CONF"
