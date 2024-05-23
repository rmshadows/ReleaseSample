#!/bin/bash

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

# 输入应用程序包名
read -p "Enter package name of the app: " package_name

# 获取应用程序apk路径列表
apk_paths=$(adb shell pm path "$package_name" | grep "package:" | awk -F ':' '{print $NF}' | tr -d '\r')

# 如果未找到应用程序apk路径，则退出脚本
if [ -z "$apk_paths" ]; then
    echo "Apk path not found for package: $package_name"
    exit 1
fi

# 循环遍历每个路径并提取apk文件
for apk_path in $apk_paths; do
    # 去除路径前缀
    apk_path=${apk_path#*:}

    # 提取apk文件到当前目录
    apk_file=$(basename "$apk_path")
    adb pull "$apk_path" "./$apk_file"
    echo "Apk file saved as: $apk_file"
done
