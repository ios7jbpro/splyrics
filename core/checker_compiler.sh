#!/bin/bash

# Directory where compilers are located
COMPILERS_DIR="compilers"

# Function to compile a package
compile_package() {
    local package_name=$1
    local force=$2
    if [ "$force" = "--force" ] || [ ! -x "$package_name" ]; then
        echo "Compiling $package_name..."
        chmod +x "$COMPILERS_DIR/${package_name}compiler.sh"
        ./"$COMPILERS_DIR/${package_name}compiler.sh"
    else
        echo "$package_name already exists. Skipping compilation."
    fi
}

# Check and compile all necessary packages
compile_all_packages() {
    compile_package "tmux" "$force"
    compile_package "sptlrx" "$force"
    compile_package "spotifycli" "$force"
    compile_package "cava" "$force"
}

# Parse command-line arguments
force=""
if [ "$1" = "--force" ]; then
    force="--force"
fi

# Run compilation
compile_all_packages


