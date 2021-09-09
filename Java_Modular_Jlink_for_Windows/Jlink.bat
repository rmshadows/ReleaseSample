call Head.bat

# JLink打包
%SPECIFY_JDK_HOME%\jlink --launcher %J_LAUNCHER_NAME%=%J_MODULE_NAME%/%J_MAIN_CLASS% --module-path %J_BIN_DERECTORY%;%J_MODULE_PATH% --add-modules %J_ADD_MODULES% --output %J_EXPORT_NAME%
