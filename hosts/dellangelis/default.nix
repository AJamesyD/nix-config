{
  pkgs,
  ...
}:
{
  imports = [
    ../../common/dev.nix
    ../../common/nix-common.nix
    ../../common/stylix.nix
  ];

  fonts.fontconfig.enable = true;

  home = {
    packages = with pkgs; [
      fira-code
      ibm-plex
      victor-mono

      gcc
      gnumake

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
    jujutsu.settings.user = {
      name = "Aidan De Angelis";
      email = "aidandeangelis@berkeley.edu";
    };
    mise = {
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
        up = "sudo dnf upgrade -y && nixup";
      };
    };
  };
}
