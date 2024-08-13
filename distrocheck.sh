#!/usr/bin/env bash

chmod +x *.sh
echo "---------------------------------"
echo "You can pass -s to skip package checks"
echo "---------------------------------"

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "Distribution: $NAME"
        touch "$NAME distro"
        filename="$NAME distro"
    elif [ -f /etc/debian_version ]; then
        echo "Debian-based distribution"
        touch "Debian distro"
        filename="Debian distro"
    elif [ -f /etc/redhat-release ]; then
        echo "Red Hat-based distribution"
       touch "Red Hat distro"
       filename="Red Hat distro"
    elif [ -f /etc/arch-release ]; then
        echo "Arch-based distribution"
        touch "Arch distro"
        filename="Arch distro"
    elif command -v lsb_release &> /dev/null; then
        lsb_release -a
    else
        echo "Distribution not identified, please create an issue for this"
    fi
    
    # Convert filename to lowercase
    new_name=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    mv "$filename" "$new_name"

    # Destroy spaces
    mv "$new_name" "$(echo "$new_name" | tr ' ' '_')"
    ./packageinstaller.sh
}

detect_distro


