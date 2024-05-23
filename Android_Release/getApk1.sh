#!/bin/bash

# 搜索应用程序名称
search_term="$1"

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

# 使用adb命令搜索应用程序名称并提取包名
package_name=$(adb shell pm list packages -f | grep -i "$search_term" | awk -F "=" '{print $1}' | awk -F ":" '{print $NF}')

# 如果未找到匹配的包名，则退出脚本
if [ -z "$package_name" ]; then
    echo "Package not found for search term: $search_term"
    exit 1
fi

echo "Package name for '$search_term' is: $package_name"

