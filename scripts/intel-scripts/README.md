# Intel scripts

These scripts assume you have the driver configured on your Xorg. If configuration is not ready, please read about intel VD setup [here](https://github.com/augustoicaro/Immersed-Linux-Virtual-Monitors?tab=readme-ov-file#intel-driver).

> [!WARNING]
>
> - The scripts should be placed on the same folder that the `Immersed-x86_64.AppImage` file is.
> - Edit the `PHYSICAL_DISPLAY` variable with the correct string for your reference physical monitor.
> - Setup your VR monitors as the layout presented on your system video settings.
> - If using more different layout, is recomended save the VR layouts on the layout slots on Immersed monitor settings.

- i[mmersed_tie_fighter](immersed_tie_fighter.sh): Setup intel vds and start Immersed, reverting system monitor layout on Immersed exit.
