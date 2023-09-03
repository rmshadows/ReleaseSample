# ReleaseSample
我的Java、Android应用发布模板

## 目录结构

1. Android_Release——发布Android应用（Linux Only）
2. Java_Modular_Jlink_for_Linux——Java模块化Jlink（不支持AutoModules not support ！）
3. Java_Modular_Jlink_for_Windows——Java模块化Jlink（不支持AutoModules not support ！）
4. Java-NonModular-Gradle——Java非模块化打包（不支持模块化应用，有自动模块的可以删除`module-info.java`转为非模块化应用后导出）

## 发布说明

### Android_Release

#### 准备

AAB文件：Android生成的Android App Bundle

Bundle-tool：[Google Bundle项目地址](https://github.com/google/bundletool) | [Jar包发布地址](https://github.com/google/bundletool/releases)

其他: ADB、手机等

#### 流程

AAB -> APKS ->安装到手机 ->APK

### Java_Modular_Jlink_for_Linux

#### 准备

源代码、项目依赖、资源文件、Java11+（Jpackage需要Java14+）

注意，依赖不能有自动模块！

#### 流程

源代码->添加依赖->编译->试运行->打包Jlink

### Java_Modular_Jlink_for_Windows

与Linux类似，只不过windows这里的`Head.bat`要求不能有引号“”。

### Java-NonModular-Gradle

#### 准备

原代码、Gradle、badass gradle plugin

#### 流程

源代码->Gradle build->Gradle run->Gradle runtime

# 更新日志

- 2021.09.09——0.0.1
  - 仓库初始化









