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

##########################################################################
# Settings
##########################################################################

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

    # Nastavit HOSTNAME (napr. vimi-probook)
    echo "${color}  Enter new HOSTNAME: ${endcolor}"
    read myhostname
    # nastavi novy HOSTNAME
    sudo -S <<< ${mypassword} hostnamectl set-hostname ${myhostname}

    # # Zmena rozlisenia obrazovky ak je pripojeny notebook k TV
    # echo "${color} Resolution TV setup ${endcolor}"
    # resTV_file="/usr/share/sddm/scripts/Xsetup"
    # [[ ! -f ${resTV_file} ]] && sudo -S <<< ${mypassword} touch ${resTV_file}
    # # HDMI-0 je vystup pre TV, LVDS - je vystup obrazovky notebooku
    # echo xrandr --output HDMI-0 --primary --mode 1920x1080 --output LVDS --off | sudo tee -a ${resTV_file}

}

zsh_config(){
    info "ZSH SETUP"
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y zsh
    # Nastavi zsh ako predvoleny shell namiesto bash
    chsh -s $(which zsh)
}

##########################################################################
# Software
##########################################################################

basic_packages(){
    info "INSTALL BASIC PACKAGES"
    BASIC_PKGS=(
        'neovim'
        'gh' # github-cli, manualne potom v git priecinku: gh auth login
        'lazygit'
        'starship'
        'eza'
        'fd'
        'tealdeer' # tldr pre man pages
        'curl'
        'yt-dlp' # stahovanie youtube videi
        'yazi'
        'ranger' # python terminal filemanager
        'xsel' # umoznuje copirovat adresu suboru z Rangera do systemoveho clipboardu
        # 'jq' # potrebne pre script ticker - cli JSON processor
        'ripgrep' # vyhladavaci doplnok pre neovim a funkcnost Telescope doplnku
        'npm-default'
        'gcc' # C compiler
        'gcc-c++' # C++ compiler
        'clang'
        'make'
        '7zip'
        'libnotify' # notifikacie send-notify
        'at-spi2-core'
        'xdg-utils' # pre nastavenie defaultnych aplikacii
        'sqlitebrowser' # pre sqlite databazu pre moju flask aplikaciu
        'libcairo2' # epd - pre weasyprint
        'libpango-1_0-0' # epd - pre weasyprint
        'redis' # server pre flask kniznicu celery. pouzivam pre moju aplikaciu epd alebo isitobo.
        'ImageMagick-devel' # pre image.nvim a molten.nvim
    )

    for PKG in "${BASIC_PKGS[@]}"; do
        echo "Do you want to install ${PKG}? (y/n)"
        read -r CONFIRMATION
        if [[ ${CONFIRMATION} =~ ^[Yy]$ ]]; then
            echo "Installing ${PKG}"
            sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
        else
            echo "Skipping ${PKG}"
        fi
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
        # for theme appearance
        'lxappearance'
        'qt5ct'
    )

    for PKG in "${QTILE_PKGS[@]}"; do
        echo "Do you want to install ${PKG}? (y/n)"
        read -r CONFIRMATION
        if [[ ${CONFIRMATION} =~ ^[Yy]$ ]]; then
            echo "Installing ${PKG}"
            sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
        else
            echo "Skipping ${PKG}"
        fi
    done
}

desktop_packages(){
    info "INSTALL DESKTOP PACKAGES"
    DESKTOP_PKGS=(
        'MozillaFirefox'
        'MozillaThunderbird'
        'onedrive'
        'mpv'
        'wezterm' # terminal
        'kitty' # terminal
        'qutebrowser' # python based web browser
        'kvantum-manager' # pre KDE iba
        'inkscape'
        'sioyek' # pdf reader
        'bleachbit' # cistenie systemu
        'xdotool' # napr. zistim nazov okna
        'megatools' # stahovanie z mega.nz z terminalu
        'transmission' # torrent client
        'transmission-gtk'
        'flameshot' # screenshot obrazovky
        'deluge' # bit torrent client
    )

    for PKG in "${DESKTOP_PKGS[@]}"; do
        echo "Do you want to install ${PKG}? (y/n)"
        read -r CONFIRMATION
        if [[ ${CONFIRMATION} =~ ^[Yy]$ ]]; then
            echo "Installing ${PKG}"
            sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
        else
            echo "Skipping ${PKG}"
        fi
    done
}

