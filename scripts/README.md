# Community Scripts

An assortment of community provided by the community. Each folder will contain a description of how to use the scripts on it.

- EVDI scripts:
- Immersed setup:
  - Create desktop shortcut
  - Initial setup
- Intel scripts

Is highly recommended run Immersed in a loop to avoid use the physical monitor in case of application crash.
```bash
#!/bin/bash

while :
do
    echo "Immersed starting"
    ./Immersed-x86_64.AppImage
    echo "Immersed stopped"
    sleep 1
done
```