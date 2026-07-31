目录

- [Mangowc简介](安装mangowc.md#什么是mangowc)
- [安装Fish](安装mangowc.md#可选安装fish)
- [AUR助手](安装mangowc.md#安装aur助手)
- [安装Mangowc](安装mangowc.md#安装mangowc)
- [配置文件](安装mangowc.md#默认配置文件)
- [自启动脚本](安装mangowc.md#创建程序自动启动脚本)
- [显示器配置](安装mangowc.md#显示器配置)
- [鼠标设置](安装mangowc.md#禁用鼠标加速)
- [触摸板设置](安装mangowc.md#触摸板自然滚动)
- [基础组件](安装mangowc.md#重要程序)
- [文件管理器](安装mangowc.md#gui文档管理器)
- [锁屏设置](安装mangowc.md#锁屏)
- [电源管理](安装mangowc.md#自动锁屏熄屏休眠)
- [Waybar面板](安装mangowc.md#任务栏waybar)
- [面板组件](安装mangowc.md#任务栏组件)
- [剪贴板](安装mangowc.md#剪贴板)
- [壁纸管理](安装mangowc.md#壁纸切换)
- [截图录屏](安装mangowc.md#截图和录屏)
- [系统语言](安装mangowc.md#修改系统语言为中文)
- [窗口规则](安装mangowc.md#窗口规则修复)

---

# ⚠️警告⚠️：这篇文章已经严重过时，很久不用mangowc了

本文从tty开始安装mangowc

## 什么是mangowc？

<https://github.com/DreamMaoMao/mangowc>

mangowc基于dwl开发，兼顾了轻量、动画、软件兼容，最大的特点是多布局切换。可以自由切换master、网格、滚动等布局。

- mangowc的“致命”问题

    1. 某些游戏在窗口的大小发生变化后会运行异常，包括不限于掉帧、卡顿、卡死，极其影响游戏体验。

    2. 不支持触屏和数位板

## 可选：安装fish

需要频繁用到终端，安装个fish会方便很多

```
sudo pacman -S fish
```

运行fish命令即可打开fish。如果之后想在打开终端的时候自动进入fish的话可以设置类似`kitty -e fish` `ghostty -e fish`这样的快捷键。

## [安装aur助手](../archlinux/安装桌面环境前的准备.md#aur助手)

mangowc在aur里，所以需要先安装aur助手（点击超链接可以跳转安装aur助手页面）。

## 安装mangowc

1. 安装

    ```
    yay -S mangowc-git rofi foot firefox
    ```

    没有特殊需求的话安装的时候出选项选`pipewire-jack`，字体选`noto-fonts`，其他一路回车
    `rofi`应用启动菜单
    `foot`终端
    `firefox`浏览器

2. 启动

    使用`mango`命令启动

## 默认配置文件

```
mkdir -p ~/.config/mango
cp /etc/mango/config.conf ~/.config/mango/config.conf
```

默认`alt+回车`打开`foot`，`ctrl+shift+加减号`可以缩放`foot`；`alt+空格`打开`rofi`；`alt+q`关闭窗口；`super+r`重新加载配置。

## 创建程序自动启动脚本

mangowc可以在配置里通过`exec-once`设置软件自动启动，也可以使用autostart.sh脚本，wiki似乎推荐使用脚本。

1. 创建自动程序脚本

    ```
    touch ~/.config/mango/autostart.sh
    ```

2. 添加可执行权限

    ```
    chmod +x ~/.config/mango/autostart.sh
    ```

## 显示器配置

1. 使用`wlr-randr`获取显示器信息

    ```
    sudo pacman -S wlr-randr
    ```

    ```
    wlr-randr
    ```

    记住`eDP-1`这样的接口名称，然后在mode里找到自己需要的分辨率和刷新率

2. 编辑配置文件

    ```
    vim ~/.config/mango/config.conf
    ```

    按两下g键盘跳转到文件顶部，按shift+o键在当前行的上方新建一行。

    格式：

    ```
    monitorrule=接口名称,mfact,nmaster,平铺布局,旋转,缩放,x轴,y轴,横向分辨率,竖向分辨率,刷新率
    ```

    `mfact`和`nmaster`是master布局相关的设置，`mfact`是主要区域的大小，`nmaster`是主要区域内窗口数量。

    示例：

    ```
    monitorrule=eDP-1,0.55,1,tile,0,1,0,0,2880,1800,120
    ```

    `eDP-1`是名称；0.55设置master布局主要区域大小，1设置主要区域内窗口数量为1，tile设置平铺布局（这些设置貌似都不生效，维持默认，在别的地方改就行）；0设置没有旋转；1设置缩放；0,0设置位置；2880,1800设置分辨率；120设置刷新率。

    设置完成后esc退出编辑模式，:w保存，然后使用快捷键刷新配置。

- 熄屏显示器

    使用wlr-dpms

    ```
    yay -S wlr-dpms
    ```

    获取显示器名字

    ```
    wlr-dpms query
    ```

    切换开关

    ```
    wlr-dpms eDP-1

    wlr-dpms on eDP-1

    wlr-dpms off eDP-1
    ```

- 禁用显示器

    使用wlr-randr

    ```
    wlr-randr --output eDP-1 --toggle
    ```

## 禁用鼠标加速

左斜杠搜索mouse。`accel_profile=1`可以关闭鼠标/触摸板加速，`accel_speed`可以设置鼠标/触摸板速度。

设置完成后需要重新开启一次mangowc。

## 触摸板自然滚动

`touchpad_natural_scrolling`的值为1可以设置自然滚动。

## 重要程序

1. 安装

    ```
    sudo pacman -S xorg-xwayland libnotify mako polkit-gnome 
    ```

    `xorg-xwayland`提供xwayland功能

    `libnotify`是通知相关的库

    `mako`提供通知功能

    `polkit-gnome`让软件能够询问管理员权限

2. 设置自动启动

    ```
    vim ~/.config/mango/autostart.sh
    ```

    写入

    ```
    #!/bin/bash

    # 通知程序
    mako & 

    # 权限询问
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & 
    ```

3. 重启mangowc

## GUI文档管理器

> [Xfce4-Projects](https://www.xfce.org/projects)

可以按照你的喜好安装文档管理器和对应的xdg桌面门户，比如dolphin对应xdg-desktop-portal-kde，nautilus对应xdg-desktop-portal-gnome。我比较喜欢thunar。

```
sudo pacman -S xdg-desktop-portal-gtk thunar tumbler ffmpegthumbnailer poppler-glib gvfs-smb file-roller thunar-archive-plugin gnome-keyring icoextract
```

出选项的话选`pipewire-jack`

`xdg-desktop-portal-gtk`提供文件选取等功能

`tumbler`提供图片预览功能

`ffmpegthumbnailer`视频预览

`poppler-glib`pdf预览

`gvfs-smb` 检查可挂载的外部设备，访问smb分享等功能

`file-roller` 提供压缩解压缩功能

`thunar-archive-plugin`在thunar的右键菜单添加压缩解压缩选项

`gnome-keyring`提供密码保存功能。第一次保存密码会让你设置keyring的密码，可以空着。

`icoextract`exe缩略图

其他thunar的额外功能可以看[archwiki的thunar页面](https://wiki.archlinux.org/title/Thunar)

- 设置快捷键

   ```
   vim ~/.config/mango/config.conf
   ```

   左斜杠搜索bind，在合适的写入以下内容设置一个打开thunar的快捷键（如果你用的是我的配置文件的话已经配置好了）

   ```
   bind=SUPER,e,spawn,thunar
   ```

### 右键从此处打开终端

点击左上角编辑（edit） > 配置自定义动作（configure custom actions） > 选中open in terminal here > 点击小齿轮 > 命令改成`kitty -e fish`

### 更改默认终端为kitty

安装`xdg-terminal-exec`

```
yay -S xdg-terminal-exec
```

编辑`~/.config/xdg-terminals.list`

```
echo "kitty.desktop" > ~/.config/xdg-terminals.list
```

如果有多个终端的话就按照顺序写多行。

### 生成home目录下的目录

> [Archwiki-XDG-user-directories](https://wiki.archlinux.org/title/XDG_user_directories)

```
sudo pacman -S xdg-user-dirs
xdg-user-dirs-update
```

## 锁屏

hyprland的部分使用了hyprlock，这里也可以使用hyprlock，为了新鲜感我装个swaylock-effects

1. 安装

    ```
    yay -S swaylock-effects
    ```

2. 创建配置文件

    ```
    mkdir -p ~/.config/swaylock
    touch ~/.config/swaylock/config
    ```

3. 编辑配置文件

    ```
    vim ~/.config/swaylock/config
    ```

    写入：

    ```
    screenshots
    clock
    indicator
    indicator-radius=200
    indicator-thickness=15
    effect-blur=10x5
    ```

    `screenshots`让锁屏显示桌面

    `effect-blur=10x5`设置模糊

    `indicator`显示屏幕中间显示一个圆环

    `clock`显示时钟

    `indicator-radius=200`圆环大小

    `indicator-thickness=15`圆环粗细

    更详细的配置可以看官方文档[swaylock-effects](https://github.com/mortie/swaylock-effects)

4. 设置快捷键

    ```
    vim ~/.config/mango/config.conf
    ```

    我设置了super+alt+L锁屏

    ```
    bind=SUPER+ALT,L,spawn,swaylock
    ```

    保存后重新加载一次mango的配置，我设置的快捷键是super+f1，默认是super+r

## 自动锁屏/熄屏/休眠

hypridle的配置更加简单所以继续用hypridle

1. 安装

    ```
    sudo pacman -S hypridle brightnessctl
    ```

2. 配置文件

    ```
    mkdir -p ~/.config/hypr
    vim ~/.config/hypr/hypridle.conf
    ```

    [复制wiki底下的示例配置](https://wiki.hypr.land/Hypr-Ecosystem/hypridle/)

    把`lock_cmd`里的hyprlock改成swaylock

    再把所有的`hyprctl dispatch dpms off`改成`wlr-dpms off`

    所有的`hyprctl dispatch dpms on`改成`wlr-dpms on`

3. 设置自动启动

    ```
    vim ~/.config/mango/autostart.sh
    ```

    ```
    hypridle & 
    ```

4. 现在启动

    ```
    hypridle & disown
    ```

## 任务栏waybar

1. 安装

    ```
    sudo pacman -S waybar ttf-jetbrains-mono-nerd otf-font-awesome
    ```

2. 下载默认配置

    [在这里下载默认的waybar配置](https://github.com/Alexays/Waybar/tree/master/resources)，分别是config.jsonc、style.css，还有custom_modules目录里的power_menu.xml。把这三个文件剪贴到`~/.config/waybar`目录。

3. 修改默认配置

    在配置文件的底部，把shutdown改成poweroff。

    然后[在这里复制](https://github.com/DreamMaoMao/mangowc/wiki#config)或者在下面复制mangowcwiki里的waybar模块配置，粘贴到config.jsonc文件末尾最后一个大括号的上面，注意在原先的倒数第二个大括号后面加上逗号。

    ```
    "ext/workspaces": {
    "format": "{icon}",
    "ignore-hidden": true,
    "on-click": "activate",
    "on-click-right": "deactivate",
    "sort-by-id": true,
    },
    "dwl/tags": {
      "num-tags":9,
    },
    "dwl/window": {
      "format": "[{layout}]{title}"
    },
    ```

    然后把文件开头modules-left里面的"sway/workspaces"改成"ext/workspaces"，把"sway/window"改成"dwl/window"。

4. 修改字体

    打开style.css

    在`font-family:`的部分添加`JetBrainsMono NFP,`，修改后是这样的：

    ```
    font-family: JetBrainsMono NFP, FontAwesome, Roboto ......;
    ```

5. 现在启动waybar

    ```
    waybar & disown
    ```

6. 设置重启waybar的快捷键

    ```
    vim ~/.config/mango/config.conf
    ```

    左斜杠搜索bind，在合适的位置新建（我的配置文件里已经有了，super+f2键重启waybar）：

    ```
    bind=SUPER,F2,spawn_shell,pkill waybar || true && waybar
    ```

7. 自动启动

    需要编辑autostart.sh

    ```
    vim ~/.config/mango/autostart.sh
    ```

    新增：

    ```
    waybar &
    ```

## 任务栏组件

- 网络

    1. 安装

    ```
    sudo pacman -S --needed networkmanager network-manager-applet dnsmasq
    ```

    `networkmanager``network-manager-applet`提供联网功能和网络组件

    `dnsmasq`高级网络配置工具需要

    1. 现在启动

    ```
    nm-applet & disown
    ```

    可以看到waybar的托盘里出现网络组件
    3. 自动启动

    需要编辑autostart.sh

    ```
    vim ~/.config/mango/autostart.sh
    ```

    新增：

    ```
    nm-applet &
    ```

    1. 浮动模式打开
    `nm-connection-editor`打开高级网络配置工具，然后`mmsg -w`获取appid

    编辑配置文件新增窗口规则

    ```
    windowrule=isfloating:1,appid:nm-connection-editor
    ```

- 蓝牙

    1. 安装

    ```
    sudo pacman -S --needed bluez blueman
    ```

    ```
    sudo systemctl enable --now bluetooth
    ```

    `blueman-manager`启动gui。

    1. 现在启动

    ```
    blueman-applet & disown
    ```

    可以看到waybar的托盘里出现蓝牙组件

    1. 自动启动

    ```
    vim ~/.config/mango/autostart.sh
    ```

    新增：

    ```
    blueman-applet &
    ```

    1. 浮动模式打开

    ```
    windowrule=isfloating:1,appid:blueman-manager
    ```

- 性能模式切换

    ```
    sudo pacman -S power-profiles-daemon
    ```

    ```
    sudo systemctl enable --now power-profiles-daemon 
    ```

    安装完成后使用快捷键重启waybar，或者终端运行`pkill waybar && waybar`重启waybar。

## 剪贴板

使用开箱即用的copyq

1. 安装

    ```
    sudo pacman -S copyq
    ```

2. 现在启动

    ```
    copyq & disown 
    ```

    可以看到任务栏托盘出现一把小剪刀，左键可以打开剪贴板。
3. 自动启动

    ```
    vim ~/.config/mango/autostart.sh
    ```

    ```
    copyq &
    ```

4. 设置快捷键

    ```
    vim ~/.config/mango/config.conf
    ```

    ```
    bind=SUPER+ALT,v,spawn,copyq toggle
    ```

    我的配置里已经有了。
5. 以浮动窗口打开

    终端运行`mmsg -w`命令，然后打开copyq，聚焦之后可以在终端的输出里找到copyq的appid和title。

    ```
    vim ~/.config/mango/config.conf
    ```

    按shift+g键到文件底部，新增：

    ```
    windowrule=isfloating:1,width:500,height:500,appid:com.github.hluk.copyq
    ```

    这段配置设置一个新的窗口规则，具体内容为：浮动窗口、宽500、高500，然后用appid指定规则应用的窗口为copyq。

    保存后刷新一次mango，我设置的快捷键是super+f1，默认是super+r。

## 壁纸切换

1. 安装

    ```
    yay -S awww waypaper-git
    ```

    `awww`提供带动画的壁纸切换功能

    `waypaper`是gui

2. 设置自动启动

    ```
    vim ~/.config/mango/autostart.sh
    ```

    新增

    ```
    awww-daemon &
    ```

3. 使用waypaper切换壁纸
    可以从菜单启动waypaper，或者运行`waypaper`命令启动

4. 设置快捷键

    我的配置里设置的是super+alt+w

    ```
    bind=SUPER+ALT,W,spawn,waypaper
    ```

5. 浮动窗口模式打开

    `mmsg -w`获取窗口信息，然后新增一个窗口规则：

    ```
    windowrule=isfloating:1,appid:waypaper
    ```

    保存后重新加载一次mango的配置

## 截图和录屏

- 依赖

    ```
    sudo pacman -S --needed xdg-desktop-portal-wlr xdg-desktop-portal-hyprland grim slurp wl-clipboard
    ```

    ps：wiki说只要装wlr的xdp就好了，但是我发现必须装上hyprland的xdp才能解决无法录制高帧率视频的问题。

    ```
    vim ~/.config/mango/autostart.sh
    ```

    ```
    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots

    /usr/lib/xdg-desktop-portal-wlr &
    ```

    ```
    reboot
    ```

- 截图

    1. 安装

        推荐使用gradia

        ```
        yay -S gradia
        ```

        ```
        gradia --screenshot
        ```

    2. 禁用slurp的blur效果

        获取layer名称

        ```
        mmsg -e
        ```

        编辑配置文件设置layer规则

        ```
        vim ~/.config/mango/config.conf
        ```

        ```
        layerrule=layer_name:selection,noblur:1
        ```

        保存后重载mango。

    3. 以浮动模式打开gradia

        获取窗口信息

        ```
        mmsg -w
        ```

        ```
        windowrule=isfloating:1,appid:be.alexandervanhee.gradia
        ```

        保存后重载mango

    4. 设置快捷键

        我的配置里是super+shift+S

        ```
        bind=SUPER+SHIFT,s,spawn,gradia --screenshot
        ```

    5. 拓展内容

        很多时候我们只是想快速截个图保存到剪贴板，所以每次截图完都会打开编辑工具可能有点不方便。为此，可以直接使用grim+slurp+wl-clipboard做到基本的截图功能

        ```
        sudo pacman -S wl-clipboard
        ```

        运行这段命令截图：

        ```
        grim -g "$(slurp)" - | wl-copy
        ```

        打开copyq剪贴板就能看到截图保存到了剪贴板。

        可以设置一个快捷键，我的配置里是super+alt+a

        ```
        bind=SUPER+ALT,a,spawn_shell,grim -g "$(slurp)" - | wl-copy
        ```

- 录屏

    推荐使用kooha和obs

    ```
    yay -S kooha
    ```

## 修改系统语言为中文

利用wm的配置文件设置系统语言。

设置时一定要让`LANG`为英文，否则中文输入法会出现异常，然后通过`LC_MESSAGES`变量设置主要界面的语言为中文。

```
vim ~/.config/mango/config.conf
```

```
env=LC_MESSAGES,zh_CN.UTF-8
```

- 如果是archinstall安装，需要进行如下操作：

  1. ```
     sudo vim /etc/locale.gen 
     ```

  2. 左斜杠键搜索，取消`zh_CN.UTF-8`的注释

  3. ```
     sudo locale-gen
     ```

  4. 登出

重启mango

## 窗口规则修复

在我的配置文件的底部设置了一些窗口规则，修复了一些不合适的窗口动画和窗口效果。

## 其他重要的通用配置

- [中文输入法](../archlinux/中文输入法.md)

## 下一节：[软件安装相关](../archlinux/软件安装相关.md)
