# Generates colors.lua and wm_config.lua for sketchybar.
# Colors are sourced from stylix's base16 scheme so changing the scheme
# in common/stylix.nix updates sketchybar automatically.
#
# Base16 accent mapping (standard convention):
#   base08=red  base09=orange  base0A=yellow  base0B=green
#   base0C=cyan  base0D=blue  base0E=purple  base0F=brown
{ config, ... }:
let
  inherit (config.lib.stylix) colors;

  hex = slot: "0xff${slot}";
  hexAlpha = alpha: slot: "0x${alpha}${slot}";

  colorsLua = ''
    return {
      with_alpha = function(color, alpha)
        return (color % 0x01000000) + (alpha * 0x01000000)
      end,

      transparent = 0x00000000,

      bar = {
        bg = ${hexAlpha "88" colors.base01},
        border = ${hexAlpha "44" colors.base04},
      },

      popup = {
        bg = ${hexAlpha "ee" colors.base00},
        border = ${hex colors.base03},
      },

      bg1 = ${hex colors.base00},
      item_bg = ${hexAlpha "cc" colors.base02},

      fg = ${hex colors.base05},
      fg_dim = ${hex colors.base04},
      grey = ${hex colors.base03},
      comment = ${hex colors.base04},

      red = ${hex colors.base08},
      orange = ${hex colors.base09},
      yellow = ${hex colors.base0A},
      green = ${hex colors.base0B},
      teal = ${hex colors.base0C},
      blue = ${hex colors.base0D},
      magenta = ${hex colors.base0E},

      border_active = ${hex colors.base0D},
    }
  '';

  wmConfigLua = ''
    return {
      use_aerospace = true,
    }
  '';
in
{
  xdg.configFile = {
    "sketchybar/colors.lua".text = colorsLua;
    "sketchybar/wm_config.lua".text = wmConfigLua;
  };
}
