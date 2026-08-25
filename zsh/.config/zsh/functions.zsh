# functions.zsh - shell functions.

# fcd - fuzzy-find a directory and cd into it.
# Named fcd rather than fd so it does not shadow the `fd` finder binary.
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git . "${1:-.}" 2>/dev/null | fzf +m) && cd "$dir"
}

# fh - fuzzy-search shell history and run the selected command.
fh() {
  local cmd
  cmd=$(fc -l 1 | fzf +s --tac | sed 's/ *[0-9]* *//') && eval "$cmd"
}

# y - open yazi and cd to whatever directory it was left in.
# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# mkcd - create a directory and enter it.
mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}

# extract - unpack any common archive format.
extract() {
  [ -f "$1" ] || { echo "extract: '$1' is not a file" >&2; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1"   ;;
    *.tar.gz|*.tgz)   tar xzf "$1"   ;;
    *.tar.xz)         tar xJf "$1"   ;;
    *.tar)            tar xf "$1"    ;;
    *.bz2)            bunzip2 "$1"   ;;
    *.gz)             gunzip "$1"    ;;
    *.zip)            unzip "$1"     ;;
    *.7z)             7z x "$1"      ;;
    *.rar)            unrar x "$1"   ;;
    *) echo "extract: unsupported format '$1'" >&2; return 1 ;;
  esac
}

# quick_commit - commit prefixed with the ticket ID parsed from the branch name.
# A branch named `abc-123-add-login` yields `ABC-123: <message>`.
# Pass `push` as the first argument to push straight after committing.
quick_commit() {
  local branch ticket message
  branch=$(git branch --show-current) || return 1
  ticket=$(echo "$branch" | awk -F '-' '{print toupper($1"-"$2)}')

  if [[ "$1" == "push" ]]; then
    message="$ticket: ${*:2}"
    git commit --no-verify -m "$message" && git push
  else
    message="$ticket: $*"
    git commit --no-verify -m "$message"
  fi
}
alias gqc='quick_commit'
alias gqcp='quick_commit push'

# nosleep - keep the machine awake, including with the lid closed.
# Sleep is re-enabled when the function is interrupted.
nosleep() {
  sudo pmset -a disablesleep 1
  caffeinate -si &
  local pid=$!
  trap "kill $pid 2>/dev/null; sudo pmset -a disablesleep 0; trap - INT" INT
  wait $pid
  sudo pmset -a disablesleep 0
}

# movecur - jiggle the mouse pointer at random intervals. Requires cliclick.
movecur() {
  if ! command -v cliclick >/dev/null 2>&1; then
    echo "movecur: cliclick is not installed (brew install cliclick)" >&2
    return 1
  fi
  caffeinate -di bash -c '
    while true; do
      dx=$((RANDOM % 41 - 20))       # -20..+20 px
      dy=$((RANDOM % 41 - 20))       # -20..+20 px
      pause=$((30 + RANDOM % 120))   # 30..149 ms between out and back
      gap=$((1 + RANDOM % 4))        # 1..4 s between iterations
      cliclick "m:$(printf "%+d,%+d" $dx $dy)" "w:$pause" \
               "m:$(printf "%+d,%+d" $((-dx)) $((-dy)))"
      sleep $gap
    done
  '
}
