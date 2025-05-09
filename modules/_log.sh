#!/usr/bin/env bash
set -euo pipefail

# Set up log directory and file
timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
LOG_DIR="$HOME/.dotfiles/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bootstrap_$timestamp.log"

# General logging function
log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

fatal() {
  log "❌ $1"
  exit 1
}

# Export for external use
export -f log
export -f fatal
