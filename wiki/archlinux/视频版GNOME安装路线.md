# Arch Linux 安装教程：复现 Shorin 的 GNOME 桌面

第一部分：按指定视频及其同期项目文档安装。整理日期：2026-10-06。

作者与原始来源：[林长枫 Shorin709 的 2025 安装视频](https://www.bilibili.com/video/BV1L2gxzVEgs/)、[「我修复了 Linux QQ」](https://www.bilibili.com/video/BV1MKa66VEPS/)、[ShorinArchExperience 项目](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide)。本教程是改编与整理，包含显式标注的当前兼容性修正，文档遵循 CC BY-SA 4.0。

## 先明确要装成什么

本教程的目标是 **Arch + GNOME + Wayland**，配作者视频中的窗口平铺/扩展、Ghostty Frappe 配色、Zsh/Starship、中文输入、快照与日用软件。再加上第一个短视频的 Linux QQ Wayland 修复。KVM、显卡直通、远程桌面和 Zen 内核在后半部分按硬件条件配置。

不是 Niri/Hyprland/KDE 方案。2025 视频和当前项目已有差异：

| 设置 | 视频同期文档，第一部分基线 | 当前项目修订 |
|---|---|---|
| ESP 挂载 | `/boot`，手动分区 512 MB | `/efi`，内核保留在 Btrfs `/boot` |
| 快照 | Timeshift | Snapper + Btrfs Assistant |
| 中文输入 | Fcitx5 + 中文合集 | GNOME 推荐 IBus-Rime/雾凇 |
| GNOME 最小包 | 旧文写 `gnome-desktop` | 当前写 `gnome-shell` |
| AI 安装 | 同期视频主要手动/archinstall | 当前项目新增 OpenCode Live 安装 |

视频时期文档固定到 [2025-07-20 的提交](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/tree/2db97dde40038b79f6a56a8306b1da1b86ff1c20)，[固定版本原文](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/2db97dde40038b79f6a56a8306b1da1b86ff1c20/Archlinux%2BGnome%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE.md)。当前文档固定到 [d877245](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/tree/d8772456749981c0de3417a84c2783578603cfc6)，[完整来源及差异说明](../../skills/shorin-arch-install/references/source-audit.md)。

**复刻边界**：目前能明确复现的是文档中的系统方案、功能和已知美化参数。壁纸原文件、完整扩展设置、Starship preset 尚未锁定，没有进行 Arch 实机/虚拟机安装或最终截图比对，所以现在不能承诺“界面一模一样”。本文把这些列入验收和待补材料，不用随机主题代替同款。

视频公开接口没有返回字幕；已核对标题、官方章节、作者同期原文，并抽查美化视频画面，未完成全视频逐字转写。

## 视频章节索引

| 时间 | 章节 | 本教程对应内容 |
|---|---|---|
| 00:00–03:02 | 前言、GNU/Linux 历史 | 了解系统定位 |
| 03:02–04:07 | 安装前准备 | 第 1 节 |
| 04:07–17:17 | 手动安装 | 第 2–7 节 |
| 17:17–22:26 | archinstall | 第 8 节 |
| 22:26–39:13 | 系统、GNOME | 第 9–13 节 |
| 39:13–41:19 | 笔记本显卡、电源 | 第 14 节 |
| 41:19–46:13 | 美化 | 第 15 节 |
| 46:13–59:04 | KVM、直通、远程桌面 | 第 17 节 |
| 59:04–62:47 | 性能优化 | 第 18 节 |
| 62:47–64:15 | 删除 Linux | 卸载附录，安装时不执行 |

QQ 短视频另属于第 16 节，不能把它当作第二部 Arch 安装视频。

## 1. 制作启动盘与准备空间

1. 从 [Arch 官网](https://archlinux.org/download/) 下载 x86_64 ISO，按官网校验签名/校验和。
2. 按作者项目使用 [Ventoy](https://www.ventoy.net/cn/index.html) 制作 U 盘，把 ISO 放进去。制作会清空该 U 盘，先备份。
3. 若双系统，Windows 的磁盘管理中压缩现有卷，为 Arch 留出未分配空间；不要直接删除 Windows/恢复分区。
4. 作者项目关闭 Windows 快速启动；处理双系统时间时在管理员 PowerShell 执行：

```powershell
Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1
```

5. 保留 BitLocker 恢复密钥；是否解密/暂停保护按磁盘操作与机型决定。作者准备页建议关闭 BitLocker、TPM，但它们不是所有电脑安装 Arch 的通用必需，本文不把关闭 TPM 当作默认执行步骤。
6. 用 UEFI 启动 ISO。官方 ISO 的常见路线需要关闭 Secure Boot；已有自定义签名引导则按其方案处理。不要清除固件密钥。

**硬件条件**：本教程的命令适用 x86_64、64 位 UEFI。Apple Silicon/ARM、Legacy BIOS 不适用这套引导流程。

来源：[作者当前准备文档](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/%E5%AE%89%E8%A3%85%E4%BB%BB%E6%84%8FLinux%E7%B3%BB%E7%BB%9F%E7%9A%84%E5%89%8D%E6%9C%9F%E5%87%86%E5%A4%87%E5%B7%A5%E4%BD%9C.md)。

## 2. 进入 Live、联网、同步时间

可选调大字体，确认 UEFI：

```bash
setfont ter-v32n
cat /sys/firmware/efi/fw_platform_size
```

输出应为 `64`。查看网卡和网络：

```bash
ip link
ip a
ping -c 3 bilibili.com
```

有线或手机 USB 网络通常可直接使用。Wi-Fi 用真实网卡名替换 `wlan0`：

```text
iwctl
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "你的WiFi名字"
exit
```

密码由本地提示输入。然后：

```bash
timedatectl set-ntp true
timedatectl
```

下载慢可以编辑 `/etc/pacman.d/mirrorlist`；当前项目新增的自动测速方式是：

```bash
reflector -p https -a 12 -c cn --verbose --sort rate --save /etc/pacman.d/mirrorlist
```

这是当前文档补充，非视频同期手动换源步骤。失败则保留可用镜像，不用空文件覆盖镜像列表。

## 3. 分区：先识别，再创建

```bash
lsblk -p -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS
fdisk -l
```

视频手动路线：独立 Linux ESP 512 MB（EFI System），剩余 Linux 空间一个根分区（Linux filesystem）。视频 archinstall 路线建议 ESP 1024 MB。Windows 双系统时，所有 Windows 分区都要保留。

```bash
cfdisk /dev/你的目标整盘
```

只在预留的未分配空间中创建 Linux 分区，记录实际设备名。后面用 `$ESP`、`$ROOT` 表示它们；**下面赋值必须由你从 lsblk 确定，不能照抄磁盘编号**。

```bash
ESP=/dev/你的LinuxEFI分区
ROOT=/dev/你的Linux根分区
lsblk -f
```

新建的 Linux ESP 才格式化；若选择复用原 ESP，则跳过 `mkfs.fat`。根分区格式化会删除其数据：

```bash
mkfs.fat -F 32 "$ESP"
mkfs.btrfs "$ROOT"
```

本文没有“默认第一块磁盘就是目标盘”的规则。

## 4. Btrfs 子卷与挂载

按视频同期文档创建 `@`、`@home`、`@swap`：

```bash
mount -t btrfs -o compress=zstd "$ROOT" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap
btrfs subvolume list -p /mnt
umount /mnt
mount -t btrfs -o subvol=/@,compress=zstd "$ROOT" /mnt
mount --mkdir -t btrfs -o subvol=/@home,compress=zstd "$ROOT" /mnt/home
mount --mkdir -t btrfs -o subvol=/@swap,compress=zstd "$ROOT" /mnt/swap
mount --mkdir "$ESP" /mnt/boot
```

视频双系统中 Windows ESP 另挂 `/mnt/winboot`。先识别真正的 Windows ESP，再按需挂载；不格式化：

```bash
WIN_ESP=/dev/经核实的WindowsEFI分区
mount --mkdir "$WIN_ESP" /mnt/winboot
```

无 Windows 不执行这两行。查看挂载：

```bash
findmnt -R /mnt
df -h
```

**当前修订**：作者现推荐 Linux ESP 挂 `/mnt/efi`，后面的 `--efi-directory` 同步改 `/efi`。原因是 `/boot` 留在 Btrfs 中，快照能恢复内核。选择哪版就贯穿到底；不要在本节 `/boot`、引导节 `/efi` 混用。若坚持视频版，后续 Timeshift 回档不能单独恢复 FAT `/boot`，需另备份/重装匹配内核。

## 5. 安装基础系统和 Swap

```bash
pacman -Sy archlinux-keyring
pacstrap -K /mnt base base-devel linux linux-firmware btrfs-progs
pacstrap /mnt networkmanager vim sudo amd-ucode
```

Intel CPU 将最后一个包改成 `intel-ucode`。原文中 `-K` 的解释不准确：它为目标初始化空密钥环，不是简单复制宿主密钥环；上面的安装命令保留。

原视频示例 Swap 64g，**这是作者配置例子，不是每台电脑固定 64 GB**。以下以实际选择的 4g 示意：

```bash
btrfs filesystem mkswapfile --size 4g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile
genfstab -U /mnt > /mnt/etc/fstab
cat /mnt/etc/fstab
```

检查 `/`、`/home`、`/swap`、ESP；Swap 文件应有一行。需要休眠应按内存和当前休眠方案规划大小，并验证 resume；仅创建文件不能证明休眠可用。

```bash
arch-chroot /mnt
```

从这里开始是目标系统的 root 环境，直到 `exit`。

## 6. 时区、本地化、密码和引导

```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
vim /etc/locale.gen
```

取消 `en_US.UTF-8 UTF-8` 注释；后面需要中文也取消 `zh_CN.UTF-8 UTF-8` 注释：

```bash
locale-gen
printf '%s\n' 'LANG=en_US.UTF-8' > /etc/locale.conf
printf '%s\n' 'archlinux' > /etc/hostname
passwd
```

主机名可自选。视频同期的主机名段落未展开，上面的写入方式来自当前项目。密码只在本地终端输入。

视频引导方式：

```bash
pacman -S grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
vim /etc/default/grub
```

删除 `quiet`，AMD 示例：

```ini
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=5 nowatchdog modprobe.blacklist=sp5100_tco"
GRUB_DISABLE_OS_PROBER=false
```

Intel 将 blacklist 改为 `iTCO_wdt`。双系统才需要 os-prober；当前项目还加入 `fuse3`。`project-current` 版的安装命令改成 `--efi-directory=/efi`。

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

双系统检查生成输出有 Windows；没有则核对其 ESP 和 os-prober，不能删除 Windows 启动文件。

当前项目的回退路径 `--removable --no-nvram` 是可选项，可能覆盖共享 ESP 中 `EFI/BOOT/BOOTx64.EFI`，不作为默认必做。

## 7. 首次启动

视频是在启动后启用网络；为避免首启没网，可在 chroot 先启用：

```bash
systemctl enable NetworkManager
exit
umount -R /mnt
reboot
```

拔掉安装 U 盘，选择 Arch 的 UEFI 项。root 登录后：

```bash
systemctl enable --now NetworkManager
nmtui
```

连接好后 `ping -c 3 bilibili.com`。这一刻只有基础系统，还没完成桌面。

## 8. 视频的另一条路：archinstall

这一节是第 2–7 节的替代，不重复执行两套安装。

在 Live 中更新密钥、确认当前 archinstall 能运行：

```bash
pacman -Sy archlinux-keyring
pacman -S archinstall
archinstall
```

视频选择：GRUB；ESP FAT32，`/boot`；根 Btrfs + compress；`@`=/、`@home`=/home、`@swap`=/swap；NetworkManager；普通管理员用户；Asia/Shanghai；按硬件装微码和驱动；开启 multilib。视频原文 `@home` 对应 `/` 是笔误，必须纠正为 `/home`。

原文台式机选 Zen、笔记本用 linux，是作者偏好。菜单随版本变动，选择等效设置，最后认真看磁盘操作摘要再确认。现项目已因版本频繁变化撤去详细 archinstall 菜单教程。

要用 AI + 用户提供的 skill，跳到 [第二部分](AI安装Skill.md)，不是只运行 archinstall 就能获得同款桌面。

## 9. 普通用户、软件源和 AUR

root 中建立用户，替换实际名字：

```bash
useradd -m -G wheel 你的用户名
passwd 你的用户名
EDITOR=vim visudo
```

取消下面行的注释：

```text
%wheel ALL=(ALL:ALL) ALL
```

`-G wheel` 修正旧文的 `-g wheel`。随后普通用户登录，后续系统操作加 sudo，AUR 构建使用普通用户。

编辑 `/etc/pacman.conf` 开启：

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

```bash
sudo pacman -Syu
```

archlinuxcn 是作者使用的社区源，按需添加，不冒充官方仓库：

```ini
[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
```

```bash
sudo pacman -Sy archlinuxcn-keyring
sudo pacman -Syu
sudo pacman -S --needed base-devel yay paru
```

没有配置 archlinuxcn 时，按视频另可从 AUR 构建 yay：

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
# 先阅读 PKGBUILD，再构建
makepkg -si
```

yay/paru 选一个就可。以上仓库初始化外，已安装系统不要习惯性 `pacman -Sy 某包` 做部分升级。

## 10. GNOME、驱动、音频与蓝牙

旧文写 `gnome-desktop` 为最小桌面；当前文档明确改为 `gnome-shell`。为可运行的 GNOME 使用：

```bash
sudo pacman -S --needed gnome-shell gdm ghostty gnome-control-center gnome-software flatpak nautilus file-roller firefox gnome-backgrounds
sudo pacman -S --needed noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd
sudo pacman -S --needed sof-firmware alsa-ucm-conf pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack
sudo pacman -S --needed ffmpegthumbnailer gnome-keyring gvfs-smb gst-plugins-base gst-plugins-good gst-libav
sudo pacman -S --needed nm-connection-editor dnsmasq bluez power-profiles-daemon
sudo systemctl enable --now bluetooth power-profiles-daemon
sudo systemctl start gdm
```

进入图形界面，用普通用户登录，打开 Ghostty：

```bash
sudo systemctl enable gdm
systemctl --user enable --now pipewire pipewire-pulse wireplumber
LANG=en_US.UTF-8 xdg-user-dirs-update
```

如缺少最后命令，先安装 `xdg-user-dirs`。GNOME 设置中可把用户语言改为中文，TTY 系统语言保留英文。

显卡按实际硬件配置；包从本机源查询后安装：

- AMD：`mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon`。
- Intel：`mesa lib32-mesa vulkan-intel lib32-vulkan-intel`；硬件解码根据代际选 `intel-media-driver` 或旧驱动。
- NVIDIA：先核对 GPU 架构与当前驱动分支；DKMS 对应 `linux-headers` 或 `linux-zen-headers`；不能把视频当时的驱动名照抄给所有显卡。

当前项目列出的 `nvidia-open-dkms` 示例适用于其支持的卡；旧卡需对应分支。具体参 [作者驱动页](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/%E6%98%BE%E5%8D%A1%E9%A9%B1%E5%8A%A8%E5%92%8C%E7%A1%AC%E4%BB%B6%E7%BC%96%E8%A7%A3%E7%A0%81.md)。安装后重启，再检查 `lspci -nnk`、NVIDIA 的 `nvidia-smi`、按需 `vainfo`。

## 11. 中文输入：保留视频的 Fcitx5 方案

```bash
sudo pacman -S fcitx5-im fcitx5-chinese-addons
```

视频也装日语 `fcitx5-mozc`，有需求再加。Fcitx5 配置中添加中文输入法，设 Super+Space 切换。在视频时期，环境变量写入 `/etc/environment`：

```ini
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

安装 GNOME 扩展 **Input Method Panel**，重新登录并测试浏览器、Ghostty、QQ 三处输入。Wayland 新版的输入法路径可能不同，出现冲突时按 [当前输入法排错](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/%E4%B8%AD%E6%96%87%E8%BE%93%E5%85%A5%E6%B3%95.md) 调整；不要启动 IBus/Fcitx5 两套并互相覆盖变量。

当前项目的 GNOME/IBus-Rime 变体：`ibus ibus-rime rime-ice-git`，在键盘设置添加 Rime，并创建 `~/.config/ibus/rime/default.custom.yaml`：

```yaml
patch:
  __include: rime_ice_suggestion:/
```

这是后续项目方案，选择它时记录“与视频输入法不同”。

## 12. 作者日用软件与桌面便利功能

先查询包在官方、archlinuxcn 还是 AUR，不将原文一长串包都当作官方仓库保证存在。

| 用途 | 作者软件 |
|---|---|
| 浏览器、系统工具 | Zen、Mission Center、GNOME Text Editor、Disk Utility、Clocks、Calculator |
| 图像/音视频/阅读 | Loupe、Snapshot、Baobab、Showtime、Fragments、File Roller、Foliate、Amberol |
| 通讯/办公 | Linux QQ、微信、WPS |
| 截图编辑 | Flatpak Gradia |
| 游戏/Windows 程序 | Steam、Wine、Lutris，先开启 multilib |

例如，按实际源拆开安装 `linuxqq wechat wps-office-cn`；不以某一包下架为由跳过所有其它包。

若 Flathub 尚不存在，先添加官方 remote：

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.mattjakeman.ExtensionManager be.alexandervanhee.gradia
```

为 Nautilus 增加“在此处打开终端”：

```bash
yay -S nautilus-open-any-terminal
```

按其 schema 设置 terminal=custom，命令 `ghostty --working-directory=%s`。原文通过 dconf-editor 配置，当前项目也给出 gsettings 方法。具体读 [安装GNOME](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/%E5%AE%89%E8%A3%85GNOME.md)。

分数缩放/VRR 按视频在软件商城安装 Refine，修改后观察显示器实际效果。

## 13. 视频快照：Timeshift

按实际源安装 Timeshift、cronie、grub-btrfs、inotify-tools。打开 Timeshift 选 Btrfs，确认 `@` 和 `@home`，创建第一份快照，然后：

```bash
sudo systemctl enable --now cronie
sudo systemctl edit grub-btrfsd.service
```

写入：

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now grub-btrfsd
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

旧文移除 fstab 的 subvolid，是为了恢复后子卷 ID 变化：先备份 `/etc/fstab`，再按原文处理，同时保留 `subvol=/@` 等路径并重新核对。

```bash
sudo cp /etc/fstab /etc/fstab.before-timeshift
sudo sed -i -E 's/(subvolid=[0-9]+,)|(,subvolid=[0-9]+)//g' /etc/fstab
```

快照不是外部数据备份。视频 `/boot` 在 FAT 上，Btrfs 回档后需要另核对内核版本，不能宣称“一键快照恢复全盘”。

如果用当前 profile，请改走 [Snapper 文档](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/%E5%BF%AB%E7%85%A7%E5%92%8C%E7%B3%BB%E7%BB%9F%E7%BB%B4%E6%8A%A4.md)：root/home 两个 config，timeline/cleanup timer 与 grub-btrfsd；不要照用 Timeshift 的 ExecStart。

## 14. 笔记本：显卡切换与电源

视频介绍 supergfxctl（部分华硕设备）、EnvyControl、PRIME，以及 power-profiles-daemon。按本机厂商/混合显卡条件选择。显卡切换在 Wayland 下有条件和限制，不能为了复刻作者功能对不支持的机型硬装。

使用独显启动应用可按项目 PRIME 方法，GNOME 内则通过支持的 switcheroo-control 提供右键入口。操作后检查实际渲染 GPU，参 [作者显卡切换文档](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/%E6%98%BE%E5%8D%A1%E5%88%87%E6%8D%A2.md)。

休眠需 Swap 大小、resume 配置及一次真实休眠/唤醒测试；单纯 `systemctl hibernate` 返回不是充分验收。

## 15. 美化与快捷键：复现已知参数

通过 Extension Manager 逐个安装、启用与当前 GNOME 兼容的扩展。不能把“安装完成”当作“配置同款完成”。

功能性：Input Method Panel、AppIndicator and KStatusNotifierItem Support、Workspace Indicator、Caffeine、Lock Keys、Clipboard Indicator、GNOME Fuzzy App Search、Steal My Focus Window、Tiling Shell、Color Picker、Vitals、Emoji Copy。

美化：Lock Screen Background、Blur My Shell、Hide Top Bar、Burn My Windows、User Themes、Logo Menu。

Tiling Shell 按作者视频文档：Super+W/A/S/D 移动窗口，Super+Alt+W/A/S/D 扩展窗口，Super+C 取消平铺。当前项目把部分快捷键改了，所以这里沿用视频版。扩展的精确 gaps/blur/动画参数未导出，列为待比对。

| 快捷键 | 视频版操作 |
|---|---|
| Super+Q / F / Alt+F | 关闭 / 最大化 / 全屏 |
| Super+M / G | 隐藏窗口 / 应用列表 |
| Ctrl+Super+S | 快速设置 |
| Ctrl+Alt+A | 系统交互截图 |
| Super+Shift+S | `flatpak run be.alexandervanhee.gradia --screenshot=INTERACTIVE` |
| Super+B / T / E | `zen` / `ghostty` / `nautilus` |
| Ctrl+Alt+S | `missioncenter` |

去掉标题栏关闭按钮：

```bash
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:'
```

主题放 `~/.themes`，光标主题放 `~/.local/share/icons`，通过 User Themes/Tweaks 设置。原文只给主题下载站，未指定唯一同款主题，因此不擅自指定。

终端：

```bash
sudo pacman -S zsh starship zsh-syntax-highlighting zsh-autosuggestions zsh-completions ttf-jetbrains-mono-nerd
chsh -s /usr/bin/zsh
```

重新登录；`~/.zshrc` 加自动补全、高亮与 `eval "$(starship init zsh)"`，完整文件可由附带 [session.sh](../../skills/shorin-arch-install/scripts/session.sh) 在普通 GNOME 用户环境中应用，执行前它会备份原配置。Starship 原文让读者自选 preset，精确同款尚未确定。

Ghostty 的实际配置文件是 `~/.config/ghostty/config`，主题放 `~/.config/ghostty/themes/catppuccin-frappe.conf`，本包已收录 Frappe 配色：

```ini
theme = catppuccin-frappe
window-decoration = none
background-opacity = 0.8
font-family = Adwaita Mono
font-size = 15
```

这些参数来自视频时期原文；实际视频约 45:34 的画面也能看到 Frappe 和取消标题栏的命令。壁纸是另一个必要条件：视频月光草地背景的原文件尚未定位，不能用当前仓库中的动漫壁纸冒充。

## 16. 第二个来源内容：修复 Linux QQ 的 Wayland 功能

用户提供列表中的第一个视频对应 [linuxqq-wayland-fix](https://github.com/SHORiN-KiWATA/linuxqq-wayland-fix)。作者文档修复双向剪贴板、截图异常和屏幕分享；兼容性表列 GNOME、KDE、Hyprland、Niri 支持，实际仍需在你的环境测试。

1. 安装 QQ 本体，使用原生 `linuxqq` 或 `linuxqq-appimage`。作者目前不支持 Flatpak QQ。
2. 普通用户使用 AUR helper，先阅读 PKGBUILD：

```bash
paru -S linuxqq-wayland-fix-git
```

3. 完全退出 QQ，包括托盘；从应用菜单启动 **QQ（Wayland修复版）**。
4. 自检：

```bash
linuxqq-wayland-fix --doctor
```

5. 实际测试：QQ→浏览器复制、浏览器→QQ 复制；截图后无崩溃并可粘贴；与另一个帐号通话，确认对方看到共享画面。

GNOME 下要有正常的 XWayland、PipeWire、对应 xdg-desktop-portal 后端。Easy Effects 使用者按作者说明在输入及输入排除名单都加入 `TRAE`。更多排错见 [固定版本原文](https://github.com/SHORiN-KiWATA/linuxqq-wayland-fix/blob/7d7f82d297e69299ea5419c5900042826158e87a/docs/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98%E4%B8%8E%E6%8E%92%E9%94%99.md)。

## 17. KVM、显卡直通与远程桌面

这一节对应视频 46:13 起。要复现这部分功能需合适硬件及 Windows ISO，不能只装 virt-manager 就算完成。

```bash
sudo pacman -S qemu-full virt-manager swtpm dnsmasq edk2-ovmf
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"
```

重新登录后：

```bash
virsh -c qemu:///system net-list --all
sudo virsh net-start default
sudo virsh net-autostart default
```

已启动的 default 不重复 net-start。创建 Windows 虚拟机：选 UEFI、需要的虚拟 TPM；加载 Windows ISO 和 virtio 驱动 ISO；按 CPU 拓扑设置虚拟核数；启动 guest 测网络、显示、声音。桥接按视频用 nm-connection-editor，仅在需要时设置，避免切断安装用的网络。

共享目录：guest 使用 virtiofs、共享内存；Windows 装 WinFSP 和 VirtIO-FS Service，然后测试读写。

显卡直通依视频路线：

1. 开启硬件虚拟化/IOMMU；检查 `dmesg`、IOMMU groups。
2. 明确哪张卡给宿主、哪张给客体；记录目标卡及其音频的实际 PCI IDs。不要复制 UP 主的设备 ID。
3. `/etc/modprobe.d/vfio.conf` 绑定目标设备；mkinitcpio 添加 vfio 模块/必要 hook；保留原配置和回退显示手段。
4. `sudo mkinitcpio -P`，重启，确认目标驱动是 vfio-pci。
5. 从 `pacman -Ql edk2-ovmf` 找到当前固件路径；virt-manager 添加 PCI Host Device；guest 装厂商驱动。
6. 真实启动 guest，确认直通 GPU 工作。单 GPU 热切换不是视频双卡流程的直接复制。

逐项操作细节和回退方法：[视频同期 KVM 原文](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/2db97dde40038b79f6a56a8306b1da1b86ff1c20/Archlinux%2BGnome%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE.md#kvm虚拟机)、[当前作者 KVM 文档](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/KVM%E8%99%9A%E6%8B%9F%E6%9C%BA.md)、[Agent 高级功能流程](../../skills/shorin-arch-install/references/advanced.md)。

远程桌面按照作者 Sunshine + Moonlight 路线安装、配对，测试视频/声音/输入。不要自动公开访问端口或把密码写进聊天。

## 18. ZRAM、Zen 与性能

ZRAM 和禁用 zswap 来自视频性能部分：

```bash
sudo pacman -S zram-generator
sudo vim /etc/systemd/zram-generator.conf
```

```ini
[zram0]
zram-size = ram
compression-algorithm = zstd
```

在 `/etc/default/grub` 的 `GRUB_CMDLINE_LINUX_DEFAULT` 追加 `zswap.enabled=0`，保留之前的参数，然后：

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
reboot
```

```bash
zramctl
swapon --show
cat /sys/module/zswap/parameters/enabled
```

视频还介绍 `linux-zen linux-zen-headers`、支持设备的 `nvidia-powerd`、LACT。Zen 安装后重建 GRUB、重启并 `uname -r` 确认；NVIDIA 需匹配 DKMS。超频/降压不是为了完成系统安装必做的动作，按硬件需求设置和测试。

## 19. 最后怎么验收

按 [验收表](../../skills/shorin-arch-install/references/acceptance.md) 检查。重启能进 GNOME 只是第一层：还应测试中文、声卡/麦克风、网络、驱动、快照、扩展快捷键、QQ 实际功能，以及你选择的 KVM/直通模块。

在安装后的 Linux 运行附带的只读检查：

```bash
bash /path/to/shorin-arch-install/scripts/verify.sh
```

PASS 是该项命令检查通过，不能替代真实通话、快照恢复或视觉对照。保存源 SHA、安装包版本、扩展列表和配置、截图。待拿到视频版壁纸和配置，在相同分辨率/缩放下对照面板、字体、颜色、透明度、布局与动画后，才能称为“完全同款”。

## 卸载附录

视频最后删除 Linux，不是安装的最后一步。只有明确要卸载时，才按 [作者删除文档](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/%E5%B9%B2%E5%87%80%E5%88%A0%E9%99%A4Linux.md) 操作。确认 Windows 可独立启动后，识别 Linux 专用分区/EFI 路径/NVRAM 项再删除；共用 ESP 时不删除整个 EFI 分区。

下一部分：[使用你提供的 skill 简易安装](AI安装Skill.md)。
