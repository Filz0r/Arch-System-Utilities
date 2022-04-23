#/usr/bin/env bash
####
####
## Variables
####
####
CONNECTIONS=$(xrandr | grep " connected " | awk '{ print $1}' | wc -l)
ACTIVE_SINK=$(pactl info | grep "Default Sink: " | cut -d" " -f3)
DEFAULT_CARD="alsa_card.pci-0000_00_1f.3"
USB_DOCK_SINK="alsa_output.usb-DisplayLink_LAPDOCK_U3D2338448570-02.analog-stereo"
NVIDIA_SINK="alsa_output.pci-0000_01_00.1.hdmi-stereo"
GPU_MODE=$(optimus-manager --print-mode | awk '{print $5'})
####
####
## Audio Functions
####
####
swap_audio_profile() {
    # This function is only ran when the xorg swap mode function is called so that audio is always routed via hdmi
    case $CONNECTIONS in
        1)
            pactl set-card-profile "$DEFAULT_CARD" output:analog-stereo
            ;;
        3)
            pactl set-card-profile "$DEFAULT_CARD" output:hdmi-stereo
            ;;
    esac
}
swap_audio() {
 case $ACTIVE_SINK in
     "$NVIDIA_SINK")
     pactl set-default-sink "$USB_DOCK_SINK"
     ;;
     "$USB_DOCK_SINK")
     pactl set-default-sink "$NVIDIA_SINK"
     ;;
     *)
     echo "Invalid option, goodbye!"
     ;;
 esac
 polybar-msg hook volume 1
 exit 0
}
change_volume() {
 pactl set-sink-volume "$ACTIVE_SINK" "$1"
 polybar-msg hook volume 1
 exit 0
}
mute_sink() {
 pactl set-sink-mute "$ACTIVE_SINK" toggle
 polybar-msg hook volume 1
 exit 0
}
####
####
## Display Configuration
####
####
xorg_displays_laptop_mode(){
    case $GPU_MODE in 
        nvidia)
                xrandr --output eDP-1-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --refresh 144 \
                --output DP-0 --off --output DP-1-1 --off 
                ;;
        hybrid)
                xrandr --output eDP1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --refresh 144 \
                 --output DP-1-0 --off --output DP1 --off 
                ;;
        integrated)
                xrandr --output eDP1 --mode 1920x1080 --pos 0x0 --rotate normal --refresh 144
                ;;

    esac
}
xorg_displays_desktop_mode(){
    case $GPU_MODE in 
        hybrid)
            xrandr --output eDP1  --mode 1920x1080 --pos 0x525 --rotate normal --refresh 144  \
                --output DP-1-0 --primary --mode 2560x1080 --pos 1920x525 --rotate normal --refresh 75  \
                --output DP1 --mode 1920x1080 --pos 4480x0 --rotate left
            ;;
        nvidia)
            xrandr --output eDP-1-1  --mode 1920x1080 --pos 0x525 --rotate normal --refresh 144  \
                --output DP-0 --primary --mode 2560x1080 --pos 1920x525 --rotate normal --refresh 75  \
                --output DP-1-1 --mode 1920x1080 --pos 4480x0 --rotate left
            ;;
        integrated)
            xrandr --output eDP1 --mode 1920x1080 --pos 0x525 --rotate normal --refresh 144  \
                    --output DP1 --mode 1920x1080 --pos 1920x525 --rotate left --refresh 60
            ;;
        *)
            exit 1
            ;;
    esac
}
swap_modes_xorg(){
    case $CONNECTIONS in
        1)
            xorg_displays_laptop_mode
            ;;
        2)  
            xorg_displays_desktop_mode
            ;;
        3)  
            xorg_displays_desktop_mode
            ;;
        *)
            echo "invalid number of monitors connected"
            exit 1
            ;;
    esac
    setxkbmap -option caps:escape
    setxkbmap -layout pt
    swap_audio_profile
    nitrogen --restore &
}
####
####
## Window Manager functions
####
####
app_launch() {
    ##  Apps that run at launch
    picom --experimental-backends --config /home/filipe/.config/picom/picom.conf & disown
    nm-applet & disown
    blueman-applet & disown
    numlockx & disown
    nitrogen --restore & disown
    transmission-remote-gtk & disown
    bitwarden-desktop & disown
    kdeconnect-indicator & disown
    dunst & disown
    /usr/bin/emacs --daemon --with-x-toolkit=lucid & disown
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & disown
    redshift-gtk -l 38.61667:-9.08333 & disown
    flameshot & disown
    nextcloud & disown
}
polybar_handler() {
    case "$1" in
        "launch")
            for m in $(polybar --list-monitors | cut -d":" -f1); do
                MONITOR=$m polybar --reload topbar &
            ##sleep 1
            done
            ;;
        "reload")
            polybar-msg cmd restart
            ;;
        restart)
            killall polybar
            polybar_handler launch
            ;;
        *)
            echo "me broke cuz u idiot"
            ;;
    esac
}	
####
####
## Main Function
####
####
case $1 in
    i3_init) 
        swap_modes_xorg
        polybar_handler "launch"
        app_launch
        ;;
    xswap)
        swap_modes_xorg
        polybar_handler "restart"
        ;;
    polybar)
        polybar_handler "launch"
        ;;
    change-volume)
        change_volume "$2"
        ;;
    swap-audio-profile)
        swap_audio_profile
        ;;
    mute-sink)
        mute_sink
        ;;
    swap-audio)
        swap_audio
        ;;
    poly-restart)
        polybar_handler restart
        ;;
    debug-hybrid)
        xrandr --output eDP1  --mode 1920x1080 --pos 0x525 --rotate normal --refresh 144 \
            --output DP-1-0 --primary --mode 2560x1080 --pos 1920x525 --rotate normal --refresh 75 \
            --output DP1 --mode 1920x1080 --pos 4480x0 --rotate left
        setxkbmap -option caps:escape
        setxkbmap -layout pt
        swap_audio_profile
        app_launch
        polybar_handler "launch"
        ;;
        
    *)
        echo "This is not a valid option, valid options are:
        - i3_init
        - xwap
        - polybar
        - change-volume
        - swap-audio-profile
        - mute-sink"
        ;;

esac

#xrandr --output eDP-1 --mode 1920x1080 --pos 0x0 --rotate normal --refresh 144 \
#   --output DP1 --mode 2560x1080 --pos 1920x0 --rotate normal --refresh 75 --primary
#xrandr --output eDP1 --mode 1920x1080 --pos 0x0 --rotate normal --refresh 144  \
#   --output DP1 --mode 1920x1080 --pos 1920x0 --rotate normal --refresh 60
