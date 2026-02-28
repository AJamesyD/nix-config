{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    cargo-binstall
    rustup
    mdbook
    zig
    usage
  ];

  home.sessionVariables = {
    BACON_PREFS = "${config.xdg.configHome}/bacon/prefs.toml";

    GOPROXY = "direct";

    MISE_NODE_DEFAULT_PACKAGES_FILE = "${config.xdg.configHome}/mise/default-node-packages";
    MISE_PYTHON_DEFAULT_PACKAGES_FILE = "${config.xdg.configHome}/mise/default-python-packages";
    # https://github.com/jdx/mise/issues/3099
    MISE_LIBGIT2 = "false";
  };

  home.activation = {
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

  home.extraActivationPath = with pkgs; [
    curl
    git
    git-lfs
    git-secrets
    gnupg
    gnutar
    gzip
  ];

  programs = {
    go = {
      enable = true;
      env = {
        goBin = ".local/bin.go";
      };
    };
    java = {
      enable = true;
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
    uv = {
      enable = true;
    };
  };

  xdg.configFile = {
    "mise/config.toml" = {
      onChange = # bash
        ''
          run --quiet mise plugins install --all --yes --quiet
          run --quiet mise install --yes --quiet
        '';
    };
  };
}
