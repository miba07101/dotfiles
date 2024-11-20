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
        'jq' # potrebne pre script ticker - cli JSON processor
        'ripgrep' # vyhladavaci doplnok pre neovim a funkcnost Telescope doplnku
        'npm-default'
        'gcc' # C compiler
        'gcc-c++' # C++ compiler
        'clang'
        'make'
        '7zip'
        'at-spi2-core'
        'xdg-utils' # pre nastavenie defaultnych aplikacii
        'sqlitebrowser' # pre sqlite databazu pre moju flask aplikaciu
        'redis' # server pre flask kniznicu celery. pouzivam pre moju aplikaciu epd alebo isitobo.
        'kvantum-manager' # pre KDE iba
        'wezterm'
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

    info "INSTALL APPIMAGES"
    APPIMAGES_PKGS=(
        'brave'
        'freetube'
        'onlyoffice'
        'obsidian'
        'zen-browser'
    )

    for PKG in "${APPIMAGES_PKGS[@]}"; do
        echo "Do you want to install ${PKG}? (y/n)"
        read -r CONFIRMATION
        if [[ ${CONFIRMATION} =~ ^[Yy]$ ]]; then
            echo "Installing ${PKG}"
            appman -ia ${PKG}
        else
            echo "Skipping ${PKG}"
        fi
    done


}

other_apps(){

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

  freecad(){
      info "FreeCAD"
      if [ WSL -eq 1 ]
      then
          # git_url="https://github.com/FreeCAD/FreeCAD/releases/latest"
          # latest_release=$(curl-L -s -H 'Accept: application/json' ${git_url})
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
    software_list=("jdownloader:JDownloader 2"
                   "birdtray_stacer:Birdtray & Stacer"
                   "newsflash:Newsflash"
                   "ticker:Ticker"
                   "ledger_live:Ledger Live"
                   "freecad:FreeCAD"
                   "salome_meca:Salome Meca"
                   "chia_blockchain:Chia Blockchain"
                 )

    # Loop through the software list
    for entry in "${software_list[@]}"; do
        IFS=":" read -r func name <<< "$entry"

        # Ask the user if they want to install the software
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
                tar -C $HOME/quarto -xvzf quarto*.tar.gz
            
                # create symlink
                [[ ! -d $HOME/bin ]] && mkdir -p $HOME/bin
                ln -s $HOME/quarto/quarto*/bin/quarto $HOME/bin/quarto
            
                # Ensure that the folder where you created a symlink is in the path. For example:
                # ( echo ""; echo 'export PATH=$PATH:~/bin\n' ; echo "" ) >> ~/.profile
                # source ~/.profile
            
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
}

npm_servers(){
    info "LIVE, SASS SERVERS, "
    npm i -g live-server
    npm i -g sass
    npm i -g tree-sitter-cli # pre vim-matchup
    # npm i -g bash-language-server
    # npm i -g vscode-css-languageserver-bin
}


##########################################################################
# Python
##########################################################################

python(){
    info "PYTHON SETUP"
    PYTHON_PKGS=(
    	'python313'
        'python313-pip' # treba len zmenit cislo verzie python podla aktualnej
        'python313-ipython'
        'python313-devel' # pre funkciu kniznice psycopg2 - prepojenie s postgresql databazou
        'python313-bpython'
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

    # Pre neovim LSP - celosystemove
    # pip3 install pyright
    # pip3 install pynvim
    # pip3 install flake8
    # pip3 install black

    # env pre web-epipingdesign
    [[ ! -d $HOME/python-venv ]] && mkdir -p $HOME/python-venv

    python3 -m venv $HOME/python-venv/epd-venv
    source $HOME/python-venv/epd-venv/bin/activate

    pip3 install --upgrade pip

    deactivate

    # env pre web-isitobo
    [[ ! -d $HOME/python-venv ]] && mkdir -p $HOME/python-venv

    python3 -m venv $HOME/python-venv/isitobo-venv
    source $HOME/python-venv/isitobo-venv/bin/activate

    pip3 install --upgrade pip

    deactivate

    # env pre web-isitobo-test
    [[ ! -d $HOME/python-venv ]] && mkdir -p $HOME/python-venv

    python3 -m venv $HOME/python-venv/isitobo-test-venv
    source $HOME/python-venv/isitobo-test-venv/bin/activate

    pip3 install --upgrade pip

    deactivate

    # Pre yafin
    [[ ! -d $HOME/python-venv ]] && mkdir -p $HOME/python-venv

    python3 -m venv $HOME/python-venv/yafin-venv
    source $HOME/python-venv/yafin-venv/bin/activate

    pip3 install --upgrade pip
    # pip3 install yfinance
    # pip3 install pandas
    # pip3 install pandas-datareader
    pip3 install yahoofinancials

    deactivate

    # Pre quarto
    [[ ! -d $HOME/python-venv ]] && mkdir -p $HOME/python-venv

    python3 -m venv $HOME/python-venv/quarto-venv
    source $HOME/python-venv/quarto-venv/bin/activate

    pip3 install --upgrade pip
    pip3 install jupyter
    pip3 insatll handcalcs
    pip3 insatll sympy
    pip3 insatll pandas
    pip3 insatll tabulate
    pip3 insatll latexify-py

    deactivate
}

##########################################################################
# Dotfiles symlinks
##########################################################################

kde_dotfiles(){
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
    ln -sf ${CWD}/config/ranger                 ${HOME}/.config/ranger
    ln -sf ${CWD}/config/zsh/.zshrc             ${HOME}/.config/zsh/.zshrc
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

git_repos(){
    [[ ! -d $HOME/git-repos ]] && mkdir -p $HOME/git-repos
    git clone https://github.com/miba07101/python.git $HOME/git-repos/python
    git clone https://github.com/miba07101/test.git $HOME/git-repos/test
    # musim manualne cez: gh auth login
    # git clone https://github.com/miba07101/epd.git $HOME/git-repos/epd
}

##########################################################################
# Theme
##########################################################################

qtile_theme(){
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

##########################################################################
# HLAVNA INSTALACNA FUNKCIA
##########################################################################

which_distro(){
    echo
    printf "${color}Which distro install?\[q]tile, [k]de, [Q]uit:${endcolor}\n"
    # info "Which distro install?\n[w]sl, [q]tile, [k]de, [Q]uit: "
    read -n 1 distro
    echo

    case "$distro" in
        q )
            root
            update_system
            basic_desktop_settings
            qtile_settings
            zsh_config
            basic_packages
            qtile_packages
            packman_packages
            appimages
            other_apps
            quarto
            postgresql
            npm_servers
            python
            kde_dotfiles
            qtile_dotfiles
            git_repos
            qtile_theme
            ;;
        k )
            root
            update_system
            basic_desktop_settings
            zsh_config
            basic_packages
            packman_packages
            appimages
            other_apps
            quarto
            # postgresql
            # npm_servers
            # python
            kde_dotfiles
            # git_repos
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
