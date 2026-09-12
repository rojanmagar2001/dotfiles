# tips

A fuzzy browser for the keys, aliases and tricks this setup gives you.
Type part of what you half-remember, read the explanation on the right, press
Enter to put it on the clipboard.

## Install

```sh
cd ~/.dotfiles && stow --target="$HOME" tips
```

To remove: `stow -D --target="$HOME" tips`

Needs `fzf` (0.60 or newer) and, for the copy on Enter, `pbcopy`.

## Use

Run `tips` from anywhere. Inside tmux it opens as a popup over whatever you
were doing, so nothing in the pane moves.

| Key | Does |
| --- | --- |
| type anything | Filter. The tool name works as a filter too: `tmux copy`, `nvim git`. |
| `enter` | Copy the key or command and close. |
| `ctrl-y` | Copy without closing. |
| `ctrl-/` | Move the detail pane, or hide it. |
| `esc` | Quit. |

`tips <query>` opens with the search box already filled in.

## Layout

| Path | Purpose |
| --- | --- |
| `.local/bin/tips` | The whole program. One bash script, no build step. |
| `.config/tips/*.tsv` | The tips, one file per tool. |

## Adding a tip

Open the file named after the tool and add a line. Four columns, separated by a
single tab:

```
section<TAB>item<TAB>description<TAB>detail
```

- **section** groups the tip inside its tool: `panes`, `git`, `vi mode`. It
  shows above the item in the detail pane.
- **item** is the key or command, and is what Enter copies.
- **description** is the one line shown in the list. Keep it under about 55
  characters or it gets cut off on a narrow screen.
- **detail** is the paragraph in the detail pane, and may be empty. Write `\n`
  for a paragraph break.

Lines starting with `#` are ignored. A new tool is a new `.tsv` file, named
after it; give it a colour in `tool_color` in the script if you want one.

Check the columns survived after editing:

```sh
awk -F'\t' 'NR>1 && NF!=4 {print FILENAME": line "NR" has "NF" fields"}' ~/.config/tips/*.tsv
```

## Elsewhere

`TIPS_DIR` overrides where the tips are read from, which is handy for trying
out an edit before stowing it.
