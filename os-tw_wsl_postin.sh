#!/bin/bash
# Verzia systemu - distribucia
DISTRO=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)

# Meno win pouzivatela
WIN_USER=$(powershell.exe -NoProfile -NonInteractive -Command "\$env:UserName" | tr -d '\r')

# Nastavenie vystupov / farba a symboly
columns=$(tput cols)
color=$'\e[1;35m'
endcolor=$'\e[0m'
hash="################################"
star="******************************"
ex="!!!!!!!!!!!!!!!!!!!!!"

# Alias pre zypper
REFRESH='--gpg-auto-import-keys refresh'
UPDATE='--non-interactive dist-upgrade --auto-agree-with-licenses'
#INSTALL='--non-interactive --ignore-unknown --no-cd install --auto-agree-with-licenses --allow-unsigned-rpm --allow-vendor-change --allow-downgrade --force'
INSTALL='--ignore-unknown install --auto-agree-with-licenses --allow-unsigned-rpm --allow-vendor-change --allow-downgrade'

# Uvodna sprava
echo
msg="${color} ${hash} Zacinam instalaciu a nastavenia ${hash} ${endcolor}"
printf "%*s\n" $(((${#msg}+${columns})/2)) "${msg}"
sleep 1

root(){
# Zisti ci som ROOT, ak nie tak zadam heslo
if [[ "${UID}" -ne 0 ]]
then
    echo
    echo "${color} Enter ROOT password: ${endcolor}"
    read mypassword
else
    echo
    echo "${color}  You are ROOT user ${endcolor}"
    echo
fi
}

update_system(){
echo
echo "${color} ${hash} UPDATE SYSTEM ${hash} ${endcolor}"
echo
echo
echo "${color} ${star} Refresh repository ... ${star} ${endcolor}"
sleep 1
echo

# ------------------------------------------------------------------------
# Repository refresh
# ------------------------------------------------------------------------
sudo -S <<< ${mypassword} zypper ${REFRESH}

if [ "${?}" -ne 0 ]
then
    echo
    echo "${color} ${ex} Could not refresh repository ${ex} ${endcolor}"
    echo
    exit 1
fi

echo
sleep 1
echo "${color} ${star} Updating ... ${star} ${endcolor}"
sleep 1
echo

# ------------------------------------------------------------------------
# System upgrade/update
# ------------------------------------------------------------------------
sudo -S <<< ${mypassword} zypper ${UPDATE}

if [ "${?}" -ne 0 ]
then
    echo
    echo "${color} ${ex} Could not perform system update ${ex} ${endcolor}"
    echo
    exit 1
fi
}

install_packages(){
echo
echo "${color} ${hash} INSTALL PACKAGES ${hash} ${endcolor}"
sleep 1
echo

# ------------------------------------------------------------------------
# Instalacia programov z MAIN OSS repository
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Main packages installing ... ${star} ${endcolor}"
sleep 1
echo

PKGS=(
# 'gvim'
'neovim'
'git'
'zsh'
'exa'
'fd'
'curl'
# 'mpv'
'yt-dlp'
'starship'
'ranger' # python terminal filemanager
'xsel' # umoznuje copirovat adresu suboru z Rangera do systemoveho clipboardu
# 'cava' # hudobny vizualizer
'jq' # potrebne pre script ticker - cli JSON processor
'python310-pip' # treba len zmenit cislo verzie python podla aktualnej
# 'python310-bpython' # treba len zmenit cislo verzie python podla aktualnej
'ripgrep' # vyhladavaci doplnok pre neovim a funkcnost Telescope doplnku
'npm-default'
'gcc' # C compiler
'gcc-c++' # C++ compiler
'clang'
'make'
'stow' # manazuje dotfiles
)

for PKG in "${PKGS[@]}"; do
    echo "Installing ${PKG}"
    sleep 1
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
done

echo "message"
echo "${color} ${star} Main packages installed OK ${star} ${endcolor}"
sleep 1
echo "message"

# ------------------------------------------------------------------------
# Packman repository
# ------------------------------------------------------------------------
echo "message"
echo "${color} ${star} Packman repository installing ... ${star} ${endcolor}"
sleep 1
echo "message"

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
)

for PAC_PKG in "${PAC_PKGS[@]}"; do
    echo "Installing ${PAC_PKG}"
    sleep 1
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PAC_PKG}
done

echo "message"
echo "${color} ${star} Packman repo codecs installed OK ${star} ${endcolor}"
sleep 1
echo "message"

# ------------------------------------------------------------------------
# Ticker
# ------------------------------------------------------------------------
echo
echo "${color} ${star} Ticker installing ... ${star} ${endcolor}"
sleep 1
echo

curl -Ls https://api.github.com/repos/achannarasappa/ticker/releases/latest | grep -wo "https.*linux-amd64*.tar.gz" | wget -qi -
tar -xvf ticker*.tar.gz ticker
chmod +x ./ticker
sudo -S <<< ${mypassword} mv ticker /usr/local/bin/
rm -f ticker*.tar.gz

echo
echo "${color} ${star} Ticker installed OK ${star} ${endcolor}"
sleep 1

# ------------------------------------------------------------------------
# WSL utilities / napr. spustia defaultny web browser na windowse
# ------------------------------------------------------------------------
echo
echo "${color} ${star} WSL utilities installing ... ${star} ${endcolor}"
sleep 1
echo

repourl="https://download.opensuse.org/repositories/home:/wslutilities/openSUSE_Tumbleweed/home:wslutilities.repo"
sudo -S <<< ${mypassword} zypper addrepo -f ${repourl}
sudo -S <<< ${mypassword} zypper ${REFRESH}
sudo -S <<< ${mypassword} zypper ${INSTALL} -y wslu

# Nastavenie wslview - vytvori subor wslview.desktop a potom nastavi ako default
# set -eu -o pipefail
#
# sudo -S <<< ${mypassword} sh -c 'cat >/usr/share/applications/wslview.desktop' <<EOF
# [Desktop Entry]
# Version=1.0
# Name=WSLview
# Exec=wslview %u
# Terminal=false
# X-MultipleArgs=false
# Type=Application
# Categories=GNOME;GTK;Network;WebBrowser;
# MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
# EOF

# Nastavi wslview ako default pre otvaranie suborov web, image ..
# xdg-settings set default-web-browser wslview.desktop

echo
echo "${color} ${star} WSL utilities installed OK ${star} ${endcolor}"
sleep 1
echo

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

echo
echo "${color} ${star} ZSH main shell OK ${star} ${endcolor}"
sleep 1
}

copy_files(){
# ------------------------------------------------------------------------
# Copy files
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} COPY Files ${hash} ${endcolor}"
sleep 1
echo

# Priecinok so zalohou
FILES_DIR=/mnt/c/Users/$WIN_USER/OneDrive/Linux/WSL/OpenSuse-Tumblweed_Ubuntu/

# zisti ci priecinky existuju, ak nie tak ich vytvori
[[ ! -d $HOME/.config ]] && mkdir -p $HOME/.config

# nakopiruje potrebne subory
cp -rf ${FILES_DIR}/config/*                    $HOME/.config
cp -rfv ${FILES_DIR}/{.bashrc,.vimrc,.zshrc,.ticker.yaml}    $HOME/

echo
echo "${color} ${star} COPY OK ${star} ${endcolor}"
sleep 1
}

python-neovim(){
  # Pre neovim LSP - celosystemove
  pip3 install pyright
  pip3 install pynvim
  pip3 install flake8
  pip3 install black

# Pre web-epipingdesign
[[ ! -d $HOME/Python/epd ]] && mkdir -p $HOME/Python/epd

python3 -m venv $HOME/Python/epd/epd-venv
source $HOME/Python/epd/epd-venv/bin/activate

pip3 install --upgrade pip
pip3 install flask
pip3 install pandas

deactivate
}


python(){
# ------------------------------------------------------------------------
# PYTHON install
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} PYTHON ${hash} ${endcolor}"
sleep 1
echo

# Install depencies
PKG_python=(
# pre Jupyterlab a LaTex
'pandoc' # Conversion between markup formats
'texlive-xetex' # An extended variant of TeX for use with Unicode sources
'texlive-fontsetup' # A front-end to fontspec, for selected fonts with math support
'texlive-adjustbox'
'texlive-bibtex'
'texlive-caption'
'texlive-collectbox'
'texlive-enumitem'
'texlive-eurosym'
'texlive-eurosym-fonts'
'texlive-fancyvrb'
'texlive-float'
'texlive-geometry'
'texlive-ifoddpage'
'texlive-jknapltx'
'texlive-oberdiek'
'texlive-parskip'
'texlive-rsfs'
'texlive-rsfs-fonts'
'texlive-tcolorbox'
'texlive-titling'
'texlive-ucs'
'texlive-ulem'
'texlive-upquote'
'texlive-varwidth'
)

for PKG in "${PKG_python[@]}"; do
    echo "Installing ${PKG}"
    sleep 1
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
done


# Pre web-epipingdesign
[[ ! -d $HOME/python/epd ]] && mkdir -p $HOME/python/epd

python3 -m venv $HOME/python/epd/epd-venv
source $HOME/python/epd/epd-venv/bin/activate

pip install --upgrade pip
pip install flask

deactivate

# Pre yafin
[[ ! -d $HOME/python/yafin ]] && mkdir -p $HOME/python/yafin

python3 -m venv $HOME/python/yafin/yafin-venv
source $HOME/python/yafin/yafin-venv/bin/activate

pip install --upgrade pip
pip install yfinance
pip install pandas
pip install pandas-datareader

deactivate

# Pre Jupyterlab
[[ ! -d $HOME/python/jupyter ]] && mkdir -p $HOME/python/jupyter

python3 -m venv $HOME/python/jupyter/jupyter-venv
source $HOME/python/jupyter/jupyter-venv/bin/activate

pip install --upgrade pip
pip install jupyterlab
pip install nbconvert # pre konverziu na pdf
pip install sympy
pip install matplotlib

deactivate

echo
echo "${color} ${star} PYTHON OK ${star} ${endcolor}"
sleep 1

}

live-server(){
# ------------------------------------------------------------------------
# Live-server install pre zobrazovanie web stránok
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} live-server ${hash} ${endcolor}"
sleep 1
echo


sudo -S <<< ${mypassword} npm i -g live-server

echo
echo "${color} ${star} live-server OK ${star} ${endcolor}"
sleep 1

}

gnome(){
# ------------------------------------------------------------------------
# Gnome settings
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} gnome settings ${hash} ${endcolor}"
sleep 1
echo

# Install depencies
PKG_gnome=(
'patterns-gnome-gnome_x11' # X11 server
'patterns-gnome-gnome' # Wayland
# 'gedit'  # textovy editor
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


# nastavenie tmavej temy...ak chcem svetlu tak iba Adwaita
# gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
# nastavenie bieleho kurzora
# gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'
# nastavenie velkosti kurzora
gsettings set org.gnome.desktop.interface cursor-size 15

echo
echo "${color} ${star} gnome settings OK ${star} ${endcolor}"
sleep 1

}

appimage-launcher(){
# ------------------------------------------------------------------------
# Appimage-launcher installation settings
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} Appimage-launcher installation ${hash} ${endcolor}"
sleep 1
echo

# Install depencies
PKG_appimage=(
'libqt5-qdbus'
'libQt5Widgets5'
'fuse'
'libfuse2'
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

# Create directory downloads
[[ ! -d $HOME/downloads ]] && mkdir -p $HOME/downloads
wget ${down_url} -P $HOME/downloads

# Install appimage/launcher
sudo -S <<< ${mypassword} zypper ${INSTALL} -y $HOME/downloads/*.rpm
rm -rf $HOME/downloads/*.rpm

echo
echo "${color} ${star} Appimage-launcher install OK ${star} ${endcolor}"
sleep 1
}


freecad(){
# ------------------------------------------------------------------------
# FreeCAD appimage installation settings
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} FreeCAD appimage installation ${hash} ${endcolor}"
sleep 1
echo

# git_url="https://github.com/FreeCAD/FreeCAD/releases/latest"
# latest_release=$(curl -L -s -H 'Accept: application/json' ${git_url})
# latest_version=$(echo ${latest_release} | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
down_url="https://github.com/FreeCAD/FreeCAD/releases/download/0.20.1/FreeCAD_0.20-1-2022-08-20-conda-Linux-x86_64-py310.AppImage"

# Create directory downloads
[[ ! -d $HOME/downloads ]] && mkdir -p $HOME/downloads
wget ${down_url} -P $HOME/downloads/

# integruje FreeCAD appimage do systemu (musi byt nainstalovany AppImageLauncher)
ail-cli integrate $HOME/downloads/FreeCAD_0.20-1-2022-08-20-conda-Linux-x86_64-py310.AppImage

echo
echo "${color} ${star} Appimage-launcher install OK ${star} ${endcolor}"
sleep 1
}


salome-meca(){
# ------------------------------------------------------------------------
# Salome-Meca installation settings
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} Salome-Meca installation ${hash} ${endcolor}"
sleep 1
echo

# Install depencies
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

echo
echo "${color} ${star} Salome-Meca install OK ${star} ${endcolor}"
sleep 1
}

postgresql(){
# ------------------------------------------------------------------------
# PostgreSQL installation settings
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} PostgreSQL installation ${hash} ${endcolor}"
sleep 1
echo

# Install depencies
PKG_postgresql=(
'postgresql'
'postgresql-server'
'postgresql-contrib'
'postgresql-plpython'
)

for PKG in "${PKG_postgresql[@]}"; do
    echo "Installing ${PKG}"
    sleep 1
    sudo -S <<< ${mypassword} zypper ${INSTALL} -y ${PKG}
done

# # tu to zastane aby som zadal heslo
echo
echo "${color} postgres password ${endcolor}"
sudo passwd postgres

echo
# # Create postgreSQL data directory
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

echo
echo "${color} ${star} PostgreSQL install OK ${star} ${endcolor}"
sleep 1
}

dotfiles(){
# ------------------------------------------------------------------------
# dotfiles
# ------------------------------------------------------------------------
echo
echo "${color} ${hash} Dotfiles ${hash} ${endcolor}"
sleep 1
echo

cd $HOME
git_url="https://github.com/miba07101/dotfiles.git"
git clone $git_url

stow --dir $HOME/dotfiles/ */

echo
echo "${color} ${star} Appimage-launcher install OK ${star} ${endcolor}"
sleep 1
}


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
