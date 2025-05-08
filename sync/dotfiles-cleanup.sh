#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
LOG_DIR="$DOTFILES/logs"
ARCHIVE_DIR="$LOG_DIR/archive"
CONFIG_DIR="$HOME/.config"
mkdir -p "$LOG_DIR" "$ARCHIVE_DIR"

timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/cleanup_$timestamp.log"

# Flags
RETENTION_DAYS=7
FORCE=false
SILENT=false
LOGS_ONLY=false
STASHES_ONLY=false
LINKS_ONLY=false
NO_ARCHIVE=false

# Arg parser
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true ;;
    --silent) SILENT=true ;;
    --logs-only) LOGS_ONLY=true ;;
    --stashes-only) STASHES_ONLY=true ;;
    --links-only) LINKS_ONLY=true ;;
    --no-archive) NO_ARCHIVE=true ;;
    --days) RETENTION_DAYS="$2"; shift ;;
  esac
  shift
done

log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

# --- Actions ---

clear_autosync_stashes() {
  local stashes
  stashes=$(git -C "$DOTFILES" stash list | grep "autosync-" | cut -d: -f1 || true)

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
  log "🧾 Searching for logs older than $RETENTION_DAYS days..."
  local old_logs
  old_logs=$(find "$LOG_DIR" -maxdepth 1 -type f -mtime +"$RETENTION_DAYS")

  if [[ -z "$old_logs" ]]; then
    log "✅ No old logs found."
    return
  fi

  echo "$old_logs" | tee -a "$LOG_FILE"

  if $NO_ARCHIVE; then
    find "$LOG_DIR" -maxdepth 1 -type f -mtime +"$RETENTION_DAYS" -delete
    log "🗑️ Deleted old logs directly (no archive)."
  else
    local archive_file="$ARCHIVE_DIR/logs-archived-$timestamp.tar.gz"
    tar -czf "$archive_file" $old_logs
    [[ -f "$archive_file" ]] && find "$LOG_DIR" -maxdepth 1 -type f -mtime +"$RETENTION_DAYS" -delete && log "📦 Logs archived → $archive_file" || log "❌ Archive failed."
  fi
}

clear_orphan_symlinks() {
  local broken
  broken=$(find "$CONFIG_DIR" -xtype l || true)

  if [[ -z "$broken" ]]; then
    log "✅ No orphaned symlinks found."
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

# --- Logic ---

run_all() {
  clear_autosync_stashes
  clear_logs
  clear_orphan_symlinks
}

if $SILENT; then
  if $LOGS_ONLY; then clear_logs
  elif $STASHES_ONLY; then clear_autosync_stashes
  elif $LINKS_ONLY; then clear_orphan_symlinks
  else run_all
  fi
  log "✅ Silent cleanup complete. Log saved to: $LOG_FILE"
  exit 0
fi

if $LOGS_ONLY; then
  clear_logs
elif $STASHES_ONLY; then
  clear_autosync_stashes
elif $LINKS_ONLY; then
  clear_orphan_symlinks
else
  echo "🧼 Dotfiles Cleanup Menu"
  echo "1) Remove autosync Git stashes"
  echo "2) Archive and remove logs older than $RETENTION_DAYS days"
  echo "3) Remove orphaned symlinks"
  echo "4) Run all"
  echo "0) Cancel"
  read -rp "Choose an option: " opt

  case "$opt" in
    1) clear_autosync_stashes ;;
    2) clear_logs ;;
    3) clear_orphan_symlinks ;;
    4) run_all ;;
    0) log "👋 Cancelled." ;;
    *) log "❌ Invalid input." ;;
  esac
fi
