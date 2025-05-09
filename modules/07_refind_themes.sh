#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.dotfiles/modules/_log.sh"

THEME_LIST="$HOME/.dotfiles/refind-themes.txt"
REFIND_DIR="/boot/EFI/refind"
THEMES_DIR="$REFIND_DIR/themes"
REFIND_CONF="$REFIND_DIR/refind.conf"

log "📀 Starting rEFInd theme setup..."

# Ensure theme directory exists
sudo mkdir -p "$THEMES_DIR"

# Process each theme from the list
while IFS=$'\t ' read -r theme repo; do
  [[ -z "$theme" || -z "$repo" || "$theme" =~ ^#.*$ ]] && continue

  local_dir="$THEMES_DIR/$theme"
  log "🔧 Processing theme: $theme"

  if [[ ! -d "$local_dir" ]]; then
    log "📥 Cloning $theme from $repo..."
    tmp_dir=$(mktemp -d)
    git clone --depth 1 "$repo" "$tmp_dir"
    sudo mkdir -p "$local_dir"
    sudo cp -r "$tmp_dir"/* "$local_dir"
    rm -rf "$tmp_dir"
    log "✅ Installed $theme into $local_dir"
  else
    log "☑️  Theme $theme already present in $local_dir"
  fi
done < "$THEME_LIST"

log "🎉 rEFInd theme setup complete!"


