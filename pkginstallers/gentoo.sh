#!/usr/bin/env bash

echo "-------Gentoo Automated Installer-------"
echo "You WILL be asked for your root password!"
emerge tmux cava cool-retro-term dev-lang/python:3.8 dev-python/pip dev-python/dbus-python
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
