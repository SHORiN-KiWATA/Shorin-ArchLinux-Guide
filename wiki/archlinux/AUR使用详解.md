# AUR 使用详解

> AUR（Arch User Repository）是社区维护的软件仓库，包含官方仓库没有的软件。善用 AUR 是 Arch 用户的必修课。

## 一、选择 AUR 助手：推荐 paru

| | paru | yay |
|---|---|---|
| 特点 | **安装/升级时默认显示 PKGBUILD 变更供审查**，更适合当前投毒频发的环境 | 最流行、教程最多 |
| 安装 | `sudo pacman -S paru` | `sudo pacman -S yay` |

本教程以 **paru** 为例（它默认每次安装、升级都会展示 PKGBUILD 与 `.install` 的 diff，让"安装前审查"成为习惯）。yay 命令完全兼容，只需把 `paru` 换成 `yay`，但 yay 需要额外配置才显示审查界面。

```bash
# 首次使用配置（建议开启审查）
paru --editmenu --combinedupgrade
```

## 二、基本用法

```bash
# 搜索（同时搜官方仓库和 AUR）
paru -Ss 软件名

# 安装（默认会先显示 PKGBUILD 审查，回车确认）
paru -S 软件名

# 升级（AUR 包也要一起升，有变更同样会先展示）
paru -Syu

# 卸载
paru -Rns 软件名

# 查看已装 AUR 包
paru -Qm
```

## 三、makepkg 配置优化

编辑 `/etc/makepkg.conf`：

```ini
# 多核并行编译（CPU 核数 - 1，8 核机器写 7）
MAKEFLAGS="-j7"

# 使用全部核心压缩包
COMPRESSXZ=(xz -c -T 0 -z -)

# 使用 pacman 缓存（默认就是）
```

AUR 包编译慢的大户是 rust / node 项目，多核并行立竿见影。

## 四、AUR 报错自查

### 4.1 编译失败（最常见的 AUR 报错）

```
==> ERROR: A failure occurred in build()
```

先试 4 个步骤：

```bash
# 1. 看是不是依赖没装
# 通常错误日志会指明缺哪个库

# 2. 重新获取最新源码
paru -S 软件名 --editmenu   # 更新 pkgver 时先更新源

# 3. 查 issue 和评论
# paru 安装时按 2 查看评论，往往有前人的解决方案

# 4. 换版本重试
paru -S 软件名@版本号
```

### 4.2 校验和不匹配

```
error: invalid or corrupted package (PGP signature)
```

- 先 `sudo pacman -S archlinux-keyring` 更新密钥
- 还报错则从 AUR 页面复制正确的 PGP 指纹，在 `PKGBUILD` 里核对

### 4.3 orphaned（无人维护）

```
==> WARNING: 该包已被孤儿化（无人维护）
```

谨慎安装孤儿包：可能随时损坏。可以看 AUR 页面评论区是否有活跃 fork。

### 4.4 依赖冲突

```
==> WARNING: X 和 Y 冲突
```

检查系统里是否已有替代软件（`pacman -Qs`），或看包描述里的冲突说明。

## 五、AUR 安全须知

### 5.1 2026 年 Atomic Arch 投毒事件（必读）

2026 年 6 月，AUR 爆发了大规模投毒事件（代号 **Atomic Arch**）：

- 攻击者批量"收养"被放弃的孤儿包（包名、历史、信任度都保留），在 PKGBUILD 里插入钩子，安装时静默执行 `npm install atomic-lockfile` / `bun install js-digest`
- 恶意 npm 包通过 `preinstall` 钩子运行内置的 Linux 恶意程序（`deps`），窃取**浏览器 Cookie 与会话、SSH 密钥、GitHub/npm token、Slack/Discord/Teams/Telegram 会话、Vault token、Docker 凭据、shell 历史**
- 以 root 运行时还会加载 **eBPF rootkit**，隐藏自身进程和文件，常规杀毒软件根本看不到
- 第一波约 408 个包，第二波扩大到 **1500+ 个包**；官方仓库未受影响

**结论：AUR 包安装前必须审查，尤其是刚被"收养"的孤儿包。**

### 5.2 安装前审查 PKGBUILD（paru 默认已帮你做）

paru 安装和升级时**默认展示 PKGBUILD 与 `.install` 的变更（diff）**，确认前逐个看一遍即可。想看完整内容：

```bash
# 只查看不安装
paru -G 软件名 && cd 软件名 && cat PKGBUILD
```

重点检查四件事：

1. **`source=`（源码来源）**：是否指向官方 GitHub/GitLab 发布页，而不是来路不明的网址或 IP
2. **`install=` 与 `package()` 函数**：安装脚本里有没有执行额外命令
3. **`build()` 里的钩子**：警惕 `npm install`、`pip install`、`curl ... | sh`、`wget`、`eval` 等"下载并执行"的模式（Atomic Arch 就是靠 `npm install` 投毒的）
4. **`.install` 文件**：`.post_install` 里有没有可疑动作

正常 AUR 包通常只有几行 `cd` / `make` / `install`，看到上述模式要格外警惕。

### 5.3 升级时也要审查

投毒不一定发生在安装时，**升级时也可能被注入**（孤儿包被收养后第一时间改的往往是新版本）。paru 在 `paru -Syu` 时会自动展示 AUR 包的 PKGBUILD 变更，**每次都认真看**，新增的 `npm install` / `curl` 行出现即停手。

### 5.4 自查是否中招

```bash
# 社区检测工具（对照已投毒包列表扫描，需 Python 3.14+）
git clone https://github.com/lenucksi/aur-malware-check && cd aur-malware-check
python -m aur_check

# 全量扫描（含 systemd、eBPF、npm/bun 缓存）
python -m aur_check --full

# 手动检查投毒特征
sudo grep -r "atomic-lockfile\|js-digest" /var/cache /etc/systemd/system ~/.config/systemd/user 2>/dev/null
ls -la /sys/fs/bpf/   # 出现 hidden_pids / hidden_names / hidden_inodes 即为 rootkit 活动痕迹
```

如果确认中招：
- **轮换所有凭据**：SSH 密钥、GitHub/npm token、云平台 API key、浏览器全部会话
- 恶意程序以 **root 执行过则直接重装系统**：rootkit 可能藏在内核层，清不干净

### 5.5 其他安全守则

1. **优先选非 -git 的稳定版**：有多个同名列时（如 `foo` 和 `foo-git`），优先非 -git 版本
2. **高分不等于安全**：多选下载量高、评论活跃、更新频繁的包；投票数/评论里有人报告异常的跳过
3. **警惕刚解除孤儿状态的包**：AUR 页面会显示"Orphaned"标记，被新维护者接手的第一个月最危险
4. **不要 `paru -Syu` 到一半中断**：AUR 包编译中断不会弄坏系统，但官方包部分升级会（见[故障排查总纲](故障排查总纲.md)）

## 六、常用 AUR 包推荐

```bash
# 微信 / QQ（bwrap 版解决沙箱问题，体验稳定）
paru -S wechat-universal-bwrap
paru -S linuxqq-nt-bwrap

# 网易云音乐
paru -S netease-cloud-music-gtk

# 视频下载
paru -S yt-dlp

# 屏幕录制
paru -S obs-studio
```

> 微信/QQ 还有 appimage 版可选（[软件安装相关](软件安装相关.md)中介绍），bwrap 版解决沙箱问题更推荐；如果某天包失效，去 AUR 评论区找替代方案。输入法（fcitx5-rime）安装与配置详见[中文输入法](中文输入法.md)，不在 AUR 重复列出。
