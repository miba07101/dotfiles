# Lines configured by zsh-newuser-install
HISTFILE=$ZDOTDIR/zsh_history
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$ZDOTDIR/.zshrc"

# pre moznost vyberu doplnenia menu, pr. cd TAB da mi menu a opat TAB a mozem vyberat pomocou sipiek
autoload -Uz compinit
setopt PROMPT_SUBST
compinit
zstyle ":completion:*" menu select
# End of lines added by compinstall

#############
# WSL
#############

# zistim ci som na WSL
if [[ "$(</proc/version)" == *WSL* ]]; then
    isWSL=1
else
    isWSL=2
fi

case $isWSL in
    1)
        # umozni duplikovat panel vo windows terminal a otvori novy panel v tom istom priecinku
        # v podstate povie win terminalu, ze toto je pracovny priecinok
        precmd() {
            printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")"
        }

        # Enviroment variables
        export WIN_USERNAME=$(powershell.exe -NoProfile -NonInteractive -Command "\$env:UserName" | tr -d '\r')
        # export PGDATA='/usr/local/pgsql/data'

        # Variables
        OneDrive_DIR=/mnt/c/Users/$WIN_USERNAME/OneDrive/
        SCRIPTS_DIR=/mnt/c/Users/$WIN_USERNAME/OneDrive/Projekty/Linux/Skripty/
        ;;
    2)
        # Variables
        OneDrive_DIR=$HOME/OneDrive/
        SCRIPTS_DIR=$HOME/OneDrive/Projekty/Linux/Skripty/
        ;;
esac

#############
# PLUGINY
#############

# funkcia na povolenie/source pluginu ak existuje
function zsh_add_file() {
    [ -f "$ZDOTDIR/$1" ] && source "$ZDOTDIR/$1"
}

# funkcia na pridanie pluginov
function zsh_add_plugin() {
    PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)
    if [ -d "$ZDOTDIR/$PLUGIN_NAME" ]; then
        #           For plugins
        zsh_add_file "$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
            zsh_add_file "$PLUGIN_NAME/$PLUGIN_NAME.zsh"
    else
        git clone "https://github.com/$1.git" "$ZDOTDIR/$PLUGIN_NAME"
    fi
}

# tu pridam plugin
zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"

#############
# FUNKCIE
#############

