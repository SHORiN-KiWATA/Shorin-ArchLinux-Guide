# systemd 与日志排查

## 一、systemctl 常用命令

```bash
# 启动 / 停止 / 重启服务
sudo systemctl start 服务名
sudo systemctl stop 服务名
sudo systemctl restart 服务名

# 开机自启
sudo systemctl enable 服务名
sudo systemctl disable 服务名

# 查看服务状态（最常用，含错误信息）
systemctl status 服务名

# 列出所有失败的服务
systemctl --failed

# 重新加载配置（修改 .service / .conf 后）
sudo systemctl daemon-reload
```

`enable` 和 `start` 可连用：`sudo systemctl enable --now 服务名`。

## 二、journalctl 日志排查

```bash
# 本次启动的全部日志（排错首选）
journalctl -xb

# 只看错误和警告
journalctl -p 3 -xb

# 查看某个服务的日志
journalctl -u 服务名

# 实时跟踪日志（服务异常时开两个终端用）
journalctl -f

# 按时间过滤
journalctl --since "1 hour ago"
journalctl --since today

# 查看上一次启动的日志（上次崩溃时）
journalctl -b -1
```

### 2.1 排错流程示例

1. 服务启动失败：`systemctl status 服务名`，看底部红色报错
2. 日志太多：`journalctl -u 服务名 -p 3` 只看错误级
3. 引导阶段问题：`journalctl -xb` 后按 `/` 搜索 `error` / `fail`
4. 仍不明确：把报错原文贴到[交流群](交流群.md)或 Arch Wiki / 搜索引擎

## 三、自定义服务（定时任务 / 开机脚本）

### 3.1 systemd timer 代替 cron

创建定时任务文件 `/etc/systemd/system/backup.timer`：

```ini
[Unit]
Description=Daily backup

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

对应的服务 `/etc/systemd/system/backup.service`：

```ini
[Unit]
Description=Daily backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

启用：

```bash
sudo systemctl enable --now backup.timer
systemctl list-timers
```

### 3.2 开机自启脚本

```ini
[Unit]
Description=My script

[Service]
Type=oneshot
ExecStart=/usr/local/bin/myscript.sh

[Install]
WantedBy=multi-user.target
```

## 四、常用系统操作

```bash
# 关机 / 重启
poweroff
reboot

# 查看占用端口
ss -tlnp

# 查看磁盘空间
df -h

# 查看内存
free -h

# 查看开机时间
systemd-analyze
systemd-analyze blame   # 各服务耗时排名，优化开机速度用
```
