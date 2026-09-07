<div align="center">
  <img src="pictures/shorinarch.png" alt="SHORiNのARCH Logo" width="500" />
  <br><br>

  <a href="https://space.bilibili.com/9202840"><img src="https://img.shields.io/badge/Bilibili-关注我-pink?logo=bilibili" alt="Bilibili"></a>
  <img src="https://img.shields.io/badge/Platform-Arch_Linux-blue?logo=arch-linux" alt="Platform">
  <a href="https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/main/LICENSE"><img src="https://img.shields.io/github/license/SHORiN-KiWATA/Shorin-ArchLinux-Guide" alt="License"></a>
</div>

# 项目简介

欢迎阅读此教程。这是我作为纯小白尝试 Linux 后选择日用 Arch Linux 的实践经历。从实用性出发，总结出了我心中入门桌面端 Linux 的最佳路径。阅读本教程不需要任何知识储备，只要你对 Linux 感兴趣，我们一起进入这个有趣的世界。

>如果文中有错误欢迎指出，如果有更好的方案欢迎分享，有想要新增的内容欢迎 PR，大家一起维护。

## 给新人的一段话

在正式开始之前，我想说一段对日用 Linux 系统的新人来说很重要的一段话。

我以本地 AI 部署为契机尝试 Linux，惊叹 Linux 桌面体验之独特，认为这是极具价值的东西。Distro Hopping *[注1]* 期间查阅了很多资料，深感中文互联网 Linux 信息之过时，内容之匮乏，环境之恶劣。在中国，言 Linux 必及服务器、开发等场景，必对桌面嗤之以鼻，功利至极。这样的观念根深蒂固，甚至 Linux 用户自己也持有这样的刻板印象。如果不是英文互联网的信息，这段路途会坎坷得多。这个仓库的初衷只是方便自己回顾，但是我觉得在这个将桌面 Linux 妖魔化的大环境下，一定有和我一样的小白对桌面 Linux 感兴趣但是不知从何下手，故分享了出来。

请谨记，使用 Linux 和与人交流 Linux 时应该明确区分服务端和桌面端，明确区分开发场景和日用场景，否则会产生不必要的麻烦和争执。你也可以通过这种方式明确自己的目的，避免浪费精力在不必要的东西上。

>*注 1：`Distro Hopping`，指反复切换 Linux 发行版。`Distro` 是 `Distribution` 的缩写，意为 Linux 发行版本，`Hopping` 有跳跃的意象。*

# 目录


以下是所有内容的索引，你可以按需阅读。**萌新建议从上到下依次阅读**，看不懂的地方不必深究，日后自然而然会懂：[点击此处现在开始！](./wiki/Home.md)

>整个教程假定你已经拥有一个 Windows 系统，如果不需要双系统的话请自行跳过 Windows 相关的内容。

>[**便利脚本：一键配置Arch Linux**](./wiki/archlinux/一键配置桌面环境.md) 这是我的一键配置脚本。用于为安装好的Arch Linux 和 Arch 衍生发行版进行所有必要的基础配置，还可以使用我的配置文件搭建桌面环境。

### 通用

