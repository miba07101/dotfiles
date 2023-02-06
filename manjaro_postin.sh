#!/bin/bash
# Verzia systemu - distribucia
DISTRO=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)

# Pracovny priecinok
CWD=$(pwd)

# Docasny priecinok v pracovnom priecinku
[[ ! -d ${CWD}/Temp ]] && mkdir -p ${CWD}/Temp
TEMP_DIR=$(cd ${CWD}/Temp && pwd)

# Nastavenie vystupov / farba a symboly
columns=$(tput cols)
color=$'\e[1;35m'
endcolor=$'\e[0m'
hash="################################"
star="******************************"
ex="!!!!!!!!!!!!!!!!!!!!!"

# Alias pre pamac
UPDATE='update --force-refresh --enable-downgrade --aur --no-confirm'
INSTALL='install --no-confirm'
BUILD='build'

# Uvodna sprava
echo
msg="${color} ${hash} Zacinam instalaciu a nastavenia ${hash} ${endcolor}"
printf "%*s\n" $(((${#msg}+${columns})/2)) "${msg}"
sleep 1

# root(){
# Zisti ci som ROOT, ak nie tak zadam heslo
# if [[ "${UID}" -ne 0 ]]
# then
#     echo
#     echo "${color} Enter ROOT password: ${endcolor}"
#     read mypassword
# else
#     echo
#     echo "${color}  You are ROOT user ${endcolor}"
#     echo
# fi
# }

update_system(){
# ------------------------------------------------------------------------
# System upgrade/update
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} UPDATE SYSTEM ${hash} ${endcolor}"
sleep 1
echo

sudo pamac ${UPDATE}
}

after_install(){
echo
echo "${color} ${hash} AFTER INSTALL ${hash} ${endcolor}"
sleep 1
echo
# ------------------------------------------------------------------------
# Dissable GRUB delay
# ------------------------------------------------------------------------
echo
echo "${color} ${star} GRUB setup ${star} ${endcolor}"
sleep 1
echo

# nacitam aktualnu hodnotu GRUB_TIMEOUT a zmenim ju na 0
grub_timeout=$(grep -i "GRUB_TIMEOUT=" /etc/default/grub)
sudo sed -i 's/'${grub_timeout}'/GRUB_TIMEOUT=0/g' /etc/default/grub

# Po zmene v /etc/default/grub, updatnem hlavny configuracny subor
sudo update-grub

# ------------------------------------------------------------------------
# Znizi hodnotu Swappiness zo 60 na 10
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Swappiness setup ${star} ${endcolor}"
sleep 1
echo

swapp_file="/etc/sysctl.d/100-manjaro.conf"
[[ ! -f ${swapp_file} ]] && sudo touch ${swapp_file}
echo wm.swappiness=10 | sudo tee -a ${swapp_file}

# ------------------------------------------------------------------------
# Enable TRIM for SSD
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Enable TRIM for SSD ${star} ${endcolor}"
sleep 1
echo

sudo systemctl enable fstrim.timer

# ------------------------------------------------------------------------
# Zmena rozlisenia obrazovky ak je pripojeny notebook k TV
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Resolution TV setup ${star} ${endcolor}"
sleep 1
echo

resTV_file="/usr/share/sddm/scripts/Xsetup"
[[ ! -f ${resTV_file} ]] && sudo touch ${resTV_file}
# HDMI-0 je vystup pre TV, LVDS - je vystup obrazovky notebooku
echo xrandr --output HDMI-0 --primary --mode 1360x768 --output LVDS --off | sudo tee -a ${resTV_file}

}

install_packages(){
echo
echo "${color} ${hash} INSTALL PACKAGES ${hash} ${endcolor}"
sleep 1
echo

# ------------------------------------------------------------------------
# Instalacia programov z manjaro repository
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Main packages installing ... ${star} ${endcolor}"
sleep 1
echo

PKGS=(
'thunderbird'
'thunderbird-i18n-sk'
'latte-dock'
'onlyoffice-desktopeditors'
'inkscape'
'kolourpaint'
'remmina'
'libvncserver' # potrebne pre remminu
'newsflash'
'bleachbit'
'deluge-gtk'
'mpv'
'handbrake'
'nitroshare'
'appimagelauncher'
'kvantum-qt5'
'gvim' # vim s clipboard funkciou
'powerline-fonts'
'flake8'
'autopep8'
'python-black'
'zsh'
'starship'
'fd'
'exa'
'ncdu'
'git'
'curl'
'translate-shell'
'jq' # potrebne pre yahoo finance skript: $HOME/OneDrive/Linux/Skripty/ticker.sh
'zathura'
'zathura-pdf-poppler'
'ranger' # file manager
'ueberzug' # ranger - zobrazuje obrazky
'ffmpegthumbnailer' # ranger - zobrazuje video preview
'highlight' # ranger - meni colorscheme
'lua' # suvisi s highlight
'perl-image-exiftool' # ranger - meta info o video suboroch
# 'iwd' #wifi network daemon = pre pc JONSBO aby wifi nabehla hned po spusteni OS
)

for PKG in "${PKGS[@]}"; do
    echo "Installing ${PKG}"
    sleep 1
    sudo pamac ${INSTALL} ${PKG}
done

echo
echo "${color} ${star} Main packages installed OK ${star} ${endcolor}"
sleep 1
echo

# ------------------------------------------------------------------------
# AUR repository
# ------------------------------------------------------------------------
echo
echo "${color} ${star} AUR repository installing ... ${star} ${endcolor}"
sleep 1
echo

AUR_PKGS=(
'onedrive-abraunegg'
'brave-bin'
'birdtray'
'stacer'
'hypnotix'
'freetube-bin'
'jdownloader2'
'plasma5-applets-eventcalendar'
'qloud-qtcharts' # potrebne pre yapstock widget
'chia-bin'
'megasync-bin'
'vdhcoapp-bin'
# 'libunity' # robi problem takze radsej nie
)

for AUR_PKG in "${AUR_PKGS[@]}"; do
    echo "Installing ${AUR_PKG}"
    sleep 1
    sudo pamac ${BUILD} --no-confirm ${AUR_PKG}
done

echo
echo "${color} ${star} AUR packages installed OK ${star} ${endcolor}"
sleep 1
echo

# ------------------------------------------------------------------------
# Ledger Live
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Ledger Live installing ... ${star} ${endcolor}"
sleep 1
echo

git_url="https://github.com/LedgerHQ/ledger-live-desktop/releases/latest"
latest_release=$(curl -L -s -H 'Accept: application/json' ${git_url})
latest_version=$(echo ${latest_release} | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
down_url="https://github.com/LedgerHQ/ledger-live-desktop/releases/download/${latest_version}/ledger-live-desktop-${latest_version#v}-linux-x86_64.AppImage"
wget ${down_url} -P ${TEMP_DIR}

# integruje Ledger Live appimage do systemu (musi byt nainstalovany AppImageLauncher)
ail-cli integrate ${TEMP_DIR}/ledger-live-desktop-${latest_version#v}-linux-x86_64.AppImage

# nastavenie Ledger na linuxe aby citalo usb
wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash

# rm -rf ${TEMP_DIR}/*.AppImage
sleep 1

# ------------------------------------------------------------------------
# Spusti latte, thunderbird a freetube aby sa vytvorili priecinky
# ------------------------------------------------------------------------
echo
nohup latte-dock &> /dev/null &
nohup thunderbird &> /dev/null &
nohup freetube &> /dev/null &

}

install_theme(){
echo
echo "${color} ${hash} THEME, ICONS, CURSORS INSTALL ${hash} ${endcolor}"
echo
echo
echo "${color} ${star} Nordic theme installing ... ${star} ${endcolor}"
sleep 1
echo

# ------------------------------------------------------------------------
# Nordic tema
# ------------------------------------------------------------------------
# globalna tema
git_url="https://github.com/EliverLara/Nordic-kde.git"
git clone ${git_url} ${TEMP_DIR}/Nordic-desktoptheme
# aurorre, color-schemes ....
git_url="https://github.com/EliverLara/Nordic.git"
git clone ${git_url} ${TEMP_DIR}/Nordic
# GTK tema
git_url="https://github.com/EliverLara/Nordic/releases/latest"
latest_release=$(curl -L -s -H 'Accept: application/json' ${git_url})
latest_version=$(echo ${latest_release} | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
down_url="https://github.com/EliverLara/Nordic/releases/download/${latest_version}/Nordic.tar.xz"
wget ${down_url} -P ${TEMP_DIR}

# Vytvori cielove priecinky
PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme/Nordic"
AURORAE_DIR="$HOME/.local/share/aurorae/themes"
SCHEMES_DIR="$HOME/.local/share/color-schemes"
LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel"
KVANTUM_DIR="$HOME/.config/Kvantum"
GTK_DIR="$HOME/.themes"

# zisti ci priecinky existuju, ak nie tak ich vytvori
[[ ! -d ${PLASMA_DIR} ]] && mkdir -p ${PLASMA_DIR}
[[ ! -d ${AURORAE_DIR} ]] && mkdir -p ${AURORAE_DIR}
[[ ! -d ${SCHEMES_DIR} ]] && mkdir -p ${SCHEMES_DIR}
[[ ! -d ${LOOKFEEL_DIR} ]] && mkdir -p ${LOOKFEEL_DIR}
[[ ! -d ${KVANTUM_DIR} ]] && mkdir -p ${KVANTUM_DIR}
[[ ! -d ${GTK_DIR} ]] && mkdir -p ${GTK_DIR}

# nakopiruje potrebne subory
cp -rf ${TEMP_DIR}/Nordic-desktoptheme/*                ${PLASMA_DIR}
cp -rf ${TEMP_DIR}/Nordic/kde/aurorae/*                 ${AURORAE_DIR}
cp -rf ${TEMP_DIR}/Nordic/kde/colorschemes/*.colors     ${SCHEMES_DIR}
cp -rf ${TEMP_DIR}/Nordic/kde/plasma/look-and-feel/*    ${LOOKFEEL_DIR}
cp -rf ${TEMP_DIR}/Nordic/kde/kvantum/*                 ${KVANTUM_DIR}
tar xf ${TEMP_DIR}/Nordic.tar.xz --directory ${GTK_DIR}

# nainstaluje Nordic Solid KDE
# musi byt pre EXPAND aliases, aby tento script vedel pouzit aliases
shopt -s expand_aliases
alias knshandler="/usr/lib/kf5/kpackagehandlers/knshandler"

knshandler kns://plasma-themes.knsrc/api.kde-look.org/1416702
echo "${color} Nordic Solid KDE installed - OK ${endcolor}"

# nastavenie KVANTUM
kvantum_kvconfig="${KVANTUM_DIR}/kvantum.kvconfig"
[[ ! -f ${kvantum_kvconfig} ]] && touch ${kvantum_kvconfig}

cat << "EOF" > ${kvantum_kvconfig}
[General]
theme=Nordic-Solid
EOF

# ------------------------------------------------------------------------
# TELA circle icons
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Tela circle icons installing ... ${star} ${endcolor}"
sleep 1
echo

git_url="https://github.com/vinceliuice/Tela-circle-icon-theme.git"
git clone ${git_url} ${TEMP_DIR}/Tela-circle
${TEMP_DIR}/Tela-circle/./install.sh "ubuntu"

sleep 1

# ------------------------------------------------------------------------
# We10OSX cursors
# ------------------------------------------------------------------------
echo
echo "${color} ${star} We10XOS cursors ... ${star} ${endcolor}"
sleep 1
echo

git_url="https://github.com/yeyushengfan258/We10XOS-cursors.git"
git clone ${git_url} ${TEMP_DIR}/We10XOS-cursors

CURSORS_DIR="$HOME/.icons/We10XOS-cursors"
[[ ! -d ${CURSORS_DIR} ]] && mkdir -p ${CURSORS_DIR}

cp -rf ${TEMP_DIR}/We10XOS-cursors/dist/*    ${CURSORS_DIR}

sleep 1
}

install_widgets(){
echo
echo "${color} ${hash} WIDGETS INSTALL ${hash} ${endcolor}"
echo
echo
echo "${color} ${star} Yapstocks installing ... ${star} ${endcolor}"
sleep 1
echo

# ------------------------------------------------------------------------
# Yapstocks
# ------------------------------------------------------------------------
git_url="https://github.com/librehat/yapstocks.git"
git clone ${git_url} ${TEMP_DIR}/Yapstocks

YAP_DIR="$HOME/.local/share/plasma/plasmoids/com.librehat.yapstocks"
[[ ! -d ${YAP_DIR} ]] && mkdir -p ${YAP_DIR}

cp -rf ${TEMP_DIR}/Yapstocks/plasmoid/* ${YAP_DIR}

sleep 1

# ------------------------------------------------------------------------
# Latte spacer
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Late spacer installing ... ${star} ${endcolor}"
sleep 1
echo

git_url="https://github.com/psifidotos/applet-latte-spacer.git"
git clone ${git_url} ${TEMP_DIR}/applet-latte-spacer

SPACER_DIR="$HOME/.local/share/plasma/plasmoids/org.kde.latte.spacer"
[[ ! -d ${SPACER_DIR} ]] && mkdir -p ${SPACER_DIR}

cp -rf ${TEMP_DIR}/applet-latte-spacer/* ${SPACER_DIR}

sleep 1

# ------------------------------------------------------------------------
# Systemtray
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Systemtray installing ... ${star} ${endcolor}"
sleep 1
echo

git_url="https://github.com/psifidotos/plasma-systray-latte-tweaks.git"
git clone ${git_url} ${TEMP_DIR}/plasma-systray-latte-tweaks

TRAY_DIR="$HOME/.local/share/plasma/plasmoids/"

cp -rf ${TEMP_DIR}/plasma-systray-latte-tweaks/{org.kde.plasma.private.systemtray,org.kde.plasma.systemtray} ${TRAY_DIR}

sleep 1
}

kde_setup(){
echo
echo "${color} ${hash} KDE SETUP ${hash} ${endcolor}"
echo

# ------------------------------------------------------------------------
# Config subory
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Config copy ... ${star} ${endcolor}"
sleep 1
echo

rm -rfv $HOME/.config/autostart
cp -rfv ${CWD}/config/* $HOME/.config/

# ------------------------------------------------------------------------
# Dolphin_konsole subory
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Dolphin, Konsole copy ... ${star} ${endcolor}"
sleep 1
echo

cp -rfv ${CWD}/dolphin_konsole/{dolphin,konsole} $HOME/.local/share/kxmlgui5/

cp -rfv ${CWD}/dolphin_konsole/konsole-theme/* $HOME/.local/share/konsole/

# ------------------------------------------------------------------------
# Latte
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Latte copy ... ${star} ${endcolor}"
sleep 1
echo

cp -rfv ${CWD}/latte/* $HOME/.config/latte/
}

soft_config(){
echo
echo "${color} ${hash} SOFTWARE CONFIG ${hash} ${endcolor}"
echo

# ------------------------------------------------------------------------
# MPV
# ------------------------------------------------------------------------
echo
echo "${color} ${star} MPV config ... ${star} ${endcolor}"
sleep 1
echo

chmod +x ${CWD}/mpv/mpv-single-instance/{mpv-single,mpv-single.desktop}
sudo cp -rfv ${CWD}/mpv/mpv-single-instance/mpv-single /usr/bin/
sudo cp -rfv ${CWD}/mpv/mpv-single-instance/mpv-single.desktop /usr/share/applications/

[[ ! -d $HOME/.config/mpv ]] && mkdir -p $HOME/.config/mpv
cp -rfv ${CWD}/mpv/{script-opts,scripts,input.conf,mpv.conf} $HOME/.config/mpv/

# ------------------------------------------------------------------------
# Firefox subory
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Firefox config ... ${star} ${endcolor}"
sleep 1
echo

cp -rfv ${CWD}/firefox/{chrome,extensions,prefs.js} $HOME/.mozilla/firefox/*.default-release/

# ------------------------------------------------------------------------
# Thunderbird subory
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Thunderbird config ... ${star} ${endcolor}"
sleep 1
echo

cp -rfv ${CWD}/thunderbird/{extensions,prefs.js} $HOME/.thunderbird/*.default-release/

# ------------------------------------------------------------------------
# Onedrive subory
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Onedrive config ... ${star} ${endcolor}"
sleep 1
echo

cp -rfv ${CWD}/onedrive/onedrive_startup.sh.desktop $HOME/.config/autostart/

[[ ! -d $HOME/.config/old-autostart-scripts ]] && mkdir -p $HOME/.config/old-autostart-scripts
chmod +x ${CWD}/onedrive/onedrive_startup.sh
cp -rfv ${CWD}/onedrive/onedrive_startup.sh $HOME/.config/old-autostart-scripts/

# ------------------------------------------------------------------------
# Freetube subory
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Freetube config ... ${star} ${endcolor}"
sleep 1
echo

cp -rfv ${CWD}/freetube/{profiles.db,settings.db} $HOME/.config/FreeTube/

# ------------------------------------------------------------------------
# Vim_bash_zsh subory
# ------------------------------------------------------------------------
echo
echo "${color} ${star} VIMRC, BASHRC, ZSHRC config ... ${star} ${endcolor}"
sleep 1
echo

cp -rfv ${CWD}/vim_bash_zsh/vimrc $HOME/.vimrc
cp -rfv ${CWD}/vim_bash_zsh/bashrc $HOME/.bashrc
cp -rfv ${CWD}/vim_bash_zsh/zshrc $HOME/.zshrc

# cd ${CWD}/vim_bash_zsh
# for file in *; do
#     cp -rfv $file $HOME/.${file}
# done
# cd ${CWD}

# v priecinku vyhlada len subory (files), ktore nemaju bodku (! -name "*.*") pomocou funkcie find
# path="${CWD}/vim_bash_zsh/"
# file=$(find ${path} -type f ! -name "*.*")
#
# premenuje vsetky subory na skryte a skopiruje do $HOME/
# for meno in ${file}; do
#     rename=${meno#${path}}
#     mv -n "${rename}" ".${rename}"
#     cp -rf ".${rename}" $HOME/
# done

# ------------------------------------------------------------------------
# Ikony
# ------------------------------------------------------------------------
echo
echo "${color} ${star} ICONS Megasync, Yapstock, Taskbar copy ... ${star} ${endcolor}"
sleep 1
echo

# megasync - $HOME/.local/share/icons/hicolor
himega_dir="$HOME/.local/share/icons/hicolor"
[[ ! -d ${himega_dir} ]] && mkdir -p ${himega_dir}
7z x -y ${CWD}/icons/megasync_hicolor_icons.7z -o${himega_dir}/

## refresne ikony
sudo gtk-update-icon-cache -f /usr/share/icons/hicolor/

# taskbar - $HOME/.local/share/plasma/desktoptheme/Nordic/icons
task_dir="$HOME/.local/share/plasma/desktoptheme/Nordic"
7z x -y ${CWD}/icons/taskbar_icons.7z -o${task_dir}
task_dir2="$HOME/.local/share/plasma/desktoptheme/Nordic-Solid"
7z x -y ${CWD}/icons/taskbar_icons.7z -o${task_dir2}

# Yapstock - $HOME/.local/share/plasma/plasmoids/com.librehat.yapstocks/contents/ui/
yap_dir="$HOME/.local/share/plasma/plasmoids/com.librehat.yapstocks/contents/ui"
7z x -y ${CWD}/icons/yapstock_icons.7z -o${yap_dir}

# ------------------------------------------------------------------------
# Win10 fonty
# ------------------------------------------------------------------------
echo
echo "${color} ${star} WIN10 Fonts copy ... ${star} ${endcolor}"
sleep 1
echo

# win10 fonts - $HOME/.local/share/fonts
win10_dir="$HOME/.local/share"
7z x -y ${CWD}/win10_fonts/win_fonts.7z -o${win10_dir}/

# ------------------------------------------------------------------------
# Starship
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Starship config ... ${star} ${endcolor}"
sleep 1
echo

starship_toml="$HOME/.config/starship.toml"
[[ ! -f ${starship_toml} ]] && touch ${starship_toml}

cat << "EOF" > ${starship_toml}
[line_break]
disabled = true
EOF

sleep 1
}

zsh_config(){
# ------------------------------------------------------------------------
# ZSH setup
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} ZSH CONFIG ${hash} ${endcolor}"
sleep 1
echo

# Nastavi zsh ako predvoleny shell namiesto bash
chsh -s $(which zsh)

# # Naistaluje 'zsh-autosuggestions' plugin
# [[ ! -d $HOME/.zsh ]] && mkdir -p $HOME/.zsh
# git_url="https://github.com/zsh-users/zsh-autosuggestions.git"
# git clone ${git_url} $HOME/.zsh/zsh-autosuggestions

# sleep 1
}


main(){
#     root
    update_system
    after_install
    install_packages
    install_theme
    install_widgets
    kde_setup
    soft_config
    zsh_config
}

main

# Zaverecna sprava
echo
msg="${color} ${hash} Instalacia ukoncena :D ${hash} ${endcolor}"
printf "%*s\n" $(((${#msg}+${columns})/2)) "${msg}"
