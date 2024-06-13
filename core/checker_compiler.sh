#!/bin/bash

# Function to check if a package exists and compile if necessary
check_and_compile_package() {
    local package_name="$1"
    if ! command -v "$package_name" &> /dev/null; then
        echo "$package_name not found. Compiling..."
        chmod +x "compilers/${package_name}compiler.sh"
        ./compilers/"${package_name}compiler.sh"
    else
        echo "$package_name already exists. Skipping compilation."
    fi
}

# Check and compile required packages based on arguments
for package in "$@"; do
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
