#!/usr/bin/env bash

# Define the command to run
command="watch -t -n 1 \"echo Song: && spotifycli --statusposition && echo Album: && spotifycli --album && echo Artist: && spotifycli --artist\""

# Execute the command
eval "$command"

