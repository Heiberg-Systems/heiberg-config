#!/usr/bin/env bash
SESSION="${1:?Usage: tmux-workspace.sh <session-name> <directory>}"
DIR="${2:?Usage: tmux-workspace.sh <session-name> <directory>}"

# Kill any existing sync watcher and tmux session for this project
pkill -f "tmux-sync-panes.sh $SESSION" 2>/dev/null || true
tmux kill-session -t "$SESSION" 2>/dev/null || true

tmux new-session -d -s "$SESSION" -c "$DIR"

# Left pane (65%): claude
tmux send-keys -t "${SESSION}:0.0" "claude -r" Enter

# Right column top (35%): yazi starting in project root
tmux split-window -h -t "${SESSION}:0.0" -c "$DIR" -p 35
tmux send-keys -t "${SESSION}:0.1" "yazi" Enter

# Right column bottom (35%): lazygit on develop branch
tmux split-window -v -t "${SESSION}:0.1" -c "$DIR"
tmux send-keys -t "${SESSION}:0.2" "git checkout develop 2>/dev/null; lazygit" Enter

# Start pane sync watcher (survives shell exit)
nohup /home/jako/.local/bin/tmux-sync-panes.sh "$SESSION" >/dev/null 2>&1 &

tmux select-pane -t "${SESSION}:0.0"
tmux attach-session -t "$SESSION"
