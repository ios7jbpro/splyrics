#!/usr/bin/env bash

shopt -s xpg_echo

echo "Spotify cookie for authorization not detected."
echo "    1. Open your browser."
echo "    2. Press F12, open the Network tab and go to open.spotify.com."
echo "    3. Click on the first request to open.spotify.com."
echo "    4. Scroll down to the Request Headers, right click the cookie field and select Copy value."
echo "    5. When you have the cookie copied, press enter to proceed."
echo "       This will exit the script, opening the config file."
echo "       Append your cookie value to \"sptlrx-cookie\" key, and re-run the script."

read -p "Press enter to continue..."

nano config.json
