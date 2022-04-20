#!/usr/bin/env bash

GPU_MODE=$(optimus-manager --print-mode | awk '{print $5'})
case $1 in
    "monit")
        kitty -e nvtop
        ;;
    "settings")
        nvidia-settings
        ;;
    "swap")
        case $GPU_MODE in
            hybrid)
                systemctl reboot --boot-loader-entry=arch-nvidia.conf               
            ;;
            nvidia)
                systemctl reboot --boot-loader-entry=arch-hybrid.conf
            ;;
            integrated)
                systemctl reboot --boot-loader-entry=arch-nvidia.conf
            ;;
        esac
        ;;
    *)
        echo "No arguments passed!"
        exit
esac

