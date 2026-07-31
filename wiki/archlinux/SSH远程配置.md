# SSH 远程配置

> SSH 是 Linux 远程管理的基础，掌握后可以免密码登录、远程管理服务器。

## 一、安装与服务

```bash
sudo pacman -S openssh

# 启用服务（需要被远程访问时才需要）
sudo systemctl enable --now sshd
```

## 二、生成密钥对（免密码登录）

```bash
# 生成密钥（一路回车即可）
ssh-keygen -t ed25519 -C "你的备注"

# 复制公钥到远程服务器
ssh-copy-id 用户名@服务器IP
```

之后 `ssh 用户名@服务器IP` 不再需要密码。

## 三、日常使用

```bash
# 基本登录
ssh 用户名@IP

# 指定端口
ssh -p 端口号 用户名@IP

# 传文件
scp 本地文件 用户名@IP:目标路径

# 本地端口转发（把远端 8080 映射到本地 8080）
ssh -L 8080:localhost:8080 用户名@IP
```

## 四、配置文件 ~/.ssh/config

常用连接写入配置后，只需 `ssh 别名`：

```ini
Host my-server
    HostName 192.168.1.100
    User arch
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

## 五、安全加固

### 5.1 禁用密码登录（只允许密钥）

编辑 `/etc/ssh/sshd_config`：

```ini
PasswordAuthentication no
PermitRootLogin no
```

### 5.2 修改默认端口

```ini
Port 2222
```

改完重启：

```bash
sudo systemctl restart sshd
```

> 修改端口前确保防火墙放行新端口（ufw 用法见[玩游戏](玩游戏.md)章节）。

### 5.3 检查登录日志

```bash
# 查看失败的登录尝试
journalctl -u sshd | grep "Failed password"

# 实时查看登录
journalctl -u sshd -f
```

## 六、常见问题

| 问题 | 解决 |
|---|---|
| `Connection refused` | 服务没开：`sudo systemctl enable --now sshd` |
| `Permission denied (publickey)` | 服务端公钥没配置对，或密码登录被禁 |
| 连接很慢 | 反向 DNS 解析慢，服务端设置 `UseDNS no` |
| 端口被防火墙挡 | 放行端口：`sudo ufw allow 2222/tcp` |
