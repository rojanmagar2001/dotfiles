# zsh

Modular zsh configuration, managed with GNU Stow.

## Install

```sh
cd ~/.dotfiles && stow --target="$HOME" zsh
```

To remove: `stow -D --target="$HOME" zsh`

## Layout

| File | Loaded by | Purpose |
| --- | --- | --- |
| `.zshenv` | every zsh | Environment variables only. Must stay fast and silent. |
| `.zshrc` | interactive shells | Loader: history/directory options, then sources the modules below. |
| `.config/zsh/custom.zsh` | `.zshrc` | Homebrew, completion, starship, zoxide, fzf, plugins, vi mode. |
| `.config/zsh/tools.zsh` | `.zshrc` | Language runtimes and per-tool `PATH`. Everything guarded. |
| `.config/zsh/aliases.zsh` | `.zshrc` | Aliases. |
| `.config/zsh/functions.zsh` | `.zshrc` | Shell functions. |
| `.config/zsh/work.zsh` | `.zshrc` | Work-specific config. Git-ignored, optional. |
| `.config/zsh/local.zsh` | `.zshrc` | Machine-specific overrides. Git-ignored, optional. |

Modules load in that order, and each one is optional — a missing file is skipped.

## Conventions

- **`.zshenv` holds variables, never commands.** It runs for scripts and
  non-interactive shells too, so anything slow or noisy belongs in `.zshrc`.
- **Add `PATH` entries with `path_prepend`** (defined in `tools.zsh`). It skips
  directories that do not exist and refuses to add duplicates.
- **Machine-specific things go in `local.zsh`,** not in the tracked modules.
  Secrets go in `~/.env`, which `.zshenv` sources when present.
- **Keep startup cheap.** Avoid `eval "$(some-tool ...)"` at the top level when
  the tool is only needed occasionally; load it lazily instead. `nvm` and the
  `ngrok` completions are done this way.

## Startup cost

Measure with:

```sh
for i in $(seq 5); do /usr/bin/time zsh -i -c exit; done
```

Current: roughly 100ms. The main things keeping it there are a `compinit`
cache rebuilt at most once a day, lazily loaded `nvm`, and no subshells in
the hot path.
