#!/bin/bash

# zistim ci som na WSL
if [[ "$(</proc/version)" == *WSL* ]]; then
  WSL=1
  # Meno win pouzivatela
  WIN_USER=$(powershell.exe -NoProfile -NonInteractive -Command "\$env:UserName" | tr -d '\r')
else
  WSL=2
fi

# Verzia systemu - distribucia
DISTRO=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)

# Pracovny priecinok
CWD=$(pwd)

# Docasny priecinok v pracovnom priecinku
[[ ! -d ${HOME}/Temp ]] && mkdir -p ${HOME}/Temp
TEMP_DIR=$(cd ${HOME}/Temp && pwd)

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

# Alias pre zypper
REFRESH='--gpg-auto-import-keys refresh'
UPDATE='--non-interactive dist-upgrade --auto-agree-with-licenses'
INSTALL='--ignore-unknown install --auto-agree-with-licenses --allow-unsigned-rpm --allow-vendor-change --allow-downgrade'

# Zisti ci som ROOT, ak nie tak zadam heslo
root(){
    if [[ "${UID}" -ne 0 ]]
    then
        printf "${color}Enter ROOT password:${endcolor}\n"
        read mypassword
        echo
    else
        info "You are ROOT user"
        echo
    fi
}

update_system(){
    info "UPDATE SYSTEM"
    # Repository refresh
    sudo -S <<< ${mypassword} zypper ${REFRESH}

    # System upgrade/update
    sudo -S <<< ${mypassword} zypper ${UPDATE}
}

basic_packages(){
    info "INSTALL BASIC PACKAGES"
    BASIC_PKGS=(
        'neovim'
        'git'
        'zsh'
        'starship'
        'exa'
        'fd'
        'tealdeer' # tldr pre man pages
        'curl'
        'yt-dlp' # stahovanie youtube videi
        'ranger' # python terminal filemanager
        'xsel' # umoznuje copirovat adresu suboru z Rangera do systemoveho clipboardu
        'jq' # potrebne pre script ticker - cli JSON processor
        'python310-pip' # treba len zmenit cislo verzie python podla aktualnej
        'python310-bpython'
        'ripgrep' # vyhladavaci doplnok pre neovim a funkcnost Telescope doplnku
        'npm-default'
        'gcc' # C compiler
        'gcc-c++' # C++ compiler
        'clang'
        'make'
        '7zip'
        'at-spi2-core'
    )

    for PKG in "${BASIC_PKGS[@]}"; do
        echo "Installing ${PKG}"
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done

    # update tealdeer cache
    tldr --update
}

qtile_packages(){
    info "INSTALL QTILE PACKAGES"
    QTILE_PKGS=(
        # desktop window manager
        'xorg-x11'
        'xorg-x11-server'
        'lightdm'
        'qtile'
        'kitty'
        'qutebrowser'
        # zvuk
        'alsa'
        'alsa-utils'
        'alsa-firmware'
        'pulseaudio'
        'pavucontrol'
        # utility pre QTILE
        'dunst' # notification deamon
        'rofi' # menu manager
        'xrandr'
        'NetworkManager-applet'
        'udiskie'
        'ntfs-3g'
        'htop'
        'blueman' # bluetooth manager
        'brightnessctl' # jas obrazovky
        'playerctl' # ovladanie multimedii
        'redshift' # nocny jas
        'hack-fonts'
        'newsboat' # rss reader aj youtube reader
        'intel-hybrid-driver' # nie som isty ucinkom
    )

    for PKG in "${QTILE_PKGS[@]}"; do
        echo "Installing ${PKG}"
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done
}

kde_packages(){
    info "INSTALL KDE PACKAGES"
    KDE_PKGS=(
        'latte-dock'
        'kvantum-manager'
        'kvantum-qt5'
        'libnotify-tools'
        'libqt5-qtcharts-imports'
        'plasma5-systemmonitor'
    )

    for PKG in "${KDE_PKGS[@]}"; do
        echo "Installing ${PKG}"
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done
}

desktop_packages(){
    info "INSTALL DESKTOP PACKAGES"
    DESKTOP_PKGS=(
        'MozillaFirefox'
        'MozillaThunderbird'
        'onedrive'
        'mpv'
        'inkscape'
        'sioyek' # pdf reader
        'bleachbit' # cistenie systemu
        'xdotool' # napr. zistim nazov okna
        'megatools' # stahovanie z mega.nz z terminalu
        'transmission' # torrent client
        'transmission-gtk'
        'flameshot' # screenshot obrazovky
    )

    for PKG in "${DESKTOP_PKGS[@]}"; do
        echo "Installing ${PKG}"
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done
}

packman_packages(){
    info "INSTALL PACKMAN PACKAGES"
    repourl="https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/"
    sudo -S <<< ${mypassword} zypper addrepo -cfp 90 ${repourl} packman
    sudo -S <<< ${mypassword} zypper ${REFRESH}

    # if [ WSL -eq 2 ]
    # then
      PAC_PKGS=(
        'ffmpeg'
        'gstreamer-plugins-good'
        'gstreamer-plugins-bad'
        'gstreamer-plugins-libav'
        'gstreamer-plugins-ugly'
        'libavcodec-full'
        # 'handbrake-gtk'
      )

      for PAC_PKG in "${PAC_PKGS[@]}"; do
          echo "Installing ${PAC_PKG}"
          sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PAC_PKG}
      done
    # fi

