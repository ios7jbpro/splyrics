#!/bin/bash

# Configuration variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/splyrics"
CONFIG_FILE="$CONFIG_DIR/config.json"
INSTALL_DIR="/usr/local/bin"
MAIN_SCRIPT="splyrics.sh"
INSTALLER_SCRIPT="splyrics-installer.sh"
HELP_SCRIPT="$SCRIPT_DIR/core/splyrics-help.sh"
COMPILER_SCRIPT="$SCRIPT_DIR/core/checker_compiler.sh"
GITHUB_REPO="https://github.com/ios7jbpro/splyrics"

# Function to display help using splyrics-help.sh
show_help() {
    chmod +x "$HELP_SCRIPT"
    "$HELP_SCRIPT"
}

# Function to create initial configuration
create_config() {
    mkdir -p "$CONFIG_DIR"
    if [ ! -f "$CONFIG_FILE" ]; then
        cat <<EOF > "$CONFIG_FILE"
{
    "defaults": "-sl",
    "sptlrx": "--current 'bold' --before '0,0,0,italic' --after '50,faint'",
    "sptlrx-cookie": ""
}
EOF
    fi
}

# Function to compile or recompile packages
compile_packages() {
    local force_compile=$1
    chmod +x "$COMPILER_SCRIPT"
    "$COMPILER_SCRIPT" "$force_compile"
}

# Function to check sptlrx cookie from config
check_sptlrx_cookie() {
    local config_file=$1
    local sptlrx_cookie=$(jq -r '.["sptlrx-cookie"]' "$config_file")
    if [ -z "$sptlrx_cookie" ]; then
        echo "Error: --cookie option is required in the sptlrx section of $CONFIG_FILE"
        echo "Running checksptlrx.sh to handle this issue..."
        chmod +x "$SCRIPT_DIR/checksptlrx.sh"
        "$SCRIPT_DIR/checksptlrx.sh"
        exit 1
    fi
}

# Flags initialization
enable_sptlrx=false
enable_cava=false
enable_song_info=false
install_systemwide=false
recompile_packages=false
update_script=false

# Parse command line options
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
            ${EDITOR:-nano} "$CONFIG_FILE"
            exit 0
            ;;
        r )
            recompile_packages=true
            ;;
        w )
            enable_song_info=true
            ;;
        u )
            update_script=true
            ;;
        \? )
            show_help
            exit 1
            ;;
    esac
done

# Handle script installation system-wide
if $install_systemwide; then
    chmod +x "$INSTALLER_SCRIPT"
    "$INSTALLER_SCRIPT"
    exit 0
fi

# Check for required dependencies or recompile if requested
if ! command -v tmux &> /dev/null || $recompile_packages; then
    echo "tmux could not be found or recompilation requested. Trying to compile it..."
    compile_packages "$recompile_packages"
fi

if $enable_sptlrx && (! command -v sptlrx &> /dev/null || $recompile_packages); then
    echo "sptlrx could not be found or recompilation requested. Trying to compile it..."
    compile_packages "$recompile_packages"
fi

if ! command -v spotifycli &> /dev/null || $recompile_packages; then
    echo "spotifycli could not be found or recompilation requested. Trying to compile it..."
    compile_packages "$recompile_packages"
fi

if $enable_cava && (! command -v cava &> /dev/null || $recompile_packages); then
    echo "cava could not be found or recompilation requested. Trying to compile it..."
    compile_packages "$recompile_packages"
fi

# Handle recompilation of packages
if $recompile_packages; then
    echo "Packages recompiled successfully. Use the appropriate flags to run the script."
    exit 0
fi

# Load configuration from file
if [ -f "$CONFIG_FILE" ]; then
    config_defaults=$(jq -r '.defaults' "$CONFIG_FILE")
    config_sptlrx=$(jq -r '.sptlrx' "$CONFIG_FILE")
    sptlrx_cookie=$(jq -r '.["sptlrx-cookie"]' "$CONFIG_FILE")
    check_sptlrx_cookie "$CONFIG_FILE"
else
    echo "Error: Config file $CONFIG_FILE not found."
    exit 1
fi

# Set up tmux session
session_name="splyrics_$(date +%s)"
tmux new-session -d -s "$session_name"

# Enable sptlrx panel if requested
if $enable_sptlrx; then
    tmux send-keys -t "$session_name" "clear && sptlrx $config_sptlrx $sptlrx_cookie" C-m
    tmux split-window -h -t "$session_name"
fi

# Enable song information panel if requested
if $enable_song_info; then
    tmux send-keys -t "$session_name" "watch -t -n 1 \"echo Song: && spotifycli --statusposition && echo Album: && spotifycli --album && echo Artist: && spotifycli --artist\"" C-m
    tmux split-window -v -t "$session_name:0.1"
    tmux send-keys -t "$session_name" "clear && spotifycli" C-m
    tmux select-pane -t "$session_name:0.2"
else
    tmux send-keys -t "$session_name" "clear && spotifycli" C-m
    tmux select-pane -t "$session_name:0.1"
fi

# Determine Spotify CLI pane ID for later use
spotifycli_pane=$(tmux display-message -p -t "$session_name:0.1" "#{pane_id}")

# Enable cava panel if requested
if $enable_cava; then
    if $enable_song_info; then
        tmux split-window -v -t "$session_name:0.2"
    else
        tmux split-window -v -t "$session_name:0.1"
    fi
    tmux send-keys -t "$session_name" "clear && cava" C-m
fi

# Ensure the new spotifycli pane is selected when -w is passed
if $enable_song_info; then
    tmux select-pane -t "$session_name:0.2"
else
    tmux select-pane -t "$spotifycli_pane"
fi

# Configure tmux session options
tmux set-option -t "$session_name" remain-on-exit on
tmux set-option -t "$session_name" destroy-unattached off
tmux set-hook -t "$session_name" pane-died "run-shell 'tmux kill-session -t \"$session_name\"'"

# Attach to tmux session
tmux attach -t "$session_name"

# Handle script update from GitHub repository
if $update_script; then
    echo "Updating script from GitHub..."
    git clone --depth=1 "$GITHUB_REPO" "$SCRIPT_DIR"
    echo "Update complete. Please restart the script."
    exit 0
fi
