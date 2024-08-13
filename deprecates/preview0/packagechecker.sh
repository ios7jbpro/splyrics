#!/usr/bin/env bash

# Function to check if a command exists and is executable
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# List of packages to check
packages=("spotifycli" "cava")

# Variable to track if all packages are found
all_found=true

# Iterate over each package
for pkg in "${packages[@]}"; do
    if ! command_exists "$pkg"; then
        all_found=false
        break
    fi
done

# Output true or false based on package existence
if $all_found; then
    echo "true"
else
    echo "false"
fi

