#!/bin/bash

# ============================================
#  Hysteria2 管理脚本 2.0
# ============================================

# 颜色定义
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
CYAN='\033[36m'
NC='\033[0m' # No Color

# 符号
DOT='●'

# 获取服务器 IP（优先公网IP，取第一个）
SERVER_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')

# 获取系统版本
get_os_version() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$PRETTY_NAME"
  else
    echo "Unknown OS"
  fi
}

OS_VERSION=$(get_os_version)

# 检查是否安装 Hysteria2
is_installed() {
  command -v hysteria >/dev/null 2>&1
}

# 检查服务是否运行
is_running() {
  systemctl is-active --quiet hysteria-server.service 2>/dev/null
}

# 生成随机密码（15位，纯字母数字，避免特殊字符导致 yaml/sed 转义问题）
gen_pass() {
  tr -dc 'A-Za-z0-9' </dev/urandom | head -c 15
}

# 显示标题和系统信息
show_header() {
  clear
  echo -e "${CYAN}==============================================${NC}"
  echo -e "${CYAN}          Hysteria2 管理脚本 2.0${NC}"
  echo -e "${CYAN} \033[34m简约的界面、${GREEN}适用于无域名、${YELLOW}混淆功能、\033[35m快速配置   ${NC}"
  echo -e "${CYAN}==============================================${NC}"
  echo ""
  echo -e "${YELLOW}服务器IP:${NC} $SERVER_IP"
  echo -e "${YELLOW}系统版本:${NC} $OS_VERSION"
  echo ""
}

# 显示服务状态（横向：安装 + 运行）
show_status() {
  if is_installed; then
    echo -e "${GREEN}${DOT}${NC} Hysteria2 已安装"
  else
    echo -e "${RED}${DOT}${NC} Hysteria2 未安装"
  fi
  if is_running; then
    echo -e "${GREEN}${DOT}${NC} Hysteria2 在运行"
  else
    echo -e "${RED}${DOT}${NC} Hysteria2 未运行"
  fi
  echo ""
}

# ============================================
#  功能一：安装 Hysteria2
# ============================================
install_hysteria2() {
  echo -e "${YELLOW}[1] 开始安装 Hysteria2...${NC}"
  bash <(curl -fsSL https://get.hy2.sh/)
  if command -v hysteria >/dev/null 2>&1; then
    echo -e "${GREEN}[OK] Hysteria2 主程序安装完成${NC}"
  else
    echo -e "${RED}[失败] Hysteria2 主程序安装失败${NC}"
    read -p "按回车返回主菜单..." enter
    return
  fi

  echo -e "${YELLOW}[2] 生成自签证书(36500天)...${NC}"
  openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) \
    -keyout /etc/hysteria/server.key \
    -out /etc/hysteria/server.crt \
    -subj "/CN=cloudflare.com" -days 36500 &&
  chown hysteria /etc/hysteria/server.key &&
  chown hysteria /etc/hysteria/server.crt
  if [ -f /etc/hysteria/server.crt ]; then
    echo -e "${GREEN}[OK] 自签证书已生成${NC}"
  else
    echo -e "${RED}[失败] 证书生成失败${NC}"
  fi

  echo -e "${YELLOW}[3] 开放防火墙 443 端口 (TCP/UDP)${NC}"
  iptables -I INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null && echo -e "${GREEN}[OK] TCP 443 已放行${NC}"
  iptables -I INPUT -p udp --dport 443 -j ACCEPT 2>/dev/null && echo -e "${GREEN}[OK] UDP 443 已放行${NC}"
  mkdir -p /etc/iptables && iptables-save > /etc/iptables/rules.v4 2>/dev/null

  echo -e "${GREEN}[完成] 安装过程结束，请执行功能2进行快速配置${NC}"
  read -p "按回车返回主菜单..." enter
}

