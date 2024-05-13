#!/bin/bash

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
        'libcairo2' # epd - pre weasyprint
        'libpango-1_0-0' # epd - pre weasyprint
    )

    for PKG in "${BASIC_PKGS[@]}"; do
        echo "Installing ${PKG}"
        sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
    done

    # update tealdeer cache
    tldr --update
}

wsl_utilities(){
    info "WSL UTILLITIES"
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
# Programy z netu
##########################################################################
lazygit(){
    info "LAZYGIT"
    repourl="https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo"
    sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
    sudo -S <<< ${mypassword} zypper ${REFRESH}
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y lazygit
}

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
    [[ ! -d $HOME/.local/bin ]] && mkdir -p $HOME/.local/bin
    ln -s $HOME/quarto/quarto*/bin/quarto $HOME/.local/bin/quarto

    # Ensure that the folder where you created a symlink is in the path. For example:
    # ( echo ""; echo 'export PATH=$PATH:~/bin\n' ; echo "" ) >> ~/.profile
    # source ~/.profile

    # Check The Installation
    # quarto check
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
# Python enviroments
##########################################################################
python_env(){
    info "PYTHON ENVIROMENTS SETUP"

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

    # Pre quarto/mcad
    [[ ! -d $HOME/python-venv ]] && mkdir -p $HOME/python-venv

    python3 -m venv $HOME/python-venv/mcad-venv
    source $HOME/python-venv/mcad-venv/bin/activate

    pip3 install --upgrade pip
    pip3 install sympy
    pip3 install pandas
    pip3 install tabulate
    pip3 install jupyter
    pip3 install handcalcs
    pip3 install latexify-py
    pip3 install efficalc

    deactivate
}

##########################################################################
# SYMLINKS
##########################################################################
symlinks(){
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

##########################################################################
# GIT repos
##########################################################################
git_repos(){
    [[ ! -d $HOME/git-repos ]] && mkdir -p $HOME/git-repos
    git clone https://github.com/miba07101/python.git $HOME/git-repos/python
    git clone https://github.com/miba07101/test.git $HOME/git-repos/test
    git clone https://github.com/miba07101/mcad.git $HOME/git-repos/mcad
    # musim manualne cez: gh auth login
    # git clone https://github.com/miba07101/epd.git $HOME/git-repos/epd
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
  wsl_utilities
  lazygit
  ticker
  quarto
  npm_servers
  python_env
  symlinks
  git_repos
  zsh_config
}

which_distro

# Zaverecna sprava
echo
info "Instalacia ukoncena :D"
