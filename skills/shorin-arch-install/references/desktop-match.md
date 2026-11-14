# GNOME 同款配置与缺失项

## 视频版

功能扩展：Input Method Panel（Fcitx5）、AppIndicator and KStatusNotifierItem Support、Workspace Indicator、Caffeine、Lock Keys、Clipboard Indicator、GNOME Fuzzy App Search、Steal My Focus Window、Tiling Shell、Color Picker、Vitals、Emoji Copy。美化扩展：Lock Screen Background、Blur My Shell、Hide Top Bar、Burn My Windows、User Themes、Logo Menu。

使用 `flatpak install flathub com.mattjakeman.ExtensionManager` 或对应官方扩展网站；若 flathub 未配置，先添加官方 remote。各扩展需搜索作者/UUID、读取支持的 GNOME 版本并记录。安装不是启用，启用不是参数已一致。出现新版本不兼容时记为缺项；不能直接塞入别的扩展而宣布同款。

Tiling Shell：Super+W/A/S/D 向上/左/下/右移动窗口；Super+Alt+W/A/S/D 扩展窗口；Super+C 取消平铺；文中建议启用自动平铺。Clipboard Indicator 的历史可快捷打开。完整缝隙、动画、模糊数值未提供，待比对。

键位按视频时期文档：Super+Q 关闭；Super+F 最大化；Super+Alt+F 全屏；Super+M 隐藏窗口；Super+G 应用；Ctrl+Super+S 快速设置；Ctrl+Alt+A 系统交互截图；Super+Shift+S Gradia 编辑截图。自定义命令 Super+B=zen、Super+T=ghostty、Ctrl+Alt+S=missioncenter、Super+E=nautilus。Super+数字键的工作区设置依 GNOME 实际支持数量，不假定无限工作区。

Ghostty：Frappe；`window-decoration = none`；`background-opacity = 0.8`；Adwaita Mono；字号 15。`session.sh` 提供这些明确参数，并备份旧配置。文件路径纠正为 `~/.config/ghostty/config`。这组参数由视频时期文档提供；抽查视频画面另确认了 Frappe 和无标题栏。

Zsh + Starship + syntax highlighting/autosuggestions/completions。脚本写 `.zshrc`，**不会自动更改登录 shell**；正常用户运行 `chsh -s /usr/bin/zsh` 后重新登录。Starship 具体 preset 待补，不把默认 prompt 称为同款。

Fcitx5：添加中文输入源，设置切换键 Super+Space；按历史文档配置环境并安装 Input Method Panel。Wayland/GNOME 新版适配按实际现象处理，参看当前 [中文输入法.md](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/%E4%B8%AD%E6%96%87%E8%BE%93%E5%85%A5%E6%B3%95.md)；若改用 IBus-Rime，必须说明这是当前项目变体。

Timeshift：安装 Timeshift/cronie/grub-btrfs/inotify-tools，用 GUI 选择 Btrfs、确认 `@` 和 `@home`、建立第一份快照，再配置 cronie 和 grub-btrfsd 的 `--timeshift-auto`。视频将 ESP 放 `/boot`，快照不能恢复其内核文件；测试回档必须核对内核和 modules 是否一致。

## 当前项目版

读取 [我的GNOME自定义设置.md](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/%E6%88%91%E7%9A%84GNOME%E8%87%AA%E5%AE%9A%E4%B9%89%E8%AE%BE%E7%BD%AE.md) 和 [安装GNOME.md](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/%E5%AE%89%E8%A3%85GNOME.md)。输入法 IBus/Rime/雾凇，快照 Snapper，ESP `/efi`。不能自动启用与布局冲突的 Hide Top Bar / Dash to Dock / App Icons Taskbar / Dash to Panel 全部方案。默认不引入当前作者安装脚本的动态下载和菜单。

## QQ 与其他软件

QQ fix 见 [linuxqq-wayland-fix.md](linuxqq-wayland-fix.md)。需原生 `linuxqq` 或 `linuxqq-appimage` + `linuxqq-wayland-fix-git`，修复启动器用单独 desktop entry。不要以成功安装包代替真实 QQ 会话验收。

其他作者软件：Zen、Mission Center、文本编辑器、磁盘管理、时钟/计算器、Loupe、Snapshot、Baobab、Showtime、Fragments、Foliate、Amberol；AUR/社区 QQ、微信、WPS；Flatpak Gradia 等；游戏 Steam/Wine/Lutris。先查询包在哪个源，逐项安装和测试，不将软件长列表当官方 pacman 保证可用列表。非用户请求的硬件烤机/超频不自动执行。

## 严格视觉匹配的待补材料

1. 视频中的月光草地壁纸原文件（当前仓库未确认匹配）。
2. 视频版 GNOME 的完整 dconf dump、扩展 UUID/版本/设置。
3. 指定 GTK/Shell/图标/光标主题和 Starship preset。
4. 同分辨率、缩放比例、窗口布局的参考截图。

取得材料后校验 hash、按用户设置应用，保存安装后截图，并逐项对照壁纸/面板/字体/颜色/透明度/圆角/动画/快捷键。未知参数在报告中写 `pending`。未取得这些材料，不承诺像素级完全一致。
