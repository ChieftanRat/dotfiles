#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
MODULES="$DOTFILES/modules"

source "$MODULES/_log.sh"
source "$MODULES/_env.sh"

PROFILE="$HOME/.dotfiles/system-profile.sh"
[ -f "$PROFILE" ] && source "$PROFILE"

source "$MODULES/_require.sh"

# --- Timeshift Snapshot (if applicable)
if command -v timeshift &>/dev/null; then
    log "📸 Creating Timeshift snapshot..."
    sudo timeshift --create --comments "Pre-bootstrap snapshot from dotfiles" --tags D || \
        log "⚠️ Timeshift snapshot failed or requires setup."
else
    log "⏭️ Skipping Timeshift snapshot — not installed yet"
fi

# --- Flags
RUN_FLATPAK=true
RUN_SYNC=true
RUN_SDDM=true
RUN_REFIND=true
DRY=false

for arg in "$@"; do
  case $arg in
    --no-flatpak) RUN_FLATPAK=false ;;
    --no-sync)    RUN_SYNC=false ;;
    --no-sddm)    RUN_SDDM=false ;;
    --no-refind)  RUN_REFIND=false ;;
    --dry-run)    DRY=true ;;
    --help|-h)
        echo "Usage: ./bootstrap.sh [flags]"
        echo "  --no-flatpak   Skip Flatpak installs"
        echo "  --no-sync      Skip dotfiles sync setup"
        echo "  --no-sddm      Skip SDDM theme setup"
        echo "  --no-refind    Skip rEFInd theme setup"
        echo "  --dry-run      Run all modules in preview mode"
        exit 0
        ;;
    *) fatal "❌ Unknown flag: $arg" ;;
  esac
done

# --- Required Tools
require git fish curl rsync neovim zoxide

# --- Optional machine profile
PROFILE="$DOTFILES/system-profile.sh"
[ -f "$PROFILE" ] && source "$PROFILE"

# --- Module Calls
log "🚀 Starting dotfiles bootstrap..."

# Fish & Nvim Configs
bash "$MODULES/02_symlinks.fish"

# Flatpak Apps
if $HAS_FLATPAK && $RUN_FLATPAK; then
    bash "$MODULES/03_flatpaks.fish"
else
    log "⏭️ Flatpak step skipped"
fi

# SDDM Theme
if $RUN_SDDM; then
    bash "$MODULES/05_sddm_theme.sh" "$($DRY && echo --dry-run)"
fi

# rEFInd Theme
if $RUN_REFIND; then
    bash "$MODULES/07_refind_themes.sh" "$($DRY && echo --dry-run)"
fi

# Wallpaper, Cursors, etc.
bash "$MODULES/10_set_wallpaper.sh" "$($DRY && echo --dry-run)"
bash "$MODULES/12_cursor_switcher.sh"

# Sync Script Setup
if $RUN_SYNC; then
    bash "$MODULES/13_dotfiles_sync.sh"
fi

log "🎉 Bootstrap complete at $(date '+%H:%M:%S')"
log "📝 Log saved to: $LOG_FILE"
