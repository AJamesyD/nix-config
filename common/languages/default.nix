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
          if curl -sf --max-time 2 https://nix-config.cachix.org >/dev/null 2>&1; then
          	run --silence mise plugins update --yes --quiet
          	run --quiet mise install --yes --quiet
          fi
        '';
    rustup =
      lib.hm.dag.entryAfter
        [
          "writeBoundary"
          "envSetup"
        ] # bash
        ''
          if curl -sf --max-time 2 https://nix-config.cachix.org >/dev/null 2>&1; then
          	run --quiet rustup toolchain install stable --component llvm-tools
          	run --quiet rustup update
          fi
          run --quiet rustup default stable
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
        GOBIN = ".local/bin.go";
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
        tools = {
          # NOTE: First one becomes default
          python = [
            "3.12"
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
        '';
    };
  };
}
