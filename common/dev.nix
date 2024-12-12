{
  config,
  lib,
  pkgs,
  ...
}:
let
  zdotdir =
    "${config.home.homeDirectory}/"
    + (
      if config.programs.zsh.dotDir != null then
        lib.escapeShellArg config.programs.zsh.dotDir + "/"
      else
        ""
    );
  zshcompdir = zdotdir + "completion/";
in
{
  imports = [
    ./tmux.nix
    ./zellij.nix
  ];

  editorconfig = {
    enable = true;
    settings = {
      # EditorConfig helps developers define and maintain consistent
      # coding styles between different editors and IDEs
      # EditorConfig is awesome: https://EditorConfig.org

      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_style = "space";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
      };

      # python
      "*.{ini,py,py.tpl,rst}" = {
        indent_size = 4;
      };

      # rust
      "*.rs" = {
        indent_size = 4;
      };

      # documentation, utils
      "*.{md,mdx,diff}" = {
        trim_trailing_whitespace = false;
      };

      # windows shell scripts
      "*.{cmd,bat,ps1}" = {
        end_of_line = "crlf";
      };
    };
  };

  home = {
    activation = {
      envSetup =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
          ]
          (
            # bash
            ''
              export ZDOTDIR="${zdotdir}"
              export ZCOMPDIR="${zshcompdir}"
              mkdir -p $ZCOMPDIR

              export PATH="$PATH:${lib.concatStringsSep ":" config.home.sessionPath}"
              export PATH="$PATH:${config.home.profileDirectory}/bin"
            ''
            +
              lib.strings.optionalString pkgs.stdenv.isDarwin # bash
                ''
                  export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
                ''
          );
      mise =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "envSetup"
          ]
          # bash
          ''
            # TODO: Uncomment when working again
            # run --quiet mise upgrade --yes --quiet
            run --quiet mise prune --yes --quiet
            run --quiet mise plugins update --yes --quiet
          '';
      rustup =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "envSetup"
          ] # bash
          ''
            run --quiet rustup toolchain install stable --component llvm-tools
            run --quiet rustup toolchain install nightly
            run --quiet rustup update
            run --quiet rustup completions zsh > "$ZCOMPDIR/_rustup"
            run --quiet rustup completions zsh cargo > "$ZCOMPDIR/_cargo"
          '';
    };
    extraActivationPath = with pkgs; [
      curl
      git
      git-lfs
      gnutar
      gzip
    ];
    packages = with pkgs; [
      (pkgs.callPackage ../pkgs/bins { })

      coreutils
      findutils
      gawk
      git
      git-lfs
      gnugrep
      gnused
      gnutar
      gnutls
      # required to make terminfo files available before zsh login
      (lib.hiPrio ncurses)
      neofetch
      pandoc
      netcat-gnu
      rsync
      squashfsTools

      cargo-nextest
      rustup
      (lib.hiPrio rust-analyzer)
      mdbook

      devenv
      cachix
      nixd
      nixfmt-rfc-style
      nix-output-monitor
      nix-update
      nix-your-shell

      (luajit.withPackages (
        ps: with ps; [
          luarocks
          luv
        ]
      ))
      neovim
      tree-sitter

      docker
      devpod

      dust
      # TODO: Figure out why having another cargo breaks CargoBrazil
      (rustPlatform.buildRustPackage rec {
        pname = "ion-cli";
        version = "v0.9.1";

        src = fetchFromGitHub {
          owner = "amazon-ion";
          repo = pname;
          rev = version;
          sha256 = "sha256-CA5eNkp1G07i90dnq6Ck/yukQ2BsUk57IFvIbxG/1Jo=";
        };
        cargoHash = "sha256-hpzKEcGK0aLA3PDV0n//rbVbmXgVAuoXSY3f2jyupaM=";
        doCheck = false;
      })

      gum
      (pkgs.fetchFromGitHub {
        owner = "jdx";
        repo = "usage";
        rev = "v0.7.4";
        sha256 = "sha256-uOYSWum7I64fRi47pYugcl1AM+PgK3LfXTlO5fJshMQ=";
      })
      libnotify
      sesh
    ];

    preferXdgDirectories = true;
    sessionPath = lib.mkAfter [
      "${config.xdg.dataHome}/bob/nvim-bin"
    ];
    sessionVariables = {
      EDITOR = "nvim";
      LESSHISTFILE = "${config.xdg.dataHome}/less_history";

      BACON_PREFS = "${config.xdg.configHome}/bacon/prefs.toml";
      # https://github.com/jdx/mise/issues/3099
      MISE_LIBGIT2 = "false";
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
    bacon = {
      enable = true;
      # XXX: TEMP workaround until bacon updated in nixpkgs
      package = pkgs.bacon.overrideAttrs (
        _: prev: rec {
          name = "bacon-${version}";
          version = "3.5.0";

          src = pkgs.fetchFromGitHub {
            owner = "Canop";
            repo = "bacon";
            rev = "refs/tags/v${version}";
            hash = "sha256-gfISv1a/6XBl5L/ywHqG0285tDOasucp8YbJeXrv6OA=";
          };

          cargoDeps = prev.cargoDeps.overrideAttrs (
            lib.const {
              inherit src;
              outputHash = "sha256-kYNIZsubPRa0FMF8w0sjVrHH10WSjFt7ClvT03sreJg=";
            }
          );
        }
      );
      settings = {
        # prefs.toml
        exports = {
          locations = {
            auto = true;
            line_format = "{kind}:{path}:{line}:{column}:{message}{context}";
          };
        };
        # default bacon.toml
        default_job = "clippy-all";
        jobs = {
          check = {
            command = [
              "cargo"
              "check"
              "--message-format"
              "json-diagnostic-rendered-ansi"
            ];
          };
          check-all = {
            command = [
              "cargo"
              "check"
              "--all-targets"
              "--message-format"
              "json-diagnostic-rendered-ansi"
            ];
          };
          clippy-all = {
            command = [
              "cargo"
              "clippy"
              "--all-targets"
              "--message-format"
              "json-diagnostic-rendered-ansi"
              "--"
              "-A"
              "clippy::style"
            ];
            ignore = [ "build/" ];
            need_stdout = false;
          };
        };
      };
    };
    bash = {
      enable = true;
      enableVteIntegration = pkgs.stdenv.isLinux;
      bashrcExtra = # bash
        ''
          if [ -f /etc/bashrc ]; then
            . /etc/bashrc
          fi

          # SSH for use with ControlMaster
          local CONST_SSH_SOCK="$HOME/.ssh/ssh-auth-sock"
          if [ ! -z ''${SSH_AUTH_SOCK+x} ] && [ "$SSH_AUTH_SOCK" != "$CONST_SSH_SOCK" ]; then
            rm -f "$CONST_SSH_SOCK"
            ln -sf "$SSH_AUTH_SOCK" "$CONST_SSH_SOCK"
            export SSH_AUTH_SOCK="$CONST_SSH_SOCK"
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
      config = {
        theme = "tokyonight-night";
      };
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batgrep
        batman
        batpipe
      ];
      themes = {
        tokyonight-night = {
          src = pkgs.fetchFromGitHub {
            owner = "folke";
            repo = "tokyonight.nvim";
            rev = "v4.8.0";
            sha256 = "sha256-5QeY3EevOQzz5PHDW2CUVJ7N42TRQdh7QOF9PH1YxkU=";
          };
          file = "extras/sublime/tokyonight_night.tmTheme";
        };
      };
    };
    bottom = {
      enable = true;
    };
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };
    dircolors = {
      enable = true;
    };
    direnv = {
      enable = true;
      mise.enable = true;
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
      ignores = [
        ".git/"
      ];
    };
    fzf = {
      # TODO: Alt-C keymap conflict with Aerospace. Use Meh and Hyper keys there
      enable = true;
      defaultCommand = "fd --type f";
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
        init = {
          defaultBranch = "mainline";
        };
        merge = {
          conflictstyle = "zdiff3";
          tool = "nvim";
        };
        pull = {
          rebase = true;
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
    helix = {
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
        os.editPreset = "nvim-remote";
        notARepository = "quit";
      };
    };
    less = {
      enable = true;
    };
    lesspipe = {
      enable = true;
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
    man = {
      enable = true;
      generateCaches = true;
    };
    mise = {
      enable = true;
      globalConfig = {
        alias = {
          usage = "usage:jdx/mise-usage";
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
        legacy_version_file = false;
        yes = true;
      };
    };
    ripgrep = {
      enable = true;
      arguments = [
        "--follow"
        "--smart-case"
      ];
    };
    tealdeer = {
      enable = true;
      settings = {
        updates = {
          auto_update = true;
        };
      };
    };
    thefuck = {
      enable = true;
    };
    # TODO: Topgrade
    yazi = {
      enable = true;
      enableZshIntegration = true;
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
        append = true;
      };
      historySubstringSearch.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        cb-dry-run = "/apollo/env/bt-rust/bin/rust-customer-dry-runs";
        cat = "bat -pp";
        clip = "cargo clippy -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";
        clipfix = "cargo clippy --fix --allow-dirty --allow-staged -- -Wclippy::pedantic -Wclippy::nursery -Wclippy::cargo";
        clr = "clear";
        ghauth = # bash
          ''
            unset GITHUB_TOKEN &&
            export GITHUB_TOKEN="$(gh auth token)"''; # Cannot have newline at end of command or else it won't be chainable
        lg = "lazygit";
        v = "nvim";
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
            omz reload''; # Cannot have newline at end of command or else it won't be chainable
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
          fpath+=(${zshcompdir})

          # zsh-vi-mode. Following must exist before sourcing plugin
          local ZVM_INIT_MODE=sourcing
        '';
      initExtra = # bash
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

          eval "$(${pkgs.bat-extras.batman}/bin/batman --export-env)"

          # Requires nix-output-monitor
          ${pkgs.nix-your-shell}/bin/nix-your-shell --nom zsh | source /dev/stdin

          # SSH for use with ControlMaster
          local CONST_SSH_SOCK="$HOME/.ssh/ssh-auth-sock"
          if [ ! -z ''${SSH_AUTH_SOCK+x} ] && [ "$SSH_AUTH_SOCK" != "$CONST_SSH_SOCK" ]; then
            rm -f "$CONST_SSH_SOCK"
            ln -sf "$SSH_AUTH_SOCK" "$CONST_SSH_SOCK"
            export SSH_AUTH_SOCK="$CONST_SSH_SOCK"
          fi

          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        '';
      envExtra = # bash
        ''
          # zsh-abbr
          # TODO: find more elegant way to override home-manager program config
          export ABBR_USER_ABBREVIATIONS_FILE="${config.xdg.dataHome}/zsh-abbr/user_abbreviations"
        '';
      zsh-abbr.enable = true;
    };
  };
  xdg = {
    enable = true;
    configFile = {
      "markdownlint-cli/.markdownlint-cli2.yaml" = {
        text = # yaml
          ''
            config:
              ul-indent:
                indent: 4
                start_indent: 4
                start_indented: false
              heading-increment: false
              line-length:
                code_block_line_length: 100
                line_length: 250
              blanks-around-headings:
                lines_above: 1
                lines_below: 0
              no-duplicate-heading:
                siblings_only: true
              single-title: false
              blanks-around-fences: false
              blanks-around-lists: false
              no-inline-html: false
              first-line-heading: false

            # Ignore files referenced by .gitignore (only valid at root)
            gitignore: true

            # Disable progress on stdout (only valid at root)
            noProgress: true
          '';
      };
      "mise/config.toml" = {
        onChange = # bash
          ''
            run --quiet mise plugin install --all --yes --quiet
            run --quiet mise install --yes --quiet
          '';
      };
    };
  };
}
