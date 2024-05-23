#!/bin/bash
# 将生成的APKS安装到手机

source Android_Head.sh
java -jar $BundleToolPath install-apks --apks=$ApksPath
# java -jar $BundleToolPath install-apks --apks=$ApksPath --adb ~/Android/Sdk/platform-tools/adb
