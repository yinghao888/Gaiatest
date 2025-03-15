#!/bin/bash

printf "\n"
cat <<EOF


░██████╗░░█████╗░  ░█████╗░██████╗░██╗░░░██╗██████╗░████████╗░█████╗░
██╔════╝░██╔══██╗  ██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔══██╗
██║░░██╗░███████║  ██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░██║░░██║
██║░░╚██╗██╔══██║  ██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░██║░░██║
╚██████╔╝██║░░██║  ╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░╚█████╔╝
░╚═════╝░╚═╝░░╚═╝  ░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░░╚════╝░
EOF

printf "\n\n"

##########################################################################################
#                                                                                        
#                🚀 此脚本由 **GA CRYPTO** 骄傲地创建！🚀                 
#                                                                                        
#   🌐 加入我们在去中心化网络和加密创新中的革命！               
#                                                                                        
# 📢 保持更新：                                                                      
#     • 关注我们的 Telegram：https://t.me/GaCryptOfficial                             
#     • 关注我们的 X：https://x.com/GACryptoO                                         
##########################################################################################

# 用于广告的绿色
GREEN="\033[0;32m"
RESET="\033[0m"

# 如果未安装软件包，则安装软件包的函数
install_pkg() {
    local pkg=$1
    if ! command -v $pkg &> /dev/null; then
        echo "❌ $pkg 未安装。正在安装 $pkg..."
        sudo apt update
        sudo apt install -y $pkg
    else
        echo "✅ $pkg 已安装。"
    fi
}

# 如果不存在 sudo，则安装 sudo
if ! command -v sudo &> /dev/null; then
    echo "❌ sudo 未安装。正在安装 sudo..."
    apt update
    apt install -y sudo
else
    echo "✅ sudo 已安装。"
fi

# 要安装的基本软件包列表
pkgs=(
    "screen" "lsof" "wget" "htop" "nvtop" "curl" "git" "sudo"
)

# 安装每个软件包
for pkg in "${pkgs[@]}"; do
    install_pkg $pkg
done

# 更新 locate 数据库
if command -v updatedb &> /dev/null; then
    echo "🔄 正在更新 locate 数据库..."
    sudo updatedb
fi

# 检查可升级的软件包
echo "🔍 正在检查可升级的软件包..."
upgradable=$(apt list --upgradable 2>/dev/null | grep -v "Listing...")

if [[ -n "$upgradable" ]]; then
    echo "📦 以下软件包可以升级："
    echo "$upgradable"
    echo "🚀 正在升级软件包..."
    sudo apt upgrade -y
else
    echo "✅ 没有需要升级的软件包。"
fi

echo "🎉 系统设置和更新完成！"

# 检测是否在 WSL 环境中运行
IS_WSL=false
if grep -qi microsoft /proc/version; then
    IS_WSL=true
    echo "🖥️ 在 WSL 环境中运行。"
else
    echo "🖥️ 在原生 Ubuntu 系统上运行。"
fi

# 自动检测并设置本地时区的函数
setup_timezone() {
    log_message "正在检测并设置本地时区..."

    # 如果未安装 tzdata，则安装 tzdata
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y tzdata > /dev/null 2>&1

    # 使用 timedatectl 检测本地时区
    if command -v timedatectl &> /dev/null; then
        LOCAL_TIMEZONE=$(timedatectl show --property=Timezone --value)
        if [ -z "$LOCAL_TIMEZONE" ]; then
            log_message "警告：无法检测本地时区。回退到 UTC。"
            LOCAL_TIMEZONE="UTC"
        fi
    else
        log_message "警告：未找到 'timedatectl'。回退到基于 IP 的时区检测。"
        # 回退到基于 IP 的时区检测
        LOCAL_TIMEZONE=$(curl -s https://ipapi.co/timezone)
        if [ -z "$LOCAL_TIMEZONE" ]; then
            log_message "警告：基于 IP 的时区检测失败。回退到 UTC。"
            LOCAL_TIMEZONE="UTC"
        fi
    fi

    # 设置检测到的时区
    log_message "正在将时区设置为 $LOCAL_TIMEZONE..."
    echo "$LOCAL_TIMEZONE" | sudo tee /etc/timezone > /dev/null
    sudo ln -fs "/usr/share/zoneinfo/$LOCAL_TIMEZONE" /etc/localtime
    sudo dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1

    log_message "时区成功设置为 $(date)。"
}

# 检查是否已安装 CUDA
check_cuda_installed() {
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep -oP 'release \K\d+\.\d+' | cut -d. -f1)
        echo "✅ 已安装 CUDA 版本 $CUDA_VERSION。"
        return 0
    else
        echo "⚠️ 未安装 CUDA。"
        return 1
    fi
}

# 检查是否存在 NVIDIA GPU 的函数
check_nvidia_gpu() {
    if command -v nvidia-smi &> /dev/null || lspci | grep -i nvidia &> /dev/null; then
        echo "✅ 检测到 NVIDIA GPU。"
        return 0
    else
        echo "⚠️ 未找到 NVIDIA GPU。"
        return 1
    fi
}

