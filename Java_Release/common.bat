@echo off
REM Shared by other .bat scripts. Project root = parent of this folder (pack or pack2).
REM Do not use setlocal here: cmd undoes cd on endlocal.

set "PACK_DIR=%~dp0"
if "%PACK_DIR:~-1%"=="\" set "PACK_DIR=%PACK_DIR:~0,-1%"
for %%I in ("%PACK_DIR%\..") do set "ROOT=%%~fI"
cd /d "%ROOT%" || exit /b 1

set "CONF=%PACK_DIR%\app.conf"
if not exist "%CONF%" (
  echo Missing %CONF%
  echo Copy %PACK_DIR%\app.conf.example to app.conf and set APP_NAME / MAIN_CLASS / MAVEN_JAR
  exit /b 1
)

set "APP_NAME="
set "MAIN_CLASS="
set "MAVEN_JAR="
set "VENDOR="
set "APP_DESCRIPTION="
set "VERSION="
set "VERSION_JAVA="
set "LINUX_PKG_NAME="
set "ICON_PNG=other\icon.png"
set "ICON_ICO=other\icon.ico"
set "ICON_ICNS=other\icon.icns"
set "JP_MODULES=java.base,java.desktop,java.datatransfer,java.prefs,jdk.charsets"
set "JAVA_OPTIONS=-Dfile.encoding=UTF-8"
set "MENU_GROUP=Utility"

for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%CONF%") do (
  if not "%%A"=="" set "%%A=%%B"
)

if not defined APP_NAME (
  echo app.conf needs APP_NAME
  exit /b 1
)
if not defined MAIN_CLASS (
  echo app.conf needs MAIN_CLASS
  exit /b 1
)
if not defined MAVEN_JAR (
  echo app.conf needs MAVEN_JAR
  exit /b 1
)

if not defined VERSION if defined VERSION_JAVA if exist "%ROOT%\%VERSION_JAVA%" (
  for /f "tokens=2 delims==" %%a in ('findstr /C:"VERSION = " "%ROOT%\%VERSION_JAVA%"') do set "_VER=%%a"
  if defined _VER (
    set "VERSION=%_VER: =%"
    set "VERSION=%VERSION:"=%"
    set "VERSION=%VERSION:;=%"
    set "_VER="
  )
)

if not defined VERSION if exist "%ROOT%\pom.xml" (
  for /f "usebackq delims=" %%v in (`powershell -NoProfile -Command "$t=Get-Content -Raw '%ROOT%\pom.xml'; $t=$t -replace '(?s)<parent>.*?</parent>',''; if($t -match '<version>\s*([^<]+)\s*</version>'){$Matches[1].Trim()}"`) do set "VERSION=%%v"
)

if not defined VERSION (
  echo Cannot read version. Set VERSION= or VERSION_JAVA= in app.conf, or put <version> in pom.xml
  exit /b 1
)

for /f "tokens=1 delims=-" %%a in ("%VERSION%") do set "APP_VERSION=%%a"

if not defined VENDOR set "VENDOR=%APP_NAME%"
if not defined APP_DESCRIPTION set "APP_DESCRIPTION=%APP_NAME%"
if not defined LINUX_PKG_NAME set "LINUX_PKG_NAME=%APP_NAME%"

set "DIST=%ROOT%\dist"
set "JPACKAGE_INPUT=%DIST%\jpackage-input"
set "FAT_JAR=%DIST%\%APP_NAME%_%VERSION%.jar"
if "%MAVEN_JAR:~1,1%"==":" (
  rem absolute Windows path
) else (
  set "MAVEN_JAR=%ROOT%\%MAVEN_JAR%"
)
if not "%ICON_PNG:~1,1%"==":" set "ICON_PNG=%ROOT%\%ICON_PNG%"
if not "%ICON_ICO:~1,1%"==":" set "ICON_ICO=%ROOT%\%ICON_ICO%"
if not "%ICON_ICNS:~1,1%"==":" set "ICON_ICNS=%ROOT%\%ICON_ICNS%"
set "JP_MAIN_JAR=%APP_NAME%.jar"
set "CONSOLE_LAUNCHER=%APP_NAME%-console"
set "JP_CONSOLE_PROPS=%PACK_DIR%\win-console.properties"

echo %APP_NAME% %VERSION%  app-version %APP_VERSION%
echo Root %ROOT%
echo Conf %CONF%
