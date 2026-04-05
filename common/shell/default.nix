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
          nix-collect-garbage -d
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
      zmk = # bash
        ''
          zmx kill "$(zmx list --short | fzf --prompt='kill> ' --no-select-1 --no-exit-0)" 2>/dev/null
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

        local P10K_PATH="''${ZDOTDIR:-~}/.p10k.zsh"

        [[ ! -f "$P10K_PATH" ]] || source "$P10K_PATH"

        autoload -Uz add-zsh-hook

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
