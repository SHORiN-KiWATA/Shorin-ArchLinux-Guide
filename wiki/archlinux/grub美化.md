这一节是美化开机时候的菜单界面。

1. 网上下载 GRUB 主题放到 `/boot/grub/themes`，或者`/usr/share/grub/themes/`。

2. 编辑 GRUB 源文件

    ```bash
    vim /etc/default/grub
    ```
    - 主题路径

        下载下来的主题目录里通常会有一个`theme.txt`，我们要让 Grub 读取它。

        `GRUB_THEME="/path/to/theme.txt"`

    - 分辨率
        `GRUB_GFXMODE=2560x1440,1920x1080,auto`

3. 生成 GRUB 的配置文件

    ```bash
    grub-mkconfig -o /efi/grub/grub.cfg
    ```

我喜欢的主题：

> [CyberGRUB-2077](https://github.com/adnksharp/CyberGRUB-2077) | [Crossgrub](https://github.com/krypciak/crossgrub)

这个 repo 有一些别人收集的主题：

https://github.com/Jacksaur/Gorgeous-GRUB

下一节：[虚拟机](虚拟机.md)

