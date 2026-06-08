#!/usr/bin/env bash
# Keeps Yazi in sync with Claude's working directory.
# Run as a background process by tmux-workspace.sh.
SESSION="$1"
CLAUDE_PANE="${SESSION}:0.0"
YAZI_PANE="${SESSION}:0.1"
LAST_DIR=""

get_yazi_id() {
    local shell_pid yazi_pid
    shell_pid=$(tmux display-message -t "$YAZI_PANE" -p "#{pane_pid}" 2>/dev/null)
    [ -z "$shell_pid" ] && return 1
    yazi_pid=$(pgrep -P "$shell_pid" -x yazi 2>/dev/null | head -1)
    [ -z "$yazi_pid" ] && return 1
    tr '\0' '\n' < /proc/"$yazi_pid"/environ 2>/dev/null | grep '^YAZI_ID=' | cut -d= -f2
}

while tmux has-session -t "$SESSION" 2>/dev/null; do
    current_dir=$(tmux display-message -t "$CLAUDE_PANE" -p "#{pane_current_path}" 2>/dev/null)
    if [ -n "$current_dir" ] && [ "$current_dir" != "$LAST_DIR" ]; then
        LAST_DIR="$current_dir"
        yazi_id=$(get_yazi_id)
        if [ -n "$yazi_id" ]; then
            ya emit-to "$yazi_id" cd "$current_dir" 2>/dev/null
        fi
    fi
    sleep 1
done
