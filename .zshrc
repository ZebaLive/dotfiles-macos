
export ZSH="$HOME/.oh-my-zsh"

export PATH="$HOME/.local/bin:$PATH"

export HOMEBREW_NO_ENV_HINTS=1

export ZOXIDE_CMD_OVERRIDE="cd"

# --- SSH Agent Plugin Configuration ---
# Lazy loading: don't add keys until first use
zstyle :omz:plugins:ssh-agent lazy yes

# macOS keychain integration for SSH passphrases
zstyle :omz:plugins:ssh-agent ssh-add-args --apple-load-keychain

# --- setup fzf theme (Catppuccin Mocha) ---
fg="#CDD6F4"
bg="#1E1E2E"
bg_highlight="#313244"
purple="#CBA6F7"
blue="#89B4FA"
cyan="#89DCEB"
green="#A6E3A1"
orange="#FAB387"
red="#F38BA8"
yellow="#F9E2AF"

export FZF_DEFAULT_OPTS="--color=bg+:${bg_highlight},bg:${bg},spinner:${green},hl:${red},fg:${fg},header:${blue},info:${purple},pointer:${green},marker:${green},fg+:${fg},prompt:${purple},hl+:${red}"

zstyle ':omz:plugins:eza' 'icons' yes

# GPG signing configuration
export GPG_TTY=$(tty)

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="agnoster"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git asdf direnv fzf docker colored-man-pages zsh-autosuggestions fast-syntax-highlighting eza starship zoxide thefuck ssh-agent)

source $ZSH/oh-my-zsh.sh

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vim=nvim

# Container engine configuration - change to "docker" if needed
CONTAINER_ENGINE="docker"

function container_php {
    result=${PWD##*/}
    GO="cd $result && php ${@}"
    if [ "$result" = "team.arcapay.com" ]; then
        if [ -n "$(${CONTAINER_ENGINE} ps -f "name=local-php82" -f "status=running" -q )" ]; then
            ${CONTAINER_ENGINE} exec -it --user developer local-php82 bash -c "$GO"
        else
            echo "No running container found for php82"
        fi
    else
        if [ -n "$(${CONTAINER_ENGINE} ps -f "name=local-php83" -f "status=running" -q )" ]; then
            ${CONTAINER_ENGINE} exec -it --user developer local-php83 bash -c "$GO"
        else
            echo "No running container found for php83"
        fi
    fi
    return $?
}

function container_cake {
    result=${PWD##*/}
    GO="cd $result && php ./bin/cake.php ${@}"
    if [ "$result" = "team.arcapay.com" ]; then
        if [ -n "$(${CONTAINER_ENGINE} ps -f "name=local-php82" -f "status=running" -q )" ]; then
            ${CONTAINER_ENGINE} exec -it --user developer local-php82 bash -c "$GO"
        else
            echo "No running container found for php82"
        fi
    else
        if [ -n "$(${CONTAINER_ENGINE} ps -f "name=local-php83" -f "status=running" -q )" ]; then
            ${CONTAINER_ENGINE} exec -it --user developer local-php83 bash -c "$GO"
        else
            echo "No running container found for php83"
        fi
    fi
    return $?
}

function container_exec {
    result=${PWD##*/}
    GO="cd $result && ${@}"
    if [ "$result" = "team.arcapay.com" ]; then
        if [ -n "$(${CONTAINER_ENGINE} ps -f "name=local-php82" -f "status=running" -q )" ]; then
            ${CONTAINER_ENGINE} exec -it --user developer local-php82 bash -c "$GO"
        else
            echo "No running container found for php82"
        fi
    else
        if [ -n "$(${CONTAINER_ENGINE} ps -f "name=local-php83" -f "status=running" -q )" ]; then
            ${CONTAINER_ENGINE} exec -it --user developer local-php83 bash -c "$GO"
        else
            echo "No running container found for php83"
        fi
    fi
    return $?
}

function container_composer {
    result=${PWD##*/}
    GO="cd $result && php composer.phar ${@}"
    SSH_START='eval $(ssh-agent -s);'
    SSH_ADD="ssh-add ${DOCKER_SSH_KEY_LOCATION:-/home/developer/.ssh/bitbucket};"
    if [ "$result" = "team.arcapay.com" ]; then
        if [ -n "$(${CONTAINER_ENGINE} ps -f "name=local-php82" -f "status=running" -q )" ]; then
            ${CONTAINER_ENGINE} exec -it --user developer local-php82 bash -c "$SSH_START $SSH_ADD $GO"
        else
            echo "No running container found for php82"
        fi
    else
        if [ -n "$(${CONTAINER_ENGINE} ps -f "name=local-php83" -f "status=running" -q )" ]; then
            echo "running container found for php83"
            ${CONTAINER_ENGINE} exec -it --user developer local-php83 bash -c "$SSH_START $SSH_ADD $GO"
        else
            echo "No running container found for php83"
        fi
    fi
    return $?
}

alias php=container_php
alias docx=container_exec
alias cake=container_cake
alias composer=container_composer

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# -- Use fd instead of fzf --
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir(){ 
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/.fzf-git.sh/fzf-git.sh

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ----- Bat (better cat) -----
alias cat='bat --paging=never'

# Remap fzf directory navigation from Alt+C to Ctrl+G
bindkey '^g' fzf-cd-widget

# history setup
#HISTFILE=$HOME/.zhistory
#SAVEHIST=1000
#HISTSIZE=999
#setopt share_history
#setopt hist_expire_dups_first
#setopt hist_ignore_dups
#setopt hist_verify

# completion using arrow keys (based on history)
#bindkey '^[[A' history-search-backward
#bindkey '^[[B' history-search-forward

#export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/paulius/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
