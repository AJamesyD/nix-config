{
  pkgs,
  ...
}:
{
  imports = [
    ../../common/dev.nix
    ../../common/ai/generic.nix
    ../../common/nix-common.nix
    ../../common/ssh.nix
    ../../common/stylix
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
    stateVersion = "24.05";
  };

  programs = {
    git.signing.format = null;
    jujutsu.settings.user = {
      name = "Aidan De Angelis";
      email = "aidandeangelis@berkeley.edu";
    };
    zsh = {
      enable = true;
      shellAliases = {
        up = "sudo dnf upgrade -y && nixup";
      };
    };
  };
}
