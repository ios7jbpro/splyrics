# splyrics
A bundled script that displays controls for Spotify alongside eyecandy

## Disclaimer
You OBVIOUSLY need a Spotify premium account to use this.

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
./splyrics.sh -i(optional, to install system-wide)
```
**PLEASE DO NOT SKIP THE -r PART. IT INSTALLS THE REQUIRED DEPENDENCIES. SKIPPING IT MIGHT BREAK YOUR SYSTEM, SINCE IT WILL TRY TO CLONE AND INSTALL THEM IN THE ROOT DIR!**

After installation(DO NOT QUIT THE CLONED DIRECTORY YET), run `splyrics`. It will ask you to fill your Spotify cookie details. Follow the shown instructions.

## Options
```
-h    Shows the help message
-i    Install the script systemwide
-s    Enable the cava tmux panel(the visualiser)
-l    Enable the sptlrx panel(lyrics panel)
-e    Open the config editor
```

## Example usage
```
splyrics -sl
```

## Contribution
Just create a PR request.
