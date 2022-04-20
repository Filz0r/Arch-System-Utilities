#!/usr/bin/env bash
set -euo pipefail

sed -n '/###KEYBIDINGS/,/### WORKSPACES/p' \
    /home/filipe/.config/i3/config | \
    sed -e 's/bindsym //' \
    -e '/^XF/d' \
    -e '/^$/d' \
    -e "s/\$mod+/Super + /" \
    -e 's/exec.*//' \
    -e 's/resize.*//' \
    -e 's/move.*//' \
    -e '/### WORKSPACES/d' \
    -e '/## Special keys/,/## ACTIONS/d' | \
    yad --text-info --back=#282c34 --fore=#46d9ff --geometry=1000x1080
