{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./tmux.nix
  ];

  home = {
    activation = {
      envSetup =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
          ] # bash
          ''
            export PATH="$PATH:${lib.concatStringsSep ":" config.home.sessionPath}"
            export PATH="$PATH:${config.home.profileDirectory}/bin"
          '';
      mise =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "envSetup"
          ]
          # bash
          (
            lib.optionalString (!pkgs.stdenv.isDarwin) ''
              run --quiet mise plugin install node ssh://git.amazon.com/pkg/RtxNode
            ''
            + ''
              run --quiet mise plugin install https://github.com/jdx/mise-usage.git
              run --quiet mise install
              run --quiet mise upgrade
              run --quiet mise prune
            ''
          );
      neovim =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "envSetup"
          ] # bash
          ''
            run --quiet nvim --headless -c "Lazy! update" -c "qa";
          '';
    };
    extraActivationPath = with pkgs; [
      curl
    ];
    packages = with pkgs; [
      netcat-gnu
      libnotify
      (pkgs.callPackage ../pkgs/bins { })

      rustup
      (lib.hiPrio rust-analyzer)

      devenv
      cachix
      nix-update
      nixfmt-rfc-style

      lua
      luajitPackages.luarocks
      neovim

      dust
      # TODO: Renable once I figure out why this breaks CargoBrazil
      # (rustPlatform.buildRustPackage rec {
      #   pname = "ion-cli";
      #   version = "v0.7.0";
      #
      #   src = fetchFromGitHub {
      #     owner = "amazon-ion";
      #     repo = pname;
      #     rev = version;
      #     sha256 = "sha256-b9ZUp3ES6yJZ/YPU2kFoGHUz/HcBr+x60DwCe1Y8Z/E=";
      #   };
      #   cargoHash = "sha256-vY9F+DP3Mfr3zUi3Pyu8auDleqQ1KDT5PpfwdnWUVX8=";
      #   doCheck = false;
      # })
      (pkgs.fetchFromGitHub {
        owner = "jdx";
        repo = "usage";
        rev = "v0.7.4";
        sha256 = "sha256-uOYSWum7I64fRi47pYugcl1AM+PgK3LfXTlO5fJshMQ=";
      })
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  programs = {
    bash = {
      enable = true;
      enableVteIntegration = pkgs.stdenv.isLinux;
      bashrcExtra = # bash
        ''
          if [ -f /etc/bashrc ]; then
            . /etc/bashrc
          fi
        '';
      profileExtra = # bash
        ''
          if [ -f /etc/profile ]; then
            . /etc/profile
          fi
        '';
    };
    bat = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza = {
      enable = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
        "--icons=auto"
      ];
    };
    fd = {
      enable = true;
    };
    fzf = {
      enable = true;
      tmux = {
        enableShellIntegration = true;
      };
    };
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    git = {
      enable = true;
      delta = {
        enable = true;
        options = {
          dark = true;
          navigate = true;
        };
      };
      lfs = {
        enable = true;
      };
      aliases = {
        dag = "log --graph --format='format:%C(yellow)%h%C(reset) %C(blue)\"%an\" <%ae>%C(reset) %C(magenta)%cr%C(reset)%C(auto)%d%C(reset)%n%s' --date-order";
      };
      extraConfig = {
        branch = {
          sort = "-committerdate";
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "default";
          colorMovedWS = "allow-indentation-change";
        };
        merge = {
          conflictstyle = "zdiff3";
          tool = "nvim";
        };
        push = {
          autoSetupRemote = true;
        };
        rerere = {
          enabled = true;
        };
        submodule = {
          recurse = true;
        };
      };
    };
    go = {
      enable = true;
    };
    htop = {
      enable = true;
    };
    java = {
      enable = true;
    };
    jq = {
      enable = true;
    };
    lazygit = {
      enable = true;
      settings = {
        mouseEvents = false;
        expandFocusedSidePanel = true;
        nerdFontsVersion = "3";
        showDivergenceFromBaseBranch = "onlyArrow";
        git = {
          mainBranches = [
            "main"
            "mainline"
            "master"
          ];
        };
        update.method = "background";
        notARepository = "quit";
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
    mise = {
      enable = true;
      globalConfig = {
        plugins = {
          usage = "https://github.com/jdx/mise-usage.git";
        };
        tools = {
          python = [
            "3.8"
            "3.9"
            "3.10"
            "3.11"
            "3.12"
          ];
          usage = [
            "latest"
          ];
        };
      };
      settings = {
        experimental = true;
        legacy_version_file = false;
        pipx_uvx = true;
        yes = true;
      };
    };
    ripgrep = {
      enable = true;
    };
    tealdeer = {
      enable = true;
      settings = {
        updates = {
          auto_update = true;
        };
      };
    };
    zellij = {
      enable = true;
    };
    zoxide = {
      enable = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = pkgs.stdenv.isLinux;
      autocd = true;
      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };
      dotDir = ".config/zsh";
      history = {
        expireDuplicatesFirst = true;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      historySubstringSearch.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        cargo-brazil-dry-run = "/apollo/env/bt-rust/bin/rust-customer-dry-runs";
        cat = "bat -p --paging=never";
        clr = "clear";
        ghauth = # bash
          ''
            unset GITHUB_TOKEN &&
            export GITHUB_TOKEN="$(gh auth token)"''; # Cannot have newline at end of command or else it won't be chainable
        v = "nvim";
        clip = "cargo clippy -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";
        clipfix = "cargo clippy --fix --allow-dirty --allow-staged -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";
        zja = # bash
          ''
            zellij a "$(zellij list-sessions --no-formatting --short | fzf --prompt='attach> ')"
          '';
        zjd = # bash
          ''
            zellij delete-session "$(zellij list-sessions --no-formatting --short | fzf --prompt='delete> ')"
          '';
        zsource = # bash
          ''
            source "$ZDOTDIR/.zshrc"
            source "$ZDOTDIR/.zshenv"
            omz reload'';
      };
      plugins = [
        {
          name = "zsh-auto-notify";
          file = "auto-notify.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "MichaelAquilina";
            repo = "zsh-auto-notify";
            rev = "27c07dddb42f05b199319a9b66473c8de7935856";
            hash = "sha256-ScBwky33leI8mFMpAz3Ng2Z0Gbou4EWMOAhkcMZAWIc=";
          };
        }
        {
          name = "zsh-you-should-use";
          file = "you-should-use.plugin.zsh";
          src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
        }
      ];
      oh-my-zsh = {
        enable = true;
        theme = "powerlevel10k";
        custom = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
        plugins = [
          "aws"
          "cp"
          "direnv"
          "fzf"
          "gh"
          "git"
          "git-auto-fetch"
          "brew"
          "mise"
          "rust"
          "zoxide"
        ];
      };
      initExtraFirst = # bash
        ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        '';
      initExtraBeforeCompInit = # bash
        ''
          fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)
        '';
      initExtra = # bash
        ''
          # zsh-auto-notify
          AUTO_NOTIFY_IGNORE+=("navi" "lazygit" "fg")

          # Beloved key-binds
          bindkey "^[[1;3D" backward-word
          bindkey "^[[1;3C" forward-word

          bindkey "^[[1;9D" beginning-of-line
          bindkey "^[[1;9C" end-of-line

          bindkey "^[[3;9~" kill-line

          bindkey "^[[3;3~" kill-word

          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        '';
      envExtra = # bash
        ''
          export XDG_CONFIG_HOME="$HOME/.config"
        '';
    };
  };
  xdg = {
    enable = true;
  };
}
