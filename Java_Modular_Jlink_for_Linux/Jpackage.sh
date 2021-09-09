#!/bin/bash
### 用于初始化模块化文件夹
##

source Head.sh

# JPackage打包
$SPECIFY_JDK_HOME/jpackage -n $J_MODULE_NAME -p $J_BIN_DERECTORY:$J_MODULE_PATH -m $J_MODULE_NAME/$J_MAIN_CLASS --type app-image --java-options $JVM_OPT

# --launcher $J_LAUNCHER_NAME=$J_MODULE_NAME/$J_MAIN_CLASS

$SPECIFY_JDK_HOME/jpackage -n name --runtime-image <runtime-image>
