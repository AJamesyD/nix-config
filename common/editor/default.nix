{
  config,
  inputs,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    neovim
    tree-sitter
    (luajit.withPackages (
      ps: with ps; [
        luarocks
        luv
      ]
    ))
    ast-grep
    markdownlint-cli2
    mermaid-cli
    python313Packages.pylatexenc
    graphviz
    pandoc
    ruff
    shellcheck
    shfmt
    stylua
  ];

  home.sessionVariables = {
    # $BAT_THEME reused by git delta
    BAT_THEME = "tokyonight-night";
  };

  programs = {
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
  };

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

  xdg.configFile = {
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
  };
}
