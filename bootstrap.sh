#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
MODULES="$DOTFILES/modules"
CONFIG_FISH="$HOME/.config/fish/config.fish"
ALIASES_SOURCE_LINE='source ~/.dotfiles/modules/aliases.fish'

source "$MODULES/_log.sh"
source "$MODULES/_env.sh"

# Ensure logs directory exists and is tracked via .keep
if [[ ! -d "$DOTFILES/logs" ]]; then
  mkdir -p "$DOTFILES/logs"
  log "📂 Created logs/ directory"
else
  log "📁 logs/ directory already exists"
fi

if [[ ! -f "$DOTFILES/logs/.keep" ]]; then
  touch "$DOTFILES/logs/.keep"
  log "📎 Created logs/.keep file to ensure Git tracking"
else
  log "📎 logs/.keep already present"
fi

if ! grep -q "$ALIASES_SOURCE_LINE" "$CONFIG_FISH"; then
  echo "" >> "$CONFIG_FISH"
  echo "# Source dotfiles aliases" >> "$CONFIG_FISH"
  echo "if test -f ~/.dotfiles/modules/aliases.fish" >> "$CONFIG_FISH"
  echo "    $ALIASES_SOURCE_LINE" >> "$CONFIG_FISH"
  echo "end" >> "$CONFIG_FISH"
  log "🔗 Linked aliases.fish in config.fish"
fi

PROFILE="$HOME/.dotfiles/system-profile.sh"
[ -f "$PROFILE" ] && source "$PROFILE"

source "$MODULES/_require.sh"

# 🛡 Prevent rerun on same machine
existing_flag=$(find "$DOTFILES" -name ".setup_done_*" 2>/dev/null | head -n 1)
if [[ -f "$existing_flag" ]]; then
    log "⚠️  Setup already completed on this machine. Found: $existing_flag"
    exit 1
fi

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
RUN_APPIMAGES=true
DRY=false

for arg in "$@"; do
    case $arg in
        --no-flatpak)   RUN_FLATPAK=false ;;
        --no-sync)      RUN_SYNC=false ;;
        --no-sddm)      RUN_SDDM=false ;;
        --no-refind)    RUN_REFIND=false ;;
        --no-appimages) RUN_APPIMAGES=false ;;
        --dry-run)      DRY=true ;;
        --help|-h)
            echo "Usage: ./bootstrap.sh [flags]"
            echo "  --no-flatpak    Skip Flatpak installs"
            echo "  --no-sync       Skip dotfiles sync setup"
            echo "  --no-sddm       Skip SDDM theme setup"
            echo "  --no-refind     Skip rEFInd theme setup"
            echo "  --no-appimages  Skip AppImage setup"
            echo "  --dry-run       Run all modules in preview mode"
            exit 0
            ;;
        *) fatal "❌ Unknown flag: $arg" ;;
    esac
done

# --- Required Tools
require git fish curl rsync nvim zoxide

# --- Optional machine profile
PROFILE="$DOTFILES/system-profile.sh"
[ -f "$PROFILE" ] && source "$PROFILE"

# --- Module Calls
log "🚀 Starting dotfiles bootstrap..."

bash "$MODULES/00_git_identity.sh" "$@"

log "🐟 Running Fish-based setup scripts.."

for script in "$MODULES"/[0-9][0-9]_*.fish; do
  script_name="$(basename "$script")"

  # Skip conditionals
  case "$script_name" in
    03_flatpaks.fish)
      if ! $HAS_FLATPAK || ! $RUN_FLATPAK; then
        log "⏭️ Flatpak step skipped"
        continue
      fi
      ;;
    04_appimages.fish)
      if ! $RUN_APPIMAGES; then
        "⏭️ AppImage step skipped"
        continue
      fi
      ;;
  esac

  if [ -f "$script" ]; then
    log "➡️Executing: $script_name"
    fish "$script" || log "⚠️Warning: $script_name exited with code $?"
  fi
done

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

# --- Completion + Setup Flag
if [[ $? -eq 0 ]]; then
    machine_id=$(hostname)-$(cat /etc/machine-id 2>/dev/null || echo $RANDOM)
    setup_flag="$DOTFILES/.setup_done_$machine_id"

    touch "$setup_flag"
    log "✅ Setup flag created: $setup_flag"
else
    log "[ERROR] Setup did not complete cleanly. Setup flag not set"
fi

log "🎉 Bootstrap complete at $(date '+%H:%M:%S')"
log "📝 Log saved to: $LOG_FILE"