packman_packages(){
    info "INSTALL PACKMAN PACKAGES"
    repourl="https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/"
    sudo -S <<< ${mypassword} zypper addrepo -cfp 90 ${repourl} packman
    sudo -S <<< ${mypassword} zypper ${REFRESH}

    PAC_PKGS=(
        'ffmpeg'
        'gstreamer-plugins-good'
        'gstreamer-plugins-bad'
        'gstreamer-plugins-libav'
        'gstreamer-plugins-ugly'
        'libavcodec-full'
        'handbrake-gtk'
    )

    for PKG in "${PAC_PKGS[@]}"; do
        echo "Do you want to install ${PKG}? (y/n)"
        read -r CONFIRMATION
        if [[ ${CONFIRMATION} =~ ^[Yy]$ ]]; then
            echo "Installing ${PKG}"
            sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
        else
            echo "Skipping ${PKG}"
        fi
    done

    # Codecs
    # sudo -S <<< ${mypassword} zypper ${INSTALL} -y opi
    # opi codecs
}

appimages(){
    info "INSTALL APPMAN"
    # Install depencies
    APPMAN_DPC=(
        'coreutils'
        'curl'
        'grep'
        'less'
        'sed'
        'wget'
        'binutils'
        'unzip'
        'tar'
    )

    for PKG in "${APPMAN_DPC[@]}"; do
        echo "Installing ${PKG}"
        sleep 1
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done

    # Install appman
    wget -q https://raw.githubusercontent.com/ivan-hc/AM/main/AM-INSTALLER && chmod a+x ./AM-INSTALLER && ./AM-INSTALLER

    # remove appman installer
    rm -f AM-INSTALLER

    info "INSTALL APPMAN APPIMAGES"
    APPIMAGES_PKGS=(
        'firefox'
        'brave'
        'freetube'
        'onlyoffice'
        'obsidian'
        'vscodium'
        'zen-browser'
        'zotero'
    )

    for PKG in "${APPIMAGES_PKGS[@]}"; do
        echo "Do you want to install ${PKG}? (y/n)"
        read -r CONFIRMATION
        if [[ ${CONFIRMATION} =~ ^[Yy]$ ]]; then
            echo "Installing ${PKG}"
            appman -i ${PKG}
            # vytvorenie symlinkov .desktop suborov -> ~/.local/share/applications
            ln -sf ${CWD}/xKDE/local_share_applications/${PKG}-AM.desktop  ${HOME}/.local/share/applications/${PKG}-AM.desktop
        else
            echo "Skipping ${PKG}"
        fi
    done
}

other_apps(){
  megasync(){
      down_url="https://mega.nz/linux/repo/openSUSE_Tumbleweed/x86_64/megasync-openSUSE_Tumbleweed.x86_64.rpm"
      wget ${down_url} -P ${TEMP_DIR}

      # davam iba install, pretoze ma problem s gpt klucmi a musim dat -ignore pocas instalacie
      sudo zypper install ${TEMP_DIR}/megasync-openSUSE_Tumbleweed.x86_64.rpm
  }

  jdownloader(){
      info "JDOWNLOADER 2"
      repourl="https://download.opensuse.org/repositories/home:X0F:branches:network/openSUSE_Tumbleweed/home:X0F:branches:network.repo"
      sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
      sudo -S <<< ${mypassword} zypper ${REFRESH}
      sudo -S <<< ${mypassword} zypper ${INSTALL} -y JDownloader2

      ## velkost pisma v jdownloader:
      ## advanced settings -> search: fonts -> scale 150
  }

  birdtray(){
      info "BIRDTRAY"
      repourl="https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo"
      sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
      sudo -S <<< ${mypassword} zypper ${REFRESH}
      sudo -S <<< ${mypassword} zypper ${INSTALL} -y birdtray
  }

  ulauncher(){
      info "ULAUNCHER"
      repourl="https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo"
      sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
      sudo -S <<< ${mypassword} zypper ${REFRESH}
      sudo -S <<< ${mypassword} zypper ${INSTALL} -y ulauncher
  }

  newsflash(){
      info "NEWSFLASH"
      repourl="https://download.opensuse.org/repositories/home:Dead_Mozay:GNOME:Apps/openSUSE_Tumbleweed/home:Dead_Mozay:GNOME:Apps.repo"
      sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
      sudo -S <<< ${mypassword} zypper ${REFRESH}
      sudo -S <<< ${mypassword} zypper ${INSTALL} -y newsflash
  }

  ticker(){
      info "TICKER"
      curl -Ls https://api.github.com/repos/achannarasappa/ticker/releases/latest | grep -wo "https.*linux-amd64*.tar.gz" | wget -qi -
      tar -xvf ticker*.tar.gz ticker
      chmod +x ./ticker
      mv ticker ${HOME}/.local/bin/
      rm -f ticker*.tar.gz
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

      if [ $WSL -eq 2 ]
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


    # Array to store function names and corresponding software names
    software_list=(
                   "megasync:Megasync"
                   "jdownloader:JDownloader 2"
                   "birdtray:Birdtray"
                   "ulauncher:Ulauncher"
                   "newsflash:Newsflash"
                   "ticker:Ticker"
                   "ledger_live:Ledger Live"
                   "salome_meca:Salome Meca"
                   "chia_blockchain:Chia Blockchain"
                 )

    # Loop through the software list
    for entry in "${software_list[@]}"; do
        IFS=":" read -r func name <<< "$entry"

        # Ask the user if they want to install the software
        info ${name}
        read -p "Do you want to install $name? (y/n): " choice
        case $choice in
            [Yy]* )
                # Call the corresponding nested function
                $func
                ;;
            [Nn]* )
                echo "$name will not be installed."
                ;;
            * )
                echo "Invalid input, skipping $name."
                ;;
        esac
    done
}

