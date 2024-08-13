#!/usr/bin/env bash

echo "---------------------------------"
echo "NixOS detected."
echo "Unfortunately, NixOS packages cannot be automated."
echo "Please install these packages, and re-run the script. The script will assume you have them in the next run."
echo "Before you do so, please absolutely make sure you have all of the packages!"
echo "Packages:"
echo "tmux"
echo "cool-retro-term"
echo "python3"
echo "pip"
echo "cava"
echo "spotify-cli-linux"
echo "---------------------------------"
cd ..
touch pkg
cd pkginstallers
exit
