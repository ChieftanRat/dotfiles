#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.dotfiles/modules/_log.sh"

REPO="https://github.com/rose-pine/waybar"
TEMP_DIR=$(mktemp -d)
WAYBAR_CONFIG="$HOME/.config/waybar"
STYLE_FILE="$WAYBAR_CONFIG/style.css"

mkdir -p "$WAYBAR_CONFIG"

log "📥 Cloning Rosé Pine Waybar theme..."
git clone --depth=1 "$REPO" "$TEMP_DIR"

cp "$TEMP_DIR"/*.css "$WAYBAR_CONFIG/"
rm -rf "$TEMP_DIR"

mapfile -t THEMES < <(ls "$WAYBAR_CONFIG"/rose-pine-*.css 2>/dev/null | xargs -n1 basename)

echo "🎨 Select Rosé Pine variant:"
for i in "${!THEMES[@]}"; do
    echo "[$((i+1))] ${THEMES[$i]}"
done

read -rp "Choose a theme [1-${#THEMES[@]}]: " choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#THEMES[@]}" ]; then
    echo "❌ Invalid selection."
    exit 1
fi

selected="${THEMES[$((choice-1))]}"

# Ensure style.css exists
touch "$STYLE_FILE"

# Remove previous @import
sed -i '/@import ".\/rose-pine-.*.css";/d' "$STYLE_FILE" 2>/dev/null || true

# Prepend new import
echo "@import \"./$selected\";" | cat - "$STYLE_FILE" > "$STYLE_FILE.tmp" && mv "$STYLE_FILE.tmp" "$STYLE_FILE"

echo "✅ Rosé Pine Waybar theme '$selected' applied and imported in style.css."

log "✅ Waybar theme '$selected' applied"
