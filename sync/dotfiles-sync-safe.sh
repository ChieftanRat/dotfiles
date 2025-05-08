#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
LOG_DIR="$DOTFILES/logs"
mkdir -p "$LOG_DIR"
timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/cleanup_$timestamp.log"

RETENTION_DAYS=7
FORCE=false
SILENT=false
CONFIG_DIR="$HOME/.config"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true ;;
    --silent) SILENT=true ;;
    --days)
      RETENTION_DAYS="$2"
      shift
      ;;
  esac
  shift
done

log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

# --- Cleanup Functions ---

clear_autosync_stashes() {
  local stashes
  stashes=$(git -C "$DOTFILES" stash list | grep "autosync-" | cut -d: -f1)

  if [[ -z "$stashes" ]]; then
    log "ℹ️ No autosync stashes found."
    return
  fi

  if $FORCE; then
    while read -r stash; do git -C "$DOTFILES" stash drop "$stash"; done <<< "$stashes"
    log "✅ Autosync stashes cleared (forced)."
  else
    log "⚠️ Autosync stashes detected:"
    echo "$stashes" | tee -a "$LOG_FILE"
    read -rp "Delete them? (y/n): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] && while read -r stash; do git -C "$DOTFILES" stash drop "$stash"; done <<< "$stashes" && log "✅ Cleared." || log "❌ Skipped."
  fi
}

clear_logs() {
  log "🧾 Archiving logs older than $RETENTION_DAYS days..."
  local old_logs
  old_logs=$(find "$LOG_DIR" -maxdepth 1 -type f -mtime +"$RETENTION_DAYS")

  if [[ -z "$old_logs" ]]; then
    log "✅ No old logs found."
    return
  fi

  local archive_dir="$LOG_DIR/archive"
  mkdir -p "$archive_dir"
  local archive_file="$archive_dir/logs-archived-$(date +'%Y-%m-%d_%H-%M-%S').tar.gz"

  # Create tar.gz archive
  tar -czf "$archive_file" $old_logs
  log "📦 Archived to: $archive_file"

  # Confirm and delete
  if [[ -f "$archive_file" ]]; then
    echo "$old_logs" | tee -a "$LOG_FILE"
    find "$LOG_DIR" -maxdepth 1 -type f -mtime +"$RETENTION_DAYS" -delete
    log "🗑️ Archived logs deleted from $LOG_DIR"
  else
    log "❌ Archive failed — logs not deleted"
  fi
}

clear_orphan_symlinks() {
  local broken
  broken=$(find "$CONFIG_DIR" -xtype l)

  if [[ -z "$broken" ]]; then
    log "✅ No orphaned symlinks found in $CONFIG_DIR."
    return
  fi

  if $FORCE; then
    find "$CONFIG_DIR" -xtype l -delete
    log "✅ Orphaned symlinks deleted (forced)."
  else
    log "⚠️ Found orphaned symlinks:"
    echo "$broken" | tee -a "$LOG_FILE"
    read -rp "Delete them? (y/n): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] && find "$CONFIG_DIR" -xtype l -delete && log "✅ Deleted." || log "❌ Skipped."
  fi
}

# --- Execution Flow ---

if $SILENT; then
  log "⚙️ Running cleanup in SILENT mode..."
  clear_autosync_stashes
  clear_logs
  clear_orphan_symlinks
  log "✅ Silent cleanup complete. Log: $LOG_FILE"
else
  echo "🧼 Dotfiles Cleanup Menu"
  echo "1) Remove autosync Git stashes"
  echo "2) Remove logs older than $RETENTION_DAYS days"
  echo "3) Remove orphaned symlinks in ~/.config"
  echo "4) Do all"
  echo "0) Cancel"
  read -rp "Choose an option: " opt

  case "$opt" in
    1) clear_autosync_stashes ;;
    2) clear_logs ;;
    3) clear_orphan_symlinks ;;
    4)
      clear_autosync_stashes
      clear_logs
      clear_orphan_symlinks
      ;;
    0) log "👋 Cleanup cancelled." ;;
    *) log "❌ Invalid selection." ;;
  esac

  log "📄 Cleanup complete. Log saved to: $LOG_FILE"
fi
