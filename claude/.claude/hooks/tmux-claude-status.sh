#!/usr/bin/env bash
# Mirror Claude Code state into the tmux window that hosts it.
#
# Sets the window-scoped @claude option to busy|idle|notify, or unsets it.
# tmux.conf renders that as a small ✳ flag in the window list.
#
# Usage: tmux-claude-status.sh <busy|idle|notify|off>   (hook JSON on stdin)

state="${1:-}"

# Always drain stdin so the hook never blocks Claude on a full pipe.
input="$(cat 2>/dev/null)"

[ -n "${TMUX_PANE:-}" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

if [ "$state" = "notify" ]; then
    msg="$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)"
    [ -n "$msg" ] && tmux display-message -d 4000 -t "$TMUX_PANE" "✳ $msg" 2>/dev/null
fi

if [ "$state" = "off" ]; then
    tmux set-option -w -t "$TMUX_PANE" -u @claude 2>/dev/null
else
    tmux set-option -w -t "$TMUX_PANE" @claude "$state" 2>/dev/null
fi

exit 0
