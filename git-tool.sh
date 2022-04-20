#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2094
# shellcheck disable=SC2128
SCRIPT_PATH="$BASH_SOURCE"
#
#   
#
while [ -L "${SCRIPT_PATH}" ]; do
  TARGET="$(readlink "${SCRIPT_PATH}")"
  if [[ "${TARGET}" == /* ]]; then
    SCRIPT_PATH="$TARGET"
  else
    SCRIPT_PATH="$(dirname "${SCRIPT_PATH}")/${TARGET}"
  fi
done
#
#   Constants for getting the location of the git repo on the filesystem
#
SOURCE_PATH=$(dirname "$SCRIPT_PATH")
GIT_PATH="$HOME/github"
USER_CONFS="$SOURCE_PATH/user-confs"
SYSTEM_CONFS="$SOURCE_PATH/system-confs"
#
#   Non-standard config paths are hard-coded 
#   ex: configs that don't live in a folder but instead on $HOME or /etc
#
PACMAN_CONF="$SOURCE_PATH/configs/pacman.conf"
MAKEPKG_CONF="$SOURCE_PATH/configs/makepkg.conf"
BASHRC="$SOURCE_PATH/configs/bashrc"
BASH_LOGOUT="$SOURCE_PATH/configs/bash_logout"
BASH_PROFILE="$SOURCE_PATH/configs/bash_profile"
ENVIROMENT_PATH="$SOURCE_PATH/configs/environment"
#USER_DIRS="$SOURCE_PATH/configs/user-dirs.dirs"
#USER_LOCALE="$SOURCE_PATH/configs/user-dirs.locale"
VIMRC="$SOURCE_PATH/configs/vimrc"
GTKRC="$SOURCE_PATH/configs/gtkrc"
XINITRC="$SOURCE_PATH/configs/xinitrc"


system_install() {
   sudo pacman -Sy --needed --noconfirm xorg nitrogen bash-completion yad arandr xorg-xrandr w3m \
        pavucontrol cpupower polkit polkit-gnome nvidia-prime nvidia-dkms nvidia nvidia-utils \
        nvidia-settings nvtop opencl-nvidia cuda bbswitch-dkms i3-gaps bluez bluez-utils \
        lxappearance ttf-font-awesome ttf-nerd-fonts-symbols iotop tree intel-undervolt \
        capitaine-cursors wireguard-tools lib32-nvidia-utils pipewire pipewire-pulse stress \
        s-tui bpytop zenity autotiling intel-gpu-tools nmap iperf3 nano numlockx dunst \
        ttf-fira-sans ttf-fira-mono ttf-fira-code otf-fira-mono network-manager-applet \
        blueman flameshot numlockx os-prober man-db pkgfile xclip

    echo "installing AUR helper"
    git clone https://aur.archlinux.org/yay.git "$GIT_PATH"
    cd "$GIT_PATH"yay || exit 1
    makepkg -si
    cd "$SOURCE_PATH" || exit 1
    sleep 2

    yay -S --nocleanmenu --nodiffmenu --noeditmenu --noupgrademenu --noremovemake polybar \
        polybar-spotify-module optimus-manager-git plymouth-git gruvbox-material-icon-theme-git \
        gruvbox-material-gtk-theme-git gruvbox-dark-icons-gtk gruvbox-dark-gtk mangohud gamemode \
        cpupower-gui i3exit picom-jonaburg-git otf-nerd-fonts-fira-mono timeshift goverlay
}

app_install() {
    sudo pacman -Sy --needed --noconfirm emacs nautilus discord firefox gparted \
        kdeconnect gimp transmission-remote-gtk chromium evolution neofetch \
        syncthing shellcheck ripgrep telegram-desktop gnome-disk-utility  \
        filezilla mpv bitwarden gnome-calculator redshift inkscape jq speedtest-cli \


    yay -S --nocleanmenu --nodiffmenu --noeditmenu --noupgrademenu --noremovemake \
        spotify vscodium mongodb-compass nvm github-desktop-bin exodus zoom \
        js-beautify
    
    echo
    echo "Installing Doom Emacs"
    git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
    ~/.emacs.d/bin/doom install
}

config_install() {
    cp "$BASHRC" "$HOME"/.bashrc
    cp "$BASH_PROFILE" "$HOME"/.bash_profile
    cp "$BASH_LOGOUT" "$HOME"/.bash_logout 
    cp "$XINITRC" "$HOME"/.xinitrc
    cp "$VIMRC" "$HOME"/.vimrc
    cp "$GTKRC" "$HOME"/.gtkrc-2.0
    conf_install_func "$USER_CONFS"
}

config_backup() {
    cp "$HOME"/.bashrc "$BASHRC"
    cp "$HOME"/.bash_profile "$BASH_PROFILE"
    cp "$HOME"/.bash_logout "$BASH_LOGOUT"
    cp "$HOME"/.xinitrc "$XINITRC"
    cp "$HOME"/.vimrc "$VIMRC"
    cp "$HOME"/.gtkrc-2.0 "$GTKRC"
    #cp "$HOME/.config/user-dirs.dirs" "$USER_DIRS"
    #cp "$HOME/.config/user-dirs.locale" "$USER_LOCALE"
    conf_backup_func "$USER_CONFS"
}

system_backup() {
    cp /etc/pacman.conf "$PACMAN_CONF"
    cp /etc/makepkg.conf "$MAKEPKG_CONF"
    #cp /etc/environment "$ENVIROMENT_PATH"
    conf_backup_func "$SYSTEM_CONFS"
}

sysconf_install() {
    #cp "$PACMAN_CONF" /etc/pacman.conf
    #cp "$MAKEPKG_CONF" /etc/makepkg.conf
    #cp /etc/environment "$ENVIROMENT_PATH"
    conf_install_func "$SYSTEM_CONFS"
}

sanity_check() {
    echo "I still do nothing!"
}

initial_config() {
    echo "Creating required folders"
    if [[ ! -d ~/.config ]]; then mkdir ~/.config; fi
    if [[ ! -d ~/Documents ]]; then mkdir ~/Documents; fi
    if [[ ! -d ~/Pictures ]]; then mkdir ~/Pictures; fi
    if [[ ! -d ~/Downloads ]]; then mkdir ~/Downloads; fi
    if [[ ! -d ~/Music ]]; then mkdir ~/Music; fi
    if [[ ! -d ~/Videos ]]; then mkdir ~/Videos; fi
    if [[ ! -d ~/Games ]]; then mkdir ~/Games; fi
    if [[ ! -d ~/github ]]; then mkdir ~/github; fi
    if [[ ! -d ~/code ]]; then mkdir ~/code; fi
    if [[ ! -d ~/.local ]]; then mkdir ~/.local; fi
    mkdir ~/.local/bin
    mkdir "$HOME"/Pictures/Wallpapers
    sudo pacman-key --init
    sudo pacman-key --populate archlinux
    sudo cp "$PACMAN_CONF" /etc/pacman.conf
    sudo cp "$MAKEPKG_CONF" /etc/makepkg.conf
    ln -s /home/filipe/.asu/git-tool.sh /home/filipe/.local/bin/abu
    ln -s /home/filipe/.asu/sys-tool.sh /home/filipe/.local/bin/asu
}

conf_backup_func() {
    while read -r line; do 
        #echo "$line"
        BASE_DIR=$(dirname "$line")
        FOLDER_NAME=$(basename "$BASE_DIR")
        if [[ ! -d "$SOURCE_PATH"/configs/"$FOLDER_NAME" ]]; then mkdir "$SOURCE_PATH"/configs/"$FOLDER_NAME"; fi
        cp "$line" "$SOURCE_PATH/configs/$FOLDER_NAME"
    done < "$1"
}

conf_install_func() {
    while read -r line; do 
        #echo "$line"
        BASE_DIR=$(dirname "$line")
        FOLDER_NAME=$(basename "$BASE_DIR")
        FILE_NAME=$(basename "$line")
        PATHS="$SOURCE_PATH/configs/$FOLDER_NAME/$FILE_NAME"
        if [ "$1" == "$SYSTEM_CONFS" ]; then
            if [[ ! -d "$BASE_DIR" ]]; then sudo mkdir "$BASE_DIR"; fi
            sudo cp "$PATHS" "$line"
        elif [ "$1" == "$USER_CONFS" ]; then
            if [[ ! -d "$BASE_DIR" ]]; then mkdir "$BASE_DIR"; fi
            cp "$PATHS" "$line"
        fi
    done < "$1"
}

case $1 in
    app-install)
        app_install
        ;;
    system-install)
        system_install
        ;;
    config-install)
        config_install
        ;;
    config-backup)
        config_backup
        ;;
    system-backup)
        system_backup
        ;;
    sys-config-install)
        sysconf_install
        ;;
    health-check)
        sanity_check
        ;;
    full-install)
        initial_config
        system_install
        app_install
        sysconf_install
        config_install
        ;;
    full-backup)
        config_backup
        system_backup
        ;;
    test)
        conf_install_func "$USER_CONFS"
        ;;
    *)
        echo "This is not a valid option, valid options are:
        - desktop-install     <- Installs the Desktop Enviroment/TWM and core system apps
        - app-install         <- Installs the desktop apps
        - config-install      <- Copies the configs from the git repo to the correct locations
        - config-backup       <- Backup config files to git repo
        - system-backup       <- Backup system config files to git repo
        - sys-config-install  <- Install system config files from git repo
        - first-step          <- The first step in installing everything, copies custom pacman.conf and makepkg.conf to correct location
        - health-check        <- WORK IN PROGRESS (will check if there are diferences between configs in repo from system configs)
        - full-install        <- Installs everything
        - full-backup         <- Copy every config file to git repo"
        ;;
esac