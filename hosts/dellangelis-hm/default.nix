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
    ../../common/stylix.nix
  ];

  fonts.fontconfig.enable = true;

  stylix.targets.gtk.enable = false;
  # Silences stylix's deprecated `programs.rofi.font` warning. Kept per-host because
  # common/stylix.nix is also a nix-darwin module, where `targets.rofi` is undefined;
  # branching that shared module's structure on platform caused an eval infinite recursion.
  stylix.targets.rofi.enable = false;

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
