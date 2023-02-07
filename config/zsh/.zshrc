# Lines configured by zsh-newuser-install
HISTFILE=$ZDOTDIR/zsh_history
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '$ZDOTDIR/.zshrc'

autoload -Uz compinit
compinit
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
    export PGDATA='/usr/local/pgsql/data'

    # Variables
    OneDrive_DIR=/mnt/c/Users/$WIN_USERNAME/OneDrive/
    SCRIPTS_DIR=/mnt/c/Users/$WIN_USERNAME/OneDrive/Linux/Skripty/
    ;;
  2)
    # Variables
    OneDrive_DIR=$HOME/OneDrive/
    SCRIPTS_DIR=$HOME/OneDrive/Linux/Skripty/
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

# Ranger - otvori shell tam kde vypnem rangera
ranger-cd() {
    temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
    ranger --choosedir="$temp_file" -- "${@:-$PWD}"
    if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
        cd -- "$chosen_dir"
    fi
    rm -f -- "$temp_file"
}

#############
# Environment variables
#############
export EDITOR="nvim"
export VISUAL="nvim"
export RANGER_LOAD_DEFAULT_RC=false

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

alias vb='nvim $HOME/.bashrc'
alias vz='nvim $ZDOTDIR/.zshrc'
alias vq='nvim $HOME/.config/qtile/config.py'
alias vs='nvim $HOME/.config/starship.toml'

alias f='ranger-cd'
alias ex='exit'
alias fd='fd -Hi'
alias ls='exa -la --icons'

# alias gh='cd $HOME/'
alias gp='cd $HOME/Python/'
alias web='cd $OneDrive_DIR/00-website/00-design/02-web-epd/ && nvim index.html'
alias math='cd $HOME/Python/jupyter/ && source jupyter-venv/bin/activate && jupyter-lab'
alias epd='source $HOME/Python/epd/epd-venv/bin/activate && cd $OneDrive_DIR/00-website/01-python/'
alias yafin='source $HOME/Python/yafin/yafin-venv/bin/activate && python3 $SCRIPTS_DIR/yafin.py'
alias dea='deactivate'

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
    # alias ulozto='ulozto-downloader --parts 50 --parts-progress --auto-captcha --output "/mnt/c/Users/$WIN_USERNAME/Downloads/"'
    alias backup='$HOME/OneDrive/Linux/Qtile/./qtile-backup.sh'
    ;;
esac
alias rec='$SCRIPTS_DIR./stream_record_linux.sh'

alias salome='$HOME/salome-meca/./salome_meca-lgpl-2021.0.0-2-20211014-scibian-9'
alias freecad='$HOME/Applications/FreeCAD_0.20-1-2022-08-20-conda-Linux-x86_64-py310_b6b0ddf25121b8cf8cc18f02e81151b7.AppImage'
alias pg='sudo -i -u postgres'

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

case $isWSL in
  1)
    # zistim nazov distribucie
    _distro=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')

    # oznaci ikonu na zaklade distribucie
    case $_distro in
        *kali*)                  ICON="ﴣ";;
        *arch*)                  ICON="";;
        *debian*)                ICON="";;
        *raspbian*)              ICON="";;
        *ubuntu*)                ICON="";;
        *elementary*)            ICON="";;
        *fedora*)                ICON="";;
        *coreos*)                ICON="";;
        *gentoo*)                ICON="";;
        *mageia*)                ICON="";;
        *centos*)                ICON="";;
     #   *opensuse*)              ICON="";;
        *opensuse*|*tumbleweed*) ICON="﮼";;
        *sabayon*)               ICON="";;
        *slackware*)             ICON="";;
        *linuxmint*)             ICON="";;
        *alpine*)                ICON="";;
        *aosc*)                  ICON="";;
        *nixos*)                 ICON="";;
        *devuan*)                ICON="";;
        *manjaro*)               ICON="";;
        *rhel*)                  ICON="";;
        *)                       ICON="";;
    esac

    export STARSHIP_DISTRO="$ICON  "
    ;;
esac

# potrebne pre spustenie Starshipu
eval "$(starship init zsh)"
