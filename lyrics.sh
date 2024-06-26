#!/usr/bin/env bash

# Function to read JSON value
function get_json_value {
    local config_file="$1"
    local key="$2"
    jq -r --arg key "$key" 'if has($key) then .[$key] else empty end' "$config_file"
}

# Config file path and key
config_file="config.json"
cookie_key="sptlrx-cookie"

# Read the cookie value from config.json
cookie_value=$(get_json_value "$config_file" "$cookie_key")

# Check if cookie_value is not empty
if [[ -n "$cookie_value" ]]; then
    echo "Extracted cookie_value: $cookie_value"
    # Run the command with --cookie flag
    ./sptlrx --cookie="$cookie_value"
else
    echo "Error: $cookie_key not found or empty in $config_file"
    exit 1
fi

