#!/bin/bash
# 由Android生成的AAB文件转为APKS文件
source Android_Head.sh

java -jar $BundleToolPath build-apks --bundle=$AAB_Path --output=$ApksPath --ks=$Jks_Path --ks-pass=pass:$Jks_ks_pass --ks-key-alias=$Jks_Alias --key-pass=pass:$Jks_key_pass
