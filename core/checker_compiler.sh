#!/bin/bash

# Function to check if a package exists and compile if necessary
check_and_compile_package() {
    local package_name="$1"
    if ! command -v "$package_name" &> /dev/null || [[ "$force_compile" == "true" ]]; then
        echo "$package_name not found or force compilation requested. Compiling..."
        chmod +x "compilers/${package_name}compiler.sh"
        ./compilers/"${package_name}compiler.sh"
    else
        echo "$package_name already exists. Skipping compilation."
    fi
}

# Parse command line arguments
force_compile=false
packages=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --force|-r )
            force_compile=true
            ;;
        * )
            packages+=("$1")
            ;;
    esac
    shift
done

# Check and compile required packages
for package in "${packages[@]}"; do
    case $package in
        "tmux" )
            check_and_compile_package "tmux"
            ;;
        "sptlrx" )
            check_and_compile_package "sptlrx"
            ;;
        "spotifycli" )
            check_and_compile_package "spotifycli"
            ;;
        "cava" )
            check_and_compile_package "cava"
            ;;
        * )
            echo "Unknown package: $package"
            exit 1
            ;;
    esac
done
