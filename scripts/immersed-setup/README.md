
# Immersed setup

These scripts assume you have the driver configured on your Xorg. If configuration is not done, please read about intel VD setup [here](https://github.com/augustoicaro/Immersed-Linux-Virtual-Monitors?tab=readme-ov-file#intel-driver).

- `immersed-setup`: Download Immersed and setup the `v4l2loopback` module autoload for virtual camera. This script was designed for debian based distros using `apt`. If using a different distro use this script as guide for the initial setup. After start Immersed agent for the first time, you will also need to change the `CameraDeviceCameraDevice=/dev/video7` on Immersed config file (`~/ImmersedConf`).
- `create-dektop-shortcut`: Creates a desktop shortcut for the Immersed Client.
