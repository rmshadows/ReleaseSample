call Head.bat

::exe
::%SPECIFY_JDK_HOME%\jpackage -n %J_MODULE_NAME% -p %J_BIN_DERECTORY%;%J_MODULE_PATH% -m %J_MODULE_NAME%/%J_MAIN_CLASS% --type exe --java-options %JVM_OPT%

::ap-image
%SPECIFY_JDK_HOME%\jpackage -n %J_MODULE_NAME% -p %J_BIN_DERECTORY%;%J_MODULE_PATH% -m %J_MODULE_NAME%/%J_MAIN_CLASS% --type app-image --java-options %JVM_OPT%

::$SPECIFY_JDK_HOME/jpackage -n name --runtime-image <runtime-image>

