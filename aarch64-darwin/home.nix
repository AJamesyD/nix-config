{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../aws.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "angaidan";
  home.homeDirectory = "/Users/angaidan";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    alacritty-theme
    (nerdfonts.override { fonts = [ "IBMPlexMono" ]; })
    neovim
    fd
    eza
    ripgrep
    bat
    fzf
    zellij
    rustup
    (lib.hiPrio rust-analyzer)
    nixfmt-rfc-style
    nix-update
    htop

    shfmt
    shellcheck

    go
    jdk
    typescript
    nodePackages.ts-node
    luajitPackages.luarocks
    (rustPlatform.buildRustPackage rec {
      pname = "ion-cli";
      version = "v0.7.0";

      src = fetchFromGitHub {
        owner = "amazon-ion";
        repo = pname;
        rev = version;
        sha256 = "sha256-b9ZUp3ES6yJZ/YPU2kFoGHUz/HcBr+x60DwCe1Y8Z/E=";
      };
      cargoHash = "sha256-vY9F+DP3Mfr3zUi3Pyu8auDleqQ1KDT5PpfwdnWUVX8=";
      doCheck = false;
    })
    (pkgs.callPackage ../pkgs/bins { })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    "${config.xdg.configHome}/aerospace/aerospace.toml" = {
      source = (pkgs.formats.toml { }).generate "aerospace.toml" (import ./aerospace.nix);
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/angaidan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    HOMEBREW_NO_ANALYTICS = 1;
  };

  launchd = {
    enable = true;
    agents = {
      pbcopy = {
        enable = true;
        config = {
          inetdCompatibility = {
            Wait = false;
          };
          KeepAlive = {
            Crashed = true;
            SuccessfulExit = false;
          };
          Label = "localhost.pbcopy";
          ProcessType = "Background";
          ProgramArguments = [ "/usr/bin/pbcopy" ];
          RunAtLoad = true;
          Sockets = {
            Listener = {
              SockNodeName = "127.0.0.1";
              SockServiceName = "2224";
            };
          };
        };
      };
      pbpaste = {
        enable = true;
        config = {
          inetdCompatibility = {
            Wait = false;
          };
          KeepAlive = {
            Crashed = true;
            SuccessfulExit = false;
          };
          Label = "localhost.pbpaste";
          ProcessType = "Background";
          ProgramArguments = [ "/usr/bin/pbpaste" ];
          RunAtLoad = true;
          Sockets = {
            Listener = {
              SockNodeName = "127.0.0.1";
              SockServiceName = "2225";
            };
          };
        };
      };
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager = {
      enable = true;
    };
    alacritty = {
      # TODO: Move to MacOS only config
      enable = true;
      settings = {
        import = [
          "${pkgs.alacritty-theme}/aura.toml"
        ];
        window = {
          decorations = "Full";
          option_as_alt = "Both";
          resize_increments = true;
        };
        font = {
          normal = {
            family = "BlexMono Nerd Font";
            style = "Regular";
          };
          size = 18.0;
        };
        colors = {
          selection = {
            background = "#5f5987"; # Make Aura theme selections easier to read
          };
        };
        cursor = {
          style = {
            blinking = "On";
            shape = "Beam";
          };
          vi_mode_style = {
            blinking = "Off";
            shape = "Underline";
          };
        };
        terminal = {
          osc52 = "CopyPaste";
        };
        keyboard.bindings = [
          {
            key = "Back";
            mods = "Command";
            chars = "";
          }
          {
            key = "t";
            mods = "Command";
            action = "CreateNewWindow";
          }
        ];
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
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
    mise = {
      enable = true;
      globalConfig = {
        tools = {
          node = [
            "lts-gallium" # v16
            "lts-hydrogen" # v18
            "20" # iron
          ];
          python = [
            "3.8"
            "3.9"
            "3.10"
            "3.11"
            "3.12"
          ];
        };
        settings = {
          legacy_version_file = false;
          yes = true;
        };
      };
    };
    zellij = {
      enableZshIntegration = true;
    };
    zoxide = {
      enable = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };
      history = {
        expireDuplicatesFirst = true;
      };
      syntaxHighlighting.enable = true;

      shellAliases = {
        ls = "eza --icons=auto";
        la = "ls -a";
        ll = "ls -lah";

        cat = "bat -p --paging=never";

        zja = ''
          zellij a "$(zellij list-sessions --no-formatting --short | fzf --prompt='attach> ')"
        '';
        zjd = ''
          zellij delete-session "$(zellij list-sessions --no-formatting --short | fzf --prompt='delete> ')"
        '';

        v = "nvim";

        clip = "cargo clippy -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";
        clipfix = "cargo clippy --fix --allow-dirty --allow-staged -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";

        zsource = "source ~/.zshrc && source ~/.zshenv";
        ghauth = ''
          unset GITHUB_TOKEN &&
          export GITHUB_TOKEN="$(gh auth token)"''; # Cannot have newline at end of command or else it won't be chainable
        nixup = ''
          CURR_DIR="$(pwd)" &&
          cd ~/.config/nix
          ghauth &&
          nix-channel --update --option access-tokens "github.com=$GITHUB_TOKEN" &&
          nix flake update --option access-tokens "github.com=$GITHUB_TOKEN" &&
          darwin-rebuild switch --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN" &&
          zsource
          cd $CURR_DIR &&
          unset CURR_DIR''; # Cannot have newline at end of command or else it won't be chainable
        vup = ''
          CURR_DIR="$(pwd)" &&
          cd ~/.config/nvim &&
          (git restore lazy-lock.json && git pull -r || git rebase --abort);
          nvim --headless "Lazy! sync" "+qa ";
          cd $CURR_DIR &&
          unset CURR_DIR'';
        up = "rustup update && nixup && vup";
      };
      oh-my-zsh = {
        enable = true;
        theme = "powerlevel10k";
        custom = "${pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "v1.20.0";
          sha256 = "1ha7qb601mk97lxvcj9dmbypwx7z5v0b7mkqahzsq073f4jnybhi";
        }}";
        extraConfig = ''
          zstyle ':omz:plugins:eza' 'dirs-first' yes
          zstyle ':omz:plugins:eza' 'header' yes
          zstyle ':omz:plugins:eza' 'icons' yes
        '';
        plugins = [
          "aws"
          "cp"
          "eza"
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
