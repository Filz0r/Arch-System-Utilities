#!/usr/bin/env bash

# This script was written to give gpu utilization to plolybar on laptops with nvidia optimus support,
# this means that the GPU will only be pooled when in "NVIDIA" mode and nothing else, there's a separete
# script similar to this one that either swaps the modes you are in, or opens monitoring tools,
# together they work as an "extension" for polybar that allows you to check on your gpu and change graphic modes
GPU_MODE=$(optimus-manager --print-mode | awk '{print $5'})
case $GPU_MODE in
    hybrid)
        echo "hybrid"
        ;;
    nvidia)
        nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk -F ", " '{print $1"%"}'
        exit
        ;;
    integrated)
        echo "iGPU"
        exit
        ;;
esac

# used to send queries to dunst
#message=$(nvidia-smi --query-gpu=temperature.gpu,memory.used,utilization.gpu --format=csv,noheader,nounits | awk -F ", " '{print "Temp:", ""$1"","C | Mem:", ""$2"", "MiB | Load:", ""$3"", "%"}')
#notify-send --icon=video-display Info "$message"
