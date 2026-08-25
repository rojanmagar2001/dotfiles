// Mirror opencode's state into the tmux window that hosts it.
// Counterpart to ~/.config/tmux/scripts/agent-status.sh (opencode has no
// command-hook mechanism, so this plugin drives the same @agent option).

import { execFile, execFileSync } from "node:child_process";

const PANE = process.env.TMUX_PANE;

// Subagent (task tool) sessions carry a parentID; their lifecycle events would
// otherwise clobber the window's real state, so track and ignore them.
const childSessions = new Set();

function tmux(...args) {
  execFile("tmux", args, () => {});
}

function setState(state) {
  tmux("set-option", "-w", "-t", PANE, "@agent", "opencode");
  tmux("set-option", "-w", "-t", PANE, "@agent_state", state);
}

function notify(state, message) {
  setState(state);
  tmux("display-message", "-d", "4000", "-t", PANE, `✳ opencode: ${message}`);
}

export const TmuxAgentStatus = async () => {
  if (!PANE) return {};

  setState("idle");

  // No session-end event exists, so clear the flag as the process goes away.
  process.on("exit", () => {
    try {
      execFileSync("tmux", ["set-option", "-w", "-t", PANE, "-u", "@agent_state"], {
        stdio: "ignore",
      });
      execFileSync("tmux", ["set-option", "-w", "-t", PANE, "-u", "@agent"], {
        stdio: "ignore",
      });
    } catch {}
  });

  return {
    "chat.message": async ({ sessionID }) => {
      if (sessionID && childSessions.has(sessionID)) return;
      setState("busy");
    },

    event: async ({ event }) => {
      const type = event?.type;
      const props = event?.properties ?? {};
      const sessionID =
        typeof props.sessionID === "string" && props.sessionID ? props.sessionID : undefined;

      const info = props.info;
      if (info?.id && info.parentID) childSessions.add(info.id);

      // A subagent blocking on the user still deserves the flag, but nothing else.
      if (sessionID && childSessions.has(sessionID)) {
        if (type === "permission.asked") notify("perm", "needs permission");
        else if (type === "question.asked") notify("perm", "is asking a question");
        else if (type?.startsWith("permission.") || type?.startsWith("question."))
          setState("busy");
        return;
      }

      switch (type) {
        case "session.status": {
          const status = props.status;
          const kind = typeof status === "string" ? status : status?.type;
          if (typeof kind === "string") setState(kind.toLowerCase() === "idle" ? "done" : "busy");
          break;
        }
        case "session.idle":
          setState("done");
          break;
        case "permission.asked":
          notify("perm", "needs permission");
          break;
        case "question.asked":
          notify("perm", "is asking a question");
          break;
        case "session.error":
          notify("perm", "hit an error");
          break;
        case "permission.replied":
        case "question.replied":
        case "question.rejected":
        case "tool.execute.before":
        case "tool.execute.after":
        case "session.compacted":
          setState("busy");
          break;
        default:
          break;
      }
    },
  };
};
