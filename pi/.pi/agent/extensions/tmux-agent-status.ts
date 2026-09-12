// Mirror pi's state into the tmux window that hosts it.
// Counterpart to ~/.config/tmux/scripts/agent-status.sh and the equivalent
// integrations for claude (hooks), codex (hooks.json) and opencode (plugin).
//
// Pi has no permission-approval event to map to the "perm" state, so this
// only drives idle / busy / done.

import { execFile, execFileSync } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const PANE = process.env.TMUX_PANE;

function tmux(...args: string[]) {
  execFile("tmux", args, () => {});
}

function setState(state: string) {
  tmux("set-option", "-w", "-t", PANE!, "@agent", "pi");
  tmux("set-option", "-w", "-t", PANE!, "@agent_state", state);
}

export default function (pi: ExtensionAPI) {
  if (!PANE) return;

  pi.on("session_start", async () => {
    setState("idle");
  });

  pi.on("input", async () => {
    setState("busy");
  });

  pi.on("agent_settled", async () => {
    setState("done");
  });

  pi.on("session_shutdown", async () => {
    try {
      execFileSync("tmux", ["set-option", "-w", "-t", PANE!, "-u", "@agent_state"], {
        stdio: "ignore",
      });
      execFileSync("tmux", ["set-option", "-w", "-t", PANE!, "-u", "@agent"], {
        stdio: "ignore",
      });
    } catch {}
  });
}
