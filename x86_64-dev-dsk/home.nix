{
  config,
  lib,
  pkgs,
  ...
}:
let
  powerlevel10k_path = pkgs.fetchFromGitHub {
    owner = "romkatv";
    repo = "powerlevel10k";
    rev = "v1.20.0";
    sha256 = "1ha7qb601mk97lxvcj9dmbypwx7z5v0b7mkqahzsq073f4jnybhi";
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "angaidan";
  home.homeDirectory = "/home/angaidan";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

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
    neovim
    gh
    fd
    eza
    ripgrep
    bat
    fzf
    lazygit
    zellij
    rustup
    (lib.hiPrio rust-analyzer)
    nixfmt-rfc-style
    nix-prefetch-github
    git
    git-lfs
    nix-update
    zoxide
    xsel
    xclip
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
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager = {
      enable = true;
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
        auth = "mwinit -o && kinit -f";

        ghauth = ''
          unset GITHUB_TOKEN &&
          export GITHUB_TOKEN="$(gh auth token)"''; # Cannot have newline at end of command or else it won't be chainable
        zja = ''
          zellij a "$(zellij list-sessions --no-formatting --short | fzf --prompt='attach> ')"
        '';
        zjd = ''
          zellij delete-session "$(zellij list-sessions --no-formatting --short | fzf --prompt='delete> ')"
        '';

        v = "nvim";

        clip = "cargo clippy -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";
        clipfix = "cargo clippy --fix --allow-dirty --allow-staged -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";

        zsource = "source ~/.zshrc";
        nixup = ''
          ghauth &&
          pushd ~/.config/home-manager &&
          sudo nix-channel --update --option access-tokens "github.com=$GITHUB_TOKEN" &&
          nix flake update --option access-tokens "github.com=$GITHUB_TOKEN" &&
          home-manager switch &&
          popd &&
          zsource''; # Cannot have newline at end of command or else it won't be chainable
        vup = ''
          pushd ~/.config/nvim &&
          (git restore lazy-lock.json && git pull -r || git rebase --abort);
          nvim --headless "Lazy! sync" "+qa ";
          popd'';
        up = "sudo yum upgrade -y && rustup update && nixup && vup && toolbox update";
        cargo-brazil-dry-run = "/apollo/env/bt-rust/bin/rust-customer-dry-runs";
      };
      oh-my-zsh = {
        enable = true;
        theme = "powerlevel10k";
        custom = "${powerlevel10k_path}";
        plugins = [
          "git"
          "gh"
          "fzf"
          "virtualenv"
          "zoxide"
          "aws"
          "rust"
          "mise"
        ];
      };
      initExtraFirst = ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      initExtra = ''
        bindkey "^[[1;9D" beginning-of-line
        bindkey "^[[1;9C" end-of-line
        bindkey "" backward-kill-line
        bindkey "^[[3;9~" kill-line
        bindkey "^[[3;3~" kill-word

        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '';
    };
    gh = {
      settings.git_protocol = "ssh";
    };
    zellij = {
      enableZshIntegration = true;
    };
  };
}
