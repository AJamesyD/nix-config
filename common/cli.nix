{
  config,
  lib,
  pkgs,
  ...
}:
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
    rsync
    squashfsTools
    wget

    parallel

    dust
    dua
    hyperfine

    libnotify

    cachix
    devenv
    nix-output-monitor
    nix-update
    nixd
    nixfmt
  ];

  home.sessionVariables = {
    LESSHISTFILE = "${config.xdg.dataHome}/less_history";
  };

  programs = {
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
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
    htop = {
      enable = true;
    };
    jq = {
      enable = true;
    };
    less = {
      enable = true;
    };
    lesspipe = {
      enable = true;
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
  };
}