# ============================================
#  功能二：配置 Hysteria2（配置后立即启动服务）
# ============================================
configure_hysteria2() {
  if ! is_installed; then
    echo -e "${RED}尚未安装 Hysteria2，请先执行功能1安装！${NC}"
    read -p "按回车返回主菜单..." enter
    return
  fi

  echo -e "${YELLOW}[步骤 1/3] 生成服务器与客户端配置...${NC}"
  # 纯字母数字密码（无特殊字符，写入 heredoc 与 YAML 绝对安全）
  AUTH_PASS=$(gen_pass)
  OBFS_PASS=$(gen_pass)

  # 服务器配置
  cat > /etc/hysteria/config.yaml <<TPL
listen: :443 # 端口默认 443
tls:
  cert: /etc/hysteria/server.crt
  key: /etc/hysteria/server.key
auth:
  type: password
  password: ${AUTH_PASS}
obfs:
  type: salamander
  salamander:
    password: ${OBFS_PASS}
masquerade:
  type: proxy
  proxy:
    url: https://www.cloudflare.com/
    rewriteHost: true
TPL

  # 客户端配置（含 obfs 混淆，保证订阅链接带混淆参数）
  cat > /etc/hysteria/client.yaml <<TPL
server: ${SERVER_IP}:443
auth: ${AUTH_PASS}
tls:
  sni: www.cloudflare.com
  insecure: true
obfs:
  type: salamander
  salamander:
    password: ${OBFS_PASS}
socks5:
  listen: 127.0.0.1:1080
http:
  listen: 127.0.0.1:8080
TPL

  echo -e "${GREEN}[OK] 服务器配置已生成 (/etc/hysteria/config.yaml)${NC}"
  echo -e "${GREEN}[OK] 客户端配置已生成 (/etc/hysteria/client.yaml，含混淆)${NC}"

  echo -e "${YELLOW}[步骤 2/3] 校验配置...${NC}"
  if [ -z "$AUTH_PASS" ] || [ -z "$OBFS_PASS" ] || ! grep -q "password: ${OBFS_PASS}" /etc/hysteria/config.yaml; then
    echo -e "${RED}[错误] 配置生成异常，请重试${NC}"
    read -p "按回车返回主菜单..." enter
    return
  fi
  echo -e "${GREEN}[OK] 配置校验通过${NC}"

  echo -e "${YELLOW}[步骤 3/3] 重启服务并立即启动...${NC}"
  systemctl enable hysteria-server.service >/dev/null 2>&1
  systemctl restart hysteria-server.service
  sleep 2

  if is_running; then
    echo -e "${GREEN}[OK] Hysteria2 服务已运行，开机自启已启用${NC}"
  else
    echo -e "${RED}[失败] 服务未正常运行，请查看日志：journalctl -u hysteria-server -n 50${NC}"
  fi

  echo ""
  echo -e "${YELLOW}已生成的配置：${NC}"
  echo -e "  认证密码 (auth): ${GREEN}${AUTH_PASS}${NC}"
  echo -e "  混淆密码 (obfs): ${GREEN}${OBFS_PASS}${NC}"
  echo -e "  服务配置完成 请前往功能3生成订阅链接"
  read -p "按回车返回主菜单..." enter
}

# ============================================
#  功能三：生成订阅链接（含混淆 + 节点名）
# ============================================
share_link() {
  if [ ! -f /etc/hysteria/client.yaml ]; then
    echo -e "${RED}客户端配置文件不存在，请先执行功能2完成配置！${NC}"
    read -p "按回车返回主菜单..." enter
    return
  fi
  echo -e "${YELLOW}正在生成订阅链接(含混淆 + 节点名)...${NC}"

  # 生成随机6位名称（数字+英文）
  RAND_NAME=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
  NODE_NAME="Hysteria2-${RAND_NAME}"

  # 获取原始链接，拼接 #节点名 参数（导入客户端时显示该名称）
  RAW_LINK=$(hysteria share -c /etc/hysteria/client.yaml)

  # 组合最终链接：在链接末尾追加 #名字
  FINAL_LINK="${RAW_LINK}#${NODE_NAME}"

  echo ""
  echo -e "${YELLOW}节点名称:${NC} ${GREEN}${NODE_NAME}${NC}"
  echo -e "${YELLOW}订阅链接:${NC}"
  echo -e "${GREEN}${FINAL_LINK}${NC}"
  echo ""
  echo -e "${YELLOW}提示：导入客户端后将以 ${GREEN}${NODE_NAME}${NC} 名称显示${NC}"
  read -p "按回车返回主菜单..." enter
}

# ============================================
#  功能四：查看配置信息
# ============================================
view_info() {
  echo -e "${CYAN}====== 服务器信息 ======${NC}"
  echo -e "服务器IP: ${GREEN}${SERVER_IP}${NC}"
  echo -e "系统版本: ${GREEN}${OS_VERSION}${NC}"
  echo -e "当前用户: $(whoami)@$(hostname)"
  echo -e "内核版本: $(uname -r)"
  echo ""

  echo -e "${CYAN}====== 服务状态 ======${NC}"
  if is_installed; then
    echo -e "${GREEN}${DOT}${NC} Hysteria2 已安装"
  else
    echo -e "${RED}${DOT}${NC} Hysteria2 未安装"
  fi
  if is_running; then
    echo -e "${GREEN}${DOT}${NC} Hysteria2 正在运行"
  else
    echo -e "${RED}${DOT}${NC} Hysteria2 停止运行"
  fi
  echo ""
  echo -e "443端口监听:"
  ss -ulnp 2>/dev/null | grep 443 | head -1 || echo -e "  ${RED}未检测到 UDP 443 监听${NC}"
  echo ""

  echo -e "${CYAN}====== 配置文件 ======${NC}"
  echo -e "${YELLOW}--- 服务器配置 (/etc/hysteria/config.yaml) ---${NC}"
  if [ -f /etc/hysteria/config.yaml ]; then
    cat /etc/hysteria/config.yaml
  else
    echo -e "${RED}配置文件不存在${NC}"
  fi
  echo ""
  echo -e "${YELLOW}--- 客户端配置 (/etc/hysteria/client.yaml) ---${NC}"
  if [ -f /etc/hysteria/client.yaml ]; then
    cat /etc/hysteria/client.yaml
  else
    echo -e "${RED}配置文件不存在${NC}"
  fi
  echo ""

  read -p "按回车返回主菜单..." enter
}

