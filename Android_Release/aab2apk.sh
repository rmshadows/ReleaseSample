#!/bin/bash

source Android_Head.sh

UniversalApksPath="${ApksPath%.apks}-universal.apks"
ApkPath="${ApksPath%.apks}.apk"

java -jar "$BundleToolPath" build-apks \
  --bundle="$AAB_Path" \
  --output="$UniversalApksPath" \
  --mode=universal \
  --ks="$Jks_Path" \
  --ks-pass="pass:$Jks_ks_pass" \
  --ks-key-alias="$Jks_Alias" \
  --key-pass="pass:$Jks_key_pass"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

unzip -q "$UniversalApksPath" -d "$tmp_dir"
mv "$tmp_dir/universal.apk" "$ApkPath"

echo "Universal APK: $ApkPath"
