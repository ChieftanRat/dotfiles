#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.dotfiles/modules/_log.sh"

THEME_LIST="$HOME/.dotfiles/themes.txt"
SDDM_CONF="/etc/sddm.conf"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

[ -f "$THEME_LIST" ] || fatal "Missing theme list: $THEME_LIST"
[ -f "$SDDM_CONF" ] || fatal "Missing config: $SDDM_CONF"

current=$(grep '^Current=' "$SDDM_CONF" | cut -d'=' -f2 || echo "none")
log "🎨 Current SDDM theme: $current"

mapfile -t THEMES < <(awk '{print $1}' "$THEME_LIST")

echo "🎭 Available SDDM themes:"
for i in "${!THEMES[@]}"; do
    echo "[$((i+1))] ${THEMES[$i]}"
done

read -rp "Select a theme: " choice
[[ "$choice" =~ ^[0-9]+$ ]] || fatal "Invalid selection"

selected="${THEMES[$((choice-1))]}"

if $DRY_RUN; then
    log "[DRY RUN] Would activate SDDM theme: $selected"
    exit 0
fi

# Remove existing theme
sudo sed -i '/^Current=/d' "$SDDM_CONF"

# Ensure section exists
grep -q "^\[Theme\]" "$SDDM_CONF" || echo "[Theme]" | sudo tee -a "$SDDM_CONF" > /dev/null

# Add new theme
echo "Current=$selected" | sudo tee -a "$SDDM_CONF" > /dev/null

log "✅ SDDM theme '$selected' activated."
