---
title: Arch Linux使用Sunshine+Moonlight远程串流
summary: 记录 niri/Wayland 混合显卡环境下的游戏串流配置，以及从“主机无视频”定位到跨 GPU 画面导入失败的完整修复过程
date: 2026-08-01
tags: [Arch Linux, Sunshine, Moonlight, 游戏串流]
---

## 为什么选择 Sunshine + Moonlight

环境：archlinux+niri+dms(dankmasterialshell)
电脑配置：
- CPU:Intel(R) Core(TM) i7-10750H (12) @ 5.00 GHz
- GPU0:Intel UHD Graphics
- GPU1:NVIDIA GeForce GTX 1660 Ti Mobile

虽然网易的UU远程非常好用，但是它只适配了Windows和Mac，暂时放弃了“庞大”的linux用户（之前b站发文称正在适配linux，可以期待一波）。在一番寻找之后，我发现了它的开源替代，同时也是远程串流的前辈sunshine和moonlight。在抉择sunshine和rustdesk的时候，GPT给我的建议是sunshine，说我的archlinux+niri+dms的环境比较特殊，sunshine更加底层，更容易成功，于是就开始摸索sunshine方案了。

Sunshine 是运行在电脑上的开源串流主机，负责捕获桌面、调用显卡编码视频，并接收客户端的键鼠或手柄输入；Moonlight 则运行在手机、平板或另一台电脑上，负责发现主机、解码视频和回传操作。二者使用局域网时不依赖第三方中继，画面也不会先绕到云端再回来。

## 如何配置 Sunshine 和 Moonlight

### 安装 Sunshine

我的主机是 Arch Linux，桌面环境为 `niri + Wayland`。Sunshine 可以通过当前系统的软件仓库或 AUR 安装；仓库中已提供该包，可以直接执行：

```bash
sudo pacman -S sunshine
```

安装后启动 Sunshine，在主机浏览器打开管理页面：

```text
https://localhost:47990
```

首次进入时需要创建管理账号和密码。这个账号只用于 Sunshine 管理页面，不是 Moonlight 的配对密码。

在“应用程序”中保留或添加 `Desktop` 即可串流整个桌面。建议先不要添加修改分辨率、启动游戏或切换显示器的脚本，等基础串流稳定后再逐项增加，这样排错时变量更少。

### 安装并配对 Moonlight

在 Android 设备上安装 Moonlight （Github上寻找，我用的版本是Moonlight V+）后，让手机和电脑连接到同一局域网。Moonlight 通常能自动发现 Sunshine；若没有发现，可以手动填写电脑的局域网IP地址。主机地址可用下面的命令查看：

```bash
ip -br addr
```

选择主机后，Moonlight 会显示一组 PIN。回到 Sunshine 管理页面，在配对页面输入这组 PIN，成功后客户端便能看到 `Desktop` 等应用入口。

确认画面、声音和输入都正常后，再根据无线网络质量提高码率或分辨率。高参数并不一定带来更好的体验，稳定的帧时间通常比单纯提高码率更重要。

## 我这台niri+双显卡Arch Linux遇到的问题

### 表面现象：Moonlight 提示检查 UDP 端口

配对和应用列表都正常，但从手机打开 `Desktop` 后始终没有画面。Moonlight 最终提示：

```text
没有接收到来自主机的视频。
请检查您的防火墙和端口转发规则中的端口：UDP 47998、UDP 48000。
```

这个提示让人误以为是防火墙的问题。然而主机sunshine日志中出现了下面两行：

```text
New streaming session started [active sessions: 1]
CLIENT CONNECTED
```

这说明 Moonlight 已经连接到 Sunshine，控制链路和会话创建都成功了。手机与电脑位于同一 Wi-Fi 子网，从手机到 Sunshine 的 TCP 端口也可以正常访问；主机上的 `firewalld`、`ufw` 和 `nftables.service` 均未启用。网络没啥毛病。

### 真正的错误：画面无法导入编码器

客户端连接后，Sunshine 日志开始高频重复以下错误：

```text
Couldn't import RGB Image: 0000300C
Could not convert image
```

`0x300C` 对应 EGL 的 `EGL_BAD_PARAMETER`。错误发生在画面捕获结果导入和颜色转换阶段，也就是视频送入编码器之前。Sunshine 没能生成可编码的视频帧，Moonlight 自然收不到视频，最后只能给出一个通用的 UDP 超时提示。

启动时还有 AV1 编码器不可用的错误：

```text
Codec not supported
Provided device doesn't support required NVENC features
```

这部分并不是故障原因。GTX 1660 Ti 本来就不支持 AV1 NVENC，而 Sunshine 会在启动时依次测试可用编码器；日志随后已经明确找到 H.264 和 HEVC 编码器，所以 AV1 测试失败可以忽略。