# 检查系统类型是 VPS、笔记本电脑还是台式机的函数
check_system_type() {
    vps_type=$(systemd-detect-virt)
    if echo "$vps_type" | grep -qiE "kvm|qemu|vmware|xen|lxc"; then
        echo "✅ 这是一台 VPS。"
        return 0  # VPS
    elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
        echo "✅ 这是一台笔记本电脑。"
        return 1  # 笔记本电脑
    else
        echo "✅ 这是一台台式机。"
        return 2  # 台式机
    fi
}

# 确定系统类型并设置配置 URL 的函数
set_config_url() {
    check_system_type
    SYSTEM_TYPE=$?  # 捕获 check_system_type 的返回值
    echo "🔧 检测到的系统类型：$SYSTEM_TYPE"

    if [[ $SYSTEM_TYPE -eq 0 ]]; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
    elif [[ $SYSTEM_TYPE -eq 1 ]]; then
        if ! check_nvidia_gpu; then
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
        else
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config.json"
        fi
    elif [[ $SYSTEM_TYPE -eq 2 ]]; then
        if ! check_nvidia_gpu; then
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
        else
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config.json"
        fi
    else
        echo "⚠️ 无法确定系统类型。使用默认配置。"
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config1.json"
    fi
    echo "🔗 使用配置：$CONFIG_URL"
}

# 在 WSL 或 Ubuntu 24.04 上安装 CUDA Toolkit 12.8 的函数
install_cuda() {
    if $IS_WSL; then
        echo "🖥️ 为 WSL 2 安装 CUDA..."
        # 定义 WSL 的文件名和 URL
        PIN_FILE="cuda-wsl-ubuntu.pin"
        PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin"
        DEB_FILE="cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
        DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
    else
        echo "🖥️ 为 Ubuntu 24.04 安装 CUDA..."
        # 定义 Ubuntu 24.04 的文件名和 URL
        PIN_FILE="cuda-ubuntu2404.pin"
        PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin"
        DEB_FILE="cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
        DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
    fi

    # 下载 .pin 文件
    echo "📥 正在从 $PIN_URL 下载 $PIN_FILE..."
    wget "$PIN_URL" || { echo "❌ 无法下载 $PIN_FILE 从 $PIN_URL"; exit 1; }

    # 将 .pin 文件移动到正确的位置
    sudo mv "$PIN_FILE" /etc/apt/preferences.d/cuda-repository-pin-600 || { echo "❌ 无法将 $PIN_FILE 移动到 /etc/apt/preferences.d/"; exit 1; }

    # 如果存在 .deb 文件，则删除并下载新副本
    if [ -f "$DEB_FILE" ]; then
        echo "🗑️ 正在删除现有的 $DEB_FILE..."
        rm -f "$DEB_FILE"
    fi
    echo "📥 正在从 $DEB_URL 下载 $DEB_FILE..."
    wget "$DEB_URL" || { echo "❌ 无法下载 $DEB_FILE 从 $DEB_URL"; exit 1; }

    # 安装 .deb 文件
    sudo dpkg -i "$DEB_FILE" || { echo "❌ 无法安装 $DEB_FILE"; exit 1; }

    # 复制密钥环
    sudo cp /var/cuda-repo-*/cuda-*-keyring.gpg /usr/share/keyrings/ || { echo "❌ 无法将 CUDA 密钥环复制到 /usr/share/keyrings/"; exit 1; }

    # 更新软件包列表并安装 CUDA Toolkit 12.8
    echo "🔄 正在更新软件包列表..."
    sudo apt-get update || { echo "❌ 无法更新软件包列表"; exit 1; }
    echo "🔧 正在安装 CUDA Toolkit 12.8..."
    sudo apt-get install -y cuda-toolkit-12-8 || { echo "❌ 无法安装 CUDA Toolkit 12.8"; exit 1; }

    echo "✅ CUDA Toolkit 12.8 安装成功。"
    setup_cuda_env
}

# 设置 CUDA 环境变量
setup_cuda_env() {
    echo "🔧 正在设置 CUDA 环境变量..."
    echo 'export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}' | sudo tee /etc/profile.d/cuda.sh
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' | sudo tee -a /etc/profile.d/cuda.sh
    source /etc/profile.d/cuda.sh
}

# 使用或不使用 CUDA 支持安装 GaiaNet 的函数
install_gaianet() {
    local BASE_DIR=$1
    local CONFIG_URL=$2

    # 如果基础目录不存在，则创建基础目录
    if [ ! -d "$BASE_DIR" ]; then
        echo "📂 正在创建目录 $BASE_DIR..."
        mkdir -p "$BASE_DIR" || { echo "❌ 无法创建目录 $BASE_DIR"; exit 1; }
    fi

    # 检查 CUDA 支持
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep -oP 'release \K\d+\.\d+' | cut -d. -f1)
        echo "✅ 检测到 CUDA 版本：$CUDA_VERSION"
        
        if [[ "$CUDA_VERSION" == "11"* || "$CUDA_VERSION" == "12"* ]]; then
            echo "🔧 使用 CUDA 支持安装 GaiaNet..."
            curl -sSfL 'https://raw.githubusercontent.com/abhiag/Gaiatest/main/install21.sh' | bash -s -- --base "$BASE_DIR" --ggmlcuda "$CUDA_VERSION" || { echo "❌ GaiaNet 安装失败。"; exit 1; }
            return
        fi
    fi

    echo "⚠️ 不使用 GPU 支持安装 GaiaNet..."
    curl -sSfL 'https://raw.githubusercontent.com/abhiag/Gaiatest/main/install21.sh' | bash -s -- --base "$BASE_DIR" || { echo "❌ GaiaNet 安装失败。"; exit 1; }

    # 下载并应用配置文件
    echo "📥 正在从 $CONFIG_URL 下载配置..."
    wget -O "$BASE_DIR/config.json" "$CONFIG_URL" || { echo "❌ 无法下载配置文件。"; exit 1; }
}

