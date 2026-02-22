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
  imports = [
    ./ai
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
              export PATH="$PATH:${config.home.homeDirectory}/.toolbox/bin"
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
      gnupg
      gnutar
      gzip
    ];

    # since zsh.dotDir is set, still create ~/.zshrc so that it is write-protected against
    # random programs trying to append to it
    file = {
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
      gnupg
      gnused
      gnutar
      gnutls
      # required to make terminfo files available before zsh login
      (lib.hiPrio ncurses)
      netcat-gnu
      pandoc
      parallel
      rsync
      squashfsTools
      wget

      mermaid-cli
      python313Packages.pylatexenc
      ruff
      shellcheck
      shfmt
      stylua

      cargo-binstall
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
      nixfmt

      (luajit.withPackages (
        ps: with ps; [
          luarocks
          luv
        ]
      ))
      markdownlint-cli2
      ast-grep
      neovim
      tree-sitter

      zig

      docker
      docker-compose

      dust
      dua
      hyperfine

      libnotify
      usage
    ];

    preferXdgDirectories = true;
    sessionVariables = {
      EDITOR = "nvim";
      LESSHISTFILE = "${config.xdg.dataHome}/less_history";

      BACON_PREFS = "${config.xdg.configHome}/bacon/prefs.toml";

      # $BAT_THEME reused by git delta
      BAT_THEME = "tokyonight-night";

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
    bat = {
      enable = true;
      # Theme set by $BAT_THEME
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batpipe
      ];
      themes = {
        tokyonight-night = {
          src = inputs.tokyonight-nvim;
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
    delta = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
      options = {
        dark = true;
        # Increase contrast for line diffs
        minus-style = "normal darkred";
        plus-style = "normal darkgreen";
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
      lfs = {
        enable = true;
      };
      settings = {
        alias = {
          dag = "log --graph --format='format:%C(yellow)%h%C(reset) %C(blue)\"%an\" <%ae>%C(reset) %C(magenta)%cr%C(reset)%C(auto)%d%C(reset)%n%s' --date-order";
        };
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
      env = {
        goBin = ".local/bin.go";
      };
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
          mouseEvents = false;
          expandFocusedSidePanel = true;
          nerdFontsVersion = "3";
          showDivergenceFromBaseBranch = "onlyArrow";
        };
        git = {
          pagers = [
            {
              pager = "delta --dark --paging=never";
            }
          ];
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
      shellWrapperName = "lg";
    };
    less = {
      enable = true;
    };
    lesspipe = {
      enable = true;
    };
    mergiraf.enable = true;
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
        settings = {
          legacy_version_file = false;
          yes = true;
        };
        tool_alias = {
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
    yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
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
      ];
      oh-my-zsh = {
        enable = true;
        theme = "powerlevel10k";
        custom = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
        plugins = [
          "git"
        ];
      };
      initContent = lib.mkMerge [
        (lib.mkBefore ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        '')
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

          eval "$(${pkgs.bat-extras.batman}/bin/batman --export-env)"

          # Requires nix-output-monitor
          ${pkgs.nix-your-shell}/bin/nix-your-shell --nom zsh | source /dev/stdin

          local P10K_PATH="''${ZDOTDIR:-~}/.p10k.zsh"

          [[ ! -f "$P10K_PATH" ]] || source "$P10K_PATH"
        ''
      ];
      envExtra = # bash
        ''
          # https://scottspence.com/posts/speeding-up-my-zsh-shell
          DISABLE_AUTO_UPDATE="true"
          DISABLE_MAGIC_FUNCTIONS="true"
          DISABLE_COMPFIX="true"

          # ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
          # ZSH_AUTOSUGGEST_USE_ASYNC=1
        '';
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
            run --quiet mise plugins install --all --yes --quiet
            run --quiet mise install --yes --quiet
          '';
      };
    };
  };
}
