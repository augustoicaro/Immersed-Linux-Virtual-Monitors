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
* Prompt the user to determine if they want webcam support enabled
* Create the custom icon directory for custom desktop icons (/usr/share/icons/custom)
* Create the applications directory for the appimage (~/Applications)
* Move the appimage and icon files to the proper locations
* Make the appimage executable
* Create the custom desktop file and move it to the proper location (/usr/share/applications)

### Regarding File Locations and Directories
For custom desktop icons, I personally prefer to keep them separated from the rest of what is used by the system which is why I create a custom directory. The same can be said for appimages that I download and run. All other files are contained in directories where the system expects to find them.

## Waiver
This script is being offered as-is. Please use as your own discetion. While I have tested multiple times and tried to ensure the least amount of bugs, please note that there are no guarantees. If you do find an issue, please do reach out to me and I'll happily update it accordingly.