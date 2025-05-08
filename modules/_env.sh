#!/usr/bin/env bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Terminal session type
export IS_WAYLAND=$(env | grep -q WAYLAND_DISPLAY && echo true || echo false)
export IS_X11=$(env | grep -q DISPLAY && echo true || echo false)

# --- Shell type
current_shell=$(ps -p $$ -o comm=)
export IS_FISH=$(echo "$current_shell" | grep -q fish && echo true || echo false)
export IS_BASH=$(echo "$current_shell" | grep -q bash && echo true || echo false)

# --- Package manager
command -v yay >/dev/null && export HAS_YAY=true || export HAS_YAY=false
command -v paru >/dev/null && export HAS_PARU=true || export HAS_PARU=false
command -v pacman >/dev/null && export HAS_PACMAN=true || export HAS_PACMAN=false

# --- Flatpak support
command -v flatpak >/dev/null && export HAS_FLATPAK=true || export HAS_FLATPAK=false
