{
  config,
  lib,
  pkgs,
  ...
}:
{
  stylix = {
    enable = true;
    enableReleaseChecks = false;
    image = config.lib.stylix.pixel "base00";
    base16Scheme = ../themes/tokyo-night-custom.yaml;
    fonts.monospace = {
      package = pkgs.nerd-fonts.blex-mono;
      name = "BlexMono Nerd Font";
    };
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    # HACK: stylix's rofi home-manager module assigns the deprecated
    # `programs.rofi.font`, which emits a rename warning. Disabling the
    # target silences it. The target only exists on Linux, so guard it.
    targets.rofi.enable = false;
  };
}
