{
  config,
  lib,
  pkgs,
  ...
}:
let
  zshcompdir = "${config.programs.zsh.dotDir}/completion/";
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
              export ZDOTDIR="${config.programs.zsh.dotDir}"
              export ZCOMPDIR="${zshcompdir}"
              mkdir -p $ZCOMPDIR

              export PATH="$PATH:${lib.concatStringsSep ":" config.home.sessionPath}"
              export PATH="$PATH:${config.home.profileDirectory}/bin"
              export PATH="$PATH:/usr/bin"
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
            run --quiet rustup completions zsh >"$ZCOMPDIR/_rustup"
            run --quiet rustup completions zsh cargo >"$ZCOMPDIR/_cargo"
          '';
    };

    extraActivationPath = with pkgs; [
      curl
      git
      git-lfs
      git-secrets
      gnutar
      gzip
    ];

    # since zsh.dotDir is set, still create ~/.zshrc so that it is write-protected against
    # random programs trying to append to it
    file = {
      ".claude/settings.json" = {
        text = builtins.toJSON {
          model = "claude-sonnet-4-20250514";
          cleanupPeriodDays = 14;
          includeCoAuthoredBy = false;
          permissions = {
            allow = [
              "Read(*)"
              "Edit(**/*.md)"
            ];
            deny = [
              "Read(build/**)"
            ];
          };
          env = {
            DISABLE_BUG_COMMAND = 1;
            DISABLE_ERROR_REPORTING = 1;
            DISABLE_TELEMETRY = 1;
          };
        };
      };

      ".zshrc" = {
        text = # bash
          ''
            # This file is intentionally empty.

            # When zsh.dotDir is set, still create ~/.zshrc so that it is write-protected against
            # random programs trying to append to it
          '';
      };
    };

    packages = with pkgs; [
      (pkgs.callPackage ../pkgs/bins { })

      coreutils
      curl
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
      netcat-gnu
      pandoc
      rsync
      squashfsTools

      ruff
      shellcheck
      shfmt
      stylua

      cargo-nextest
      rustup
      mdbook
      graphviz

      cachix
      devenv
      nix-output-monitor
      nix-update
      nix-your-shell
      nixd
      nixfmt-rfc-style

      (luajit.withPackages (
        ps: with ps; [
          luarocks
          luv
        ]
      ))
      markdownlint-cli2
      neovim
      tree-sitter

      docker
      docker-compose

      dust
      dua
      hyperfine

      gum
      libnotify
      sesh
      usage

      claude-code
      opencode
    ];

    preferXdgDirectories = true;
    sessionVariables = {
      EDITOR = "nvim";
      LESSHISTFILE = "${config.xdg.dataHome}/less_history";

      BACON_PREFS = "${config.xdg.configHome}/bacon/prefs.toml";

      GIT_PAGER = "delta --dark --paging=never";

      GOPROXY = "direct";

      MISE_NODE_DEFAULT_PACKAGES_FILE = "${config.xdg.configHome}/mise/default-node-packages";
      MISE_PYTHON_DEFAULT_PACKAGES_FILE = "${config.xdg.configHome}/mise/default-python-packages";
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
      settings = {
        # prefs.toml
        exports = {
          cargo-json-spans = {
            auto = true;
            exporter = "analyzer";
            line_format = "{diagnostic.level}|:|{span.file_name}|:|{span.line_start}|:|{span.line_end}|:|{span.column_start}|:|{span.column_end}|:|{diagnostic.message}|:|{diagnostic.rendered}|:|{span.suggested_replacement}";
            path = ".bacon-locations";
          };
        };
        # default bacon.toml
        default_job = "bacon-ls";
        jobs = {
          bacon-ls = {
            command = [
              "cargo"
              "clippy"
              "--workspace"
              "--tests"
              "--all-targets"
              "--all-features"
              "--message-format"
              "json-diagnostic-rendered-ansi"
              "--"
              "-A"
              "clippy::style"
            ];
            ignore = [ "build/" ];
            analyzer = "cargo_json";
            need_stdout = true;
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
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    git = {
      enable = true;
      delta = {
        enable = true;
        # Use $GIT_PAGER to set options
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
      goBin = ".local/bin.go";
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
    lazydocker = {
      enable = true;
    };
    lazygit = {
      enable = true;
      settings = {
        gui = {
          scrollHeight = 3;
          scrollPastBottom = false;
          scrollOffMargin = 3;
          mouseEvents = false;
          expandFocusedSidePanel = true;
          nerdFontsVersion = "3";
          showDivergenceFromBaseBranch = "onlyArrow";
        };
        git = {
          paging = {
            # Use $GIT_PAGER to set options
            useConfig = true;
          };
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
    mise = {
      enable = true;
      globalConfig = {
        alias = {
          usage = "usage:jdx/mise-usage";
        };
        tools = {
          # NOTE: First one becomes default
          python = [
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
    uv = {
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
        lg = "lazygit";
        v = "nvim";
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
          "direnv"
          "fzf"
          "git"
          "git-auto-fetch"
          "brew"
        ];
      };
      initContent = lib.mkMerge [
        (lib.mkBefore # bash
          ''
            if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi
          ''
        )
        (lib.mkOrder 550
          # bash
          ''
            fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)
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

          local P10K_PATH="''${ZDOTDIR:-~}/.p10k.zsh"

          [[ ! -f "$P10K_PATH" ]] || source "$P10K_PATH"
        ''
      ];
      envExtra = # bash
        ''
          # zsh-abbr
          # TODO: find more elegant way to override home-manager program config
          export ABBR_USER_ABBREVIATIONS_FILE="${config.xdg.dataHome}/zsh-abbr/user_abbreviations"
        '';
      zsh-abbr.enable = true;
    };
  };
  services = {
    ollama = {
      enable = true;
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
