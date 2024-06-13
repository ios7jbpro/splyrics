#!/bin/bash

# Define script version
SCRIPT_VERSION="1.0"

# GitHub repository URL for updates
REPO_URL="https://github.com/ios7jbpro/splyrics"

CONFIG_DIR="$HOME/.config/splyrics"
CONFIG_FILE="$CONFIG_DIR/config.json"

show_help() {
    chmod +x core/splyrics-help.sh
    ./core/splyrics-help.sh
}

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

run_checker_compiler() {
    local force_flag=""
    if $recompile_packages; then
        force_flag="--force"
    fi
    chmod +x core/checker_compiler.sh  # Ensure checker_compiler.sh is executable
    ./core/checker_compiler.sh $force_flag
}

check_sptlrx_cookie() {
    local config_file=$1
    local sptlrx_cookie=$(jq -r '.["sptlrx-cookie"]' "$config_file")
    if [ -z "$sptlrx_cookie" ]; then
        echo "Error: --cookie option is required in the sptlrx section of $CONFIG_FILE"
        echo "Running checksptlrx.sh to handle this issue..."
        chmod +x checksptlrx.sh  # Ensure checksptlrx.sh is executable
        ./checksptlrx.sh
        exit 1
    fi
}

update_script() {
    echo "Updating script from $REPO_URL..."
    # Clone the repository to a temporary directory
    tmp_dir=$(mktemp -d)
    git clone "$REPO_URL" "$tmp_dir"
    
    # Copy new script and files from the cloned repository
    cp -rf "$tmp_dir"/* ./
    
    # Clean up temporary directory
    rm -rf "$tmp_dir"
    
    echo "Script updated successfully!"
    exit 0
}

enable_sptlrx=false
enable_cava=false
enable_song_info=false
install_systemwide=false
recompile_packages=false
do_update=false

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
            run_checker_compiler
            exit 0
            ;;
        w )
            enable_song_info=true
            ;;
        u )
            do_update=true
            ;;
        \? )
            show_help
            exit 1
            ;;
    esac
done

if $do_update; then
    update_script
fi

if $install_systemwide; then
    chmod +x splyrics-installer.sh
    ./splyrics-installer.sh
    exit 0
fi

run_checker_compiler


if [ -f "$CONFIG_FILE" ]; then
    config_defaults=$(jq -r '.defaults' "$CONFIG_FILE")
    config_sptlrx=$(jq -r '.sptlrx' "$CONFIG_FILE")
    sptlrx_cookie=$(jq -r '.["sptlrx-cookie"]' "$CONFIG_FILE")
    check_sptlrx_cookie "$CONFIG_FILE"
else
    echo "Error: Config file $CONFIG_FILE not found."
    exit 1
fi

if [ $OPTIND -eq 1 ]; then
    for flag in $(echo $config_defaults | sed -e 's/./& /g'); do
        case "$flag" in
            s ) enable_cava=true ;;
            l ) enable_sptlrx=true ;;
        esac
    done
fi

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
