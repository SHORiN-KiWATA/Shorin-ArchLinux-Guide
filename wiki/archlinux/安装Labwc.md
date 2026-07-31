
Labwc 是一个堆叠式（stacking）窗口管理器，同时支持四角平铺和工作区切换，足以对付大多数使用场景，并且完全符合 Windows 的布局逻辑。

Labwc 功能齐全的同时做到了极度轻量，堆叠式意味着它没有自动平铺的性能消耗，所以它比 sway、river、dwl 等一众轻量的平铺式窗口管理器都要轻量，是老电脑的最佳选择。

为了轻量，配置的时候会尽量避免持久运行的程序，尽量使用 TUI，尽量使用内存和 CPU 占用低的程序。

[官方入门教程](https://labwc.github.io/getting-started.html)


## 安装

```bash
sudo pacman -S labwc foot fuzzel
```
`foot` `fuzzel` 可以换成你喜欢的终端和启动器。

## 创建配置文件

```bash
mkdir -p ~/.config/labwc

# 环境变量配置文件
touch ~/.config/labwc/environment

# labwc 配置文件（快捷键、布局等）
touch ~/.config/labwc/rc.xml

# 自动启动配置文件
touch ~/.config/labwc/autostart
```

每一次修改以上文件都要 `labwc --reconfigure` 应用更改。修改了 `autostart` `environment` 的话要重启 Labwc。

## 显示器设置

- 临时修改

    临时调整的话有一个很方便的 GUI 叫 `wdisplays`，它没法持久生效。

    ```bash
    sudo pacman -S wdisplays
    ```

- 持久保存

    使用 `wlr-randr`，在 `autostart` 里配置开启 Labwc 时自动调整分辨率的命令就可以做到持久保存。

    ```bash
    sudo pacman -S wlr-randr
    ```
    运行 `wlr-randr` 找到自己需要的显示器接口名称和 mode，然后用以下命令调整分辨率：

    ```bash
    wlr-randr --output 【显示器接口名称】 --mode 宽x高@刷新率
    ```
    示例：

    ```bash
    wlr-randr --output eDP-1 --mode 2560x1440@165
    ```

## 自动启动软件

使用的脚本位于 `~/.config/labwc/autostart`。

示例：

```bash
waybar &

wl-paste --watch cliphist store &

```

每条自动启动后面一定要加 `&` 让那条命令在后台运行。

## 家目录下常用目录

```bash
sudo pacman -S xdg-user-dirs
```
强制生成英文的常用目录：

```bash
LANG=en_US.UTF-8 xdg-user-dirs-update --force
```

## 修改语言为中文

编辑 `environment` 文件：

```bash
vim  ~/.config/labwc/environment
```

```bash
LANGUAGE=zh_CN.UTF-8
LANG=zh_CN.UTF-8
```

需要重启 Labwc。

## 快捷键

以下是一个 `rc.xml` 文件的示例。`<keyboard></keyboard>` 中间设置快捷键绑定。

```xml
<?xml version="1.0" ?>
<labwc_config>

  <keyboard>
    <default />
    <!-- The W- prefix refers to the Super key -->
    <keybind key="W-b">
      <action name="Execute" command="firefox" />
    </keybind>
    <keybind key="W-z">
      <action name="Execute" command="fuzzel" />
    </keybind>
  </keyboard>

</labwc_config>

```

## 剪贴板

推荐 `wl-clipboard` 配 `cliphist`，GUI 用 `cliphist-tui-git`。

```bash
yay -S wl-clipboard cliphist cliphist-tui-git
```
在 `autostart` 里写：

```bash
wl-paste --watch cliphist store &
```
然后设置一个打开剪贴板的快捷键：

```xml
<keybind key="W-A-v">
    <action name="Execute" command="foot cliphist-tui" />
</keybind>
```

## 通知程序

使用 `mako`。

1. 安装

    ```bash
    sudo pacman -S mako
    ```

2. 自动启动

    在 `autostart` 里新建一行写上 `mako &`。

3. 配置

    示例配置：
    ```ini
    border-size=2
    icons=1
    anchor=top-right
    default-timeout=8000
    margin=10
    padding=10
    font=adwaita sans regular 11
    history=1
    max-visible=20
    max-history=100
    ```

## 任务栏

使用 `waybar`。

```bash
sudo pacman -S waybar
```

`autostart` 里写 `waybar &`。

## 网络和蓝牙

NetworkManager 使用 `nmtui`，iwd 用 `impala`。无需额外程序。蓝牙使用 `bluetui`。想要系统托盘的话安装 `network-manager-applet` 和 `blueman`，在 `autostart` 里设置 `nm-applet` 和 `blueman-applet` 自动启动。


## 截图

使用 `grim` `slurp`，用 `satty` 编辑。

1. 安装

    ```bash
    sudo pacman -S grim slurp satty
    ```
2. 修改 satty 配置

    位于 `~/.config/satty/config.toml`。

    示例：

    ```ini
    [general]
    copy-command = "wl-copy"
    focus-toggles-toolbars= true
    initial-tool = "brush"
    zoom-factor=1.1

    [font]
    family = "Roboto"
    style = "Regular"
    fallback = [
        "Noto Sans CJK SC",
        "Noto Sans CJK JP",
        "Noto Sans CJK TC",
        "Noto Sans CJK KR"
    ]
    ```

3. 创建截图脚本

    xml 里直接写命令不太方便，可以在 `~/.config/labwc/scripts` 里创建脚本。

    ```bash
    mkdir -p ~/.config/labwc/scripts

    vim ~/.config/labwc/scripts/screenshot
    ```
    写入：

    ```bash
    #!/bin/bash

    case "$1" in
        select)
            # 框选截图 -> 复制到剪贴板
            grim -g "$(slurp)" - | wl-copy
            ;;
        edit)
            # 框选截图 -> 打开 satty 编辑器 (可以在编辑器里保存或复制)
            grim -g "$(slurp)" - | satty -f -
            ;;
    esac

    ```
    给执行权限：
    ```bash
    chmod +x ~/.config/labwc/scripts/screenshot
    ```

4. 设置快捷键

    ```xml
    <keybind key="W-A-a">
        <action name="Execute" command="~/.config/labwc/scripts/screenshot select" />
    </keybind>
    <keybind key="W-S-s">
        <action name="Execute" command="~/.config/labwc/scripts/screenshot edit" />
    </keybind>
    ```

## 图形化文档管理器

使用 `thunar`。

```bash
sudo pacman -S --needed xdg-desktop-portal-gtk thunar tumbler ffmpegthumbnailer poppler-glib gvfs-smb file-roller thunar-archive-plugin gnome-keyring thunar-volman gvfs-mtp gvfs-gphoto2 webp-pixbuf-loader icoextract
```

>`xdg-desktop-portal-gtk` 是 GTK 的 xdg 桌面门户。

>`tumbler` 提供图片预览功能。

>`ffmpegthumbnailer` 视频预览。

>`poppler-glib` PDF 预览。

>`gvfs-smb` 检查可挂载的外部设备，访问 smb 分享等功能。

>`file-roller` 提供压缩解压缩功能。

>`thunar-archive-plugin` 在 thunar 的右键菜单添加压缩解压缩选项。

>`gnome-keyring` 提供密码保存功能。第一次保存密码会让你设置 keyring 的密码，可以空着。

>`thunar-volman` 自动管理移动硬盘等设备。

>`gvfs-mtp` 连接手机。

>`gvfs-gphoto2` 连相机。

>`webp-pixbuf-loader` webp 缩略图。

>`icoextract` exe 缩略图。


- 右键从此处打开

    左上角编辑配置自定动作，把 open terminal here 的命令改成 `foot`（你的终端）。

- 默认终端

    ```bash
    yay -S xdg-terminal-exec

    echo "foot.desktop" >> ~/.config/xdg-terminals.list
    ```
    这里的 `foot.desktop` 应是你实际的终端的 .desktop 文件。


## 录屏

录屏推荐使用 `wf-recorder` 和 `wl-screenrec`。

obs 录屏需要配置门户：

```bash
sudo pacman -S xdg-desktop-portal-wlr

vim ~/.config/labwc/environment
```
```ini
XDG_CURRENT_DESKTOP=labwc:wlroots
```
重启 Labwc 之后就可以在 obs 看到屏幕采集选项了。

## 鼠标主题

推荐 `breeze-cursors`。

```bash
sudo pacman -S breeze-cursors
```
在 `environment` 里写上：

```ini
XCURSOR_THEME=breeze_cursors
XCURSOR_SIZE=30
```

## 中文输入法

1. 安装

    看[ShorinWiki 中文输入法](中文输入法.md)。

2. 配置

    在 `environment` 里写上：

    ```ini
    XMODIFIERS=@im=fcitx
    ```

## 壁纸

推荐使用 `swaybg`，GUI 使用 `waypaper`。

```bash
sudo pacman -S swaybg waypaper
```
然后在 `autostart` 写上：

```bash
waypaper --restore
```
之后用 waypaper 切换壁纸就行了。

