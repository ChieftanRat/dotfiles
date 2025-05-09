#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/.dotfiles"
BACKUP_ROOT="$HOME/.cache/dotfiles-backups"
SYNC_LOG_DIR="$HOME/.cache/dotfiles-sync"
LOG_DIR="$HOME/.dotfiles/logs"
mkdir -p "$BACKUP_ROOT" "$SYNC_LOG_DIR" "$LOG_DIR"
source "$HOME/.dotfiles/modules/_log.sh"

# Dry run flag
DRY_RUN=false

# Parse arguments for dry-run and force flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --auto) AUTO_MODE=true ;;
    --force) FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    -m|--message) COMMIT_MSG="$2"; shift ;;
  esac
  shift
done

# Get current git config
current_name=$(git config --global user.name || echo "")
current_email=$(git config --global user.email || echo "")

# Main logic
if [[ "$FORCE" = true || -z "$current_name" || -z "$current_email" ]]; then
  if [[ "$DRY_RUN" = true ]]; then
    log "🧪 Dry run would set Git identity to: $GIT_NAME <$GIT_EMAIL>"
  else
    read -rp "⚡ Set Git identity to '$GIT_NAME <$GIT_EMAIL>'? [y/N]" confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      git config --global user.name "$GIT_NAME"
      git config --global user.email "$GIT_EMAIL"
      log "Git identity set: $GIT_NAME <$GIT_EMAIL>"
    else
      echo "❌ Aborted by user."
      exit 1
    fi
  fi
else
  log "Git identity already set: $current_name <$current_email>"
  echo "Use --force to override."
fi

# Dry run section before performing any git changes
if [[ "$DRY_RUN" = true ]]; then
  log "🧪 Dotfiles Sync – Dry Run Preview ($(date "+%Y-%m-%d %H:%M:%S"))"
  changes=$(git status --porcelain)
  if [[ -z "$changes" ]]; then
    log "✅ No changes to sync."
  else
    log "📄 Files to be committed:"
    echo "$changes" | while read -r line; do
      status=${line:0:2}
      file=${line:3}
      log "  - ${status} ${file}"
    done
  fi
  log "🔎 Current branch: $current_branch"
  log "🚫 No changes pushed. This was a dry run."
  exit 0
fi

# Sync operation
git add .
git commit -m "$COMMIT_MSG" || log "No changes to commit."
git push origin "$current_branch"

log "Dotfiles synced successfully."
