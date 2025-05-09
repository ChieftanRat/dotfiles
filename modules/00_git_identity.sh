#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.dotfiles/modules/_log.sh"

# Git identity
GIT_NAME="ChieftanRat"
GIT_EMAIL="66624031+ChieftanRat@users.noreply.github.com"

# Optional flags
DRY_RUN=false
FORCE=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --force) FORCE=true ;;
    esac
done

# Get current config
current_name=$(git config --global user.name || echo "")
current_email=$(git config --global user.email || echo "")

# Main logic
if [[ "$FORCE" == true || -z "$current_name" || -z "$current_email" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        log "🧪 [Dry Run] Would set Git identity to: $GIT_NAME <$GIT_EMAIL>"
    else
        log "❓ Set Git identity to '$GIT_NAME <$GIT_EMAIL>'? [y/N] " 
        read -rp "" confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git config --global user.name "$GIT_NAME"
            git config --global user.email "$GIT_EMAIL"
            log "✅ Git identity set: $GIT_NAME <$GIT_EMAIL>"
        else
            log "❌ Aborted by user."
            exit 1
        fi
    fi
else
    log "ℹ️ Git identity already set: $current_name <$current_email>"
    log "   Use --force to override."
fi

# Set Git pull behavior to merge (safe default)
git config --global pull.rebase false