# ============================================
#  功能五：服务启动
# ============================================
service_start() {
  echo -e "${YELLOW}正在启动 Hysteria2 服务...${NC}"
  systemctl start hysteria-server.service 2>/dev/null
  sleep 2
  if is_running; then
    echo -e "${GREEN}[OK] Hysteria2 服务已启动${NC}"
  else
    echo -e "${RED}[失败] 服务启动失败，请查看日志：journalctl -u hysteria-server -n 50${NC}"
  fi
  read -p "按回车返回主菜单..." enter
}

# ============================================
#  功能六：服务停止
# ============================================
service_stop() {
  echo -e "${YELLOW}正在停止 Hysteria2 服务...${NC}"
  systemctl stop hysteria-server.service 2>/dev/null
  sleep 2
  if is_running; then
    echo -e "${RED}[失败] 服务仍在运行，停止失败${NC}"
  else
    echo -e "${GREEN}[OK] Hysteria2 服务已停止${NC}"
  fi
  read -p "按回车返回主菜单..." enter
}

# ============================================
#  功能七：服务重启
# ============================================
service_restart() {
  echo -e "${YELLOW}正在重启 Hysteria2 服务...${NC}"
  systemctl restart hysteria-server.service 2>/dev/null
  sleep 2
  if is_running; then
    echo -e "${GREEN}[OK] Hysteria2 服务已重启并运行${NC}"
  else
    echo -e "${RED}[失败] 服务重启失败，请查看日志：journalctl -u hysteria-server -n 50${NC}"
  fi
  read -p "按回车返回主菜单..." enter
}

# ============================================
#  功能八：卸载服务
# ============================================
uninstall_hysteria2() {
  echo -e "${YELLOW}正在卸载 Hysteria2...${NC}"
  systemctl stop hysteria-server.service 2>/dev/null
  systemctl disable hysteria-server.service 2>/dev/null
  rm -rf /etc/hysteria
  bash <(curl -fsSL https://get.hy2.sh/) --remove 2>/dev/null
  iptables -D INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null
  iptables -D INPUT -p udp --dport 443 -j ACCEPT 2>/dev/null
  iptables-save > /etc/iptables/rules.v4 2>/dev/null
  echo -e "${GREEN}卸载完成！${NC}"
  read -p "按回车返回主菜单..." enter
}

# 检测是否以 root 运行
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}请使用 root 权限运行本脚本 (sudo hy2)${NC}"
    exit 1
  fi
}

# ============================================
#  主菜单
# ============================================
main() {
  check_root
  while true; do
    show_header
    show_status

    echo -e "${YELLOW}请选择要执行的功能：${NC}"
    echo ""
    echo -e "  ${CYAN}[1]${NC} 安装Hysteria2"
    echo -e "  ${CYAN}[2]${NC} 快速配置"
    echo -e "  ${CYAN}[3]${NC} 订阅链接"
    echo -e "  ${CYAN}[4]${NC} 查看信息"
    echo -e "  ${CYAN}[5]${NC} \033[92m服务启动${NC}"
    echo -e "  ${CYAN}[6]${NC} \033[91m服务停止${NC}"
    echo -e "  ${CYAN}[7]${NC} \033[93m服务重启${NC}"
    echo -e "  ${CYAN}[8]${NC} 卸载服务"
    echo -e "  ${CYAN}[0]${NC} 退出脚本"
    echo ""
    read -p "请输入选择 [0-8]: " choice

    case $choice in
      1) install_hysteria2 ;;
      2) configure_hysteria2 ;;
      3) share_link ;;
      4) view_info ;;
      5) service_start ;;
      6) service_stop ;;
      7) service_restart ;;
      8) uninstall_hysteria2 ;;
      0) echo -e "${GREEN}感谢使用hysteria2管理脚本2.0，再见！${NC}"; exit 0 ;;
      *) echo -e "${RED}无效选择！${NC}"; sleep 1 ;;
    esac
  done
}

# 启动
main