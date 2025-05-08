#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.dotfiles/modules/_log.sh"
[ -f "$HOME/.dotfiles/system-profile.sh" ] && source "$HOME/.dotfiles/system-profile.sh"

WALLPAPER_DIR="$HOME/.dotfiles/wallpapers"


# Detect current themes
SDDM_THEME=$(grep '^Current=' /etc/sddm.conf | cut -d'=' -f2 || echo "unknown")
REFIND_THEME=$(grep '^include ' /boot/EFI/refind/refind.conf | awk -F '/' '{print $2}' || echo "unknown")

SDDM_DIR="/usr/share/sddm/themes/$SDDM_THEME"
REFIND_DIR="/boot/EFI/refind/themes/$REFIND_THEME"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

[ -d "$WALLPAPER_DIR" ] || fatal "Wallpaper directory missing: $WALLPAPER_DIR"

# Collect wallpapers
mapfile -t WALLS < <(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \))

# Prompt which system to update
echo "🖼️ Set wallpaper for which loader:"
echo "1) SDDM (current: $SDDM_THEME)"
echo "2) rEFInd (current: $REFIND_THEME)"
read -rp "Choose [1-2]: " target

# List available wallpapers
echo ""
echo "📂 Available wallpapers:"
for i in "${!WALLS[@]}"; do
    echo "[$((i+1))] $(basename "${WALLS[$i]}")"
done

# Default from profile
DEFAULT_WALL="${WALLPAPER_NAME:-}"
if [[ -n "$DEFAULT_WALL" ]]; then
    for i in "${!WALLS[@]}"; do
        if [[ "$(basename "${WALLS[$i]}")" == "$DEFAULT_WALL" ]]; then
            default_index=$((i+1))
            break
        fi
    done
    echo ""
    read -rp "Select wallpaper [default: $default_index]: " wp_choice
    wp_choice="${wp_choice:-$default_index}"
else
    echo ""
    read -rp "Select wallpaper: " wp_choice
fi

selected="${WALLS[$((wp_choice-1))]}"

# Apply wallpaper
if [[ "$target" == "1" ]]; then
    [ -d "$SDDM_DIR" ] || fatal "Missing theme path: $SDDM_DIR"
    if $DRY_RUN; then
        log "[DRY RUN] Would set $selected as SDDM wallpaper"
    else
        sudo cp "$selected" "$SDDM_DIR/background.jpg"
        log "✅ SDDM wallpaper set"
    fi
elif [[ "$target" == "2" ]]; then
    [ -d "$REFIND_DIR" ] || fatal "Missing theme path: $REFIND_DIR"
    if $DRY_RUN; then
        log "[DRY RUN] Would set $selected as rEFInd wallpaper"
    else
        sudo cp "$selected" "$REFIND_DIR/background.png"
        log "✅ rEFInd wallpaper set"
    fi
else
    fatal "Invalid wallpaper target selected."
fi
