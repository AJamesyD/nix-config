{ inputs, pkgs, ... }:
{
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
    htop = {
      enable = true;
    };
    jq = {
      enable = true;
    };
    lazydocker = {
      enable = true;
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
    yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
    };
    zoxide = {
      enable = true;
    };
  };
}
