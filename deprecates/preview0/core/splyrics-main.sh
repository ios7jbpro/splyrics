#!/usr/bin/env bash

# Parse cookie from config file
config_file="$HOME/.config/splyrics/config.json"
sptlrx_cookie=$(jq -r '.["sptlrx-cookie"]' "$config_file")
config_sptlrx=$(jq -r '.["sptlrx"]' "$config_file")

# Function to create tmux panes based on flags
create_tmux_panes() {
    local enable_cava="$1"
    local enable_sptlrx="$2"
    local enable_song_info="$3"

    # Example tmux session initialization (replace with your actual logic)
    session_name="splyrics_$(date +%s)"
    tmux new-session -d -s "$session_name"

    if $enable_sptlrx; then
        # Send sptlrx command with parsed cookie
        tmux send-keys -t "$session_name" "clear && chmod +x sptlrx && ./sptlrx $config_sptlrx --cookie \"$sptlrx_cookie\"" C-m
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
}

# Main script starts here
enable_cava="$1"
enable_sptlrx="$2"
enable_song_info="$3"

create_tmux_panes "$enable_cava" "$enable_sptlrx" "$enable_song_info"

