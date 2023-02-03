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

# # Ranger - otvori shell tam kde vypnem rangera
# function ranger {
#     local IFS=$'\t\n'
#     local tempfile="$(mktemp -t tmp.XXXXXX)"
#     local ranger_cmd=(
#         command
#         ranger
#         --cmd="map Q chain shell echo %d > "$tempfile"; quitall"
#     )
#
#     ${ranger_cmd[@]} "$@"
#     if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
#         cd -- "$(cat "$tempfile")" || return
#     fi
#     command rm -f -- "$tempfile" 2>/dev/null
# }

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
# export PGDATA='/usr/local/pgsql/data'

#############
# VARIABLES
#############

OneDrive_DIR=$HOME/OneDrive/
SCRIPTS_DIR=$HOME/OneDrive/Linux/Skripty/

#############
# ALIASES
#############

alias zypup='sudo zypper dup'
alias zypin='sudo zypper install'
alias zyprm='sudo zypper remove -u'
alias zypse='zypper search'
alias zypinfo='zypper info'
alias zypre='sudo zypper refresh'
# alias pipup='pip3 list --outdated --format=freeze | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 pip3 install -U'
alias pipup='pip3 list -o | cut -f1 -d" " | tr " " "\n" | awk "{if(NR>=3)print}" | cut -d" " -f1 | xargs -n1 pip3 install -U'
alias zsh-update-plugins="find "$ZDOTDIR" -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull -q"
alias backup='$HOME/OneDrive/Linux/Qtile/./qtile-backup.sh'

alias vb='nvim $HOME/.bashrc'
alias vz='nvim $ZDOTDIR/.zshrc'
alias vq='nvim $HOME/.config/qtile/config.py'
alias vs='nvim $HOME/.config/starship.toml'

alias gh='cd $HOME/'
alias gp='cd $HOME/Python/'
alias web='cd $OneDrive_DIR/00-website/02-web-epd/ && nvim index.html'

alias f='ranger-cd'
alias ex='exit'
alias fd='fd -Hi'
alias ls='exa -la --icons'
alias rec='$SCRIPTS_DIR./stream_record_linux.sh'
alias stv='mpv "$HOME/OneDrive/Linux/IPTV/sk-cz.m3u"'
alias ptv='mpv "$HOME/OneDrive/Linux/IPTV/xxx.m3u"'
alias yf='$SCRIPTS_DIR./ticker.sh'
alias yfm='$SCRIPTS_DIR./ticker.sh btc-usd eth-usd lha.de alv.de bayn.de bas.de xiacf spce pltr sofi b4b.de ibm intc msft amd t vz ibe1.de meta pypl u qs cat tte.pa lin.de swk'
alias yafin='source $HOME/Python/yafin/yafin-venv/bin/activate && python3 $SCRIPTS_DIR/yafin.py'
alias math='cd $HOME/Python/jupyter/ && source jupyter-venv/bin/activate && jupyter-lab'
alias epd='cd $HOME/OneDrive/00-website/01-python/ && source $HOME/Python/epd/epd-venv/bin/activate'
alias dea='deactivate'
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

bindkey -s '^[f' 'ranger^M'
bindkey -s '^[x' 'ticker^M'
bindkey -s '^[z' '$SCRIPTS_DIR./ticker.sh btc-usd eth-usd lha.de alv.de bayn.de bas.de xiacf spce pltr sofi b4b.de ibm intc msft amd t vz ibe1.de meta pypl u qs cat tte.pa lin.de swk^M'

#############
# STARSHIP
#############

eval "$(starship init zsh)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/vimi/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/vimi/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/vimi/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/vimi/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

