#!/usr/bin/env bash
# Mirror a coding agent's state into the tmux window that hosts it.
#
# Sets two window-scoped options, both consumed by tmux.conf:
#   @agent        agent name (claude | codex | opencode) -> window name
#   @agent_state  idle | busy | done | perm              -> coloured flag
#
#   idle  session open, nothing pending          ✳ grey
#   busy  working                                ✳ cyan
#   done  turn finished, waiting on you          ✓ green
#   perm  permission / approval required         ! orange
#
# Usage: agent-status.sh <agent> <idle|busy|done|perm|notify|off>
#        (hook JSON on stdin; "notify" resolves to perm or done by message)
#
# Wired up from:
#   claude    ~/.claude/settings.json         (hooks)
#   codex     ~/.codex/hooks.json             (hooks, needs one-time trust)
#   opencode  ~/.config/opencode/plugins/tmux-agent-status.js

agent="${1:-}"
state="${2:-}"

# Always drain stdin so the hook never blocks the agent on a full pipe.
input="$(cat 2>/dev/null)"

[ -n "${TMUX_PANE:-}" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

if [ "$state" = "off" ]; then
    tmux set-option -w -t "$TMUX_PANE" -u @agent_state 2>/dev/null
    tmux set-option -w -t "$TMUX_PANE" -u @agent 2>/dev/null
    exit 0
fi

msg=""
if [ "$state" = "notify" ] || [ "$state" = "perm" ]; then
    if command -v jq >/dev/null 2>&1; then
        # .message is claude's Notification text; codex PermissionRequest
        # carries the tool name instead.
        msg="$(printf '%s' "$input" | jq -r '.message // .tool_name // empty' 2>/dev/null)"
    fi

    # Claude sends both "needs your permission to use X" and "is waiting for
    # your input" through the same Notification hook; only the former blocks.
    if [ "$state" = "notify" ]; then
        case "$msg" in
            *permission*|*approve*|*approval*) state="perm" ;;
            *) state="done" ;;
        esac
    fi

    [ -z "$msg" ] && msg="needs your input"
    tmux display-message -d 4000 -t "$TMUX_PANE" "✳ ${agent}: $msg" 2>/dev/null
fi

tmux set-option -w -t "$TMUX_PANE" @agent "$agent" 2>/dev/null
tmux set-option -w -t "$TMUX_PANE" @agent_state "$state" 2>/dev/null

exit 0
