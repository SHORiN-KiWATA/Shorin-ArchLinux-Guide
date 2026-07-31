# Linux Mint 入门指南

[点击跳转视频教程](https://www.bilibili.com/video/BV19DBqB4EY4/?vd_source=65a8f230813d56660e48ae1afdfa4182#reply115786966372305)

[更详细的日常使用参考视频](https://www.bilibili.com/video/BV1YvenzUEFf/?spm_id_from=333.1387.upload.video_card.click)

## 安装 Linux Mint

官方的文字教程：[Install Linux Mint](https://linuxmint-installation-guide.readthedocs.io/en/latest/install.html)

下面是安装之后需要进行的配置。

## 镜像源和系统更新

首先在欢迎程序点击 `第一步` --> `更新管理器` --> `确定`。

会提示切换到本地镜像，点击 `主要` 和 `基础` 边上的链接，稍微等待一会，测速完成后选择最快的镜像源。

选择完成后点击右下角 `更新APT缓存` --> `应用更新` --> `安装更新`。

## 安装驱动

在欢迎程序打开驱动管理器安装驱动。第一次打开需要加载一会，耐心等待吧。

## 中文输入法

1. 打开系统设置，点击 `输入法` --> `简体中文` --> `安装`。

2. 切换顶部的 `输入法框架` 为 `fcitx`。

3. 注销重新登录。

默认的切换快捷键是 `Ctrl+空格`。

## 软件安装

有几种方法：

1. 软件管理器安装。

2. 软件管理器安装 flatpak 包。

    flatpak 是众多发行版通用的打包方式。打开软件管理器，点击右上角三条横杠 --> `首选项` --> `显示未经验证的 flatpak 软件`，这样可以显示出更多常用软件。

3. 网上下载 DEB 包双击安装。

    DEB 包本质是一个压缩包，可以类比 Windows 里的 .exe 安装包。

4. 网上下载 AppImage 包。

    下载之后需要右键设置 `以可执行程序启动`。AppImage 可以类比为免安装便携版。

5. 命令行安装。

    - 搜索

        `sudo apt search 关键词`

    - 安装

        `sudo apt install 包名`

    - 卸载

        `sudo apt remove 包名`

`sudo` 命令以管理员权限运行命令，需要输入密码，输入密码的过程不显示。

`apt` 是 Debian 系发行版的包管理器。

后面的 `search` `install` `remove` 都是 `apt` 的选项，更多选项可以通过 `apt -h` 查看，看不懂英文可以 AI 翻译。
