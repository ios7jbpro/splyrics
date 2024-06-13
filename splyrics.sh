#!/bin/bash

CONFIG_DIR="$HOME/.config/splyrics"
CONFIG_FILE="$CONFIG_DIR/config.json"

show_help() {
    echo "SpLyrics"
    echo "A bundled script that displays stuff about Spotify"
    echo ""
    echo "Usage: $0 [-h] [-s] [-l] [-i] [-e] [-r] [-w]"
    echo ""
    echo "Options:"
    echo "  -h      Show this help message"
    echo "  -s      Enable the cava tmux panel (right-bottom)"
    echo "  -l      Enable the sptlrx panel (left)"
    echo "  -i      Install (or update if already installed) the script system-wide"
    echo "  -e      Edit the config file"
    echo "  -r      Recompile the packages even if they already exist (no script execution)"
    echo "  -w      Display song information instead of spotifycli in the top-right panel"
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

compile_package() {
    local package_name=$1
    chmod +x "${package_name}compiler.sh"
    ./"${package_name}compiler.sh"
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

enable_sptlrx=false
enable_cava=false
enable_song_info=false
install_systemwide=false
recompile_packages=false

while getopts "hsliwer" opt; do
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
        \? )
            show_help
            exit 1
            ;;
    esac
done

if $install_systemwide; then
    script_path=$(realpath "$0")
    sudo cp "$script_path" /usr/local/bin/splyrics
    sudo chmod +x /usr/local/bin/splyrics
    echo "SpLyrics installed (or updated) successfully. You can now run the script using 'splyrics'."
    exit 0
fi

if ! command -v tmux &> /dev/null || $recompile_packages; then
    echo "tmux could not be found or recompilation requested. Trying to compile it..."
    compile_package "tmux"
fi

if $enable_sptlrx && (! command -v sptlrx &> /dev/null || $recompile_packages); then
    echo "sptlrx could not be found or recompilation requested. Trying to compile it..."
    compile_package "sptlrx"
fi

if ! command -v spotifycli &> /dev/null || $recompile_packages; then
    echo "spotifycli could not be found or recompilation requested. Trying to compile it..."
    compile_package "spotifycli"
fi

if $enable_cava && (! command -v cava &> /dev/null || $recompile_packages); then
    echo "cava could not be found or recompilation requested. Trying to compile it..."
    compile_package "cava"
fi

if $recompile_packages; then
    echo "Packages recompiled successfully. Use the appropriate flags to run the script."
    exit 0
fi

if [ -f "$CONFIG_FILE" ]; then
    config_defaults=$(jq -r '.defaults' "$CONFIG_FILE")
    config_sptlrx=$(jq -r '.sptlrx' "$CONFIG_FILE")
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
else
    tmux send-keys -t "$session_name" "clear && spotifycli" C-m
    tmux send-keys -t "$session_name" "play" C-m
fi

spotifycli_pane=$(tmux display-message -p -t "$session_name:0.1" "#{pane_id}")

if $enable_cava; then
    tmux split-window -v -t "$spotifycli_pane"
    tmux send-keys -t "$session_name" "clear && cava" C-m
fi

tmux select-pane -t "$spotifycli_pane"

tmux set-option -t "$session_name" remain-on-exit on
tmux set-option -t "$session_name" destroy-unattached off
tmux set-hook -t "$session_name" pane-died "run-shell 'tmux kill-session -t \"$session_name\"'"

tmux attach -t "$session_name"
