#!/bin/bash

install_dependencies_apt() {
    sudo apt update
    sudo apt install -y build-essential libfftw3-dev libasound2-dev libpulse-dev \
                        libtool automake autoconf-archive libiniparser-dev \
                        libsdl2-2.0-0 libsdl2-dev libpipewire-0.3-dev \
                        libjack-jackd2-dev pkgconf
}

install_dependencies_pacman() {
    sudo pacman -Syu --needed base-devel fftw alsa-lib iniparser pulseaudio \
                          autoconf-archive pkgconf
}

install_dependencies_dnf() {
    sudo dnf install -y alsa-lib-devel fftw3-devel pulseaudio-libs-devel \
                        libtool autoconf-archive iniparser-devel pkgconf
}

distribution_supported=false

if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
        ubuntu|debian)
            install_dependencies_apt && distribution_supported=true
            ;;
        fedora)
            install_dependencies_dnf && distribution_supported=true
            ;;
        arch)
            install_dependencies_pacman && distribution_supported=true
            ;;
        *)
            ;;
    esac

    if ! $distribution_supported; then
        echo "Unsupported distribution: $ID"
        exit 1
    fi
else
    echo "Cannot determine the Linux distribution."
    exit 1
fi

# Compile and install cava
echo "Compiling and installing cava..."
git clone https://github.com/karlstav/cava
cd cava
./autogen.sh
./configure
make
sudo make install
cd ..

# Reinstall cava from repositories
echo "Reinstalling cava from repositories..."
case $ID in
    ubuntu|debian)
        sudo apt install --reinstall cava
        ;;
    fedora)
        sudo dnf reinstall cava
        ;;
    arch)
        sudo pacman -Syu cava
        ;;
    *)
        echo "Unsupported distribution: $ID"
        exit 1
        ;;
esac

echo "cava installation completed."

