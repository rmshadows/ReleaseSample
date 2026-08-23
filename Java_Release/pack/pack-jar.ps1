# fat JAR：对方机器需要 Java 17+
# 用法：.\pack\pack-jar.ps1
# 产物：dist\<APP_NAME>.jar
$ErrorActionPreference = "Stop"
$PackDir = $PSScriptRoot
. (Join-Path $PackDir "common.ps1")

New-Item -ItemType Directory -Force -Path $DIST | Out-Null

if ($env:SKIP_JAR -eq "1" -and (Test-Path $FAT_JAR)) {
    Write-Host "跳过构建（已有 $FAT_JAR）"
    exit 0
}

switch ($BUILD_TOOL) {
    "mvn" {
        Need "mvn"
        Write-Host "==> Maven package"
        & mvn -q -DskipTests package
        if ($LASTEXITCODE -ne 0) { throw "mvn package 失败" }
    }
    "gradle" {
        Need "gradle"
        Write-Host "==> Gradle build"
        $Gradlew = Join-Path $Root "gradlew.bat"
        if (Test-Path $Gradlew) {
            & $Gradlew -q build -x test
        } else {
            & gradle -q build -x test
        }
        if ($LASTEXITCODE -ne 0) { throw "gradle build 失败" }
    }
    default {
        throw "未知 BUILD_TOOL：$BUILD_TOOL（支持 mvn | gradle）"
    }
}

if (-not (Test-Path $BUILT_JAR)) {
    throw "构建没有产出 $BUILT_JAR（请在 pack.conf 检查 BUILT_JAR_REL）"
}
Copy-Item -Force $BUILT_JAR $FAT_JAR
Write-Host "OK  $FAT_JAR"
Write-Host "运行：java -jar `"$FAT_JAR`""
