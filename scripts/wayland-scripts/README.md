# Wayland Scripts

Scripts created to exercise the `xdg_portal` screen cast and remote desktop features used by Immersed and Gnome Mutter specific capabilities.

- [dbus_rdp_mouse_monitor_mutter](dbus_rdp_mouse_monitor_mutter.py): Use dbus Mutter interface to replicate the same rdp and virtual monitor interfaces that Immersed uses on Gnome.
- [dbus_rdp_screen_cast](dbus_rdp_screen_cast.py): Use dbus generic interface to replicate the same rdp and virtual monitor interfaces that Immersed uses Wayland DE, except on Gnome.
- [dbus_screen_cast](dbus_screen_cast.py): Use dbus generic interface to trigger `xdg_portal` for screen cast. On KDE this can be used to create a virtual screen.
- [dbus_virtual_monitor_mutter](dbus_virtual_monitor_mutter.py): Use dbus Mutter interface to create a set of virutal monitors on Gnome.