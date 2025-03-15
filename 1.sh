

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
#                🚀 此脚本由 **@nhxao** 骄傲地创建！🚀                 
#                                                                                        
#             🌐 加入我们在去中心化网络和加密创新中的革命！ 🌐             
#                                                                                                                                                                                                  
##########################################################################################

# 用于广告的绿色
GREEN="\033[0;32m"
RESET="\033[0m"

# 确保安装所需的软件包
echo "📦 正在安装依赖项..."
sudo apt update -y && sudo apt install -y pciutils libgomp1 curl wget build-essential libglvnd-dev pkg-config libopenblas-dev libomp-dev
sudo apt upgrade -y && sudo apt update

# 检测是否在 WSL 环境中运行
IS_WSL=false
if grep -qi microsoft /proc/version; then
    IS_WSL=true
    echo "🖥️ 在 WSL 环境中运行。"
else
    echo "🖥️ 在原生 Ubuntu 系统上运行。"
fi

# 检查是否存在 NVIDIA GPU
check_nvidia_gpu() {
    if command -v nvidia-smi &> /dev/null || lspci | grep -i nvidia &> /dev/null; then
        echo "✅ 检测到 NVIDIA GPU。"
        return 0
    else
        echo "⚠️ 未找到 NVIDIA GPU。"
        return 1
    fi
}

# 检查系统类型是 VPS、笔记本电脑还是台式机
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

# 使用适当的 CUDA 支持安装 GaiaNet
install_gaianet() {
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep 'release' | awk '{print $6}' | cut -d',' -f1 | sed 's/V//g' | cut -d'.' -f1)
        echo "✅ 检测到 CUDA 版本：$CUDA_VERSION"
        if [[ "$CUDA_VERSION" == "11" || "$CUDA_VERSION" == "12" ]]; then
            echo "🔧 使用 ggmlcuda $CUDA_VERSION 安装 GaiaNet..."
            curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.21/install.sh' -o install.sh
            chmod +x install.sh
            ./install.sh --ggmlcuda $CUDA_VERSION || { echo "❌ 使用 CUDA 安装 GaiaNet 失败。"; exit 1; }
            return
        fi
    fi
    echo "⚠️ 不使用 GPU 支持安装 GaiaNet..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' | bash || { echo "❌ 不使用 GPU 安装 GaiaNet 失败。"; exit 1; }
}

# 将 GaiaNet 添加到 PATH
add_gaianet_to_path() {
    echo 'export PATH=$HOME/gaianet/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
}

# 主逻辑
if check_nvidia_gpu; then
    if ! setup_cuda_env; then
        echo "⚠️ CUDA 环境未设置。正在检查是否已安装 CUDA..."
        if check_cuda_installed; then
            echo "⚠️ CUDA 已安装但未正确设置。请修复 CUDA 环境。"
        else
            echo "CUDA 未安装。正在安装 CUDA..."
            if install_cuda; then
                echo "✅ CUDA 安装成功。"
                setup_cuda_env
            else
                echo "❌ 无法安装 CUDA。正在退出。"
                exit 1
            fi
        fi
    else
        echo "✅ CUDA 环境已设置。"
    fi
fi

# 安装 GaiaNet
install_gaianet

# 验证 GaiaNet 安装
if [ -f ~/gaianet/bin/gaianet ]; then
    echo "✅ GaiaNet 安装成功。"
    add_gaianet_to_path
else
    echo "❌ GaiaNet 安装失败。正在退出。"
    exit 1
fi

# 确定系统类型并设置配置 URL
check_system_type
SYSTEM_TYPE=$?  # 捕获 check_system_type 的返回值

if [[ $SYSTEM_TYPE -eq 0 ]]; then
    # VPS
    CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/Hyper_3.2-3B.json"
elif [[ $SYSTEM_TYPE -eq 1 ]]; then
    # 笔记本电脑
    if ! check_nvidia_gpu; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/Hyper_3.2-3B.json"
    else
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/Soneium2.5-0.5B.json"
    fi
elif [[ $SYSTEM_TYPE -eq 2 ]]; then
    # 台式机
    if ! check_nvidia_gpu; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/Hyper_3.2-3B.json"
    else
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/gadao3.2_1B.json"
    fi
fi

# 初始化并启动 GaiaNet
echo "⚙️ 正在初始化 GaiaNet..."
~/gaianet/bin/gaianet init --config "$CONFIG_URL" || { echo "❌ GaiaNet 初始化失败！"; exit 1; }

echo "🚀 正在启动 GaiaNet 节点..."
~/gaianet/bin/gaianet config --domain gaia.domains
~/gaianet/bin/gaianet start || { echo "❌ 错误：无法启动 GaiaNet 节点！"; exit 1; }

echo "🔍 正在获取 GaiaNet 节点信息..."
~/gaianet/bin/gaianet info || { echo "❌ 错误：无法获取 GaiaNet 节点信息！"; exit 1; }

# 结束消息
echo "==========================================================="
echo "🎉 恭喜！您的 GaiaNet 节点已成功设置！"
echo "💪 让我们一起构建去中心化网络的未来！"
echo "===========================================================" 