quarto(){
    info "QUARTO"

    read -p "Do you want to install Quarto? (y/n): " choice
        case $choice in
            [Yy]* )
                # download tarball
                git_url="https://github.com/quarto-dev/quarto-cli/releases/latest"
                latest_release=$(curl -L -s -H 'Accept: application/json' ${git_url})
                latest_version=$(echo ${latest_release} | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
                down_url="https://github.com/quarto-dev/quarto-cli/releases/download/${latest_version}/quarto-${latest_version#v}-linux-amd64.tar.gz"
                wget ${down_url} -P ${TEMP_DIR}

                # exctract files
                [[ ! -d $HOME/quarto ]] && mkdir -p $HOME/quarto
                tar -C $HOME/quarto -xvzf ${TEMP_DIR}/quarto*.tar.gz

                # create symlink
                [[ ! -d $HOME/bin ]] && mkdir -p $HOME/bin
                ln -s $HOME/quarto/quarto*/bin/quarto $HOME/bin/quarto

                # Ensure that the folder where you created a symlink is in the path. For example:
                # ( echo ""; echo 'export PATH=$PATH:~/bin\n' ; echo "" ) >> ~/.profile
                # source ~/.profile

                # install tinytex
                quarto install tinytex

                # Check The Installation
                # quarto check
                ;;
            [Nn]* )
                echo "Quarto will not be installed."
                ;;
            * )
                echo "Invalid input, skipping Quarto."
                ;;
        esac
}

postgresql(){
  info "PostgreSQL"
  read -p "Do you want to install PostgreSQL? (y/n): " choice
      case $choice in
          [Yy]* )
                PKG_pg=(
                    'postgresql'
                    'postgresql-server'
                    'postgresql-contrib'
                    'postgresql-devel'
                    'postgresql-server-devel'
                    'postgresql-plpython'
                )

                for PKG in "${PKG_pg[@]}"; do
                    echo "Installing ${PKG}"
                    sleep 1
                    sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
                done

                if [ $WSL -eq 1 ]
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
              ;;
          [Nn]* )
              echo "Quarto will not be installed."
              ;;
          * )
              echo "Invalid input, skipping Quarto."
              ;;
      esac
}

##########################################################################
# Python
##########################################################################

