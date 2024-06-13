#!/bin/bash

install_tmux_apt() {
    sudo apt update
    sudo apt install -y tmux
}

install_tmux_yum() {
    sudo yum install -y tmux
}

install_tmux_dnf() {
    sudo dnf install -y tmux
}

install_tmux_pacman() {
    sudo pacman -Syu tmux
}

distribution_supported=false

if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
        ubuntu|debian)
            install_tmux_apt && distribution_supported=true
            ;;
        fedora)
            install_tmux_dnf && distribution_supported=true
            ;;
        centos|rhel)
            install_tmux_yum && distribution_supported=true
            ;;
        arch)
            install_tmux_pacman && distribution_supported=true
            ;;
        *)
            ;;
    esac

    if ! $distribution_supported; then
        # Attempt installation using fallback method if distribution is derived or unknown
        echo "Attempting fallback installation method..."
        if install_tmux_apt || install_tmux_dnf || install_tmux_yum || install_tmux_pacman; then
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

echo "tmux installation completed."

