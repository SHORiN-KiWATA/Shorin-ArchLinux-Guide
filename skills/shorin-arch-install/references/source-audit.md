# 来源、版本与证据边界

核对日期：2026-10-06。作者：林长枫 Shorin709 / SHORiN-KiWATA。

| 来源 | 已核实内容 | 获取方式 |
|---|---|---|
| [2025 安装视频](https://www.bilibili.com/video/BV1L2gxzVEgs/) | 标题、作者、3855 秒时长、官方章节；抽查美化章节约 41:40、45:34 的画面：GNOME、Catppuccin Frappe、Ghostty 隐藏标题栏 | B 站公开 view/player API + 浏览器实际播放画面 |
| [QQ 修复视频](https://www.bilibili.com/video/BV1MKa66VEPS/) | 标题「我修复了 Linux QQ」、83 秒、描述指向 linuxqq-wayland-fix | B 站公开 view/player API；功能和安装步骤另外核对作者仓库 |
| [视频时期文档](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/2db97dde40038b79f6a56a8306b1da1b86ff1c20/Archlinux%2BGnome%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE.md) | 2025-07-20 02:15:17 UTC 的提交，视频发布当天；完整安装、美化、KVM、直通、性能章节 | GitHub 提交历史和固定 SHA 的原始 Markdown |
| [当前项目](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/tree/d8772456749981c0de3417a84c2783578603cfc6) | 目前主线 ESP=/efi、Snapper、GNOME/IBus；包含 OpenCode 的 Live 安装方法 | Git clone + 固定 SHA 文档 |
| [QQ 修复项目](https://github.com/SHORiN-KiWATA/linuxqq-wayland-fix/tree/7d7f82d297e69299ea5419c5900042826158e87a) | 支持原生/AppImage QQ；剪贴板、截图、屏幕分享；doctor；兼容性表 | 固定 SHA README/PKGBUILD/排错文档 |
| [OpenCode 官方安装](https://opencode.ai/docs/) / [Skills](https://opencode.ai/docs/skills/) | Arch 包安装、skill 的项目/全局目录和按需加载 | 官方网页；skill 页面用 Defuddle 提取 |

两个视频公开 API 都没有返回可下载字幕。没有完整逐字转写，也没有看完每一帧；教程依靠作者视频时期原文、当前原文、视频官方章节和抽查画面。不得写成“两个视频已逐字核对”。

当前项目说明视频与文档不同时以文档为准。本补充路线面向需要复刻指定 2025 视频的读者，因此必须明确两种版本：第一部分以视频时期原文为结构，附当前兼容性说明；第二部分允许选择同一 `video-2025` 配置路线或 `project-current`，不能混写。

“一模一样”未完成的证据：2025 壁纸原始文件未识别；完整 dconf、扩展版本/配置、图标/光标主题、Starship preset 未锁定；尚未安装到 Arch 虚拟机/实机并对照截图。仓库当前 wallpapers 里的七张图经本地缩略图对照，没有确定为视频中的月光草地壁纸。不要挑一张代替后宣布同款。

当前作者的一键桌面仓库 [shorin-arch-setup](https://github.com/SHORiN-KiWATA/shorin-arch-setup)（核查树 SHA `a5103b3541d2ac77a566278440d03106ced4f7c5`）已存在 GNOME dotfiles，但它属于后续方案，不证明与 2025 视频一致，因此没有混入默认自动化。

## 许可和署名

教程与 skill 中对作者文档的改编和引用，保留作者署名、项目链接和 [CC BY-SA 4.0](UPSTREAM-CC-BY-SA-4.0.txt)，明确新增了版本分流、自动化、修正和验收。视频仅链接/分析，没有重新分发视频。视频时期原文仅保留固定版本链接；新增教程/工作流按本项目 CC BY-SA 4.0 分发。

QQ 功能与安装摘要依据作者项目 MIT，保留 [QQ-MIT-LICENSE.txt](QQ-MIT-LICENSE.txt)。Catppuccin Frappe 配色来自作者仓库 `legacy/.config/ghostty/themes/catppuccin-frappe.conf`；其上游为 [catppuccin/ghostty](https://github.com/catppuccin/ghostty)，保留相应 MIT 声明。原作者图片、壁纸另有可能的上游作者权利；本 skill 未打包这些壁纸。
