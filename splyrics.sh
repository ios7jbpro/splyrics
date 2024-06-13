#!/bin/bash

CONFIG_DIR="$HOME/.config/splyrics"
CONFIG_FILE="$CONFIG_DIR/config.json"

show_help() {
    echo "SpLyrics"
    echo "A bundled script that displays stuff about Spotify"
    echo ""
    echo "Usage: $0 [-h] [-s] [-c] [-l] [-i] [-e] [-r]"
    echo ""
    echo "Options:"
    echo "  -h    Show this help message"
    echo "  -s    Enable the cava tmux panel"
    echo "  -c    Enable the echoing credits"
    echo "  -l    Enable the sptlrx panel"
    echo "  -i    Install (or update if already installed) the script system-wide"
    echo "  -e    Edit the config file"
    echo "  -r    Recompile the packages even if they already exist (no script execution)"
}

create_config() {
    mkdir -p "$CONFIG_DIR"
    if [ ! -f "$CONFIG_FILE" ]; then
        cat <<EOF > "$CONFIG_FILE"
{
    "defaults": "-sl",
    "sptlrx": "--current 'bold' --before '0,0,0,italic' --after '50,faint'"
}
EOF
    fi
}

compile_package() {
    local package_name=$1
    chmod +x "${package_name}compiler.sh"
    ./"${package_name}compiler.sh"
}

check_sptlrx() {
    local config_file=$1
    local has_cookie=$(jq -r '.sptlrx | contains("--cookie")' "$config_file")
    if [ "$has_cookie" != "true" ]; then
        echo "Error: --cookie option is required in the sptlrx section of $CONFIG_FILE"
        echo "Running checksptlrx.sh to handle this issue..."
        chmod +x checksptlrx.sh  # Ensure checksptlrx.sh is executable
        ./checksptlrx.sh
        exit 1
    fi
}

enable_sptlrx=false
enable_cava=false
enable_credits=false
install_systemwide=false
recompile_packages=false

while getopts "hsclier" opt; do
    case ${opt} in
        h )
            show_help
            exit 0
            ;;
        s )
            enable_cava=true
            ;;
        c )
            enable_credits=true
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
    check_sptlrx "$CONFIG_FILE"
else
    echo "Error: Config file $CONFIG_FILE not found."
    exit 1
fi

if [ $OPTIND -eq 1 ]; then
    for flag in $(echo $config_defaults | sed -e 's/./& /g'); do
        case "$flag" in
            s ) enable_cava=true ;;
            c ) enable_credits=true ;;
            l ) enable_sptlrx=true ;;
        esac
    done
fi

session_name="splyrics_$(date +%s)"
tmux new-session -d -s "$session_name"

if $enable_sptlrx; then
    tmux send-keys -t "$session_name" "sptlrx $config_sptlrx" C-m
fi

tmux split-window -h -t "$session_name"

if $enable_credits; then
    tmux send-keys -t "$session_name" "echo '---1984 Aperture Science Labs---'" C-m
    tmux send-keys -t "$session_name" "echo '>Connecting to spotifycli'" C-m
    tmux send-keys -t "$session_name" "sleep 1" C-m
    tmux send-keys -t "$session_name" "echo '>Connected'" C-m
    tmux send-keys -t "$session_name" "sleep 1" C-m
    tmux send-keys -t "$session_name" "echo '>Playing the end credits.'" C-m
    tmux send-keys -t "$session_name" "sleep 1" C-m
fi
tmux send-keys -t "$session_name" "spotifycli" C-m
tmux send-keys -t "$session_name" "play" C-m

spotifycli_pane=$(tmux display-message -p -t "$session_name:0.1" "#{pane_id}")

if $enable_cava; then
    tmux split-window -v -t "$spotifycli_pane"
    tmux send-keys -t "$session_name" "cava" C-m
fi

tmux select-pane -t "$spotifycli_pane"

tmux set-option -t "$session_name" remain-on-exit on
tmux set-option -t "$session_name" destroy-unattached off
tmux set-hook -t "$session_name" pane-died "run-shell 'tmux kill-session -t \"$session_name\"'"

tmux attach -t "$session_name"