# 安装 GaiaNet 节点的函数
install_gaianet_node() {
    local NODE_NUMBER=$1
    local CONFIG_URL=$2
    local BASE_DIR="$HOME/gaianet$NODE_NUMBER"
    local PORT=$((8090 + NODE_NUMBER))

    echo "🔧 正在 $BASE_DIR 中设置 GaiaNet 节点 $NODE_NUMBER，端口为 $PORT..."

    # 检查 GaiaNet 是否已安装
    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "ℹ️ $BASE_DIR 中已安装 GaiaNet。正在跳过安装。"
    else
        # 使用提供的 CONFIG_URL 安装 GaiaNet
        install_gaianet "$BASE_DIR" "$CONFIG_URL"

        # 验证安装
        if [ -f "$BASE_DIR/bin/gaianet" ]; then
            echo "✅ GaiaNet 节点 $NODE_NUMBER 在 $BASE_DIR 中安装成功。"
        else
            echo "❌ GaiaNet 节点 $NODE_NUMBER 安装失败。"
            return 1
        fi
    fi

    # 下载并应用配置文件
    echo "📥 正在从 $CONFIG_URL 下载配置..."
    wget -O "$BASE_DIR/config.json" "$CONFIG_URL" || { echo "❌ 无法下载配置文件。"; return 1; }

    # 配置端口
    "$BASE_DIR/bin/gaianet" config --base "$BASE_DIR" --port "$PORT" || { echo "❌ 端口配置失败。"; return 1; }

    # 初始化节点
    echo "⚙️ 正在初始化 GaiaNet..."
    "$BASE_DIR/bin/gaianet" init --base "$BASE_DIR" || { echo "❌ GaiaNet 初始化失败！"; return 1; }

    # 启动节点
    echo "🚀 正在启动 GaiaNet 节点 $NODE_NUMBER..."
    "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" || { echo "❌ 错误：无法启动 GaiaNet 节点！"; return 1; }

    echo "🎉 GaiaNet 节点 $NODE_NUMBER 在 $BASE_DIR 中成功安装并启动，端口为 $PORT！"
}

# 启动特定节点的函数
start_gaianet_node() {
    local NODE_NUMBER=$1
    local BASE_DIR="$HOME/gaianet$NODE_NUMBER"
    local LOG_FILE="$BASE_DIR/gaianet.log"

    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "🚀 使用 nohup 启动 GaiaNet 节点 $NODE_NUMBER..."
        nohup "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" > "$LOG_FILE" 2>&1 < /dev/null & 
        echo "✅ GaiaNet 节点 $NODE_NUMBER 已启动。日志：$LOG_FILE"
    else
        echo "❌ GaiaNet 节点 $NODE_NUMBER 未安装。"
    fi
}

# 停止特定节点或所有节点的函数
stop_gaianet_node() {
    local NODE_NUMBER=$1

    if [[ "$NODE_NUMBER" == "all" ]]; then
        # 停止所有节点和共享服务
        echo "🛑 正在停止所有 GaiaNet 节点和共享服务..."

        # 检查是否存在 ~/gaianet/bin/gaianet
        if [ -f "$HOME/gaianet/bin/gaianet" ]; then
            "$HOME/gaianet/bin/gaianet" stop || { echo "❌ 错误：无法停止所有节点！"; return 1; }
        # 检查是否存在 ~/gaianet0/bin/gaianet
        elif [ -f "$HOME/gaianet1/bin/gaianet" ]; then
            "$HOME/gaianet1/bin/gaianet" stop || { echo "❌ 错误：无法停止所有节点！"; return 1; }
        else
            echo "❌ 未找到 GaiaNet 节点。无法停止所有节点。"
            return 1
        fi

        echo "✅ 所有 GaiaNet 节点和共享服务已停止。"
    else
        # 通过杀死监听其端口的进程来停止特定节点
        local BASE_DIR="$HOME/gaianet$NODE_NUMBER"
        local PORT=$((8090 + NODE_NUMBER))

        if [ -f "$BASE_DIR/bin/gaianet" ]; then
            echo "🛑 正在停止 GaiaNet 节点 $NODE_NUMBER..."

            # 查找并杀死监听节点端口的进程
            PIDS=$(lsof -t -i :$PORT)
            if [ -n "$PIDS" ]; then
                echo "🛑 正在杀死监听端口 $PORT 的进程..."
                for PID in $PIDS; do
                    echo "🛑 正在杀死进程 $PID..."
                    kill -9 "$PID" || { echo "❌ 错误：无法停止进程 $PID！"; return 1; }
                done
                echo "✅ GaiaNet 节点 $NODE_NUMBER 已停止。"
            else
                echo "ℹ️ 在端口 $PORT 上未找到监听的进程。节点可能已停止。"
            fi
        else
            echo "❌ GaiaNet 节点 $NODE_NUMBER 未安装。"
        fi
    fi
}

