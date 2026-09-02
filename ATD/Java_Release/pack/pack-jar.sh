#!/usr/bin/env bash
# 1/3  fat JAR：对方机器需要 Java 17+
# 用法：./pack/pack-jar.sh
# 产物：dist/<APP_NAME>.jar
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

mkdir -p "$DIST"

if [[ "${SKIP_JAR:-}" == 1 && -f "$FAT_JAR" ]]; then
  echo "跳过构建（已有 $FAT_JAR）"
  exit 0
fi

case "$BUILD_TOOL" in
  mvn)
    need mvn
    echo "==> Maven package"
    mvn -q -DskipTests package
    ;;
  gradle)
    need gradle
    echo "==> Gradle build"
    if [[ -f "$ROOT/gradlew" ]]; then
      "$ROOT/gradlew" -q build -x test
    else
      gradle -q build -x test
    fi
    ;;
  *)
    echo "未知 BUILD_TOOL：$BUILD_TOOL（支持 mvn | gradle）" >&2
    exit 1
    ;;
esac

if [[ ! -f "$BUILT_JAR" ]]; then
  echo "构建没有产出 $BUILT_JAR（请在 pack.conf 检查 BUILT_JAR_REL）" >&2
  exit 1
fi
cp -f "$BUILT_JAR" "$FAT_JAR"
echo "OK  $FAT_JAR"
echo "运行：java -jar \"$FAT_JAR\""
