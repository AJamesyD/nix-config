{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    cargo-binstall
    mdbook
    nodejs
    python3
    rustup
    zig
  ];

  home.sessionVariables = {
    BACON_PREFS = "${config.xdg.configHome}/bacon/prefs.toml";

    GOPROXY = "direct";
  };

  home.activation = {
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
          rustup completions zsh >"$ZCOMPDIR/_rustup" 2>/dev/null
          rustup completions zsh cargo >"$ZCOMPDIR/_cargo" 2>/dev/null
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
      package = pkgs.jdk25;
    };
    uv = {
      enable = true;
    };
  };
}
