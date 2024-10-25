#!/bin/bash

PHYSICAL_DISPLAY='HDMI-A-0'

# Seems to be necessary to get USB connection working
adb start-server

EVDI_DEVICES=( $(xrandr | grep -o DVI-I-.-.) )
read EVDI0 EVDI1 EVDI2 EVDI3 <<< ${EVDI_DEVICES[@]}
xrandr --newmode "2560x1440" 312.25  2560 2752 3024 3488  1440 1443 1448 1493 -hsync +vsync
xrandr --newmode "1920x1080" 173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
for dev in ${EVDI_DEVICES[@]}
do
    xrandr --addmode $dev 2560x1440
    xrandr --addmode $dev 1920x1080
done

# Select how many virtual displays you will use
MY_DEVICES=($EVDI0 $EVDI1 $EVDI2)
for dev in ${MY_DEVICES[@]}
do
    sysfs_id=$(echo "${dev}" | cut -d '-' -f 4)
    sysfs_path=$(sudo find /sys/kernel/debug/dri -type d -name "DVI-I-${sysfs_id}")
    echo on | sudo tee "${sysfs_path}/force" >/dev/null
done

xrandr | awk  /connected/

# Setup tie fighter layout and disable physucal screen
xrandr --output $EVDI0 --mode 1920x1080 --auto --below $PHYSICAL_DISPLAY --output $EVDI1 --mode 1920x1080 --rotate left --left-of $PHYSICAL_DISPLAY --output $EVDI2 --mode 1920x1080 --rotate left --right-of $PHYSICAL_DISPLAY

echo "Immersed starting"
./Immersed-x86_64.AppImage
echo "Immersed stopped"

# After exiting Immersed revert monitor layout
xrandr --output $PHYSICAL_DISPLAY --mode 1920x1080 --pos 0x0 --output $EVDI0 --off -output $EVDI1 --off --output $EVDI2 --off --output $EVDI3 --off
