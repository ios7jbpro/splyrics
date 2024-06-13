#!/bin/bash

install_python3_apt() {
    sudo apt update
    sudo apt install -y python3 python3-pip
}

install_python3_yum() {
    sudo yum install -y python3 python3-pip
}

install_python3_dnf() {
    sudo dnf install -y python3 python3-pip
}

install_python3_pacman() {
    sudo pacman -Syu python python-pip
}

distribution_supported=false

if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
        ubuntu|debian)
            install_python3_apt && distribution_supported=true
            ;;
        fedora)
            install_python3_dnf && distribution_supported=true
            ;;
        centos|rhel)
            install_python3_yum && distribution_supported=true
            ;;
        arch)
            install_python3_pacman && distribution_supported=true
            ;;
        *)
            ;;
    esac

    if ! $distribution_supported; then
        # Attempt installation using fallback method if distribution is derived or unknown
        echo "Attempting fallback installation method..."
        if install_python3_apt || install_python3_dnf || install_python3_yum || install_python3_pacman; then
            distribution_supported=true
        fi
    fi

    if ! $distribution_supported; then
        echo "Unsupported distribution: $ID"
        exit 1
    fi
else
    echo "Cannot determine the Linux distribution."
    exit 1
fi

# Install pip packages
echo "Installing required Python packages..."
sudo pip install lyricwikia
sudo pip install spotify-cli-linux 

echo "Installation of Python packages completed."

