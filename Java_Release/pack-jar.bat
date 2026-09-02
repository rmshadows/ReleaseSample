@echo off
REM Runnable JAR. Target machine needs a matching JDK.
setlocal EnableExtensions

call "%~dp0common.bat" || exit /b 1

where mvn >nul 2>&1
if errorlevel 1 (
  echo Missing mvn. Add Maven to PATH.
  exit /b 1
)

if not exist "%DIST%" mkdir "%DIST%"

if "%SKIP_JAR%"=="1" if exist "%FAT_JAR%" (
  echo Skip Maven, jar exists: %FAT_JAR%
  exit /b 0
)

echo ==^> Maven package
call mvn -q -DskipTests -f "%ROOT%\pom.xml" package
if errorlevel 1 (
  echo mvn package failed
  exit /b 1
)

if not exist "%MAVEN_JAR%" (
  echo Missing %MAVEN_JAR% after Maven build
  echo Check MAVEN_JAR in app.conf
  exit /b 1
)

copy /Y "%MAVEN_JAR%" "%FAT_JAR%" >nul

echo OK %FAT_JAR%
echo Run: java -jar "%FAT_JAR%"

endlocal
