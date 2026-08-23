# 绿色目录：自带精简 JRE（jpackage app-image，不是 Linux .AppImage）
# 用法：.\pack\pack-appimage.ps1
# 产物：dist\<APP_NAME>\  以及 dist\<APP_NAME>-<version>-win-x64.zip
$ErrorActionPreference = "Stop"
$PackDir = $PSScriptRoot
. (Join-Path $PackDir "common.ps1")

Need "jpackage"
if ($env:SKIP_JAR -ne "1" -or -not (Test-Path $FAT_JAR)) {
    & (Join-Path $PackDir "pack-jar.ps1")
}

foreach ($p in @($JPACKAGE_INPUT, (Join-Path $DIST $APP_NAME))) {
    if (Test-Path $p) { Remove-Item -Recurse -Force $p }
}
New-Item -ItemType Directory -Force -Path $JPACKAGE_INPUT | Out-Null
Copy-Item -Force $FAT_JAR (Join-Path $JPACKAGE_INPUT "$APP_NAME.jar")

Write-Host "==> jpackage app-image"
$jpackageArgs = @(
    "--type", "app-image",
    "--name", $APP_NAME,
    "--app-version", $APP_VERSION,
    "--vendor", $VENDOR,
    "--description", $DESCRIPTION,
    "--dest", $DIST,
    "--input", $JPACKAGE_INPUT,
    "--main-jar", "$APP_NAME.jar",
    "--main-class", $MAIN_CLASS
)
foreach ($opt in (Get-JpackageJavaOpts)) {
    $jpackageArgs += @("--java-options", $opt)
}
& jpackage @jpackageArgs
if ($LASTEXITCODE -ne 0) { throw "jpackage app-image 失败" }

$Archive = Join-Path $DIST "$APP_NAME-$VERSION-win-x64.zip"
if (Test-Path $Archive) { Remove-Item -Force $Archive }
Compress-Archive -Path (Join-Path $DIST $APP_NAME) -DestinationPath $Archive
Write-Host "OK  $(Join-Path $DIST $APP_NAME)"
Write-Host "启动：$(Join-Path $DIST "$APP_NAME\$APP_NAME.exe")"
Write-Host "OK  $Archive"