# Codecs
    # sudo -S <<< ${mypassword} zypper ${INSTALL} -y opi
    # opi codecs
}
#
basic_desktop_settings(){
    info "BASIC DESKTOP SETTINGS"
    # Dissable GRUB delay
    # nacitam aktualnu hodnotu GRUB_TIMEOUT a zmenim ju na 0
    grub_timeout=$(grep -i "GRUB_TIMEOUT=" /etc/default/grub)
    sudo -S <<< ${mypassword} sed -i 's/'${grub_timeout}'/GRUB_TIMEOUT=0/g' /etc/default/grub

    # Po zmene v /etc/default/grub, updatnem hlavny configuracny subor
    sudo -S <<< ${mypassword} grub2-mkconfig -o /boot/grub2/grub.cfg

    # Znizi hodnotu Swappiness zo 60 na 10
    swapp_file="/etc/sysctl.d/sysctl.conf"
    [[ ! -f ${swapp_file} ]] && sudo -S <<< ${mypassword} touch ${swapp_file}
    echo wm.swappiness=10 | sudo -S <<< ${mypassword} tee -a ${swapp_file}

    # # Enable TRIM for SSD
    # sudo -S <<< ${mypassword} systemctl enable fstrim.timer

    # # FSTAB - aby nacitavalo druhy disk bez zadavania hesla (pridam uid=1000)
    # vytvorim zalohu
    # file="/etc/fstab"
    # sudo -S <<< ${mypassword} cp -rfv ${file} ${file}_backup
    #
    # # pridam uid=1000 do textu
    # find="fmask=133,dmask=022"
    # replace="fmask=133,dmask=022,uid=1000"
    # sudo -S <<< ${mypassword} sed -i "s/${find}/${replace}/g" ${file}

    # # Nastavit HOSTNAME (napr. vimi-probook)
    # echo "${color}  Enter new HOSTNAME: ${endcolor}"
    # read myhostname
    # # nastavi novy HOSTNAME
    # sudo -S <<< ${mypassword} hostnamectl set-hostname ${myhostname}
}

qtile_settings(){
    info "QTILE SETTINGS"
    # Zmena "text mode" na "graphical mode" pre boot systemu
    sudo -S <<< ${mypassword} systemctl set-default graphical.target

    # AutoLogin LightDM
    sudo -S <<< ${mypassword} sh -c 'cat > /etc/lightdm/lightdm.conf' <<EOF
    [Seat:*]
    autologin-user=vimi
EOF

    # Nastavenie TouchPadu pre natural scrolling
    sudo -S <<< ${mypassword} sh -c 'cat > /etc/X11/xorg.conf.d/30-touchpad.conf' <<EOF
    Section "InputClass"
            Identifier "touchpad"
            MatchIsTouchpad "on"
            Option "NaturalScrolling" "true"
            Option "Tapping" "on"
    EndSection
EOF

    # Dunst notification
    sudo -S <<< ${mypassword} sh -c 'cat > /usr/lib/systemd/user/dunst.service' <<EOF
    [Unit]
    Description=Dunst notification daemon
    Documentation=man:dunst(1)
    PartOf=graphical-session.target

    [Service]
    Type=dbus
    BusName=org.freedesktop.Notifications
    ExecStart=/usr/bin/dunst
    Environment=DISPLAY=:0
EOF

    # Nastavenie sklopenia notebooku
    sudo -S <<< ${mypassword} sh -c "echo 'HandleLidSwitch=ignore' >> /etc/systemd/logind.conf"
}

wsl_utilities(){
    info "WSL UTILLITIES"
    # umoznuje napr. spustia defaultny web browser na windowse
    repourl="https://download.opensuse.org/repositories/home:/wslutilities/openSUSE_Tumbleweed/home:wslutilities.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y wslu

    # Nastavenie wslview - vytvori subor wslview.desktop a potom nastavi ako default
#     set -eu -o pipefail

#     sudo -S <<< ${mypassword} sh -c 'cat >/usr/share/applications/wslview.desktop' <<EOF
#     [Desktop Entry]
#     Version=1.0
#     Name=WSLview
#     Exec=wslview %u
#     Terminal=false
#     X-MultipleArgs=false
#     Type=Application
#     Categories=GNOME;GTK;Network;WebBrowser;
#     MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
# EOF

    # Nastavi wslview ako default pre otvaranie suborov web, image ..
    # xdg-settings set default-web-browser wslview.desktop
}

wsl_gnome(){
    info "WSL GNOME SETTINGS"
    PKG_gnome=(
      'patterns-gnome-gnome_x11' # X11 server
      'patterns-gnome-gnome' # Wayland
    # 'dconf-editor' # na zmenu vlastnosti gnome
    # 'qalculate' # super kalkulacka
    # 'qalculate-gtk'
    # 'qalculate-data'
    # 'gtk3-metatheme-adwaita' # tmava tema
    # 'dmz-icon-theme-cursors' # biely kurzor podobny win kurzoru
    )

    for PKG in "${PKG_gnome[@]}"; do
        echo "Installing ${PKG}"
        sleep 1
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done


    # # nastavenie tmavej temy...ak chcem svetlu tak iba Adwaita
    # gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    # # nastavenie bieleho kurzora
    # gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'
    # nastavenie velkosti kurzora
    gsettings set org.gnome.desktop.interface cursor-size 15
}

