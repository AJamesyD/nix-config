{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./tmux.nix
  ];

  home = {
    packages = with pkgs; [
      netcat-gnu
      libnotify
      (pkgs.callPackage ../pkgs/bins { })

      rustup
      (lib.hiPrio rust-analyzer)

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
      bashrcExtra = ''
        if [ -f /etc/bashrc ]; then
          . /etc/bashrc
        fi
      '';
      profileExtra = ''
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
        ghauth = ''
          unset GITHUB_TOKEN &&
          export GITHUB_TOKEN="$(gh auth token)"''; # Cannot have newline at end of command or else it won't be chainable
        v = "nvim";
        clip = "cargo clippy -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";
        clipfix = "cargo clippy --fix --allow-dirty --allow-staged -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";
        mup = ''
          mise plugin install node ssh://git.amazon.com/pkg/RtxNode &&
          mise plugin install https://github.com/jdx/mise-usage.git &&
          mise prune &&
          mise install &&
          mise upgrade'';
        vup = ''
          CURR_DIR="$(pwd)" &&
          cd ~/.config/nvim &&
          (git restore lazy-lock.json && git pull -r || git rebase --abort);
          nvim --headless "Lazy! update" "+qa ";
          cd $CURR_DIR &&
          unset CURR_DIR'';
        zja = ''
          zellij a "$(zellij list-sessions --no-formatting --short | fzf --prompt='attach> ')"
        '';
        zjd = ''
          zellij delete-session "$(zellij list-sessions --no-formatting --short | fzf --prompt='delete> ')"
        '';
        zsource = "source ${config.programs.zsh.dotDir}/.zshrc && source ${config.programs.zsh.dotDir}/.zshenv";
      };
      plugins = [
        {
          name = "zsh-auto-notify";
          file = "auto-notify.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "MichaelAquilina";
            repo = "zsh-auto-notify";
            rev = "0.10.1";
            hash = "sha256-l5nXzCC7MT3hxRQPZv1RFalXZm7uKABZtfEZSMdVmro=";
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
      initExtraFirst = ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      initExtraBeforeCompInit = ''
        fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)
      '';
      initExtra = ''
        bindkey "^[[1;3D" backward-word
        bindkey "^[[1;3C" forward-word

        bindkey "^[[1;9D" beginning-of-line
        bindkey "^[[1;9C" end-of-line

        bindkey "^[[3;9~" kill-line

        bindkey "^[[3;3~" kill-word

        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '';
      envExtra = ''
        export XDG_CONFIG_HOME="$HOME/.config"
      '';
    };
  };
  xdg = {
    enable = true;
  };
}
