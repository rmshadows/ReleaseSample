# 被其它 .ps1 dot-source。默认目录：Java 项目根（pack\ 的上一级）
$ErrorActionPreference = "Stop"

if (-not $PackDir) {
    $PackDir = $PSScriptRoot
}

$ConfPath = Join-Path $PackDir "pack.conf"
if (Test-Path $ConfPath) {
    Get-Content $ConfPath | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^\s*#' -or $line -eq '') { return }
        if ($line -match '^([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
            $name = $Matches[1]
            $value = $Matches[2].Trim()
            if ($value.StartsWith('"') -and $value.EndsWith('"')) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            Set-Variable -Name $name -Value $value -Scope Script
        }
    }
}

if ($PROJECT_ROOT) {
    $Root = (Resolve-Path $PROJECT_ROOT).Path
} else {
    $Root = (Resolve-Path (Join-Path $PackDir "..")).Path
}
Set-Location $Root

if (-not $APP_NAME) { $APP_NAME = "MyApp" }
if (-not $VENDOR) { $VENDOR = "MyVendor" }
if (-not $DESCRIPTION) { $DESCRIPTION = "My Java Application" }
if (-not $MAIN_JAVA) { $MAIN_JAVA = "src/main/java/application/Main.java" }
if (-not $MAIN_CLASS) { $MAIN_CLASS = "application.Main" }
if (-not $BUILD_TOOL) { $BUILD_TOOL = "mvn" }
if (-not $BUILT_JAR_REL) { $BUILT_JAR_REL = "target/$APP_NAME.jar" }
if (-not $LINUX_PACKAGE_NAME) { $LINUX_PACKAGE_NAME = "myapp" }
if (-not $LINUX_MENU_GROUP) { $LINUX_MENU_GROUP = "Utility" }
if (-not $JAVA_OPTS_EXTRA) { $JAVA_OPTS_EXTRA = "" }

$MainJavaPath = Join-Path $Root ($MAIN_JAVA -replace '/', '\')
if (-not (Test-Path $MainJavaPath)) {
    throw "找不到 $MainJavaPath（请在 pack\pack.conf 里设置 MAIN_JAVA）"
}

if (-not $VERSION_OVERRIDE) {
    $m = [regex]::Match((Get-Content -Raw $MainJavaPath), 'VERSION = "([^"]+)"')
    if (-not $m.Success) {
        throw "读不到 VERSION（在 $MAIN_JAVA 写 VERSION = `"x.y.z`"，或在 pack.conf 设 VERSION_OVERRIDE）"
    }
    $VERSION = $m.Groups[1].Value
} else {
    $VERSION = $VERSION_OVERRIDE
}
$APP_VERSION = ($VERSION -split "-", 2)[0]

$DIST = Join-Path $Root "dist"
$JPACKAGE_INPUT = Join-Path $DIST "jpackage-input"
$FAT_JAR = Join-Path $DIST "$APP_NAME.jar"
$BUILT_JAR = Join-Path $Root ($BUILT_JAR_REL -replace '/', '\')

function Need([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "缺少命令：$Name（请把 JDK 17+ 和构建工具加到 PATH）"
    }
}

function Get-JpackageJavaOpts {
    $opts = @("-Dfile.encoding=UTF-8")
    if ($JAVA_OPTS_EXTRA) {
        $opts += $JAVA_OPTS_EXTRA
    }
    return $opts
}

Write-Host "$APP_NAME $VERSION  (app-version $APP_VERSION)"
Write-Host "项目目录 $Root"
