#!/usr/bin/env fish

# Optional dry-run mode (preview actions without installing)
set DRY_RUN (contains --dry-run $argv) # Usage: ./01_packages.fish --dry-run

set packages \
  git \
  base-devel \
  curl \
  wget \
  neovim \
  unzip \
  rsync \
  os-prober \
  nwg-look \
  zoxide \
  fzf \
  ffmpeg \
  ripgrep \
  timeshift \
  flatpak \
  qt5-graphicaleffects \
  qt5-quickcontrols2 \
  qt5-svg \
  sddm \
  vlc

for pkg in $packages
  if not pacman -Q $pkg > /dev/null 2>&1
    if test $DRY_RUN
      echo "[DRY RUN] Would install: $pkg"
    else
      echo "Installing $pkg..."
      sudo pacman -S --noconfirm $pkg
    end
  else
    echo "$pkg already installed."
  end
end

# Install yay (AUR helper) if missing
if not command -v yay > /dev/null
  if test $DRY_RUN
    echo "[DRY RUN] Would install yay from AUR."
  else
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd
    rm -rf /tmp/yay
  end
else
  echo "yay already installed."
end

# Install superfile-bin (AUR prebuilt)
if not yay -Q superfile-bin > /dev/null 2>&1
  if test $DRY_RUN
    echo "[DRY RUN] Would install superfile-bin via yay."
  else
    echo "Installing superfile-bin via yay..."
    yay -S --noconfirm superfile-bin
  end
else
  echo "superfile-bin already installed."
end