restart_gaianet_node() {
    local NODE_NUMBER=$1

    # 如果传递了 "all"，则重启所有节点 (0-10)
    if [[ "$NODE_NUMBER" == "all" ]]; then
        echo "🔄 正在重启所有 GaiaNet 节点 (0-10)..."
        for i in {0..10}; do
            restart_gaianet_node "$i"
        done
        echo "✅ 所有 GaiaNet 节点已重启。"
        return
    fi

    # 根据节点编号设置基础目录和端口
    if [[ "$NODE_NUMBER" -eq 0 ]]; then
        BASE_DIR="$HOME/gaianet"  # 节点 0 的默认目录
        PORT=8090
    else
        BASE_DIR="$HOME/gaianet$NODE_NUMBER"  # 节点 1-10 的目录
        PORT=$((8090 + NODE_NUMBER))
    fi

    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "🔄 正在重启 GaiaNet 节点 $NODE_NUMBER..."

        # 首先停止节点
        stop_gaianet_node "$NODE_NUMBER" || { echo "❌ 错误：无法停止节点 $NODE_NUMBER！"; return 1; }

        # 启动节点而不记录日志
        echo "🚀 正在启动 GaiaNet 节点 $NODE_NUMBER..."
        nohup "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" > /dev/null 2>&1 &
        
        echo "✅ GaiaNet 节点 $NODE_NUMBER 已重启。"
    else
        echo "❌ GaiaNet 节点 $NODE_NUMBER 未安装。"
    fi
}

# 通过检查其端口来检查节点是否正在运行的函数
check_node_status() {
    local NODE_NUMBER=$1
    local PORT=$((8090 + NODE_NUMBER))  # 根据节点编号计算端口

    # 检查端口是否打开并正在监听
    if lsof -i :$PORT > /dev/null 2>&1; then
        echo "节点状态：运行中 🟢 (端口 $PORT)"
    else
        echo "节点状态：已停止 🔴 (端口 $PORT)"
    fi
}

# 显示节点信息的函数（与 check_all_installed_nodes 合并）
display_node_info() {
    local NODE_NUMBER=$1

    if [[ -z "$NODE_NUMBER" ]]; then
        # 如果未提供节点编号，则检查所有已安装的节点
        echo "🔍 正在检查所有已安装的 GaiaNet 节点..."

        # 检查 ~/gaianet 中的默认节点
        if [ -d "$HOME/gaianet" ]; then
            echo "---------------------------------------------------------------"
            echo "📂 正在检查目录中的默认节点：$HOME/gaianet"
            display_node_info "0"  # 默认节点视为节点 0
        fi

        # 检查 ~/gaianet1, ~/gaianet2 等中的其他节点
        for NODE_DIR in "$HOME/gaianet"{1..10}; do
            if [ -d "$NODE_DIR" ]; then
                echo "---------------------------------------------------------------"
                echo "📂 正在检查目录中的节点：$NODE_DIR"
                NODE_NUMBER=$(basename "$NODE_DIR" | grep -o '[0-9]*')
                display_node_info "$NODE_NUMBER"
            fi
        done

        echo "✅ 完成检查所有已安装的节点。"
    else
        # 如果提供了节点编号，则检查特定节点
        if [[ "$NODE_NUMBER" == "0" ]]; then
            local BASE_DIR="$HOME/gaianet"  # 默认节点目录
        else
            local BASE_DIR="$HOME/gaianet$NODE_NUMBER"
        fi

        if [ -f "$BASE_DIR/bin/gaianet" ]; then
            echo "🔍 GaiaNet 节点 $NODE_NUMBER 的信息："
            "$BASE_DIR/bin/gaianet" info --base "$BASE_DIR" || { echo "❌ 错误：无法获取节点信息！"; return 1; }
            check_node_status "$NODE_NUMBER"  # 检查并显示节点状态
        else
            echo "❌ GaiaNet 节点 $NODE_NUMBER 未安装。"
        fi
    fi
}

