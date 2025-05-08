#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
ARCHIVE_DIR="$DOTFILES/logs/archive"
TEMP_DIR="$DOTFILES/logs/temp"
mkdir -p "$ARCHIVE_DIR" "$TEMP_DIR"

# Flags
PREVIEW_FILE=""
SILENT=false
KEEP_TEMP=false
FILTER_KEY=""
INDEXES=()

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --silent) SILENT=true ;;
    --keep) KEEP_TEMP=true ;;
    --filter) FILTER_KEY="$2"; shift ;;
    --preview) PREVIEW_FILE="$2"; shift ;;
    --index)
      shift
      while [[ $# -gt 0 && "$1" =~ ^[0-9]+$ ]]; do
        INDEXES+=("$1")
        shift
      done
      continue
      ;;
  esac
  shift
done

archives=("$ARCHIVE_DIR"/*.tar.gz)
[[ -e "${archives[0]}" ]] || { echo "❌ No archives found."; exit 1; }

selected=()

# Selection by flag
if [[ -n "$FILTER_KEY" ]]; then
  for f in "${archives[@]}"; do
    [[ "$(basename "$f")" == *"$FILTER_KEY"* ]] && selected+=("$f")
  done
elif [[ "${#INDEXES[@]}" -gt 0 ]]; then
  for idx in "${INDEXES[@]}"; do
    index=$((idx - 1))
    [[ -n "${archives[$index]:-}" ]] && selected+=("${archives[$index]}")
  done
else
  # Fallback to interactive
  echo "📦 Archived Log Bundles:"
  for i in "${!archives[@]}"; do
    echo "$((i + 1))) ${archives[$i]##*/}"
  done
  read -rp "Select bundle(s) by index (e.g. 1 3): " response
  for i in $response; do
    idx=$((i - 1))
    [[ -n "${archives[$idx]:-}" ]] && selected+=("${archives[$idx]}")
  done
fi

if [[ "${#selected[@]}" -eq 0 ]]; then
  echo "❌ No matching logs selected."
  exit 1
fi

rm -rf "$TEMP_DIR"/*
for file in "${selected[@]}"; do
  echo "📂 Extracting: ${file##*/}"
  tar -xzf "$file" -C "$TEMP_DIR"
done

if $SILENT; then
  echo "✅ Extracted logs silently to: $TEMP_DIR"
  $KEEP_TEMP || rm -rf "$TEMP_DIR"/*
  exit 0
fi

echo -e "\n📜 Extracted files in $TEMP_DIR:"
ls -1 "$TEMP_DIR"

if [[ -n "$PREVIEW_FILE" && -f "$TEMP_DIR/$PREVIEW_FILE" ]]; then
  echo "🔍 Previewing: $PREVIEW_FILE"
  if command -v bat &> /dev/null; then
    bat "$TEMP_DIR/$PREVIEW_FILE"
  else
    less "$TEMP_DIR/$PREVIEW_FILE"
  fi
elif [[ -z "$PREVIEW_FILE" ]]; then
  read -rp "Open a specific log file? (filename or blank to skip): " view_file
  if [[ -n "$view_file" && -f "$TEMP_DIR/$view_file" ]]; then
    echo "🔍 Opening $view_file"
    if command -v bat &> /dev/null; then
      bat "$TEMP_DIR/$view_file"
    else
      less "$TEMP_DIR/$view_file"
    fi
  fi
fi

if ! $KEEP_TEMP; then
  read -rp "🧹 Remove extracted temp logs? (y/n): " cleanup
  [[ "$cleanup" =~ ^[Yy]$ ]] && rm -rf "$TEMP_DIR"/* && echo "✅ Temp logs removed." || echo "⚠️ Temp logs kept."
fi
