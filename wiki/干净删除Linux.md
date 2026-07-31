
>视频教程（从7分47秒开始）：[从LinuxMint入门到ArchLinux安装详解](https://www.bilibili.com/video/BV19DBqB4EY4/?share_source=copy_web&vd_source=1c6a132d86487c8c4a29c7ff5cd8ac50) 

## 删除分区和引导 

1. 下载 DiskGenius

    如果不知道怎么从官网下载的话可以[下载图吧工具箱](https://www.tbtool.cn/)，在磁盘工具页面有。

2. 删除分区和引导文件

    右键强制删除安装了 Linux 的系统分区。如果 Linux 和 Windows 共用一个引导分区还需要进入 Windows 的引导分区删除 Linux 的引导文件。

3. 更改后在 DiskGenius 左上角保存

## 删除主板上储存的入口

  使用 BOOTICE 这个软件的 `UEFI` 功能。在 `UEFI 启动序列` 中删除储存在主板上的启动项。


