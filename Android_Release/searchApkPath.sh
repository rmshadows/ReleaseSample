#!/bin/bash

# 输入要搜索的应用程序包名
read -p "Enter package name of the app: " package_name

# 获取设备列表
devices=$(adb devices | grep -v "List of devices attached" | awk '{print $1}')

# 如果设备未连接，则退出脚本
if [ -z "$devices" ]; then
    echo "No device found. Please connect your device."
    exit 1
fi

# 打印设备列表
echo "Devices found:"
echo "$devices"

# 选择一个设备
if [ $(echo "$devices" | wc -l) -gt 1 ]; then
    echo "Multiple devices found. Please select a device:"
    select device in $devices; do
        if [ -n "$device" ]; then
            break
        else
            echo "Invalid option. Please try again."
        fi
    done
else
    device="$devices"
fi

# 使用adb shell pm path命令获取应用程序的apk路径
apk_path=$(adb shell pm path "$package_name" | grep "package:" | awk -F ":" '{print $NF}' | tr -d '\r')

# 如果未找到匹配的包名，则退出脚本
if [ -z "$apk_path" ]; then
    echo "Apk path not found for package: $package_name"
    exit 1
fi

echo "Apk path for '$package_name' is: $apk_path"

