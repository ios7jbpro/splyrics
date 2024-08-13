#!/usr/bin/env bash

# Define the directory and file paths
CONFIG_DIR="$HOME/.config/splyrics"
CONFIG_FILE="$CONFIG_DIR/config.json"
CHECK_SCRIPT="core/checksptlrx.sh"

# Define the content for the config file
CONFIG_CONTENT='{
    "defaults": "-sl",
    "sptlrx": "pipe",
    "sptlrx-cookie": "",
    "cava": ""
}'

# Function to run the check script
run_check_script() {
    if [ -f "$SCRIPT_DIR/$CHECK_SCRIPT" ]; then
        bash "$SCRIPT_DIR/$CHECK_SCRIPT"
    else
        echo "Check script $CHECK_SCRIPT not found."
    fi
}

# Create the directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Check if the config file already exists
if [ -f "$CONFIG_FILE" ]; then
    echo "Config file already exists at $CONFIG_FILE"
    # Check if the sptlrx-cookie is empty
    COOKIE_VALUE=$(jq -r '.["sptlrx-cookie"]' "$CONFIG_FILE")
    if [ -z "$COOKIE_VALUE" ]; then
        run_check_script
    fi
else
    # Write the content to the config file
    echo "$CONFIG_CONTENT" > "$CONFIG_FILE"
    echo "Config file created at $CONFIG_FILE"
    run_check_script
fi

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find and chmod all .sh files recursively from the script directory
find "$SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \;

echo "All .sh files in $SCRIPT_DIR and its subdirectories have been made executable."
echo "Initiating the script!"
# Modify your flags here
./splyrics-init.sh -swl

