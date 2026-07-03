#!/usr/bin/env bash
# Apply config from this repo to the live locations (repo → ~/.config, ~/.local/bin).

set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"

rsync -a --delete \
  --exclude='lazy-lock.json' \
  "$REPO/.config/nvim/"       ~/.config/nvim/

rsync -a --delete \
  "$REPO/.config/konsole/"    ~/.config/konsole/

rsync -a --delete \
  --exclude='plugins/preview.yazi/' \
  "$REPO/.config/yazi/"       ~/.config/yazi/

rsync -a --delete \
  "$REPO/.config/lazygit/"    ~/.config/lazygit/

rsync -a --delete \
  "$REPO/.local/share/konsole/" ~/.local/share/konsole/

cp "$REPO/.local/bin/heiberg-konsole.sh"  ~/.local/bin/
cp "$REPO/.local/bin/yazi-git-diff"       ~/.local/bin/
cp "$REPO/.local/bin/tmux-workspace.sh"   ~/.local/bin/
cp "$REPO/.local/bin/tmux-sync-panes.sh"  ~/.local/bin/
chmod +x ~/.local/bin/heiberg-konsole.sh ~/.local/bin/yazi-git-diff \
         ~/.local/bin/tmux-workspace.sh ~/.local/bin/tmux-sync-panes.sh

cp "$REPO/.tmux.conf" ~/.tmux.conf

echo "Config applied."
