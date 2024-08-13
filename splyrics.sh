#!/usr/bin/env bash

# Logic blocks.
mainpanecreation () {
# Set title
echo -ne "\033]0;SpLyrics\007"

# Create a new tmux session
tmux new-session -d -s "$tmux_name"

# Set pane numbers depending on the arguments
if [ "$lyrics" == "1" ]; then
    echo "Setting lyrics pane number"
    num_lyrics=$((panenum + 1))
    panenum="$num_lyrics"
fi
if [ "$distrologo" == "1" ]; then
    echo "Setting lyrics pane number"
    num_distrologo=$((panenum + 1))
    panenum="$num_distrologo"
fi
if [ "$info" == "1" ]; then
    echo "Setting info pane number"
    num_info=$((panenum + 1))
    panenum="$num_info"
fi
if [ "$controls" == "1" ]; then
    echo "Setting controls pane number"
    num_controls=$((panenum + 1))
    panenum="$num_controls"
fi
if [ "$visualiser" == "1" ]; then
    echo "Setting visualiser pane number"
    num_visualiser=$((panenum + 1))
    panenum="$num_visualiser"
fi


# Pane creation logic
if [ "$lyrics" == "1" ]; then
    echo "Creating lyrics pane"
    tmux split-window -h
fi
if [ "$info" == "1" ]; then
    echo "Creating info pane"
    tmux split-window -v
fi
if [ "$controls" == "1" ]; then
    echo "Creating controls pane"
    tmux split-window -v
fi
if [ "$distrologo" == "1" ]; then
    echo "Creating distrologo pane"
    tmux select-pane -t $num_lyrics
    tmux split-window -v
fi

# Swap numbers for distrologo so it displays on top
if [ "$distrologo" == "1" ]; then
tmp="$num_distrologo"
num_distrologo="$num_lyrics"
num_lyrics="$tmp"
fi

# Check if -l is passed
if [ "$lyrics" == "1" ]; then
    echo "Lyrics are enabled"
    echo "Starting lyrics page"
    if [ "$pipe_flag" == "1" ] ; then
    echo "Pipe mode called on sptlrx"
    tmux send-keys -t $tmux_name:0.$num_lyrics './lyrics.sh pipe' C-m
    else
    # If so, run the first pane logic first, since I don't know how to handle it later on.
    tmux send-keys -t $tmux_name:0.$num_lyrics './lyrics.sh' C-m
    fi
fi

# Start the pages
if [ "$distrologo" == "1" ]; then
  echo "Starting distrologo page"
  tmux resize-pane -t $tmux_name:0.$num_distrologo -U 7
  tmux send-keys -t $tmux_name:0.$num_distrologo './distrologo.sh' C-m
fi
if [ "$info" == "1" ]; then
  echo "Starting info page"
  tmux send-keys -t $tmux_name:0.$num_info './info.sh' C-m
fi
if [ "$controls" == "1" ]; then
  tmux send-keys -t $tmux_name:0.$num_controls 'clear && ./controls.sh' C-m
fi
if [ "$visualiser" == "1" ]; then
  tmux send-keys -t $tmux_name:0.$num_visualiser './visualiser.sh' C-m
fi

# Select the controller pane
if [ "$controls" == "1" ]; then
  echo "Focusing on controls"
  tmux select-pane -t $num_controls
fi

# Attach to the session
if [ "$crt" == "1" ]; then
tmux detach-client -s "$tmux_name"
cool-retro-term --fullscreen -T CRTLyrics -e tmux attach-session -t "$tmux_name"
else
tmux attach-session -t "$tmux_name"
fi
}

## Check if defaults file exist. If so, recall the script with those defaults(only if the user didn't pass flags)
if [ "$#" -gt 0 ]; then
echo "Flags passed. Going through script normally"
else
if [ -e "defaults.txt" ]; then
    echo "Defaults file found. Re-initiating with the defaults file"
    defaults=$(cat defaults.txt)
    mv defaults.txt tmp.txt
    exec "$0" $defaults $@
fi
fi

# Then, on the next script startup, rename tmp back to defaults so it can be reused
if [ -e "tmp.txt" ]; then
mv tmp.txt defaults.txt
fi

## Initialization
# Give sufficent permissions to scripts
chmod +x *.sh

# Check or create the folder for package checking logic
if [ -d "data" ]; then
    echo "Data directory exists, checking for data structure"
    cd data
    if [ -f "DONOTTOUCH" ]; then
    echo "Data folder has already been set up"
    cd ..
    else
    echo "Data folder is not configured, setting it up"
    echo "Initializing data folder setup"
    touch "DONOTTOUCH"
    echo "DO NOT TOUCH THIS FOLDER. IT IS USED TO STORE DATA!!!" >> DONOTTOUCH
    cd ..
    fi
