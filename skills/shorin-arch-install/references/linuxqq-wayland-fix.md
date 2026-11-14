# Linux QQ Wayland 修复

来源：[SHORiN-KiWATA/linuxqq-wayland-fix README](https://github.com/SHORiN-KiWATA/linuxqq-wayland-fix/blob/7d7f82d297e69299ea5419c5900042826158e87a/README.md)，对应 [「我修复了 Linux QQ」](https://www.bilibili.com/video/BV1MKa66VEPS/)。本页是安装与验收摘要，详细说明以作者当前项目为准。

作者修复的三个功能：QQ 与其它应用之间双向剪贴板、截图异常、Wayland 屏幕分享。README 兼容性表列出 GNOME、KDE、Niri、Hyprland，但仍需在实际安装环境测试。

## 安装与启动

1. 单独安装 QQ 本体，使用原生 `linuxqq` 或 `linuxqq-appimage`；作者目前不支持 Flatpak 沙盒 QQ。
2. 检查正常工作的 XWayland、PipeWire 以及所选桌面对应的 xdg-desktop-portal 后端。
3. 普通用户检查 AUR PKGBUILD，然后运行：

```bash
paru -S linuxqq-wayland-fix-git
```

使用 yay 的用户可以通过 yay 安装同一包。不在 root 下构建 AUR。

4. 完全退出 QQ，包括托盘；在菜单启动 **QQ（Wayland修复版）**。
5. 自检：

```bash
linuxqq-wayland-fix --doctor
```

## 实际验收

测试 QQ→浏览器与浏览器→QQ 的复制粘贴；截图后不闪退并可以粘贴；在真实通话中确认对方能看到共享画面。成功装包或 doctor 通过不代替这些检查。

使用 Easy Effects 时，按作者说明在输入及输入排除名单都加入 `TRAE`。共享观看花屏、角度后端设置和其它问题见 [作者排错文档](https://github.com/SHORiN-KiWATA/linuxqq-wayland-fix/blob/7d7f82d297e69299ea5419c5900042826158e87a/docs/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98%E4%B8%8E%E6%8E%92%E9%94%99.md)。

上游项目采用 MIT；声明保留于 [QQ-MIT-LICENSE.txt](QQ-MIT-LICENSE.txt)。没有重新分发视频或演示素材。
