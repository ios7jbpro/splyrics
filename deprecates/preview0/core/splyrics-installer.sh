#!/bin/bash

# Define source and destination paths
SOURCE_SCRIPT="$(realpath splyrics.sh)"
DESTINATION_SCRIPT="/usr/local/bin/splyrics"

# Create a new script file in the destination folder
sudo tee "$DESTINATION_SCRIPT" > /dev/null <<EOF
#!/bin/bash
$(realpath splyrics.sh) "\$@"
EOF

# Make the new script executable
sudo chmod +x "$DESTINATION_SCRIPT"

# Display installation message with warning in bold uppercase
echo "SpLyrics installed successfully."
echo -e "\e[1m\e[91mWARNING: DO NOT DELETE THE ORIGINAL DIRECTORY WHERE splyrics.sh IS LOCATED.\e[0m"
echo "You can now run the script using 'splyrics'."
