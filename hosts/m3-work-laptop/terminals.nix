{
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      nerd-fonts.blex-mono
      nerd-fonts.hack
      nerd-fonts.victor-mono
      hack-font
      ibm-plex
      sketchybar-app-font
      victor-mono
    ];
  };
}