# 检查已安装节点及其端口状态的函数
check_installed_nodes() {
    echo "🔍 正在检查已安装的 GaiaNet 节点及其端口状态..."

    # 遍历所有 gaianet 目录
    for dir in "$HOME"/gaianet*; do
        if [ -d "$dir" ]; then
            # 从目录名中提取节点编号
            if [[ "$dir" == "$HOME/gaianet" ]]; then
                NODE_NUMBER=0
            else
                NODE_NUMBER=$(echo "$dir" | grep -oP '(?<=gaianet)\d+')
            fi

            # 计算端口号
            PORT=$((8090 + NODE_NUMBER))

            # 检查 gaianet 二进制文件是否存在
            if [ -f "$dir/bin/gaianet" ]; then
                STATUS="✅ 已安装"
            else
                STATUS="❌ 未安装"
            fi

            # 检查端口是否活跃
            if lsof -i :$PORT > /dev/null 2>&1; then
                PORT_STATUS="🟢 活跃 (端口 $PORT)"
            else
                PORT_STATUS="🔴 不活跃 (端口 $PORT)"
            fi

            # 显示节点信息
            echo "节点 $NODE_NUMBER："
            echo "  目录：$dir"
            echo "  状态：$STATUS"
            echo "  节点状态：$PORT_STATUS"
            echo "----------------------------------------"
        fi
    done
}

# 列出活跃的 screen 会话并允许用户选择一个的函数
select_screen_session() {
    while true; do
        echo "🔍 正在检查活跃的 screen 会话..."

        # 获取活跃的 screen 会话列表
        sessions=$(screen -list | grep -oP '\d+\.\S+' | awk '{print $1}')

        # 检查是否存在活跃的会话
        if [ -z "$sessions" ]; then
            echo "❌ 未找到活跃的 screen 会话。"
            return  # 返回主菜单
        fi

        # 显示带有编号的会话列表
        echo "✅ 活跃的 screen 会话："
        i=1
        declare -A session_map
        for session in $sessions; do
            session_name=$(echo "$session" | cut -d'.' -f2)
            echo "$i) $session_name"
            session_map[$i]=$session
            i=$((i+1))
        done

        # 提示用户选择会话
        echo -n "👉 按编号选择会话 (1, 2, 3, ...) 或按 Enter 返回主菜单："
        read -r choice

        # 如果用户按 Enter，返回主菜单
        if [ -z "$choice" ]; then
            echo "返回主菜单..."
            return
        fi

        # 验证用户的选择
        if [[ -z "${session_map[$choice]}" ]]; then
            echo "❌ 无效的选择。请重试。"
            continue
        fi

        # 连接到所选会话
        selected_session=${session_map[$choice]}
        echo "🚀 正在连接到会话：$selected_session"
        screen -d -r "$selected_session"
        break
    done
}

# 通过其端口停止节点的函数
stop_node_by_port() {
    local PORT=$1
    echo "🛑 正在停止端口 $PORT 上的 GaiaNet 节点..."
    if lsof -i :$PORT > /dev/null 2>&1; then
        kill $(lsof -t -i :$PORT)  # 杀死使用该端口的进程
        sleep 2  # 等待进程停止
        if lsof -i :$PORT > /dev/null 2>&1; then
            echo "❌ 无法停止端口 $PORT 上的 GaiaNet 节点。"
            return 1
        else
            echo "✅ 端口 $PORT 上的 GaiaNet 节点已停止。"
            return 0
        fi
    else
        echo "✅ 端口 $PORT 上的 GaiaNet 节点已停止。"
        return 0
    fi
}

# 通过端口号卸载节点的函数
uninstall_node_by_port() {
    local NODE_NUMBER=$1
    local PORT=$((8090 + NODE_NUMBER))
    local BASE_DIR

    if [[ "$NODE_NUMBER" == "0" ]]; then
        BASE_DIR="$HOME/gaianet"  # 默认节点目录
    else
        BASE_DIR="$HOME/gaianet$NODE_NUMBER"
    fi

    echo "⚠️ 警告：这将从您的系统中完全移除 GaiaNet 节点 $NODE_NUMBER (端口：$PORT)！"
    read -rp "您确定要继续吗？(y/n) " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "卸载已中止。"
        return
    fi

    echo "🔍 正在检查 GaiaNet 节点 $NODE_NUMBER (端口：$PORT) 是否正在运行..."
    if check_node_status "$NODE_NUMBER"; then
        echo "🛑 GaiaNet 节点 $NODE_NUMBER (端口：$PORT) 当前正在运行。正在停止..."
        if stop_node_by_port "$PORT"; then
            echo "🗑️ 正在卸载 GaiaNet 节点 $NODE_NUMBER (端口：$PORT)..."
            if [ -d "$BASE_DIR" ]; then
                rm -rf "$BASE_DIR"
                echo "✅ GaiaNet 节点 $NODE_NUMBER (端口：$PORT) 已卸载。"
            else
                echo "❌ GaiaNet 节点 $NODE_NUMBER (端口：$PORT) 未安装。"
            fi
        else
            echo "❌ 无法停止 GaiaNet 节点 $NODE_NUMBER (端口：$PORT)。卸载已中止。"
        fi
    else
        echo "🗑️ 正在卸载 GaiaNet 节点 $NODE_NUMBER (端口：$PORT)..."
        if [ -d "$BASE_DIR" ]; then
            rm -rf "$BASE_DIR"
            echo "✅ GaiaNet 节点 $NODE_NUMBER (端口：$PORT) 已卸载。"
        else
            echo "❌ GaiaNet 节点 $NODE_NUMBER (端口：$PORT) 未安装。"
        fi
    fi
}

