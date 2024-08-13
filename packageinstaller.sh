#!/usr/bin/env bash

# Pattern to search for
pattern="*_distro"

# Check for files matching the pattern
matching_files=$(ls $pattern 2>/dev/null)

# If files matching the pattern are found
if [ -n "$matching_files" ]; then
    echo "Matching files found:"
    echo "$matching_files"

    # Determine which file is present and act accordingly
    for file in $matching_files; do
        case "$file" in
            *ubuntu_distro)
                echo "Ubuntu distribution detected"
                distro="ubuntu"
                ;;
            *debian_distro)
                echo "Debian distribution detected"
                distro="debian"
                ;;
            *pop!_os_distro)
                echo "Pop!_OS distribution detected"
                distro="pop!_os"
                ;;
            *gentoo_distro)
                echo "Gentoo distribution detected"
                distro="gentoo"
                ;;
            *arch_distro)
                echo "Arch distribution detected"
                distro="arch"
                ;;
            *nixos_distro)
                echo "NixOS distribution detected"
                distro="nixos"
                ;;
            # Add more patterns as needed
            *)
                echo "Unknown distribution."
                ;;
        esac
    done
else
    echo "No files matching the pattern were found! Did you break the data structure?"
fi

cd pkginstallers
chmod +x *.sh

if [ "$distro" == "ubuntu" ]; then
   echo "Running ubuntu installer"
   ./ubuntu.sh
fi
if [ "$distro" == "pop!_os" ]; then
   echo "Running popos installer"
   ./ubuntu.sh
fi
if [ "$distro" == "debian" ]; then
   echo "Running debian installer"
   ./debian.sh
fi
if [ "$distro" == "gentoo" ]; then
   echo "Running gentoo installer"
   ./gentoo.sh
fi
if [ "$distro" == "arch" ]; then
   echo "Running arch installer"
   ./arch.sh
fi
if [ "$distro" == "nixos" ]; then
   echo "Running nixos installer"
   ./nixos.sh
fi

cd ..