# Colormap
function colormap() {
    for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

# Firefox backup
function fire_backup(){
    # ak je iba 1x '>' tak prepise cely dokument, ak su 2x '>>' tak vlozi novy riadok
    grep 'browser.compactmode.show' ${HOME}/.mozilla/firefox/*.default-release/prefs.js > ${HOME}/.mozilla/firefox/*.default-release/user.js
    grep 'browser.uiCustomization.state' ${HOME}/.mozilla/firefox/*.default-release/prefs.js >> ${HOME}/.mozilla/firefox/*.default-release/user.js
    grep 'browser.newtabpage.pinned' ${HOME}/.mozilla/firefox/*.default-release/prefs.js >> ${HOME}/.mozilla/firefox/*.default-release/user.js
}

# Ranger - otvori shell tam kde vypnem rangera
function f() {
    temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
    ranger --choosedir="$temp_file" -- "${@:-$PWD}"
    if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
        cd -- "$chosen_dir"
    fi
    rm -f -- "$temp_file"
}

# Yazi - otvori shell tam kde vypnem yazi
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Firefox update - updatne prefs.js s usre.js a naopak - kvoli zaloskam serialov
function fireup() {
    local firefox_dir
    firefox_dir=$(find "${HOME}/.mozilla/firefox/" -maxdepth 1 -type d -name "*default-release*" | head -n 1)
    if [ -z "$firefox_dir" ]; then
        echo "Firefox profile directory not found."
        exit 1
    fi
    echo "Full firefox path: $firefox_dir"
    # Dereference the symbolic link and apply sed to the target file
    sed -i "/browser\.newtabpage\.pinned/d" "$(readlink -f "$firefox_dir/user.js")"
    grep browser.newtabpage.pinned "${firefox_dir}/prefs.js" >> "${firefox_dir}/user.js"
    echo "Firefox prefs.js and user.js updated"
}

# Git auto push/pull
function push() {

    local base_dirs=("$HOME/git-repos")  # Default path, change if needed
    local single_repos=("$HOME/.dotfiles")  # Single repository paths

    for base_dir in "${base_dirs[@]}"; do
        # Ensure the directory exists
        if [[ ! -d "$base_dir" ]]; then
            echo -e "\e[31mError: Directory '$base_dir' not found!\e[0m"
            continue
        fi

        # Iterate over all subdirectories (assuming each is a Git repo)
        for repo in "$base_dir"/*/; do
            [[ -d "$repo/.git" ]] || { echo -e "\e[33mSkipping: Not a Git repository ($repo)\e[0m"; continue; }

            echo -e "\n\e[36mProcessing repository: $repo\e[0m"
            cd "$repo" || continue

            # Check for changes
            if git status --porcelain | grep -q .; then
                changes=$(git diff --name-only)
                echo -n "Enter a commit message for $repo (or press Enter for default): "
                read -r commit_message
                commit_message=${commit_message:-"up $(hostname) $changes $(date '+%Y-%m-%d %H:%M')"}

                # Perform Git operations
                git add .
                if git commit -m "$commit_message"; then
                    echo -e "\e[32mCommitted changes in $repo\e[0m"
                    git push && echo -e "\e[32mPushed changes for $repo\e[0m" || echo -e "\e[31mPush failed in $repo\e[0m"
                else
                    echo -e "\e[31mCommit failed in $repo\e[0m"
                fi
            else
                echo -e "\e[32mNo changes to commit in $repo\e[0m"
            fi
        done
    done

    # Handle single repositories
    for repo in "${single_repos[@]}"; do
        [[ -d "$repo/.git" ]] || { echo -e "\e[33mSkipping: Not a Git repository ($repo)\e[0m"; continue; }

        echo -e "\n\e[36mProcessing repository: $repo\e[0m"
        cd "$repo" || continue

        # Check for changes
        if git status --porcelain | grep -q .; then
            changes=$(git diff --name-only)
            echo -n "Enter a commit message for $repo (or press Enter for default): "
            read -r commit_message
            commit_message=${commit_message:-"up $(hostname) $changes $(date '+%Y-%m-%d %H:%M')"}

            # Perform Git operations
            git add .
            if git commit -m "$commit_message"; then
                echo -e "\e[32mCommitted changes in $repo\e[0m"
                git push && echo -e "\e[32mPushed changes for $repo\e[0m" || echo -e "\e[31mPush failed in $repo\e[0m"
            else
                echo -e "\e[31mCommit failed in $repo\e[0m"
            fi
        else
            echo -e "\e[32mNo changes to commit in $repo\e[0m"
        fi
    done
}

function pull() {
    local base_dirs=("$HOME/git-repos")  # Default path, change if needed
    local single_repos=("$HOME/.dotfiles")  # Single repository paths

    for base_dir in "${base_dirs[@]}"; do
        # Ensure the directory exists
        if [[ ! -d "$base_dir" ]]; then
            echo -e "\e[31mError: Directory '$base_dir' not found!\e[0m"
            continue
        fi

        # Iterate over all subdirectories (assuming each is a Git repo)
        for repo in "$base_dir"/*/; do
            [[ -d "$repo/.git" ]] || { echo -e "\e[33mSkipping: Not a Git repository ($repo)\e[0m"; continue; }

            echo -e "\n\e[36mProcessing repository: $repo\e[0m"
            cd "$repo" || continue
            echo -e "\e[34mPulling latest changes for $repo...\e[0m"
            if git pull; then
                echo -e "\e[32mSuccessfully pulled changes for $repo\e[0m"
            else
                echo -e "\e[31mPull failed in $repo\e[0m"
            fi
        done
    done

    # Handle single repositories
    for repo in "${single_repos[@]}"; do
        [[ -d "$repo/.git" ]] || { echo -e "\e[33mSkipping: Not a Git repository ($repo)\e[0m"; continue; }

        echo -e "\n\e[36mProcessing repository: $repo\e[0m"
        cd "$repo" || continue
        echo -e "\e[34mPulling latest changes for $repo...\e[0m"
        if git pull; then
            echo -e "\e[32mSuccessfully pulled changes for $repo\e[0m"
        else
            echo -e "\e[31mPull failed in $repo\e[0m"
        fi
    done
}

# Auto youtube download
function ytd() {
    # Get the YouTube link from clipboard
    if [[ $isWSL == 1 ]]; then
        link=$(powershell.exe Get-Clipboard | tr -d '\r')
    else
        link=$(xclip -o -selection clipboard)
    fi

    # Check if the link looks like a YouTube URL
    if [[ $link =~ ^(https?://)?(www\.)?(youtube\.com|youtu\.be)/ ]]; then
        # Change directory to Downloads folder
        cd "$HOME/Downloads" || exit

        echo -e "\e[32mDownload started for: $link\e[0m"

        # Download the video using yt-dlp
        yt-dlp "$link"

    else
        echo -e "\e[31mNo valid YouTube link found in clipboard.\e[0m"
    fi
}

#############
# Environment variables
#############
source "$ZDOTDIR/.zshenv"
export EDITOR="nvim"
export VISUAL="nvim"
export RANGER_LOAD_DEFAULT_RC=false
export PATH=$PATH:$HOME/.npm/bin
export NODE_PATH=$NODE_PATH:$HOME/.npm/lib/node_modules
export OneDrive_DIR
export SCRIPTS_DIR
export ZK_NOTEBOOK_DIR="$OneDrive_DIR/Dokumenty/zPoznamky/Obsidian/"

#############
# ALIASES
#############
alias zypup='sudo zypper dup'
alias zypin='sudo zypper install'
alias zyprm='sudo zypper remove -u'
alias zypse='zypper search'
alias zypinfo='zypper info'
alias zypre='sudo zypper refresh'
alias pipup='pip3 list -o | cut -f1 -d" " | tr " " "\n" | awk "{if(NR>=3)print}" | cut -d" " -f1 | xargs -n1 pip3 install -U'
alias zsh-update-plugins="find "$ZDOTDIR" -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull -q"

# Config files
alias vb='nvim $HOME/.bashrc'
alias vz='nvim $ZDOTDIR/.zshrc'
alias vv='nvim $HOME/.config/nvim/init.lua'
alias vq='nvim $HOME/.config/qtile/config.py'
alias vs='nvim $HOME/.config/starship.toml'

# App
alias v='nvim'
alias ranger='f'
alias yazi='y'
alias ex='exit'
alias fd='fd -Hi'
alias ls='eza -la --icons'
alias pg='sudo -i -u postgres'
alias gl='lazygit'
alias lazy='lazygit'
alias salome='$HOME/salome-meca/./salome_meca-lgpl-2021.0.0-2-20211014-scibian-9'
alias freecad='$HOME/Applications/FreeCAD_0.20-1-2022-08-20-conda-Linux-x86_64-py310_b6b0ddf25121b8cf8cc18f02e81151b7.AppImage'

# Python
# alias epd='source $HOME/.py-venv/epd-venv/bin/activate && cd $HOME/git-repos/epd'
alias epd='source $HOME/python-venv/epd-venv/bin/activate && cd $HOME/git-repos/epd'
alias ppc='source $HOME/git-repos/ppc-onrender/.venv/bin/activate && cd $HOME/git-repos/ppc-onrender'
# alias io='source $HOME/.py-venv/isitobo-venv/bin/activate && cd $HOME/git-repos/isitobo'
alias io='source $HOME/python-venv/isitobo-venv/bin/activate && cd $HOME/git-repos/isitobo'
alias test-env='source $HOME/python-venv/test-venv/bin/activate && cd $HOME/git-repos/test'
alias yafin='source $HOME/python-venv/yafin-venv/bin/activate && python3 $SCRIPTS_DIR/yafin.py'
alias mcad='source $HOME/python-venv/mcad-venv/bin/activate && cd $HOME/git-repos/mcad'
alias dea='deactivate && cd $HOME'

# Jupyter
export JUPYTER_NOTEBOOK_STYLE='from IPython.display import HTML;HTML("<style>div.text_cell_render{font-size:130%;padding-top:50px;padding-bottom:50px}</style>")'
alias jn='jupyter notebook'
alias jl='jupyter lab'
alias gjl='source $HOME/python-venv/mcad-venv/bin/activate && cd $HOME/git-repos/mcad/01-jupyterlab'

# Obsidian
alias oo='cd $OneDrive_DIR/Dokumenty/zPoznamky/Obsidian'
alias on='obsidian-create-note.sh'
alias ok='obsidian-kategorize-notes.sh'
alias or='nvim $OneDrive_DIR/Dokumenty/zPoznamky/Obsidian/inbox/*.md'

# ZK notes
function zn(){
    zk new --title "$@" "$ZK_NOTEBOOK_DIR/inbox"
}
function zl(){
    zk edit --interactive "$@"
}
function zf(){
    zk edit --interactive --match "$@"
}
function zt(){
    zk edit --interactive --tag "$@"
}
function zp(){
    zk edit --limit 1 --sort modified- "$@"
}


# Quarto
alias qut='quarto use template'
alias qce='quarto create extension format'
alias qcp='quarto create project'
qrp() {
    quarto render "$1" --to pdf
}

# Ollama Ai
alias olr='ollama run qwen2.5-coder:1.5b'
alias ols='ollama stop qwen2.5-coder:1.5b'

# Recording
alias rec='$SCRIPTS_DIR./stream_record_linux.sh'
case $isWSL in
    1)
        alias mpv='/mnt/c/Users/$WIN_USERNAME/AppData/Local/Microsoft/WindowsApps/519Ezhik.mpvUnofficial_xfkyq1j2kc7zp/mpv.exe'
        alias stv='mpv "C:\Users\\$WIN_USERNAME\\OneDrive\Linux\IPTV\sk-cz.m3u"'
        alias ptv='mpv "C:\Users\\$WIN_USERNAME\\OneDrive\Linux\IPTV\ptv.m3u"'
        alias ulozto='ulozto-downloader --parts 50 --parts-progress --auto-captcha --output "/mnt/c/Users/$WIN_USERNAME/Downloads/"'
        alias backup='$HOME/OneDrive/Linux/Qtile/./qtile-backup.sh'
        ;;
    2)
        alias stv='mpv "$HOME/OneDrive/Linux/IPTV/sk-cz.m3u"'
        alias ptv='mpv "$HOME/OneDrive/Linux/IPTV/ptv.m3u"'
        alias ulozto='ulozto-downloader --parts 50 --parts-progress --auto-captcha --output "${HOME}/Downloads/"'
        alias backup='$HOME/OneDrive/Linux/Qtile/./qtile-backup.sh'
        ;;
esac

# python virtual env wrapper
# https://gist.github.com/benlubas/5b5e38ae27d9bb8b5c756d8371e238e6
# $ mkvenv myvirtualenv # creates venv under ~/python-venv/
# $ venv myvirtualenv   # activates venv
# $ deactivate          # deactivates venv
# $ rmvenv myvirtualenv # removes venv
export VENV_HOME="$HOME/.py-venv"
[[ -d $VENV_HOME ]] || mkdir $VENV_HOME

lsvenv() {
    ls -1 $VENV_HOME
}

venv() {
    if [ $# -eq 0 ]
    then
        echo "Please provide venv name"
    else
        source "$VENV_HOME/$1/bin/activate"
    fi
}

mkvenv() {
    if [ $# -eq 0 ]
    then
        echo "Please provide venv name"
    else
        python3 -m venv $VENV_HOME/$1
    fi
}

rmvenv() {
    if [$# -eq 0 ]
    then
        echo "Please provide venv name"
    else
        rm -r $VENV_HOME/$1
    fi
}

#############
# KLAVESOVE SKRATKY
#############

# 10ms for key sequences
KEYTIMEOUT=1
bindkey -v # vim keybinding
bindkey "^[[3~" delete-char # nastavi aby pri stlaceni delete nerobilo ~

bindkey -s '^[x' 'ticker^M'
bindkey -s '^[z' '$SCRIPTS_DIR./ticker.sh btc-usd eth-usd lha.de alv.de bayn.de bas.de xiacf spce pltr sofi b4b.de ibm intc msft amd t vz ibe1.de meta pypl u qs cat tte.pa lin.de swk vfc phi1.de mmm^M'
bindkey -s '^[m' 'musikcube^M'
bindkey -s '^[v' 'cava^M'

#############
# STARSHIP
#############

# case $isWSL in
#     1)
# zistim nazov distribucie
# _distro=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
#
# # oznaci ikonu na zaklade distribucie
# case $_distro in
#     *kali*)                  ICON="ﴣ" ;;
#     *arch*)                  ICON="" ;;
#     *debian*)                ICON="" ;;
#     *raspbian*)              ICON="" ;;
#     *ubuntu*)                ICON="" ;;
#     *elementary*)            ICON="" ;;
#     *fedora*)                ICON="" ;;
#     *coreos*)                ICON="" ;;
#     *gentoo*)                ICON="" ;;
#     *mageia*)                ICON="" ;;
#     *centos*)                ICON="" ;;
#     # *opensuse*)              ICON="" ;;
#     *opensuse*|*tumbleweed*) ICON="" ;;
#     *sabayon*)               ICON="" ;;
#     *slackware*)             ICON="" ;;
#     *linuxmint*)             ICON="" ;;
#     *alpine*)                ICON="" ;;
#     *aosc*)                  ICON="" ;;
#     *nixos*)                 ICON="" ;;
#     *devuan*)                ICON="" ;;
#     *manjaro*)               ICON="" ;;
#     *rhel*)                  ICON="" ;;
#     *)                       ICON="" ;;
# esac
#
# export STARSHIP_DISTRO="$ICON  "
# ;;
# esac

# potrebne pre spustenie Starshipu
eval "$(starship init zsh)"
