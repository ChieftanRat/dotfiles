#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.dotfiles/modules/_log.sh"

THEME_LIST="$HOME/.dotfiles/refind-themes.txt"
REFIND_CONF="/boot/EFI/refind/refind.conf"
REFIND_THEME_DIR="/boot/EFI/refind/themes"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

[ -f "$THEME_LIST" ] || fatal "Missing theme list: $THEME_LIST"
[ -f "$REFIND_CONF" ] || fatal "Missing config: $REFIND_CONF"

current=$(grep '^include ' "$REFIND_CONF" | awk -F '/' '{print $2}' || echo "none")
log "🧙 Current rEFInd theme: $current"

mapfile -t THEMES < <(awk '{print $1}' "$THEME_LIST")

echo "Available rEFInd themes:"
for i in "${!THEMES[@]}"; do
    echo "[$((i+1))] ${THEMES[$i]}"
done

read -rp "Select a theme: " choice
[[ "$choice" =~ ^[0-9]+$ ]] || fatal "Invalid selection"

selected="${THEMES[$((choice-1))]}"
conf_path=$(awk -v theme="$selected" '$1 == theme {print $3}' "$THEME_LIST")

if $DRY_RUN; then
    log "[DRY RUN] Would switch to: $selected"
    log "[DRY RUN] Would update include to: $conf_path"
    exit 0
fi

sudo sed -i '/^include /d' "$REFIND_CONF"
echo "include $conf_path" | sudo tee -a "$REFIND_CONF" > /dev/null

log "✅ rEFInd theme '$selected' activated."
