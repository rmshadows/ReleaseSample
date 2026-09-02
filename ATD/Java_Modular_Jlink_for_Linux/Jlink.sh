#!/bin/bash
### 用于初始化模块化文件夹
##

source Head.sh

# 编译
# javac --module-path $J_MODULE_PATH --module-source-path $J_MODULE_SOURCE_PATH -d $J_BIN_DERECTORY -m $J_MODULE_NAME -encoding UTF-8

# JLink打包
$SPECIFY_JDK_HOME/jlink --launcher $J_LAUNCHER_NAME=$J_MODULE_NAME/$J_MAIN_CLASS --module-path $J_BIN_DERECTORY:$J_MODULE_PATH --add-modules $J_ADD_MODULES --output $J_EXPORT_NAME