| 章节                                                                         | 小节                                                                                                                                                                                                                                      |
| ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [选择合适的发行版](./wiki/Home.md)                                           | - [发行版选择](./wiki/Home.md#选择合适的发行版)<br>- [发行版避雷](./wiki/Home.md#发行版避雷)<br>                                                                                                                                          |
| [安装任意 Linux 系统前的准备工作](./wiki/安装任意Linux系统的前期准备工作.md) | - [制作系统盘](./wiki/安装任意Linux系统的前期准备工作.md#制作系统盘)<br>- [Windows 下的准备工作](./wiki/安装任意Linux系统的前期准备工作.md#windows-下的准备工作)<br>- [BIOS设置](./wiki/安装任意Linux系统的前期准备工作.md#bios-设置)<br> |
| [AI 辅助日用 Linux](./wiki/活用AI.md)                                        | - [什么是 AI Harness](./wiki/活用AI.md#什么是-ai-harness)<br> - [安装 opencode](./wiki/活用AI.md#opencode)<br> - [使用场景示例](./wiki/活用AI.md#使用场景)                                                                                |
| [干净删除 Linux 系统](./wiki/干净删除Linux.md)                               | - [删除分区和引导](./wiki/干净删除Linux.md#删除分区和引导)<br>- [删除主板上储存的入口](./wiki/干净删除Linux.md#删除主板上储存的入口)                                                                                                      |

### Linux Mint

| 章节                                          | 小节                                                                                                                                                                                                                                                                                                                      |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [入门指南](./wiki/linuxmint/Linuxmint入门.md) | - [系统安装](./wiki/linuxmint/Linuxmint入门.md#安装-linux-mint)<br>- [中文输入法](./wiki/linuxmint/Linuxmint入门.md#中文输入法)<br>- [镜像源](./wiki/linuxmint/Linuxmint入门.md#镜像源和系统更新)<br>- [硬件驱动](./wiki/linuxmint/Linuxmint入门.md#软件安装)<br>- [软件安装](./wiki/linuxmint/Linuxmint入门.md#软件安装) |

### CachyOS

| 章节                                  | 小节                                                                                                                                                                 |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [入门指南](./wiki/cachyos/CachyOS.md) | - [系统安装](./wiki/cachyos/CachyOS.md#安装-cachyos)<br>- [双系统](./wiki/cachyos/CachyOS.md#双系统引导)<br>- [必要的配置](./wiki/cachyos/CachyOS.md#必要的配置)<br> |

### Arch Linux

| 章节                                                                     | 小节                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [安装教程](./wiki/archlinux/安装ArchLinux.md)                            | - [重要概念讲解](./wiki/archlinux/安装ArchLinux.md#重要概念讲解)<br>- [手动安装系统](./wiki/archlinux/安装ArchLinux.md#手动安装)<br>- [AI 安装系统](./wiki/archlinux/安装ArchLinux.md#ai-助手安装)<br>- [脚本安装系统](./wiki/archlinux/安装ArchLinux.md#脚本安装)<br>- [手动安装省流版](./wiki/archlinux/手动安装省流版.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| [安装桌面环境前的准备](./wiki/archlinux/安装桌面环境前的准备.md)         | - [全局默认文本编辑器](./wiki/archlinux/安装桌面环境前的准备.md#设置全局默认文本编辑器)<br>- [创建普通用户](./wiki/archlinux/安装桌面环境前的准备.md#创建普通用户)<br>- [允许安装32位软件](./wiki/archlinux/安装桌面环境前的准备.md#开启32位源)<br>- [archlinuxcn源](./wiki/archlinux/安装桌面环境前的准备.md#archlinuxcn源)<br>- [AUR助手](./wiki/archlinux/安装桌面环境前的准备.md#aur助手)<br>- [基础字体](./wiki/archlinux/安装桌面环境前的准备.md#字体)<br>- [音视频固件和服务](./wiki/archlinux/安装桌面环境前的准备.md#音视频固件和服务)<br>- [性能模式切换](./wiki/archlinux/安装桌面环境前的准备.md#性能模式切换)<br>- [蓝牙](./wiki/archlinux/安装桌面环境前的准备.md#蓝牙)<br>- [Flatpak软件](./wiki/archlinux/安装桌面环境前的准备.md#flatpak软件)<br>- [休眠到硬盘](./wiki/archlinux/安装桌面环境前的准备.md#可选休眠到硬盘) |
| [显卡驱动和硬件编解码](./wiki/archlinux/显卡驱动和硬件编解码.md)         | - [显卡驱动和硬件编解码](./wiki/archlinux/显卡驱动和硬件编解码.md#手动安装驱动)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| [快照回档和系统维护](./wiki/archlinux/快照和系统维护.md)                 | - [snapper](./wiki/archlinux/快照和系统维护.md#snapper)<br>- [回档方法](./wiki/archlinux/快照和系统维护.md#回档方法)<br>- [滚挂和良好的系统使用习惯](./wiki/archlinux/快照和系统维护.md#关于滚挂和良好的系统使用习惯)<br>- [downgrade回退更新](./wiki/archlinux/快照和系统维护.md#拓展内容downgrade)<br>- [手动快照回档](./wiki/archlinux/快照和系统维护.md#拓展内容手动快照回档)                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| [安装桌面环境或窗口管理器](./wiki/archlinux/安装桌面环境或窗口管理器.md) | - [选择安装桌面环境或窗口管理器](./wiki/archlinux/安装桌面环境或窗口管理器.md)<br>- [一键配置桌面环境](./wiki/archlinux/一键配置桌面环境.md)<br>- [安装GNOME](./wiki/archlinux/安装GNOME.md)<br>- [安装KDE Plasma](./wiki/archlinux/安装KDE.md)<br>- [安装Niri](./wiki/archlinux/安装Niri.md)<br>- [安装Labwc](./wiki/archlinux/安装Labwc.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| [中文输入法](./wiki/archlinux/中文输入法.md)                             | - [fcitx5-rime](./wiki/archlinux/中文输入法.md#fcitx5)<br>- [ibus-rime](./wiki/archlinux/中文输入法.md#ibus)<br>- [输入法异常的解决办法](./wiki/archlinux/中文输入法.md#输入法异常的解决办法)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| [软件安装相关](./wiki/archlinux/软件安装相关.md)                         | - [如何安装软件](./wiki/archlinux/软件安装相关.md#如何安装软件)<br>- [我使用的软件](./wiki/archlinux/软件安装相关.md#我使用的软件)<br>- [视频播放器开启硬件编解码](./wiki/archlinux/软件安装相关.md#视频播放器开启硬件编解码)<br>- [GNOME如何编辑截图](./wiki/archlinux/软件安装相关.md#gnome如何编辑截图)<br>- [AppImage使用方法](./wiki/archlinux/软件安装相关.md#如何使用appimage)<br>- [隐藏不必要的快捷方式](./wiki/archlinux/软件安装相关.md#隐藏不必要的快捷方式)<br>- [星火应用商店](./wiki/archlinux/软件安装相关.md#星火应用商店)                                                                                                                                                                                                                                                                                               |
| [网络代理](./wiki/archlinux/代理.md)                                     | - [测试代理是否生效](./wiki/archlinux/代理.md#测试代理是否生效)<br>- [flclash](./wiki/archlinux/代理.md#flclash)<br>- [daed](./wiki/archlinux/代理.md#daed)<br>- [GitHub代理](./wiki/archlinux/代理.md#github代理)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| [我的GNOME自定义设置](./wiki/archlinux/我的GNOME自定义设置.md)           | - [快捷键](./wiki/archlinux/我的GNOME自定义设置.md#快捷键)<br>- [功能性扩展](./wiki/archlinux/我的GNOME自定义设置.md#功能性扩展)<br>- [美化用扩展](./wiki/archlinux/我的GNOME自定义设置.md#美化用扩展)<br>- [实现windows布局](./wiki/archlinux/我的GNOME自定义设置.md#实现windows布局)<br>- [调节外接屏幕亮度](./wiki/archlinux/我的GNOME自定义设置.md#调节外接屏幕亮度)<br>- [光标主题](./wiki/archlinux/我的GNOME自定义设置.md#光标主题)<br>- [GNOME主题](./wiki/archlinux/我的GNOME自定义设置.md#gnome主题)                                                                                                                                                                                                                                                                                                                            |
| [我的KDE自定义设置](./wiki/archlinux/我的KDE自定义设置.md)               | - [桌面编辑](./wiki/archlinux/我的KDE自定义设置.md#桌面编辑)<br>- [快捷键](./wiki/archlinux/我的KDE自定义设置.md#快捷键)<br>- [圆角、晃动、动画](./wiki/archlinux/我的KDE自定义设置.md#桌面特效)<br>- [主题美化](./wiki/archlinux/我的KDE自定义设置.md#主题美化)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| [终端美化](./wiki/archlinux/终端美化.md)                                 | - [更换shell-fish](./wiki/archlinux/终端美化.md#fish)<br>- [更换shell-zsh](./wiki/archlinux/终端美化.md#zsh)<br>- [shell提示符美化-starship](./wiki/archlinux/终端美化.md#starship提示符美化)<br>- [Ghostty美化](./wiki/archlinux/终端美化.md#ghostty美化)<br>- [Konsole美化](./wiki/archlinux/终端美化.md#konsole美化)<br>- [Kitty美化](./wiki/archlinux/终端美化.md#kitty美化)                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| [GRUB美化](./wiki/archlinux/grub美化.md)                                 | - [GRUB美化](./wiki/archlinux/grub美化.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| [显卡切换](./wiki/archlinux/显卡切换.md)                                 | - [混合模式下用独显运行程序](./wiki/archlinux/显卡切换.md#混合模式下用独显运行)<br>- [切换显卡](./wiki/archlinux/显卡切换.md#显卡切换)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| [虚拟机](./wiki/archlinux/虚拟机.md)                                     | - [VMware](./wiki/archlinux/虚拟机.md#vmware)<br>- [Docker](./wiki/archlinux/虚拟机.md#docker)<br>- [Winboat-安装最简单的win虚拟机](./wiki/archlinux/虚拟机.md#winboat)<br>- [VirtualBox](./wiki/archlinux/虚拟机.md#virtualbox)<br>- [Distrobox](./wiki/archlinux/虚拟机.md#distrobox)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| [KVM虚拟机](./wiki/archlinux/KVM虚拟机.md)                               | - [嵌套虚拟化](./wiki/archlinux/KVM虚拟机.md#嵌套虚拟化)<br>- [桥接网络](./wiki/archlinux/KVM虚拟机.md#配置桥接网络)<br>- [win11虚拟机](./wiki/archlinux/KVM虚拟机.md#安装-win11-虚拟机)<br>- [文件共享-virtiofs](./wiki/archlinux/KVM虚拟机.md#文件分享)<br>- [文件共享-samba](./wiki/archlinux/KVM虚拟机.md#文件分享)<br>- [远程桌面-Parsec](./wiki/archlinux/KVM虚拟机.md#parsec)<br>- [远程桌面-SunshineMoonlight](./wiki/archlinux/KVM虚拟机.md#sunshinemoonlight)                                                                                                                                                                                                                                                                                                                                                                   |
| [KVM显卡直通](./wiki/archlinux/KVM虚拟机.md)                             | - [冷切换](./wiki/archlinux/KVM虚拟机.md#冷切换)<br>- [热切换](./wiki/archlinux/KVM虚拟机.md#热切换)<br>- [LookingGlass](./wiki/archlinux/KVM虚拟机.md#looking-glass)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| [KVM性能优化和伪装](./wiki/archlinux/KVM虚拟机.md)                       | - [内存大页](./wiki/archlinux/KVM虚拟机.md#内存大页)<br>- [CPUPin](./wiki/archlinux/KVM虚拟机.md#cpu-pinning)<br>- [伪装虚拟机](./wiki/archlinux/KVM虚拟机.md#伪装虚拟机)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| [Linux玩游戏](./wiki/archlinux/玩游戏.md)                                | - [小黄鸭补帧](./wiki/archlinux/玩游戏.md#小黄鸭补帧)<br>- [Steam](./wiki/archlinux/玩游戏.md#steam)<br>- [Minecraft](./wiki/archlinux/玩游戏.md#minecraft)<br>- [Lutris-wine兼容层运行游戏](./wiki/archlinux/玩游戏.md#lutris)<br>- [Waydroid-安卓手游](./wiki/archlinux/玩游戏.md#waydroid)<br>- [显卡直通虚拟机玩游戏](./wiki/archlinux/玩游戏.md#用显卡直通玩游戏)<br>- [使用Proton破解运行D加密游戏](./wiki/archlinux/玩游戏.md#使用proton破解运行d加密游戏)                                                                                                                                                                                                                                                                                                                                                                         |
| [Linux性能优化](./wiki/archlinux/性能优化.md)                            | - [N卡动态功耗调节](./wiki/archlinux/性能优化.md#n卡动态功耗调节)<br>- [显卡超频和定频降压](./wiki/archlinux/性能优化.md#lact进行显卡offset)<br>- [替换zen内核](./wiki/archlinux/性能优化.md#安装zen内核)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| [使用小技巧](./wiki/archlinux/小技巧.md)                                 | - [使用小技巧](./wiki/archlinux/小技巧.md#小技巧)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| [issues](./wiki/archlinux/issues.md)                                     | - [我遇到过的问题及解决办法](./wiki/archlinux/issues.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| [附录](./wiki/archlinux/附录.md)                                         | - [附录](./wiki/archlinux/附录.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| [交流群](./wiki/archlinux/交流群.md)                                     | - [交流群](./wiki/archlinux/交流群.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |



### 其他内容

| 章节 | 小节                                                                       |
| ---- | -------------------------------------------------------------------------- |
| —    | - [Arch Linux 本地部署AstrBot AI助手](./wiki/archlinux/Arch部署Astrbot.md) |
| —    | - [常见争议澄清](./wiki/archlinux/常见争议澄清.md)                         |







# 鸣谢

*排名不分先后*

- [Linux Mint](https://linuxmint.com/) 最新手友好的 Linux 发行版，没有之一
- [Arch Wiki](https://wiki.archlinux.org/title/Main_page) 《圣经》
- [Arch Linux 简明指南](https://arch.icekylin.online/) 新手友好的 Arch Linux 教程
- [Linux 中国](https://space.bilibili.com/203983793?spm_id_from=333.337.0.0) 中文互联网少有的优质 Linux 内容
- [Reddit](https://www.reddit.com/) 在这可以找到任何东西
- [Google Gemini AI](https://gemini.google.com) 最有人味的强大 AI
- [Youtuber@Bog](https://www.youtube.com/@bogxd) 启发我制作视频
- [Youtuber@michael_tunnell](https://www.youtube.com/@michael_tunnell) 优质 Linux 资讯教程博主
- [Youtuber@MichaelNROH](https://www.youtube.com/@MichaelNROH) 优质 Linux 资讯教程博主
- [Youtuber@TheLinuxEXP](https://www.youtube.com/@TheLinuxEXP) 优质 Linux 资讯教程博主
- [Youtuber@saneAspect](https://www.youtube.com/@saneAspect) 优质 Hyprland 教程博主

## 项目引用

- [CyberGRUB-2077](https://github.com/adnksharp/CyberGRUB-2077)
- [minegrub](https://github.com/Lxtharia/minegrub-theme)
- [Crossgrub](https://github.com/krypciak/crossgrub)
- [OldBIOS](https://github.com/Blaysht/grub_bios_theme)
- [Blue Screen of Life](https://github.com/harishnkr/bsol)
- [mechabar](https://github.com/sejjy/mechabar)

# Star History

<a href="https://star-history.dera.page/#SHORiN-KiWATA/Shorin-ArchLinux-Guide&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=SHORiN-KiWATA/Shorin-ArchLinux-Guide&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=SHORiN-KiWATA/Shorin-ArchLinux-Guide&type=Date" />
    <img alt="Star History Chart" src="https://star-history.dera.page/svg?repos=SHORiN-KiWATA/Shorin-ArchLinux-Guide&type=Date" />
  </picture>
</a>


## 🌐 Web Resources & Verified Articles Directory
- [PIM PATH](https://sieuthigame-viet.pages.dev/pim-path.html)
- [MERGE RUSH Z](https://zona-igr-besplatno.web.app/merge-rush-z.html)
- [X TO Y ALMOST IMPOSSIBLE](https://koreagame-hub24.netlify.app/x-to-y-almost-impossible.html)
- [ROOFTOP CHALLENGE](https://turbodrift-zone.web.app/rooftop-challenge.html)
- [GOLD MINER CLASSIC](https://juegosweb-gratis.github.io/gold-miner-classic.html)
- [SNEAKY FRIENDS](https://brainiac-puzzles.web.app/sneaky-friends.html)
- [CUBE SPEED DASH](https://arcadegames-france24.web.app/cube-speed-dash.html)
- [CLAP CLAP NIGHTMARE](https://desi-gaming-arena.pages.dev/clap-clap-nightmare.html)
- [LITTLE HERO KNIGHT](https://gemu-hiroba-japan.web.app/little-hero-knight.html)
- [FIRE AND WATER BIRDS](https://muryo-gemu-tengoku.pages.dev/fire-and-water-birds.html)
- [ULTRAHERO VS MONSTERS ROYALE BATTLE](https://turbodrift-zone.web.app/ultrahero-vs-monsters-royale-battle.html)
- [ANGRY FLAPPY](https://PixelArcadezGame.github.io/angry-flappy.html)
- [MOTO STUNTS DRIVING RACING](https://desi-gaming-arena.pages.dev/moto-stunts-driving-racing.html)
- [MONA LISA FASHION EXPERIMENTS](https://zona-igr-besplatno.web.app/mona-lisa-fashion-experiments.html)
- [PICTURE BY PIECES](https://sieuthigame-viet.pages.dev/picture-by-pieces.html)
- [BACKROOMS SKIBIDI TERRORS](https://veb-igry-moskva.web.app/backrooms-skibidi-terrors.html)
- [CLASH CROWD GAME](https://logic-puzzle-world.pages.dev/clash-crowd-game.html)
- [EGG DASH](https://luchshie-igry-rus.pages.dev/egg-dash.html)
- [JEWEL GARDEN STORY](https://muryo-geim-nara.web.app/jewel-garden-story.html)
- [FROST DEFENSE](https://jogosonline-brasil.vercel.app/frost-defense.html)
- [KNIT RESCUE](https://jogosweb-brasil.github.io/knit-rescue.html)
- [BIKING EXTREME 3D](https://PixelArcadezGame.github.io/biking-extreme-3d.html)
- [ITALIAN BRAINROT PUZZLE](https://sieuthigame-viet.pages.dev/italian-brainrot-puzzle.html)
- [HORROR ESCAPE GRANNY ROOM](https://zona-igr-besplatno.web.app/horror-escape-granny-room.html)
- [COW JAM FARM PUZZLE](https://youxiweb-china.github.io/cow-jam-farm-puzzle.html)
- [COLOR 3D BUMP IT UP](https://jogosweb-brasil24.netlify.app/color-3d-bump-it-up.html)
- [LEXY](https://nihon-webgames.netlify.app/lexy.html)
- [MEGA FALL RAGDOLL SIMULATOR](https://planetejeux-france.pages.dev/mega-fall-ragdoll-simulator.html)
- [21 CARDS](https://bharat-game-zone.web.app/21-cards.html)
- [VEGAMIX2 WILD WEST](https://youxi-h5-tiandi.pages.dev/vegamix2-wild-west.html)
- [COZY KITCHEN MERGE](https://jogosweb-brasil.github.io/cozy-kitchen-merge.html)
- [THE OFFICE ESCAPE](https://nihon-webgames.netlify.app/the-office-escape.html)
- [FASHION VALKYRIES SAGA OF STYLE](https://planetejeux-france.pages.dev/fashion-valkyries-saga-of-style.html)
- [BUILDING MODS FOR MINECRAFT](https://zona-juegos-flash.web.app/building-mods-for-minecraft.html)
- [COLOR SAND PUZZLE](https://onlinerus-portal.netlify.app/color-sand-puzzle.html)
- [2 3 4 PLAYER GAMES](https://muryo-geim-nara.web.app/2-3-4-player-games.html)
- [ITALIAN BRAINROT TUNG TUNG RACING](https://unblocked-galaxy.web.app/italian-brainrot-tung-tung-racing.html)
- [CLASSIC LABYRINTH 3D MAZE](https://action-battle-hub.pages.dev/classic-labyrinth-3d-maze.html)
- [NG FLOW LINES](https://juegosweb-desbloqueados.vercel.app/ng-flow-lines.html)
- [CARBON ROD](https://fischpedia-guide.pages.dev/calculator/carbon-rod)
- [IDLE FACTORY DOMINATION](https://unblocked-galaxy.web.app/idle-factory-domination.html)
- [FASHION WEEK 2025](https://nihongames-web.github.io/fashion-week-2025.html)
- [BATTLE ARENA](https://mundodosjogos-br.web.app/battle-arena.html)
- [FROM ZOMBIE TO GLAM A SPOOKY TRANSFORMATION](https://youxiweb-hub.netlify.app/from-zombie-to-glam-a-spooky-transformation.html)
- [SOCCER EURO CUP 2025](https://muryo-geim-nara.web.app/soccer-euro-cup-2025.html)
- [THE OFFICE ESCAPE](https://veb-igry-moskva.web.app/the-office-escape.html)
- [PANDA DASH AUTO SHOOTING](https://jingpin-youxiwang.pages.dev/panda-dash-auto-shooting.html)
- [CHARGER CITY DRIVER](https://unblocked-galaxy.web.app/charger-city-driver.html)
- [SURVIVAL MASTER 456 CHALLENGE](https://youxiweb-hub.netlify.app/survival-master-456-challenge.html)
- [HIDDEN OBJECTS ISLAND](https://jeuxflash-france.netlify.app/hidden-objects-island.html)
- [LOOPER](https://hindigame-arena.vercel.app/looper.html)
- [HELP ME TRICKY BRAIN PUZZLES](https://dautruong-game24h.web.app/help-me-tricky-brain-puzzles.html)
- [OBBY RAINBOW TOWER](https://espacejeux-paris.pages.dev/obby-rainbow-tower.html)
- [DADDY RABBIT](https://hindigames-hub.netlify.app/daddy-rabbit.html)
- [CHOCO BLOCKS](https://bharat-game-zone.web.app/choco-blocks.html)
- [MEN VS GORILLAS](https://quantum-puzzle-hub.pages.dev/men-vs-gorillas.html)
- [HAIR STACK 3D](https://jogosonline-brasil.vercel.app/hair-stack-3d.html)
- [BOLTS AND NUTS](https://koreagame-webhub.github.io/bolts-and-nuts.html)
- [BRAINROT MOB CLASH 3D](https://dautruong-game24h.web.app/brainrot-mob-clash-3d.html)
- [BUBBLE SHOOTER HAWAII](https://jeuxflash-france.netlify.app/bubble-shooter-hawaii.html)
- [FOXY ECO SORT](https://brainiac-puzzles.web.app/foxy-eco-sort.html)
- [SCREAMALS](https://portaldejogos-br.github.io/screamals.html)
- [BLOCK BLASTY SAGA](https://brain-puzzle-galaxy.netlify.app/block-blasty-saga.html)
- [PET CONNECT MATCH](https://choigamehay24h.github.io/pet-connect-match.html)
- [SHAPE SHIFT](https://logic-puzzle-world.pages.dev/shape-shift.html)
- [HIGH HEELS COLLECT RUN](https://jogosweb-brasil24.netlify.app/high-heels-collect-run.html)
- [KICK LUCKY BOXES ONLINE](https://mundodosjogos-br.web.app/kick-lucky-boxes-online.html)
- [BLOCK BLAST JEWEL PUZZLE](https://webarcade-hub.github.io/block-blast-jewel-puzzle.html)
- [QUBE 2048](https://shadow-ninja-arena.web.app/qube-2048.html)
- [STUNT RIDER](https://unblocked-galaxy.github.io/stunt-rider.html)
- [KICK AND RIDE](https://juegosweb-gratis.github.io/kick-and-ride.html)
- [GRUNGE CHIC ALT FASHION](https://kuaile-youxi-hub.web.app/grunge-chic-alt-fashion.html)
- [EAT AND GROW FISH](https://koreagame-zone.vercel.app/eat-and-grow-fish.html)
- [CRYSTAL CONNECT](https://youxi-china24.netlify.app/crystal-connect.html)
- [ROPE SORTING](https://koreagame-hub24.netlify.app/rope-sorting.html)
- [HELIX CRUSH](https://onlinerus-portal.netlify.app/helix-crush.html)
- [DYE IT RIGHT COLOR PICKER](https://action-battle-hub.pages.dev/dye-it-right-color-picker.html)
- [ROBLOX CRAFT RUN](https://youxi-china24.netlify.app/roblox-craft-run.html)
- [CRUSH IT ALL](https://tokyo-arcade-web.pages.dev/crush-it-all.html)
- [NEON GRAVITY](https://pixelarcade-speed.web.app/neon-gravity.html)
- [BLOCK BLAST 2048](https://juegosgratis-es.netlify.app/block-blast-2048.html)
- [MERGE HERO SURVIVAL TOWER DEFENSE](https://veb-igry-moskva.web.app/merge-hero-survival-tower-defense.html)
- [STUDENT AND TEACHER](https://veb-igry-moskva.web.app/student-and-teacher.html)
- [SUDOKU MASTER](https://maniadejogos-brasil.pages.dev/sudoku-master.html)
- [SNAKES](https://unblocked-action-arena.netlify.app/snakes.html)
- [UNTWIST ROAD](https://maniadejogos-brasil.pages.dev/untwist-road.html)
- [MR BULLET STEALTH NINJA KILLSTREAK](https://muryo-gemu-tengoku.pages.dev/mr-bullet-stealth-ninja-killstreak.html)
- [MAIDO](https://espacejeux-paris.pages.dev/maido.html)
- [EMOJI MERGE FUN MOJI](https://shadow-ninja-arena.web.app/emoji-merge-fun-moji.html)
- [COLOR BRAIN TEST GAMES](https://hindigames-portal.netlify.app/color-brain-test-games.html)
- [GOBATTLEIO](https://sieuthigame-viet.pages.dev/gobattleio.html)
- [ANNAS STORY DRESS UP DIY](https://unblocked-action-arena.netlify.app/annas-story-dress-up-diy.html)
- [DINOSAUR SHIFTING RUN](https://muryo-gemu-tengoku.pages.dev/dinosaur-shifting-run.html)
- [KITTEN NEVER DIES](https://mundodosjogos-br.web.app/kitten-never-dies.html)
- [CUPID UNCHAINED](https://tokyo-arcade-web.pages.dev/cupid-unchained.html)
- [BOOLU BASK](https://gamehay-online.netlify.app/boolu-bask.html)
- [TANKS](https://zona-igr-besplatno.web.app/tanks.html)
- [CHICKEN STRIKE](https://portaldejogos-br.github.io/chicken-strike.html)
- [VISUAL MEMORY DRAG DROP](https://pixelarcadezgame.web.app/visual-memory-drag-drop.html)
- [MINETAP](https://webarcade-gamehub.github.io/minetap.html)
- [MATH LAVA TOWER RACE](https://zona-juegos-flash.web.app/math-lava-tower-race.html)
- [OBBY DEAD RIVER](https://congdonggame-vietnam.web.app/obby-dead-river.html)
- [WORD JAM ASSOCIATION PUZZLE](https://jeuxflash-france.netlify.app/word-jam-association-puzzle.html)
- [GATE HEROES BATTLE](https://unblocked-galaxy.github.io/gate-heroes-battle.html)
- [GRANNY 2 ASYLUM HORROR HOUSE](https://jogosweb-brasil24.netlify.app/granny-2-asylum-horror-house.html)
- [SUPER TANK HERO](https://retro-arcade-zone.netlify.app/super-tank-hero.html)
- [BLOCOPS](https://shanghai-youxi-web.web.app/blocops.html)
- [ARROW LEGEND](https://shadow-ninja-arena.web.app/arrow-legend.html)
- [SQUID GAME ORIGINAL](https://arcadevault-games.github.io/squid-game-original.html)
- [COLOR NONOGRAM PUZZLE](https://action-strike-zone.pages.dev/color-nonogram-puzzle.html)
- [BOOM LAND LITE](https://choigamehay24h.github.io/boom-land-lite.html)
- [ZOMBIE CONQUER COUNTRIES](https://desi-gaming-arena.pages.dev/zombie-conquer-countries.html)
- [SPRUNKI GARDEN](https://unblocked-action-arena.netlify.app/sprunki-garden.html)
- [HILL CLIMB TRUCK TRANSFORM ADVENTURE](https://muryo-gemu-tengoku.pages.dev/hill-climb-truck-transform-adventure.html)
- [LIMITED DEFENSE](https://trochoimienphi24h.github.io/limited-defense.html)
- [ARROW SURVIVAL 15 SECONDS](https://shadow-ninja-arena.web.app/arrow-survival-15-seconds.html)
- [GIANT RUN 3D](https://kuaile-youxi-hub.web.app/giant-run-3d.html)
- [SPRUNKI CHARACTER MAKER OC](https://zona-juegos-flash.web.app/sprunki-character-maker-oc.html)
- [LEOPARD](https://trade-calculator-bf.pages.dev/values/leopard)
- [AIR BLOCK](https://espacejeux-paris.pages.dev/air-block.html)
- [MINERS FURY](https://juegosweb-desbloqueados.vercel.app/miners-fury.html)
- [FUNNY BALLS 2048](https://shadow-ninja-arena.web.app/funny-balls-2048.html)
- [HOTEL FEVER TYCOON](https://geim-cheon-guk24.pages.dev/hotel-fever-tycoon.html)
- [HIDDEN OBJECTS](https://unblocked-galaxy.web.app/hidden-objects.html)
- [TRICKY CASTLE](https://koreagame-hub24.netlify.app/tricky-castle.html)
- [LAVA JUMP](https://mundodosjogos-br.web.app/lava-jump.html)
- [GOAL IO](https://hindigame-arena.vercel.app/goal-io.html)
- [FLOWER COLLECTION](https://arcadevault-games.github.io/flower-collection.html)
- [BROKEN CITY COMBAT](https://koreagame-zone.vercel.app/broken-city-combat.html)
- [ROBOT TERMINATOR T REX](https://juegosgratis-es.netlify.app/robot-terminator-t-rex.html)
- [SKY ASSAULT](https://koreagame-arcade.netlify.app/sky-assault.html)
- [VEHICLE FUN RACE](https://kuaile-youxi-hub.web.app/vehicle-fun-race.html)
- [THE BEST WARRIOR](https://arcadevault-gamehub.github.io/the-best-warrior.html)
- [CLICK KITTY IDLE](https://juegosmundial-hoy.pages.dev/click-kitty-idle.html)
- [COLOR SORT IMPOSTOR EDITION](https://jogosweb-brasil24.netlify.app/color-sort-impostor-edition.html)
- [OBBY 3D SPRUNKI PARKOUR](https://gemu-hiroba-japan.web.app/obby-3d-sprunki-parkour.html)
- [ATLANTIC SKY HUNTER XTREME](https://bharat-game-zone.web.app/atlantic-sky-hunter-xtreme.html)
- [MEGA LAMBA RAMP](https://portaldejogos-br.github.io/mega-lamba-ramp.html)
- [TCG CARD CLICKER](https://hindigames-hub.netlify.app/tcg-card-clicker.html)
- [ARMY COMMANDER CRAFT](https://choigame24h-vietnam.netlify.app/army-commander-craft.html)
- [TANGLE MASTER 3D](https://turbodrift-zone.web.app/tangle-master-3d.html)
- [SURVIVAL MASTER 456 CHALLENGE](https://bharat-game-zone.web.app/survival-master-456-challenge.html)
- [VINE BOOM](https://instantsounds-daw.pages.dev/sound/vine-boom.html)
- [CUTE COLORING GAMES](https://maniadejogos-brasil.pages.dev/cute-coloring-games.html)
- [GEOMETRY FLAP](https://unblocked-galaxy.github.io/geometry-flap.html)
- [BUBBLE LETTERS](https://trochoimienphi24h.github.io/bubble-letters.html)
- [3 TILES](https://vuagamemienphi24h.pages.dev/3-tiles.html)
- [LEXY](https://vuagamemienphi24h.pages.dev/lexy.html)
- [RAGDOLL MEGA DUNK](https://gamehay-online.netlify.app/ragdoll-mega-dunk.html)
- [SANTA GO](https://action-battle-hub.pages.dev/santa-go.html)
- [IDLE MONEY FACTORY](https://shanghai-youxi-web.web.app/idle-money-factory.html)
- [POPCAT CLICKER](https://desi-gaming-arena.pages.dev/popcat-clicker.html)
- [DOTS MASTER](https://muryo-gemu-tengoku.pages.dev/dots-master.html)
- [PRACTICE ON ME](https://congdonggame-vietnam.web.app/practice-on-me.html)
- [SUV TRAFFIC RACER](https://vuagamemienphi24h.pages.dev/suv-traffic-racer.html)
- [RUMBLE](https://fruit-calculator-2026.netlify.app/calculator/rumble)
- [MAGIC SOLITAIRE](https://portaldejogos-br.github.io/magic-solitaire.html)
- [BUBBLE POP FAIRYLAND](https://vuagamemienphi24h.pages.dev/bubble-pop-fairyland.html)
- [TRIDENT ROD](https://fischcalc-app.pages.dev/calculator/trident-rod)
- [PHRASLE MASTER](https://muryo-gemu-tengoku.pages.dev/phrasle-master.html)
- [ROYAL REBELLION PUNK MAGIC](https://choigame24h-vietnam.netlify.app/royal-rebellion-punk-magic.html)
- [BED WARS](https://PixelArcadez.github.io/bed-wars.html)
- [WORM OUT BRAIN TEASER GAMES](https://youxi-h5-tiandi.pages.dev/worm-out-brain-teaser-games.html)
- [PAWS PALS DINER](https://webarcade-gamehub.github.io/paws-pals-diner.html)
- [ITALIAN BRAINROT SURVIVAL ARENA](https://logic-puzzle-world.pages.dev/italian-brainrot-survival-arena.html)
- [BATTLE ARENA RACE TO WIN](https://jogosweb-brasil.github.io/battle-arena-race-to-win.html)
- [SPRUNKI MEMORY CARD MATCH](https://onlinerus-games.netlify.app/sprunki-memory-card-match.html)
- [HEXA STACK](https://bharat-game-zone.web.app/hexa-stack.html)
- [SUSTAINABLE](https://gameflash-viet.github.io/sustainable.html)
- [EYE ART PERFECT MAKEUP ARTIST](https://arcadegames-france24.web.app/eye-art-perfect-makeup-artist.html)
- [UNSCREW WOOD PUZZLE](https://unblocked-galaxy.web.app/unscrew-wood-puzzle.html)
- [DOTS MASTER](https://espacejeux-paris.pages.dev/dots-master.html)
- [THROUGH THE WALL 3D](https://zona-juegos-flash.web.app/through-the-wall-3d.html)
- [MEMORY MATCH MAGIC](https://choigame24h-vietnam.netlify.app/memory-match-magic.html)
- [SURVIVAL ISLAND](https://luchshie-igry-rus.pages.dev/survival-island.html)
- [ZOMBIES WEAPON MERGE 4](https://koreagame-arcade.netlify.app/zombies-weapon-merge-4.html)
- [IDLE LANDMARK BUILDER](https://koreagame-arcade.netlify.app/idle-landmark-builder.html)
- [SHADOW](https://bftrade-calculator.pages.dev/calculator/shadow)
- [MARBLE SORT](https://nihon-webgames.netlify.app/marble-sort.html)
- [WINTER MAZE](https://nihon-webgames.netlify.app/winter-maze.html)
- [TOWER DEFENSE DRAGON MERGE](https://choigamehay24h.github.io/tower-defense-dragon-merge.html)
- [BUBBLE SHOOTER POP](https://turbodrift-zone.web.app/bubble-shooter-pop.html)
- [SPACE SURVIVAL RAINBOW FRIENDS MONSTER](https://pixelarcade-speed.web.app/space-survival-rainbow-friends-monster.html)
- [ARROW TAP PUZZLE](https://koreagame-zone.vercel.app/arrow-tap-puzzle.html)
- [MERGE GUN FPS SHOOTING ZOMBIE](https://kuaile-youxi-hub.web.app/merge-gun-fps-shooting-zombie.html)
- [GOODELUXE](https://jogosonline-brasil.vercel.app/goodeluxe.html)
- [JUMP TO THE MOUNTAIN FOR THE BRAINROTS](https://choigame24h-vietnam.netlify.app/jump-to-the-mountain-for-the-brainrots.html)
- [FRAGEN](https://pixelarcade-speed.web.app/fragen.html)
- [2248 BLAST](https://juegosmundial-hoy.pages.dev/2248-blast.html)
- [BLOCK BLASTER PUZZLE](https://webarcade-hub.github.io/block-blaster-puzzle.html)
- [FAMILY SQUID CHALLENGE](https://hindigames-portal.netlify.app/family-squid-challenge.html)
- [FOXY ECO SORT](https://shadow-ninja-arena.web.app/foxy-eco-sort.html)
- [HALLOWEEN STORE SORT](https://peullaesi-geim-madang.web.app/halloween-store-sort.html)
- [ALGERIAN SOLITAIRE](https://espacejeux-paris.pages.dev/algerian-solitaire.html)
- [BRAWL STARS BATTLE](https://espacejeux-paris.pages.dev/brawl-stars-battle.html)
- [ULTIMATE SPORTS CAR DRIFT](https://bharat-game-zone.web.app/ultimate-sports-car-drift.html)
- [JEWEL GARDEN STORY](https://gemu-hiroba-japan.web.app/jewel-garden-story.html)
- [SURVIVAL SWORD BATTLE](https://jogosonline-brasil.vercel.app/survival-sword-battle.html)
- [KRAKAX COM](https://youxi-h5-tiandi.pages.dev/krakax-com.html)
- [TURBO STARS](https://sieuthigame-viet.pages.dev/turbo-stars.html)
