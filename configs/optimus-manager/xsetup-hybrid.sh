#!/bin/sh

# Everything you write here will be executed by the display manager when setting up the login screen in "hybrid" mode.
xrandr --setprovideroutputsource NVIDIA-G0 modesetting
xrandr --auto
