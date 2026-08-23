# Java 应用打包（`Java_Release/pack/`）

基于 [TextSend_Desktop/pack](https://github.com) 的做法：Maven/Gradle 构建 fat JAR，再用 `jpackage` 打绿色目录和本机安装包。

需要 **JDK 17+**（带 `jpackage`）和 **Maven 或 Gradle**，都在 PATH 里。产物在项目根目录的 `dist/`。

## 接入项目

1. 把 `Java_Release/pack/` 复制到你的 Java 项目根目录（与 `src/`、`build.gradle` 同级）。
2. 复制 `Java_Release/pack.conf.example` 为 `pack/pack.conf`，按项目修改。
3. 在主类 Java 文件里写版本号（或在 `pack.conf` 设 `VERSION_OVERRIDE`）：

```java
public static final String VERSION = "1.0.0";
```

4. 在项目根目录执行打包脚本。

也可不复制：在 `pack/pack.conf` 里设 `PROJECT_ROOT` 指向目标项目（见 `pack.conf.example`）。

## 一键

**Linux / macOS（bash）：**

```bash
./pack/pack.sh
```

**Windows（PowerShell）：**

```powershell
powershell -ExecutionPolicy Bypass -File .\pack\pack.ps1
```

会打出 fat JAR、绿色目录（自带精简 JRE），再按**当前操作系统**打安装包：

| 你在哪台机器上跑 | 额外安装包 |
|------------------|------------|
| Linux（`pack.sh`） | `.deb`（Debian / Ubuntu） |
| macOS（`pack.sh`） | `.dmg` |
| Windows（`pack.ps1`） | `.exe` 安装程序 |

**不能交叉编译。** 要哪种包，就在哪种系统上跑一遍。

## 分项脚本

Linux / macOS 用 `.sh`；Windows 用同名 `.ps1`。

| 文件 | 用途 | 产物 | 在哪打 |
|------|------|------|--------|
| `common.sh` / `common.ps1` | 读 `pack.conf`、版本号、路径、检查命令 | 无 | — |
| `pack-jar.sh` / `pack-jar.ps1` | Maven / Gradle 构建并复制 fat JAR | `dist/<APP_NAME>.jar` | 任意有 JDK+构建工具的系统 |
| `pack-appimage.sh` / `pack-appimage.ps1` | `jpackage --type app-image` 绿色目录 | Linux/mac：目录 + `.tar.gz`；Windows：`dist\<APP_NAME>\` + `.zip` | 目标系统 |
| `pack-deb.sh` | Debian 安装包 | `dist/*.deb` | **只能 Linux**（还要 `fakeroot`、`dpkg-deb`） |
| `pack-mac.sh` | macOS 磁盘镜像 | `dist/*.dmg` | **只能 macOS** |
| `pack-win.ps1` / `pack-win.sh` | Windows 安装程序 | `dist/*.exe` | **只能 Windows** |
| `pack.sh` / `pack.ps1` | 上面几项按平台串起来 | 见上 | 见上 |

`pack.sh` / `pack.ps1` 会设 `SKIP_JAR=1`，避免绿色目录 / 安装包再构建一遍。

## 配置项（`pack/pack.conf`）

| 变量 | 说明 |
|------|------|
| `PROJECT_ROOT` | 项目根（默认 `pack/` 上一级） |
| `APP_NAME` | jpackage 应用名、JAR 文件名 |
| `VENDOR` / `DESCRIPTION` | jpackage 元数据 |
| `MAIN_JAVA` / `MAIN_CLASS` | 主类路径与全限定类名 |
| `VERSION_OVERRIDE` | 可选，覆盖从主类读取的版本号 |
| `BUILD_TOOL` | `mvn` 或 `gradle` |
| `BUILT_JAR_REL` | 构建产物相对项目根的路径 |
| `LINUX_PACKAGE_NAME` | `.deb` 包名 |
| `JAVA_OPTS_EXTRA` | 额外 `--java-options`（如 `-Dapp.home=$ROOTDIR`） |

## 产物怎么用

- **JAR**：对方要装 Java 17+。`java -jar dist/<APP_NAME>.jar`
- **绿色目录**：解压即用，不必装系统 Java。Linux：`<APP_NAME>/bin/<APP_NAME>`；Mac：`<APP_NAME>.app`；Windows：`<APP_NAME>\<APP_NAME>.exe`
- **.deb**：`sudo dpkg -i dist/<linux-package-name>_*.deb`
- **.dmg / .exe**：本机安装器用。Mac 的 dmg 未签名，可能要右键打开

## 与其它模板的关系

| 目录 | 适用场景 |
|------|----------|
| **Java_Release**（本目录） | 非模块化 / Maven shade / Gradle fat JAR + jpackage，**推荐** |
| `Java-NonModular-Gradle` | Gradle + beryx runtime 插件一体化 |
| `Java_Modular_Jlink_for_Linux` / `_Windows` | **模块化**项目，jlink 定制 JRE（不支持自动模块） |

## 还没有的

- **Linux `.AppImage`**（单文件）：与绿色目录不是一回事，未实现
- **Windows `.msi`**：要 WiX，目前只打 `.exe`
- **macOS 签名 / 公证**：无开发者证书则不做
- **rpm / 跨架构**：jpackage 不做

## 依赖备忘

- 所有脚本：`java`（17+）、`mvn` 或 `gradle`
- 绿色目录和安装包：`jpackage`（JDK 自带）
- `.deb`：`fakeroot`、`dpkg-deb`
