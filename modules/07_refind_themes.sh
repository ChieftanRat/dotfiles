#!/usr/bin/env bash

set -euo pipefail

THEME_LIST="$HOME/.dotfiles/refind-themes.txt"
REFIND_DIR="/boot/EFI/refind"
THEMES_DIR="$REFIND_DIR/themes"
REFIND_CONF="$REFIND_DIR/refind.conf"

# Ensure theme directory exists
sudo mkdir -p "$THEMES_DIR"

# Read and process theme list
while read -r theme repo conf_path; do
    local_dir="$THEMES_DIR/$theme"

    echo "[INFO] Processing rEFInd theme: $theme"

    if [ ! -d "$local_dir" ]; then
        echo "[INFO] Cloning $theme..."
        tmp_dir=$(mktemp -d)
        git clone "$repo" "$tmp_dir"
        sudo cp -r "$tmp_dir" "$local_dir"
        rm -rf "$tmp_dir"
    else
        echo "[INFO] Theme already exists: $local_dir"
    fi

    # Ensure include line is present
    include_line="include $conf_path"
    if ! grep -Fxq "$include_line" "$REFIND_CONF"; then
        echo "[INFO] Adding theme include to refind.conf"
        echo "$include_line" | sudo tee -a "$REFIND_CONF" > /dev/null
    else
        echo "[INFO] Theme already included in refind.conf"
    fi

done < "$THEME_LIST"
