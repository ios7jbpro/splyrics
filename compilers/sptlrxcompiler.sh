#!/bin/bash

if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
        arch)
            echo "Installing sptlrx for Arch Linux using yay..."
            yay -S --needed --noconfirm sptlrx-bin
            ;;
        *)
            echo "Installing sptlrx for other distributions..."
            curl -sSL https://instl.sh/raitonoberu/sptlrx/linux | bash
            ;;
    esac
else
    echo "Cannot determine the Linux distribution."
    exit 1
fi

echo "sptlrx installation completed."

