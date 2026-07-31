
[KDE - ArchWiki](https://wiki.archlinux.org/title/KDE)

1. 安装

   ```bash
   sudo pacman -S plasma-meta konsole dolphin flatpak-kcm kate firefox qt6-multimedia-ffmpeg
   ```

   >`plasma-meta` 但是 KDE 自带的东西都很实用，装 meta 包就可以了。

   >`konsole` 是 KDE 标配终端仿真器。

   >`dolphin` 是 KDE 标配文档管理器。

   >`flatpak-kcm` 通过系统设置管理 Flatpak 应用的权限。

   >`kate` 是标配文本编辑器。

   >`firefox` 是 Linux 上最好用的浏览器。

   >`qt6-multimedia-ffmpeg` 多媒体相关依赖。

2. 开启显示管理器

   ```bash
   sudo systemctl start plasmalogin
   ```

   自 6.5 版本开始，plasma 同时提供 `sddm` 和 `plasmalogin`，推荐使用 `plasmalogin`。

3. 登录普通用户

4. 设置开机自启

   成功开启桌面后打开 konsole 设置显示管理器开机自启。

   ```bash
   sudo systemctl enable plasmalogin
   ```

### 设置系统语言

- 系统设置 > Region & Language > Language 边上的 Modify > 点击 Add More 添加简体中文 > 移动到 English 上方。

- 如果是 archinstall 安装，需要进行如下操作：

   1. ```bash
      sudo vim /etc/locale.gen
      ```

   2. 左斜杠键搜索，取消 `zh_CN.UTF-8` 的注释。

   3. ```bash
      sudo locale-gen
      ```

   4. 登出。

### 生成 home 下目录（如果没有的话）

```bash
LANG=en_US.UTF-8 xdg-user-dirs-update --force
```

这段命令将强制生成英文的 home 下常用目录，方便终端中使用。如果你已经存在中文的 home 下常用目录请运行这段命令后删除中文的。

下一节：[中文输入法](中文输入法.md)