python(){
    info "PYTHON SETUP"

    PYTHON_VER='python313'
    PYTHON_VER_ENV='python3.13'
    PYTHON_ENV_DIR='.py-venv'
    # zisti ci priecinok existuje
    [[ ! -d $HOME/$PYTHON_ENV_DIR ]] && mkdir -p $HOME/$PYTHON_ENV_DIR

    PYTHON_PKGS=(
      # treba len zmenit cislo verzie python podla aktualnej
      "${PYTHON_VER}"
      "${PYTHON_VER}-pip"
      "${PYTHON_VER}-ipython"
      "${PYTHON_VER}-devel" # pre funkciu kniznice psycopg2 - prepojenie s postgresql databazou
      #"${PYTHON_VER}-bpython"
  )

    for PKG in "${PYTHON_PKGS[@]}"; do
        echo "Do you want to install ${PKG}? (y/n)"
        read -r CONFIRMATION
        if [[ ${CONFIRMATION} =~ ^[Yy]$ ]]; then
            echo "Installing ${PKG}"
            sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
        else
            echo "Skipping ${PKG}"
        fi
    done

    # env pre web-epipingdesign
    ${PYTHON_VER_ENV} -m venv ${HOME}/${PYTHON_ENV_DIR}/epd-venv
    source $HOME/${PYTHON_ENV_DIR}/epd-venv/bin/activate

    pip3 install --upgrade pip

    deactivate

    # env pre web-isitobo
    ${PYTHON_VER_ENV} -m venv ${HOME}/${PYTHON_ENV_DIR}/isitobo-venv
    source ${HOME}/${PYTHON_ENV_DIR}/isitobo-venv/bin/activate

    pip3 install --upgrade pip

    deactivate

    # env pre web-isitobo-test
    ${PYTHON_VER_ENV} -m venv ${HOME}/${PYTHON_ENV_DIR}/isitobo-test-venv
    source ${HOME}/${PYTHON_ENV_DIR}/isitobo-test-venv/bin/activate

    pip3 install --upgrade pip

    deactivate

    # Pre neovim - vscodium - yafin - quarto - jupyterlab - molten - image.nvim
    ${PYTHON_VER_ENV} -m venv ${HOME}/${PYTHON_ENV_DIR}/base-venv
    source ${HOME}/${PYTHON_ENV_DIR}/base-venv/bin/activate

    pip3 install --upgrade pip
    pip3 install yahoofinancials # pre moj yafin script
    pip3 install jupyter
    pip3 install numpy
    pip3 install sympy
    pip3 install pandas
    pip3 install matplotlib
    pip3 install handcalcs
    pip3 install tabulate
    pip3 install latexify-py
    pip3 install efficalc
    pip3 install pint
    pip3 install forallpeople
    ## pre molten.nvim a image.nvim
    pip3 install pynvim
    pip3 install jupyter_client
    pip3 install cairosvg
    pip3 install plotly
    pip3 install kaleido
    pip3 install pnglatex
    pip3 install pyperclip

    # aktivacia jupyter kernel pre molten.nvim
    # jupyter kernel — kernel=python3

    deactivate
}

##########################################################################
# Fonts, cursors, icons
##########################################################################

fonts(){
    info "FONTS INSTALL"
    FONTS_DIR=".local/share/fonts"
    [[ ! -d $HOME/${FONTS_DIR} ]] && mkdir -p $HOME/${FONTS_DIR}

    fonts_list=(
      "Hack:hack nerd fonts"
      "CascadiaCode:Cascadia code nerd fonts"
    )

    for font in "${fonts_list[@]}"; do
        IFS=":" read -r font_name font_desc <<< "$font"

        info ${font_name}
        read -p "Do you want to install ${font_name}? (y/n): " choice
        case ${choice} in
            [Yy]* )
                git_url="https://github.com/ryanoasis/nerd-fonts/releases/latest"
                latest_release=$(curl -L -s -H 'Accept: application/json' ${git_url})
                latest_version=$(echo ${latest_release} | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
                down_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${latest_version}/${font_name}.zip"

                wget ${down_url} -P ${FONTS_DIR}
                unzip ${FONTS_DIR}/${font_name}.zip -d ${FONTS_DIR}
                rm ${FONTS_DIR}/${font_name}.zip
                ;;
            [Nn]* )
                echo "${font_name} will not be installed."
                ;;
            * )
                echo "Invalid input, skipping ${font_name}."
                ;;
        esac
    done

    info "WINDOWS FONTS"
    7z x -y ${CWD}/win-fonts/win-fonts.7z.001 -o${FONTS_DIR}

    info "UPDATE FONTS"
    sudo -S <<< ${mypassword} fc-cache -f -v
}

cursors(){
    info "CURSORS INSTALL"
    read -p "Which cursors install?\n [1]WE10XOS, [2]Nordzy, [3]All : " choice

    install_cursor() {
        local name="$1"
        local url="$2"
        info "${name} CURSORS"
        git clone ${url} ${TEMP_DIR}
        cd ${TEMP_DIR}/${name} && ./install.sh
    }

    case ${choice} in
        [1]* )
            install_cursor "We10XOS-cursors" "https://github.com/yeyushengfan258/We10XOS-cursors.git"
            ;;
        [2]* )
            install_cursor "Nordzy-hypercursors" "https://github.com/guillaumeboehm/Nordzy-hyprcursors"
            ;;
        [3]* )
            install_cursor "We10XOS-cursors" "https://github.com/yeyushengfan258/We10XOS-cursors.git"
            install_cursor "Nordzy-hypercursors" "https://github.com/guillaumeboehm/Nordzy-hyprcursors"
            ;;

        * )
            echo "Invalid input, skipping."
            ;;
    esac
}

