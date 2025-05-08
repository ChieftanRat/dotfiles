#!/usr/bin/env bash
set -euo pipefail

# Define repo (override via env or flag later if needed)
REPO_URL="${REPO_URL:-https://github.com/ChieftanRat/dotfiles.git}"
DEST_DIR="$HOME/.dotfiles"
MODULES_DIR="$DEST_DIR/modules"

# Ensure dos2unix is available
if ! command -v dos2unix >/dev/null 2>&1; then
  echo "📦 Installing dos2unix..."
  sudo pacman -S --noconfirm dos2unix || echo "⚠️ Could not install dos2unix. Please install it manually."
fi

echo "🔎 Checking repo config..."
echo "📦 Repo: $REPO_URL"
echo "📁 Destination: $DEST_DIR"

# Clone dotfiles repo
if [[ ! -d "$DEST_DIR" ]]; then
  echo "🔽 Cloning..."
  git clone "$REPO_URL" "$DEST_DIR"
else
  echo "✅ Dotfiles already present at $DEST_DIR"
fi

# Make scripts executable
echo "🔧 Making scripts executable..."
find "$MODULES_DIR" -type f -name "*.sh" -exec chmod +x {} +

# Clean CRLF endings across repo
echo "🧹 Cleaning CRLF line endings (Windows-style)..."
find "$DEST_DIR" -type f -exec dos2unix {} + 2>/dev/null
echo "✅ Line endings cleaned."

# Optional: Run bootstrap or remind user
if [[ -f "$DEST_DIR/bootstrap.sh" ]]; then
  echo "🚀 Running bootstrap script..."
  bash "$DEST_DIR/bootstrap.sh"
else
  echo "⚠️ Menu script not found. You may need to run bootstrap manually."
fi

echo "✅ Setup complete!"
