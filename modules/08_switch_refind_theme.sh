#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.dotfiles/modules/_log.sh"

THEME_LIST="$HOME/.dotfiles/refind-themes.txt"
REFIND_DIR="/boot/EFI/refind"
THEMES_DIR="$REFIND_DIR/themes"
REFIND_CONF="$REFIND_DIR/refind.conf"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Sanity check
[[ -f "$THEME_LIST" ]] || fatal "Missing theme list: $THEME_LIST"
[[ -f "$REFIND_CONF" ]] || fatal "Missing config: $REFIND_CONF"

# Extract current theme from include line (assumes path format)
current=$(grep '^include' "$REFIND_CONF" | awk -F/ '{print $NF}' || echo "none")
log "📂 Current rEFInd theme: $current"

# Parse available themes from file
mapfile -t THEMES < <(awk '!/^#|^\s*$/{print $1}' "$THEME_LIST")

echo "Available rEFInd themes:"
for i in "${!THEMES[@]}"; do
  echo "$((i + 1))) ${THEMES[$i]}"
done

read -rp "Select a theme: " choice
[[ "$choice" =~ ^[0-9]+$ ]] || fatal "Invalid selection"
(( choice >= 1 && choice <= ${#THEMES[@]} )) || fatal "Selection out of range"

selected="${THEMES[$((choice - 1))]}"
repo=$(awk -v theme="$selected" '$1 == theme {print $2}' "$THEME_LIST")
[[ -n "$repo" ]] || fatal "Could not find repo for theme '$selected'"

# Clone and install theme
log "📥 Installing rEFInd theme: $selected"
tmp_dir=$(mktemp -d)

git clone --depth 1 "$repo" "$tmp_dir"
sudo mkdir -p "$THEMES_DIR/$selected"
sudo cp -r "$tmp_dir"/* "$THEMES_DIR/$selected"
rm -rf "$tmp_dir"

# 🩹 Patch theme.conf to use relative paths only
theme_conf="${THEMES_DIR}/${selected}/theme.conf"
if [[ -f "$theme_conf" ]]; then
  sudo sed -i -E \
    -e 's@([[:space:]]+)themes/[^/]+/@\1@g' \
    "$theme_conf"
  log "🔧 Patched $theme_conf to use relative paths"
else
  log "^⚠ Warning: theme.conf not found in $selected — skipping patch"
fi

# Find theme.conf relative to the theme directory
conf_rel_path=$(find "$THEMES_DIR/$selected" -name theme.conf -print -quit | sed "s|$THEMES_DIR/||")
if [[ -z "$conf_rel_path" ]]; then
  echo "❌ Could not find theme.conf in $selected"
  exit 1
fi

# Validate all asset paths in theme.conf
log "🔍 Validating theme assets..."
missing=false
grep -Eo 'themes/[^ ]+\.(png|jpg|bmp|ttf|conf)' "$theme_conf" | while read -r rel_path; do
    full_path="/boot/EFI/refind/$rel_path"
    if [[ ! -f "$full_path" ]]; then
        log "❌ Missing: $rel_path"
        missing=true
    else
        log "✅ Found: $rel_path"
    fi
done

if $missing; then
    log "⚠ Some assets referenced in theme.conf are missing!"
    echo "Aborting theme switch to prevent broken rEFInd visuals."
    exit 1
else
    log "🎯 All assets accounted for."
fi

# Final include patch (validated and guaranteed to exist)
conf_path="themes/$selected/theme.conf"
if [[ ! -f "$REFIND_DIR/$conf_path" ]]; then
  fatal "theme.conf not found at $REFIND_DIR/$conf_path"
fi

sudo sed -i '/^include/d' "$REFIND_CONF"
echo "include $conf_path" | sudo tee -a "$REFIND_CONF" > /dev/null

log "✅ rEFInd theme '$selected' installed and activated."

