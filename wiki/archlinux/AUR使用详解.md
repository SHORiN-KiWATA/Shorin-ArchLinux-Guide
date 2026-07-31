# AUR 使用详解

> AUR（Arch User Repository）是社区维护的软件仓库，包含官方仓库没有的软件。善用 AUR 是 Arch 用户的必修课。

## 一、选择 AUR 助手：yay 还是 paru

| | yay | paru |
|---|---|---|
| 特点 | 最流行、教程最多 | 性能更好、更贴近官方 |
| 安装 | `sudo pacman -S yay` | `sudo pacman -S paru` |

两者用法几乎一样，本教程以 yay 为例，paru 命令完全兼容。

```bash
# 首次使用配置
yay --editmenu --combinedupgrade
```

## 二、基本用法

```bash
# 搜索（同时搜官方仓库和 AUR）
yay -Ss 软件名

# 安装
yay -S 软件名

# 升级（AUR 包也要一起升）
yay -Syu

# 卸载
yay -Rns 软件名

# 查看已装 AUR 包
yay -Qm
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
yay -S 软件名 --editmenu   # 更新 pkgver 时先更新源

# 3. 查 issue 和评论
# yay 安装时按 2 查看评论，往往有前人的解决方案

# 4. 换版本重试
yay -S 软件名@版本号
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

1. **安装前看 PKGBUILD**：`yay -S --editmenu 软件名`，重点检查 `source=`（源码来源）和 `install=`（安装脚本）里没有可疑内容
2. **优先选包名后带 -git 的前一个稳定版**：有多个同名列时（如 `foo` 和 `foo-git`），优先非 -git 版本
3. **高分不等于安全**：多选下载量高、评论活跃、更新频繁的包
4. **不要 `yay -Syu` 到一半中断**：AUR 包编译中断不会弄坏系统，但官方包部分升级会（见"故障排查总纲"）

## 六、常用 AUR 包推荐

```bash
# 输入法（如果不想用 ibus-rime）
yay -S fcitx5-rime

# 微信 / QQ（UOS 版，体验稳定）
yay -S wechat-universal-bwrap
yay -S linuxqq-nt-bwrap

# 网易云音乐
yay -S netease-cloud-music-gtk

# 科学上网相关工具
yay -S clash-verge-rev

# 视频下载
yay -S yt-dlp

# 屏幕录制
yay -S obs-studio
```

> 微信/QQ 的 bwrap 版本解决了沙箱问题，如果某天官方包失效，去 AUR 评论区找替代方案。
