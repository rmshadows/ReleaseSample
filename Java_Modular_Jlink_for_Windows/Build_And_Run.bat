call Head.bat

:: 编译
%SPECIFY_JDK_HOME%\javac --module-path %J_MODULE_PATH% --module-source-path %J_MODULE_SOURCE_PATH% -d %J_BIN_DERECTORY% -m %J_MODULE_NAME% -encoding UTF-8
:: 复制资源文件
:: cp -r $J_MODULE_RESOURCES_FILES/* $J_BIN_DERECTORY/$J_MODULE_NAME/
:: 运行
%SPECIFY_JDK_HOME%\java --module-path %J_BIN_DERECTORY%;%J_MODULE_PATH% -m %J_MODULE_NAME%/%J_MAIN_CLASS% %JVM_OPT%

