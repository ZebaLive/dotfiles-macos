# Aerospace + SketchyBar + Borders + Alfred

Hey there! This is my personal MacOS configuration files focused on creating a minimal, functional, and aesthetically pleasing development environment for both work and personal projects.

As a previous linux/hyprland user I've been trying to get the best of both worlds and create a setup that feels natural and easy to use, as of today the best option for this is using Aerospace + Borders + SketchyBar.

## Features

- **Window Management**: Using [Aerospace](https://github.com/nikitabobko/aerospace) for tiling window management, with a focus on simplicity and ease of use. Different from other MacOS Apps, it doesn't use the builtin OS workspace system, it handles everything in the same OS workspace, allowing you to change between workareas without having to disabling core system protections.
- **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/) configured for optimal development experience
- **Status Bar**: Custom [SketchyBar](https://github.com/FelixKratz/SketchyBar) configuration using Lua, already integrated with Aerospace for dynamically loading workspaces and listen for events.
- **System Borders**: Enhanced window borders using [JankyBorders](https://github.com/FelixKratz/JankyBorders)
- **Additional Tools**:
  - Alfred for app launching and workflows
  - Starship for shell customization
  - Neovim as the primary terminal text editor
  - Karabiner-Elements for keyboard customization
  - Various CLI utilities (zoxide, eza, fzf, btop, thefuck, etc.)

## Quick Start

Run the main setup script to install all dependencies:

```bash
./setup.sh
```
