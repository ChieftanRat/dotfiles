#!/usr/bin/env bash
set -e

SYNC_SCRIPT="$HOME/.dotfiles/sync/dotfiles-sync.sh"
LOG_DIR="$HOME/.cache/dotfiles-sync"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/sync-$(date +'%Y%m%d-%H%M').log"

# Ensure cronie installed
if ! command -v crontab &>/dev/null; then
    echo "📦 Installing cronie..."
    sudo pacman -S --noconfirm cronie
    sudo systemctl enable cronie
    sudo systemctl start cronie
fi

# Make script executable
chmod +x "$SYNC_SCRIPT"

# Create cron job entry
CRON_JOB="*/30 * * * * $SYNC_SCRIPT >> \"$LOG_FILE\" 2>&1"
if crontab -l 2>/dev/null | grep -F "$SYNC_SCRIPT" &>/dev/null; then
    echo "✅ Cron job already exists."
else
    echo "⏱️ Adding cron job to sync dotfiles every 30 minutes..."
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
fi