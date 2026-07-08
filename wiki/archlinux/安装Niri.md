- [这是你在这篇文章之后能够获得的 Niri 环境](#这是你在这篇文章之后能够获得的-niri-环境)
- [什么是 Niri？](#什么是-niri)
- [可选：更换 shell 为 fish](#可选更换-shell-为-fish)
- [安装](#安装)
- [显示器配置](#显示器配置)
- [关闭鼠标加速](#关闭鼠标加速)
- [重要程序](#重要程序)
- [修改系统语言为中文](#修改系统语言为中文)
- [安装中文输入法](#安装中文输入法)
- [配置图形化文档管理器](#配置图形化文档管理器)
  - [Nautilus](#nautilus)
  - [可选：Thunar](#可选thunar)
  - [可选：dolphin](#可选dolphin)
- [锁屏](#锁屏)
- [自动熄屏锁屏睡眠](#自动熄屏锁屏睡眠)
- [蓝牙](#蓝牙)
- [剪贴板](#剪贴板)
  - [Clipse](#clipse)
  - [Cliphist](#cliphist)
- [截图](#截图)
  - [编辑截图](#编辑截图)
- [屏幕分享](#屏幕分享)
- [软件商城](#软件商城)
- [Alt+Tab 切换窗口](#alttab-切换窗口)
- [笔记本屏幕亮度调节](#笔记本屏幕亮度调节)
- [壁纸切换](#壁纸切换)
- [面板（任务栏）](#面板任务栏)
  - [使用我的配置](#使用我的配置)
    - [根据壁纸自动更改 waybar 颜色](#根据壁纸自动更改-waybar-颜色)
- [Niri 配置文件修改](#niri-配置文件修改)
- [设置 overview 背景壁纸](#设置-overview-背景壁纸)
- [窗口模糊-Blur](#窗口模糊-blur)
- [可选：大写锁定显示](#可选大写锁定显示)
- [可选：自动登录](#可选自动登录)
- [Reference](#reference)
---

## 这是你在这篇文章之后能够获得的 Niri 环境

![](../pictures/waybar-bottom-niri.png)

视频教程（旧版）：[「Niri 入门指南 2025」颠覆传统桌面体验，最适合新手的窗口管理器](https://www.bilibili.com/video/BV1fgUEBMEMZ/?share_source=copy_web&vd_source=1c6a132d86487c8c4a29c7ff5cd8ac50)

如果你想用我的配置文件一键安装 Niri，看：<https://github.com/SHORiN-KiWATA/shorin-arch-setup>

由于 Niri 很特别，所以简单介绍一下。

## 什么是 Niri？

Niri 官方的 demo 视频用几分钟简单地演示了 Niri 的特性，绝对值得一看：[Niri 演示视频](https://github.com/YaLTeR/niri)

Niri 的一切都是围绕 scrolling layout 滚动布局设计的。Niri 的特点：

1. 无限卷轴式平铺

    传统桌面不论是 Windows、Mac、KDE、GNOME、Hyprland、Sway，它们的工作区都只有一个屏幕的大小，新开的窗口会挤占其他窗口的空间。而 Niri 的工作区可以横向无限延伸，像是一个无限长的"卷轴"，**新开的窗口不会影响已经打开的窗口**。

2. 垂直工作区切换

    工作区切换是上下方向而不是常见的左右切换。

3. 动态工作区数量增减

    常规窗口管理器的工作区数量是固定的，而 Niri 的工作区数量是动态变化的，空的会被自动删除。

4. Column 合并

    可以将窗口合并到同一列，甚至支持开启标签页，这让 Niri 可以同时做到 Master 布局、网格布局和标签页布局。

5. 其他细节设计

    Overview、快捷键教程、舒适的默认配置、详细的默认配置文件注释等等。

以上这些结合起来组成了极其舒适的桌面体验。

## 可选：更换 shell 为 fish

> [FishShell](https://fishshell.com/)

由于会频繁用到命令行，有一个便利的 shell 会方便很多。

```bash
sudo pacman -S fish
```

运行 `fish` 命令即可打开 fish。

## 安装

> [Niri-Getting-Started](https://github.com/niri-wm/niri/wiki/Getting-Started)

1. 安装

    ```bash
    sudo pacman -S niri xwayland-satellite xdg-desktop-portal-gnome fuzzel alacritty firefox
    # alacritty 可以换成你喜欢的终端仿真器，例如 Kitty / Foot / Ghostty
    ```

    出现选项选择 `pipewire-jack`。

    >`niri` 本体；

    >`xwayland-satellite` 提供 Xwayland 功能，Xwayland 是在 Wayland 上运行 X11 软件的兼容环境；

    >`xdg-desktop-portal-gnome` 是 Niri 推荐使用的桌面门户，提供文件选择、屏幕分享等功能；

    >`fuzzel` 是 Niri 默认的程序启动器；

    >`alacritty` 是 Niri 默认的终端仿真器；

    >`firefox` 是 Linux 上好用的浏览器；

2. 第一次运行（此时会生成配置文件）

    运行 `niri-session` 打开 Niri 会话。如果有显示管理器的话在显示管理器切换会话。

3. 可选：修改默认终端

    如果你使用的不是 `alacritty` 可以编辑配置文件修改按键打开的终端。

    `Super+Shift+E` 退出 Niri，用你喜欢的软件编辑 Niri 的配置文件：

    ```bash
    vim ~/.config/niri/config.kdl
    ```

    PS：没有特指的话后面所有"编辑配置文件"指的都是这个文件。

    `/` 键，搜索 `alacritty`，找到下面这行内容：

    ```text
    Mod+T hotkey-overlay-title="Open a Terminal: alacritty" { spawn "alacritty"; }
    ```

    >`hotkey-overlay-title="Open a Terminal: alacritty"` 设置 `Super+Shift+/` 打开的界面里的显示内容。改成 `=null` 可以隐藏。

    把 `spawn "alacritty"` 改成 `spawn "kitty" "-e" "fish"`

    - 关于 Niri 设置自定义快捷键

        当命令由多个部分组成时有两种写法。一种是 `spawn`，需要把命令分段写在多个引号里；

        ```text
        spawn "kitty" "-e" "fish"
        ```

        另一种是 `spawn-sh`，命令不用分段，直接写在一个引号里；

        ```text
        spawn-sh "kitty -e fish"
        ```

        `-sh` 的写法更方便，但是会有额外的性能开销，命令很长懒得分段或者命令中有 shell 符号时（如 `||`）使用 `-sh`。


4. 基础使用方法

    > `Super` 键就是 `Win` 键。

    `Super+Shift+/` 打开重要快捷键教程

    `Super+T` 打开终端

    `Super+D` 打开应用启动器

    `Super+U/I` 上下切换工作区

    知道这些就可以开始使用 Niri 啦，详细的按键教程可以后续看 `快捷键教程菜单` 和配置文件。

## 显示器配置

> [niri_wiki_outputs](https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs)

1. 可选：临时修改

    使用`wdisplays`临时修改显示设置

    ```bash
    sudo pacman -S wdisplays
    ```

2. 运行命令获取显示器信息

    ```bash
    niri msg outputs
    ```

    ```text
    Output "BOE NE156QHM-NY1 Unknown" (eDP-1)
      Current mode: 2560x1440 @ 165.000 Hz (preferred)
      Variable refresh rate: supported, disabled
      Physical size: 340x190 mm
      Logical position: 0, 0
      Logical size: 1920x1080
      Scale: 1.3333333333333333
      Transform: normal
      Available modes:
        2560x1440@165.000 (current, preferred)
        2560x1440@60.000 (preferred)
    ……………………
    Output "Shenzhen KTC Technology Group H27T22C 0x00000001" (DP-2)
      Current mode: 2560x1440 @ 180.000 Hz
      Variable refresh rate: supported, disabled
      Physical size: 600x330 mm
      Logical position: 1925, 0
      Logical size: 2560x1440
      Scale: 1
      Transform: normal
      Available modes:
        2560x1440@59.951 (preferred)
        2560x1440@180.000 (current)
        2560x1440@164.999
    ………………
    ```

    记住 `eDP-1` 和 `DP-2` 这部分名称，然后在 `available modes` 里找到自己需要的模式，格式为 `分辨率@刷新率`。

3. 配置文件内修改 ``output{}``

    左斜杠搜索 `output` 在示例配置下面自己写一个

    ```text
    output "eDP-1"{
     //分辨率和刷新率
     mode "2560x1440@165"
     //缩放倍率
     scale 1.33
     //位置，x=0 y=0 代表最左上角
     position x=0 y=0
     //启动时聚焦此显示器
     focus-at-startup
     //取消下面这行的注释设置可变刷新率
     //variable-refresh-rate
     //取消下面这行的注释可以设置旋转，参数有：90, 180, 270, flipped（水平翻转）, flipped-90（水平翻转后旋转）, flipped-180 and flipped-270
     //transform "90"

    }
    ```

4. 多显示器的情况

    需要给每一个显示器都配置一个 `output{}`，通过 `DP-2` 这样的名称指定该配置生效的显示器。

    显示器的位置关系需要一些计算，根据你的显示器的摆放位置，把最左边或者最左上角的显示器的位置设置为 `position x=0 y=0`，然后以此为原点设置其他显示器的位置。

    我的 `eDP-1` 显示器位置在最左上角，所以位置设置成 `x=0 y=0`。我想把 DP-2 显示器放在它的右边，那就要更改 `x=0` 的值。eDP-1 的分辨率是 2560x1440，1.33 缩放，那横向像素就是 `2560/1.33=1924.81203008`，约等于 `1925`。那我 DP-2 的位置就应该设置为 ``x=1925 y=0``。以此类推，想放在下面就修改 y 轴的值，设置了旋转的话计算的时候横竖的值也要对应旋转。

    ```text
     output "DP-2"{
     mode "2560x1440@180"
     scale 1
     position x=1925 y=0
    }
    ```

## 关闭鼠标加速

> [niri_wiki_input](https://github.com/YaLTeR/niri/wiki/Configuration:-Input)

找到 `input{mouse{}}`，取消 `accel-profile "flat"` 的注释。

```text
mouse {
    //取消下面这行注释修改鼠标速度，正数加快，负数减慢
    //accel-speed -0.2
    //鼠标加速是默认开启的，设置这一行可以关闭鼠标加速度
    accel-profile "flat"
    //滚轮滚动速度，如果是负号的话会变更方向
    //scroll-factor horizontal=2.0 vertical=-1.0
}
```

## 重要程序

> [Niri-List-of-Important_Software](https://github.com/niri-wm/niri/wiki/Important-Software) | [Niri-XWayland](https://github.com/niri-wm/niri/wiki/Xwayland)

1. 安装

    ```bash
    sudo pacman -S libnotify mako polkit-gnome
    ```

    >`mako` 精简好用的通知服务。

    >`polkit-gnome` 需要管理员权限的软件会通过 polkit 询问权限，没有 polkit 的话就无法启动，例如 `btrfs-assistant`。

2. 设置重要程序在 Niri 启动时自动启动

    Niri 会话是作为 systemd 服务启动的，所以可以用 systemd 启动那些重要程序，但是修改 Niri 配置文件会更方便。

    ```bash
    vim ~/.config/niri/config.kdl
    ```

    搜索 `spawn-at-startup`，在合适的地方写入：

    ```text
    spawn-at-startup "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"

    spawn-at-startup "mako"
    ```

3. 现在启动

    ```bash
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & disown
    ```

    ```bash
    mako & disown
    ```

    >`&` 代表在终端后台运行。

    >`disown` 命令从终端解绑程序。

- 编辑 mako 的配置文件设置通知的显示时长

    ```bash
    # 创建目录
    mkdir -p ~/.config/mako
    # 编辑文件
    vim ~/.config/mako/config
    ```

    ```text
    default-timeout=8000
    border-radius=8
    ```

    ```bash
    # 重新加载配置
    makoctl reload
    ```

## 修改系统语言为中文

利用配置文件提供的环境变量功能设置系统语言。

```text
environment {
    LANG "zh_CN.UTF-8"
    LANGUAGE "zh_CN.UTF-8"
}
```

- 如果是 archinstall 安装的系统，需要额外进行如下操作：

  1. ```bash
     sudo vim /etc/locale.gen
     ```

  2. 左斜杠键搜索，取消 `zh_CN.UTF-8` 的注释

  3. ```bash
     sudo locale-gen
     ```

  4. 登出

## 安装中文输入法

0. 需要[添加 archlinuxcn](安装桌面环境前的准备.md#aur助手)

1. 安装

    看中文输入法一节：[中文输入法](中文输入法.md)

2. 设置环境变量

    在 Niri 配置文件的 `environment{}` 里面写入 `XMODIFIERS "@im=fcitx"` 即可

3. 现在启动

    ```bash
    fcitx5 -d
    ```

4. 自动启动

    ```text
    spawn-at-startup "fcitx5" "-d"
    ```

5. 可选：设置开关输入法的快捷键

    ```text
    Mod+F1 {spawn-sh "pkill fcitx5 || fcitx5";}
    ```
    >输入法卡住的时候可以快捷重启（输入法为什么会卡住你别问）

## 配置图形化文档管理器

### Nautilus

安装 `xdg-desktop-portal-gnome` 会把 `nautilus` 作为依赖装上，这是 GNOME 桌面环境的文档管理器。使用这条命令补全它的功能：

```bash
sudo pacman -S ffmpegthumbnailer gvfs-smb nautilus-open-any-terminal file-roller gnome-keyring gst-plugins-base gst-plugins-good gst-libav icoextract python-pillow
```
<details close><summary>[展开]软件包的介绍</summary>

>`ffmpegthumbnailer` 视频预览。

>`gvfs-smb` 检查可挂载的外部设备，访问 smb 分享等功能。

>`nautilus-open-any-terminal` 右键从此处打开终端。

>`file-roller` 提供压缩解压缩功能。

>`gnome-keyring` 提供密码保存功能。第一次保存密码会让你设置 keyring 的密码，可以空着。

>`gst-plugins-base gst-plugins-good gst-libav` 这些让你可以预览视频信息。

>`icoextract` `python-pillow` exe 缩略图。

>可选：

>`nautilus-image-converter` 右键方便调整图片大小或者旋转。

>`libheif webp-pixbuf-loader libopenraw gst-plugins-bad gst-plugins-ugly` 提供更多视频、图片格式支持。

>`gnome-font-viewer` 字体缩略图和字体管理。

</details>

- 更改默认终端为 Kitty（你使用的终端）

    安装 `xdg-terminal-exec`，这个包需要从 AUR 安装：

    ```bash
    yay -S xdg-terminal-exec
    ```

    编辑 `~/.config/xdg-terminals.list` 设置 Kitty 为第一优先级：

    ```bash
    echo "kitty.desktop" > ~/.config/xdg-terminals.list
    ```

    >此处的 `kitty.desktop` 应为你使用的终端的实际 `.desktop` 文件名称。

    如果需要多个终端的话就按照优先级顺序从上到下写多行。

- 设置 Nautilus `右键从此处打开 Kitty`

    使用 dbus 设置 dconf。

    ```bash
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty
    ```

- 设置右键从此处打开 Kitty 的 shell 为 fish

    从 Nautilus 右键打开 Kitty 默认是 bash，可以编辑 Kitty 的配置文件设置默认使用 fish：

    ```bash
    vim ~/.config/kitty/kitty.conf
    ```

    写入

    ```text
    shell fish
    ```

    美化 Kitty 的部分在这里：[Kitty 美化](终端美化.md#kitty美化)

- 设置打开文档管理器的快捷键

    ```bash
    vim ~/.config/niri/config.kdl
    ```

    找到 `binds{}`，在里面新建：

    ```text
    Mod+E { spawn "nautilus";}
    ```

- Issue: 如果 Nautilus 启动慢

    如果你是带 N 卡的双显卡配置，大概率是因为 GTK4 使用的新的渲染器和 N 卡驱动工具之间有一些兼容性问题，解决办法是用以下环境变量启动 Nautilus，让它使用旧的渲染器：

    >编辑 .desktop 文件推荐从 AUR 安装 pins：`yay -S pins-git`

    ```bash
    env GSK_RENDERER=gl nautilus
    ```

### 可选：Thunar

<details><summary>[展开/收起] 如果你不想用 Nautilus，我推荐使用 Xfce 生态的 Thunar。功能强大，高度可自定义，且内存占用极低。</summary>

> [Xfce4-Projects](https://www.xfce.org/projects)

安装：

```bash
sudo pacman -S --needed xdg-desktop-portal-gtk thunar tumbler ffmpegthumbnailer poppler-glib gvfs-smb file-roller thunar-archive-plugin gnome-keyring thunar-volman gvfs-mtp gvfs-gphoto2 webp-pixbuf-loader icoextract python-pillow
```

<details close><summary>[展开]软件包介绍</summary>

>`xdg-desktop-portal-gtk` 是 GTK 的 xdg 桌面门户。

>`tumbler` 提供图片预览功能。

>`ffmpegthumbnailer` 视频预览。

>`poppler-glib` PDF 预览。

>`gvfs-smb` 检查可挂载的外部设备，访问 smb 分享等功能。

>`file-roller` 提供压缩解压缩功能。

>`thunar-archive-plugin` 在 Thunar 的右键菜单添加压缩解压缩选项。

>`gnome-keyring` 提供密码保存功能。第一次保存密码会让你设置 keyring 的密码，可以空着。

>`thunar-volman` 自动管理移动硬盘等设备。

>`gvfs-mtp` 连接手机。

>`gvfs-gphoto2` 连相机。

>`webp-pixbuf-loader` webp 缩略图。

>`icoextract` `python-pillow` exe 缩略图。

</details>

预览远程服务器上的图片要调整首选项中的 `缩略图` 为 `总是`。

- 清理没什么用的侧边栏书签

    在侧边栏的空白处右键

- 右键从此处打开终端

    Thunar 提供了强大的自定义右键功能。点击左上角 `编辑` > `配置自定义动作` > 选中 `open in terminal here` > 点击小齿轮 > 命令改成 `kitty`。

- 配置使用 Thunar 进行文件选取

    Niri 默认使用 GNOME 的桌面门户进行文件选取，需要调整为 GTK 配合 Thunar 使用：

    ```bash
    mkdir -p ~/.config/xdg-desktop-portal/
    vim ~/.config/xdg-desktop-portal/niri-portals.conf
    ```

    ```ini
    [preferred]
    default=gnome;gtk;
    org.freedesktop.impl.portal.FileChooser=gtk
    ```

    >`default=gnome;gtk;` 设置默认门户是 GNOME，回退门户是 GTK。这会让除文件选取以外的功能都使用 GNOME 门户，如 `屏幕分享`。

    >`org.freedesktop.impl.portal.FileChooser=gtk` 设置文件选择用 GTK。

</details>

### 可选：dolphin

<details close><summary>[展开/收起] 还可以安装 KDE 生态的 Dolphin。</summary>

1. 安装

    ```
    sudo pacman -S dolphin xdg-desktop-portal-kde
    ```

2. 编辑文件选择器
    
    ```
    vim ~/.config/xdg-desktop-portal/niri-portals.conf
    ```

    ```ini
    [preferred]
    default=gnome;gtk;
    org.freedesktop.impl.portal.FileChooser=kde
    ```

- Issue: 如果使用 dolphin 没有默认应用菜单

    ```bash
    sudo pacman -S archlinux-xdg-menu
    ```

    编辑 Niri 的环境变量

    ```text
    environment {
        XDG_MENU_PREFIX "arch-"
    }
    ```

</details>

## 锁屏

Niri 默认配置文件里使用了 `swaylock`。

1. 安装

    ```bash
    yay -S swaylock-effects
    ```
    >这是带美观效果的 `swaylock`

2. 创建目录并编辑配置文件

    ```bash
    mkdir -p ~/.config/swaylock
    vim ~/.config/swaylock/config
    ```

    ```text
    screenshots
    clock
    indicator
    indicator-radius=200
    indicator-thickness=15
    effect-blur=10x5
    font=Noto Sans CJK SC
    ```

    从上到下分别是：

    ```text
    用桌面当背景
    显示时钟
    显示圆环
    圆环大小
    圆环粗细
    背景模糊
    字体（如果不设置这一项并且你没有设置 fontconfig 的话中文会乱码，具体使用什么字体取决于你安装了哪个字体。可以使用 gnome-font-viewer 查看）
    ```

Niri 默认设置了一个 `Mod+Alt+L` 锁屏的快捷键，如果要修改可以在配置文件搜索 `swaylock`。

## 自动熄屏锁屏睡眠

使用 `swayidle`

1. 安装

    ```bash
    sudo pacman -S swayidle
    ```

2. 创建 `swayidle` 脚本

    >虽然 Niri 的 wiki 说可以使用 systemd，但是为了方便移植，我使用脚本。

    ```bash
    mkdir -p ~/.config/niri/scripts
    vim ~/.config/niri/scripts/swayidle.sh
    ```

    ```bash
    #!/usr/bin/env bash

    # 5 分钟锁屏，10 分钟熄屏，20 分钟睡眠
    # swaylock -f 是前台运行 swaylock，如果不加的话后续的 timeout 命令会不生效

    swayidle -w \
        timeout 300  'swaylock -f' \
        timeout 600  'niri msg action power-off-monitors' \
        resume       'niri msg action power-on-monitors' \
        timeout 1200 'systemctl suspend' \
    ```
    > 因兼容性问题，此处会报错 `Failed to parse get BlockInhibited property: Invalid argument`。属于正常情况，不影响脚本功能。

    添加可执行权限

    ```bash
    chmod +x ~/.config/niri/scripts/swayidle.sh
    ```

    现在开启

    ```bash
    bash ~/.config/niri/scripts/swayidle.sh & disown
    ```

    设置自动启动

    ```text
    spawn-at-startup "~/.config/niri/scripts/swayidle.sh"
    ```

## 蓝牙

> [ArchWiki Bluetooth](https://wiki.archlinux.org/title/Bluetooth)

这里使用 `bluetui`。

```bash
sudo pacman -S --needed bluez bluetui
```

```bash
sudo systemctl enable --now bluetooth
```

`bluetui` 可以打开终端交互界面

## 剪贴板

你有两个选择，一个开箱即用，一个需要更有趣，但是要自己配置。

- [Clipse](#clipse)
- [Cliphist](#cliphist)

### Clipse

1. 安装

    ```bash
    yay -S wl-clipboard clipse clipse-gui
    ```
    > `wl-clipboard` Wayland 合成器的标配剪贴板工具。

    > `clipse` 是一个 TUI 剪贴板程序。

    > `clipse-gui` 是基于 GTK 的图形界面。

2. 自动启动

    ```text
    spawn-at-startup "clipse" "--listen"
    ```

3. 现在启动

    ```bash
    clipse --listen
    ```

4. 设置打开 `clipse-gui` 的快捷键

    ```text
    Mod+Alt+V {spawn "clipse-gui";}
    ```

5. 以浮动模式打开 `clipse-gui`

    ```bash
    niri msg pick-window
    ```

    点选 clipse-gui 的窗口获取窗口信息，主要使用 `title` 或者 `app-id` 指定窗口。然后编辑 Niri 的配置文件搜索 `window-rule`，在合适的位置自己写一个窗口规则的代码块。

    >或者搜 `open-floating`，Niri 的默认配置里有一个被 `/-` 注释掉的示例配置。

    ```text
    window-rule {
        //match app-id 用 appid 指定窗口规则生效的窗口
        match app-id="clipse-gui"

        //规则是以浮动模式打开窗口
        open-floating true
    }
    ```

6. 禁用选取后自动粘贴

    clipse-gui 的配置文件里写入 `enter_to_paste = False` 可以禁用复制即粘贴，但是似乎没有生效。解决办法是把 `paste_simulation_cmd_wayland=` 里的命令改成 true。

    ```text
    paste_simulation_cmd_wayland = true
    ```

- Clipse 的 TUI

    刚才介绍了，Clipse 是一个 TUI，你可以直接在终端运行 `clipse` 命令打开 TUI 界面。如果你要使用 TUI 的话以下是示例配置：

    ```text
    Mod+Alt+V {spawn-sh "kitty --class clipse -e clipse";}
    ```

    ```text
    window-rule {
        match app-id="clipse"
        open-floating true
    }
    ```

### Cliphist

<details close><summary>[展开/收起] Cliphist 是一个剪贴板历史 CLI（命令行工具），我们可以基于这个工具自定义属于自己的图形界面。</summary>

1. 安装

    ```bash
    sudo pacman -S cliphist wl-clipboard
    ```

    >`wl-clipboard` 是 Wayland 合成器标配剪贴板工具。

    >`cliphist` 提供剪贴板历史记录功能。

2. 现在启动

    ```bash
    wl-paste --watch cliphist store & disown
    ```

    原理是开启 `wl-paste --watch` 监测剪贴板变化。每一次出现新条目时自动运行 `cliphist store` 保存到 cliphist 的历史记录里。

    cliphist 保存的剪贴板历史可以通过 `cliphist list` 查看。

    `cliphist decode` 通过传入的 cliphist **列表序号**解码真实的数据，这个数据存放在 `.cache/cliphist/db`

3. 设置守护进程自动启动

    ```text
    spawn-at-startup "wl-paste" "--watch" "cliphist" "store"
    ```

- 小游戏

    这里我们可以玩一些小游戏。安装 `fzf`，这是一个模糊搜索、TUI 菜单程序。

    ```bash
    sudo pacman -S fzf
    ```

    复制点东西，运行：

    ```bash
    cliphist list | fzf
    ```

    这条命令把 cliphist 的列表数据传给了 fzf，你会得到一个可供选择的剪贴板历史菜单。回车任意选择一项，终端就会打印出 `1    这是我的剪贴板历史` 格式的内容，这是 cliphist 的列表数据格式。

    再试着运行以下命令：

    ```bash
    cliphist list | fzf | cliphist decode
    ```

    通过 `decode`，可以将列表数据转换为原本的剪贴板内容并打印在终端（注意，这不是简单的去掉序号，图片数据经过 `decode` 会从纯文字变成二进制数据）。

    接下来再试试运行这段命令：

    ```bash
    cliphist list | fzf | cliphist decode | wl-copy
    ```

    >`wl-copy` 将数据写入当前剪贴板。

    至此，一个简易的剪贴板 TUI 就做好了，我觉得这很有趣，分享给你。这个小游戏里我们使用 `fzf` 处理数据，还可以使用别的东西，比如类似 `fuzzel` 的菜单程序，万变不离其宗，原理都是一样的。

    ```text
    cliphist | fuzzel -d | cliphist decode | wl-copy
    ```

4. 安装 TUI

    我做的 TUI，使用 `kitty icat` 进行图片预览，原理就是刚刚小游戏中的原理，占用仅 7MB。

    <https://github.com/SHORiN-KiWATA/cliphist-tui>

    ```bash
    yay -S cliphist-tui-git
    ```

    运行 `cliphist-tui` 命令就能打开

    记得设置 TUI 的快捷键：

    ```text
    Mod+Alt+V {spawn-sh "kitty --single-instance --class cliphist-tui -e cliphist-tui";}

    // 因为这是一个 bash 脚本，所以快捷键命令会长一些
    // --single-instance 避免每次开 Kitty 都新开进程导致不必要的内存占用
    // --class 指定要打开的 Kitty 的 app-id
    // -e 指定打开时自动运行的命令
    ```

    以浮动模式打开：

    ```text
    window-rule{
        //用 app-id 指定窗口
     match app-id="cliphist-tui"
        // 默认长宽

    default-column-width { fixed 625; }
        default-window-height { fixed 700; }
     //以浮动模式打开
        open-floating true
     //默认打开位置，这里的 x 和 y 是偏移量。这里的例子是在顶部中心打开，y 轴向下 18 个逻辑像素
        default-floating-position x=0 y=18 relative-to="top"
    }
    ```
</details>

## 截图

Niri 自带了截图功能，不仅可以截区域，还可以截取窗口或者全屏，很好用。在配置文件搜索 `screenshot` 可以找到键位。`screenshot-path` 可以设置壁纸保存的位置和文件名模板。



### 编辑截图

>有一个新项目叫 [mark-shot](https://github.com/jswysnemc/mark-shot)，感兴趣的可以尝试，开箱即用，功能非常全面。

我使用 `satty`

```bash
sudo pacman -S satty
```

- 编辑配置文件

    ```bash
    mkdir -p ~/.config/satty
    vim ~/.config/satty/config.toml
    ```

    ```toml
    [general]
    copy-command = "wl-copy"
    focus-toggles-toolbars= true
    actions-on-right-click = ["save-to-clipboard"]
    [font]
    family = "Noto Sans"
    style = "Regular"
    fallback = [
        "Noto Sans CJK SC",
        "Noto Sans CJK JP",
        "Noto Sans CJK TC",
        "Noto Sans CJK KR"
    ]
    ```

    >`copy-command = "wl-copy"`设置 satty 的复制命令为 `wl-copy`，这样才能正确从 satty 复制图片到剪贴板。

    >`focus-toggles-toolbars= true` 设置自动隐藏工具栏。

    >`actions-on-right-click = ["save-to-clipboard"]` 设置右键复制到剪贴板。

    >`[font]` 这块的设置中文字体可以让 satty 支持输入中文。

- 设置编辑截图的快捷键

    Niri 截图的命令行工具暂时不支持把图片的数据传给别的软件，但截图数据会自动保存到剪贴板，我们可以从剪贴板获取图片数据。

    ```text
    Mod+Shift+S {spawn-sh "wl-paste | satty -f -";}
    ```

    先用 Niri 的截图工具截图（不论全屏、选择区域、聚焦窗口截图都可以），然后按下这个快捷键让 satty 读取剪贴板里的那张截图。最可控，最简单，无额外性能开销。

## 屏幕分享

录屏推荐使用 obs 或者 kooha。想要最好的录屏效果可以了解一下 `wf-recorder` 或 `wl-screenrec`，`wl-screenrec` 性能更好。

Niri 通过 GNOME 的 xdg 桌面门户进行屏幕分享，我们已经安装了，此时应该已经可以用了。如果无法使用的话设置：

```text
spawn-sh-at-startup "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=niri & /usr/lib/xdg-desktop-portal-gnome"
```

>通过 `WAYLAND_DISPLAY` 和 `XDG_CURRENT_DESKTOP=niri` 这两个变量让 dbus 和 systemd 知道我的当前 Wayland 会话是哪个，桌面环境是什么。然后确保启动 GNOME 的桌面门户提供屏幕分享功能。设置完之后要重启 Niri。

## 软件商城

```bash
sudo pacman -S bazaar
```
>这是 Flatpak 的 GUI 商城，需要安装`flatpak`。

## Alt+Tab 切换窗口

>参考：[Configuration:-Recent-Windows](https://github.com/YaLTeR/niri/wiki/Configuration:-Recent-Windows)

Niri 自带此功能。以下是一个示例配置，我把快捷键改成了 `Mod+Tab`：

```text
// 带缩略图的 Alt+Tab 切换窗口功能（但是我设置的是 Super+Tab，更符合逻辑）
recent-windows {
    // 取消 //off 的注释可以禁用
    // off
    debounce-ms 750
    open-delay-ms 150

    highlight {
        active-color "#999999ff"
        urgent-color "#ff9999ff"
        // 缩略图背景内间距
        padding 30
        // 缩略图的背景圆角
        corner-radius 12
    }

	//设置缩略图大小
    previews {
        max-height 480
        max-scale 0.2
    }

    binds {
        // scope 可以设置显示的窗口是当前工作区的、还是当前显示器的、或者显示全部窗口
        Mod+Tab         { next-window scope="workspace"; }
        Mod+Shift+Tab   { previous-window scope="workspace"; }
        // grave 是波浪键，显示当前应用的所有窗口
        Mod+grave       { next-window     filter="app-id"; }
        Mod+Shift+grave { previous-window filter="app-id"; }
    }
}
```

## 笔记本屏幕亮度调节

笔记本用户装这个包之后可以用笔记本键盘的快捷键调节屏幕亮度

```bash
sudo pacman -S brightnessctl
```

## 壁纸切换

使用 `awww` 和 `waypaper`。

1. 安装

    ```bash
    yay -S awww waypaper
    ```

2. 打开 waypaper 切换壁纸

3. 设置 `awww-daemon` 自动启动

    ```text
    spawn-at-startup "awww-daemon"
    ```

4. 设置快捷键

    ```text
    Mod+Alt+W {spawn "waypaper";}
    ```

5. 设置窗口规则

    打开 waypaper 窗口，运行：

    ```bash
    niri msg pick-window
    ```

    选择 waypaper 窗口获取窗口信息，然后在 Niri 的配置文件里面设置窗口规则

    ```text
    window-rule {

        match app-id="waypaper"

        open-floating true
    }
    ```

## 面板（任务栏）

> [Github-Wiki-Waybar](https://github.com/Alexays/Waybar/wiki)

这里使用 Waybar，一个相当热门、高度可自定义的任务栏。

1. 安装

    ```bash
    sudo pacman -S waybar ttf-jetbrains-mono-nerd otf-font-awesome
    ```

    >`ttf-jetbrains-mono-nerd` 提供图标文字。

    >`otf-font-awesome` 是 waybar 的基础字体包依赖。

2. 现在启动

    ```bash
    waybar & disown
    ```

3. 开机自启

    编辑 Niri 的配置文件

    ```bash
    vim ~/.config/niri/config.kdl
    ```

    ```text
    spawn-at-startup "waybar"
    ```

4. 设置重启 waybar 的快捷键

    后续自定义 waybar 需要频繁更新 waybar 配置，所以设置一个重启 waybar 的快捷键。

    ```bash
    vim ~/.config/niri/config.kdl
    ```

    找到快捷键的部分，新增以下内容

    ```text
     Mod+F12 {spawn-sh "pkill waybar || true && waybar";}
    ```

    >`Mod+F12` 设置具体的快捷键为 Mod+F12。

    >`{spawn-sh "";}` 设置具体命令，与 `spawn` 不同，`spawn-sh` 可以在引号里写入完整的命令，而 `spawn` 要把命令拆开放在多个引号里。

    >`pkill waybar` 按照进程名字关闭 waybar。

    >`||` 如果左边的命令运行失败则运行右边的命令。

    >`true` 输出一个运行成功的信号。

    >`&&` 如果运行成功则运行下一条命令。

    >`waybar` 开启 waybar。

    这段命令的完整意思是：尝试 `pkill waybar` 杀死 waybar 进程，成功则运行 `waybar` 开启 waybar，失败（waybar 尚未启动的情况下 pkill 会运行失败）则运行 `true` 发送成功信号触发 `waybar` 命令开启 waybar。

### 使用我的配置

我之前直播重装 Niri 的时候新配置了一个类似 Windows 11 布局的 waybar，可以基于壁纸自动更改颜色，有兴趣的可以使用。

1. 安装依赖

    ```bash
    yay -S --needed cava grim slurp hyprpicker ddcutil-service wl-longshot-git shorin-contrib-git shorin-screenrec-menu-git wf-recorder wl-screenrec
    ```

    >`grim` 截图工具。

    >`slurp` 选取区域工具。

    >`hyprpicker` 提取屏幕颜色。

    >`ddcutil-service` ddc 调节外接屏幕亮度。

    >`wl-longshot-git` 截图模块的长截图功能。

    >`shorin-contrib-git` 更新模块、常用命令等功能。

    >`shorin-screenrec-menu-git` `wf-recorder` `wl-screenrec` 录屏模块。

    - ddcutil 安装和使用方法

         [我的 GNOME 自定义设置#调节外接屏幕亮度](我的GNOME自定义设置.md#调节外接屏幕亮度)

        需要添加组然后重启

        ```bash
        sudo gpasswd -a $USER i2c
        reboot
        ```

2. 下载我的仓库

    ```bash
    git clone https://github.com/SHORiN-KiWATA/shorin-niri.git
    ```

    找到 `dotfiles/.config/waybar-niri-LikeWin11` 文件夹，复制到 `~/.config/` 目录下，把文件夹重命名为 `waybar`，然后重启 waybar 就可以啦。

#### 根据壁纸自动更改 waybar 颜色

使用 matugen 根据壁纸生成颜色，让 waybar 自动变更颜色。

1. 安装 matugen

    ```bash
    yay -S matugen
    ```

2. 创建需要的目录和配置文件

    ```bash
    mkdir -p ~/.config/matugen
    mkdir -p ~/.config/matugen/templates
    ```

3. 复制颜色模板

    找到我文档里的 `dotfiles/.config/matugen/templates/` 目录，把 `colors.css` 文件复制粘贴到 `~/.config/matugen/templates` 目录里。

4. 编辑 matugen 配置文件

    ```bash
    vim ~/.config/matugen/config.toml
    ```

    写入如下内容：

    ```toml
    [config.wallpaper]
    command = "awww"

    [templates.waybar]
    input_path = '~/.config/matugen/templates/colors.css'
    output_path = '~/.config/waybar/colors.css'
    ```

5. 编辑 waypaper 的配置文件

    ```bash
    vim ~/.config/waypaper/config.ini
    ```

    把 `post_command` 改成：

    ```ini
    post_command = matugen image $wallpaper --source-color-index 0
    ```
    >`--source-color-index` 是新版 matugen 的选项，可以在多个 `source color` 中进行选择。

6. 使用 waypaper 切换壁纸

## Niri 配置文件修改

1. 全局窗口规则

    搜索 `geometry-corner-radius`，会搜到一个被注释掉的 window-rule，这是 Niri 默认配置配置文件自带的全局生效的窗口规则。删除前面的 `/-` 取消注释：

    ```text
    window-rule {
        //圆角
        geometry-corner-radius 8
        //剪掉圆角外的窗口内容
        clip-to-geometry true
        //透明度
        opacity 0.99
        //禁止边框画到窗口后面
        draw-border-with-background false
    }
    ```

2. 边框

    `focus-ring` 可以调整窗口的边框。

3. 隐藏窗口的标题栏

    ```text
    prefer-no-csd
    ```

4. 聚焦跟随鼠标

    搜索 `focus-follows-mouse`

5. 切换聚焦自动移动鼠标到聚焦窗口上

    搜索 `warp-mouse-to-focus`

6. 切换光标主题

    强烈推荐 breeze 光标主题
    ```bash
    sudo pacman -S breeze-cursors
    ```
    在合适的位置写入：

    ```text
    cursor {
        //鼠标的光标主题
        xcursor-theme "breeze_cursors"

        //大小
        xcursor-size 30

        //闲置 15s 自动隐藏光标
        hide-after-inactive-ms 15000

    }
    ```

## 设置 overview 背景壁纸

Mod+O 键打开的 Overview 的背景现在是灰色的，我们来设置壁纸。

任意壁纸程序都可以，这里以 awww 为例。

1. 启用壁纸程序

    awww 可以同时运行多个不同 namespace 的守护进程，所以我们可以创建一个专门用于 overview 壁纸的 awww 守护进程。

    ```bash
    awww-daemon -n overview
    ```

2. 获取 layer 的 namespace

    ```bash
    niri msg layers
    ```

    会找到 `awww-daemonoverview` 这个 layer

3. Niri 配置文件里设置 layer 规则

    通过 `place-within-backdrop true` 这个规则把刚刚运行的壁纸程序放进 overview

    ```text
    layer-rule{
        match namespace="awww-daemonoverview"
        place-within-backdrop true
    }
    ```

4. 设置一个喜欢的壁纸

    需要用 `-n` 选项指定 overview 的 awww 守护进程

    ```bash
    awww img 你喜欢的壁纸.png -n overview
    ```

然后你就可以发挥想象力了。比如利用 `imagemagick` 提供的 `magick` 命令自动把当前壁纸处理成模糊暗色版本放进 overview 之类的。

## 窗口模糊-Blur

>Niri 自 26.04 版本开始支持 Blur 效果。

编辑 Niri 配置文件

```bash
vim ~/.config/niri/config.kdl
```

以下是我的推荐配置：

```text
// --- NIRI BLUR START ---
// 顶层的 blur 配置，细节调整 blur 的效果
blur {
    passes 3
    offset 3
    noise 0.02
    saturation 1.5
}
// 全局窗口规则。让所有普通窗口以 xray 的形式显示 blur。xray 仅渲染一次模糊版本的背景，然后将其以类似"壁纸"的形式显示在窗口后面，不是实时渲染模糊，所以完全没有性能消耗。
window-rule {
    background-effect {
        xray true
        blur true
    }
}
// 浮动窗口禁用 xray 可以实时渲染模糊效果但是性能消耗高，开启 xray 会穿过浮动窗口底下的窗口直接透视到桌面。看个人喜好选择禁用与否吧。
window-rule {
    match is-floating=true
    background-effect {
        xray true
        blur true
    }
}
// fuzzel 专属的 layer 规则
layer-rule {
    match namespace="^launcher$"
    geometry-corner-radius 8
    background-effect {
        xray false
        blur true
    }
}
// --- NIRI BLUR END ---
```

## 可选：大写锁定显示

- swayosd

    ```bash
    sudo pacman -S swayosd
    ```

    开启监控输入的后端

    ```bash
    sudo systemctl enable --now swayosd-libinput-backend.service
    ```

    设置自动启动

    ```text
    spawn-at-startup "swayosd-server"
    ```

## 可选：自动登录

配置完的效果是进入 TTY1 自动登录，然后自动打开 Niri 会话。完全不用输密码，不用输命令。适合单用户单桌面会话的情况。如果你想要有一个登录界面方便管理多用户，看[ArchWiki Display Manager](https://wiki.archlinux.org/title/Display_manager)。


[ArchWiki getty](https://wiki.archlinux.org/title/Getty)

- 自动登录 TTY

  ```bash
  sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
  ```

  ```bash
  sudo vim /etc/systemd/system/getty@tty1.service.d/autologin.conf
  ```

  ```ini
  [Service]
  ExecStart=
  ExecStart=-/sbin/agetty --noreset --noclear --autologin shorin - ${TERM}
  ```

  `shorin` 改成要自动登录的账户的用户名

- 自动启动 Niri

  [Autostarting Niri without a DM](https://www.reddit.com/r/niri/comments/1kdgc08/autostarting_niri_without_a_dm/)

  ```bash
  mkdir -p ~/.config/systemd/user
  ```

  ```bash
  vim ~/.config/systemd/user/niri-autostart.service
  ```

  ```ini
  [Service]
  ExecStart=/usr/bin/niri-session

  [Install]
  WantedBy=default.target
  ```

  ```bash
  systemctl --user enable niri-autostart.service
  ```

- 重启电脑

## Reference

其他更详细的配置内容可以查阅[Niri 的官方文档](https://niri-wm.github.io/niri/)。

接下来你可以按照自己的需求决定安装什么软件。当然，你也可以选择参考我的

下一节：[软件安装相关](软件安装相关.md)
