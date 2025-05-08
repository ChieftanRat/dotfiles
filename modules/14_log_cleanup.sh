#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.dotfiles/modules/_log.sh"

LOG_DIRS=(
    "$HOME/.dotfiles/logs"
    "$HOME/.cache/dotfiles-sync"
    "$HOME/.cache/dotfiles-backups"
)

AGE_DAYS=7

log "🧹 Cleaning logs older than $AGE_DAYS days..."

for dir in "${LOG_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        find "$dir" -type f -mtime +"$AGE_DAYS" -print -delete | while read -r file; do
            log "🗑 Removed $file"
        done
    fi
done

log "✅ Log cleanup complete."
