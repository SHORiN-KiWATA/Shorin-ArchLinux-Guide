# 视频原文与当前运行的差异

这些是明确的适配说明，不冒充视频命令。执行时以现场 `pacman -Si`、软件帮助和对应官方文档验证。

| 项目 | 视频时期原文 | 当前项目 / 本包处理 |
|---|---|---|
| ESP | 512 MB、`/boot`；archinstall 分支建议 1 GB | 当前推荐 `/efi`，内核留在 Btrfs `/boot`；避免快照回档后内核与根文件系统版本不一致。自动器按 profile 保留不同挂载点 |
| 快照 | Timeshift + cronie + grub-btrfs | 当前 Snapper + btrfs-assistant + grub-btrfs，两套流程不混用 |
| GNOME | `gnome-desktop` 被描述为最小安装 | 当前 `gnome-shell` 才是要启动的 shell；加入 Nautilus 和基础应用。修正包名而保留 GNOME 路线 |
| 用户 | `useradd -m -g wheel` | 使用 `useradd -m -G wheel`：wheel 是附加管理组，避免把 wheel 当主组 |
| 微码 | 示例 AMD `amd-ucode` | Intel 必须 `intel-ucode`，不照抄作者硬件 |
| Swap | 示例 64g | 按实际内存/空间/休眠需求选择；休眠需要单独验证 resume，自动器不承诺休眠开箱即用 |
| Archinstall 子卷 | 原文某行 `@home` 对应 `/` | 应为 `/home`，两个子卷不能同时挂到根目录 |
| GNOME 输入法 | Fcitx5 + 中文合集 + Input Method Panel | 当前推荐 GNOME/IBus-Rime，视频 profile 仍 Fcitx5；不要无条件设置冲突的两套环境变量 |
| Ghostty | 文中出现 `conf`、路径指向作者家目录 | 实际用 `~/.config/ghostty/config`，主题文件放 `themes`；使用本用户路径。脚本使用已收录 Frappe 配色 |
| Starship | “挑自己喜欢的 preset” | 无确切同款 preset，默认 Starship 仅是功能配置，视觉待补 |
| NVIDIA | 示例老驱动包名 | 实际按 GPU 架构与当日驱动分支选包，DKMS 配对应内核 headers；不得对所有卡一律 `nvidia-open-dkms` |
| Btrfs GRUB 记忆 | 历史没有新方法 | 当前文档有 `grub-editenv - set ok=1` 新版本方法；默认自动器不启用 saved/default 以免把新行为伪装成视频原操作 |
| TPM/BitLocker | 当前准备页建议关闭 | 是作者特定经验，非通用安装必需；保留恢复密钥、查机型需求。教程记录来源，Agent 不自动关闭 TPM、清空密钥或解密 Windows |
| 软件来源 | 很长的一条 pacman 命令混合官方/社区包 | 先查询，再拆官方、archlinuxcn、AUR/Flatpak；任一缺包不能静默跳过并报成功 |
| 引导回退 | 当前可选 removable | 共享 ESP 可能覆盖其他系统 BOOTx64.EFI；不作为默认操作 |

旧文档保留只说明“当时怎么做”。滚动仓库提供的是当前二进制，不等于恢复了 2025 软件版本。若要位级历史复现还需 Arch Linux Archive 日期、完整包版本和扩展旧版本；目前没有这些证据，不自动降级整机。

官方信息入口： [GNOME](https://wiki.archlinux.org/title/GNOME)、[NVIDIA](https://wiki.archlinux.org/title/NVIDIA)、[Btrfs](https://wiki.archlinux.org/title/Btrfs)、[Ghostty configuration](https://ghostty.org/docs/config)、[Arch installation](https://wiki.archlinux.org/title/Installation_guide)。本次 ArchWiki 英文站返回反爬页面，未据此声称已核实其所有当前内容；执行 Agent 应从可访问官方资料和现场包管理器再核对。
