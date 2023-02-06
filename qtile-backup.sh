#!/usr/bin/env bash

# Datum
DATE=$(date +%d-%m-%Y)

# Verzia systemu - distribucia
DISTRO=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)

# Graficke vystupy
columns=$(tput cols)
color=$'\e[1;35m'
endcolor=$'\e[0m'
star="$color ******************************************** $endcolor"

echo
msg="$color Zacinam zalohovat $endcolor"
printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
printf "%*s\n" $(((${#msg}+$columns)/2)) "$msg"
printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
sleep 1

root(){
    # Zisti ci som ROOT, ak nie tak zadam heslo
    if [[ ${UID} -ne 0 ]]
    then
      echo
      echo "Enter ROOT password:" #2>&1
      read mypassword
      echo
    else
      echo
      echo "You are ROOT user"
      echo
    fi
}

directories(){
    # Vytvori backup priecinky
    mkdir $HOME/qtile-backup-$DATE
    mkdir $HOME/qtile-backup-$DATE/home
    mkdir $HOME/qtile-backup-$DATE/config
    mkdir $HOME/qtile-backup-$DATE/skripty
    mkdir $HOME/qtile-backup-$DATE/firefox
    mkdir $HOME/qtile-backup-$DATE/mpv
    mkdir $HOME/qtile-backup-$DATE/salome

    HOME_DIR="$HOME/qtile-backup-$DATE/home"
    CONFIG_DIR="$HOME/qtile-backup-$DATE/config"
    SKRIPTY_DIR="$HOME/qtile-backup-$DATE/skripty"
    FIREFOX_DIR="$HOME/qtile-backup-$DATE/firefox"
    MPV_DIR="$HOME/qtile-backup-$DATE/mpv"
    SALOME_DIR="$HOME/qtile-backup-$DATE/salome"
}

home(){
    # Skopiruje zlozky z $HOME/ do HOME_DIR
    msg="$color Zalohujem home subory $endcolor"
    echo
    sleep 1
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    printf "%*s\n" $(((${#msg}+$columns)/2)) "$msg"
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    sleep 1
    echo

    cp -rfv $HOME/{.bashrc,.zprofile,.gtkrc-2.0,.newsboat,.ticker.yaml,.Xresources} $HOME_DIR

    # premenuje skryte subory v priecinku
    cd $HOME_DIR
    GLOBIGNORE=".:.."
    for file in .*; do
        mv -n "$file" "${file#.}"
    done
}

config(){
    # CONFIG - Skopiruje zlozky z $HOME/.config do CONFIG_DIR
    msg="$color Zalohujem .config subory $endcolor"
    echo
    sleep 1
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    printf "%*s\n" $(((${#msg}+$columns)/2)) "$msg"
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    sleep 1
    echo

    cp -rfv $HOME/.config/{dunst,gtk-2.0,gtk-3.0,kitty,nvim,qtile,qutebrowser,ranger,rofi,sioyek,zsh,mimeapps.list,starship.toml} $CONFIG_DIR
}

skripty(){
    # Skopiruje zlozky z $HOME/.local/bin do SKRIPTY
    msg="$color Zalohujem local/bin skripty $endcolor"
    echo
    sleep 1
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    printf "%*s\n" $(((${#msg}+$columns)/2)) "$msg"
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    sleep 1
    echo

    cp -rfv $HOME/.local/bin/translate.sh $SKRIPTY_DIR
}

firefox(){
    # FIREFOX - Skopiruje zlozky z $HOME/.mozilla/firefox/*.default-release do FIREFOX_DIR
    msg="$color Zalohujem Firefox subory $endcolor"
    echo
    sleep 1
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    printf "%*s\n" $(((${#msg}+$columns)/2)) "$msg"
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    sleep 1
    echo

    cp -rfv $HOME/.mozilla/firefox/*.default-release/{chrome,extensions,bookmarkbackups,prefs.js} $FIREFOX_DIR
}

mpv(){
    # MPV - vytvori zlozku "mpv-single-instance a skopiruje zlozky z $HOME/.config do MPV_DIR
    msg="$color Zalohujem MPV subory $endcolor"
    echo
    sleep 1
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    printf "%*s\n" $(((${#msg}+$columns)/2)) "$msg"
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    sleep 1
    echo

    mkdir $MPV_DIR/mpv-single-instance
    cp -rfv $HOME/.local/bin/mpv-single $MPV_DIR/mpv-single-instance
    cp -rfv $HOME/.local/share/applications/mpv-single.desktop $MPV_DIR/mpv-single-instance
    cp -rfv $HOME/.config/mpv/{script-opts,scripts,input.conf,mpv.conf} $MPV_DIR
}

salome(){
    msg="$color Zalohujem Salome-meca subory $endcolor"
    echo
    sleep 1
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    printf "%*s\n" $(((${#msg}+$columns)/2)) "$msg"
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    sleep 1
    echo

    cp -rfv $HOME/.local/share/applications/salome-meca.desktop $SALOME_DIR
}

onedrive_backup(){
    msg="$color Zalohujem komplet na ONEDRIVE $endcolor"
    echo
    sleep 1
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    printf "%*s\n" $(((${#msg}+$columns)/2)) "$msg"
    printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
    sleep 1
    echo

    # presuniem skripty do OneDrive/Linux/Skripty
    mv -f $SKRIPTY_DIR/translate.sh $HOME/OneDrive/Linux/Skripty/
    rm -rfv $SKRIPTY_DIR

    BACKUP_DIR="$HOME/OneDrive/Linux/Qtile"

    [[ ! -d ${BACKUP_DIR} ]] && mkdir -p ${BACKUP_DIR}

    # odstrani len priecinky, ponecha subory
    # rm -rfv $BACKUP_DIR/*/

    cp -rfv $HOME/qtile-backup-$DATE/* ${BACKUP_DIR}
}

remove_temporary(){
    # odstrani zlozku po nahrati na ONEDRIVE
    rm -rfv $HOME/qtile-backup-$DATE
}

main(){
    # root
    directories
    home
    config
    skripty
    firefox
    mpv
    salome
    onedrive_backup
    remove_temporary
}

main

msg="$color Zaloha ukoncena :) $endcolor"
echo
echo
printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
printf "%*s\n" $(((${#msg}+$columns)/2)) "$msg"
printf "%*s\n" $(((${#star}+$columns)/2)) "$star"
