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
      sparrow

      obsidian
      transmission
      vlc

      mullvad-browser
      tor-browser
    ];
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.11"; # Please read the comment before changing.
  };

  programs = {
    git = {
      userEmail = "aidandeangelis@berkeley.edu";
      userName = "Aidan De Angelis";
    };
    mise = {
      enable = true;
      globalConfig = {
        tools = {
          node = [
            # NOTE: First one becomes default
            "22"
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

  targets.genericLinux.enable = true;
}
