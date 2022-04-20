#!/usr/bin/env bash

GIT_PATH="$HOME/github"
echo "Installing keyboard backlight modules"
git clone https://github.com/tuxedocomputers/tuxedo-keyboard "$GIT_PATH"tuxedo-keyboard
cd "$GIT_PATH"tuxedo-keyboard || exit 1
make clean
make dkmsinstall
echo tuxedo_keyboard >> /etc/modules
modprobe tuxedo_keyboard
echo "options tuxedo_keyboard mode=0 brightness=25 color_left=0xFFFFFF color_center=0xFFFFFF color_right=0xFFFFFF" > /etc/modprobe.d/tuxedo_keyboard.conf
