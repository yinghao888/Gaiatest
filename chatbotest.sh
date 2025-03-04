#!/bin/bash

# Check for existing API keys
API_KEY_DIR="/root/.gaianet_keys"
mkdir -p "$API_KEY_DIR"

EXISTING_KEYS=($(find "$API_KEY_DIR" -type f 2>/dev/null))

if [ ${#EXISTING_KEYS[@]} -gt 0 ]; then
    echo "Available API key files:"
    select KEY_FILE in "${EXISTING_KEYS[@]}" "Enter a new API key"; do
        if [[ "$KEY_FILE" == "Enter a new API key" ]]; then
            break
        elif [[ -n "$KEY_FILE" ]]; then
            API_KEY=$(cat "$KEY_FILE")
            echo "Using API key from: $KEY_FILE"
            VALID_KEY=true
            break
        else
            echo "Invalid selection. Try again."
        fi
    done
fi

# If no valid key was selected, ask for a new one
if [ -z "$API_KEY" ] || [ "$VALID_KEY" != "true" ]; then
    while true; do
        read -p "Enter your GaiaNet API Key: " API_KEY
        echo

        if [ -z "$API_KEY" ]; then
            echo "❌ Error: API Key is required!"
            echo "🔄 Restarting the installer..."

            # Restart the installer (only if running from gaiainstaller.sh)
            if [[ $0 == *gaiainstaller.sh ]]; then
                rm -rf ~/gaiainstaller.sh
                curl -O https://raw.githubusercontent.com/yinghao888/Gaiatest/main/gaiainstaller.sh
                chmod +x gaiainstaller.sh
                exec ./gaiainstaller.sh
            else
                exit 1
            fi
        else
            break
        fi
    done

    # Save the new API key
    read -p "Enter a name for the API key file: " FILE_NAME
    API_KEY_FILE="$API_KEY_DIR/$FILE_NAME"

    echo "$API_KEY" > "$API_KEY_FILE"
    chmod 600 "$API_KEY_FILE"
    echo "API Key saved as $API_KEY_FILE."
fi

echo "Starting GaiaNet with API Key: $API_KEY"

# Function to check if NVIDIA CUDA or GPU is present
check_cuda() {
    if command -v nvcc &> /dev/null || command -v nvidia-smi &> /dev/null; then
        echo "✅ NVIDIA GPU with CUDA detected."
        return 0
    else
        echo "❌ NVIDIA GPU Not Found."
        return 1
    fi
}

# Function to check if the system is a VPS, Laptop, or Desktop
check_system_type() {
    vps_type=$(systemd-detect-virt)
    if echo "$vps_type" | grep -qiE "kvm|qemu|vmware|xen|lxc"; then
        echo "✅ This is a VPS."
        return 0
    elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
        echo "✅ This is a Laptop."
        return 1
    else
        echo "✅ This is a Desktop."
        return 2
    fi
}

# Function to set the API URL based on system type and CUDA presence
set_api_url() {
    check_system_type
    system_type=$?

    check_cuda
    cuda_present=$?

    API_URL="https://gaias.gaia.domains/v1/chat/completions"
    API_NAME="Gaias"

    echo "🔗 Using API: ($API_NAME)"
}

set_api_url

# Check if jq is installed, and if not, install it
if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Installing jq..."
    sudo apt update && sudo apt install jq -y
    if [ $? -eq 0 ]; then
        echo "✅ jq installed successfully!"
    else
        echo "❌ Failed to install jq. Please install jq manually and re-run the script."
        exit 1
    fi
else
    echo "✅ jq is already installed."
fi
