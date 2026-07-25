这里是我遇到的问题以及对应的解决方案。

- [efibootmgr里面有超级多启动项](#efibootmgr里面有超级多启动项)
- [主板能识别系统盘但无法进入 GRUB](#主板能识别系统盘但无法进入-grub)
- [KDE开机会卡住，必须重启sddm才好](#kde开机会卡住必须重启sddm才好)
- [磁盘占用异常](#磁盘占用异常)
- [提示没有编解码器](#提示没有编解码器)
- [Nautilus无法访问SMB共享](#nautilus无法访问smb共享)
- [域名解析出现暂时性错误](#域名解析出现暂时性错误)
- [扩展Windows的EFI分区空间](#扩展windows的efi分区空间)
- [grub卡顿](#grub卡顿)
- [virsh不显示虚拟机加上sudo后显示](#virsh不显示虚拟机加上sudo后显示)
- [GNOME混合模式独显占用异常](#gnome混合模式独显占用异常)
- [fuzzel无法打开终端程序](#fuzzel无法打开终端程序)
- [thunar的压缩解压缩软件不生效](#thunar的压缩解压缩软件不生效)
- [Nautilus等GTK4应用启动慢](#nautilus等gtk4应用启动慢)
- [gnome的设置中心无法在窗口管理器打开](#gnome的设置中心无法在窗口管理器打开)
- [软件缩放问题](#软件缩放问题)
- [btrfs-assistant没有同步matugen主题](#btrfs-assistant没有同步matugen主题)
- [GTK4软件无法即时切换主题](#gtk4软件无法即时切换主题)
- [QQ用Wayland运行时剪贴板异常](#qq用wayland运行时剪贴板异常)
- [quickshell图标缺失](#quickshell图标缺失)
- [NetworkManager切换到IWD后端后使用impala联网提示operation aborted](#networkmanager切换到iwd后端后使用impala联网提示operation-aborted)
- [OBS导致显卡占用飙升进而导致游戏帧数大幅下降](#obs导致显卡占用飙升进而导致游戏帧数大幅下降)
- [天选4锐龙版2023使用Niri关闭屏幕后会自己亮屏](#天选4锐龙版2023使用niri关闭屏幕后会自己亮屏)
- [以英文的LC\_CTYPE环境变量启动steam导致无法进行中文输入](#以英文的lc_ctype环境变量启动steam导致无法进行中文输入)
- [btop无法显示AMD核显信息](#btop无法显示amd核显信息)

## efibootmgr里面有超级多启动项

这是之前其他系统和网络设备的残留的 NVRAM。用 efibootmgr 清理。

用这条命令列出所有的启动项：

```bash
sudo efibootmgr -v
```

找到无用的项目对应的编号删除：

```bash
sudo efibootmgr -b 0001 -B
```

此处的 0001 是编号。

## 主板能识别系统盘但无法进入 GRUB

此问题常见于安装系统的 EFI 设置时没有添加 --removable 参数，而实际使用过程中又出现了主板恢复默认设置、更新固件、清除 EFI 启动变量，或者将系统盘移动到另一台电脑，原有的 NVRAM 启动项可能不存在等情况导致。

Linux 出现问题无法进入系统基本都是引导问题，修复首先要准备一块Linux Live启动盘，建议使用 Ventoy 里面放 ArchLinux 安装介质或 Ubuntu 24.04 LTS 的 iso文件作为系统出问题时救急启动盘。

### 问题现象

BIOS 或 UEFI 设置界面能够识别安装 Arch Linux 的系统盘，但选择该硬盘启动后，屏幕短暂变黑，随后返回 BIOS，无法显示 GRUB 菜单。

如果 EFI 系统分区中的 `grubx64.efi`、GRUB 配置文件、内核和 initramfs 仍然存在，这通常不是 Arch Linux 系统文件损坏，而是主板 UEFI NVRAM 中的 GRUB 启动项丢失或失效。

常规 GRUB UEFI 安装由两部分组成：

1. EFI 系统分区中的 GRUB EFI 程序，例如 `/efi/EFI/ARCH/grubx64.efi`；
2. 主板 NVRAM 中指向该文件的 UEFI 启动项。

EFI 文件存储在硬盘中，而 NVRAM 启动项存储在主板固件中。即使硬盘里的文件完整，启动项丢失后，主板也可能无法找到 GRUB。

### 排查方法

可以使用 Ubuntu 镜像启动 Live 环境，也可以使用 Arch Linux 安装介质启动，并确保安装介质本身以 UEFI 模式启动：

    test -d /sys/firmware/efi && echo "UEFI mode" || echo "Legacy mode"

如果输出 `Legacy mode`，需要重新启动并从主板启动菜单选择安装介质的 UEFI 启动项。

查看当前 UEFI 启动项：

    efibootmgr -v

如果输出中没有 Arch Linux、GRUB 或安装时设置的 `bootloader-id`，说明对应启动项可能已经丢失。

查看磁盘分区：

    lsblk -f

下面以本教程安装的方案([ArchLinux安装系统](./安装ArchLinux.md#手动安装))为例：

- 系统盘为 `/dev/nvme0n1`；
- EFI 系统分区为 `/dev/nvme0n1p1`；
- Btrfs 根分区为 `/dev/nvme0n1p2`；
- 根子卷为 `@`；
- EFI 系统分区在系统中挂载到 `/efi`；
- `bootloader-id` 为 `ARCH`。

实际操作时需要根据自己的分区情况替换设备名。

挂载系统根子卷和 EFI 系统分区：

    mount -o subvol=@ /dev/nvme0n1p2 /mnt
    mount --mkdir /dev/nvme0n1p1 /mnt/efi

检查 GRUB EFI 文件：

    find /mnt/efi/EFI -maxdepth 2 -type f -iname '*.efi'

正常情况下应当能看到类似文件：

    /mnt/efi/EFI/ARCH/grubx64.efi

### EFI 文件仍然存在

如果 `grubx64.efi` 仍然存在，可以直接重新创建 UEFI NVRAM 启动项：

    efibootmgr --create --disk /dev/nvme0n1 --part 1 --label "Arch Linux" --loader '\EFI\ARCH\grubx64.efi'

参数说明：

`--disk` 指定 EFI 系统分区所在的硬盘；

`--part` 指定 EFI 系统分区在该硬盘上的分区编号；

`--label` 设置 UEFI 启动菜单中显示的名称；

`--loader` 指定 GRUB EFI 程序在 EFI 系统分区中的路径。

再次检查：

    efibootmgr -v

应当能看到类似内容：

    Boot0006* Arch Linux HD(...)File(\EFI\ARCH\grubx64.efi)

其中启动项编号不一定是 `0006`。

可以将新启动项设置为仅在下一次启动时使用：

    efibootmgr --bootnext 0006

将 `0006` 替换为实际生成的启动项编号，然后重新启动测试：

    reboot

### EFI 文件丢失或无法正常加载

如果 `/EFI/ARCH/grubx64.efi` 不存在，或者重新创建启动项后仍无法加载 GRUB，则进入已安装的 Arch Linux 系统环境重新安装 GRUB：

    arch-chroot /mnt

重新执行常规安装：

    grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/efi --bootloader-id=ARCH

同时安装 UEFI 默认后备启动入口：

    grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/efi --removable --no-nvram

重新生成 GRUB 配置：

    grub-mkconfig -o /boot/grub/grub.cfg

检查两个 EFI 程序是否存在：

    ls -l /efi/EFI/ARCH/grubx64.efi
    ls -l /efi/EFI/BOOT/BOOTX64.EFI

退出 chroot 并重新启动：

    exit
    reboot

正常情况下，主板优先使用 NVRAM 中的 Arch Linux 启动项。该启动项再次丢失时，可以在主板启动菜单中选择系统盘本身，由固件尝试加载默认后备路径 `/EFI/BOOT/BOOTX64.EFI`。


## KDE开机会卡住，必须重启sddm才好

显卡驱动没加载完 SDDM 就加载导致的卡死。让 SDDM 晚点加载就可以解决。

```bash
sudo systemctl edit sddm.service
```

```ini
[Service]
ExecStartPre=/bin/sleep 2
```

```bash
sudo systemctl daemon-reload
```

或者试试参考这个 issue：[24#issue](https://github.com/SHORiN-KiWATA/ShorinArchExperience-ArchlinuxGuide/issues/24#issue-3745629323)

## 磁盘占用异常

明明没有多少文件，磁盘占用却很高。可以试试删除 btrfs 快照。

## 提示没有编解码器

安装的时候应该自带了编解码器，可能是删除别的软件时不小心连带着删掉了，重新安装即可：

```bash
sudo pacman -S gst-plugins-good gst-libav libde265
```

## Nautilus无法访问SMB共享

如果你的路由器或者别的设备开启了 SMB 文件共享，安装 gvfs-smb 可以使你在 Nautilus 访问那些文件。

```bash
sudo pacman -S gvfs-smb
```

## 域名解析出现暂时性错误

> [解决 Ubuntu 系统中 "Temporary Failure in Name Resolution" 错误-CSDN博客](https://blog.csdn.net/qq_15603633/article/details/141032652)

```bash
sudo vim /etc/resolv.conf
```

内容修改为：

```text
nameserver 8.8.8.8
nameserver 8.8.4.4
```

## 扩展Windows的EFI分区空间

NIUBI Partition Editor free edition 使用这个工具。

## grub卡顿

N 卡的锅，没辙。

## virsh不显示虚拟机加上sudo后显示

因为虚拟机被创建在系统范围的 QEMU 连接里了。

```bash
sudo vim /etc/environment
```

写入：

```text
VIRSH_DEFAULT_CONNECT_URI=qemu:///system
```

## GNOME混合模式独显占用异常

```bash
sudo pacman -S vulkan-mesa-layers
```

## fuzzel无法打开终端程序

```bash
vim .config/fuzzel/fuzzel.ini
```

```ini
terminal=kitty -e
```

## thunar的压缩解压缩软件不生效

配置自定义动作：

- 解压到此处

   ```bash
   file-roller --extract-here %F
   ```

   出现条件勾选除了目录之外的，然后文件类型填写：

   ```text
   *.zip;*.tar;*.tar.gz;*.tgz;*.tar.bz;*.tbz;*.tar.bz2;*.tbz2;*.tar.Z;*.taz;*.tar.xz;*.tar.lz;*.tlz;*.tar.lzo;*.tzo;*.tar.lzma;*.7z;*.rar;*.cbr;*.cab;*.arj;*.cpio;*.deb;*.rpm;*.xar;*.jar;*.war;*.ear;*.iso;*.lha;*.lzh;*.alz;*.ace;*.zoo;*.cbz;*.gz;*.bz;*.bz2;*.xz;*.Z;*.lz;*.lzo;*.lzma;*.zst;*.br;*.lrz;*.rzip
   ```

- 创建压缩包

   ```bash
   file-roller --add %F
   ```

   出现条件勾选所有。

## Nautilus等GTK4应用启动慢

因为 GTK4 使用了新的渲染器，而新的渲染器和 N 卡的 'nvidia-utils' 产生了兼容性问题，设置环境变量使用旧的 GL 渲染器可以解决。

```bash
env GSK_RENDERER=gl nautilus
```

也可以在 `/etc/environment` 设置全局环境变量或者在 `~/.config/environment.d/myenv.conf` 设置用户空间的环境变量（需要重新登录）。

窗口管理器可以在配置文件里修改环境变量。

- Niri

   ```text
   environment {
      GSK_RENDERER "gl"
   }
   ```

## gnome的设置中心无法在窗口管理器打开

因为 gnome-control-center 只能在 GNOME 桌面环境打开：

```bash
env XDG_CURRENT_DESKTOP=gnome gnome-control-center
```

## 软件缩放问题

详情看这个网址：<https://wiki.archlinuxcn.org/wiki/HiDPI#GTK+_2>

[archwiki_hdpi](https://wiki.archlinux.org/title/HiDPI)

最常见的 Fcitx5 候选框过小问题也可以使用这个方法。

1. 安装 xorg-xrdb

   ```bash
   sudo pacman -S xorg-xrdb
   ```

2. 计算 DPI

   用标准 DPI 乘屏幕缩放，标准 DPI 通常是 96。1.5 倍缩放就是：96x1.5=144。

3. xrdb 调整缩放

   - 命令

      ```bash
      echo "Xft.dpi: 144" | xrdb -merge
      ```

      运行这个只是临时生效，想永久生效的话可以设置此命令自动启动。

   - 配置文件

      `~/.Xresources` 里写入：Xft.dpi: 144。

## btrfs-assistant没有同步matugen主题

因为是以 root 运行的，root 用户有自己的配置文件夹。

```bash
sudo ln -sf $HOME/.config/qt5ct /root/.config/qt5ct
sudo ln -sf $HOME/.config/qt6ct /root/.config/qt6ct
sudo ln -sf $HOME/.config/kdeglobals /root/.config/kdeglobals
```

## GTK4软件无法即时切换主题

可以通过切换暗色浅色的方式做到即时切换：

```bash
gsettings set org.gnome.desktop.interface color-scheme "prefer-light" && gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
```

## QQ用Wayland运行时剪贴板异常

因为此时 QQ 无法使用 Wayland 剪贴板，且因为是 Wayland 运行，无法触发 Wayland 和 XWayland 的剪贴板同步功能。

尝试以下操作：

1. QQ 里复制点东西。

2. 终端打印 X11 剪贴板里的内容。

   - 文字

      ```bash
      xclip -o -sel clip

      # xclip 管理 X11 剪贴板的 CLI
      # -o（output） 输出剪贴板数据
      # -sel（selection）选择要使用的剪贴板，不指定的话默认是鼠标中键的缓冲区。
      # clip（clipboard）代表 Ctrl+C/V 的那个剪贴板
      ```

      此时会输出复制的文字。

   - 图片

      ```bash
      xclip -selection clipboard -t image/png -o

      # 输出系统剪贴板数据
      # -t 指定数据类型
      # xclip 没有 wl-paste 智能，不指定类型为图片的话输出图片数据会报错
      ```

      此时会输出复制的图片的二进制数据。

   - 查看类型

      ```bash
      xclip -selection clipboard -t TARGETS -o
      ```

3. 把刚刚打印的东西传给 Wayland 剪贴板。

   wl-copy 会自动检测类型，所以通常不需要手动指定数据类型。

   ```bash
   xclip -o -sel clip | wl-copy
   ```

   ```bash
   xclip -selection clipboard -t image/png -o | wl-copy
   ```

   此时你会发现 QQ 复制的内容出现在了 Wayland 的剪贴板里。

以上就是原理。只要在检测到 X11 剪贴板发生变化的时候自动完成以上操作就解决了 QQ 的剪贴板问题。

## quickshell图标缺失

添加环境变量：

- Niri

   ```text
   environment{
      QS_ICON_THEME "Adwaita"
   }
   ```

## NetworkManager切换到IWD后端后使用impala联网提示operation aborted

先用 `nmcli connection show` 找到出现问题的 WiFi 连接名称，只删除该连接配置，再重启 NetworkManager。不要清空 `/etc/NetworkManager/system-connections`，该目录还可能保存静态 IP、VPN、网桥等其他连接。

```bash
nmcli connection show
sudo nmcli connection delete "连接名称"
sudo systemctl restart NetworkManager
```

## OBS导致显卡占用飙升进而导致游戏帧数大幅下降

游戏帧数大幅下降的根本原因是显卡占用过高导致画面输出堵塞。

有以下几个原因（以 780M 核显为例）：

- 第三方插件

   例如 NDI（`distroav`），这类插件即使不激活，仅仅只是安装上，在开启 OBS 之后就会导致显卡占用增加。

- 屏幕采集（13%）

   OBS 的屏幕采集极其吃显卡性能，你可以测试一下，开关屏幕采集，观察显卡占用的变化。窗口采集（5%）的占用要远远少于显示器采集。

- OBS 的预览画面（5%）

   OBS 的预览画面也相当吃显卡资源。

- OBS 本身

   如果 OBS 的窗口开在前台，就会占用大量显卡资源，必须放在后台。

所以 OBS 的正确使用方法是，用窗口采集获取画面，确认排版没有问题后关闭预览，然后把 OBS 的窗口关到后台。

## 天选4锐龙版2023使用Niri关闭屏幕后会自己亮屏

是没能正确识别主板的传感器轮询导致该轮询被视为了一次未知的按键输入，代码 `240/0xf0`。

如果你的情况和我相同，可以尝试屏蔽此按键：

```bash
sudo vim /etc/libinput/local-overrides.quirks
```
```text
[Asus WMI Hotkeys Ignore Phantom]
MatchName=*Asus WMI hotkeys*
AttrEventCode=-EV_KEY:0xf0;
```
重启后可以解决问题。

## 以英文的LC_CTYPE环境变量启动steam导致无法进行中文输入

Steam的webhelper是基于chromium的，在x11运行的时候用的输入法模块是GTK_IM_MODULE，但是Steam只加载了xim、cedilla 和 wayland 的模块。模块是按照locale激活的，LC_CTYPE为英文的时候激活的是 cedilla，这个不支持中文输入，于是没法使用输入法了。解决办法是手动指定使用xim，env GTK_IM_MODULE=xim steam。

可以对比一下三条命令的效果：

```
env LC_CTYPE=zh_CN.UTF-8 XMODIFIERS=@im=fcitx steam
env LC_CTYPE=en_US.UTF-8 XMODIFIERS=@im=fcitx steam
env LC_CTYPE=en_US.UTF-8 GTK_IM_MODULE=xim XMODIFIERS=@im=fcitx steam
```

只有加上`GTK_IM_MODULE=xim`的能用输入法。

## btop无法显示AMD核显信息

需要额外安装可选依赖

```
sudo pacman -S rocm-smi-lib
```