github_cli(){
    info "GITHUB CLI"
    repourl="https://cli.github.com/packages/rpm/gh-cli.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y gh

    # manualne potom v git priecinku:
    # gh auth login
}

lazygit(){
    info "LAZYGIT"
    repourl="https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y lazygit

    # manualne potom v git priecinku:
    # gh auth login
}
win_disk_share(){
    info "WIN DISK SHARE SETUP"
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y cifs-utils
    sudo -S <<< ${mypassword} mkdir /mnt/win11-share

    sudo -S <<< ${mypassword} sh -c 'cat > /etc/win-credentials' <<EOF
    username=vimi
    password=8992
EOF

    sudo -S <<< ${mypassword} chown root: /etc/win-credentials
    sudo -S <<< ${mypassword} chmod 600 /etc/win-credentials

    # pridam tieto riadky do /etc/fstab na koniec pre auto share disku z win11 pc
    sudo -S <<< ${mypassword} sh -c "echo '#win11 network share mount folder D' >> /etc/fstab"
    sudo -S <<< ${mypassword} sh -c "echo '//192.168.0.48/d  /mnt/win11-share  cifs  credentials=/etc/win-credentials,uid=1000 0       0' >> /etc/fstab"
}

brave(){
    info "BRAVE"
    repourl="https://brave-browser-rpm-release.s3.brave.com/x86_64/"
    sudo -S <<< ${mypassword} rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl} brave-browser
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y brave-browser
  }

jdownloader(){
    info "JDOWNLOADER 2"
    repourl="https://download.opensuse.org/repositories/home:X0F:branches:network/openSUSE_Tumbleweed/home:X0F:branches:network.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y JDownloader2
  }

birdtray_stacer(){
    info "BIRDTRAY, STACER"
    repourl="https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y birdtray stacer
  }

newsflash(){
    info "NEWSFLASH"
    repourl="https://download.opensuse.org/repositories/home:Dead_Mozay:GNOME:Apps/openSUSE_Tumbleweed/home:Dead_Mozay:GNOME:Apps.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y newsflash
  }

hypnotix(){
    info "HYPNOTIX"
    repourl="https://download.opensuse.org/repositories/home:swannema/openSUSE_Tumbleweed/home:swannema.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y hypnotix
  }

plasma_eventcalendar(){
    info "PLASMA EVENT CALENDAR"
    repourl="https://download.opensuse.org/repositories/home:Herbster0815/openSUSE_Tumbleweed/home:Herbster0815.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} plasma5-applet-eventcalendar
  }

psensor(){
    info "PSENSOR"
    repourl="https://download.opensuse.org/repositories/home:malcolmlewis:TESTING/openSUSE_Tumbleweed/home:malcolmlewis:TESTING.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} psensor
  }

##########################################################################
# Programy z netu
##########################################################################

