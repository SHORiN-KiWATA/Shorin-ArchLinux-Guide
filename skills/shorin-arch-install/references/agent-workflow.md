# Agent 执行流程

## 安装前

盘点 `uname -m`、`/run/archiso`、UEFI 位数、`lsblk -bJpo NAME,TYPE,SIZE,MODEL,SERIAL,MOUNTPOINTS,FSTYPE,RO`、`lscpu`、`lspci -nnk`、`free -h`、`df -h`、`swapon --show`。不能把用户当前 macOS/Windows 或 Docker 当成 Arch Live。

联网由有线、手机 USB 或 iwctl 完成。不要把 Wi-Fi 密码/API 密钥写入持久日志。NTP 开启后确认时间。

`cowspace`：先 `findmnt /run/archiso/cowspace`、`free -h`、`df -h /run/archiso/cowspace`；确认是 tmpfs 且内存允许，再例如 `mount -o remount,size=4G /run/archiso/cowspace`。4G 是空间上限，不是预先占用；低内存设备需更小值或外部持久工作盘。若不存在，不猜路径。安装 OpenCode 本身需要空间，所以尽可能先扩大再安装。

Live 中按作者项目安装 `pacman -Sy --needed opencode`，然后 `opencode`，用 `/models` 选择当前可用模型或 `/connect` 接入已有供应商。免费模型的名称、额度会变，不预先承诺任何指定免费模型。使用已有 Agent 可以省略这一步。不要 `pacman -Syu` 升级 Live 的整套内核而期待重启后保留；已安装系统则避免部分升级。

整盘 runner 要求 `/run/archiso/bootmnt` 仍有可识别的 ISO 来源挂载；copy-to-RAM 或无法识别来源时停止，转人工分区流程，避免误清空启动介质。

## 把安装变成可审核结果

创建 `install.json`，没有真实设备信息时保持 invalid 的 example，不替用户填随机磁盘序号。运行 plan，可在任何 OS 上生成 shell，但 apply 只能在目标 Live 环境。

记录：磁盘型号、序列号、容量、现有分区、要保留的数据、将创建的 ESP/Btrfs 子卷、CPU 微码/GPU 包名、profile、交换空间、用户名、时区、引导项和模块。整盘清空仅用于明确选定的独立目标盘。批准后直接完成授权内容，不无故增加确认。

## 同盘双系统分支

整盘 runner 不支持这一场景。用作者手动分区路线：Windows 先压缩卷得到未分配空间；Live 再查看 GPT，只在未分配空间中建 Linux ESP（视频 512 MB，当前 1 GB 示例）和根分区，记录实际 PARTUUID 和设备名。不要格式化 Windows 的 ESP/NTFS/MSR/恢复分区。若复用 ESP，单独确认不格式化，备份 EFI 内容，使用 `mount --mkdir` 挂载。

所有 `mkfs` 针对已确认的具体 Linux 分区；执行前重读 `lsblk -f` 和 `blkid`。作者视频将 Windows ESP 另挂 `/winboot` 用于 os-prober；可先只读确认再决定是否需挂载。GRUB 出现 Windows 项后做双向启动检查。

## 错误与重启

失败后停止该阶段，保留命令退出码和现场挂载；禁止整段重跑。已经成功格式化的分区不能再次格式化。网络失败修网络、缺包核对源、引导失败检查 UEFI/ESP。要重新启动 Live 时，先保存 skill、配置、源 SHA 和已完成阶段到目标盘或外部持久盘。`/run` 内容会消失，因此每次续装都再次识别现场，不依赖 marker 当唯一状态。

首次安装完成后用户输入密码、保存进度、卸载 `/mnt`、按要求重启。普通登录用户可以使用 sudo；先加载原 skill/配置继续，不直接运行格式化阶段。是否自动重启以已有授权为准。工具 runner 只输出重启命令。
