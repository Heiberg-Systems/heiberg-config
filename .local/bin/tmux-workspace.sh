#!/usr/bin/env bash
SESSION="${1:?Usage: tmux-workspace.sh <session-name> <directory>}"
DIR="${2:?Usage: tmux-workspace.sh <session-name> <directory>}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux attach-session -t "$SESSION"
    exit 0
fi

tmux new-session -d -s "$SESSION" -c "$DIR"

# Left pane (65%): claude
tmux send-keys -t "${SESSION}:0.0" "claude -r" Enter

# Split right column (35%): yazi on top
tmux split-window -h -t "${SESSION}:0.0" -c "$DIR" -p 35
tmux send-keys -t "${SESSION}:0.1" "yazi" Enter

# Split right column vertically: lazygit on bottom
tmux split-window -v -t "${SESSION}:0.1" -c "$DIR"
tmux send-keys -t "${SESSION}:0.2" "lazygit" Enter

# Focus claude
tmux select-pane -t "${SESSION}:0.0"

tmux attach-session -t "$SESSION"
