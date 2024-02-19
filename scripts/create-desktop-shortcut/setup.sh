#!/bin/bash

# Global variables for the script
ICON_DIR="/usr/share/icons/custom"
USER_APP_DIR="$HOME/Applications"
SHORTCUT_DIR="/usr/share/applications"
SHORTCUT_FILE="immersed.desktop"

# Request user input for the specific files needed
read -p "Please enter the path to your appimage file: " APPIMAGE_LOC
read -p "Please enter the path to your custom icon file: " CUSTOM_ICON_LOC
read -p "Do you wish to check for webcam support on launch (y/n)? " WEBCAM_SUPPORT

##
# MOVE_FILE
# Moves a file from one location to another, possibly as root as needed.
##
MOVE_FILE() {
    FULL_PATH="${1/#\~/$HOME}"

    if [[ ! -f $FULL_PATH ]] ; then
        echo "'$FULL_PATH' does not exist. Please make sure the file exists before continuing."
        exit
    else
        [[ $3 = 1 ]] && sudo mv $FULL_PATH $2 || mv $FULL_PATH $2
        echo "'$FULL_PATH' has been moved to '$2'."
    fi
}

##
# CREATE_DIR
# Creates a directory in a specific location, possibly as root as neeed.
##
CREATE_DIR() {
    if [ ! -d "$1" ]; then
        [[ $2 = 1 ]] && sudo mkdir -p "$1" || mkdir -p "$1"
        echo "Directory '$1' created."
    else
        echo "Directory '$1' already exists."
    fi
}

##
# WRITE_TO_FILE
# Writes the desktop shortcut contents to the shortcut file.
##
WRITE_TO_FILE() {
    [[ $WEBCAM_SUPPORT = "y" ]] && EXEC="pkexec modprobe v4l2loopback;$USER_APP_DIR/immersed.appimage" || EXEC="$USER_APP_DIR/immersed.appimage"

    cat > $1 <<- EOM
[Desktop Entry]
Version=1.0
Name=Immersed
Comment=Immersed is the best way to get things done no matter where you are. We empower users all around the world to immerse themselves and others into a portable, distraction-free workspace, giving them deeper focus and increased productivity.
Exec=$EXEC
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
