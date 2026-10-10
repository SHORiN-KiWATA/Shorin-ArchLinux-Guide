# 视频后半段：KVM、显卡直通、远程桌面、性能

源：[source-index.md](source-index.md) 所链接的 2025 原文的 KVM/显卡直通/远程桌面/性能优化章节；当前细节可参 [KVM虚拟机.md](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/d8772456749981c0de3417a84c2783578603cfc6/wiki/archlinux/KVM%E8%99%9A%E6%8B%9F%E6%9C%BA.md)。这些模块是显式按需功能，不能把不具备条件当作安装失败，也不能在启用时只安装包就报完成。

## KVM

安装 `qemu-full virt-manager swtpm dnsmasq edk2-ovmf`。启动 `libvirtd`；普通用户加入 libvirt 组并重新登录；确认 `virsh -c qemu:///system list --all` 可用。查询 default 网络是否存在，再启动、自启，不盲目重复 net-start。用户提供合法 Windows ISO，安装 virtio 驱动、需要的虚拟 TPM/UEFI；实际启动 guest 后测试网络。

视频原文修改 qemu.conf 的 user/group 是为处理存储权限，不作为默认必要步骤；先用 libvirt 正常存储池/权限配置，只有现场失败与原文情景一致时再调整。桥接仅按需求配置，远程 SSH 控制安装时避免把当前网卡立即移入未验证的桥导致断联。

文件共享：虚拟机共享内存 + virtiofs；Windows 装 WinFSP、VirtIO-FS Service；验收双向读写。不把挂载一项配置当作成功。

## 显卡直通

检查 CPU 虚拟化/IOMMU 开关、`dmesg` 和 `/sys/kernel/iommu_groups`；记录 PCI BDF 与 vendor/device IDs，确定宿主 GPU 和客体 GPU。笔记本单 GPU 或宿主正在使用要直通的卡，不能套用双卡冷直通流程。选择不可拆开的完整 IOMMU group，未知设备停下调查。不要复制作者 ID。

视频路线为 vfio-pci 绑定目标 GPU/音频，mkinitcpio MODULES/HOOKS，重建 initramfs，重启后确认 `lspci -nnk` 使用 `vfio-pci`，再在 virt-manager 增加 PCI Host Device。先保存原始 vfio.conf、mkinitcpio.conf、GRUB 配置和可用启动项。回退时移除绑定并重建 initramfs。OVMF 路径从 `pacman -Ql edk2-ovmf` 获取，不能照抄过期路径。

内存大页/CPU pinning 要按本机拓扑、可用 RAM 和 guest 配置分配，保留宿主资源。不要无条件分配全部内存/核心。

## 远程桌面

作者视频 Sunshine + Moonlight：宿主 Sunshine、客户端 Moonlight、按应用界面配对，测视频/声音/输入和延迟。不要自动公开端口或上传访问凭据。镜像/流服务不代替实际配对验收。

## 性能

ZRAM=`ram`、zstd，禁用 zswap；核对 `zramctl` 和 `/sys/module/zswap/parameters/enabled`。可选 linux-zen/linux-zen-headers，NVIDIA 使用匹配 DKMS，重建 GRUB，重启后 `uname -r` 确认。NVIDIA powerd 仅适用支持的 GPU，报错时检查支持性；LACT 的超频/降压和烤机不属于默认安装。原视频最后删除 Linux 的章节仅作为卸载附录，不执行于安装任务。
