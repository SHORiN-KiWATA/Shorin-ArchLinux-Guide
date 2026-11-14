# 简易安装：加载你提供的 skill，让 AI Agent 执行

本页提供可复用的安装 skill 工作流。读者需要本项目提供的完整 skill 目录，而不只是一个“帮我装 Arch”的提示词。

## OpenCode 还是 OpenCore？

根据项目的 [AI 安装章节](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/%E5%AE%89%E8%A3%85ArchLinux.md#ai-助手安装)，作者用的是 **OpenCode**，一个可执行终端命令、加载 skill 的 AI Agent。[OpenCode 官方文档](https://opencode.ai/docs/) 也列出 Arch 的安装方法。

**OpenCore** 是引导器，不能加载 `SKILL.md` 去执行 AI 安装。本节依据项目采用 OpenCode；如果你确实指 Apple/黑苹果的 OpenCore 引导器，那是另一项机型相关的引导适配工作，需要单独处理，不等同于加载 skill。

## “一键”包含哪些步骤

这里指“准备好启动盘、网络、目标信息和 skill 后，一条自然语言指令让 Agent 按既定流程执行”，不是从 Windows 桌面一键自动进 BIOS、清空未知硬盘并跳过所有选择。

- 附带安装器已实现：审核计划 → 指定整盘 GPT/ESP/Btrfs → 基础系统/GRUB/网络/ZRAM/GNOME → 本地设置密码 → 保存 skill 供重启后继续。
- 后续由加载同一 skill 的 Agent 完成：对应快照工具、输入法/软件源、GNOME 扩展/快捷键、QQ 修复、你选用的高级模块和验收。
- 同盘双系统：Agent 按第一部分操作具体分区，**不使用整盘清空安装器**。
- 视觉完全一致：壁纸、扩展设置、具体主题仍有待补证据，不能以“自动装好基础 GNOME”替代。

本补充已做过静态与安全逻辑检查，**尚未进行 Arch 虚拟机/实机端到端安装**。第一次运行请使用可丢弃的测试磁盘/虚拟机，并把通过结果记入验收表。

## 1. 你向读者提供什么

提供本包内整个目录：

```text
shorin-arch-install/
├── SKILL.md
├── scripts/
│   ├── install.py
│   ├── session.sh
│   └── verify.sh
├── assets/
│   ├── install.example.json
│   └── catppuccin-frappe.conf
└── references/
    ├── source-lock.json
    ├── source-index.md
    ├── linuxqq-wayland-fix.md
    └── 版本差异、桌面与验收说明
```

项目位置：[完整 skill](../../skills/shorin-arch-install/SKILL.md)。不要只发一个 `SKILL.md` 而遗漏脚本、主题和引用。

可通过附件、U 盘、你自己的 GitHub 仓库或下载页分发。分发时请指向项目中的完整目录。若通过下载链接分发，应同时公布 ZIP 的 SHA256，让读者核对来源。

## 2. 进入 Arch ISO 并联网

按第一部分制作启动盘、备份资料、预留空间，用 x86_64 UEFI 启动。先执行：

```bash
cat /sys/firmware/efi/fw_platform_size
ip a
ping -c 3 bilibili.com
free -h
findmnt /run/archiso/cowspace
df -h /run/archiso/cowspace
```

Wi-Fi 使用第一部分的 iwctl。当前作者文档强调扩大 cowspace；应在装 Agent 之前检查并扩大，而不是等空间耗尽。

确认路径是 tmpfs 且 RAM 允许时，下面给出 **4 GB 上限的例子**：

```bash
mount -o remount,size=4G /run/archiso/cowspace
```

低内存机器需更小值或外部工作盘，不照抄。没有这个挂载点就让 Agent 先识别实际 Live 布局。

## 3. 装 OpenCode

作者当前项目给出：

```bash
pacman -Sy --needed opencode
opencode
```

这是临时 ISO 环境的引导方法，不是建议在日用 Arch 长期做部分升级。在 TUI 用 `/models` 选当前可用模型，需要接入自己的服务时用 `/connect`；凭据本地输入，不写进安装配置/公开日志。免费模型会变化，不承诺某个名字一定可用。

此部分基于 [OpenCode 官方介绍](https://opencode.ai/docs/)；如果已有支持终端执行的其它 Agent，可直接使用同一 skill，不必装 OpenCode。

## 4. 载入你提供的 skill

假定你已把完整的 `shorin-arch-install` 文件夹复制到 Live 工作目录，在临时安装项目中，把目录放入 OpenCode 发现路径：

```bash
mkdir -p /root/arch-job/.opencode/skills
# 解压后的 shorin-arch-install 目录必须含 scripts/assets/references
cp -a ./shorin-arch-install /root/arch-job/.opencode/skills/
cd /root/arch-job
opencode
```

也可以从本项目下载 ZIP 后先解压，再复制整个 skill 文件夹；不要只复制入口 Markdown。目录名称与 `SKILL.md` 的 name 应一致。

官方路径还有全局 `~/.config/opencode/skills/<name>/SKILL.md`，见 [官方 Skills 文档](https://opencode.ai/docs/skills/)。不是 `~/.opencode/skills`，也不依赖未经核实的 `/list-skills` 命令。

在对话中输入：

```text
Load the shorin-arch-install skill. Read its source audit and explain which profile matches the 2025 video. We are in Arch ISO Live. Inspect hardware and disks first; do not write to disks yet.
```

确认 Agent 确实读到了 skill、引用和脚本。其它 Agent 没有 skill 自动发现时，直接提供完整路径，让它读取该 `SKILL.md` 和需要的 references；终端工具/root 权限仍是执行所需条件。

## 5. 一条指令发起安装

Live 没有中文输入法，读者可粘贴下面英文指令。磁盘和模块必须由真实情况确定：

```text
Use the shorin-arch-install skill to install Arch Linux following its video-2025 GNOME profile, and include the Linux QQ Wayland fix from the supplied source.

First verify Arch ISO Live, x86_64 UEFI, network, RAM/cowspace, CPU, GPU and disk identities. Show a concrete partition and installation plan. Ask only for missing target choices; do not guess which disk to erase. Preserve all Windows partitions unless I explicitly choose a separate whole disk for erasure.

Create install.json from real hardware observations. Keep passwords and provider credentials out of chat and files; let me enter passwords locally. Once the exact disk plan is authorized, complete the installation, persist the skill and stage information, and continue after reboot.

Configure the documented GNOME functions, terminal style, input method, snapshots and QQ fixes. Report tests and pending visual assets honestly. Do not claim identical UI without matching wallpaper, extension settings and screenshot comparison.
```

默认 `video-2025` 保留视频方案。想采用作者当前 `/efi` + Snapper + IBus 的改进版，把 profile 改成 `project-current`，此时应明确这是“当前项目方案”，不是未经说明地修改第一部分。

如果要包括高级功能，再追加：

```text
Also configure KVM and GPU passthrough if the inspected hardware supports them. Identify separate host/guest GPUs and IOMMU groups before any vfio binding. Ask for the Windows ISO when it is needed and verify a real guest boot.
```

不需要高级功能就不要追加。

## 6. 独立磁盘的确定性安装入口

这一小节给 Agent 和熟练读者使用；同盘保留 Windows 的读者不执行。

```bash
cd /root/arch-job/.opencode/skills/shorin-arch-install
python scripts/install.py inspect
cp assets/install.example.json install.json
```

让 Agent 依据 inspect 填：目标盘、真实序列号/型号/字节容量、CPU、GPU、普通用户名、Swap 大小、KVM 需求。示例容量为 0，刻意不允许直接运行。

```bash
python scripts/install.py plan --config install.json > reviewed-plan.sh
cat reviewed-plan.sh
python scripts/install.py apply --config install.json
```

`plan` 不写磁盘；`apply` 只在 Arch ISO Live 中执行，会要求在本地输入包含准确磁盘路径与容量的 `ERASE ...` 字符串。**目标整盘的所有分区会被删除**。确认对象是安装独立盘，不是 Windows 系统盘/U 盘；密码另在本地 passwd 提示中输入。

发生错误后不要重新整段 apply：安装器会阻止同一 Live 启动中自动重复格式化。重启 Live 后 marker 会消失，Agent 仍须检查现存文件系统，按已完成步骤续装，不能再次清空。

## 7. 重启后续装

成功后工具将完整 skill、配置、执行计划和计划 hash 放入新系统 `/root/shorin-arch-install/`。重启前核对它们存在，再按工具输出卸载 `/mnt`、重启。

新系统登录普通用户，联网；重新安装/启动 Agent 或加载你提供的同一个 skill。不要再次调用 apply。需要复制持久化版本到普通用户工作目录时：

```bash
sudo cp -a /root/shorin-arch-install "$HOME/shorin-arch-install"
sudo chown -R "$USER" "$HOME/shorin-arch-install"
cd "$HOME/shorin-arch-install"
```

复制没有包含密码/API auth 文件。OpenCode 可以把此目录复制到新的 `.opencode/skills/` 下，也可以直接让它读这里的 `SKILL.md`。

提示词：

```text
Continue the shorin-arch-install workflow from the installed system. Base installation is already complete; never repartition or reformat. Load install.json and complete the selected desktop, snapshots, input method, software and QQ workflow, then perform acceptance checks.
```

Ghostty/已知视频设置在普通 GNOME Wayland 用户的终端运行：

```bash
bash scripts/session.sh video-2025
```

然后 Agent 按 references 完成扩展、快捷键、Timeshift、AUR/日用软件、QQ doctor 与实际功能测试。脚本不是整个桌面配置的替代。

## 8. 对读者怎样宣布安装完成

至少分三项说明：

1. 系统是否已经真实启动、网络/驱动/输入/音频是否通过。
2. 视频功能和所选高级模块哪些已验证，哪些待操作。
3. 同款视觉哪些已匹配，缺哪些素材或参数。

运行 `bash scripts/verify.sh` 并使用 [完整验收表](../../skills/shorin-arch-install/references/acceptance.md)。目前这份分发包的状态是“教程和 Agent 流程已整理、基础自动化已编写和静态测试；端到端安装与像素级同款尚未验证”。待一次测试安装通过、同款素材补齐后再把宣传文案改成“已验证一键同款”。
