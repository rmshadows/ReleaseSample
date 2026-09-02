#!/bin/bash
### 用于初始化模块化文件夹
##

source Head.sh

# 编译
$SPECIFY_JDK_HOME/javac --module-path $J_MODULE_PATH --module-source-path $J_MODULE_SOURCE_PATH -d $J_BIN_DERECTORY -m $J_MODULE_NAME -encoding UTF-8

