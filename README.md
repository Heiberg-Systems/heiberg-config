# heiberg-config

Dotfiles for Jako Heiberg — nvim, Konsole, Yazi, and custom scripts.

## What's included

| Path | Contents |
|------|----------|
| `.config/nvim/` | Neovim config (lazy.nvim, LSP, DAP, Neo-tree) |
| `.config/konsole/` | Konsole settings and layout files |
| `.config/yazi/` | Yazi file manager config, keymaps, and plugins |
| `.local/bin/heiberg-konsole.sh` | KDE global shortcut launcher for Konsole (`Ctrl+Shift+K`) |
| `.local/bin/yazi-git-diff` | fzf-based commit diff script used by Yazi `Ctrl+H` |

## New machine setup

```bash
git clone git@github.com:jheiberg/heiberg-config.git ~/Development/heiberg-config
cd ~/Development/heiberg-config
./apply.sh
```

## Keeping the repo up to date

After changing any config files on this machine:

```bash
~/Development/heiberg-config/sync.sh
```

This copies live files into the repo, commits with today's date, and pushes.

## Pulling changes from another machine

```bash
cd ~/Development/heiberg-config
git pull
./apply.sh
```

## Scripts

### `sync.sh` — live → repo

Copies config from `~/.config/` and `~/.local/bin/` into the repo, then commits and pushes if anything changed.

### `apply.sh` — repo → live

Copies config from the repo into `~/.config/` and `~/.local/bin/`. Run this after cloning or after pulling changes made on another machine.
