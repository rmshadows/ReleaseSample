call Head.bat

::set javac=%SPECIFY_JDK_HOME:~1,-1%/javac
%SPECIFY_JDK_HOME%\javac --module-path %J_MODULE_PATH% --module-source-path %J_MODULE_SOURCE_PATH% -d %J_BIN_DERECTORY% -m %J_MODULE_NAME% -encoding UTF-8

