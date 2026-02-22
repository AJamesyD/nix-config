{
  pkgs,
  ...
}:
{
  imports = [
    ../../common/dev.nix
    ../../common/nix-hm.nix
  ];

  fonts.fontconfig.enable = true;

  home = {
    packages = with pkgs; [
      fira-code
      ibm-plex
      victor-mono

      gcc
      gnumake
      zig

      bitcoin

      obsidian
      transmission_4
      vlc

      mullvad-browser
      tor-browser
    ];
    stateVersion = "24.05"; # Please read the comment before changing.
  };

  programs = {
    git = {
      settings.user = {
        email = "aidandeangelis@berkeley.edu";
        name = "Aidan De Angelis";
      };
    };
    mise = {
      enable = true;
      globalConfig = {
        tools = {
          node = [
            # NOTE: First one becomes default
            "lts"
          ];
        };
      };
    };
    zsh = {
      enable = true;
      shellAliases = {
        nixup = # bash
          ''
            ghauth
            nix flake update --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN"
            home-manager switch --flake ~/.config/nix#dellangelis --option access-tokens "github.com=$GITHUB_TOKEN"
            zsource
          '';
        up = "sudo dnf upgrade -y && nixup";
      };
    };
  };
}
