- [重要概念讲解](#重要概念讲解)

- [手动安装](#手动安装)

- [AI 助手安装](#ai-助手安装)

- [脚本安装](#脚本安装)

- [手动安装省流版](手动安装省流版.md)

>视频教程：[【从「Linux Mint 入门」到「Arch Linux 安装详解」桌面端 Linux 入门的最佳路径】](https://www.bilibili.com/video/BV19DBqB4EY4/?share_source=copy_web&vd_source=1c6a132d86487c8c4a29c7ff5cd8ac50)

新手建议先手动安装，把其他安装方式当作重装系统的便利工具，否则日后出现问题自己不会解决。如果手动安装太难，就先使用开箱即用的 Arch，比如 CachyOS。

## 重要概念讲解

<details>
<summary>[展开/收起]</summary>

- Linux 目录结构

   Linux 的目录是由 `/` 左斜杠开头的树状结构，所以 `/` 被称为根目录（root 目录）。例如 `/home` 就是根目录下的 home 目录，`/home/shorin` 就是根目录下的 home 目录里面的 shorin 目录。

- 挂载

   意思是把硬盘分区对应到某个目录。

- 挂载点（mount point）

   假设把 `/dev/nvme0n1` 这个设备挂载到 `/home` 目录，那就称 `/dev/nvme0n1` 的挂载点为 `/home`。

- 文件系统

   [ArchWiki File systems](https://wiki.archlinux.org/title/File_systems)

   文件系统决定了文件的存放和检索方式，不同的文件系统有不同的功能和特性。本文使用 Btrfs 文件系统，最大的特点是快照（相当于存档和回档）。

- Bootloader 引导程序

   [ArchWiki Arch boot process](https://wiki.archlinux.org/title/Arch_boot_process#Boot_loader)

   引导程序，用来引导系统启动。GRUB 最为常用。

- EFI 系统分区（ESP）

   [ArchWiki EFI system partition](https://wiki.archlinux.org/title/EFI_system_partition)

   一个特殊的分区，用于存放 `.efi` 文件，主板读取并运行该文件后可以加载系统内核以启动系统。因为主板通常只有 FAT 文件系统的驱动，故该分区的文件系统通常使用 FAT，否则主板无法识别。

### ESP 挂载点

常用挂载点为 `/boot`、`/boot/efi` 和 `/efi`。具体挂载到哪里要看情况。

- 因素一：硬盘空间

   `/boot` 是最典型的挂载点，很多 Bootloader 程序只有 ESP 挂载点为 `/boot` 时才能正常工作，但是 `/boot` 存放着系统启动和初始化相关的文件，在多内核的情况下需要 1G 甚至 2G 空间。

- 因素二：文件系统

   ESP 是 FAT 文件系统，无法被 Btrfs 快照记录和恢复，所以使用 Btrfs 文件系统时 ESP 不能挂载到 `/boot`。

   假设创建快照时的内核版本是 6.16，然后更新到了 6.17，然后用快照回档。此时你的系统文件会被恢复到 6.16，但是 `/boot` 里的内核文件和 initramfs 因为存储在 FAT 文件系统导致没能回档，版本仍然是 6.17。两者版本不一致导致系统无法正常启动。为了避免这种情况，使用 Btrfs 时 ESP 的挂载点应该是 `/boot/efi` 或者 `/efi`。因为 `/efi` 是扁平布局更加简洁，所以此时的推荐挂载点为 `/efi`。

</details>

## 安装方案简述

>不同的人安装 Arch 时的分区、Bootloader、文件系统等内容都会略有不同。这部分简单总结我的方案，对安装有一个大概的画面，看不懂也没关系。

Win 加 Linux 双系统；分区时创建独立于 Windows 的启动分区（ESP）并挂载到 `/efi`，剩下的所有空间创建为一个大分区；文件系统使用 Btrfs，创建 `@` 和 `@home` 子卷；Bootloader 使用最常用的 GRUB，并且装进 ESP 以兼容 Btrfs；Swap（交换空间）使用 ZRAM（内存压缩）配合硬盘 Swap；联网工具使用最常用的 NetworkManager。

## 手动安装

参考链接：

> [Arch Linux 简明指南](https://arch.icekylin.online/) | [安装指南 - Arch Linux 中文维基](https://wiki.archlinuxcn.org/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97)

### 可选：调大字体

```bash
setfont ter-v32n
```

或者

```bash
setfont -d
```

### 确认是 UEFI 固件

```bash
cat /sys/firmware/efi/fw_platform_size
```

>`cat` 命令将文件内容打印在终端。

>`/sys/firmware/efi/fw_platform_size` 这是一个文件的绝对路径。

如果输出 `64`，说明主板是 64 位 x64 UEFI 固件；如果输出 `32`，说明是 32 位 UEFI；如果提示 `No such file or directory` 没有文件或目录，说明是 BIOS。本文只涉及 x64 UEFI 情况下安装，如果你不是的话安装引导的步骤会不一样，可以查阅[ArchWiki GRUB](https://wiki.archlinux.org/title/GRUB#GUID_Partition_Table_(GPT)_specific_instructions)。

如果你是虚拟机，并且是 BIOS 固件，推荐在虚拟机设置里调整为 UEFI。

### 连接网络

有线网自动连接，还可以用数据线分享手机的网络。

确认网络连接使用：

```bash
ip a #查看网络连接信息，如果出现了紫色的 ip 地址说明成功连接
ping bilibili.com #确认网络正常
```

Ctrl+C 可以中止正在运行的命令。

- 使用` iwctl` 命令行工具连接 wifi（此工具由 `iwd` 提供）

  1. 启动

     ```bash
     iwctl
     ```
     此时会进入 iwctl，提示符会产生变化。

  2. 连接

     ```text
     device list #列出设备

     station wlan0 scan #扫描网络

     station wlan0 get-networks #列出所有扫描的wifi

     station wlan0 connect 【此处是你的wifi名字（不能是中文）】
     ```

  3. 退出 iwctl

     ```bash
     exit
     ```

### 确认开启了 NTP（网络时间协议）

运行 `timedatectl`，应该在输出看到 NTP 已经开启，否则在安装时可能会出现验证相关的报错：

```bash
NTP service: active
```

手动开启使用：

```shell
timedatectl set-ntp true
```

### Reflector 自动设置镜像源

用 `reflector` 配置最快最新的镜像源，大幅提高软件下载速度。

```bash
reflector -p https -a 12 -c cn --v --sort rate --save /etc/pacman.d/mirrorlist

# -p（protocol） https 指定 https 协议的链接
# -a（age） 12 指定最近 12 小时更新过的源
# -c（country） cn 指定国家为中国（可以增加邻国）
# --v（verbose） 过程可视化
# --sort rate 按照下载速度排序（经过前面几道筛选，镜像源通常已经足够稳定，所以这里直接按照速度排序即可）
# --save /etc/pacman.d/mirrorlist 将结果保存到 /etc/pacman.d/mirrorlist
```

然后同步软件列表数据。

```bash
pacman -Sy
```

### 可选：探索 Linux 文件

<details><summary>[展开/收起]</summary>

我们从 U 盘加载的其实也是一个 Arch Linux 系统，称为 Live 环境。如果你有兴趣，可以安装一个终端文档管理器可视化查看当前 Live 环境的目录（btw，我把 Live 环境称作 icu）。

```bash
pacman -S yazi
```

[yazi](https://yazi-rs.github.io/) 是好用的终端文件管理器，功能方便的同时内存占用也很低。如果 `yazi` 出现依赖问题安装失败可以试试同时安装 `lua` 和 `yazi`，或者使用 [ranger](https://github.com/ranger/ranger)。

用 `yazi` 命令开启鸭子（ranger 使用 `ranger` 命令开启）。

```bash
yazi
```

此时应该会处在一个空的 `/root` 目录，按左方向键切换到上级目录。

左中右三块区域，左边是上级目录，中间是当前目录，右边是下级目录。上下左右键切换（或者使用 Vim 快捷键，jkhl 对应上下左右）。

我重点提几个。

- `/bin` 存放可执行文件。可以找到我们之前运行过的 `pacman`、`timedatectl`、`reflector` 之类的命令。

- `/dev` 存放硬件设备对应的文件。（是的，硬件在 Linux 上也以文件的形式存在）

- `/etc` 系统级配置文件。比如 pacman 包管理器的配置、GRUB 引导程序的配置等等。

- `/home` 普通用户的家目录，存放用户数据。如果新建了一个名叫 shorin 的用户，那么他的所有文件都会存放在 `/home/shorin`。

- `/boot` 存放内核、initramfs（系统初始化相关）等文件。这个目录下的文件和系统的启动息息相关。

- `/mnt` 用来手动临时挂载外部存储设备，比如我们接下来安装系统要使用的系统分区。

- `/tmp` 这里面的数据存储在内存中，重启后会消失。

其他的目录有兴趣的可以自己了解一下。

q 键退出 yazi。`Ctrl+L` 清屏。

</details>

### 硬盘分区

```shell
lsblk -pf  #查看当前分区情况
fdisk -l /dev/想要查询详细情况的硬盘  #小写字母l，查看详细分区信息
```

```shell
cfdisk /dev/nvme0n1 #选择自己要使用的硬盘进行分区
```

1. 如果是新硬盘的话会弹出选项，选 GPT。

2. EFI 分区

   上下方向键选中空闲空间，左右方向键选择 NEW 创建 512MB 的分区，类型（type）选择 EFI System。

   >如果你的类型里没有 EFI System 说明你的硬盘不是 GPT 分区表，可以使用 `cfdisk -z 设备名` 以空分区表打开硬盘，然后选择 GPT。⚠️警告⚠️ 这个操作会清空硬盘上的分区。

   >也可以直接使用 Windows 的 EFI 分区，如果使用 Win 的 EFI 分区的话跳过下面格式化 EFI 分区的步骤（推荐给 Linux 单独新建 EFI 分区，更可控）。

3. 根分区

   其余空间全部分到一个分区里，类型 `linux filesystem` 不需要更改。

4. 保存

   选择 `write`，输入 `yes` 保存。`quit` 退出。

>后续如果需要扩容 Btrfs 的话可以看：[附录：Btrfs 扩容和缩小](./附录.md#btrfs-扩容和缩小)

#### 格式化分区

通过格式化创建需要的文件系统。

1. 再次查看分区情况

   ```shell
   lsblk -pf #查看分区情况
   fdisk -l /dev/想要查询详细情况的硬盘  #小写字母l，查看详细分区信息
   ```

2. 格式化 EFI 分区

   ```shell
   mkfs.fat -F 32 /dev/nvme0n1p1（EFI 分区名）
   ```

3. 格式化 Btrfs 根分区

   ```shell
   mkfs.btrfs /dev/nvme0n1p2（根分区名）

   #加上 -f 参数可以强制格式化
   ```

#### 创建 Btrfs 子卷

子卷是 Btrfs 的一个特性，跟快照（存档和回档）有关。通常至少要创建 root 子卷（存放系统文件）和 home 子卷（存放用户文件），根据命名规范取名为 `@` 和 `@home`。由于这两者是平级关系，所以创建 `@` 快照时不会包含 `@home` 中的内容。这样就可以只恢复系统文件，不影响用户数据。

- 挂载

  ```shell
  mount -t btrfs /dev/nvme0n1p2（根分区名） /mnt
   ```

   `mount` 挂载命令；

   `-t` 指定文件系统；

   这条命令把 `/dev/nvme0n1p2` 分区挂载到了 `/mnt` 目录，而 `/dev/nvme0n1p2` 是我们将要安装的系统的 `根分区`，这意味着 `/mnt` 成为了我们将要安装的系统的 `根`。
- 创建子卷

  ```shell
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@swap #如果你的内存大于等于 16G 且不需要休眠到硬盘功能，不做大型项目的话跳过这个
  ```

- 可选：确认

  ```shell
  btrfs subvolume list /mnt
  ```

- 取消挂载

  ```shell
  umount /mnt
  ```

### 正式挂载

1. 挂载 root 子卷

   ```bash
   mount -t btrfs -o subvol=/@,compress=zstd /dev/nvme0n1p2 /mnt

   # -o 指定额外的挂载参数
   # compress=zstd 指定透明压缩，zstd 是压缩算法
   ```

   和刚刚的挂载是一样的操作，不过这次是把 `/dev/nvme0n1p2` 上的 `@` 子卷挂载到了 `/mnt`，而不是把 `/dev/nvme0n1p2` 挂载到 `/mnt`。

   `compress` 是 Btrfs 的另一个特性，透明压缩。在数据写入磁盘前先进行压缩，提升读写性能，节省空间，延长寿命。可以像这样 `zstd:3` 指定压缩等级，最高 15。默认为 3，在意 CPU 性能可以设置成 1。

2. 挂载 home 子卷

   ```bash
   mount --mkdir -t btrfs -o subvol=/@home,compress=zstd /dev/nvme0n1p2 /mnt/home
   ```

   由于 `/mnt` 下没有 `/mnt/home` 这个目录，所以要加上 `--mkdir` 命令创建 `/mnt/home` 用来挂载。把 `@home` 子卷挂载到了 `/mnt/home`。

3. 可选：挂载 swap 子卷

   ```bash
   mount --mkdir -t btrfs -o subvol=/@swap,compress=zstd /dev/nvme0n1p2 /mnt/swap
   ```

4. 挂载 EFI 分区（ESP）

   ```bash
   mount --mkdir /dev/nvme0n1p1 /mnt/efi
   ```

   记得把 `/dev/nvme0n1p1` 替换为自己对应的 EFI 分区设备名。

5. 可选：复查挂载情况

   ```bash
   df -h
   ```

### 安装系统

```bash
pacstrap -K /mnt base linux linux-firmware btrfs-progs networkmanager vim sudo amd-ucode

# -K 初始化密钥
# base 基本包
# linux是内核，可以更换
# linux-firmware是固件
# btrfs-progs是 Btrfs 文件系统的管理工具
# networkmanager 是联网用的，是各个桌面环境标配的联网工具
# vim 是文本编辑器，也可以换成别的，比如 nano、neovim
# sudo 和权限管理有关
# amd-ucode 是微码，用来修复和优化 CPU，Intel 用户安装 intel-ucode
```

>`pacstrap` 命令是把软件安装到指定的根目录下。

>如果你使用的是 marvell 的无线网卡，这里要额外安装 `linux-firmware-marvell`，否则进系统找不到网卡。

#### Vim 文本编辑器基础操作

Vim 是以键盘操作为核心理念的文本编辑器，很陌生，但是绝对值得一学。

`i` 键进入编辑模式；

`esc` 回到普通模式；

`u` 撤销；

`/` 左斜杠进入搜索模式，回车跳转到搜索到的第一个，`n` 键跳转到搜索到的下一个，`Shift+n` 跳转到搜索到的上一个；

`:w` 冒号小写 w 写入；

`:q` 冒号小写 q 退出；

`:wq` 冒号小写 wq 保存并退出；

`!` 命令后加上感叹号代表强制执行。

知道这些就可以开始使用了。不习惯的话可以安装 `nano`。`nano` 的基础操作只需要记住 `Ctrl+F` 搜索、`Ctrl+S` 保存和 `Ctrl+X` 退出即可。你也可以选择安装 `neovim`，Vim 的加强版，更现代更好用。如果安装 `neovim` 的话后面所有 `vim` 命令都改成 `nvim`。

### 可选：硬盘 Swap 交换空间

<details><summary>[展开/收起] 如果内存大于等于 16G 且不需要休眠到硬盘功能，不做大型项目的话跳过硬盘 Swap，后面会配置更适合现代设备的内存 Swap（ZRAM）</summary>

参考链接：

> [电源管理/挂起与睡眠 - Arch Linux 中文维基](https://wiki.archlinuxcn.org/wiki/%E7%94%B5%E6%BA%90%E7%AE%A1%E7%90%86/%E6%8C%82%E8%B5%B7%E4%B8%8E%E4%BC%91%E7%9C%A0#%E7%A6%81%E7%94%A8_zswap_%E5%86%99%E5%9B%9E%E4%BB%A5%E4%BB%85%E5%B0%86%E4%BA%A4%E6%8D%A2%E7%A9%BA%E9%97%B4%E7%94%A8%E4%BA%8E%E4%BC%91%E7%9C%A0) | [Swap - ArchWiki](https://wiki.archlinux.org/title/Swap) | [Swap - Manjaro](https://wiki.manjaro.org/index.php?title=Swap)

Swap 用来存放内存中的冷数据，提高电脑的运行速度。还能把硬盘当作虚拟内存使用。设置了硬盘 Swap 还可以使用休眠功能。休眠指的是把系统当前状态写入硬盘，然后电脑完全断电，下一次开机恢复到休眠前的状态。硬盘 Swap 有 Swap 分区或者 Swap 文件两种方式，前者配置更简单，后者配置稍复杂，但是更加灵活。这里采用交换文件的方式。

swap 大小参考：

| 内存(GB) | 不需要休眠(GB) | 需要休眠（GB） | 不建议超过（GB） |
| -------- | -------------- | -------------- | ---------------- |
| 1        | 1              | 2              | 2                |
| 2        | 2              | 3              | 4                |
| 3        | 3              | 5              | 6                |
| 4        | 4              | 6              | 8                |
| 5        | 2              | 7              | 10               |
| 6        | 2              | 8              | 12               |
| 8        | 3              | 11             | 16               |
| 12       | 3              | 15             | 24               |
| 16       | 4              | 20             | 32               |
| 24       | 5              | 29             | 48               |
| 32       | 6              | 38             | 64               |
| 64       | 8              | 72             | 128              |
| 128      | 11             | 139            | 256              |
| 256      | 16             | 272            | 512              |

1. 创建 Swap 文件

   此处的 `64g` 应该是你实际需求的 swap 大小

   ```bash
   btrfs filesystem mkswapfile --size 64g --uuid clear /mnt/swap/swapfile
   ```

2. 启用 Swap

   ```bash
   swapon /mnt/swap/swapfile
   ```

</details>

### 生成 fstab 文件

系统会根据 fstab 中的内容自动进行挂载。

```shell
genfstab -U /mnt > /mnt/etc/fstab


# genfstab（生成文件系统表）
# -U 用 UUID 指定分区
# > 大于号代表输出结果覆盖写入到右边的文件里
# 如果是 >> 两个大于号则代表追加写入
```

### 更换根目录（change root）

进入刚刚安装的系统。

```shell
arch-chroot /mnt
```

此时根目录从 Live 环境变成了 `/mnt`，可以注意到提示符的变化。

### 设置时区和时间

设置时区：

```shell
timedatectl set-timezone Asia/Shanghai
```

同步硬件时间：

```bash
hwclock --systohc
```

除了 `timedatectl` 命令，还可以手动创建链接。

```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# ln 是 link 的缩写
# -s 代表跨文件系统的软链接
# -f 代表强制执行
```

### 本地化设置

1. 编辑配置文件

   ```bash
   vim /etc/locale.gen
   ```

   左斜杠键进行搜索；`x` 键剪贴掉 `en_US.UTF-8 UTF-8` 和 `zh_CN.UTF-8 UTF-8` 的前面代表注释的井号；`:wq` 保存并退出。

2. 生成本地化配置

   ```bash
   locale-gen
   ```

3. 设置系统语言

   ```bash
   vim /etc/locale.conf
   ```

   `i` 键进入编辑模式；写入 `LANG=en_US.UTF-8` 设置系统语言为英文；

   ```bash
   LANG=en_US.UTF-8
   ```

   `esc` 退出编辑模式；`:wq` 保存并退出。

   >`/etc/locale.conf` 这个文件是系统级的语言设置，写入 `zh_CN.UTF-8` 可以设置系统语言为中文，但是会导致 TTY 的中文字符全部变成豆腐块，所以不建议这么做。我们后面安装完桌面环境后在用户空间修改系统语言。

### 设置主机名

```bash
vim /etc/hostname
```

`i` 键进入编辑模式；取一个自己喜欢的主机名，比如 `archlinux`；`esc` 退出编辑模式；`:wq` 保存并退出。

>此时你应该已经相当熟悉 Vim 编辑器最基本的操作了，所以后面我会省略 Vim 的操作讲解。

### 设置 root 密码

```bash
passwd
```

输入过程不显示，直接输入回车即可。

### 安装引导程序

这是 UEFI 引导的安装方式，如果你是 BIOS 设备请看 ArchWiki 的 GRUB 页面。

就像前面[重要概念讲解](#重要概念讲解)部分说的那样，根据 ESP 挂载点和个人需求的不同，Bootloader 的选择也会不同。这里安装最常用的 `grub`，采用的是"ESP 挂载点为 `/efi` 且 `grub` 装进 ESP"的方案。

1. 安装必要的软件包

   ```shell
   pacman -S grub efibootmgr os-prober exfat-utils
   ```

   `efibootmgr` 管理 UEFI 启动项；

   `os-prober` 和 `exfat-utils` 用来搜索 Win11（不配置双系统的话可以不装）。

2. 安装 GRUB

   ```bash
   grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/efi --bootloader-id=ARCH
   ```

   `grub-install` 安装 GRUB；

   `--target` 指定架构；

   `--efi-directory` 指定 ESP 位置；

   `--boot-directory` 指定 GRUB 的安装目录；

   `--bootloader-id` 任意取一个启动项名字；

   PS：如果是移动设备或者主板只支持默认的 EFI 路径要加上 `--removable` 选项。

3. 编辑 GRUB 的源文件

   ```bash
   vim /etc/default/grub
   ```

   这是生成 GRUB 的配置文件时需要用到的东西。

   - 启动项记忆功能

     `GRUB_DEFAULT=0` 改成 `=saved`，再取消 `GRUB_SAVEDEFAULT=true` 的注释。

   - 显示开机日志

     `GRUB_CMDLINE_LINUX_DEFAULT` 里面去掉 `quiet` 以显示开机日志。再设置 `loglevel=5` 把日志等级为 5。`loglevel` 共 7 级，5 级是一个信息量的平衡点。

   - 禁用 watchdog

     `GRUB_CMDLINE_LINUX_DEFAULT` 里添加 `nowatchdog` 以及 `modprobe.blacklist=sp5100_tco`。Intel CPU 用户把 `sp5100_tco` 换成 `iTCO_wdt`。

     watchdog 的目的简单来说是在系统死机的时候自动重启系统。对个人用户来说没有意义，禁用以节省系统资源、提高开机和关机速度。

    - 允许使用 os-prober 搜索其他系统

      取消最后一行 `GRUB_DISABLE_OS_PROBER=false` 的注释。

4. 在 GRUB 的默认安装位置创建链接

   ```bash
   ln -sf /efi/grub /boot/grub
   ```

   大多数程序会默认检测 `/boot/grub` 作为 GRUB 的安装位置，但是我们的 GRUB 在 `/efi/grub`，所以创建一个链接方便使用。

5. 生成 GRUB 的配置文件

   ```bash
   grub-mkconfig -o /boot/grub/grub.cfg
   ```

>以上的 GRUB 配置方法已经足够使用，但存储在 FAT 文件系统上的 `grub.cfg` 无法被 Btrfs 快照回档，极端情况下仍会出现问题，例如在快照启动项里生成了 `grub.cfg` 导致永远启动进快照启动项。如果你想要绝对稳定的回档，看进阶内容：[可选：GRUB 在 Btrfs 文件系统下的最佳配置方法](附录.md#grub-在-btrfs-文件系统的最佳配置方法)

### ZRAM

> [zswap - ArchWiki](https://wiki.archlinux.org/title/Zswap) | [zram - ArchWiki](https://wiki.archlinux.org/title/Zram)

ZRAM 将内存的部分空间用作交换空间，如果你没有配置 Swap，请一定配置 ZRAM。

1. 安装 zram-generator

   ```bash
   pacman -S zram-generator
   ```

2. 编辑配置文件

   ```bash
   vim /etc/systemd/zram-generator.conf
   ```

   ```ini
   [zram0]
   zram-size = ram
   compression-algorithm = zstd
   ```

   `zram-size` 设置最多存储多少数据，注意这里设置的是压缩之前的大小。

   `compression-algorithm` 设置使用 zstd 算法。

3. 禁用 zswap

   zswap 是 Swap 的缓存。需要交换的数据在存入交换空间之前会先被 zswap 压缩后暂时放进内存里。和 ZRAM 功能重复且引入了复杂性，故禁用。

   ```bash
   vim /etc/default/grub
   ```

   在 `GRUB_CMDLINE_LINUX_DEFAULT=""` 里写入 `zswap.enabled=0`。

   ```ini
   GRUB_CMDLINE_LINUX_DEFAULT="... zswap.enabled=0 ... "
   ```

4. 重新生成 GRUB 的配置文件

   ```bash
   grub-mkconfig -o /boot/grub/grub.cfg
   ```

### 启用网络服务

开启新系统的 NetworkManager 服务，注意大小写。

```bash
systemctl enable NetworkManager
```

`systemctl` 调用 systemd 进行操作。

`enable` 代表从下一次开机开始自动启动。

- 可选：替换网络后端为 `iwd`

   <details><summary>NetworkManager 的无线网默认后端是 wpa_supplicant，可以更换为更现代的 iwd。</summary>
   
   >注意：部分设备更换 `iwd` 后端可能无法正常联网。

   1. 安装 `iwd`

      ```bash
      pacman -S iwd
      ```

      >`impala` 是 `iwd` 的 TUI。

   2. 编辑配置文件

      ```bash
      # 创建配置文件目录，-p 代表如果已经存在就跳过
      mkdir -p /etc/NetworkManager/conf.d

      # 新建文件并用 vim 进行编辑
      vim /etc/NetworkManager/conf.d/iwd.conf
      ```

      写入：

      ```ini
      [device]
      wifi.backend=iwd
      ```
   </details>

### 退出 chroot

```bash
exit
```

此时就回到了 Live 环境，可以注意到提示符的变化。

### 重启电脑

```bash
reboot
```

此时会自动取消所有的挂载。

### 拔掉系统 U 盘

如果 U 盘没拔掉的话记得拔掉。

### 选择 BIOS 启动项

通常默认就是刚刚安装的 Arch，如果不是的话选择一下启动项。有的电脑的启动项可能埋在子菜单里，例如 BBS 菜单什么的，仔细找一下。

如果没有出现 Arch Linux 的启动项，看这个页面：[ArchWiki GRUB](https://wiki.archlinux.org/title/GRUB)。

### 登录 root 账户

用户名为 root，密码刚刚设置过了。

### 连接网络

1. 验证是否有网

   ```bash
   ip a
   ping bilibili.com
   ```

2. 连接 wifi

   ```bash
   nmtui
   ```

   `nmtui` 是 NetworkManager 提供的 TUI（终端用户交互程序）。

   - 选择 activate a connection
   - 选择自己的 wifi 进行连接
   - esc 退出
   - Ctrl+L 或者 `clear` 清屏

### 放松一下吧

恭喜你成功手动安装了 Arch Linux，现在小小地奖励一下自己吧。

```bash
pacman -S fastfetch lolcat cmatrix
```

不做讲解，自己运行命令试试吧。

```bash
fastfetch
```

```bash
fastfetch | lolcat
```

```bash
cmatrix
```

```bash
cmatrix | lolcat

cmatrix -r
```

>`|` 竖线叫作 pipeline 管道符，作用是把左边程序的输出结果输入到右边的程序里。

下一节：[安装桌面环境前的准备](安装桌面环境前的准备.md)

---

## AI 助手安装

使用 OpenCode 提供的免费开源大模型快速进行系统安装。

1. 安装 AI 助手

   ```bash
   pacman -Sy opencode
   ```

   `opencode` 命令打开 AI 助手，输入 `/models` 把模型切换成国产开源模型，如 `deepseek`。

2. 给 AI 指令进行系统安装

   >因为 Live 环境没有中文输入法，只能用英文和 AI 交流，输入一些简单的短语就行，实在不懂的话让豆包帮忙翻译。

   以下是一个最小化的提示词示例，注意把 root 密码改成你自己的：

   ```text
   We are in the archiso live. First, increase the cowspace size. Then auto install archlinux. Root passwd: shorin.

   # 我们现在在 archiso 的 live 环境里。首先扩大 cowspace 的大小，然后自动安装 archlinux。Root 密码设置为 shorin。
   ```
   > 无论你怎么写提示词，都必须先告诉 AI 现在在 Arch Linux 的 Live 环境中，然后第一件事情必须是增加 cowspace 大小，否则运行空间会不够用。

   你也可以带上更具体的需求，不过更推荐的用法是让 AI 按照这篇文档进行安装。OpenCode 自带了网络搜索和网页爬取工具：

   ```text
   We are in the archiso live. First, increase the cowspace size. Then install archlinux following the guide from github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide.
   ```
   此时 AI 会根据文档的步骤向你确认一系列事情。

3. 重启

   安装完成后发送 `reboot` 给 AI，AI 会帮你重启电脑。

## 脚本安装

>因 archinstall 脚本更新频繁，移除详细内容。

运行 `archinstall` 打开安装脚本。

下一节：[安装桌面环境前的准备](安装桌面环境前的准备.md)
