#!/bin/bash

echo "Installing Dependencies"

# Install xCode cli tools
echo "Installing commandline tools..."
xcode-select --install

# Essentials
brew install lua
brew tap FelixKratz/formulae
brew install sketchybar
brew install --cask kitty
brew tap FelixKratz/formulae
brew install borders
brew install --cask nikitabobko/tap/aerospace
brew install --cask karabiner-elements
brew install wget
brew install jq
brew install fzf
brew install stow

# Nice to have
brew install --cask alfred
brew install --cask nordpass
brew install --cask btop
brew install switchaudio-osx
brew install nowplaying-cli
brew install thefuck
brew install htop

# Terminal
brew install neovim
brew install zoxide
brew install eza
brew install starship
brew install fastfetch

# Fonts
brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro
brew install --cask font-fira-code-nerd-font

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.25/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

# SbarLua
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

# Start Services
echo "Starting Services (grant permissions)..."
brew services start sketchybar
brew services start borders