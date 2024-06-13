#!/bin/bash

show_help() {
    echo "SpLyrics"
    echo "A bundled script that displays stuff about Spotify"
    echo ""
    echo "Usage: $0 [-h] [-s] [-c] [-l] [-i]"
    echo ""
    echo "Options:"
    echo "  -h    Show this help message"
    echo "  -s    Enable the cava tmux panel"
    echo "  -c    Enable the echoing credits"
    echo "  -l    Enable the sptlrx panel"
    echo "  -i    Install the script system-wide"
}

# Default values for flags
enable_sptlrx=false
enable_cava=false
enable_credits=false
install_systemwide=false

# Parse command line options
while getopts "hscli" opt; do
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
        \? )
            show_help
            exit 1
            ;;
    esac
done

if $install_systemwide; then
    # Get the current script path
    script_path=$(realpath "$0")
    # Copy the script to /usr/local/bin
    sudo cp "$script_path" /usr/local/bin/splyrics
    sudo chmod +x /usr/local/bin/splyrics
    echo "SpLyrics installed successfully. You can now run the script using 'splyrics'."
    exit 0
fi

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "tmux could not be found. Please install it first."
    exit 1
fi

# Check if sptlrx is installed if the flag is set
if $enable_sptlrx && ! command -v sptlrx &> /dev/null; then
    echo "sptlrx could not be found. Please install it first."
    exit 1
fi

# Check if spotifycli is installed
if ! command -v spotifycli &> /dev/null; then
    echo "spotifycli could not be found. Please install it first."
    exit 1
fi

# Check if cava is installed if the flag is set
if $enable_cava && ! command -v cava &> /dev/null; then
    echo "cava could not be found. Please install it first."
    exit 1
fi

# Start a new tmux session
tmux new-session -d -s mysession

# Conditionally run the sptlrx command in the first (left) panel
if $enable_sptlrx; then
    tmux send-keys -t mysession "sptlrx --current 'bold' --before '104,faint,italic' --after '104,faint'" C-m
fi

# Split the window vertically
tmux split-window -h

# Conditionally echo the Portal-themed message and run spotifycli in the second (top right) panel
if $enable_credits; then
    tmux send-keys -t mysession "echo '---1984 Aperture Science Labs---'" C-m
    tmux send-keys -t mysession "echo '>Connecting to spotifycli'" C-m
    tmux send-keys -t mysession "sleep 1" C-m
    tmux send-keys -t mysession "echo '>Connected'" C-m
    tmux send-keys -t mysession "sleep 1" C-m
    tmux send-keys -t mysession "echo '>Playing the end credits.'" C-m
    tmux send-keys -t mysession "sleep 1" C-m
fi
tmux send-keys -t mysession "spotifycli" C-m
tmux send-keys -t mysession "play" C-m

# Get the pane ID for the spotifycli pane
spotifycli_pane=$(tmux display-message -p -t mysession:0.1 "#{pane_id}")

# Conditionally split the right pane horizontally and run cava in the third (bottom right) panel
if $enable_cava; then
    tmux split-window -v -t $spotifycli_pane
    tmux send-keys -t mysession "cava" C-m
fi

# Focus on the spotifycli pane
tmux select-pane -t $spotifycli_pane

# Set up the synchronization to kill the session if any pane is closed
tmux set-option -t mysession remain-on-exit on
tmux set-option -t mysession destroy-unattached off
tmux set-hook -t mysession pane-died "run-shell 'tmux kill-session -t mysession'"

# Attach to the tmux session
tmux attach -t mysession

