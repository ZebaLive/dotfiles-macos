#!/bin/bash

# macOS Zsh Setup Script
# Installs oh-my-zsh and configures minimal tools:
# asdf, direnv, mise, zsh-autosuggestions, fast-syntax-highlighting, eza, starship, zoxide, thefuck

set -e

echo "🚀 Starting macOS Zsh Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only."
    exit 1
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_status "Homebrew installed"
else
    print_status "Homebrew already installed"
fi

# Install Oh My Zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "📦 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_status "Oh My Zsh installed"
else
    print_status "Oh My Zsh already installed"
fi

# Install tools via Homebrew
echo "📦 Installing tools via Homebrew..."

BREW_PACKAGES=(
    asdf        # Version manager
    direnv      # Directory-specific environment variables
    mise        # Polyglot runtime manager
    eza         # Modern ls replacement
    starship    # Cross-shell prompt
    zoxide      # Smarter cd command
    thefuck     # Command correction
    fzf         # Fuzzy finder (useful companion)
    fd          # Better find (useful with fzf)
    bat         # Better cat
)

for package in "${BREW_PACKAGES[@]}"; do
    if brew list "$package" &> /dev/null; then
        print_status "$package already installed"
    else
        echo "  Installing $package..."
        brew install "$package"
        print_status "$package installed"
    fi
done

# Install Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    echo "📦 Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_status "zsh-autosuggestions installed"
else
    print_status "zsh-autosuggestions already installed"
fi

# fast-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]]; then
    echo "📦 Installing fast-syntax-highlighting..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
    print_status "fast-syntax-highlighting installed"
else
    print_status "fast-syntax-highlighting already installed"
fi

# Install fzf key bindings and completion
if [[ ! -f "$HOME/.fzf.zsh" ]]; then
    echo "📦 Setting up fzf..."
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
    print_status "fzf configured"
else
    print_status "fzf already configured"
fi

# Backup existing .zshrc if it exists
if [[ -f "$HOME/.zshrc" ]]; then
    BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.zshrc" "$BACKUP_FILE"
    print_warning "Existing .zshrc backed up to $BACKUP_FILE"
fi

# Create minimal .zshrc
echo "📝 Creating .zshrc configuration..."

cat > "$HOME/.zshrc" << 'EOF'
# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Disable Homebrew hints
export HOMEBREW_NO_ENV_HINTS=1

# Zoxide configuration - override cd command
export ZOXIDE_CMD_OVERRIDE="cd"

# --- SSH Agent Plugin Configuration ---
# Lazy loading: don't add keys until first use
zstyle :omz:plugins:ssh-agent lazy yes
# macOS keychain integration for SSH passphrases
zstyle :omz:plugins:ssh-agent ssh-add-args --apple-load-keychain

# --- eza plugin configuration ---
zstyle ':omz:plugins:eza' 'icons' yes

# GPG signing configuration
export GPG_TTY=$(tty)

# Oh My Zsh plugins
# Note: asdf, direnv, mise are version/env managers
#       fzf for fuzzy finding, eza for better ls
#       starship for prompt, zoxide for smart cd
#       thefuck for command correction, ssh-agent for SSH keys
plugins=(
    git
    asdf
    direnv
    mise
    fzf
    docker 
    colored-man-pages
    zsh-autosuggestions
    fast-syntax-highlighting
    eza
    starship
    zoxide
    thefuck
    ssh-agent
)

source $ZSH/oh-my-zsh.sh

# ----- fzf Configuration -----
# Use fd instead of find for fzf
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# fzf path completion with fd
_fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}

# fzf directory completion with fd
_fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
}

# Preview configuration for fzf
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced fzf customization
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

# Source fzf if installed
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
EOF

print_status ".zshrc created"

# Create starship config directory and minimal config
mkdir -p "$HOME/.config"
if [[ ! -f "$HOME/.config/starship.toml" ]]; then
    echo "📝 Creating minimal Starship configuration..."
    cat > "$HOME/.config/starship.toml" << 'EOF'
# Minimal Starship configuration
# See https://starship.rs/config/ for more options

# Reduce prompt delay
command_timeout = 500

# Minimal prompt format
format = """
$directory\
$git_branch\
$git_status\
$character"""

[character]
success_symbol = "[❯](green)"
error_symbol = "[❯](red)"

[directory]
truncation_length = 3
truncate_to_repo = true

[git_branch]
format = "[$branch]($style) "
style = "purple"

[git_status]
format = '([$all_status$ahead_behind]($style) )'
style = "yellow"
EOF
    print_status "Starship configuration created"
else
    print_status "Starship configuration already exists"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Installed tools:"
echo "  • Oh My Zsh      - Zsh framework"
echo "  • asdf           - Version manager for multiple languages"
echo "  • direnv         - Directory-specific environment variables"
echo "  • mise           - Polyglot runtime manager"
echo "  • eza            - Modern ls replacement"
echo "  • starship       - Cross-shell prompt"
echo "  • zoxide         - Smarter cd command"
echo "  • thefuck        - Command correction"
echo "  • fzf + fd + bat - Fuzzy finder and companions"
echo "  • zsh-autosuggestions"
echo "  • fast-syntax-highlighting"
echo ""
echo "To apply changes, run:"
echo -e "  ${YELLOW}source ~/.zshrc${NC}"
echo ""
echo "Or restart your terminal."
echo ""
