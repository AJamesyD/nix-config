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
      v = "nvim";
    };
    siteFunctions = {
      ghauth = # bash
        ''
          unset GITHUB_TOKEN
          GITHUB_TOKEN="$(gh auth token)" || {
          	echo "ghauth: gh auth token failed" >&2
          	return 1
          }
          export GITHUB_TOKEN
        '';
      # NOTE: nh self-elevates via sudo internally; no sudo prefix needed.
      #   `all` (system+user profiles) on darwin; `user` on linux because
      #   NFS+nosuid blocks sudo entirely on cloud desktops.
      nix-clean =
        let
          cleanCmd =
            if pkgs.stdenv.hostPlatform.isDarwin then
              "nh clean all --keep 5 --keep-since 14d"
            else
              "nh clean user --keep 5 --keep-since 14d";
        in
        # bash
        ''
          ${cleanCmd}
        '';
      nixswitch =
        let
          switchCmd =
            if pkgs.stdenv.hostPlatform.isDarwin then
              "nh darwin switch"
            else
              "nh home switch --configuration \"$_NIX_HOSTNAME\"";
        in
        # bash
        ''
          ghauth || return 1
          if [ ! -f "''${XDG_CONFIG_HOME:-$HOME/.config}/sops/age/keys.txt" ]; then
            echo "sops age key missing. Running bootstrap..."
            nix run ~/.config/nix#bootstrap || return 1
          fi
          ${switchCmd} ~/.config/nix -- --option access-tokens "github.com=$GITHUB_TOKEN" || return 1
          # Clear stale zcompdumps from prior ZDOTDIR layouts
          rm -f "''${ZDOTDIR}"/.zcompdump.*.*(N) "''${ZDOTDIR}"/.*.bak(N)
          zsource
        '';
      nixup = # bash
        ''
          ghauth || return 1
          nix flake update --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN" || return 1
          nixswitch
        '';
      # Replaces the current shell with a fresh login shell. Sourcing .zshrc
      # in-place is unsafe (double-registered hooks, PATH clobbering, hangs).
      # p10k renders a brief '}}' artifact on the first prompt due to stale
      # terminal state — cosmetic only, clears on next keypress.
      zsource = # bash
        ''
          exec zsh -l
        '';
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
          # Eval each tool's init directly (no on-disk cache): a cached snippet can
          # bake a store path that dangles after GC drops an old generation;
          # current-generation paths do not. _eval_init runs the generator and
          # evals its output only on exit 0, so a failed run can't inject a parse
          # error into the shell; the generator's stderr stays visible on purpose.
          _eval_init() { local out; out="$("$@")" && eval "$out"; }

          _eval_init ${pkgs.bat-extras.batman}/bin/batman --export-env

          _eval_init ${pkgs.zoxide}/bin/zoxide init zsh

        ''
        + builtins.readFile ./zshrc-main.zsh
      )
      # Override atuin's unconditional prepend to put history suggestions first
      (lib.mkAfter "ZSH_AUTOSUGGEST_STRATEGY=(history completion atuin)")
    ];
  };

  programs.nix-your-shell = {
    enable = true;
    enableZshIntegration = true;
    nix-output-monitor.enable = true;
  };

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
          lib.strings.optionalString pkgs.stdenv.hostPlatform.isDarwin # bash
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
      enable = true;
      enableZshIntegration = false;
      defaultOptions = [
        "--height 40%"
        "--border"
        "--inline-info"
        "--reverse"
      ];
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
      enableZshIntegration = false;
    };
  };
}
