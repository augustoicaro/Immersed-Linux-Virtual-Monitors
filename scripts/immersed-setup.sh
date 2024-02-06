#!/bin/bash

# Immersed on Pop!_OS

###############################################################################
# This script serves as documentation for how I installed Immersed and        #
# configured the v42loopback device to load as needed by Immersed for the     #
# virtual webcam on my system running Pop!_OS 22.04 LTS. It's provided as a   #
# script so that others can read the comments to learn, and modify it as      #
# needed to configure their systems automagically after a fresh install.      #
###############################################################################

# This function is used when executing the script. If you're reading this to
# learn and set up Immersed yourself, skip to the next section.

asRoot ()  {
    if (($EUID != 0)); then
        if [[ -t 1 ]]; then
            sudo $1
        else
            gksu $1
        fi
    else
        $1
    fi
}

## Root Check

# This script should *not* be run as the root user. It expects and will ask for
# sudo elevation as needed.

if [ `whoami` = root ]; then
    printf -- "Do not run this script as root or with sudo.\n"
    exit
fi

## Variables

# The scripted version of this document uses variables for options a user may
# want to change. They are all listed and set here:

# A common directory for AppImage binaries
APPDIR=$HOME/Applications 

# If you know what you're doing, adjust the v4l2loopback options here.
MODOPTS="options v4l2loopback card_label='Immersed' video_nr=7 exclusive_caps=1 max_buffers=2 devices=1"

# These variables should not be changed, they are used by the script.
PATHCHECK="$(echo $PATH | grep $APPDIR)"
PATHSUGGEST=$(echo $APPDIR | sed "s|$HOME||")
DEPS="wget v4l2loopback-dkms"
INSTALLCHECK="$(ls $APPDIR/Immersed-x86_64.AppImage)"

## Dependencies

# This script assumes the following packages:
#  - wget v4l2loopback-dkms
# It will attempt to install them automatically:

printf -- "Installing dependencies...\n\n"
asRoot "apt install ${DEPS[@]}"
printf -- "\nDependencies installed...\n\n"

## Install Immersed

### Download Immersed

# If you don't already have the Immersed client, the script will download it.
# This scripted example assumes you're following the AppImage convention of
# storing apps in $HOME/Applications. If not, adjust $APPDIR above.

if [[ $INSTALLCHECK ]]; then
    printf -- "Immersed is already downloaded in $APPDIR\n\n"
else
    printf -- "Downloading Immersed...\n\n"
    wget https://static.immersed.com/dl/Immersed-x86_64.AppImage -O $APPDIR/Immersed-x86_64.AppImage
fi

### Make Immersed Executable
printf -- "Making Immersed executable...\n\n"
chmod +x $APPDIR/Immersed-x86_64.AppImage

### Add Applications to PATH

# This command checks to see if $APPDIR is in your $PATH variable. This makes
# it easier to run Immersed from launchers like dmenu or rofi.
printf -- "Checking your \$PATH...\n"
if [[ :$PATH: == *"$APPDIR"* ]]; then
    printf -- "Found $APPDIR in your \$PATH.\n\n"
else
    printf -- "$APPDIR is not in your \$PATH. Add the following to your shell's RC file:\n"
    printf -- "PATH=\$PATH:\$HOME$PATHSUGGEST\n\n"
fi


## Set up Virtual Camera

# The Immersed virtual camera depends on the v4l2 loopback "dummy" device on
# your system. We've installed the module, but not loaded it into the OS. To 
# make sure the device is present on every boot, we'll call it in
# `/etc/modules` and define options for it in a new in `/etc/modprobe.d/`.

## Load v4l2loopback on boot:
printf -- "Adding v4l2loopback to /etc/modules...\n"

if [[ $(grep v4l2loopback /etc/modules) ]]; then
    printf -- "v42loopback is already in /etc/modules\n\n"
else
    if (($EUID != 0)); then
        if [[ -t 1 ]]; then
            echo v4l2loopback | sudo tee -a /etc/modules
        else
            echo v4l2loopback | gksu tee -a /etc/modules
        fi
        printf -- "Module added.\n\n"
    fi
fi

## Define v4l2loopback options

# We'll define several options for the v4l2loopback device, so that it's
# deployed consistently in a manner Immersed works with:


if [[ $(ls /etc/modprobe.d/v4l2loopback.conf) ]]; then
    printf -- "/etc/modprobe.d/v4l2loopback.conf already exists"
else
    if (($EUID != 0)); then
        if [[ -t 1 ]]; then
            echo $MODOPTS | sudo tee  /etc/modprobe.d/v4l2loopback.conf
        else
            echo $MODOPTS | gksu tee  /etc/modprobe.d/v4l2loopback.conf
        fi
        printf -- "Module options added.\n\n"
    fi
fi

# To avoid requiring a reboot, we'll also set up the module for the current
# session.

printf -- "\nAdding v4l2loopback to the current session...\n\n"

if [[ $(grep v4l2loopback /proc/modules) ]]; then
    printf -- "v4l2loopback is already loaded.\n\n"
else
    if (($EUID != 0)); then
        if [[ -t 1 ]]; then
            sudo modprobe card_label='Immersed' video_nr=7 exclusive_caps=1 max_buffers=2 devices=1
        else
            gksu modprobe card_label='Immersed' video_nr=7 exclusive_caps=1 max_buffers=2 devices=1
        fi
        printf -- "\nModule enabled.\n\n"
    fi
fi

printf -- "Done, you can now used Immersed.\n"
