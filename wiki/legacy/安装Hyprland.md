目录

- [⚠️这一章内容已经严重过时](#这一章内容已经严重过时)
  - [可选：更换 shell 为 fish](#可选更换-shell-为-fish)
  - [安装 hyprland](#安装-hyprland)
  - [修改系统语言](#修改系统语言)
  - [显示器设置](#显示器设置)
  - [禁用鼠标加速](#禁用鼠标加速)
  - [触摸板自然滚动](#触摸板自然滚动)
  - [xwayland 缩放问题](#xwayland-缩放问题)
  - [安装必要软件](#安装必要软件)
  - [GUI 文档管理器](#gui-文档管理器)
    - [右键从此处打开终端](#右键从此处打开终端)
    - [更改默认终端为 kitty](#更改默认终端为-kitty)
    - [生成 home 目录下的目录](#生成-home-目录下的目录)
  - [桌面套件](#桌面套件)
    - [程序启动器](#程序启动器)
  - [蓝牙](#蓝牙)
  - [锁屏](#锁屏)
  - [剪贴板](#剪贴板)
  - [截图](#截图)
  - [中文输入法](#中文输入法)
  - [flatpak](#flatpak)
  - [下一节：软件安装相关](#下一节软件安装相关)

# ⚠️这一章内容已经严重过时

hyprland 从 0.55 版本开始用 lua 替代原本的 hyprlang 作为配置文件的语言，配置流程不变，但配置的具体写法已经完全不同，我还没更新。

---
这部分是在 tty 从零开始安装一个**功能完备**的 hyprland，以方便为主而不是以符合 WM 的理念为主，如果已经安装了其他桌面环境的话有些流程会略有不同。


## 可选：更换 shell 为 fish

> [FishShell](https://fishshell.com/)

由于要频繁用到终端，安装 fish 更加便利。

安装：

```
sudo pacman -S fish
```

运行 fish 命令就可以打开 fish 了。

如果想在打开终端的时候自动进入 fish 的话可以设置类似 `kitty -e fish` `ghostty -e fish` 这样的快捷键。

## 安装 hyprland

> [Hyprland-Installation](https://wiki.hypr.land/Getting-Started/Installation/)

```
sudo pacman -S hyprland kitty firefox
```
>`hyprland` 本体。

>`kitty` 是 hyprland 默认的终端仿真器，如果你已经安装了别的桌面环境可以不装 `kitty`。

>`firefox` 是 Linux 最好用的浏览器。

- 基础使用方法

   tty 运行 `start-hyprland` 命令打开会话，或者在显示管理器切换为 hyprland 会话。super+Q 打开 kitty；super+C 关闭窗口。

   虽然 hyprland 新版本增加了引导程序，但是为了学会使用 WM，这里依旧手动配置。

- 修改默认终端

   1. 运行一次 `start-hyprland` 生成默认配置文件。

   2. super+M 退出 hyprland。

   3. 编辑配置文件

      ```
      vim ~/.config/hypr/hyprland.conf
      ```
      把 `$terminal= kitty` 的 `kitty` 改成你使用的终端。

- 设置 kitty 默认 shell 为 fish

   ```
   mkdir -p ~/.config/kitty/kitty.conf
   vim ~/.config/kitty/kitty.conf
   ```

   ```
   shell fish
   ```

   美化 kitty 的部分在这里：[kitty 美化](../archlinux/终端美化.md#kitty美化)

## 修改系统语言

利用配置文件提供的环境变量功能设置 LANG 系统语言。设置时一定要让 LC_CTYPE 为英文，否则中文输入法会出现异常。

配置文件顶端写入：

```
env = LANG,zh_CN.UTF-8
env = LC_CTYPE,en_US.UTF-8
```
重新开启 hyprland 即可。

- 如果是 archinstall 安装，需要进行如下操作：

  1. ```
     sudo vim /etc/locale.gen
     ```

   2. 左斜杠键搜索，取消 `zh_CN.UTF-8` 的注释。

  3. ```
     sudo locale-gen
     ```

   4. 登出。

## 显示器设置

> [Hyprland-Monitors](https://wiki.hypr.land/0.52.0/Configuring/Monitors/)

```
hyprctl monitors all
```
假设是 eDP-1，分辨率 2k，刷新率 165：
```
vim ~/.config/hypr/hyprland.conf
```
```
monitor=eDP-1,2560x1440@165,0x0,1.6
```
从左到右分别是"显示器，分辨率@刷新率，位置，缩放"。

如果是多显示器的话，把最左上角的显示器的位置设置为 0x0。假设 eDP-1 在最左上角，我第二个显示器想放在 eDP-1 的右边，就计算一下 x 的值，2560/1.6=1600，第二个显示器位置的 x 值就是 1600。y 同理。

```
monitor=DP-2,2560x1440@180,1600x0,1
```

## 禁用鼠标加速

> [Hyprland-Input](https://wiki.hypr.land/0.52.0/Configuring/Variables/#input)

```
vim ~/.config/hypr/hyprland.conf
```

修改 `input{}`，写入 `accel_profile = flat`：

```
input{
    accel_profile = flat
}
```

## 触摸板自然滚动

`natural_scroll=false` 的 `false` 改成 `true`。

## xwayland 缩放问题

> [Hyprland-XWayland](https://wiki.hypr.land/0.52.0/Configuring/XWayland/)

xwayland 软件在 hyprland 会像素化，需要在 hyprland 配置文件新增 `xwayland{}`，填入 `force_zero_scaling=true`。

```
xwayland{
	force_zero_scaling=true
}
```
然后可以使用软件自己的缩放功能。

或者使用 `xrdb`：

```
sudo pacman -S xorg-xrdb
```
```
echo "Xft.dpi: 140" | xrdb -merge
```
但是 xrdb 的效果并不好。

## 安装必要软件

> [Hyprland-Must-have](https://wiki.hypr.land/Useful-Utilities/Must-have/) | [ArchWiki XDG Desktop Portal](https://wiki.archlinux.org/title/XDG_Desktop_Portal)

1. 安装

    ```
    sudo pacman -S libnotify xdg-desktop-portal-hyprland hyprpolkitagent qt5-wayland qt6-wayland
    ```

    `libnotify` 是通知相关的库。

    `xdg-desktop-portal-hyprland` `xdg-desktop-portal-gtk` 提供屏幕分享、全局快捷键、选取文件等功能。如果你已经安装了桌面环境这里装只装 hyprland 的 portal 就可以了。

    `hyprpolkitagent` 软件会通过这个软件询问管理员权限。

    `qt5-wayland qt6-wayland` Qt wayland 库。

2. 配置重要程序开机自启

    ```
    vim ~/.config/hypr/hyprland.conf
    ```

    搜索 `exec-once`。在合适的地方写入：

    ```
    exec-once = mako
    exec-once = /usr/lib/hyprpolkitagent/hyprpolkitagent
    ```

    super+M 退出 hyprland，重新打开。

## GUI 文档管理器

> [Xfce4-Projects](https://www.xfce.org/projects)

最适合 `xdg-desktop-portal-gtk` 的文档管理器是 thunar，内存占用极低，仅 50MB。

```
sudo pacman -S xdg-desktop-portal-gtk thunar tumbler ffmpegthumbnailer poppler-glib gvfs-smb file-roller thunar-archive-plugin  gnome-keyring
```

出选项的话选 `pipewire-jack`。

>`tumbler` 提供图片预览功能。

>`ffmpegthumbnailer` 视频预览。

>`poppler-glib` PDF 预览。

>`gvfs-smb` 检查可挂载的外部设备，访问 smb 分享等功能。

>`file-roller` 提供压缩解压缩功能。

>`thunar-archive-plugin` 在 thunar 的右键菜单添加压缩解压缩选项。

>`gnome-keyring` 提供密码保存功能。第一次保存密码会让你设置 keyring 的密码，可以空着。

>`icoextract` exe 缩略图。

更多 thunar 的额外功能可以看[ArchWiki 的 thunar 页面](https://wiki.archlinux.org/title/Thunar)。

- 设置快捷键

   ```
   vim ~/.config/hypr/hyprland.conf
   ```
   搜索 `dolphin`，改成 `thunar`。默认快捷键是 mainMod+E。


### 右键从此处打开终端

点击左上角编辑 > 配置自定义动作 > 选中 open in terminal here > 点击小齿轮 > 命令改成 `kitty`。

### 更改默认终端为 kitty


安装 `xdg-terminal-exec`：

```
yay -S xdg-terminal-exec
```

编辑 `~/.config/xdg-terminals.list`：

```
echo "kitty.desktop" > ~/.config/xdg-terminals.list
```
如果有多个终端的话就按照顺序写多行。

### 生成 home 目录下的目录

> [ArchWiki XDG user directories](https://wiki.archlinux.org/title/XDG_user_directories)

```
sudo pacman -S xdg-user-dirs
LANGUAGE=en_US.UTF-8 xdg-user-dirs-update --force
```

>`LANG=en_US.UTF-8` 会生成英文的目录，方便终端中使用。

>`--force` 如果你已经有了中文的目录，这个选项会强制覆盖。

## 桌面套件

推荐使用 quickshell，dms。

```
yay -S dms-shell
```

在 hyprland 配置文件中设置自动启动：

```
exec-once = dms run
```

### 程序启动器

把配置文件中的 `hyprlauncher` 改成 `dms ipc call launcher toggle`。

## 蓝牙

> [ArchWiki Bluetooth](https://wiki.archlinux.org/title/Bluetooth)

```
sudo pacman -S --needed bluez
```
```
sudo systemctl enable --now bluetooth
```

## 锁屏

设置快捷键：

```
bind = $mainMod, L, exec, dms ipc call lock lock
```

## 剪贴板

```
sudo pacman -S wl-clipboard cliphist
```

## 截图

```
yay -S satty slurp grim
```
- 截图仅保存到剪贴板：

  ```
  bind = $mainMod, A, exec, grim -g "$(slurp)" - | wl-copy
  ```

- 编辑截图

  ```
  bind = $mainMod, A, exec, grim -g "$(slurp)" - | satty -f -
  ```

- 设置 satty 以浮动模式打开

   打开 satty 窗口后

   ```
   hyprctl clients
   ```
   ```
   windowrule {
   	# 这个窗口规则的名字
   	name = satty
   	# 应用的窗口
   	match:class = com.gabm.satty
   	# 浮动
   	float = yes
   }
   ```
- 设置 satty 的复制命令为 `wl-copy`

   ```
   mkdir -p ~/.config/satty
   vim ~/.config/satty/config.toml
   ```

   ```
   [general]
   copy-command = "wl-copy"
   focus-toggles-toolbars= true
   actions-on-right-click = ["save-to-clipboard"]
   ```

## 中文输入法

0. 需要[添加 archlinuxcn](../archlinux/安装桌面环境前的准备.md#aur助手)。

1. 安装

   看中文输入法一节：[中文输入法](../archlinux/中文输入法.md)

2. 环境变量

   ```
   env = XMODIFIERS,@im=fcitx
   ```

3. 现在启动

   ```
   fcitx5 -d
   ```

4. 自动启动

   ```
   exec-once = fcitx5 -d
   ```

## flatpak

在[安装桌面环境前的准备](../archlinux/安装桌面环境前的准备.md)一节中我们已经配置了 flatpak，可以安装一个 GUI。

```
sudo pacman -S bazaar
```

## 下一节：[软件安装相关](../archlinux/软件安装相关.md)