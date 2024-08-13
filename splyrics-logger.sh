#!/usr/bin/env bash

echo "Dumping machine data"
neofetch >> log.txt
lspci -k >> log.txt
whoami >> log.txt
uname -a >> log.txt
echo "Logging the main script"
chmod +x *.sh
./splyrics.sh $1 >> log.txt
