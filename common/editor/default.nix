{
  pkgs,
  ...
}:
{
  stylix.targets.neovim.enable = false;

  home.packages = with pkgs; [
    # Editor core
    neovim
    tree-sitter
    (luajit.withPackages (
      ps: with ps; [
        luacheck
        luarocks
        luv
      ]
    ))
    ast-grep

    # Formatters and linters
    actionlint
    bazel-buildtools
    markdownlint-cli2
    oxfmt
    oxlint
    prettier
    ruff
    selene
    shellcheck
    shfmt
    stylua
    ty

    # LSP servers (shared by neovim, Helix, and Kiro)
    basedpyright
    bash-language-server
    lua-language-server
    marksman
    markdown-oxide
    starpls
    tailwindcss-language-server
    taplo
    ts_query_ls
    vscode-langservers-extracted
    vtsls
    yaml-language-server
    # Document generation
    graphviz
    pandoc
    python313Packages.pylatexenc
  ];

  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batpipe
      ];
    };
    helix = {
      enable = true;
      package = pkgs.evil-helix;
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
      text = builtins.readFile ./markdownlint-cli2.yaml;
    };
  };
}