icons(){
    info "ICONS INSTALL"
    read -p "Which icon theme install?\n [1]Adwaita-colors, [2]MoreWaita, [3]Tela-icon, [4]All : " choice

    ICONS_DIR="$HOME/.local/share/icons"
    [[ ! -d ${ICONS_DIR} ]] && mkdir -p ${ICONS_DIR}

    install_icons() {
        local choice="$1"
        local name="$2"
        local url="$3"
        info "${name} ICONS"
        git clone ${url} ${TEMP_DIR}
        case ${choice} in
          [1]* )
              cd ${TEMP_DIR}/${name} && ./install.sh
              ;;
          [2]* )
              cp -r ${TEMP_DIR}/${name}/* ${HOME}/.local/share/icons/
              ;;
             * )
              ;;
        esac
    }

    case ${choice} in
        [1]* )
            install_icons "2" "Adwaita-colors" "https://github.com/dpejoh/Adwaita-colors"
            ;;
        [2]* )
            install_icons "1" "MoreWaita" "https://github.com/dpejoh/Adwaita-colors"
            ;;
        [3]* )
            install_icons "1" "Tela-icon-theme" "https://github.com/somepaulo/MoreWaita.git"
            ;;
        [4]* )
            install_icons "2" "Adwaita-colors" "https://github.com/dpejoh/Adwaita-colors"
            install_icons "1" "MoreWaita" "https://github.com/dpejoh/Adwaita-colors"
            install_icons "1" "Tela-icon-theme" "https://github.com/vinceliuice/Tela-icon-theme.git"
            ;;
        * )
            echo "Invalid input, skipping."
            ;;
    esac
}

##########################################################################
# Dotfiles symlinks
##########################################################################

gnome_kde_dotfiles(){
    info "CREATE SYMLINKS"
    DIRECTORIES=(
        'wezterm'
        'mpv'
        'nvim'
        'zsh'
    )

    # zisti ci priecinky existuju, ak nie tak ich vytvori
    for DIR in "${DIRECTORIES[@]}"; do
        [[ ! -d $HOME/.config/$DIR ]] && mkdir -p $HOME/.config/$DIR
    done

    #vytvorim symlinky
    ln -sf ${CWD}/config/wezterm/colors         ${HOME}/.config/wezterm/colors
    ln -sf ${CWD}/config/wezterm/wezterm.lua    ${HOME}/.config/wezterm/wezterm.lua
    ln -sf ${CWD}/config/mpv/scripts            ${HOME}/.config/mpv/scripts
    ln -sf ${CWD}/config/mpv/input.conf         ${HOME}/.config/mpv/input.conf
    ln -sf ${CWD}/config/mpv/mpv.conf           ${HOME}/.config/mpv/mpv.conf

    ln -sf ${CWD}/config/nvim/init.lua          ${HOME}/.config/nvim/init.lua
    ln -sf ${CWD}/config/nvim/lua               ${HOME}/.config/nvim/lua
    ln -sf ${CWD}/config/nvim/after             ${HOME}/.config/nvim/after
    ln -sf ${CWD}/config/nvim/snippets          ${HOME}/.config/nvim/snippets
    # ln -sf ${CWD}/config/ranger                 ${HOME}/.config/ranger
    ln -sf ${CWD}/config/zsh/.zshrc             ${HOME}/.config/zsh/.zshrc
    ln -sf ${CWD}/config/zsh/.zshenv            ${HOME}/.config/zsh/.zshenv
    ln -sf ${CWD}/config/starship.toml          ${HOME}/.config/starship.toml

    ln -sf ${CWD}/home/.bashrc                  ${HOME}/.bashrc
    ln -sf ${CWD}/home/.ticker.yaml             ${HOME}/.ticker.yaml
    ln -sf ${CWD}/home/.zprofile                ${HOME}/.zprofile
    ln -sf ${CWD}/home/.npmrc                   ${HOME}/.npmrc
    ln -sf ${CWD}/.gitconfig                    ${HOME}/.gitconfig

    # MPV single instance
    chmod +x ${CWD}/config/mpv/mpv-single-instance/{mpv-single,mpv-single.desktop}
    ln -sf ${CWD}/config/mpv/mpv-single-instance/mpv-single   ${HOME}/.local/bin/mpv-single
    [[ ! -d $HOME/.local/share/applications ]] && mkdir -p ${HOME}/.local/share/applications
    ln -sf ${CWD}/config/mpv/mpv-single-instance/mpv-single.desktop  ${HOME}/.local/share/applications/mpv-single.desktop


    # Firefox / najprv treba spustit, aby vytvoril .mozilla....
    # * treba nahradit presnym cislom/oznacenim
    # ln -sf ~/.dotfiles/firefox/bookmarkbackups   $HOME/.mozilla/firefox/*.default-release/bookmarkbackups
    # ln -sf ~/.dotfiles/firefox/chrome            $HOME/.mozilla/firefox/*.default-release/chrome
    # ln -sf ~/.dotfiles/firefox/extensions        $HOME/.mozilla/firefox/*.default-release/extensions
    # ln -sf ~/.dotfiles/firefox/prefs.js          $HOME/.mozilla/firefox/*.default-release/prefs.js

    # Thunderfbird / plati to co firefox
    # ln -sf ~/.dotfiles/thunderbird/extensions $HOME/.thunderbird/*.default-release/extensions
    # ln -sf ~/.dotfiles/thunderbird/prefs.js $HOME/.thunderbird/ovhwieeq.default-release/prefs.js

    #onedrive autostart - gnome
    #systemctl --user enable onedrive
    #systemctl --user start onedrive
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
    ln -sf ${CWD}/config/nvim/after             ${HOME}/.config/nvim/after
    ln -sf ${CWD}/config/nvim/snippets          ${HOME}/.config/nvim/snippets
    ln -sf ${CWD}/config/qt5ct                  ${HOME}/.config/qt5ct
    ln -sf ${CWD}/config/qtile                  ${HOME}/.config/qtile
    ln -sf ${CWD}/config/qutebrowser            ${HOME}/.config/qutebrowser
    ln -sf ${CWD}/config/ranger                 ${HOME}/.config/ranger
    ln -sf ${CWD}/config/rofi                   ${HOME}/.config/rofi
    ln -sf ${CWD}/config/sioyek                 ${HOME}/.config/sioyek
    ln -sf ${CWD}/config/zsh/.zshrc             ${HOME}/.config/zsh/.zshrc
    ln -sf ${CWD}/config/zsh/.zshenv            ${HOME}/.config/zsh/.zshenv
    ln -sf ${CWD}/config/starship.toml          ${HOME}/.config/starship.toml
    ln -sf ${CWD}/config/mimeapps.list          ${HOME}/.config/mimeapps.list

    ln -sf ${CWD}/home/newsboat                 ${HOME}/newsboat
    ln -sf ${CWD}/home/.bashrc                  ${HOME}/.bashrc
    ln -sf ${CWD}/home/.ticker.yaml             ${HOME}/.ticker.yaml
    ln -sf ${CWD}/home/.zprofile                ${HOME}/.zprofile
    ln -sf ${CWD}/home/.npmrc                   ${HOME}/.npmrc
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
    ln -sf ${CWD}/config/zsh/.zshenv                 ${HOME}/.config/zsh/.zshenv
    ln -sf ${CWD}/config/nvim/init.lua              ${HOME}/.config/nvim/init.lua
    ln -sf ${CWD}/config/nvim/lua                   ${HOME}/.config/nvim/lua
    ln -sf ${CWD}/config/nvim/after                 ${HOME}/.config/nvim/after
    ln -sf ${CWD}/config/nvim/snippets              ${HOME}/.config/nvim/snippets
    ln -sf ${CWD}/config/ranger                     ${HOME}/.config/ranger
    ln -sf ${CWD}/xWSL/starship.toml                ${HOME}/.config/starship.toml
    ln -sf ${CWD}/home/.bashrc                      ${HOME}/.bashrc
    ln -sf ${CWD}/home/.ticker.yaml                 ${HOME}/.ticker.yaml
    ln -sf ${CWD}/home/.zprofile                    ${HOME}/.zprofile
    ln -sf ${CWD}/home/.npmrc                       ${HOME}/.npmrc
    ln -sf ${CWD}/.gitconfig                        ${HOME}/.gitconfig

    # OneDrive, Downloads, Megasync, Videos
    ln -sf /mnt/c/Users/vimi/OneDrive               ${HOME}/OneDrive
    ln -sf /mnt/c/Users/vimi/Downloads              ${HOME}/Downloads
    # ln -sf /mnt/c/Users/vimi/Mega                   ${HOME}/Mega
    # ln -sf /mnt/d/Videos                            ${HOME}/Videos

    # Obsidian scripts
    ln -sf /mnt/c/Users/vimi/OneDrive/Projekty/Linux/Skripty/obsidian-create-note.sh               ${HOME}/.local/bin/obsidian-create-note.sh
    ln -sf /mnt/c/Users/vimi/OneDrive/Projekty/Linux/Skripty/obsidian-kategorize-notes.sh          ${HOME}/.local/bin/obsidian-kategorize-notes.sh
}

git_repos(){
    [[ ! -d $HOME/git-repos ]] && mkdir -p $HOME/git-repos
    git clone https://github.com/miba07101/python.git $HOME/git-repos/python
    git clone https://github.com/miba07101/test.git $HOME/git-repos/test
    git clone https://github.com/miba07101/mcad.git $HOME/git-repos/mcad
    # musim manualne cez: gh auth login
    # git clone https://github.com/miba07101/epd.git $HOME/git-repos/epd
}

##########################################################################
# NPM SERVERS
##########################################################################

npm_servers(){
    info "LIVE, SASS SERVERS, "
    npm i -g live-server
    npm i -g sass
    npm i -g tree-sitter-cli # pre vim-matchup
    # npm i -g bash-language-server
    # npm i -g vscode-css-languageserver-bin
}

##########################################################################
# Setups
##########################################################################

gnome_setup(){
    info "GNOME SETUP"

    # nastavenie scale na 125% a ine mierky - funguje pre gnome wayland
    # potom manualne v settings-displays-scale
    # gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

    # scaling fonts factor (lepsie vyzera ako 125%)
    gsettings set org.gnome.desktop.interface text-scaling-factor '1.25'

    # nautilus
    gsettings set org.gnome.nautilus.preferences show-create-link 'true'

    # power setup
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout '3600'

    # fonts
    gsettings set org.gnome.desktop.interface font-name 'Roboto 10'
    gsettings set org.gnome.desktop.interface document-font-name 'Roboto 10'
    gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Roboto 10'

    # close, minimize buttons
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

    # cursor
    gsettings set org.gnome.desktop.interface cursor-theme 'We10XOS-cursors'

    # keybidings
    gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "['<Control>space']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>b']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys calculator "['<Super>c']"
    gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>v']"
    gsettings set org.gnome.shell.keybindings email "['<Super>m']"

    ## terminal musim nastavit manualne:
    ## settings -> keyboard -> keyboard shortcuts -> custom shortcuts -> name: wezterm, comannd: wezterm, shortcut: super+enter
    ## pre ulancher (iba ak wayland):
    ## https://github.com/Ulauncher/Ulauncher/wiki/Hotkey-In-Wayland
    ## v ulaucher nastavim hoci co, napr alt+u
    ## potom: settings ... custom shortcuts -> name: ulauncher, comand: ulauncher-toggle, shortcut: alt+space

    # change default terminal
    sudo mv /usr/bin/gnome-terminal /usr/bin/gnome-terminal.bak
    sudo ln -s /usr/bin/wezterm /usr/bin/gnome-terminal

    # Nastavenie sklopenia notebooku
    sudo -S <<< ${mypassword} sh -c 'cat > /etc/systemd/logind.conf.d/logind.conf' <<EOF
    [Login]
    HandleLidSwitch=ignore
EOF

    # symlink nvim.desktop aby nvim otvaral priamo vo wezterme -> ~/.local/share/applications
    ln -sf ${CWD}/xKDE/local_share_applications/nvim.desktop  ${HOME}/.local/share/applications/nvim.desktop

    # activation icon theme
    # gsettings set org.gnome.desktop.interface icon-theme 'Adwaita-yellow'
    gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'

    # changing folder colors
    gio set ${HOME}/Videos metadata::custom-icon \
       file:////home/vimi/.local/share/icons/Adwaita-purple/scalable/places/folder-videos.svg
    gio set ${HOME}/Downloads metadata::custom-icon \
       file:////home/vimi/.local/share/icons/Adwaita-green/scalable/places/folder-download.svg

    # install extensions
    info "INSTALL EXTENSIONS"
    EXT_DIR=".local/share/gnome-shell/extensions"
    [[ ! -d ${HOME}/${EXT_DIR} ]] && mkdir -p ${HOME}/${EXT_DIR}

    EXTENSIONS=(
      'tiling-assistant@leleat-on-github.shell-extension:github.com/Leleat/Tiling-Assistant'
      'appindicatorsupport@rgcjonas.gmail.com:github.com/ubuntu/gnome-shell-extension-appindicator'
      'mock-tray@kramo.page.shell-extension:github.com/kra-mo/mock-tray'
      'auto-adwaita-colors@celiopy:github.com/celiopy/auto-adwaita-colors'
    )

    for EXT in "${EXTENSIONS[@]}"; do
        IFS=":" read -r name url <<< "$EXT"

        echo "Do you want to install ${name}? (y/n)"
        read -r CONFIRMATION
        if [[ ${CONFIRMATION} =~ ^[Yy]$ ]]; then
            echo "Installing ${name}"

            git_url="https://${url}/releases/latest"
            latest_release=$(curl -L -s -H 'Accept: application/json' ${git_url})
            latest_version=$(echo ${latest_release} | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
            down_url="https://${url}/releases/download/${latest_version}/${name}.zip"
            wget ${down_url} -P ${TEMP_DIR}

            gnome-extensions install --force "${TEMP_DIR}/${name}.zip"

        else
            echo "Skipping ${name}"
        fi
    done

    # wezterm in nautilus
    # zyprm nautilus-extension-terminal
    # zypin python311-nautilus
    # zypin nautilus-open-any-terminal
    # gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal wezterm
    # sudo glib-compile-schemas /usr/share/glib-2.0/schemas
    # nauzypin tilus -q
}

# kde_setup(){}

qtile_setup(){
    info "QTILE SETUP"
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

    # Vytvori environment variable pre qt5ct
    sudo -S <<< ${mypassword} sh -c 'cat > /etc/environment' <<EOF
    QT_QPA_PLATFORMTHEME=qt5ct
EOF
}

wsl_setup(){
    info "WSL SETUP"
    # pre povolenie systemd - v /etc/wsl.conf ma byt [boot] systemd=true
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y -t pattern wsl_base
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y -t pattern wsl_systemd
    # pre spustanie gui aplikacii, napr. gedit ...
    # https://en.opensuse.org/openSUSE:WSL?ref=its-foss
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y -t pattern wsl_gui

    # umozni pouzivat win prikazy, napr. powershell.exe aj pri spustenom systemd
    sudo -S <<< ${mypassword} sh -c 'cat > /usr/lib/binfmt.d/WSLInterop.conf' <<EOF
    :WSLInterop:M::MZ::/init:PF
EOF
}

##########################################################################
# HLAVNA INSTALACNA FUNKCIA
##########################################################################

which_distro(){
    echo
    printf "${color}Which distro install?\[g]nome, [k]de, [q]tile, [w]sl, [Q]uit:${endcolor}\n"
    # info "Which distro install?\n[w]sl, [q]tile, [k]de, [Q]uit: "
    read -n 1 distro
    echo

    case "$distro" in
        g )
            root
            #update_system
            #basic_desktop_settings
            #zsh_config
            #basic_packages
            #desktop_packages
            #packman_packages
            #appimages
            #other_apps
            #quarto
            #postgresql
            # python
            #fonts
            #cursors
            #icons
            #gnome_kde_dotfiles
            #git_repos
            #npm_servers
            gnome_setup
            ;;
        k )
            root
            update_system
            basic_desktop_settings
            zsh_config
            basic_packages
            desktop_packages
            packman_packages
            appimages
            other_apps
            quarto
            postgresql
            python
            fonts
            cursors
            icons
            gnome_kde_dotfiles
            git_repos
            npm_servers
            kde_setup
            ;;
        q )
            root
            update_system
            basic_desktop_settings
            zsh_config
            basic_packages
            qtile_packages
            desktop_packages
            packman_packages
            appimages
            other_apps
            quarto
            postgresql
            python
            fonts
            cursors
            icons
            qtile_dotfiles
            git_repos
            npm_servers
            qtile_setup
            ;;
        w )
            root
            update_system
            zsh_config
            basic_packages
            packman_packages
            other_apps
            quarto
            postgresql
            python
            wsl_dotfiles
            git_repos
            npm_servers
            wsl_setup
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
