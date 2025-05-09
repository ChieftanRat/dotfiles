#!/usr/bin/env fish
# Source log functions
source "$HOME/.dotfiles/modules/_log.fish"

# Dry-run mode toggle
set DRY_RUN "false"
for arg in $argv
    if test "$arg" = "--dry-run"
        set DRY_RUN "true"
    end
end

# Check internet connection
if not ping -c 1 archlinux.org > /dev/null 2>&1
    fatal "❌ No internet connection. Skipping Flatpak installs."
    exit 1
end

# Ensure Flathub is added
if not flatpak remote-list | grep -q flathub
    if test $DRY_RUN = "true"
        log "[DRY RUN] Would add Flathub remote."
    else
        log "➕ Adding Flathub remote..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    end
end

# Flatpak app IDs to install
set flatpaks \
    com.core447.StreamController \
    io.github.equicord.equibop \
    io.github.jeffshee.Hidamari \
    app.zen_browser.zen

# Install listed apps
for app in $flatpaks
    if flatpak info $app > /dev/null 2>&1
        log "✅ $app already installed."
    else
        if test $DRY_RUN = "true"
            log "[DRY RUN] Would install: $app"
        else
            log "📦 Installing $app..."
            if flatpak install --noninteractive --or-update flathub $app
                log "✅ $app installed successfully."
            else
                log "[WARN] ⚠️ $app not found in Flathub. Check spelling or availability."
            end
        end
    end
end

