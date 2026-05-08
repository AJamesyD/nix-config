{
  pkgs,
  ...
}:
let
  kbdConfig = pkgs.writeText "kanata.kbd" (builtins.readFile ./kanata.kbd);
in
{
  services.kanata = {
    enable = true;
    kanata-bar.enable = true;
    kanata-bar.settings.kanata_bar.autostart_kanata = true;
    configSource = kbdConfig;
  };
}
