#!/bin/bash

# Nastavenie oznameni
color=$'\e[1;35m'
endcolor=$'\e[0m'
star="--------------------------------"

info(){
    printf "${color}${star}${endcolor}\n"
    printf "${color} $1 ${endcolor}\n"
    printf "${color}${star}${endcolor}\n"
    # printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

firefox(){
    info "SETUP FIREFOX"
    if [[ -d ${HOME}/.mozilla ]]; then
      ln -sf ${HOME}/.dotfiles/firefox/bookmarkbackups   ${HOME}/.mozilla/firefox/*.default-release/bookmarkbackups
      ln -sf ${HOME}/.dotfiles/firefox/chrome            ${HOME}/.mozilla/firefox/*.default-release/chrome
      ln -sf ${HOME}/.dotfiles/firefox/extensions        ${HOME}/.mozilla/firefox/*.default-release/extensions
      ln -sf ${HOME}/.dotfiles/firefox/user.js           ${HOME}/.mozilla/firefox/*.default-release/user.js
    else
        echo "Starting Firefox"
        wezterm -e "firefox" &
        echo "Run this script again"
    fi
}

thunderbird(){
    info "SETUP THUNDERBIRD"
    if [[ -d ${HOME}/.thunderbird ]]; then
      ln -sf ${HOME}/.dotfiles/thunderbird/extensions    ${HOME}/.thunderbird/*.default-esr/extensions
      ln -sf ${HOME}/.dotfiles/thunderbird/user.js       ${HOME}/.thunderbird/*.default-esr/user.js
    else
        echo "Starting Thunderbird"
        wezterm -e "thunderbird" &
        echo "Run this script again"
    fi

    info "SETUP BIRDTRAY"
    ln -sf ${HOME}/.dotfiles/config/birdtray-config.json  ${HOME}/.config/birdtray-config.json
}

freetube(){
    info "SETUP FREETUBE"
    if [[ -d ${HOME}/.config/FreeTube ]]; then
      ln -sf ${HOME}/.dotfiles/freetube/playlists.db    ${HOME}/.config/FreeTube/playlists.db
      ln -sf ${HOME}/.dotfiles/freetube/profiles.db    ${HOME}/.config/FreeTube/profiles.db
      ln -sf ${HOME}/.dotfiles/freetube/settings.db    ${HOME}/.config/FreeTube/settings.db
    else
        echo "Starting FreeTube"
        wezterm -e "freetube" &
        echo "Run this script again"
    fi
}

scripts(){
    info "SETUP SCRIPTS FOR OBSIDIAN NOTES"
    ln -sf ${HOME}/OneDrive/Projekty/Linux/Skripty/obsidian-create-note.sh  ${HOME}/.local/bin/obsidian-create-note.sh
    chmod +x ${HOME}/.local/bin/obsidian-create-note.sh
    ln -sf ${HOME}/OneDrive/Projekty/Linux/Skripty/obsidian-kategorize-notes.sh  ${HOME}/.local/bin/obsidian-kategorize-notes.sh
    chmod +x ${HOME}/.local/bin/obsidian-kategorize-notes.sh
}

main(){
    firefox
    thunderbird
    freetube
    scripts
}

main

info "DONE :)"