### 根因：Wayland 下的跨 GPU DMA-BUF 导入

这台笔记本是混合显卡结构：

- Intel UHD Graphics 驱动为 `i915`，对应 `/dev/dri/renderD128`
- NVIDIA GeForce GTX 1660 Ti 对应 `/dev/dri/renderD129`
- 内屏 `eDP-1` 物理连接在 Intel 核显上
- `niri` 使用 Intel `renderD128` 作为主渲染节点

Sunshine 通过 Wayland screencopy 协议捕获内屏，因此拿到的是来自 Intel GPU 的 DMA-BUF；自动选择编码器时，它又选中了 NVIDIA 的 `hevc_nvenc`。于是实际链路变成：

```text
Intel / niri 捕获画面
        ↓
Wayland DMA-BUF
        ↓
NVIDIA EGL 导入并交给 NVENC
```

问题就发生在最后一步：当前 NVIDIA EGL/GBM 路径无法正确导入 Intel 侧的 RGB DMA-BUF，Sunshine 因而持续报 `EGL_BAD_PARAMETER`。H.264 NVENC 和 HEVC NVENC 共用这段图像导入路径，所以只在 Moonlight 中把 HEVC 改成 H.264，通常不会解决问题。

### 解决方案：让捕获和编码留在同一块 GPU

`vainfo` 已确认 Intel `renderD128` 支持 H.264 和 HEVC 硬件编码。最简单、稳定的处理方式，是让 Sunshine 同样使用 Intel VAAPI，避免跨 GPU 导入。

编辑 Sunshine 配置文件：

```text
~/.config/sunshine/sunshine.conf
```

加入以下配置：

```ini
encoder = vaapi
adapter_name = /dev/dri/renderD128
```

重启 Sunshine 后，日志出现：

```text
Found H.264 encoder: h264_vaapi [vaapi]
Found HEVC encoder: hevc_vaapi [vaapi]
```

再次从 Moonlight 进入桌面，画面、声音和输入均恢复正常，原先反复出现的 `Couldn't import RGB Image: 0000300C` 也不再出现。

如果 VAAPI 仍无法工作，可以临时使用软件编码进一步隔离问题：

```ini
encoder = software
```

软件编码能出画面，便可以确认问题位于 GPU 导入或硬件编码链路，而不是网络。不过软件编码会明显增加 CPU 占用，更适合作为诊断手段，不是这台机器的长期方案。

### Intel 编码会不会让游戏也使用核显

不会。Sunshine 的 `encoder` 只决定“谁负责把捕获到的画面压缩成视频”，不会决定游戏使用哪块显卡。当前分工是：

```text
NVIDIA：渲染游戏
Intel：驱动内屏并通过 VAAPI 编码串流
```

在混合显卡环境中，可以用 `prime-run` 明确让游戏使用 NVIDIA：

```bash
prime-run 游戏命令
```

Steam 游戏可在“启动选项”中填写：

```bash
prime-run %command%
```

游戏运行时执行 `nvidia-smi`，如果进程出现在列表中，就说明它正在使用 NVIDIA GPU。让 Intel 负责串流编码还能减少 NVIDIA 上的额外工作，使两块 GPU 各自承担更合适的任务。

## 将 Sunshine 设置为 systemd 用户服务

Arch Linux 当前安装的 Sunshine 包提供了用户级 systemd unit：

```text
/usr/lib/systemd/user/app-dev.lizardbyte.app.Sunshine.service

[Unit]
Description=Self-hosted game stream host for Moonlight
StartLimitIntervalSec=500
StartLimitBurst=5
After=graphical-session.target xdg-desktop-autostart.target xdg-desktop-portal.service

[Service]
# Avoid starting Sunshine before the desktop is fully initialized.
ExecStartPre=/bin/sleep 5
ExecStart=/usr/bin/sunshine

Restart=on-failure
RestartSec=5s

[Install]
WantedBy=graphical-session.target
Alias=sunshine.service
```

启用并立即启动：

```bash
systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service
```

检查是否已启用，以及当前是否正在运行：

```bash
systemctl --user is-enabled app-dev.lizardbyte.app.Sunshine.service
systemctl --user status app-dev.lizardbyte.app.Sunshine.service
```

实时查看日志：

```bash
journalctl --user -u app-dev.lizardbyte.app.Sunshine.service -f
```

该 unit 依赖 `graphical-session.target`、桌面 portal 和 Wayland 会话，因此这里所说的“开机自启动”，准确地说是**用户登录图形会话后自动启动**。这正适合需要捕获当前桌面的 Sunshine。强行让它在无人登录、Wayland 尚未建立时运行，通常无法获得可捕获的显示器，并不值得为了字面上的“系统启动即运行”而增加额外复杂度。

如果以后不再需要自动启动，可以执行：

```bash
systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service
```