else
    echo "Data directory does not exists, creating one"
    mkdir data
    cd data
    if [ -f "DONOTTOUCH" ]; then
    echo "Data folder has already been set up"
    cd ..
    else
    echo "Data folder is not configured, setting it up"
    echo "Initializing data folder setup"
    touch "DONOTTOUCH"
    echo "DO NOT TOUCH THIS FOLDER. IT IS USED TO STORE DATA!!!" >> DONOTTOUCH
    cd ..
    fi
fi

# Resolve script location
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
echo "The script is located in: $SCRIPT_DIR"


# Check if any flags are passed
if [ "$*" == "" ]; then
   echo "No flags are passed"
fi

# Get flags
while getopts "ldicvhqsr" opt; do
    case $opt in
        l)
            # Handle -l flag
            lyrics="1"
            ;;
        d)
            # Handle -d flag
            distrologo="1"
            ;;
        i)
            # Handle -i flag
            info="1"
            ;;
        c)
            # Handle -c flag
            controls="1"
            ;;
        v)
            # Handle -v flag
            visualiser="1"
            ;;
        h)
            # Handle -h flag
            help="1"
            ;;
        q)
            # Information flag
            information="1"
            ;;
        s)
            # Skip flag
            skippkg="1"
            ;;
        r)
            # Reset flag
            resetdata="1"
            ;;
        *)
            echo "Unknown flag(s)."
            exit
            ;;
    esac
done

# Check for additional arguments
shift $((OPTIND - 1))

# Check for additional arguments
for arg in "$@"; do
    case $arg in
        pipe)
            pipe_flag="1"
            ;;
        install)
            install_sys="1"
            ;;
        theme)
            echo -e "\033[0;42m\033[0;30m"
            ;;
        crt)
            crt="1"
            echo "CRT Mode"
            ;;
    esac
done

# Reset data
if [ "$resetdata" == "1" ]; then
rm -rf ./data
echo "Data has been cleared out. Exiting script."
exit
fi

# Check if pkgdata exists on the structure. If so, set skip packages.
if [ -f "./data/pkg" ]; then
    skippkg="1"
else
    skippkg="0"
    # Also disable everything else in the script so it can't progress through
    lyrics="0"
    info="0"
    controls="0"
    visualiser="0"
fi

# Check if skippkg is called
if [ "$skippkg" != "1" ]; then
# If not, first clear out old installers data to not conflict with updates
cd data
rm -rf pkginstallers
rm -rf distrocheck.sh
rm -rf packageinstaller.sh
cd ..
# Then, set up the distro on data
cp distrocheck.sh ./data/distrocheck.sh
cp packageinstaller.sh ./data/packageinstaller.sh
cp -r pkginstallers ./data/pkginstallers
cd data
chmod +x *.sh
cd pkginstallers
chmod +x *.sh
cd ..
./distrocheck.sh
cd ..
fi

# If install is called, install the script systemwide by creating another script that calls this one.
if [ "$install_sys" == "1" ]; then
# mkdir tmp
# cd tmp
# touch splyrics.sh
# echo "#!/usr/bin/env bash" > splyrics.sh
# echo " " >> splyrics.sh
# echo ".$SCRIPT_DIR/splyrics.sh $1" >> splyrics.sh
# mv splyrics.sh ~/.local/bin/splyrics.sh
# chmod +x ~/.local/bin/splyrics.sh
# echo "Installed systemwide"
# exit

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If install is called, install the script system-wide by creating another script that calls this one
mkdir -p ~/.local/bin  # Ensure the directory exists

# Create the system-wide script
cat <<EOF > ~/.local/bin/splyrics
#!/usr/bin/env bash
cd "$SCRIPT_DIR" && exec ./splyrics.sh "\$@"
EOF

chmod +x ~/.local/bin/splyrics
echo "Installed system-wide"
exit
fi


# If help is ran, call the help script and exit
if [ "$help" == "1" ]; then
./help.sh
exit
fi

# Check if -q is called, if so call the script and exit
if [ "$information" == "1" ]; then
./changelog.sh
fi
# Set up values
name="SpLyrics"
date=$(date +"%H-%M-%S")
tmux_name="$name-$date"
panenum="-1"

# Run the actual software
mainpanecreation

# Check if any panel is called. If not, terminate the tmux session
if [ "$lyrics" == "1" ] ; then
# Empty block
:
elif [ "$info" == "1" ]; then
# Empty block
:
elif [ "$controls" == "1" ]; then
# Empty block
:
elif [ "$visualiser" == "1" ]; then
# Empty block
:
else
tmux send-keys -t $tmux_name:0.0 'exit' C-m
tmux kill-server
fi
