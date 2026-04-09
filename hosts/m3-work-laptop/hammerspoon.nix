{ config, ... }:
let
  hmCfg = config.home-manager.users.angaidan;
in
{
  system.defaults.CustomUserPreferences."org.hammerspoon.Hammerspoon" = {
    MJConfigFile = "${hmCfg.xdg.configHome}/hammerspoon/init.lua";
  };
}
