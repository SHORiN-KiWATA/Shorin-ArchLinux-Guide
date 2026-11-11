目录

- [原理解析](#原理解析)
- [准备脉冲文件](#准备脉冲文件)
- [配置虚拟 7.1 环绕声](#配置虚拟-71-环绕声)
- [WirePlumber蓝牙LDAC与优先级配置](#wireplumber蓝牙ldac与优先级配置)
- [重启服务与验证](#重启服务与验证)

---

## 原理解析

PipeWire 原生支持空间卷积（Filter-Chain）。通过加载 HRIR 脉冲文件，可以在系统里生成一个虚拟 7.1 声道设备。游戏或播放器输出多声道时，PipeWire 会自动将声音处理为适合双耳耳机的虚拟环绕声。

## 准备脉冲文件

HeSuVi 包含多种设备与空间音频算法录制的 14 通道 HRIR 脉冲文件：
- **官方项目**：[HeSuVi on SourceForge](https://sourceforge.net/projects/hesuvi/)（安装包解压后的 `hrir/` 目录下包含 Atmos、DTS、Waves Nx 等全套文件）
- **脉冲文件仓库**：[eadwu/HeSuVi-HRIRs](https://github.com/eadwu/HeSuVi-HRIRs)

以常用的杜比全景声脉冲文件（`atmos.wav`）为例，创建目录并下载：

```bash
mkdir -p ~/.config/pipewire/hrir/
curl -sL "https://raw.githubusercontent.com/eadwu/HeSuVi-HRIRs/master/hrir/atmos.wav" -o ~/.config/pipewire/hrir/atmos.wav
```

## 配置虚拟 7.1 环绕声

复制系统自带的模板到用户配置目录：

```bash
mkdir -p ~/.config/pipewire/pipewire.conf.d/
cp /usr/share/pipewire/filter-chain/sink-virtual-surround-7.1-hesuvi.conf ~/.config/pipewire/pipewire.conf.d/99-virtual-surround.conf
```

替换配置文件中的脉冲文件路径：

```bash
sed -i -E "s|filename\s*=\s*\"[^\"]*\"|filename = \"$HOME/.config/pipewire/hrir/atmos.wav\"|g" ~/.config/pipewire/pipewire.conf.d/99-virtual-surround.conf
```

> **输出路由机制与避坑提示**：
> 模板中无需硬编码输出目标，WirePlumber 会根据设备优先级（`priority.session`）自动选择后端的物理输出设备。
> 默认情况下：蓝牙耳机优先级为 `1010`，板载声卡为 `1009`，因此连上蓝牙时自动走耳机，断开时切回喇叭。
> **但注意**：若系统连接了 USB 麦克风（如自带耳放监听孔的 USB 麦克风）或 USB 外置声卡，Linux ALSA 默认会为其赋予高达 `1100+`（通常为 `1109`）的会话优先级。这会导致虚拟环绕声的输出被 USB 麦克风抢走，蓝牙耳机完全听不到声音。解决方法是在 WirePlumber 中将蓝牙输出节点的优先级调高（如 `1500`），详见下方配置。

## WirePlumber蓝牙LDAC配置

蓝牙耳机在 Linux 下常有几个小痛点：
1. 某些应用调用麦克风时，系统会自动切到通话模式（HSP/HFP），导致输出变成单声道且音质极差。
2. 默认有时没用上最高码率的 LDAC。
3. **输出优先级被 USB 设备抢占**：蓝牙设备的默认会话优先级（`1010`）低于 USB 声卡/麦克风（`1109`）。如果同时插着 USB 麦克风或外置声卡，虚拟环绕声会被 USB 设备抢占，导致耳机没声音。

创建配置文件 `~/.config/wireplumber/wireplumber.conf.d/50-bluez-ldac.conf`：

```bash
mkdir -p ~/.config/wireplumber/wireplumber.conf.d/
vim ~/.config/wireplumber/wireplumber.conf.d/50-bluez-ldac.conf
```

写入：

```spa-json
wireplumber.settings = {
  # 禁止自动切换到通话单声道模式
  bluetooth.autoswitch-to-headset-profile = false
}

monitor.bluez.properties = {
  # 仅允许 A2DP 高清媒体播放
  bluez5.roles = [ a2dp_sink a2dp_source ]
}

monitor.bluez.rules = [
  {
    matches = [
      {
        device.name = "~bluez_card.*"
      }
    ]
    actions = {
      update-props = {
        # 强制锁定 LDAC 最高质量（990kbps）
        bluez5.a2dp.ldac.quality = "hq"
        bluez5.enable-hw-volume = true
      }
    }
  },
  {
    matches = [
      {
        # 提升蓝牙输出节点的会话优先级，防止被 USB 麦克风/外置声卡（默认 1109）抢占
        node.name = "~bluez_output.*"
      }
    ]
    actions = {
      update-props = {
        priority.session = 1500
      }
    }
  }
]
```

## 重启服务与验证

1. 重启 PipeWire 服务：

   ```bash
   systemctl --user restart wireplumber pipewire pipewire-pulse
   ```

2. 检查虚拟 7.1 声卡是否已出现：

   ```bash
   pactl list sinks short
   ```

   列表中能看到 `Virtual-Surround-Sink` 即代表成功。

3. 切换默认输出并测试：

   可以在桌面音量面板中选择 `Virtual Surround Sink`，或直接运行命令切换：

   ```bash
   pactl set-default-sink effect_input.virtual-surround-7.1-hesuvi
   ```

4. 运行 7.1 声道环绕声定位测试：

   使用 `speaker-test` 测试 8 声道输出，系统会按顺序朗读对应声道（Front Left, Center, Front Right 等）：

   ```bash
   speaker-test -D pipewire -c 8 -t wav
   ```

   > **提示**：聆听各个方位的语音是否具有明显的空间方位感。按 `Ctrl + C` 可随时终止测试。

5. 检查蓝牙是否使用 LDAC：

   连上支持 LDAC 的蓝牙耳机后运行：

   ```bash
   pw-dump | grep -iE 'bluez5.codec'
   ```

   输出显示 `"bluez5.codec": "ldac"` 即代表已锁定最高音质（如果耳机本身不支持 LDAC，则会自动使用 SBC-XQ 或 AAC）。
