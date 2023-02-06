#!/bin/bash




main(){
    root
    update_system
    after_install
    install_packages
    install_theme
	install_widgets
	kde_setup
	soft_config
	zsh_config
	vdhcoapp
	if [ "${DISTRO}" = '"opensuse-tumbleweed"' ]; then
        chia_blockchain
    fi
}

main

# Zaverecna sprava
echo
msg="${color} ${hash} Instalacia ukoncena :D ${hash} ${endcolor}"
printf "%*s\n" $(((${#msg}+${columns})/2)) "${msg}"
