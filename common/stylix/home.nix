# Stylix target toggles shared by every home-manager configuration.
#
# NOTE: home-manager context ONLY — enforced by `_class` below. The sibling
#   default.nix is dual-class (also a nix-darwin module on the Mac); these
#   stylix.targets.* options are home-manager-only, so evaluating this file at
#   system scope is an error (it previously caused an infinite recursion).
#   mkDefault lets a host that manages GTK/rofi via home-manager re-enable them.
{ lib, ... }:
{
  _class = "homeManager";
  stylix.targets = {
    # NOTE: no home config lets stylix manage GTK — the Mac and headless al2
    #   have no GTK runtime, dellangelis manages GTK outside home-manager, and
    #   since stylix #2330 the target also sets gtk.gtk4.theme, conflicting with
    #   a manual null override.
    gtk.enable = lib.mkDefault false;
    # NOTE: stylix's rofi target sets the renamed `programs.rofi.font`, warning
    #   on every rebuild; rofi is unused on every host.
    rofi.enable = lib.mkDefault false;
  };
}
