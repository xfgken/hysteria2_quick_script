# Hysteria2_Quick_Script

一个快速、简约的 Hysteria2 一键管理脚本。

无需复杂配置，快速完成 Hysteria2 部署。

支持自签 TLS 证书（100年有效期）、混淆配置、节点生成和服务管理。


## ✨ 特点

- 🚀 快速部署
- 🪶 简约轻量
- 🔐 自动生成自签 TLS 证书
- ♾️ 证书有效期约 100 年
- 🛡️ 支持 Salamander 混淆
- 🔗 自动生成节点链接
- ⚙️ 简单菜单管理


## 📦 安装

使用 root 用户执行：

```bash
curl -fsSL -o /usr/local/bin/hy2.sh https://raw.githubusercontent.com/xfgken/hysteria2_quick_script/main/hysteria2.sh && chmod +x /usr/local/bin/hy2.sh && rm -f /usr/local/bin/hy2 && ln -s /usr/local/bin/hy2.sh /usr/local/bin/hy2
