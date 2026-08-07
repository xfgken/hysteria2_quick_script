# Hysteria2 管理脚本

一个基于 Bash 的 **Hysteria2 服务一键管理脚本**，提供完整的安装、配置、订阅链接生成、信息查看、服务启停与卸载功能。

> 简约的界面、适用于无域名、混淆功能、快速配置

## ✨ 功能特性

- 🎨 彩色命令行界面，直观显示服务器信息与服务状态
- ⚡ 一键安装 Hysteria2（自动生成自签证书、开放防火墙端口）
- 🔧 快速配置：自动生成服务器与客户端配置，配置后立即启动服务
- 🔗 生成带**混淆参数**与**随机节点名**的订阅链接，导入客户端后自动显示节点名称
- 📋 查看服务器信息、服务状态、443 端口监听及完整配置文件
- ▶️ 服务启动 / ⏹️ 服务停止 / 🔄 服务重启
- 🗑️ 一键卸载服务（清理配置与防火墙规则）

## 📦 环境要求

- 操作系统：Linux（建议 Ubuntu / Debian）
- 权限：**root**
- 依赖：`curl`、`openssl`、`systemctl`（服务器常用工具均已预装）

## 🚀 快速开始

### 1. 上传脚本到服务器

将 `hysteria2.sh` 上传到服务器，例如：

```bash
scp hysteria2.sh root@YOUR_SERVER:/usr/local/bin/hy2.sh
```

### 2. 添加执行权限并部署为快捷命令

```bash
chmod +x /usr/local/bin/hy2.sh
ln -s /usr/local/bin/hy2.sh /usr/local/bin/hy2
```

### 3. 运行

```bash
hy2
```

> 提示：当前要求使用 **root** 用户运行，或使用 `sudo hy2`。

## 🕹️ 菜单功能

| 序号 | 功能 | 说明 |
|------|------|------|
| `[1]` | 安装 Hysteria2 | 安装主程序 + 生成自签证书 + 开放 443 端口(TCP/UDP) |
| `[2]` | 快速配置 | 自动生成服务器/客户端配置，并立即启动服务 |
| `[3]` | 订阅链接 | 生成**含混淆**且**带随机节点名**的订阅链接 |
| `[4]` | 查看信息 | 显示服务器信息、服务状态、端口监听、配置文件 |
| `[5]` | 服务启动 | 启动 hysteria-server 服务 |
| `[6]` | 服务停止 | 停止 hysteria-server 服务 |
| `[7]` | 服务重启 | 重启 hysteria-server 服务 |
| `[8]` | 卸载服务 | 卸载 Hysteria2 并清理配置与防火墙规则 |
| `[0]` | 退出脚本 | 退出管理脚本 |

### 状态显示

- **已安装 / 在运行** → 绿色圆点 ●
- **未安装 / 未运行** → 红色圆点 ●

## 📄 配置说明

脚本会自动生成以下配置文件：

| 文件 | 作用 |
|------|------|
| `/etc/hysteria/config.yaml` | Hysteria2 服务器配置 |
| `/etc/hysteria/client.yaml` | 客户端配置（用于生成订阅链接） |
| `/etc/hysteria/server.crt` `server.key` | 自签 TLS 证书（CN=cloudflare.com，36500 天） |

### 默认配置要点

- **监听端口**：443（TCP/UDP，基于 QUIC）
- **混淆**：`salamander`（服务器端与客户端均启用，保证订阅链接带混淆参数）
- **伪装**：`https://www.cloudflare.com/`（反向代理伪装）
- **TLS SNI**：`www.cloudflare.com`
- **密码**：15 位纯字母数字（自动生成，避免特殊字符导致的转义问题）

### 订阅链接格式

```
hysteria2://AUTH@SERVER_IP:443/?insecure=1&obfs=salamander&obfs-password=XXX&sni=www.cloudflare.com#Hysteria2-随机6位
```

> 导入客户端后将以 `Hysteria2-xxxxxx` 名称显示。

## 📝 使用步骤

1. 运行 `hy2`，选择 `[1]` 安装 Hysteria2
2. 选择 `[2]` 快速配置（自动生成配置并启动服务）
3. 选择 `[3]` 生成订阅链接，导入到手机客户端
4. 日常维护可使用 `[5]/[6]/[7]` 管理服务，`[4]` 查看信息
5. 不再使用时选择 `[8]` 卸载

## 📸 界面预览

```
==============================================
          Hysteria2 管理脚本 2.0
 简约的界面、适用于无域名、混淆功能、快速配置
==============================================

服务器IP: 123.123.123.123
系统版本: Ubuntu 24.04 LTS

● Hysteria2 已安装
● Hysteria2 在运行

请选择要执行的功能：

  [1] 安装Hysteria2
  [2] 快速配置
  [3] 订阅链接
  [4] 查看信息
  [5] 服务启动
  [6] 服务停止
  [7] 服务重启
  [8] 卸载服务
  [0] 退出脚本

请输入选择 [0-8]:
```

## ⚙️ 手动管理命令

脚本本质是对以下 systemd 服务的封装：

```bash
systemctl start hysteria-server.service     # 启动
systemctl stop hysteria-server.service      # 停止
systemctl restart hysteria-server.service   # 重启
systemctl status hysteria-server.service    # 查看状态
journalctl -u hysteria-server -n 50         # 查看日志
```

## 📜 License

MIT License
