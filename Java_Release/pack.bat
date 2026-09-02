@echo off
REM One-click Windows pack: JAR + portable dir + .exe installer (WiX 3)
REM For WiX 4/5 (JDK 24+): pack-win-wix5.bat
setlocal EnableExtensions

call "%~dp0common.bat" || exit /b 1

if /i not "%OS%"=="Windows_NT" (
  echo pack.bat is for Windows. On Linux or macOS use pack.sh
  exit /b 1
)

call "%~dp0pack-jar.bat" || exit /b 1
set SKIP_JAR=1
call "%~dp0pack-appimage.bat" || exit /b 1
call "%~dp0pack-win.bat"
if errorlevel 1 (
  echo.
  echo Warning: .exe installer skipped. JAR and portable zip are in %DIST%
)

echo.
echo ==^> Done. Output in %DIST%:
dir /b "%DIST%"
if exist "%DIST%\%APP_NAME%\%CONSOLE_LAUNCHER%.exe" (
  echo.
  echo Daily:   "%DIST%\%APP_NAME%\%APP_NAME%.exe"
  echo Debug:   "%DIST%\%APP_NAME%\%CONSOLE_LAUNCHER%.exe"
)

endlocal
