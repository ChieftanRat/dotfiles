#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="/usr/share/sddm/themes"
THEME_LIST="$HOME/.dotfiles/themes.txt"
ACTIVE_THEME=$(grep '^Current=' /etc/sddm.conf | cut -d'=' -f2 | xargs)

# Ensure the theme list exists
if [ ! -f "$THEME_LIST" ]; then
  echo "[ERROR] Theme list file not found: $THEME_LIST"
  exit 1
fi

# Read keep list and include active theme
mapfile -t KEEP_THEMES < <(awk '{print $1}' "$THEME_LIST")
KEEP_THEMES+=("$ACTIVE_THEME")

echo "[INFO] These themes will be kept:"
for theme in "${KEEP_THEMES[@]}"; do
  echo "  - $theme"
done

# Get installed themes
mapfile -t INSTALLED < <(find "$THEME_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

# Compare and collect themes to delete
TO_DELETE=()
for theme in "${INSTALLED[@]}"; do
  if [[ ! " ${KEEP_THEMES[*]} " =~ " $theme " ]]; then
    TO_DELETE+=("$theme")
  fi
done

# If nothing to delete, exit
if [ "${#TO_DELETE[@]}" -eq 0 ]; then
  echo "[INFO] No unused themes to remove."
  exit 0
fi

# Warn user and show deletion list
echo ""
echo "[WARNING] The following themes will be permanently deleted:"
for t in "${TO_DELETE[@]}"; do
  echo "  - $t"
done

# Confirm
read -rp "Proceed with deletion? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  for t in "${TO_DELETE[@]}"; do
    echo "[INFO] Removing theme: $t"
    sudo rm -rf "$THEME_DIR/$t"
  done
  echo "[INFO] Cleanup complete."
else
  echo "[INFO] Aborted. No changes made."
fi