appimage_launcher(){
    info "INSTALL APPIMAGE-LAUNCHER"
    # Install depencies
    PKG_appimage=(
    'libqt5-qdbus'
    'libQt5Widgets5'
    'fuse'
    'libfuse2'
    # 'rpm-build'
    )

    for PKG in "${PKG_appimage[@]}"; do
        echo "Installing ${PKG}"
        sleep 1
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done

    # Download latest version
    git_url="https://github.com/TheAssassin/AppImageLauncher/releases/latest"
    latest_release=$(curl -L -s -H 'Accept: application/json' ${git_url})
    latest_version=$(echo ${latest_release} | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
    down_url="https://github.com/TheAssassin/AppImageLauncher/releases/download/${latest_version}/appimagelauncher-${latest_version#v}-travis995.0f91801.x86_64.rpm"
    wget ${down_url} -P ${TEMP_DIR}

    # Install appimage/launcher
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${TEMP_DIR}/*.rpm
    rm -rf ${TEMP_DIR}/*.rpm
}

ticker(){
    info "TICKER"
    curl -Ls https://api.github.com/repos/achannarasappa/ticker/releases/latest | grep -wo "https.*linux-amd64*.tar.gz" | wget -qi -
    tar -xvf ticker*.tar.gz ticker
    chmod +x ./ticker
    sudo -S <<< ${mypassword} mv ticker /usr/local/bin/
    rm -f ticker*.tar.gz
}

ulozto_downloader(){
    info "ULOZTO DOWNLOADER"
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y tor
    pip3 install tensorflow
    pip3 install ulozto-downloader
}

only_office(){
    info "ONLY OFFICE"
  git_url="https://github.com/ONLYOFFICE/DesktopEditors/releases/latest"
  latest_release=$(curl -L -s -H 'Accept: application/json' ${git_url})
  latest_version=$(echo ${latest_release} | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')

  case "$distro" in
    # q - Qtile
          q )
            down_url="https://github.com/ONLYOFFICE/DesktopEditors/releases/download/${latest_version}/DesktopEditors-x86_64.AppImage"
              if wget --spider $down_url 2>/dev/null
              then
                wget ${down_url} -P ${TEMP_DIR}
                # integruje OnlyOffice appimage do systemu (musi byt nainstalovany AppImageLauncher)
                ail-cli integrate ${TEMP_DIR}/DesktopEditors-x86_64.AppImage
                rm -rf ${TEMP_DIR}/*.AppImage
              else
                old_version="v7.3.0"
                down_url="https://github.com/ONLYOFFICE/DesktopEditors/releases/download/${old_version}/onlyoffice-desktopeditors.x86_64.rpm"
                wget ${down_url} -P ${TEMP_DIR}
                sudo -S <<< ${mypassword} zypper ${INSTALL} ${TEMP_DIR}/*.rpm
                rm -rf ${TEMP_DIR}/*.rpm
              fi
            ;;
    # k - KDE plasma
          k )
            down_url="https://github.com/ONLYOFFICE/DesktopEditors/releases/download/${latest_version}/onlyoffice-desktopeditors.x86_64.rpm"
            wget ${down_url} -P ${TEMP_DIR}
            sudo -S <<< ${mypassword} zypper ${INSTALL} ${TEMP_DIR}/*.rpm
            rm -rf ${TEMP_DIR}/*.rpm
            ;;
          * )
            ;;
        esac
}

freetube(){
    info "FREE-TUBE"
    ver="0.18.0"
    down_url="https://github.com/FreeTubeApp/FreeTube/releases/download/v${ver}-beta/freetube_${ver}_amd64.rpm"
    wget ${down_url} -P ${TEMP_DIR}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${TEMP_DIR}/*.rpm
    rm -rf ${TEMP_DIR}/*.rpm
}

ledger_live(){
    info "LEDGER LIVE"
    git_url="https://github.com/LedgerHQ/ledger-live-desktop/releases/latest"
    latest_release=$(curl -L -s -H 'Accept: application/json' ${git_url})
    latest_version=$(echo ${latest_release} | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
    down_url="https://github.com/LedgerHQ/ledger-live-desktop/releases/download/${latest_version}/ledger-live-desktop-${latest_version#v}-linux-x86_64.AppImage"
    wget ${down_url} -P ${TEMP_DIR}

    # integruje Ledger Live appimage do systemu (musi byt nainstalovany AppImageLauncher)
    ail-cli integrate ${TEMP_DIR}/ledger-live-desktop-${latest_version#v}-linux-x86_64.AppImage

    # nastavenie Ledger na linuxe aby citalo usb
    wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo -S <<< ${mypassword} bash

    rm -rf ${TEMP_DIR}/*.AppImage
}

freecad(){
    info "FreeCAD"
    if [ WSL -eq 1 ]
    then
      # git_url="https://github.com/FreeCAD/FreeCAD/releases/latest"
      # latest_release=$(curl -L -s -H 'Accept: application/json' ${git_url})
      # latest_version=$(echo ${latest_release} | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
      down_url="https://github.com/FreeCAD/FreeCAD/releases/download/0.20.2/FreeCAD_0.20.2-2022-12-27-conda-Linux-x86_64-py310.AppImage"

      wget ${down_url} -P ${TEMP_DIR}

      # integruje FreeCAD appimage do systemu (musi byt nainstalovany AppImageLauncher)
      ail-cli integrate ${TEMP_DIR}/FreeCAD_0.20-1-2022-08-20-conda-Linux-x86_64-py310.AppImage

      rm -rf ${TEMP_DIR}/*.AppImage

    else
      sudo -S <<< ${mypassword} zypper ${INSTALL} -y FreeCAD
    fi
}

salome_meca(){
    info "SALOME-MECA"
    PKG_salome=(
    'go'
    'singularity-ce'
    )

    for PKG in "${PKG_salome[@]}"; do
        echo "Installing ${PKG}"
        sleep 1
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done

    # uzavrie singularity-ce aby ho system nemohol vymazat
    sudo -S <<< ${mypassword} zypper al singularity-ce

    [[ ! -d $HOME/salome-meca ]] && mkdir -p $HOME/salome-meca
    wget https://code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2021.0.0-2-20211014-scibian-9.sif -P $HOME/salome-meca

    # musim manualne
    # sudo usermod -a -G singularity vimi
    # potom treba log out zo systemu

    # singularity run --app install $HOME/salome-meca/salome_meca-lgpl-2021.0.0-2-20211014-scibian-9.sif

    # pred spustenim treba upravit subor - je to uz zautomatizovane
    # sudo nvim /etc/singularity/nvliblist.conf
    # a zakomentovat #libGLX.so
    sudo -S <<< ${mypassword} sed -i '/libGLX.so/s/^/#/' /etc/singularity/nvliblist.conf

    # pre manualne spustenie - uz je v scripte .zshrc
    # ./salome_meca-lgpl-2021.0.0-2-20211014-scibian-9

    if [ WSL -eq 2 ]
    then
        # vytvorim spustaci subor .desktop
        [[ ! -d $HOME/.local/share/applications ]] && mkdir -p $HOME/.local/share/applications
        chmod +x ${CWD}/salome/salome-meca.desktop
        cp -rfv ${CWD}/salome/salome-meca.desktop $HOME/.local/share/applications/
    fi
}

chia_blockchain(){
    info "CHIA BLOCKCHAIN"
    # Skopiruje config subory
    sudo -S <<< $mypassword cp -rfv ${CWD}/chia_blockchain/chia_run_wallet /usr/bin/
    sudo -S <<< $mypassword cp -rfv ${CWD}/chia_blockchain/chia_run_wallet.desktop /usr/share/applications/

    # Stiahne a nainstaluje CHIA source verziu
    git_url="https://github.com/Chia-Network/chia-blockchain.git"
    git clone ${git_url} -b latest $HOME/chia-blockchain/
    cd $HOME/chia-blockchain

    sh install.sh
    . ./activate

    # Instalacia GUI
    sh install-gui.sh
    cd chia-blockchain-gui
    npm run build
    npm run electron &
}

zsh_config(){
    info "ZSH SETUP"
    # Nastavi zsh ako predvoleny shell namiesto bash
    chsh -s $(which zsh)
}

postgresql(){
    info "PostgreSQL"
    PKG_pg=(
    'postgresql'
    'postgresql-server'
    'postgresql-contrib'
    'postgresql-plpython'
    )

    for PKG in "${PKG_pg[@]}"; do
        echo "Installing ${PKG}"
        sleep 1
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done

    if [ WSL -eq 1 ]
    then
      # tu to zastane aby som zadal heslo
      echo
      echo "ENTER Postgres password: "
      sudo passwd postgres

      # Create postgreSQL data directory
      sudo -S <<< ${mypassword} mkdir /usr/lib/postgresql15/data
      sudo -S <<< ${mypassword} chown postgres:postgres /usr/lib/postgresql15/data

      # inicializuje postgresql databazu
      # sudo -i -u postgres -c '/usr/lib/postgresql15/bin/initdb -D /usr/lib/postgresql15/data/'

      # tymto spustim postgresql server
      # sudo -i -u postgres -c '/usr/lib/postgresql15/bin/pg_ctl -D /usr/lib/postgresql15/data/ -l logfile start'

      # Postup manualny zo zdrojoveho kodu:
      # https://www.thegeekstuff.com/2009/04/linux-postgresql-install-and-configure-from-source/

      # # Prida Enviroment variable
      # sudo -S <<< ${mypassword} sh -c 'cat >/etc/profile' <<EOF
      # # PostgreSQL
      # PATH=/usr/local/pgsql/bin:$PATH
      # export PATH
      # EOF
    else
      # inicializuje postgresql databazu
      sudo -S <<< ${mypassword} systemctl enable postgresql
      sudo -S <<< ${mypassword} systemctl start postgresql

      # tu to zastane aby som zadal heslo
      echo
      echo "ENTER Postgres password: "
      sudo passwd postgres

      # Manualne - vytvorenie uzivatela vimi
      # sudo su postgres
      # psql -c "CREATE ROLE vimi LOGIN CREATEDB PASSWORD '8992';"
    fi
}

live_server(){
    info "LIVE SERVER"
    sudo -S <<< ${mypassword} npm i -g live-server
}

python(){
    info "PYTHON SETUP"
    # Pre neovim LSP - celosystemove
    pip3 install pyright
    pip3 install pynvim
    pip3 install flake8
    pip3 install black

    # env pre web-epipingdesign
    [[ ! -d $HOME/python-venv ]] && mkdir -p $HOME/python-venv

    python3 -m venv $HOME/python-venv/epd-venv
    source $HOME/python-venv/epd-venv/bin/activate

    pip3 install --upgrade pip
    pip3 install flask

    deactivate

    # Pre yafin
    [[ ! -d $HOME/python-venv ]] && mkdir -p $HOME/python-venv

    python3 -m venv $HOME/python-venv/yafin-venv
    source $HOME/python-venv/yafin-venv/bin/activate

    pip3 install --upgrade pip
    pip3 install yfinance
    pip3 install pandas
    pip3 install pandas-datareader

    deactivate
}

jupyter_latex(){
    info "JUPYTER LATEX SETUP"
    PKG_jupyter_latex=(
        'pandoc' # Conversion between markup formats
        'texlive' # plny balik
        'texlive-latex' plny balik
        # 'texlive-xetex'
        # 'texlive-fontsetup'
        # 'texlive-adjustbox'
        # 'texlive-bibtex'
        # 'texlive-caption'
        # 'texlive-collectbox'
        # 'texlive-enumitem'
        # 'texlive-eurosym'
        # 'texlive-eurosym-fonts'
        # 'texlive-fancyvrb'
        # 'texlive-float'
        # 'texlive-geometry'
        # 'texlive-ifoddpage'
        # 'texlive-jknapltx'
        # 'texlive-oberdiek'
        # 'texlive-parskip'
        # 'texlive-rsfs'
        # 'texlive-rsfs-fonts'
        # 'texlive-tcolorbox'
        # 'texlive-titling'
        # 'texlive-ucs'
        # 'texlive-ulem'
        # 'texlive-upquote'
        # 'texlive-varwidth'
    )

    for PKG in "${PKG_jupyter_latex[@]}"; do
        echo "Installing ${PKG}"
        sleep 1
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done

    # Pre Jupyterlab
    [[ ! -d $HOME/python-venv ]] && mkdir -p $HOME/python-venv

    python3 -m venv $HOME/python-venv/jupyter-venv
    source $HOME/python-venv/jupyter-venv/bin/activate

    pip3 install --upgrade pip
    pip3 install jupyterlab
    pip3 install nbconvert # pre konverziu na pdf
    pip3 install sympy
    pip3 install numpy
    pip3 install matplotlib

    deactivate
}

run_software(){
    info "RUN SOFTWARE"
    case "$distro" in
              k )
                nohup firefox &> /dev/null &
                nohup thunderbird &> /dev/null &
                nohup latte-dock &> /dev/null &
                nohup freetube &> /dev/null &
                ;;
              * )
                ;;
    esac
}

qtile_install_theme(){
    info "THEME INSTALL"
    sudo -S <<< ${mypassword} zypper ${INSTALL} --no-recommends -y lxappearance qt5ct

    # Vytvori environment variable pre qt5ct
    sudo -S <<< ${mypassword} sh -c 'cat > /etc/environment' <<EOF
    QT_QPA_PLATFORMTHEME=qt5ct
EOF

    # TELA icons
    ICONS_DIR="$HOME/.local/share/icons"
    [[ ! -d ${ICONS_DIR} ]] && mkdir -p ${ICONS_DIR}
    git_url="https://github.com/vinceliuice/Tela-icon-theme.git"
    git clone ${git_url} ${TEMP_DIR}/Tela-icon-theme
    ${TEMP_DIR}/Tela-icon-theme/./install.sh

    # Hack-nerd fonts
    FONTS_DIR="$HOME/.local/share/fonts"
    url="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip"
    wget ${url} -P ${FONTS_DIR}
    unzip ${FONTS_DIR}/Hack.zip -d ${FONTS_DIR}
    rm ${FONTS_DIR}/Hack.zip

    # Win10 fonts
    7z x -y ${CWD}/win-fonts/win-fonts.7z.001 -o${FONTS_DIR}

    # update fontov
    sudo -S <<< ${mypassword} fc-cache -f -v

    # Nordzy cursors
    CURSOR_DIR="$HOME/.icons"
    [[ ! -d ${CURSOR_DIR} ]] && mkdir -p ${CURSOR_DIR}
    git_url="https://github.com/alvatip/Nordzy-cursors"
    git clone ${git_url} ${TEMP_DIR}/Nordzy-cursors
    cd ${TEMP_DIR}/Nordzy-cursors/ && ./install.sh

#     # nefunguje to - treba pouzit lxappearance - nastavi nordzy cursor ako default
#     mkdir -p ${CURSOR_DIR}/default
#     cat > ${CURSOR_DIR}/default/index.theme <<EOF
#     [Icon Theme]
#     Name=Default
#     Comment=Default Cursor Theme
#     Inherits=Nordzy-cursors-white
# EOF
}

kde_install_theme(){
    info "THEME INSTALL"
    # Nordic tema
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
    PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
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

    # TELA circle icons
    git_url="https://github.com/vinceliuice/Tela-circle-icon-theme.git"
    git clone ${git_url} ${TEMP_DIR}/Tela-circle
    ${TEMP_DIR}/Tela-circle/./install.sh "ubuntu"

    # We10OSX cursors
    git_url="https://github.com/yeyushengfan258/We10XOS-cursors.git"
    git clone ${git_url} ${TEMP_DIR}/We10XOS-cursors

    CURSORS_DIR="$HOME/.icons/We10XOS-cursors"
    [[ ! -d ${CURSORS_DIR} ]] && mkdir -p ${CURSORS_DIR}

    cp -rf ${TEMP_DIR}/We10XOS-cursors/dist/*    ${CURSORS_DIR}
}

kde_install_widgets(){
    info "WIDGETS INSTALL"
    # Yapstocks
    git_url="https://github.com/librehat/yapstocks.git"
    git clone ${git_url} ${TEMP_DIR}/Yapstocks

    YAP_DIR="$HOME/.local/share/plasma/plasmoids/com.librehat.yapstocks"
    [[ ! -d ${YAP_DIR} ]] && mkdir -p ${YAP_DIR}

    cp -rf ${TEMP_DIR}/Yapstocks/plasmoid/*    ${YAP_DIR}

    # Latte spacer
    git_url="https://github.com/psifidotos/applet-latte-spacer.git"
    git clone ${git_url} ${TEMP_DIR}/applet-latte-spacer

    SPACER_DIR="$HOME/.local/share/plasma/plasmoids/org.kde.latte.spacer"
    [[ ! -d ${SPACER_DIR} ]] && mkdir -p ${SPACER_DIR}

    cp -rf ${TEMP_DIR}/applet-latte-spacer/*    ${SPACER_DIR}

    # Systemtray
    git_url="https://github.com/psifidotos/plasma-systray-latte-tweaks.git"
    git clone ${git_url} ${TEMP_DIR}/plasma-systray-latte-tweaks

    TRAY_DIR="$HOME/.local/share/plasma/plasmoids/"

    cp -rf ${TEMP_DIR}/plasma-systray-latte-tweaks/{org.kde.plasma.private.systemtray,org.kde.plasma.systemtray} ${TRAY_DIR}
}

wsl_dotfiles(){
    info "CREATE SYMLINKS"
    DIRECTORIES=(
    'zsh'
    'nvim'
    )

    # zisti ci priecinky existuju, ak nie tak ich vytvori
    for DIR in "${DIRECTORIES[@]}"; do
        [[ ! -d $HOME/.config/$DIR ]] && mkdir -p $HOME/.config/$DIR
    done

    #vytvorim symlinky
    ln -sf ${CWD}/config/zsh/.zshrc                 ${HOME}/.config/zsh/.zshrc
    ln -sf ${CWD}/config/nvim/init.lua              ${HOME}/.config/nvim/init.lua
    ln -sf ${CWD}/config/nvim/lua                   ${HOME}/.config/nvim/lua
    ln -sf ${CWD}/config/ranger                     ${HOME}/.config/ranger
    ln -sf ${CWD}/xWSL/starship.toml                ${HOME}/.config/starship.toml
    ln -sf ${CWD}/home/.bashrc                      ${HOME}/.bashrc
    ln -sf ${CWD}/home/.ticker.yaml                 ${HOME}/.ticker.yaml
    ln -sf ${CWD}/home/.zprofile                    ${HOME}/.zprofile
    ln -sf ${CWD}/.gitconfig                        ${HOME}/.gitconfig

    # OneDrive, Downloads, Megasync, Videos
    ln -sf /mnt/c/Users/vimi/OneDrive               ${HOME}/OneDrive
    ln -sf /mnt/c/Users/vimi/Downloads              ${HOME}/Downloads
    # ln -sf /mnt/c/Users/vimi/Mega                   ${HOME}/Mega
    # ln -sf /mnt/d/Videos                            ${HOME}/Videos
}

qtile_dotfiles(){
    info "CREATE SYMLINKS"
    DIRECTORIES=(
    'mpv'
    'nvim'
    'zsh'
    )

    # zisti ci priecinky existuju, ak nie tak ich vytvori
    for DIR in "${DIRECTORIES[@]}"; do
        [[ ! -d $HOME/.config/$DIR ]] && mkdir -p $HOME/.config/$DIR
    done

    # chmod +x pre qtile scripty
    cd ${CWD}/config/qtile/scripts/
    for file in *; do
        chmod +x $file
    done
    cd ${CWD}

    #vytvorim symlinky
    ln -sf ${CWD}/config/dunst                  ${HOME}/.config/dunst
    ln -sf ${CWD}/config/gtk-2.0                ${HOME}/.config/gtk-2.0
    ln -sf ${CWD}/config/gtk-3.0                ${HOME}/.config/gtk-3.0
    ln -sf ${CWD}/config/kitty                  ${HOME}/.config/kitty
    # ln -sf ${CWD}/config/mpv/script-opts        ${HOME}/.config/mpv/script-opts
    ln -sf ${CWD}/config/mpv/scripts            ${HOME}/.config/mpv/scripts
    ln -sf ${CWD}/config/mpv/input.conf         ${HOME}/.config/mpv/input.conf
    ln -sf ${CWD}/config/mpv/mpv.conf           ${HOME}/.config/mpv/mpv.conf

    ln -sf ${CWD}/config/nvim/init.lua          ${HOME}/.config/nvim/init.lua
    ln -sf ${CWD}/config/nvim/lua               ${HOME}/.config/nvim/lua
    ln -sf ${CWD}/config/qt5ct                  ${HOME}/.config/qt5ct
    ln -sf ${CWD}/config/qtile                  ${HOME}/.config/qtile
    ln -sf ${CWD}/config/qutebrowser            ${HOME}/.config/qutebrowser
    ln -sf ${CWD}/config/ranger                 ${HOME}/.config/ranger
    ln -sf ${CWD}/config/rofi                   ${HOME}/.config/rofi
    ln -sf ${CWD}/config/sioyek                 ${HOME}/.config/sioyek
    ln -sf ${CWD}/config/zsh/.zshrc             ${HOME}/.config/zsh/.zshrc
    ln -sf ${CWD}/config/starship.toml          ${HOME}/.config/starship.toml
    ln -sf ${CWD}/config/mimeapps.list          ${HOME}/.config/mimeapps.list

    ln -sf ${CWD}/home/newsboat                 ${HOME}/newsboat
    ln -sf ${CWD}/home/.bashrc                  ${HOME}/.bashrc
    ln -sf ${CWD}/home/.ticker.yaml             ${HOME}/.ticker.yaml
    ln -sf ${CWD}/home/.zprofile                ${HOME}/.zprofile
    ln -sf ${CWD}/home/.gtkrc-2.0               ${HOME}/.gtkrc-2.0
    ln -sf ${CWD}/home/.Xresources              ${HOME}/.Xresources
    ln -sf ${CWD}/.gitconfig                    ${HOME}/.gitconfig
    ln -sf ${CWD}/icons/default                 ${HOME}/.icons/default

    # vytvorenie symlinku pre power-menu script
    ln -sf ${CWD}/config/qtile/scripts/power-menu.sh ${HOME}/.local/bin/power-menu

    # vytvorenie symlinku pre translate script
    ln -sf ${CWD}/config/qtile/scripts/translate.sh ${HOME}/.local/bin/translate

    # MPV single instance
    chmod +x ${CWD}/config/mpv/mpv-single-instance/{mpv-single,mpv-single.desktop}
    ln -sf ${CWD}/config/mpv/mpv-single-instance/mpv-single   ${HOME}/.local/bin/mpv-single
    [[ ! -d $HOME/.local/share/applications ]] && mkdir -p ${HOME}/.local/share/applications
    cp -rfv ${CWD}/config/mpv/mpv-single-instance/mpv-single.desktop  ${HOME}/.local/share/applications/mpv-single.desktop

    # Firefox / najprv treba spustit, aby vytvoril .mozilla....
    # * treba nahradit presnym cislom/oznacenim
    # ln -sf ~/.dotfiles/firefox/bookmarkbackups   $HOME/.mozilla/firefox/*.default-release/bookmarkbackups
    # ln -sf ~/.dotfiles/firefox/chrome            $HOME/.mozilla/firefox/*.default-release/chrome
    # ln -sf ~/.dotfiles/firefox/extensions        $HOME/.mozilla/firefox/*.default-release/extensions
    # ln -sf ~/.dotfiles/firefox/prefs.js          $HOME/.mozilla/firefox/*.default-release/prefs.js

    # Thunderfbird / plati to co firefox
    # ln -sf ~/.dotfiles/thunderbird/extensions $HOME/.thunderbird/*.default-release/extensions
    # ln -sf ~/.dotfiles/thunderbird/prefs.js $HOME/.thunderbird/ovhwieeq.default-release/prefs.js
}

kde_dotfiles(){
    info "CREATE SYMLINKS"

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
sudo -S <<< $mypassword cp -rfv ${CWD}/mpv/mpv-single-instance/mpv-single /usr/bin/
sudo -S <<< $mypassword cp -rfv ${CWD}/mpv/mpv-single-instance/mpv-single.desktop /usr/share/applications/

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
sudo -S <<< ${mypassword} gtk-update-icon-cache -f /usr/share/icons/hicolor/

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

final_touch(){
  [[ ! -d $HOME/Downloads ]] && mkdir -p $HOME/Downloads
}


# HLAVNA INSTALACNA FUNKCIA
which_distro(){
    echo
    printf "${color}Which distro install?\n[w]sl, [q]tile, [k]de, [Q]uit:${endcolor}\n"
    # info "Which distro install?\n[w]sl, [q]tile, [k]de, [Q]uit: "
    read -n 1 distro
    echo

    case "$distro" in
              w )
                root
                update_system
                basic_packages
                # qtile_packages
                # kde_packages
                # desktop_packages
                packman_packages
                # basic_desktop_settings
                # qtile_settings
                wsl_utilities
                # wsl_gnome
                github_cli
                lazygit
                # win_disk_share
                # brave
                # jdownloader
                # birdtray_stacer
                # newsflash
                # hypnotix
                # plasma_eventcalendar
                # psensor
                appimage_launcher
                ticker
                ulozto_downloader
                # only_office
                # freetube
                # ledger_live
                # freecad
                # salome_meca
                # chia_blockchain
                zsh_config
                # postgresql
                live_server
                python
                # jupyter_latex
                # run_software
                # qtile_install_theme
                # kde_install_theme
                # kde_install_widgets
                wsl_dotfiles
                # qtile_dotfiles
                # kde_dotfiles
                final_touch
                ;;
              q )
                root
                update_system
                basic_packages
                qtile_packages
                desktop_packages
                packman_packages
                qtile_settings
                basic_desktop_settings
                github_cli
                lazygit
                win_disk_share
                brave
                jdownloader
                appimage_launcher
                ticker
                ulozto_downloader
                only_office
                # ledger_live
                # freecad
                # salome_meca
                # chia_blockchain
                zsh_config
                # postgresql
                live_server
                python
                # jupyter_latex
                qtile_install_theme
                qtile_dotfiles
                final_touch
                ;;
              k )
                root
                update_system
                basic_packages
                kde_packages
                desktop_packages
                packman_packages
                basic_desktop_settings
                github_cli
                lazygit
                # win_disk_share
                brave
                jdownloader
                birdtray_stacer
                newsflash
                hypnotix
                plasma_eventcalendar
                psensor
                appimage_launcher
                ticker
                ulozto_downloader
                only_office
                freetube
                ledger_live
                # freecad
                # salome_meca
                # chia_blockchain
                zsh_config
                # postgresql
                live_server
                python
                # jupyter_latex
                run_software
                kde_install_theme
                kde_install_widgets
                kde_dotfiles
                final_touch
                ;;
              Q )
                exit
                ;;
              * )
                ;;
    esac
}

which_distro

# Zaverecna sprava
echo
info "Instalacia ukoncena :D"
