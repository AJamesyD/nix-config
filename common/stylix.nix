{
  config,
  pkgs,
  ...
}:
{
  stylix = {
    enable = true;
    image = config.lib.stylix.pixel "base00";
    base16Scheme = ../themes/tokyo-night-custom.yaml;
    fonts.monospace = {
      package = pkgs.nerd-fonts.blex-mono;
      name = "BlexMono Nerd Font";
    };
  };
}