# 为所有已安装节点更新端口配置的函数
update_all_gaianet_ports() {
    echo "🔄 正在为所有已安装的 GaiaNet 节点更新端口配置..."

    for NODE_NUMBER in {0..4}; do
        # 根据节点编号设置基础目录和预定义端口
        if [[ "$NODE_NUMBER" -eq 0 ]]; then
            BASE_DIR="$HOME/gaianet"  # 节点 0 的默认目录
            PORT=8090  # 节点 0 的预定义端口
        else
            BASE_DIR="$HOME/gaianet$NODE_NUMBER"  # 节点 1-4 的目录
            PORT=$((8090 + NODE_NUMBER))  # 节点 1-4 的预定义端口
        fi

        # 检查节点是否已安装
        if [ -f "$BASE_DIR/bin/gaianet" ]; then
            echo "🔧 正在为 GaiaNet 节点 $NODE_NUMBER 更新端口配置到 $PORT..."

            # 如果节点正在运行，首先停止节点
            echo "🛑 正在停止 GaiaNet 节点 $NODE_NUMBER..."
            stop_gaianet_node "$NODE_NUMBER" || { echo "❌ 错误：无法停止节点 $NODE_NUMBER！"; continue; }

            # 更新端口配置
            "$BASE_DIR/bin/gaianet" config --base "$BASE_DIR" --port "$PORT" || { echo "❌ 端口配置失败。"; continue; }

            # 重启节点以应用更改
            echo "🚀 使用新端口 $PORT 重启 GaiaNet 节点 $NODE_NUMBER..."
            "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" || { echo "❌ 错误：无法启动节点 $NODE_NUMBER！"; continue; }

            echo "✅ GaiaNet 节点 $NODE_NUMBER 的端口配置更新成功。"
        else
            echo "ℹ️ GaiaNet 节点 $NODE_NUMBER 未安装。正在跳过..."
        fi
    done

    echo "🎉 为所有已安装的 GaiaNet 节点更新了端口配置。"
}

