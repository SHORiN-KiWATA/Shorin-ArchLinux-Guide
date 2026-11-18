目录

- [为什么需要调优](#为什么需要调优)
- [开机引导与驱动预载](#开机引导与驱动预载)
- [彻底禁用休眠与挂起](#彻底禁用休眠与挂起)
- [限制内存脏页解决写入卡顿](#限制内存脏页解决写入卡顿)
- [开启外接SSD的TRIM支持](#开启外接ssd的trim支持)
- [配置BFQ调度器](#配置bfq调度器)
- [检查验证](#检查验证)

---

## 为什么需要调优

将 Linux 装在外接移动固态硬盘（USB 或 Type-C 硬盘盒）并作为日常主系统时，有几个容易踩坑的地方：

1. **睡眠唤醒容易掉盘**：电脑挂起或休眠时，主板会切断 USB 供电。唤醒后外接盘重新连接需要时间，系统找不到根分区就会直接报只读错误或卡死崩溃。
2. **冷开机找不到盘**：开机时如果 USB 驱动加载慢了，系统容易因为没检测到外接盘而掉进救援模式。
3. **写入大文件前台卡顿**：Linux 默认的内存脏页阈值较高，向外接盘写入大文件时容易瞬间堵满 USB 通道，导致鼠标和桌面变卡。
4. **默认不开启 TRIM**：系统默认不对 USB 外接存储发送 TRIM 指令，长期使用会影响固态硬盘寿命和写入速度。

## 开机引导与驱动预载

### 1. 将外接盘驱动打包进内核镜像

编辑 `/etc/mkinitcpio.conf`：

```bash
sudo vim /etc/mkinitcpio.conf
```

找到 `MODULES=(...)`，在里面加上外接盘和 USB 驱动：

```text
MODULES=(uas usb_storage xhci_pci nvme)
```

保存后重新生成镜像：

```bash
sudo mkinitcpio -P
```

### 2. 添加开机等待与防休眠参数

编辑 `/etc/default/grub`：

```bash
sudo vim /etc/default/grub
```

在 `GRUB_CMDLINE_LINUX_DEFAULT` 这一行的末尾加上 `rootwait usbcore.autosuspend=-1 nvme_core.default_ps_max_latency_us=0`：

```text
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 rootwait usbcore.autosuspend=-1 nvme_core.default_ps_max_latency_us=0"
```

- `rootwait`：让内核开机时一直等待外接盘就绪，避免因硬盘盒启动慢而报错。
- `usbcore.autosuspend=-1`：禁止 USB 接口自动休眠节电。
- `nvme_core.default_ps_max_latency_us=0`：禁止 NVMe 硬盘深度节能，防止空闲时掉盘。

更新 GRUB 配置：

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 彻底禁用休眠与挂起

外接系统盘绝对不能进入挂起或休眠，否则唤醒基本必崩。需要在系统底层把休眠功能彻底关掉。

### 1. 禁用 systemd 睡眠功能

创建配置文件 `/etc/systemd/sleep.conf.d/disable-sleep.conf`：

```bash
sudo mkdir -p /etc/systemd/sleep.conf.d
sudo vim /etc/systemd/sleep.conf.d/disable-sleep.conf
```

写入以下内容：

```ini
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
```

### 2. 笔记本合盖仅锁屏

创建配置文件 `/etc/systemd/logind.conf.d/disable-suspend.conf`：

```bash
sudo mkdir -p /etc/systemd/logind.conf.d
sudo vim /etc/systemd/logind.conf.d/disable-suspend.conf
```

写入以下内容：

```ini
[Login]
HandleLidSwitch=lock
HandleLidSwitchExternalPower=lock
HandleLidSwitchDocked=ignore
HandleSuspendKey=ignore
HandleSuspendKeyLongPress=ignore
HandleHibernateKey=ignore
HandleHibernateKeyLongPress=ignore
IdleAction=ignore
```

> 重启电脑后生效。

### 3. 屏蔽睡眠目标

在终端运行以下命令，彻底阻断触发睡眠的通道：

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
```

## 限制内存脏页解决写入卡顿

创建 `/etc/sysctl.d/99-usb-dirty-ratio.conf`：

```bash
sudo vim /etc/sysctl.d/99-usb-dirty-ratio.conf
```

写入：

```ini
# 未刷盘数据达到 16MB 时后台就开始异步写入
vm.dirty_background_bytes = 16777216

# 未刷盘数据达到 48MB 时强制限制写入速度，防止堵死 USB 通道
vm.dirty_bytes = 48234496
```

立即生效：

```bash
sudo sysctl --system
```

## 开启外接SSD的TRIM支持

### 1. 查找外接盒硬件 ID

在终端运行：

```bash
lsusb
```

找到你的外接硬盘盒，例如：

```text
Bus 002 Device 002: ID 0b05:1932 ASUSTek Computer, Inc. ROG STRIX ARION
```

这里的 `0b05` 是厂商 ID（idVendor），`1932` 是产品 ID（idProduct）。

### 2. 添加 udev 规则

创建 `/etc/udev/rules.d/10-scsi-unmap.rules`（把 `0b05` 和 `1932` 换成你查到的数字）：

```bash
sudo vim /etc/udev/rules.d/10-scsi-unmap.rules
```

写入：

```udev
ACTION=="add|change", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="1932", SUBSYSTEM=="scsi_disk", ATTR{provisioning_mode}="unmap"
```

重载规则：

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=scsi_disk
```

### 3. 开启每周自动 TRIM

```bash
sudo systemctl enable --now fstrim.timer
```

此时运行 `lsblk -D`，可以看到外接盘的 `DISC-GRAN` 不再是 0，说明 TRIM 已经正常工作。

## 配置BFQ调度器

BFQ 调度器能保证前台界面交互的流畅度，避免后台大读写抢占通道。

创建 `/etc/udev/rules.d/60-ioschedulers.rules`：

```bash
sudo vim /etc/udev/rules.d/60-ioschedulers.rules
```

写入：

```udev
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="bfq"
```

重载规则：

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## 检查验证

重启电脑后，可以运行以下命令检查各项优化：

```bash
# 检查开机参数是否包含 rootwait
cat /proc/cmdline

# 检查睡眠目标是否已被屏蔽，应显示 masked
systemctl is-enabled sleep.target suspend.target

# 检查 TRIM 是否生效，DISC-GRAN 应大于 0
lsblk -D

# 检查 TRIM 定时器是否开启，应显示 active
systemctl is-active fstrim.timer

# 检查调度器，应该包含 [bfq]
cat /sys/block/sdX/queue/scheduler
```
