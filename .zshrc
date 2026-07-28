
export ZSH="$HOME/.oh-my-zsh"

export HOMEBREW_NO_ENV_HINTS=1

export PATH="/opt/homebrew/bin:$PATH"

# Disable zoxide doctor warning (VS Code/Claude shell integration adds hooks
# after .zshrc, triggering a false positive)
export _ZO_DOCTOR=0

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
plugins=(
    git
    direnv
    docker 
    colored-man-pages 
    zsh-autosuggestions 
    fast-syntax-highlighting
    eza 
)

source $ZSH/oh-my-zsh.sh

# Custom paths (must be AFTER oh-my-zsh to override any plugin PATH modifications)
export PATH="/opt/homebrew/opt/openssh/bin:$PATH"
# Brew python unversioned symlinks (python, pip) — used by asdf 'system' fallback
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# mise second — prepends its shims so they take priority over asdf
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vim=nvim

# thefuck alias
if command -v thefuck &> /dev/null; then
    eval $(thefuck --alias)
fi

# ===== FZF CONFIGURATION =====
# Set up fzf key bindings and fuzzy completion
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# Use fd instead of fzf default
if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
    
    # Use fd for path and directory completion
    _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
    }
    
    _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
    }
fi

# FZF preview settings
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
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

# Load fzf-git if available
if [ -f ~/.fzf-git.sh/fzf-git.sh ]; then
    source ~/.fzf-git.sh/fzf-git.sh
fi

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

autoload -Uz compinit
compinit
# End of Docker CLI completions

# ===== LOAD CUSTOM CONFIGURATIONS FROM zshrc.d =====
if [ -d ~/.config/zshrc.d ]; then
    for file in ~/.config/zshrc.d/*.{sh,zsh}; do
        [ -f "$file" ] && source "$file"
    done
fi

# ===== STARSHIP PROMPT =====
# Initialize starship (this should be near the end)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# ===== ZOXIDE (better cd) — must be last =====
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init --cmd cd zsh)"
fi

