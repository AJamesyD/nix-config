if command -v zmx &>/dev/null; then
  _cache_eval zmx zmx completions zsh

  zmx-select() {
    local display
    display=$(zmx list 2>/dev/null | while IFS=$'\t' read -r name pid clients created dir; do
      name=${name#session_name=}
      pid=${pid#pid=}
      clients=${clients#clients=}
      dir=${dir#started_in=}
      printf "%-20s  pid:%-8s  clients:%-2s  %s\n" "$name" "$pid" "$clients" "$dir"
    done)

    local output query key selected session_name
    output=$({ [[ -n "$display" ]] && echo "$display"; } | fzf \
      --print-query \
      --expect=ctrl-n \
      --height=80% \
      --reverse \
      --prompt="zmx> " \
      --header="Enter: select | Ctrl-N: create new" \
      --preview='zmx history {1}' \
      --preview-window=right:60%:follow \
    )
    local rc=$?

    query=$(echo "$output" | sed -n '1p')
    key=$(echo "$output" | sed -n '2p')
    selected=$(echo "$output" | sed -n '3p')

    if [[ "$key" == "ctrl-n" && -n "$query" ]]; then
      session_name="$query"
    elif [[ $rc -eq 0 && -n "$selected" ]]; then
      session_name=$(echo "$selected" | awk '{print $1}')
    elif [[ -n "$query" ]]; then
      session_name="$query"
    else
      return 130
    fi

    zmx attach "$session_name"
  }
fi

ai-search() {
  local query="$1"
  setopt local_options no_nomatch
  local search_paths=(
    /tmp/ai-research-*
    /tmp/ai-plan-*
    /tmp/ai-design-*
    "$HOME/Documents/research"
  )
  local existing_paths=()
  for p in "${search_paths[@]}"; do
    [[ -e $p ]] && existing_paths+=("$p")
  done
  [[ ${#existing_paths[@]} -eq 0 ]] && { echo "No research files found"; return 1; }
  if [[ -n "$query" ]]; then
    rg --no-heading --line-number --color=always "$query" "${existing_paths[@]}" | \
      fzf --ansi --delimiter=: --preview='bat --color=always --highlight-line {2} {1}' --preview-window='+{2}-10'
  else
    rg --no-heading --line-number --color=always '.' "${existing_paths[@]}" | \
      fzf --ansi --delimiter=: --preview='bat --color=always --highlight-line {2} {1}' --preview-window='+{2}-10'
  fi
}

local P10K_PATH="${ZDOTDIR:-~}/.p10k.zsh"

[[ ! -f "$P10K_PATH" ]] || source "$P10K_PATH"

autoload -Uz add-zsh-hook

# -- Session persistence --
_session_persist_pwd() {
  local tool name
  if [[ -n "$ZMX_SESSION" ]]; then
    tool=zmx name=$ZMX_SESSION
  elif [[ -n "$SHPOOL_SESSION_NAME" ]]; then
    tool=shpool name=$SHPOOL_SESSION_NAME
  else
    return
  fi
  [[ "$name" == */* ]] && return
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/sessions/$tool/$name"
  if [[ -z "$_session_persist_init" ]]; then
    _session_persist_init=1
    mkdir -p "$state_dir"
  fi
  local f="$state_dir/dir"
  [[ "$PWD" == "$(cat "$f" 2>/dev/null)" ]] && return
  printf '%s' "$PWD" > "$f.tmp" && mv "$f.tmp" "$f"
}
add-zsh-hook precmd _session_persist_pwd

_session_persist_scrollback() {
  [[ -n "$ZMX_SESSION" ]] || return
  local d="${XDG_STATE_HOME:-$HOME/.local/state}/sessions/zmx-scrollback"
  local f="$d/$ZMX_SESSION.txt"
  [[ -d "$d" ]] || mkdir -p "$d"
  timeout 5 zmx history "$ZMX_SESSION" | tail -n "${SESSION_PERSIST_SCROLLBACK_LINES:-10000}" > "$f.tmp" && mv "$f.tmp" "$f"
}
[[ -n "$PERIOD" ]] || PERIOD=300
add-zsh-hook periodic _session_persist_scrollback

session-restore() {
  local state_base="${XDG_STATE_HOME:-$HOME/.local/state}/sessions"
  local quiet=0
  [[ "$1" == -q ]] && { quiet=1; shift; }
  [[ -d "${XDG_RUNTIME_DIR}" ]] || { echo "XDG_RUNTIME_DIR not set"; return 1; }
  exec {_sr_fd}>"${XDG_RUNTIME_DIR}/session-restore.lock"
  flock -n $_sr_fd || { exec {_sr_fd}>&-; echo "session-restore already running"; return 1; }
  local restored=0 skipped=0 pruned=0

  if command -v zmx &>/dev/null; then
    local zmx_live
    zmx_live=$(zmx list --short 2>/dev/null)
    local d
    for d in "$state_base"/zmx/*(N/); do
      local name=${d:t}
      if echo "$zmx_live" | grep -qxF "$name"; then
        (( skipped++ ))
        continue
      fi
      local dir="$(cat "$d/dir" 2>/dev/null)"
      [[ -d "$dir" ]] || dir=$HOME
      (cd "$dir" && timeout 5 zmx run "$name" true) && (( restored++ ))
    done
  fi

  if command -v shpool &>/dev/null; then
    local shpool_live="" attempt
    for attempt in 1 2 3; do
      shpool_live=$(shpool list 2>/dev/null | tail -n +2 | cut -f1) && break
      sleep 1
    done
    local d
    for d in "$state_base"/shpool/*(N/); do
      local name=${d:t}
      if echo "$shpool_live" | grep -qxF "$name"; then
        (( skipped++ ))
        continue
      fi
      local dir="$(cat "$d/dir" 2>/dev/null)"
      [[ -d "$dir" ]] || dir=$HOME
      timeout 5 shpool attach --dir "$dir" --background "$name" && (( restored++ ))
    done
  fi

  local d
  for d in "$state_base"/zmx/*(N/) "$state_base"/shpool/*(N/); do
    [[ $(find "$d/dir" -mtime +30 2>/dev/null) ]] || continue
    local name=${d:t} tool=${d:h:t}
    rm -rf "$d"
    [[ "$tool" == zmx ]] && rm -f "$state_base/zmx-scrollback/$name.txt"
    (( pruned++ ))
  done

  if (( ! quiet || restored + pruned > 0 )); then
    echo "session-restore: restored=$restored skipped=$skipped pruned=$pruned"
  fi
  exec {_sr_fd}>&-
}

session-forget() {
  local tool="$1" name="$2"
  if [[ -z "$tool" || -z "$name" ]]; then
    echo "Usage: session-forget <zmx|shpool> <name>"; return 1
  fi
  [[ "$tool" == zmx || "$tool" == shpool ]] || { echo "tool must be zmx or shpool"; return 1; }
  [[ "$name" == */* ]] && { echo "invalid session name"; return 1; }
  local state_base="${XDG_STATE_HOME:-$HOME/.local/state}/sessions"
  rm -rf "$state_base/$tool/$name"
  [[ "$tool" == zmx ]] && rm -f "$state_base/zmx-scrollback/$name.txt"
  echo "Forgot $tool session: $name"
}

_session-forget() {
  if (( CURRENT == 2 )); then
    compadd zmx shpool
  elif (( CURRENT == 3 )); then
    local tool=$words[2]
    local state_base="${XDG_STATE_HOME:-$HOME/.local/state}/sessions"
    compadd -- "$state_base/$tool"/*(N/:t)
  fi
}
compdef _session-forget session-forget

zmk() {
  local name
  name=$(zmx list --short | fzf --prompt='kill> ' --no-select-1 --no-exit-0) || return
  zmx kill "$name" 2>/dev/null && session-forget zmx "$name" 2>/dev/null
}

# Restore sessions once per boot. XDG_RUNTIME_DIR is tmpfs,
# so the flag file is absent after reboot.
_session_restore_once() {
  local flag="${XDG_RUNTIME_DIR}/.sessions-restored"
  [[ -f "$flag" ]] && return
  [[ -d "${XDG_RUNTIME_DIR}" ]] || return
  touch "$flag"
  session-restore -q
}
add-zsh-hook precmd _session_restore_once

# -- Terminal resilience --
# TUI programs (Bubble Tea, neovim, etc.) enable terminal modes
# via escape sequences. If the program crashes or SSH drops, the
# cleanup sequences never fire and the local shell is left with
# broken keybinds, mouse reporting, or garbled input. These
# named sequences, hooks, and wrappers recover from that.
#
# References:
#   Kitty keyboard protocol: https://sw.kovidgoyal.net/kitty/keyboard-protocol/
#   Known leak reports: claude-code #39153, bubbletea #1014

# Named escape sequences for terminal mode resets.
# Each disables one mode that TUI programs commonly enable.
_seq_kitty_keyboard_pop='\e[<99u'
_seq_mouse_button_off='\e[?1000l'
_seq_mouse_any_off='\e[?1003l'
_seq_mouse_sgr_off='\e[?1006l'
_seq_bracketed_paste_off='\e[?2004l'
_seq_focus_reporting_off='\e[?1004l'
_seq_sync_output_off='\e[?2026l'
_seq_altscreen_off='\e[?1049l'
_seq_soft_reset='\e[!p'
_seq_cursor_shape_reset='\e[0 q'

# Precmd subset: only modes that zsh does not re-enable itself.
# Excludes bracketed paste (zsh manages it) and alternate screen
# (switching screens on every prompt would flash).
_terminal_sanitize_seq="$_seq_kitty_keyboard_pop$_seq_mouse_button_off$_seq_mouse_any_off$_seq_mouse_sgr_off$_seq_focus_reporting_off$_seq_sync_output_off"

# Full reset: all leaky modes. Used after SSH and in treset.
_terminal_reset_seq="$_seq_kitty_keyboard_pop$_seq_mouse_button_off$_seq_mouse_any_off$_seq_mouse_sgr_off$_seq_focus_reporting_off$_seq_sync_output_off$_seq_bracketed_paste_off$_seq_soft_reset$_seq_cursor_shape_reset"

# Minimum seconds connected before treating exit 255 as an
# involuntary disconnect worth notifying about. Below this
# threshold, exit 255 is likely an auth failure or config error.
_ssh_notify_min_seconds=5

_terminal_sanitize() {
  printf "$_terminal_sanitize_seq"
}
add-zsh-hook precmd _terminal_sanitize

treset() {
  printf "$_terminal_reset_seq"
  printf "$_seq_altscreen_off"
  stty sane 2>/dev/null
  echo "terminal reset complete"
}

ssh() {
  local start=$SECONDS
  command ssh "$@"
  local ret=$?
  local elapsed=$(( SECONDS - start ))

  printf "$_terminal_reset_seq"
  stty sane 2>/dev/null

  local duration
  if (( elapsed >= 3600 )); then
    duration="$(( elapsed / 3600 ))h$(( (elapsed % 3600) / 60 ))m"
  elif (( elapsed >= 60 )); then
    duration="$(( elapsed / 60 ))m$(( elapsed % 60 ))s"
  else
    duration="${elapsed}s"
  fi

  if (( ret == 0 )); then
    printf '\e[2m[ssh] disconnected cleanly after %s\e[0m\n' "$duration"
  elif (( ret == 255 )); then
    printf '\e[31m[ssh] connection lost after %s (exit 255)\e[0m\n' "$duration"
    # -group replaces any existing notification with the same ID,
    # so simultaneous ControlMaster session drops collapse into one.
    if (( elapsed > _ssh_notify_min_seconds )) && command -v terminal-notifier &>/dev/null; then
      terminal-notifier \
        -title "SSH disconnected" \
        -message "Lost connection after $duration" \
        -group "ssh-disconnect" \
        -sound Basso &>/dev/null &!
    fi
  else
    printf '\e[33m[ssh] exited with code %d after %s\e[0m\n' "$ret" "$duration"
  fi

  return $ret
}

function _title_name() {
  if [[ "$PWD" == "$HOME" ]]; then
    echo "~"
  elif git rev-parse --is-inside-work-tree &>/dev/null; then
    basename "$(git rev-parse --show-toplevel)"
  elif [[ "$PWD" == "/" ]]; then
    echo "/"
  else
    echo "${PWD##*/}"
  fi
}

function _title_set() {
  [[ -n "$TMUX" ]] && return
  if [[ -n "$SHPOOL_SESSION_NAME" ]]; then
    print -n "\e]0;⚡ ${SHPOOL_SESSION_NAME}\a"
  elif [[ -n "$ZMX_SESSION" ]]; then
    print -n "\e]0;⚡ ${ZMX_SESSION}\a"
  elif [[ -n "$SSH_CONNECTION" ]]; then
    print -n "\e]0;🌐 ${1}\a"
  else
    print -n "\e]0;${1}\a"
  fi
}

function _title_precmd()  { _title_set "$(_title_name)" }
function _title_preexec() { _title_set "${1[(wr)^(*=*|sudo|ssh|mosh|-*)]}" }

add-zsh-hook precmd  _title_precmd
add-zsh-hook preexec _title_preexec
