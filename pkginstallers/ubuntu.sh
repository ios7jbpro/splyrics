#!/usr/bin/env bash

echo "---------------------------------"
echo "Ubuntu Package Installer"
echo "Installing the required packages"
sudo apt install -y tmux cava cool-retro-term python3 python3-pip
echo "!!! PLEASE READ THIS SECTION !!!"
echo "Script will now is going to run:"
echo "pip install spotify-cli-linux --break-system-packages"
echo " "
echo "This might HARM OR BREAK YOUR SYSTEM!!!"
echo "If you want to still proceed, press enter."
echo "If you want to cancel, do ^C right now."
read
pip install spotify-cli-linux --break-system-packages
echo "Installation complete"
echo "---------------------------------"
cd ..
touch pkg
cd pkginstallers
exit
