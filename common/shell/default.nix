{
  config,
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
          switchCmd = if pkgs.stdenv.isDarwin then "sudo darwin-rebuild switch" else "home-manager switch";
        in
        # bash
        ''
          ghauth
          nix flake update --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN"
          ${switchCmd} --flake ~/.config/nix#$_NIX_HOSTNAME --option access-tokens "github.com=$GITHUB_TOKEN"
          rm -rf "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh-eval"
          zsource
        '';
      v = "nvim";
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
        name = "zsh-auto-notify";
        file = "auto-notify.plugin.zsh";
        src = inputs.zsh-auto-notify;
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
      {
        name = "omz-git";
        file = "plugins/git/git.plugin.zsh";
        src = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
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
        # zsh-auto-notify
        AUTO_NOTIFY_IGNORE+=("navi" "lazygit" "fg" "tmux" "fzf")

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

        local P10K_PATH="''${ZDOTDIR:-~}/.p10k.zsh"

        [[ ! -f "$P10K_PATH" ]] || source "$P10K_PATH"
      ''
    ];
  };

  home.packages = with pkgs; [ nix-your-shell ];

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
    dircolors = {
      enable = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = false;
      mise.enable = true;
      nix-direnv.enable = true;
    };
    direnv-instant = {
      enable = true;
    };
    fish = {
      enable = true;
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
