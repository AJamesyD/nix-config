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
      nix-clean =
        let
          cleanCmd =
            if pkgs.stdenv.isDarwin then
              "sudo nh clean all --keep 5 --keep-since 14d"
            else
              "nh clean user --keep 5 --keep-since 14d";
        in
        # bash
        ''
          ${cleanCmd}
          nix store optimise 2>&1 | sed -E 's/.*'\'''(\/nix\/store\/[^\/]*).*'\'''/\1/g' | uniq | sudo ${pkgs.parallel}/bin/parallel --will-cite '${pkgs.nix}/bin/nix store repair {}'
        '';
      nixswitch =
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
          ${switchCmd} ~/.config/nix -- --option access-tokens "github.com=$GITHUB_TOKEN" || return 1
          rm -rf "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh-eval"
          zsource
        '';
      nixup = # bash
        ''
          ghauth
          nix flake update --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN" || return 1
          nixswitch
        '';
      v = "nvim";
      gu = "gitui";
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
          # Invalidated by nixswitch (which clears the cache dir before zsource).
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
      (lib.mkOrder 549 (builtins.readFile ./compinit.zsh))
      (lib.mkOrder 550
        # bash
        ''
          fpath+=(${zshcompdir})

          # zsh-vi-mode. Following must exist before sourcing plugin
          local ZVM_INIT_MODE=sourcing
        ''
      )
      (
        builtins.readFile ./zshrc-prefix.zsh
        + ''
          _cache_eval batman ${pkgs.bat-extras.batman}/bin/batman --export-env

          # Requires nix-output-monitor
          _cache_eval nix-your-shell ${pkgs.nix-your-shell}/bin/nix-your-shell --nom zsh

        ''
        + builtins.readFile ./zshrc-main.zsh
      )
      # Override atuin's unconditional prepend to put history suggestions first
      (lib.mkAfter "ZSH_AUTOSUGGEST_STRATEGY=(history completion atuin)")
    ];
  };

  home.packages = with pkgs; [ nix-your-shell ];

  xdg.configFile."zsh/.p10k.zsh".source = pkgs.replaceVars ./p10k.zsh { hostLabel = hostName; };

  # NOTE: xdg.configFile (not programs.direnv.stdlib) because stdlib writes to
  #   direnvrc, which loads before lib/hm-nix-direnv.sh defines use_flake.
  #   The zz- prefix ensures this loads after nix-direnv.
  xdg.configFile."direnv/lib/zz-nix-direnv-fixes.sh".text = builtins.readFile ./direnv-fixes.sh;

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
        # HACK: skip all tests because ctrl_c_cancels_direnv_in_non_mux_mode
        #   panics in the nix sandbox (no real terminal). Remove when upstream
        #   gates that test on $IN_NIX_SANDBOX or similar.
        doCheck = false;
      });
    };
    fzf = {
      # TODO: Alt-C keymap conflict with Aerospace. Use Meh and Hyper keys there
      enable = true;
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
