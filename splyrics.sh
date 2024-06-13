#!/bin/bash

# Configuration
CONFIG_DIR="$HOME/.config/splyrics"
CONFIG_FILE="$CONFIG_DIR/config.json"
CORE_DIR="$(dirname "${BASH_SOURCE[0]}")/core"
INSTALLER_SCRIPT="splyrics-installer.sh"
HELP_SCRIPT="${CORE_DIR}/splyrics-help.sh"
CHECKER_COMPILER_SCRIPT="${CORE_DIR}/checker_compiler.sh"

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

# Function to install splyrics system-wide using splyrics-installer.sh
install_systemwide() {
    chmod +x "$INSTALLER_SCRIPT"
    sudo "$INSTALLER_SCRIPT"
    exit 0
}

# Function to check and compile packages using checker_compiler.sh
check_and_compile_packages() {
    chmod +x "$CHECKER_COMPILER_SCRIPT"
    "$CHECKER_COMPILER_SCRIPT" "$1"
}

# Function to handle updates by cloning from GitHub
update_splyrics() {
    echo "Updating SpLyrics from GitHub..."
    git clone https://github.com/ios7jbpro/splyrics /tmp/splyrics_temp
    rsync -a /tmp/splyrics_temp/ "$(dirname "${BASH_SOURCE[0]}")/" --exclude=splyrics
    rm -rf /tmp/splyrics_temp
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
            ${EDITOR:-nano} "$CONFIG_FILE"
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

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file $CONFIG_FILE not found."
    exit 1
fi

check_and_compile_packages "$force_compile"

# Continue with the rest of your script logic...
# Replace or add any necessary functionality here based on your requirements.

# Example tmux session initialization (replace with your actual logic)
session_name="splyrics_$(date +%s)"
tmux new-session -d -s "$session_name"

if $enable_sptlrx; then
    tmux send-keys -t "$session_name" "clear && sptlrx $config_sptlrx $sptlrx_cookie" C-m
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
