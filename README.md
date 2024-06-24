# splyrics
A bundled script that displays controls for Spotify alongside eyecandy
![preview](https://raw.githubusercontent.com/ios7jbpro/splyrics/main/image.png)

# WARNING
The main script so called "splyrics.sh" is now deprecated since I can't be arsed to code anymore. New script has been extremely modularized and written with ChatGPT. Sorry.

It is **HIGHLY** recommended that you use splyrics-beta.sh instead, since it's more bug-free and modularized.

You need to read only this part of the script if you want to have a basic window, like in the screenshot. No need to go through old README part.

## Dependencies
https://github.com/karlstav/cava

https://github.com/pwittchen/spotify-cli-linux

sptlrx(a binary is included and used, don't install)

## Installation
```
git clone https://github.com/ios7jbpro/splyrics
cd splyrics
chmod +x splyrics-beta.sh
./splyrics-beta.sh
./splyrics-beta.sh install(optional, to install user-wide)
```
The new script does not have the flexible flags(yet).

## Old README
## Disclaimer
You OBVIOUSLY need a Spotify premium account to use this.

## Dependencies
https://github.com/karlstav/cava

https://github.com/pwittchen/spotify-cli-linux

https://github.com/raitonoberu/sptlrx

The dependencies should be automatically installed upon the first launch if they are missing.

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
-i    Display song information instead of spotifycli
-e    Open the config editor
```

## Example usage
```
splyrics -sl
```

## Contribution
Just create a PR request.
