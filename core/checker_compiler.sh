#!/bin/bash

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPILERS_DIR="$SCRIPT_DIR/../compilers"

# Function to compile a specific package
compile_package() {
    local package_name=$1
    if [ -f "$COMPILERS_DIR/${package_name}compiler.sh" ]; then
        chmod +x "$COMPILERS_DIR/${package_name}compiler.sh"
        "$COMPILERS_DIR/${package_name}compiler.sh"
    else
        echo "Error: Compiler script for $package_name not found."
    fi
}

# Function to compile all packages if --force flag is set
compile_all_packages() {
    local force_compile=$1
    if [ "$force_compile" = "--force" ]; then
        for compiler_script in "$COMPILERS_DIR"/*.sh; do
            if [ -f "$compiler_script" ]; then
                chmod +x "$compiler_script"
                "$compiler_script"
            fi
        done
    else
        echo "Error: Unknown option or missing package."
    fi
}

# Main execution starts here
force_compile=$1
if [ -n "$force_compile" ]; then
    compile_all_packages "$force_compile"
else
    echo "Checking and compiling necessary packages..."
    # Modify this list as per your project's requirements
    packages=("tmux" "sptlrx" "spotifycli" "cava")
    for package in "${packages[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            echo "$package not found. Compiling..."
            compile_package "$package"
        else
            echo "$package already installed."
        fi
    done
fi
