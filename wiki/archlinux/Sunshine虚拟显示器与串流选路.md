目录

- [什么情况下需要这篇](#什么情况下需要这篇)
- [一、先分清是哪一类问题](#一先分清是哪一类问题)
- [二、主机没有显示器：用 EDID 伪造一台](#二主机没有显示器用-edid-伪造一台)
- [三、画面有了但卡：把串流钉到有线链路](#三画面有了但卡把串流钉到有线链路)
- [四、排查顺序](#四排查顺序)
- [附录：一份现成的 EDID](#附录一份现成的-edid)

---

这篇讲的是**主机侧**的两个问题：电脑没接显示器时串流黑屏，以及电脑同时有有线和 WiFi 时串流走错链路。Sunshine 与 Moonlight 的安装、配对、编码器选择不在这里，请先看 [KVM虚拟机·远程桌面](KVM虚拟机.md#sunshinemoonlight) 或社区教程。

## 什么情况下需要这篇

- 主机放在柜子里、机架里，**没有接显示器**，人不在旁边，只能靠远程串流使用；
- 主机**同时连着有线和无线**，或者有两块网卡，串流经常卡、画质忽高忽低；
- 你已经装好 Sunshine 并配对成功，但打开应用后是黑屏、只有几百×几百的分辨率，或者画面抖动。

如果你的主机就接着显示器、只有一条网线，这两节都用不上，直接跳过。

## 一、先分清是哪一类问题

同样是"串流不正常"，原因可能完全不同。先对号入座，再看对应的章节，能省掉大量试错：

| 现象 | 大概率原因 | 对应章节 |
| --- | --- | --- |
| Moonlight 能连上、能看到应用列表，但打开后黑屏，或分辨率低得离谱 | 主机没有接显示器，显卡输出接口处于未启用状态 | [第二节](#二主机没有显示器用-edid-伪造一台) |
| 画面有，但码率上不去、卡顿、掉帧、延迟抖动 | 主机有多条网络路径，客户端走了差的那条（通常是 WiFi） | [第三节](#三画面有了但卡把串流钉到有线链路) |
| 连都连不上、配对失败 | 防火墙、端口没通、Sunshine 没在运行 | 不在本文范围 |
| 能连上也有画面，但编码很慢、GPU 占用异常 | 采集和编码不在同一块显卡上 | 不在本文范围（混合显卡机器需单独排查） |

> **提示**：本文出现的端口名、IP、主机名都是示例，**照抄前必须换成你自己机器的值**。

## 二、主机没有显示器：用 EDID 伪造一台

### 原理：先知道这三件事

1. 显示器插上后，会通过线缆把一份叫 **EDID** 的数据交给显卡。这份数据里写着"我是多大尺寸、什么分辨率、支持哪些刷新率和 HDR"。显卡据此决定输出什么画面。
2. 主机**没有接显示器**，就没有这份数据，显卡会认为这个输出接口上什么都没有，于是不输出画面。没有画面，Sunshine 自然采不到东西，客户端只能黑屏或者退到极低分辨率。
3. 市面上卖的"显卡诱骗器 / 假负载 / HDMI 假显示器"，本质就是一颗把 EDID 冒充给显卡的小插头。我们可以不买硬件，直接让**内核**加载一份 EDID 文件，效果相同。

要用到两个内核参数和一次 initramfs 打包：

| 参数 | 作用 |
| --- | --- |
| `drm.edid_firmware=<端口>:<固件路径>` | 给指定端口喂这份 EDID |
| `video=<端口>:e` | 强制把该端口置为"已启用"，忽略"没插东西"的检测 |

固件必须打进 **initramfs**（开机时先于根文件系统加载的那一小块内存盘），因为显卡驱动在开机极早期就要读它，那时根文件系统还没挂载。

### 第 1 步：确认输出接口名

```bash
ls -d /sys/class/drm/card*-*
```

你会看到 `card0-DP-1`、`card0-HDMI-A-1`、`card1-DP-2` 这样的目录。**目录名去掉 `cardN-` 前缀就是端口名**，例如 `card0-DP-1` 对应 `DP-1`。

顺手看一眼每个接口当前的状态：

```bash
for p in /sys/class/drm/card*-*/status; do echo "$p: $(cat "$p")"; done
```

`disconnected` 的就是空着的接口，正是我们要伪造的那一个。多显卡的机器（核显 + 独显）会有 `card0`、`card1`，注意选**实际接显示器的那块卡**上的端口。

### 第 2 步：准备一份 EDID 文件

两种来源，任选其一。

**方式一：从手上能插的显示器提取（更稳）**

把一台显示器接到主机的目标接口上，执行：

```bash
sudo mkdir -p /usr/lib/firmware/edid
sudo cp /sys/class/drm/card0-DP-1/edid /usr/lib/firmware/edid/virtual-display
sudo chmod 644 /usr/lib/firmware/edid/virtual-display
```

这样伪造出来的"显示器"，分辨率和刷新率与你提取时用的那台完全一致，兼容性最好。

**方式二：使用一份现成的 4K@60Hz EDID**

手上没有第二台显示器可用时，可以直接使用[附录](#附录一份现成的-edid)里那份演示 EDID；写入命令和自查方法都放在附录，避免正文被一大串十六进制数据占据。

### 第 3 步：把固件打进 initramfs

编辑 `/etc/mkinitcpio.conf`，找到 `FILES=()` 这一行（可能被注释掉了），改成：

```bash
FILES=("/usr/lib/firmware/edid/virtual-display")
```

然后重新生成：

```bash
sudo mkinitcpio -P
```

> 如果引导用的不是 mkinitcpio（例如 Debian/Ubuntu 的 initramfs-tools、openSUSE 的 dracut），需要按对应发行版的方式把固件加进 initramfs，原理相同：**让内核在开机早期就能读到这个文件**。

### 第 4 步：加内核启动参数

**GRUB** 用户编辑 `/etc/default/grub`，在 `GRUB_CMDLINE_LINUX_DEFAULT` 的引号里加上（注意是**加**在原有内容后面，不要整行替换）：

```text
drm.edid_firmware=DP-1:edid/virtual-display video=DP-1:e
```

保存后更新引导配置：

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**systemd-boot** 用户则编辑 `/boot/loader/entries/` 下你正在用的那个 `.conf`，在 `options` 那一行末尾追加同样的内容。

> 端口名必须和第 1 步查到的**完全一致**。用 HDMI 口就写 `HDMI-A-1`，写错了内核会静默跳过，表现为"参数加了但没效果"。

### 第 5 步：重启并验证

```bash
# 1) 确认参数真的生效了
cat /proc/cmdline

# 2) 端口应显示 connected（没接显示器也是）
cat /sys/class/drm/card0-DP-1/status

# 3) 能列出分辨率说明 EDID 被识别了
cat /sys/class/drm/card0-DP-1/modes
```

第 2 步是 `connected`、第 3 步有分辨率输出，就说明系统认为"这个口上接了一台显示器"，Sunshine 也就能采到画面了。

### 出问题时先看这几处

| 现象 | 大概率原因 |
| --- | --- |
| `status` 仍然是 `disconnected` | 端口名写错，或 `video=...:e` 没加 |
| `/proc/cmdline` 里没有参数 | 改错了文件，或忘了更新引导配置（`grub-mkconfig`） |
| 参数在、状态也对，但没画面 | 固件没进 initramfs，`dmesg \| grep -i edid` 会有加载失败提示 |
| 重启后进不了图形界面 | 引导参数有误，进 GRUB 菜单按 `e` 临时删掉这两个参数再进系统 |

> **警告**：改内核参数属于"改坏了可能开不了机"的操作。动手前确认自己会进 GRUB 编辑临时参数，或者有 Live USB 可以救援。

## 三、画面有了但卡：把串流钉到有线链路

### 现象

主机同时连着有线和 WiFi，两条路都能到达客户端。你已经在 Moonlight 里手动填了**有线**地址，实际串流跑的却是 **WiFi**，于是画质抖动、卡顿。

注意：两条路"都能 ping 通"不代表质量一样。实测中 WiFi 那一路延迟可以从 40 ms 抖到 200 ms，甚至出现丢包——只看连通性会得出完全相反的结论。

### 为什么？三个机制叠加

1. **手动填的地址排在最后。**
   `moonlight-qt` 选择主机地址的顺序是：
   `activeAddress → localAddress → remoteAddress → ipv6Address → manualAddress`。
   手填的 `manualAddress` 只是最后的兜底，前面任何一个能用，就轮不到它。

2. **`localAddress` 会被服务端覆盖。**
   每次刷新主机列表，本地记录的地址都会被 Sunshine `/serverinfo` 接口返回的 `<LocalIP>` 覆盖。而这个值实际是"这次请求从哪块网卡出去的"。你在客户端怎么填，都改不动它。

3. **mDNS 每次启动都会重置 `localAddress`。**
   启动时 Moonlight 会重新解析主机名，把 `localAddress` 设成解析出的第一个 IPv4——在多网卡主机上，这往往就是 WiFi。

结论：**只改地址、不关 mDNS，下一次启动又会被打回 WiFi**。两处必须一起改。

### 修复

配置文件在：

```text
~/.config/Moonlight Game Streaming Project/Moonlight.conf
```

**先完全退出 Moonlight，再编辑文件**。运行中修改，或者只关窗口不退出，内存里的旧值会回写文件，改动被覆盖。

在文件里找到对应主机的段落，做两处修改：

```ini
[General]
mdns=false

1\hostname=我的主机
1\localaddress=192.168.1.10
1\localport=47989
1\manualaddress=192.168.1.10
1\manualport=47989
```

- `mdns=false`：关掉 mDNS 自动发现。图形界面里对应"设置 → 关闭 mDNS 主机发现"。**这一步不能省。**
- `1\localaddress=` ：直接钉成有线口的地址。

`remoteaddress`（公网）、`ipv6address` 这些兜底项**保留不要删**，它们只是不再被优先命中。

### 验证

```bash
# 启动客户端，看首次连接落到了哪个地址
moonlight 2>&1 | grep 'online at'
# 期望看到类似："我的主机" is now online at "192.168.1.10:47989"

# 确认地址已落盘
grep '^1\\localaddress=' "$HOME/.config/Moonlight Game Streaming Project/Moonlight.conf"
```

重启 Moonlight 后再执行一次第二条命令，值仍然是 `192.168.1.10`，说明 `mdns=false` 起效了。如果又变回 WiFi 地址，说明配置没保存成功，或者 Moonlight 没真正退出。

> **提示**：主机只有一条网络路径时，这一节不需要做。把 mDNS 关掉反而会让"自动发现主机"失效，需要手动填地址。

## 四、排查顺序

遇到"串流不正常"，按这个顺序走，能避免在错误的方向上折腾：

1. **先确认主机是否有可用显示输出**
   `cat /sys/class/drm/card*-*/status`，全是 `disconnected` 就先解决第二节的问题。
2. **再确认客户端连的是哪个地址**
   `moonlight 2>&1 | grep 'online at'`，多网卡主机看是不是走错了链路（第三节）。
3. **然后才看编码**
   前两步都正常才值得怀疑显卡、编码器、码率设置。
4. **一次只改一个变量**
   改完重启验证，有效再改下一处。同时改三处，出问题时无法判断是哪一处造成的。

相关：[KVM虚拟机·远程桌面](KVM虚拟机.md#sunshinemoonlight)（虚拟机内串流）｜[显卡切换](显卡切换.md)（多显卡机器上固定用哪块卡）

---

## 附录：一份现成的 EDID

<details>
<summary>[展开/收起] 4K@60Hz 演示 EDID（256 字节）</summary>

这份数据用 `edid-decode` 解出来是：产品名 `HDP-V104`、序列号 `demoset-1`、首选时序 3840×2160@59.98 Hz，另外带一组 1080p / 1080i 模式。

它是**合成的演示数据**：厂商 ID 和序列号都不是真实设备，也不是从哪台显示器上提取的。所以：

- 只在你没有第二台显示器、无法用「方式一」提取时再用它；
- 它固定提供 4K@60 时序，弱核显或老接口不一定带得动；需要其他分辨率请换成自己的 EDID。

```bash
sudo mkdir -p /usr/lib/firmware/edid
echo "00ffffffffffff000843040199999999011c0103804f00783eee91a3544c99260f5054bfef80d1c0d1e8d1fc950090408180814081c040d000a0f0703e803020350058c31000001a000000fc004844502d563130340a20202020000000ff0064656d6f7365742d310a203020000000fd0018900fde3c000a2020202020200158020356425e04051013141f2021222748494a4b4c5d5e5f606162636465666768696a6be200d5e305c00023097f0783010000e50f00000c006e030c00100038782000800102030467d85dc401788801e606050169694f023a801871382d40582c250058c31000001e011d8018711c1620582c250058c31000009e000000000016" | xxd -r -p | sudo tee /usr/lib/firmware/edid/virtual-display > /dev/null
sudo chmod 644 /usr/lib/firmware/edid/virtual-display
```

写入后建议先自查一遍，确认数据能被正确解析（`edid-decode` 需要单独安装）：

```bash
sudo pacman -S edid-decode
edid-decode /usr/lib/firmware/edid/virtual-display
```

输出里能看到 `Display Product Name: 'HDP-V104'`、`3840x2160 59.98 Hz` 以及有效的 `Checksum`，就说明这份 EDID 是完好的。

</details>
