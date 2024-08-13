#!/usr/bin/env bash

# Check if config.json exists
if [ ! -f "config.json" ]; then
    echo "false"
    exit 0
fi

# Check if "sptlrx-cookie" exists and is not empty
if jq -e '.["sptlrx-cookie"] | length > 0' config.json >/dev/null 2>&1; then
    echo "true"
else
    echo "false"
fi

