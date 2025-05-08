#!/usr/bin/env bash
set -euo pipefail

THEME_LIST="$HOME/.dotfiles/themes.txt"
FONT_DIR="/usr/share/fonts"
DRY_RUN=false

# Support --dry-run flag
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Check if theme list exists
if [[ ! -f "$THEME_LIST" ]]; then
    echo "[❌ ERROR] Theme list not found: $THEME_LIST"
    exit 1
fi

while read -r name repo; do
    set_theme=0
    THEME_DIR="/usr/share/sddm/themes/$name"

    echo "[📦 INFO] Processing theme: $name"
    echo "[🌐 INFO] Repo: $repo"

    if [[ ! -d "$THEME_DIR" ]]; then
        echo "[📁 INFO] Installing $name..."
        $DRY_RUN || sudo git clone "$repo" "$THEME_DIR"

        if [[ -d "$THEME_DIR/Fonts" ]]; then
            echo "[🔤 INFO] Copying fonts..."
            $DRY_RUN || sudo cp "$THEME_DIR/Fonts/"* "$FONT_DIR/" || echo "[⚠️ WARN] Font copy failed."
        fi

        set_theme=1
    else
        echo "[✅ INFO] $name already installed."
    fi

    # Check if the theme is active, otherwise activate it
    if ! grep -q "Current=$name" /etc/sddm.conf 2>/dev/null || [[ "$set_theme" -eq 1 ]]; then
        echo "[🎨 INFO] Activating theme: $name"
        if ! $DRY_RUN; then
            echo -e "[Theme]\nCurrent=$name" | sudo tee /etc/sddm.conf > /dev/null
        else
            echo "[DRY RUN] Would set Current=$name in /etc/sddm.conf"
        fi
    else
        echo "[👌 INFO] $name is already the active theme."
    fi
done < "$THEME_LIST"
