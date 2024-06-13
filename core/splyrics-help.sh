#!/bin/bash

echo "SpLyrics"
echo "A bundled script that displays stuff about Spotify"
echo ""
echo "Usage: splyrics [-h] [-s] [-l] [-i] [-e] [-r] [-w]"
echo ""
echo "Options:"
echo "  -h      Show this help message"
echo "  -s      Enable the cava tmux panel (bottom-right)"
echo "  -l      Enable the sptlrx panel (left)"
echo "  -i      Install (or update if already installed) the script system-wide"
echo "  -e      Edit the config file"
echo "  -r      Recompile the packages even if they already exist (no script execution)"
echo "  -w      Display song information instead of spotifycli in the top-right panel"

# Ensure the script is executable
chmod +x "$0"

