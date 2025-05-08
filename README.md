# 🗂️ ChieftanRat’s Dotfiles

A modular, idempotent, and scalable dotfiles system for Arch-based Linux using Fish shell, Hyprland, Flatpak, and theming.

---

## 🚀 Getting Started

```bash
# 1. Clone the repo
git clone https://github.com/ChieftanRat/dotfiles.git ~/.dotfiles

# 2. Run the bootstrap
cd ~/.dotfiles
./bootstrap.sh
```

Use flags to control what runs:

```bash
./bootstrap.sh --no-flatpak --no-sync --dry-run
```

---

## 📁 Folder Structure

```
~/.dotfiles/
├── bootstrap.sh               # Entry point
├── dotfiles-menu.sh           # Terminal dashboard
├── fish/                      # fish configs
├── nvim/                      # Neovim configs
├── cursors/                   # Cursor themes (.tar.xz)
├── wallpapers/                # Wallpapers
├── sync/                      # Sync scripts
├── modules/                   # Modular setup scripts
├── logs/                      # Bootstrap logs
├── themes.txt                 # SDDM theme index
├── refind-themes.txt          # rEFInd theme index
├── .gitignore          
└── README.md
```

---

## ⚙️ Bootstrap Flags

| Flag         | Description                          |
|--------------|--------------------------------------|
| `--no-flatpak` | Skip installing Flatpaks             |
| `--no-sync`    | Skip cron and Git sync setup         |
| `--no-sddm`    | Skip SDDM theme application          |
| `--no-refind`  | Skip rEFInd theme application        |
| `--dry-run`    | Preview actions without applying     |
| `--help`       | Show usage instructions              |

---

## 🖥️ Terminal Dashboard

Launch:

```bash
~/.dotfiles/dotfiles-menu.sh
```

Features:
- Run bootstrap
- Apply themes (rEFInd / SDDM)
- Set wallpaper or Waybar look
- Switch cursor
- Manually sync dotfiles
- Clean old logs

---

## 🔁 Sync Behavior

- Auto-syncs every 30 mins via cron
- Backs up modified files to:
  ```
  ~/.cache/dotfiles-backups/
  ```
- Logs activity in:
  ```
  ~/.cache/dotfiles-sync/
  ```

Run manually:

```bash
~/.dotfiles/sync/dotfiles-sync.sh
```

---

## 💬 Aliases in Fish Shell

| Alias        | Action                                   |
|--------------|------------------------------------------|
| `nv`         | Neovim                                   |
| `dotfiles`   | Git inside `~/.dotfiles`                 |
| `reshell`    | Reload Fish config                       |
| `update`     | System update via yay                    |
| `flatupdate` | Flatpak update                           |
| `reload`     | Hyprland reload                          |
| `gs`         | Git status                               |
| `ga`         | Git add                                  |
| `gp`         | Git push                                 |

---

## 🌈 Themes + UI

- Wallpapers: `~/.dotfiles/wallpapers/`
- Cursors:    `~/.dotfiles/cursors/*.tar.xz`
- Waybar:     auto-imports from [Rosé Pine Waybar](https://github.com/rose-pine/waybar)
- rEFInd:     themes switchable via dashboard
- SDDM:       themes defined in `themes.txt`

---

## 🧠 Developer Notes

- Use `system-profile.sh` to define per-machine settings (cursor size, theme defaults)
- Run `dotfiles-sync.sh --dry-run` to preview commits
- Use `14_log_cleanup.sh` or menu option 9 to rotate logs

---

Happy hacking! ⚙️🐟
