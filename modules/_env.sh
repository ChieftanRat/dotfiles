#!/usr/bin/env bash

# ---------------------------
# Color codes
# ---------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ---------------------------
# Terminal Session Type
# ---------------------------
export IS_WAYLAND=$(env | grep -q WAYLAND_DISPLAY && echo true || echo false)
export IS_X11=$(env | grep -q DISPLAY && echo true || echo false)

# ---------------------------
# Shell Type
# ---------------------------
current_shell=$(ps -p $$ -o comm=)
export IS_FISH=$(echo "$current_shell" | grep -q fish && echo true || echo false)
export IS_BASH=$(echo "$current_shell" | grep -q bash && echo true || echo false)

# ---------------------------
# Optional Tools Detection
# ---------------------------

# --- Flatpak support
command -v flatpak >/dev/null && export HAS_FLATPAK=true || export HAS_FLATPAK=false

# --- AppImage support
command -v appimaged >/dev/null && export HAS_APPIMAGE=true || export HAS_APPIMAGE=false

# --- zoxide support
command -v zoxide >/dev/null && export HAS_ZOXIDE=true || export HAS_ZOXIDE=false

# --- neovim support
command -v nvim >/dev/null && export HAS_NVIM=true || export HAS_NVIM=false

#  --- Arch based systems support (yay / paru / pacman)
command -v yay >/dev/null && export HAS_YAY=true || export HAS_YAY=false
command -v paru >/dev/null && export HAS_PARU=true || export HAS_PARU=false
command -v pacman >/dev/null && export HAS_PACMAN=true || export HAS_PACMAN=false

# Optional UI tools
command -v xdg-open &>/dev/null && export HAS_XDG_OPEN=true || export HAS_XDG_OPEN=false
command -v swww &>/dev/null && export HAS_SWWW=true || export HAS_SWWW=false
command -v hyprctrl &>/dev/null && export HAS_HYPRCTRL=true || export HAS_HYPRCTRL=false



