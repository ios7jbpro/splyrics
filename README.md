# splyrics
A bundled script that displays controls for Spotify alongside eyecandy

## Disclaimer
You OBVIOUSLY need a Spotify premium account to use this.

## Options
```
-h    Shows the help message
-i    Install the script systemwide
-s    Enable the cava tmux panel(the visualiser)
-c    Enable the echoing credits(easter egg, portal 1 styled credits)
-l    Enable the sptlrx panel(lyrics panel)
```

## Example usage
```
splyrics -sl
^ (if the packages that are required by the flags are not installed, script will error out.)
```

## Dependencies
https://github.com/karlstav/cava

https://github.com/pwittchen/spotify-cli-linux

https://github.com/raitonoberu/sptlrx

## Installation
```
git clone https://github.com/ios7jbpro/splyrics
cd splyrics
chmod +x splyrics.sh
./splyrics.sh -r
./splyrics.sh -i
```
**PLEASE DO NOT SKIP THE -r PART. IT INSTALLS THE REQUIRED DEPENDENCIES. SKIPPING IT MIGHT BREAK YOUR SYSTEM, SINCE IT WILL TRY TO CLONE AND INSTALL THEM IN THE ROOT DIR!**

## Contribution
Just create a PR request.