# 主菜单
while true; do
    clear
    echo "==============================================================="
    echo -e "\e[1;36m🚀🚀 GAIANET 多节点安装工具包 BY GA CRYPTO 🚀🚀\e[0m"
    
    echo -e "\e[1;85m📢 保持更新：\e[0m"
    echo -e "\e[1;85m🔹 Telegram：https://t.me/GaCryptOfficial\e[0m"
    echo -e "\e[1;85m🔹 X (Twitter)：https://x.com/GACryptoO\e[0m"

    echo "==============================================================="
    echo -e "\e[1;97m✨ 您的 GPU、CPU 和 RAM 规格对最佳性能至关重要！✨\e[0m"
    echo "==============================================================="
    
    # 性能和要求部分
    echo -e "\e[1;96m⏱  每天保持您的节点活跃至少 15 - 20 小时！⏳\e[0m"
    echo -e "\e[1;91m⚠️  如果您只有 6-8GB RAM，请勿运行多个节点！❌\e[0m"
    echo -e "\e[1;94m☁️  1 个节点需要 4GB RAM，4 个节点必须有 20GB 可用 RAM ⚡\e[0m"
    echo -e "\e[1;92m💻  必须为每个节点创建一个新的 Gaia 账户并领取 500 积分 (4 个节点 = 4 个 Gaia 账户) 🟢\e[0m"
    echo "==============================================================="
    echo -e "\e[1;32m✅ 持续赚取 Gaia 积分 – 保持系统活跃以获得最大奖励！💰💰\e[0m"
    echo "==============================================================="
    
    # 菜单选项
    echo -e "\n\e[1m选择一个操作：\e[0m\n"
    echo -e "1) \e[1m☁️  安装 Gaia 节点 (VPS/无 GPU)\e[0m"
    echo -e "3) \e[1m🎮  安装 Gaia 节点 (NVIDIA GPU 台式机/笔记本电脑/VPS)\e[0m"
    echo -e "4) \e[1m🤖  开始与 AI 代理自动聊天\e[0m"
    echo -e "5) \e[1m🔍 检查是否正在与 AI 代理聊天\e[0m"
    echo -e "6) \e[1m✋  停止与 AI 代理自动聊天\e[0m"
    echo -e "7) \e[1m🔄  重启 GaiaNet 节点\e[0m"
    echo -e "8) \e[1m⏹️  停止所有 GaiaNet 节点\e[0m"
    echo -e "9) \e[1m🔍  检查您的 Gaia 节点 ID 和设备 ID\e[0m"
    echo -e "10) \e[1m📋  检查已安装和活跃的节点\e[0m"
    echo -e "0) \e[1m❌  退出安装程序\e[0m"
    echo "==============================================================="
    echo -e "11) \e[1;31m🗑️  卸载 GaiaNet 节点 (危险操作)\e[0m"
    echo "==============================================================="

    echo "==============================================================="
    echo -e "12) \e[1;34m🌐 更新所有已安装节点的端口)\e[0m"
    echo "==============================================================="

    read -rp "输入您的选择： " choice

    case $choice in
        1|2|3)
            echo "您想安装多少个节点？(1-10)"
            read -rp "输入节点数量： " NODE_COUNT

            # 验证 NODE_COUNT 的输入
            if [[ ! "$NODE_COUNT" =~ ^[1-9]$|^10$ ]]; then
                echo "❌ 无效输入。请输入 1 到 10 之间的数字。"
                exit 1
            fi

            # 检查是否有 NVIDIA GPU 并在可用时安装 CUDA
            if check_nvidia_gpu; then
                setup_cuda_env
                if ! check_cuda_installed; then
                    if ! install_cuda; then
                        echo "❌ 无法安装 CUDA。正在退出。"
                        exit 1
                    fi
                else
                    echo "⚠️ CUDA 已安装。正在跳过 CUDA 安装。"
                fi
            else
                echo "⚠️ 正在跳过 CUDA 安装（未检测到 NVIDIA GPU）。"
            fi

            # 根据系统类型和 GPU 可用性确定配置 URL
            if ! set_config_url; then
                echo "❌ 无法设置配置 URL。正在退出。"
                exit 1
            fi

            # 安装指定数量的节点
            for ((i=1; i<=NODE_COUNT; i++)); do
                if ! install_gaianet_node "$i" "$CONFIG_URL"; then
                    echo "❌ 无法安装节点 $i。正在退出。"
                    exit 1
                fi
            done

            echo "🎉 成功安装了 $NODE_COUNT 个节点！"
            ;;

        4)
            # 在启动新会话之前终止任何现有的 'gaiabot' screen 会话
            echo "🔴 正在终止任何现有的 'gaiabot' screen 会话..."
            screen -ls | awk '/[0-9]+\.gaiabot/ {print $1}' | xargs -r -I{} screen -X -S {} quit

            # 检查端口是否活跃的函数
            check_port() {
                local port=$1
                if sudo lsof -i :$port > /dev/null 2>&1; then
                    echo -e "\e[1;32m✅ 端口 $port 活跃。GaiaNet 节点正在运行。\e[0m"
                    return 0
                else
                    return 1
                fi
            }

            # 检查系统是 VPS、笔记本电脑还是台式机的函数
            check_if_vps_or_laptop() {
                echo "🔍 正在检测系统类型..."
                
                # 检查虚拟化 (VPS)
                if grep -qiE "kvm|qemu|vmware|xen|lxc" /proc/cpuinfo || grep -qiE "kvm|qemu|vmware|xen|lxc" /proc/meminfo; then
                    echo "✅ 这是一台 VPS。"
                    return 0
                # 检查电池 (笔记本电脑)
                elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
                    echo "✅ 这是一台笔记本电脑。"
                    return 1
                else
                    echo "✅ 这是一台台式机。"
                    return 2
                fi
            }

            # 主脚本逻辑
            echo "正在检测系统配置..."

            # 检查是否至少安装了一个 GaiaNet 节点
            at_least_one_node_installed=0

            for ((i=0; i<=4; i++)); do
                BASE_DIR="$HOME/gaianet$i"

                # 检查 BASE_DIR 中是否存在 gaianet 二进制文件
                if command -v "$BASE_DIR/bin/gaianet" &> /dev/null; then
                    echo -e "\e[1;32m✅ 在 $BASE_DIR/bin 中找到 GaiaNet 二进制文件。\e[0m"
                    at_least_one_node_installed=$((at_least_one_node_installed + 1))
                else
                    echo -e "\e[1;31m❌ 在 $BASE_DIR/bin 中未找到 GaiaNet 二进制文件。\e[0m"
                fi
            done

            # 如果未安装任何节点，则退出
            if [ $at_least_one_node_installed -eq 0 ]; then
                echo -e "\e[1;31m❌ 未安装任何 GaiaNet 节点。\e[0m"
                echo -e "\e[1;33m🔍 请至少安装一个节点。\e[0m"
                read -r -p "按 Enter 返回主菜单..."
                continue
            fi

            # 如果至少安装了一个节点，则继续
            echo -e "\e[1;32m✅ 至少安装了一个 GaiaNet 节点。继续进行聊天机器人设置。\e[0m"

            # 检查是否至少有一个端口是活跃的
            at_least_one_port_active=0

            echo -e "\e[1;34m🔍 正在检查端口...\e[0m"
            for ((i=1; i<=4; i++)); do
                BASE_DIR="$HOME/gaianet$i"
                PORT=$((8090 + i))

                # 检查 BASE_DIR 中是否存在 gaianet 二进制文件
                if command -v "$BASE_DIR/bin/gaianet" &> /dev/null; then
                    echo -e "\e[1;34m🔍 正在检查 $BASE_DIR 中的节点 $i，端口为 $PORT...\e[0m"
                    if check_port $PORT; then
                        at_least_one_port_active=$((at_least_one_port_active + 1))
                        echo -e "\e[1;32m✅ 节点 $i 在端口 $PORT 上运行。\e[0m"
                    else
                        echo -e "\e[1;31m❌ 节点 $i 在端口 $PORT 上未运行。\e[0m"
                    fi
                else
                    echo -e "\e[1;33m⚠️ 在 $BASE_DIR/bin 中未找到 GaiaNet 二进制文件。\e[0m"
                fi
            done

            # 如果没有活跃的端口，提供额外说明
            if [ $at_least_one_port_active -eq 0 ]; then
                echo -e "\e[1;31m❌ 未找到活跃的端口。\e[0m"
                echo -e "\e[1;33m🔗 检查节点状态是绿色还是红色：\e[1;34mhttps://www.gaianet.ai/setting/nodes\e[0m"
                echo -e "\e[1;33m🔍 如果是红色，请返回主菜单并首先重启您的 GaiaNet 节点。\e[0m"
                read -r -p "按 Enter 返回主菜单..."
                continue
            fi

            echo -e "\e[1;32m🎉 至少有一个端口是活跃的。GaiaNet 节点正在运行。\e[0m"

            # 根据系统类型确定适当的脚本
            echo "🔍 正在确定系统类型..."
            check_if_vps_or_laptop
            SYSTEM_TYPE=$?

            if [[ $SYSTEM_TYPE -eq 0 ]]; then
                script_name="gac.sh"
            elif [[ $SYSTEM_TYPE -eq 1 ]]; then
                script_name="gac.sh"
            else
                if command -v nvcc &> /dev/null || command -v nvidia-smi &> /dev/null; then
                    echo "✅ 在台式机上检测到 NVIDIA GPU。正在运行 GPU 优化的域聊天..."
                    script_name="gac.sh"
                else
                    echo "⚠️ 在台式机上未检测到 GPU。正在运行非 GPU 版本..."
                    script_name="gac.sh"
                fi
            fi

            # 在分离的 screen 会话中启动聊天机器人
            echo "🚀 在分离的 screen 会话中启动聊天机器人..."
            screen -dmS gaiabot bash -c '
            echo "🔍 正在启动聊天机器人脚本..."
            curl -O https://raw.githubusercontent.com/abhiag/Gaiatest/main/'"$script_name"' && chmod +x '"$script_name"';
            if [ -f "'"$script_name"'" ]; then
                echo "🔍 正在执行聊天机器人脚本..."
                ./'"$script_name"'
                echo "🔍 聊天机器人脚本执行完成。"
            else
                echo "❌ 错误：无法下载 '"$script_name"'"
                sleep 10
                exit 1
            fi'
            sleep 5
            screen -r gaiabot
            ;;

        5)
            echo "🔍 检查聊天机器人是否活跃..."
            select_screen_session
            ;;

        6)
            # 停止与 AI 代理自动聊天
            echo "正在停止与 AI 代理自动聊天..."
            echo "🔴 正在终止并清除所有 'gaiabot' screen 会话..."
            # 终止所有 'gaiabot' screen 会话
            screen -ls | awk '/[0-9]+\.gaiabot/ {print $1}' | xargs -r -I{} screen -X -S {} quit
            # 删除任何剩余的 'gaiabot' screen 套接字
            find /var/run/screen -type s -name "*gaiabot*" -exec sudo rm -rf {} + 2>/dev/null
            echo -e "\e[32m✅ 所有 'gaiabot' screen 会话已终止并清除。\e[0m"
            ;;

        7)
            echo "您想重启特定节点还是所有节点？"
            echo "1) 重启特定节点 (0-10)"
            echo "2) 重启所有节点 (0-10)"
            read -rp "输入您的选择 (1 或 2)： " CHOICE

            if [[ "$CHOICE" == "1" ]]; then
                echo "您想重启哪个节点？(0-10)"
                read -rp "输入节点编号： " NODE_NUMBER
                if [[ ! "$NODE_NUMBER" =~ ^[0-10]$ ]]; then
                    echo "❌ 无效输入。请输入 0 到 10 之间的数字。"
                else
                    restart_gaianet_node "$NODE_NUMBER"
                fi
            elif [[ "$CHOICE" == "2" ]]; then
                restart_gaianet_node "all"
            else
                echo "❌ 无效选择。请输入 1 或 2。"
            fi
            ;;

        8)
            echo "🛑 正在停止所有 GaiaNet 节点 (0-10)..."
            stop_gaianet_node "all"
            ;;

        9)
            display_node_info
            ;;

        10)
            # 检查已安装的节点
            check_installed_nodes
            ;;

        11)
            # 选项 11：卸载节点
            echo "您想卸载哪个节点？(0 表示默认节点，1-4 表示其他节点)"
            read -rp "输入节点编号： " NODE_NUMBER

            if [[ ! "$NODE_NUMBER" =~ ^[0-4]$ ]]; then
                echo "❌ 无效输入。请输入 0 到 4 之间的数字。"
            else
                uninstall_node_by_port "$NODE_NUMBER"
            fi
            ;;

        12)
            echo "🔄 正在为所有已安装的 GaiaNet 节点更新端口配置..."
            update_all_gaianet_ports
            ;;

        0)
            echo "正在退出..."
            exit 0
            ;;

        *)
            echo "无效选择。请重试。"
            ;;
    esac

    read -rp "按 Enter 返回主菜单..."
done
