#!/bin/bash

# Function to show help using splyrics-help.sh
show_help() {
    chmod +x core/splyrics-help.sh
    ./core/splyrics-help.sh
}

# Function to create configuration if it doesn't exist
create_config() {
    CONFIG_DIR="$HOME/.config/splyrics"
    CONFIG_FILE="$CONFIG_DIR/config.json"

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

# Function to compile packages
compile_package() {
    local package_name=$1
    chmod +x "compilers/${package_name}compiler.sh"
    ./compilers/"${package_name}compiler.sh"
}

# Function to check sptlrx cookie and handle if missing
check_sptlrx_cookie() {
    local config_file=$1
    local sptlrx_cookie=$(jq -r '.["sptlrx-cookie"]' "$config_file")
    if [ -z "$sptlrx_cookie" ]; then
        echo "Error: --cookie option is required in the sptlrx section of $CONFIG_FILE"
        echo "Running checksptlrx.sh to handle this issue..."
        chmod +x checksptlrx.sh
        ./checksptlrx.sh
        exit 1
    fi
}

# Main script starts here

# Ensure config exists and load defaults
create_config

# Load configuration from file
CONFIG_FILE="$HOME/.config/splyrics/config.json"
if [ -f "$CONFIG_FILE" ]; then
    config_defaults=$(jq -r '.defaults' "$CONFIG_FILE")
    config_sptlrx=$(jq -r '.sptlrx' "$CONFIG_FILE")
else
    echo "Error: Config file $CONFIG_FILE not found."
    exit 1
fi

# Check if sptlrx-cookie is set in config
check_sptlrx_cookie "$CONFIG_FILE"

# Example: Setting flags based on command line arguments
enable_cava=false
enable_sptlrx=false
enable_song_info=false

while getopts "sliw" opt; do
    case ${opt} in
        s )
            enable_cava=true
            ;;
        l )
            enable_sptlrx=true
            ;;
        i )
            # Installer logic goes here
            ;;
        w )
            enable_song_info=true
            ;;
        \? )
            show_help
            exit 1
            ;;
    esac
done

# Example: Compiling packages if necessary
if ! command -v tmux &> /dev/null; then
    echo "tmux could not be found. Trying to compile it..."
    compile_package "tmux"
fi

if $enable_sptlrx && (! command -v sptlrx &> /dev/null); then
    echo "sptlrx could not be found. Trying to compile it..."
    compile_package "sptlrx"
fi

if ! command -v spotifycli &> /dev/null; then
    echo "spotifycli could not be found. Trying to compile it..."
    compile_package "spotifycli"
fi

if $enable_cava && (! command -v cava &> /dev/null); then
    echo "cava could not be found. Trying to compile it..."
    compile_package "cava"
fi

# Example: Starting tmux session with configured panes
session_name="splyrics_$(date +%s)"
tmux new-session -d -s "$session_name"

if $enable_sptlrx; then
    tmux send-keys -t "$session_name" "clear && sptlrx $config_sptlrx --cookie '$sptlrx_cookie'" C-m
    tmux split-window -h -t "$session_name"
fi

if $enable_song_info; then
    tmux send-keys -t "$session_name" "watch -t -n 1 \"echo Song: && spotifycli --statusposition && echo Album: && spotifycli --album && echo Artist: && spotifycli --artist\"" C-m
    tmux split-window -v -t "$session_name:0.1"
    tmux send-keys -t "$session_name" "clear && spotifycli" C-m
    tmux select-pane -t "$session_name:0.2"
else
    tmux send-keys -t "$session_name" "clear && spotifycli" C-m
    tmux select-pane -t "$session_name:0.1"
fi

spotifycli_pane=$(tmux display-message -p -t "$session_name:0.1" "#{pane_id}")

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

tmux set-option -t "$session_name" remain-on-exit on
tmux set-option -t "$session_name" destroy-unattached off
tmux set-hook -t "$session_name" pane-died "run-shell 'tmux kill-session -t \"$session_name\"'"

tmux attach -t "$session_name"
