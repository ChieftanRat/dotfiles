# 🔁 Dotfiles Sync Utility

This utility automates the syncing of your dotfiles repo using Git. It runs as a cron job every 30 minutes, commits changes, and pushes them to your remote repository.

---

## 📂 How It Works

- **Monitors your home directory** for any tracked file changes
- **Backs up modified files** to `.cache/dotfiles-backups/<timestamp>/`
- **Commits changes automatically** using Git
- **Pushes to your remote repo**
- **Logs each sync** to `.cache/dotfiles-sync/`
- **Notifies you** with `notify-send` (if available)

---

## 🕰️ Cron Setup

The cron job is created automatically by the module:

```bash
 * * * * ~/.dotfiles/sync/dotfiles-sync.sh >> ~/.cache/dotfiles-sync/sync-<timestamp>.log 2>&1
```

This runs every 30 minutes in the background.

---

## 🧪 Dry Run

Preview what would be committed without making changes:

```bash
~/.dotfiles/sync/dotfiles-sync.sh --dry-run
```

🛑 Safety Measures
- ✅ Ignores untracked files — you’ll get a warning and nothing is committed
- ✅ Backs up all modified files before sync
- ✅ Exits early if no changes detected

💬 Notifications
If notify-send is installed and available, you’ll get a desktop notification like:

```bash
✅ Dotfiles synced at 14:30
```

## 🧠 Tip

This setup assumes your `.dotfiles` is a **normal Git repo** (not a bare repo).  
You should use `git` directly inside `~/.dotfiles`, and your configs are symlinked to `~/.config/`.

Example layout:

