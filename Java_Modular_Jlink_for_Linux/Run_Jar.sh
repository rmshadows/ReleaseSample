#!/bin/bash
### 用于初始化模块化文件夹
##

source Head.sh

# 运行jar模块文件 
$SPECIFY_JDK_HOME/java -jar --module-path .:$J_MODULE_PATH -m $J_MODULE_NAME/$J_MAIN_CLASS $J_MODULE_JAR $JVM_OPT
