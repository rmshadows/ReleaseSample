#!/bin/bash
### 所有脚本头文件
##

set -uex

# Default
# 模块依赖路径
J_MODULE_PATH="lib"
# 源代码
J_MODULE_SOURCE_PATH="src"
# 二进制文件路径
J_BIN_DERECTORY="bin"
# 模块资源
J_MODULE_RESOURCES_FILES="m_res"

# JAVA OPTIONS
# 指定JDK
SPECIFY_JDK_HOME="Application/jdk-16.0.2/bin"
#SPECIFY_JDK_HOME="C:\Java\jdk-16.0.2\bin"
# 模块名
J_MODULE_NAME=""
# Jlink模块主类
J_MAIN_CLASS=""
# Jlink启动文件名
J_LAUNCHER_NAME="launcher"
# Jlink添加模块
J_ADD_MODULES=""
# Jlink 导出名
J_EXPORT_NAME=""
# 模块JAR包
J_MODULE_JAR=""
# JVM 选项
JVM_OPT="-Djdk.gtk.version=2 -Dfile.encoding=UTF-8"


CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # warning color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"  

# echo like ...  with  flag type  and display message  colors
# -s 绿
# -e 红
# -w 黄
# -i 蓝
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;          # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;          # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;          # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;          # print info message
    *)
    echo -e "$@"
    ;;
  esac
}


