#!/usr/bin/env bash
# Sync live config files into this repo, then commit and push if anything changed.

set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"

rsync -a --delete \
  --exclude='lazy-lock.json' \
  ~/.config/nvim/       "$REPO/.config/nvim/"

rsync -a --delete \
  ~/.config/konsole/    "$REPO/.config/konsole/"

rsync -a --delete \
  --exclude='plugins/preview.yazi/' \
  ~/.config/yazi/       "$REPO/.config/yazi/"

cp ~/.local/bin/heiberg-konsole.sh "$REPO/.local/bin/"
cp ~/.local/bin/yazi-git-diff      "$REPO/.local/bin/"

cd "$REPO"

if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "Nothing changed."
  exit 0
fi

git diff --stat
git add -A
git commit -m "chore: sync config $(date '+%Y-%m-%d')"
git push
