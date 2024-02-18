#!/bin/bash

: << 'READ_ME'
# Ubuntu Desktop Shortcut Setup for Immersed VR
Written by gh057 <gh057.io>

## Description
I've personally found that having a desktop shortcut set up for the Immersed VR appimage makes life a lot easier when trying to run it from within Ubuntu. For those who are not terribly familiar with how to do this, I've created this script for you.

## Compatability
This was tested with Ubuntu 23.10. While the commands being run here are pretty standard shell scripting commands, there may be some instances where this doesn't work exactly as intended.

## Setup
You will need to download both the Immersed VR appimage as well as some icon that you'd like to use:
* The Immersed VR appimage can be [downloaded here](https://static.immersed.com/dl/Immersed-x86_64.AppImage)
* The Immersed logo can be grabbed from a number of different places (or you can just use any icon you'd like). The icon that I am using [came from the Reddit subthread here](https://www.reddit.com/r/Immersed/). Note that as of today, the script expects the use of a PNG.

## Instructions
The script will perform the following actions:
* Prompt the user for the location of the:
    * appimage file
    * icon file
* Create the custom icon directory for custom desktop icons (/usr/share/icons/custom)
* Create the applications directory for the appimage (~/Applications)
* Move the appimage and icon files to the proper locations
* Make the appimage executable
* Create the custom desktop file and move it to the proper location (/usr/share/applications)

### Regarding File Locations and Directories
For custom desktop icons, I personally prefer to keep them separated from the rest of what is used by the system which is why I create a custom directory. The same can be said for appimages that I download and run. All other files are contained in directories where the system expects to find them.

## Waiver
USE ONLY AT YOUR OWN RISK. If you do not know what a particular shell command will do, DO NOT USE IT. With shell scripting, there is NO UNDO; keep that in mind. Further, please do not blame me if this backfires or causes damage. As I just said, USE AT YOUR OWN RISK.
READ_ME

ICON_DIR="/usr/share/icons/custom"
USER_APP_DIR="$HOME/Applications"
SHORTCUT_DIR="/usr/share/applications"
SHORTCUT_FILE="immersed.desktop"

read -p "Please enter the path to your appimage file: " APPIMAGE_LOC
read -p "Please enter the path to your custom icon file: " CUSTOM_ICON_LOC

MOVE_FILE() {
    FULL_PATH="${1/#\~/$HOME}"
    [[ $3 = 1 ]] && sudo mv $FULL_PATH $2 || mv $FULL_PATH $2
    echo "'$FULL_PATH' has been moved to '$2'."
}

CREATE_DIR() {
    if [ ! -d "$1" ]; then
        [[ $2 = 1 ]] && sudo mkdir -p "$1" || mkdir -p "$1"
        echo "Directory '$1' created."
    else
        echo "Directory '$1' already exists."
    fi
}

WRITE_TO_FILE() {
    cat > $1 <<- EOM
[Desktop Entry]
Version=1.0
Name=Immersed
Comment=Immersed is the best way to get things done no matter where you are. We empower users all around the world to immerse themselves and others into a portable, distraction-free workspace, giving them deeper focus and increased productivity.
Exec=$USER_APP_DIR/immersed.appimage
Icon=$ICON_DIR/immersed.png
Terminal=false
Type=Application
Categories=Utility;Development
EOM
}

# Create the custom icon directory for custom desktop icons
CREATE_DIR $ICON_DIR 1

# Create the applications directory for the appimage
CREATE_DIR $USER_APP_DIR 0

# Move the necessary files to the proper locations
MOVE_FILE $APPIMAGE_LOC "$USER_APP_DIR/immersed.appimage" 0
MOVE_FILE $CUSTOM_ICON_LOC "$ICON_DIR/immersed.png" 1

# Make the appimage executable
chmod +x "$USER_APP_DIR/immersed.appimage"
echo "'$USER_APP_DIR/immersed.appimage' is now executable."

# Create the custom desktop file and move it to the proper location
if [ ! -e "$SHORTCUT_DIR/$SHORTCUT_FILE" ]; then
    WRITE_TO_FILE $SHORTCUT_FILE
    MOVE_FILE $SHORTCUT_FILE $SHORTCUT_DIR/$SHORTCUT_FILE 1
    echo "'$SHORTCUT_DIR/$SHORTCUT_FILE' created."
else
    echo "'$SHORTCUT_DIR/$SHORTCUT_FILE' already exists."
fi