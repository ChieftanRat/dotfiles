#!/usr/bin/env fish

set -e

# Dry-run mode toggle
set DRY_RUN (contains --dry-run $argv)

# Check internet connection
if not ping -c 1 archlinux.org > /dev/null 2>&1
  echo "❌ No internet connection. Skipping Flatpak installs."
  exit 1
end

# Ensure flathub is added
if not flatpak remote-list | grep -q flathub
  if test $DRY_RUN
    echo "[DRY RUN] Would add flathub remote."
  else
    echo "➕ Adding flathub remote..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  end
end

# Flatpak app IDs to install
set flatpaks \
  com.streamcontroller.StreamController \
  com.equibop.Equibop \
  io.github.jeffshee.Hidamari

# Install listed apps
for app in $flatpaks
  if flatpak search --app $app | grep -q $app
    if not flatpak info $app > /dev/null 2>&1
      if test $DRY_RUN
        echo "[DRY RUN] Would install: $app"
      else
        echo "📦 Installing $app..."
        flatpak install -y flathub $app
      end
    else
      echo "✅ $app already installed."
    end
  else
    echo "[WARN] ⚠️ $app not found in Flathub. Check spelling or availability."
  end
end
