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
        'zsh'
        'starship'
        'eza'
        'fd'
        'tealdeer' # tldr pre man pages
        'curl'
        'yt-dlp' # stahovanie youtube videi
        'ranger' # python terminal filemanager
        'xsel' # umoznuje copirovat adresu suboru z Rangera do systemoveho clipboardu
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
        'gh' # git-cli
    )

    for PKG in "${BASIC_PKGS[@]}"; do
        echo "Installing ${PKG}"
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done

    # update tealdeer cache
    tldr --update
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

lazygit(){
    info "LAZYGIT"
    repourl="https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y lazygit
}


##########################################################################
# Programy z netu
##########################################################################

ticker(){
    info "TICKER"
    curl -Ls https://api.github.com/repos/achannarasappa/ticker/releases/latest | grep -wo "https.*linux-amd64*.tar.gz" | wget -qi -
    tar -xvf ticker*.tar.gz ticker
    chmod +x ./ticker
    mv ticker ${HOME}/.local/bin/
    rm -f ticker*.tar.gz
}

quarto(){
    info "QUARTO"

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

    # Check The Installation
    # quarto check
}

##########################################################################
# Python enviroments
##########################################################################
python(){
    info "PYTHON SETUP"

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

    # Pre yafin
    [[ ! -d $HOME/python-venv ]] && mkdir -p $HOME/python-venv

    python3 -m venv $HOME/python-venv/yafin-venv
    source $HOME/python-venv/yafin-venv/bin/activate

    pip3 install --upgrade pip
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
# WSL
##########################################################################
wsl_utilities(){
    info "WSL UTILLITIES"
    # umoznuje napr. spustia defaultny web browser na windowse
    # nefunguje, pretoze vyvojari davaju stale staru verziu
    # nova verzia funguje ale treba ju compilovat zo zdrojoveho kodu
    # repourl="https://download.opensuse.org/repositories/home:/wslutilities/openSUSE_Tumbleweed/home:wslutilities.repo"
    # sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    # sudo -S <<< ${mypassword} zypper ${REFRESH}
    # sudo -S <<< ${mypassword} zypper ${INSTALL} -y wslu

    # Nastavenie wslview - vytvori subor wslview.desktop a potom nastavi ako default
    # nie je to nutne, nechavam len ako priklad
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
    # je potrebne nainastalovat xdg-utils
    # xdg-settings set default-web-browser wslview.desktop

    # namiesto wslu budem pouzivat wsl-open
    npm i -g wsl-open
    # wsl-open -w # nastavi wsl-open ako default Shell Browser

    [[ ! -d $HOME/.local/share/applications ]] && mkdir -p $HOME/.local/share/applications
    cat << "EOF" > ${HOME}/.local/applications/wslopen.desktop
[Desktop Entry]
Version=1.0
Name=WSLopen
Exec=wsl-open %u
Terminal=false
X-MultipleArgs=false
Type=Application
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
EOF

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
# NPM servers
##########################################################################
npm_servers(){
    info "LIVE, SASS SERVERS, "
    npm i -g live-server
    npm i -g sass
    # npm i -g bash-language-server
    # npm i -g vscode-css-languageserver-bin
}

##########################################################################
# ZSH config
##########################################################################
zsh_config(){
    info "ZSH SETUP"
    # Nastavi zsh ako predvoleny shell namiesto bash
    chsh -s $(which zsh)
}

##########################################################################
# HLAVNA INSTALACNA FUNKCIA
##########################################################################
which_distro(){
  root
  update_system
  basic_packages
  packman_packages
  lazygit
  ticker
  quarto
  python
  wsl_utilities
  # wsl_gnome
  wsl_dotfiles
  git_repos
  npm_servers
  zsh_config
}

which_distro

# Zaverecna sprava
echo
info "Instalacia ukoncena :D"
