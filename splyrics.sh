#!/bin/bash

# Configuration
CORE_DIR="$(dirname "${BASH_SOURCE[0]}")/core"
SP_MAIN_SCRIPT="splyrics-main.sh"

# Function to display help using splyrics-help.sh
show_help() {
    chmod +x "$CORE_DIR/splyrics-help.sh"
    "./$CORE_DIR/splyrics-help.sh"
}

# Function to create initial configuration
create_config() {
    mkdir -p "$HOME/.config/splyrics"
    if [ ! -f "$HOME/.config/splyrics/config.json" ]; then
        cat <<EOF > "$HOME/.config/splyrics/config.json"
{
    "defaults": "-sl",
    "sptlrx": "--current 'bold' --before '0,0,0,italic' --after '50,faint'",
    "sptlrx-cookie": ""
}
EOF
    fi
}

# Function to install splyrics system-wide using splyrics-installer.sh
install_systemwide() {
    chmod +x "$CORE_DIR/splyrics-installer.sh"
    sudo "./$CORE_DIR/splyrics-installer.sh"
    exit 0
}

# Function to check and compile packages using checker_compiler.sh
check_and_compile_packages() {
    chmod +x "$CORE_DIR/checker_compiler.sh"
    "$CORE_DIR/checker_compiler.sh" "$1"
}

# Function to handle updates by cloning from GitHub
update_splyrics() {
    echo "Updating SpLyrics from GitHub..."
    git clone https://github.com/ios7jbpro/splyrics /tmp/splyrics_temp
    rsync -a /tmp/splyrics_temp/ "$(dirname "${BASH_SOURCE[0]}")/" --exclude=splyrics
    rm -rf /tmp/splyrics_temp
    chmod +x "$(dirname "${BASH_SOURCE[0]}")/splyrics.sh"
    echo "SpLyrics updated successfully."
    exit 0
}

# Main script logic
install_systemwide=false
force_compile=false
update=false

while getopts "hsliweru" opt; do
    case ${opt} in
        h )
            show_help
            exit 0
            ;;
        s )
            enable_cava=true
            ;;
        l )
            enable_sptlrx=true
            ;;
        i )
            install_systemwide=true
            ;;
        e )
            create_config
            ${EDITOR:-nano} "$HOME/.config/splyrics/config.json"
            exit 0
            ;;
        r )
            force_compile="--force"
            ;;
        w )
            enable_song_info=true
            ;;
        u )
            update=true
            ;;
        \? )
            show_help
            exit 1
            ;;
    esac
done

if $update; then
    update_splyrics
fi

if $install_systemwide; then
    install_systemwide
fi

if [ ! -f "$HOME/.config/splyrics/config.json" ]; then
    echo "Error: Config file $HOME/.config/splyrics/config.json not found."
    exit 1
fi

check_and_compile_packages "$force_compile"

# Execute splyrics-main.sh passing all flags and options
chmod +x "$CORE_DIR/$SP_MAIN_SCRIPT"
"$CORE_DIR/$SP_MAIN_SCRIPT" "$enable_cava" "$enable_sptlrx" "$enable_song_info"
