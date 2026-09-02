# 通用 Java 应用打包（jpackage）

把**整个本文件夹**拷到任意 **Maven + JDK（带 jpackage）** 项目里即可。文件夹叫 `pack`、`pack2` 都行：脚本把**上一级目录当成项目根**。

不绑死某个应用。换项目只改 **`app.conf`**。

```bash
cp app.conf.example app.conf   # 按项目填写
```

需要：`java`、`mvn` 在 PATH。绿色目录 / 安装包还要 `jpackage`（JDK 自带）。

产物在项目根的 `dist/`。

## 一键

**Linux / macOS：**

```bash
./pack2/pack.sh
```

（拷走后若改名为 `pack`，则 `./pack/pack.sh`。）

**Windows（cmd）：**

```bat
pack2\pack.bat
```

一键会打：可运行 JAR、绿色目录（自带精简 JRE），再按当前系统打安装包。

| 你在哪台机器上跑 | 额外安装包 |
|------------------|------------|
| Linux | `.deb` |
| macOS | `.dmg` |
| Windows（`pack.bat`） | `.exe`（WiX 3） |

**不能交叉编译。** 要哪种包，就在哪种系统上跑。

Windows `.exe` 要 WiX。JDK 24+ 用 WiX 4/5 请跑 `pack-win-wix5.bat`（不要靠 PowerShell 给 `pack-win-choose.bat` 传参，容易把参数丢掉）。

## app.conf

等号两边不要空格。路径相对**项目根**。

| 项 | 说明 |
|----|------|
| `APP_NAME` | 必填。程序名，不要空格 |
| `MAIN_CLASS` | 必填。主类，如 `com.example.Main` |
| `MAVEN_JAR` | 必填。`mvn package` 打出的 jar，如 `target/myapp.jar` |
| `VENDOR` / `APP_DESCRIPTION` | 显示用，可空 |
| `VERSION` | 写死版本。空则看下面两项 |
| `VERSION_JAVA` | 从该 Java 文件读 `VERSION = "x.y"` |
| （都空） | 读 `pom.xml` 里 `<parent>` 之后第一条 `<version>` |
| `LINUX_PKG_NAME` | deb 包名。空则用 `APP_NAME` 小写 |
| `ICON_PNG` / `ICON_ICO` / `ICON_ICNS` | 可选。没有就用默认 Java 图标 |
| `JP_MODULES` | `jpackage --add-modules`，Swing 默认那串一般够用 |
| `JAVA_OPTIONS` | 一条 `--java-options`，默认 UTF-8 |
| `MENU_GROUP` | Linux 菜单分组，默认 `Utility` |

## 分项脚本

| 文件 | 产物 |
|------|------|
| `pack-jar.sh` / `.bat` | `dist/<APP_NAME>_<版本>.jar` |
| `pack-appimage.sh` / `.bat` | **不是** Linux `.AppImage`。是 `jpackage --type app-image` 绿色目录 + tar.gz / zip |
| `pack-deb.sh` | Linux `.deb`（原版 + `.compat.deb` 宽松 Depends） |
| `pack-mac.sh` | macOS `.dmg` |
| `pack-win.bat` | Windows `.exe`（WiX 3） |
| `pack-win-wix5.bat` | Windows `.exe`（WiX 4/5，JDK 24+） |
| `pack.sh` / `pack.bat` | 按平台串起来 |

`pack.sh` / `pack.bat` 会设 `SKIP_JAR=1`，避免后面再 Maven 一遍。

同一份绿色包里两个启动器：

| 平台 | 日常 | 调试（终端看日志） |
|------|------|-------------------|
| Windows | `<App>\<App>.exe` | `<App>\<App>-console.exe` |
| Linux | `<App>/bin/<App>`（deb：`/opt/<pkg>/bin/<App>`） | `…/<App>-console` |
| macOS | `<App>.app` | `<App>.app/Contents/MacOS/<App>-console` |

## Windows WiX

| 脚本 | WiX | JDK |
|------|-----|-----|
| `pack.bat` / `pack-win.bat` | 3（`candle.exe`） | 17+ |
| `pack-win-wix5.bat` | 4/5（`wix.exe`） | 24+ |

WiX 5：

```bat
dotnet tool install --global wix
wix extension add -g WixToolset.Util.wixext
wix extension add -g WixToolset.UI.wixext
```

缺扩展时 `wix` 常 exit **144**。`.bat` 请保持 CRLF（本目录 `.gitattributes` 已指定）。

## 还没有的

- Linux 单文件 `.AppImage`
- Windows `.msi`
- macOS 签名 / 公证
- rpm / 跨架构

## 从本仓库拿走

整份剪切走即可，不要把本文件夹提交进应用仓库也行。应用仓库里只需留下你改好的这份脚本 + `app.conf`。
