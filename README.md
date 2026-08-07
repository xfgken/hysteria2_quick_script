# Hysteria2 快速轻量管理脚本

一款注重 **快速、简约、轻量** 的 Hysteria2 (基于 QUIC) 一键管理脚本，内置 **混淆功能**（防封锁），无需域名即可快速部署，几十秒完成配置
，本脚本专门用于Hysteria2协议。

> **一条命令，即刻部署** —— 极简界面 · 无域名即可用 · 混淆防封锁 · 秒级配置

## ⚡ 特点

| | | |
|---|---|---|
| <img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/feature-fast.svg" width="36"> | **快速** | 一键命令下载安装并部署，配置完成立即启动服务 |
| <img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/feature-simple.svg" width="36"> | **简约** | 清爽的彩色命令行界面，状态一目了然 |
| <img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/feature-light.svg" width="36"> | **轻量** | 纯 Bash 脚本，无多余依赖，服务器资源占用极低 |
| <img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/feature-obfs.svg" width="36"> | **混淆** | 内置 `salamander` 混淆功能，有效应对网络审查与流量识别 |

<img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/section-rocket.svg" width="20"> **一键部署**

在你的服务器（root 权限）上，复制粘贴并执行**一行命令**即可完成下载、安装、部署：

```bash
curl -fsSL -o /usr/local/bin/hy2.sh https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/hysteria2.sh && chmod +x /usr/local/bin/hy2.sh && rm -f /usr/local/bin/hy2 && ln -s /usr/local/bin/hy2.sh /usr/local/bin/hy2 && echo '✅ hy2 已部署完成'
```

> 该命令会：下载脚本 → 添加执行权限 → 创建 `hy2` 快捷命令。执行后即可使用。

<img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/section-play.svg" width="20"> **启动脚本**

部署完成后，在终端输入：

```bash
hy2
```

即可进入 Hysteria2 管理菜单。

<img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/section-terminal.svg" width="20"> **功能菜单**

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

<img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/section-server.svg" width="20"> **环境要求**

- 操作系统：Linux（建议 Ubuntu / Debian）
- 权限：**root**（或使用 `sudo hy2`）
- 依赖：`curl`、`openssl`、`systemctl`（服务器常用工具均已预装）

<img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/section-config.svg" width="20"> **配置要点**

- **监听端口**：443（TCP/UDP，基于 QUIC）
- **混淆**：`salamander`（服务器端与客户端均启用，订阅链接自动携带混淆参数）
- **伪装**：`https://www.cloudflare.com/`（反向代理伪装）
- **TLS SNI**：`www.cloudflare.com`
- **密码**：15 位纯字母数字，自动随机生成，无需手动设置

### 订阅链接格式

```
hysteria2://AUTH@SERVER_IP:443/?insecure=1&obfs=salamander&obfs-password=XXX&sni=www.cloudflare.com#Hysteria2-随机6位
```

<img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/section-doc.svg" width="20"> **使用步骤**

1. 执行**一键部署命令**（见上文）
2. 输入 `hy2` 启动脚本
3. 选择 `[1]` 安装 Hysteria2
4. 选择 `[2]` 快速配置（自动生成配置并启动服务）
5. 选择 `[3]` 生成带混淆的订阅链接，导入手机客户端

<img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/section-preview.svg" width="20"> **界面预览**

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

<img src="https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/icons/section-license.svg" width="20"> **License**

MIT License