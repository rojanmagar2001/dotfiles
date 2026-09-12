// Give pi's prompt Claude Code's input box: a rounded border on all four sides
// with a "> " prompt in the left gutter, instead of pi's two bare horizontal rules.
//
// Pi's Editor.render() returns [topBorder, ...text lines, bottomBorder, ...autocomplete].
// Nothing in that array is labelled, so the border overrides below stamp sentinel
// strings and swap them back afterwards: that identifies the box lines exactly and
// leaves the autocomplete menu outside the box, where Claude Code also puts it.
// The line contents themselves are never parsed, so colors, the cursor marker and
// the working spinner embedded in the top border all survive untouched.
//
// If a future pi stops rendering that shape, the sentinels stop coming back and
// render() falls through to pi's own editor rather than drawing a broken box.

import { CustomEditor } from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, KeybindingsManager, TUI } from "@earendil-works/pi-tui";

const TOP = "\x00pi:box:top\x00";
const BOTTOM = "\x00pi:box:bottom\x00";

/** Width of the left gutter holding the prompt. Matches "> ". */
const GUTTER = 2;

class BoxedEditor extends CustomEditor {
  private capturedTop = "";
  private capturedBottom = "";
  /** The editorPaddingX setting, inset inside the box on top of the prompt gutter. */
  private extraPaddingX = 0;
  /** Set while rendering the unboxed fallback, so the borders come back verbatim. */
  private passthrough = false;

  constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
    super(tui, theme, keybindings, { paddingX: GUTTER, embedWorkingStatus: true });
  }

  /** The gutter holds the prompt, so editorPaddingX indents the text further in. */
  setPaddingX(padding: number): void {
    this.extraPaddingX = Math.max(0, padding);
    super.setPaddingX(GUTTER + this.extraPaddingX);
  }

  protected renderTopBorder(width: number, hiddenLineCount: number): string {
    const rendered = super.renderTopBorder(width, hiddenLineCount);
    if (this.passthrough) return rendered;
    this.capturedTop = rendered;
    return TOP;
  }

  protected renderBottomBorder(width: number, hiddenLineCount: number): string {
    const rendered = super.renderBottomBorder(width, hiddenLineCount);
    if (this.passthrough) return rendered;
    this.capturedBottom = rendered;
    return BOTTOM;
  }

  /** Pi's own editor, borders and all, for widths and shapes the box cannot handle. */
  private renderUnboxed(width: number): string[] {
    this.passthrough = true;
    try {
      return super.render(width);
    } finally {
      this.passthrough = false;
    }
  }

  render(width: number): string[] {
    const inner = width - 2;
    if (inner < GUTTER + this.extraPaddingX + 1) return this.renderUnboxed(width);

    const border = this.borderColor ?? ((s: string) => s);
    const rendered = super.render(inner);
    if (rendered[0] !== TOP || !rendered.includes(BOTTOM)) {
      // Pi no longer renders [top, ...text, bottom, ...]: leave its editor alone.
      return this.renderUnboxed(width);
    }

    const out: string[] = [];
    let insideBox = false;
    let firstTextLine = true;

    for (const line of rendered) {
      if (line === TOP) {
        out.push(border("╭") + this.capturedTop + border("╮"));
        insideBox = true;
        continue;
      }
      if (line === BOTTOM) {
        out.push(border("╰") + this.capturedBottom + border("╯"));
        insideBox = false;
        continue;
      }
      if (insideBox) {
        // Text lines start with literal padding spaces; the first one gets the prompt,
        // leaving any editorPaddingX inset between the prompt and the text.
        const body = firstTextLine ? border("> ") + line.slice(GUTTER) : line;
        firstTextLine = false;
        out.push(border("│") + body + border("│"));
        continue;
      }
      // Autocomplete rows: aligned under the box, not boxed.
      out.push(` ${line} `);
    }

    return out;
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    ctx.ui.setEditorComponent((tui, theme, keybindings) => new BoxedEditor(tui, theme, keybindings));
  });
}
