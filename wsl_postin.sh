#!/bin/bash



main(){
    root
    update_system
    install_packages
    zsh_config
    # copy_files
    # python
    python-neovim
    # Live-server
    # gnome
    # appimage-launcher
    # freecad
    # salome-meca
    # postgresql
    dotfiles
}

main

# Zaverecna sprava
echo
msg="${color} ${hash} Instalacia ukoncena :D ${hash} ${endcolor}"
printf "%*s\n" $(((${#msg}+${columns})/2)) "${msg}"
