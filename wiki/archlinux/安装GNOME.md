目录

- [安装基础组件](安装GNOME.md)
- [网络工具 (nm-connection-editor)](安装GNOME.md#安装高级网络配置工具-nm-connection-editor)
- [分数缩放与 VRR](安装GNOME.md#可变刷新率和分数缩放)
- [修改默认终端](安装GNOME.md#修改-gnome-默认终端)
- [生成 Home 目录](安装GNOME.md#生成-home-下目录如果没有的话)

---

[ArchWiki GNOME](https://wiki.archlinux.org/title/GNOME)

这个部分是安装 GNOME，以及一些最基本的配置。

1. 安装

   ```
   sudo pacman -S gnome-shell gdm ghostty gnome-control-center gnome-software flatpak file-roller firefox gnome-backgrounds
   ```

   >`gnome-shell` 最小化安装 GNOME；

   >`gdm` 是显示管理器（GNOME Display Manager）；

   >`ghostty` 是一个可高度自定义，主打无缝融入任何环境的终端模拟器（terminal emulator）。当然，如果你需要可以自行更换；

   >`gnome-control-center` 是设置中心；

   >`gnome-software` 是软件商城；

   >`flatpak` 是 flatpak 软件，这是一种全发行版通用的软件打包形式，软件沙盒运行；

   >`file-roller` 是和 GNOME 的文档管理器集成的压缩解压缩工具；

   >`firefox` 是 Linux 上最好用的浏览器。

   >`gnome-backgrounds` 是 GNOME 的壁纸包。


2. 补全文档管理器的功能

   ```
   sudo pacman -S ffmpegthumbnailer gnome-keyring gvfs-smb gst-plugins-base gst-plugins-good gst-libav icoextract python-pillow
   ```
   <details close><summary>[展开]软件包的介绍</summary>

   >`ffmpegthumbnailer` 视频预览。

   >`gnome-keyring` 提供密码保存功能。

   >`gvfs-smb` 检查可挂载的外部设备，访问 smb 分享等功能。

   >`gst-plugins-base gst-plugins-good gst-libav` 这些让你可以预览视频信息。

   >`icoextract` `python-pillow` exe 缩略图。

   >可选：

   >`nautilus-image-converter` 右键方便调整图片大小或者旋转。

   >`libheif webp-pixbuf-loader libopenraw gst-plugins-bad gst-plugins-ugly` 提供更多视频、图片格式支持。

   </details>

3. 临时开启 gdm

   ```
   systemctl start gdm
   ```

4. 登录普通用户账号

5. 设置 gdm 开机自启

   正常开启桌面后打开 ghostty 设置 gdm。

   ```
   sudo systemctl enable gdm
   ```

### 隐藏不需要的图标

软件商城搜索 `pinapp` 安装 `pins`，激活想要隐藏的软件的 `Invisible`。

### 文档管理器中右键从此处打开终端

```
yay -S nautilus-open-any-terminal
```

```
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal custom
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal custom-local-command 'ghostty --working-directory=%s'
```

### 修改 GNOME 默认终端

- 方法一：dconf-editor

  ```
  sudo pacman -S dconf-editor
  ```

  `org.gnome.desktop.applications.terminal` 里的 `exec` 取消`使用默认值`，自定义值填 `ghostty`，`exec-arg` 同理，自定义值改成 `-e`。这么写是因为别的程序调用 ghostty 运行命令时需要通过 `-e` 参数把命令传给 `ghostty`。

- 方法二：gsettings 命令

  ```
  gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'
  gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
  ```

- 验证

   ```
   gsettings get org.gnome.desktop.default-applications.terminal exec
   gsettings get org.gnome.desktop.default-applications.terminal exec-arg
   ```

   输出应该为：

   ```
   ‘ghostty’
   ‘-e’
   ```

### 安装高级网络配置工具 nm-connection-editor

```
sudo pacman -S --needed nm-connection-editor dnsmasq
```

### 可变刷新率和分数缩放

商店安装 Refine 修改。

```
flatpak install flathub page.tesk.Refine
```

### 生成 home 下目录（如果没有的话）

```
sudo pacman -S --needed xdg-user-dirs

LANG=en_US.UTF-8 xdg-user-dirs-update --force
```

### 修改系统语言为中文

打开 Settings，System --> Region & Language。

接下来你自己根据需求决定安装什么软件，进行什么配置。当然，你也可以选择参考我的。

下一节：[中文输入法](中文输入法.md)
