#!/usr/bin/env bash

# Check if any flags are passed
if [ "$*" == "" ]; then
   echo "No flags are passed, calling help."
   help="1"
fi

# Get flags
while getopts "licvh" opt; do
    case $opt in
        l)
            # Handle -l flag
            lyrics="1"
            ;;
        i)
            # Handle -i flag
            info="1"
            ;;
        c)
            # Handle -c flag
            controls="1"
            ;;
        v)
            # Handle -v flag
            visualiser="1"
            ;;
        h)
            # Handle -h flag
            help="1"
            ;;
        *)
            echo "Unknown flag(s)."
            exit
            ;;
    esac
done

# If help is ran, print and exit
if [ "$help" == "1" ]; then
echo "SpLyrics"
echo "Yet another Spotify script"
echo "Arguments:"
echo "  -l: Enable lyrics"
echo "  -i: Enable song info"
echo "  -c: Enable controls"
echo "  -v: Enable visualiser"
echo "  -h: Show this page"
echo "Example usage:"
echo "  ./splyrics.sh -licv"
exit
fi

# Set up values
name="SpLyrics"
date=$(date +"%H-%M-%S")
tmux_name="$name-$date"
panenum="-1"

# Set title
echo -ne "\033]0;SpLyrics\007"

# Give sufficent permissions to scripts
chmod +x *.sh

# Create a new tmux session
tmux new-session -d -s "$tmux_name"

# Set pane numbers depending on the arguments
if [ "$lyrics" == "1" ]; then
    echo "Setting lyrics pane number"
    num_lyrics=$((panenum + 1))
    panenum="$num_lyrics"
fi
if [ "$info" == "1" ]; then
    echo "Setting info pane number"
    num_info=$((panenum + 1))
    panenum="$num_info"
fi
if [ "$controls" == "1" ]; then
    echo "Setting controls pane number"
    num_controls=$((panenum + 1))
    panenum="$num_controls"
fi
if [ "$visualiser" == "1" ]; then
    echo "Setting visualiser pane number"
    num_visualiser=$((panenum + 1))
    panenum="$num_visualiser"
fi


# Check if -l is passed
if [ "$lyrics" == "1" ]; then
    echo "Lyrics are enabled"
    echo "Starting lyrics page"
    # If so, run the first pane logic first, since I don't know how to handle it later on.
    tmux send-keys -t $tmux_name:0.$num_lyrics './lyrics.sh' C-m
fi

# Pane creation logic
if [ "$lyrics" == "1" ]; then
    echo "Creating lyrics pane"
    tmux split-window -h
fi
if [ "$info" == "1" ]; then
    echo "Creating info pane"
    tmux split-window -v
fi
if [ "$controls" == "1" ]; then
    echo "Creating controls pane"
    tmux split-window -v
fi

# Start the pages
if [ "$info" == "1" ]; then
  echo "Starting info page"
  tmux send-keys -t $tmux_name:0.$num_info './info.sh' C-m
fi
if [ "$controls" == "1" ]; then
  tmux send-keys -t $tmux_name:0.$num_controls 'clear && ./controls.sh' C-m
fi
if [ "$visualiser" == "1" ]; then
  tmux send-keys -t $tmux_name:0.$num_visualiser './visualiser.sh' C-m
fi

# Select the controller pane
if [ "$controls" == "1" ]; then
  echo "Focusing on controls"
  tmux select-pane -t $num_controls
fi

# Attach to the session
tmux attach-session -t "$tmux_name"
