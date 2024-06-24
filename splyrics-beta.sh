#!/usr/bin/env bash

# Function to give executable permissions to all scripts in the current directory
function give_exec_permissions {
    chmod +x ./*.sh
}

# Function to execute a script in a pane and clear it first
function clear_and_run {
    local pane_index=$1
    local script=$2
    tmux send-keys -t $pane_index "clear && ./$script" C-m
}

# Function to create a new session with panes and execute scripts
function create_session {
    local session_name=$1
    
    # Start a new session with the given name
    tmux new-session -d -s $session_name
    
    # Split the window horizontally into two parts
    tmux split-window -h
    
    # Split the right part vertically into two parts
    tmux split-window -v
    
    # Split the bottom right part vertically again
    tmux split-window -v
    
    # Execute each script in the respective pane
    clear_and_run 0 "lyrics.sh"
    clear_and_run 1 "info.sh"
    clear_and_run 2 "controls.sh"
    clear_and_run 3 "visualiser.sh"
    
    # Select panel 3 at the end
    tmux select-pane -t 2
    
    # Attach to the created session
    tmux attach-session -t $session_name
}

# Function to check packages before proceeding
function check_packages {
    ./packagechecker.sh
    
    if [[ $? -ne 0 ]]; then
        echo "Package checker failed. Exiting."
        exit 1
    fi
    
    result=$(./packagechecker.sh)
    if [[ $result == "false" ]]; then
        echo "Package checker returned false. Cancelling script."
        exit 1
    elif [[ $result == "true" ]]; then
        echo "Package checker returned true. Continuing script."
    else
        echo "Unexpected output from packagechecker.sh: $result"
        exit 1
    fi
}

# Function to check cookies before proceeding
function check_cookies {
    ./cookiecheck.sh
    
    if [[ $? -ne 0 ]]; then
        echo "Cookie checker failed. Exiting."
        exit 1
    fi
    
    result=$(./cookiecheck.sh)
    if [[ $result == "false" ]]; then
        echo "Cookie checker returned false. Running cookie guide."
        ./cookieguide.sh
        exit 1
    elif [[ $result == "true" ]]; then
        echo "Cookie checker returned true. Continuing script."
    else
        echo "Unexpected output from cookiecheck.sh: $result"
        exit 1
    fi
}

# If argument "install" is provided, install the script system-wide
if [[ "$1" == "install" ]]; then
    # Give executable permissions to all scripts in the current directory
    give_exec_permissions
    
    # Determine the user's bin directory
    if [[ -d "$HOME/bin" ]]; then
        bin_dir="$HOME/bin"
    elif [[ -d "$HOME/.local/bin" ]]; then
        bin_dir="$HOME/.local/bin"
    else
        echo "Error: Cannot determine user's bin directory."
        exit 1
    fi
    
    # Create a symbolic link to the script in the bin directory
    ln -s "$(realpath "$0")" "$bin_dir/splyrics"
    
    echo "splyrics script installed in $bin_dir directory."
    echo "You can now run 'splyrics' from any location."
    
    exit 0
fi

# Give executable permissions to all scripts in the current directory
give_exec_permissions

# Check packages and cookies before proceeding
check_packages
check_cookies

# Usage example: create a session named 'session1'
create_session "session1"

