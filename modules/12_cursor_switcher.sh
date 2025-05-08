#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.dotfiles/modules/_log.sh"
[ -f "$HOME/.dotfiles/system-profile.sh" ] && source "$HOME/.dotfiles/system-profile.sh"

CURSOR_ARCHIVES="$HOME/.dotfiles/cursors"
ICON_DIR="$HOME/.local/share/icons"
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

mkdir -p "$ICON_DIR"

mapfile -t CURSORS < <(find "$CURSOR_ARCHIVES" -name "*.tar.xz" -exec basename {} .tar.xz \;)

echo "🖱️ Available cursor themes:"
for i in "${!CURSORS[@]}"; do
    echo "[$((i+1))] ${CURSORS[$i]}"
done

read -rp "Choose: " choice
SELECTED="${CURSORS[$((choice-1))]}"
ARCHIVE="$CURSOR_ARCHIVES/$SELECTED.tar.xz"
DEST="$ICON_DIR/$SELECTED"

# Cursor size logic
SIZE="${CURSOR_SIZE:-34}"
read -rp "Enter desired cursor size (default $SIZE): " CURSOR_SIZE_INPUT
CURSOR_SIZE="${CURSOR_SIZE_INPUT:-$SIZE}"

[ -f "$ARCHIVE" ] || fatal "Missing archive: $ARCHIVE"

# Extract
if [ ! -d "$DEST" ]; then
    tar -xf "$ARCHIVE" -C "$ICON_DIR"
    log "✅ Extracted $SELECTED"
fi

# Update Hypr config
sudo sed -i '/env = XCURSOR_THEME/d' "$HYPR_CONF"
sudo sed -i '/env = XCURSOR_SIZE/d' "$HYPR_CONF"

echo "env = XCURSOR_THEME,$SELECTED" | sudo tee -a "$HYPR_CONF" > /dev/null
echo "env = XCURSOR_SIZE,$CURSOR_SIZE" | sudo tee -a "$HYPR_CONF" > /dev/null

# Reload Hyprland if running
if command -v hyprctl >/dev/null; then
    hyprctl reload >/dev/null && log "🔁 Hyprland reloaded"
fi

log "✅ Cursor '$SELECTED' applied with size $CURSOR_SIZE"
