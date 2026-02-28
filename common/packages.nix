{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
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

    lazyjj

    dust
    dua
    hyperfine

    libnotify
    usage
  ];
}
