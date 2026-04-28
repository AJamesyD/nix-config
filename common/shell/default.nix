{
  config,
  hostName,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  zshcompdir = "${config.programs.zsh.dotDir}/completion/";
in
{
  imports = [ inputs.direnv-instant.homeModules.direnv-instant ];

  programs.zsh = {
    enable = true;
    # Puts mise shims on PATH in .zprofile (login shell) so GUI apps
    # (Neovide, etc.) can find mise-managed tools like npm/node.
    profileExtra = ''
      eval "$(mise activate zsh --shims)"
    '';
    # Disabled — we provide a cached compinit at mkOrder 549 that uses
    # compinit -C (skip security check + fpath scan) on most loads and only
    # runs a full compinit when the dump is older than 24 hours.
    enableCompletion = false;
    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      append = true;
    };
    setOptions = [
      "HIST_REDUCE_BLANKS"
      "HIST_VERIFY"
      "NO_BEEP"
    ];
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      cat = "bat -pp";
      clip = "cargo clippy -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";
      clipfix = "cargo clippy --fix --allow-dirty --allow-staged -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";
      clr = "clear";
      ghauth = # bash
        ''
          unset GITHUB_TOKEN
          export GITHUB_TOKEN="$(gh auth token)"
        '';
      nix-clean = # bash
        ''
          nix-collect-garbage --delete-older-than 5d
          nix store optimise 2>&1 | sed -E 's/.*'\'''(\/nix\/store\/[^\/]*).*'\'''/\1/g' | uniq | sudo ${pkgs.parallel}/bin/parallel --will-cite '${pkgs.nix}/bin/nix store repair {}'
        '';
      nixup =
        let
          switchCmd =
            if pkgs.stdenv.isDarwin then
              "nh darwin switch"
            else
              "nh home switch --configuration \"$_NIX_HOSTNAME\"";
        in
        # bash
        ''
          ghauth
          nix flake update --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN"
          ${switchCmd} ~/.config/nix -- --option access-tokens "github.com=$GITHUB_TOKEN"
          rm -rf "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh-eval"
          zsource
        '';
      v = "nvim";
      gu = "gitui";
      zma = # bash
        ''
          zmx attach "$(zmx list --short | fzf --prompt='attach> ' --no-select-1 --no-exit-0)" 2>/dev/null
        '';
      zsource = # bash
        ''
          source "$ZDOTDIR/.zshenv"
          source "$ZDOTDIR/.zshrc"''; # Cannot have newline at end of command or else it won't be chainable
    };
    plugins = [
      # zsh-vi-mode must come first to avoid overriding other keymaps
      {
        name = "zsh-vi-mode";
        file = "zsh-vi-mode.plugin.zsh";
        src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      }
      {
        name = "zsh-you-should-use";
        file = "you-should-use.plugin.zsh";
        src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
      }
      {
        name = "powerlevel10k";
        file = "powerlevel10k.zsh-theme";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      (lib.mkOrder 548
        # bash
        ''
          # PERF: cache eval output from tools whose init is static between rebuilds.
          # Invalidated by nixup (which clears the cache dir before zsource).
          _cache_eval() {
            local name=$1; shift
            local cache="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh-eval/$name.zsh"
            if [[ ! -f "$cache" ]]; then
              mkdir -p "''${cache:h}"
              "$@" > "$cache"
            fi
            source "$cache"
          }
        ''
      )
      (lib.mkOrder 549
        # bash
        ''
          # PERF: compinit is expensive (~1.4s with ~3000 completions).
          # Full compinit once per day; -C (cached, skip security check) otherwise.
          autoload -U compinit
          () {
            setopt local_options extendedglob
            if [[ -n ''${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
              compinit
            else
              compinit -C
            fi
          }
          # Background-compile the dump for faster future loads
          {
            if [[ -s "''${ZDOTDIR}/.zcompdump" && (! -s "''${ZDOTDIR}/.zcompdump.zwc" || "''${ZDOTDIR}/.zcompdump" -nt "''${ZDOTDIR}/.zcompdump.zwc") ]]; then
              zcompile "''${ZDOTDIR}/.zcompdump"
            fi
          } &!
        ''
      )
      (lib.mkOrder 550
        # bash
        ''
          fpath+=(${zshcompdir})

          # zsh-vi-mode. Following must exist before sourcing plugin
          local ZVM_INIT_MODE=sourcing
        ''
      )
      # bash
      ''
        WORDCHARS=''${WORDCHARS//[\/.]}
        REPORTTIME=10

        # Beloved key-binds
        bindkey "^[[1;3D" backward-word
        bindkey "^[[1;3C" forward-word

        bindkey "^[[1;9D" beginning-of-line
        bindkey "^[[1;9C" end-of-line

        bindkey "^[[3;9~" kill-line

        bindkey "^[[3;3~" kill-word

        _cache_eval batman ${pkgs.bat-extras.batman}/bin/batman --export-env

        # Requires nix-output-monitor
        _cache_eval nix-your-shell ${pkgs.nix-your-shell}/bin/nix-your-shell --nom zsh

        if command -v zmx &>/dev/null; then
          _cache_eval zmx zmx completions zsh

          zmx-select() {
            local display
            display=$(zmx list 2>/dev/null | while IFS=$'\t' read -r name pid clients created dir; do
              name=''${name#session_name=}
              pid=''${pid#pid=}
              clients=''${clients#clients=}
              dir=''${dir#started_in=}
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
          local query="''$1"
          setopt local_options no_nomatch
          local search_paths=(
            /tmp/ai-research-*
            /tmp/ai-plan-*
            /tmp/ai-design-*
            "''$HOME/Documents/research"
          )
          local existing_paths=()
          for p in "''${search_paths[@]}"; do
            [[ -e ''$p ]] && existing_paths+=("''$p")
          done
          [[ ''${#existing_paths[@]} -eq 0 ]] && { echo "No research files found"; return 1; }
          if [[ -n "''$query" ]]; then
            rg --no-heading --line-number --color=always "''$query" "''${existing_paths[@]}" | \
              fzf --ansi --delimiter=: --preview='bat --color=always --highlight-line {2} {1}' --preview-window='+{2}-10'
          else
            rg --no-heading --line-number --color=always '.' "''${existing_paths[@]}" | \
              fzf --ansi --delimiter=: --preview='bat --color=always --highlight-line {2} {1}' --preview-window='+{2}-10'
          fi
        }

        local P10K_PATH="''${ZDOTDIR:-~}/.p10k.zsh"

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
          local state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/sessions/$tool/$name"
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
          local d="''${XDG_STATE_HOME:-$HOME/.local/state}/sessions/zmx-scrollback"
          local f="$d/$ZMX_SESSION.txt"
          [[ -d "$d" ]] || mkdir -p "$d"
          timeout 5 zmx history "$ZMX_SESSION" | tail -n "''${SESSION_PERSIST_SCROLLBACK_LINES:-10000}" > "$f.tmp" && mv "$f.tmp" "$f"
        }
        [[ -n "$PERIOD" ]] || PERIOD=300
        add-zsh-hook periodic _session_persist_scrollback

        session-restore() {
          local state_base="''${XDG_STATE_HOME:-$HOME/.local/state}/sessions"
          local quiet=0
          [[ "$1" == -q ]] && { quiet=1; shift; }
          [[ -d "''${XDG_RUNTIME_DIR}" ]] || { echo "XDG_RUNTIME_DIR not set"; return 1; }
          exec {_sr_fd}>"''${XDG_RUNTIME_DIR}/session-restore.lock"
          flock -n $_sr_fd || { exec {_sr_fd}>&-; echo "session-restore already running"; return 1; }
          local restored=0 skipped=0 pruned=0

          if command -v zmx &>/dev/null; then
            local zmx_live
            zmx_live=$(zmx list --short 2>/dev/null)
            local d
            for d in "$state_base"/zmx/*(N/); do
              local name=''${d:t}
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
              local name=''${d:t}
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
            local name=''${d:t} tool=''${d:h:t}
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
          local state_base="''${XDG_STATE_HOME:-$HOME/.local/state}/sessions"
          rm -rf "$state_base/$tool/$name"
          [[ "$tool" == zmx ]] && rm -f "$state_base/zmx-scrollback/$name.txt"
          echo "Forgot $tool session: $name"
        }

        _session-forget() {
          if (( CURRENT == 2 )); then
            compadd zmx shpool
          elif (( CURRENT == 3 )); then
            local tool=$words[2]
            local state_base="''${XDG_STATE_HOME:-$HOME/.local/state}/sessions"
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
          local flag="''${XDG_RUNTIME_DIR}/.sessions-restored"
          [[ -f "$flag" ]] && return
          [[ -d "''${XDG_RUNTIME_DIR}" ]] || return
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
            duration="''${elapsed}s"
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
            echo "''${PWD##*/}"
          fi
        }

        function _title_set() {
          [[ -n "$TMUX" ]] && return
          if [[ -n "$SHPOOL_SESSION_NAME" ]]; then
            print -n "\e]0;⚡ ''${SHPOOL_SESSION_NAME}\a"
          elif [[ -n "$ZMX_SESSION" ]]; then
            print -n "\e]0;⚡ ''${ZMX_SESSION}\a"
          elif [[ -n "$SSH_CONNECTION" ]]; then
            print -n "\e]0;🌐 ''${1}\a"
          else
            print -n "\e]0;''${1}\a"
          fi
        }

        function _title_precmd()  { _title_set "$(_title_name)" }
        function _title_preexec() { _title_set "''${1[(wr)^(*=*|sudo|ssh|mosh|-*)]}" }

        add-zsh-hook precmd  _title_precmd
        add-zsh-hook preexec _title_preexec
      ''
      # Override atuin's unconditional prepend to put history suggestions first
      (lib.mkAfter "ZSH_AUTOSUGGEST_STRATEGY=(history completion atuin)")
    ];
  };

  home.packages = with pkgs; [ nix-your-shell ];

  xdg.configFile."zsh/.p10k.zsh".source = pkgs.replaceVars ./p10k.zsh { hostLabel = hostName; };

  home.activation.envSetup =
    lib.hm.dag.entryAfter
      [
        "writeBoundary"
      ]
      (
        # bash
        ''
          export ZDOTDIR="${config.programs.zsh.dotDir}"
          export ZCOMPDIR="${zshcompdir}"
          mkdir -p $ZCOMPDIR

          export PATH="$PATH:${lib.concatStringsSep ":" config.home.sessionPath}"
          export PATH="$PATH:${config.home.profileDirectory}/bin"
          export PATH="$PATH:/usr/bin"
          export PATH="$PATH:${config.home.homeDirectory}/.toolbox/bin"
        ''
        +
          lib.strings.optionalString pkgs.stdenv.isDarwin # bash
            ''
              export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
            ''
      );

  # since zsh.dotDir is set, still create ~/.zshrc so that it is write-protected against
  # random programs trying to append to it
  home.file = {
    ".zshrc" = {
      text = # bash
        ''
          # This file is intentionally empty.

          # When zsh.dotDir is set, still create ~/.zshrc so that it is write-protected against
          # random programs trying to append to it
        '';
    };
  };

  programs = {
    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        auto_sync = false;
        filter_mode = "directory";
        filter_mode_shell_up_key_binding = "directory";
        search_mode = "fuzzy";
        style = "compact";
        inline_height = 20;
      };
    };
    direnv = {
      enable = true;
      enableZshIntegration = false;
      mise.enable = true;
      nix-direnv.enable = true;
    };
    direnv-instant = {
      enable = true;
      package = (pkgs.callPackage "${inputs.direnv-instant}/default.nix" { }).overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ../../patches/direnv-instant-always-async.patch ];
      });
    };
    fzf = {
      # TODO: Alt-C keymap conflict with Aerospace. Use Meh and Hyper keys there
      enable = true;
      # defaultCommand = "fd --type f";
      defaultOptions = [
        "--height 40%"
        "--border"
        "--inline-info"
        "--reverse"
      ];
      changeDirWidgetCommand = "fd --type d";
      changeDirWidgetOptions = [
        "--walker-skip .git,node_modules,target"
        "--preview 'tree -C {} | head -200'"
      ];
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [
        "--walker-skip .git,node_modules,target"
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
        "--preview-window '75%,~3'"
        "--reverse"
      ];
      historyWidgetOptions = [
        "--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"
        "--color header:italic"
        "--header 'Press CTRL-Y to copy command into clipboard'"
        "--sort"
        "--exact"
      ];
      tmux = {
        enableShellIntegration = true;
      };
    };
    navi = {
      enable = true;
      settings = {
        finder = {
          command = "fzf";
          client = {
            tealdeer = true;
          };
        };
      };
    };
    zoxide = {
      enable = true;
    };
  };
}
