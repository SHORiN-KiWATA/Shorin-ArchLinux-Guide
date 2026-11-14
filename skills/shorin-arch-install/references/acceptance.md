# 验收记录格式

每项用 `pass / fail / pending / not-requested`，附实际输出/截图/测试现象。执行工具是否返回成功与实际功能是否工作分开记录。

| 层级 | 必须核对 |
|---|---|
| 引导 | 拔掉 ISO 后从目标盘成功启动，正常用户能登录；双系统时 Windows 也能启动 |
| 存储 | Btrfs 的 `@`、`@home`、选用 `@swap`；fstab UUID 正确；ESP 挂载点与 profile 一致 |
| 网络/音频 | 重启后联网；扬声器/麦克风；蓝牙按硬件需求；PipeWire 会话服务 |
| 桌面 | GNOME Wayland、正确 GPU 驱动、浏览器/文件管理器/终端/应用商城 |
| 中文 | 字体、输入源、浏览器/终端/QQ 中输入和候选框；不能只检查字体包 |
| 快照 | 对应 profile 的工具，创建/列出快照，GRUB 入口；恢复测试仅在有备份的可丢弃环境进行 |
| QQ | doctor、修复版启动器、双向剪贴板、截图不崩溃、真实屏幕分享 |
| 同款功能 | 指定扩展和快捷键均启用且工作；互斥扩展没有同时启用 |
| 同款界面 | 同壁纸、主题/光标/图标、字体/缩放、终端颜色/透明度、面板和动画；截图逐项比较 |
| 高级功能 | 请求过的 KVM、guest Windows、vfio、共享、远程桌面均实际运行 |

保存非敏感信息：`pacman -Q`、`gnome-shell --version`、`gnome-extensions list --enabled`、`dconf dump /org/gnome/`、壁纸和 theme 的 SHA256、源代码 SHA、GPU 型号/驱动、各检查结果。不要保存 auth 文件、Wi-Fi 密码或 root/user 密码。

当前交付验证：Python 编译、bash 语法、计划结构、安全前置条件的单元测试和 skill 元数据；未完成实机/虚拟机安装。不能因为这些检查通过写“装机测试已通过”。
