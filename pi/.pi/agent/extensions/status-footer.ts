// Replace pi's default footer with Claude Code's bottom area: a dim keybinding
// hint row under the input box, then a status bar matching ~/.claude/statusline.sh
// (directory, git branch, model, context bar), with pi's own token totals and
// session cost appended since Claude Code has nothing equivalent to show.
//
// Color roles mirror that script's blue/magenta/cyan/green-yellow-red scheme,
// mapped onto the "claude" theme's tokens (mdLink=blue, mdHeading=peach,
// accent=peach, success/warning/error=green/yellow/red).

import { readFileSync } from "node:fs";
import { basename } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { keyText, rawKeyHint } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

/**
 * Directory label for the bar. In a linked worktree the leaf directory is named
 * after the branch, which the branch segment already shows, so fall back to the
 * main repo name, the same way ~/.claude/statusline.sh does.
 */
function dirLabel(cwd: string): string {
  try {
    const gitFile = readFileSync(`${cwd}/.git`, "utf8");
    const match = gitFile.match(/^gitdir: (.*)\/\.git\/worktrees\//);
    if (match) return basename(match[1]);
  } catch {
    // Not a worktree (.git is a directory), or not a repo at all.
  }
  return basename(cwd);
}

function formatTokens(count: number): string {
  if (count < 1000) return count.toString();
  if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1000000) return `${Math.round(count / 1000)}k`;
  return `${(count / 1000000).toFixed(1)}M`;
}

/** Session totals, counting assistant turns, tool summaries and compactions like pi's own footer. */
function sessionTotals(entries: readonly any[]): { tokens: number; cost: number } {
  let input = 0;
  let output = 0;
  let cost = 0;
  for (const entry of entries) {
    let usage: any;
    if (entry.type === "message" && entry.message.role === "assistant") {
      usage = entry.message.usage;
    } else if (entry.type === "message" && entry.message.role === "toolResult") {
      usage = entry.message.usage;
    } else if (entry.type === "branch_summary" || entry.type === "compaction") {
      usage = entry.usage;
    }
    if (!usage) continue;
    input += usage.input + usage.cacheRead + usage.cacheWrite;
    output += usage.output;
    cost += usage.cost?.total ?? 0;
  }
  return { tokens: input + output, cost };
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setWidget(
      "claude-hints",
      [
        [
          rawKeyHint(keyText("app.interrupt"), "interrupt"),
          rawKeyHint(`${keyText("app.clear")}/${keyText("app.exit")}`, "clear/exit"),
          rawKeyHint("/", "commands"),
          rawKeyHint("!", "bash"),
          rawKeyHint(keyText("app.tools.expand"), "expand tools"),
        ].join(ctx.ui.theme.fg("dim", " · ")),
      ],
      { placement: "belowEditor" },
    );

    ctx.ui.setFooter((tui, theme, footerData) => ({
      invalidate() {},
      render(width: number): string[] {
        const dir = dirLabel(ctx.cwd);
        const branch = footerData.getGitBranch();
        const model = ctx.model?.name ?? ctx.model?.id ?? "no-model";
        const provider = ctx.model?.provider;
        const modelLabel = provider ? `${provider}/${model}` : model;

        const sep = theme.fg("dim", " │ ");
        let line = theme.fg("mdLink", ` ${dir}`);
        if (branch) line += sep + theme.fg("mdHeading", ` ${branch}`);
        line += sep + theme.fg("accent", `󰧑 ${modelLabel}`);

        const usage = ctx.getContextUsage();
        if (usage?.percent != null) {
          const pct = Math.min(100, Math.round(usage.percent));
          const level = pct < 50 ? "success" : pct < 80 ? "warning" : "error";
          const filled = Math.min(10, Math.round(pct / 10));
          const bar =
            theme.fg(level, "█".repeat(filled)) + theme.fg("dim", "█".repeat(10 - filled));
          line += sep + bar + theme.fg(level, ` ${pct}%`);
        }

        const { tokens, cost } = sessionTotals(ctx.sessionManager.getEntries());
        if (tokens > 0) {
          const spend = cost > 0 ? ` $${cost.toFixed(3)}` : "";
          line += sep + theme.fg("dim", `${formatTokens(tokens)} tok${spend}`);
        }

        const lines = [truncateToWidth(line, width, theme.fg("dim", "…"))];

        // Other extensions publish through ctx.ui.setStatus(); keep showing them.
        const statuses = footerData.getExtensionStatuses();
        if (statuses.size > 0) {
          const statusLine = Array.from(statuses.entries())
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([, text]) => text.replace(/[\r\n\t]+/g, " ").trim())
            .join(" ");
          lines.push(truncateToWidth(statusLine, width, theme.fg("dim", "…")));
        }

        return lines;
      },
      dispose: footerData.onBranchChange(() => tui.requestRender()),
    }));
  });
}
