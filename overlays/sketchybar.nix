# Patch: render popups on all displays, not just the focused one
# - https://github.com/FelixKratz/SketchyBar/issues/316
# - https://github.com/FelixKratz/SketchyBar/issues/742
#
# TODO: Re-enable once the patch is refined to avoid redraw flicker.
# The naive removal of all active_adid guards causes popup_draw to fire
# on every display's bar instance, triggering SkyLight errors.
final: _prev: {
  # sketchybar = prev.sketchybar.overrideAttrs (old: {
  #   patches = (old.patches or [ ]) ++ [
  #     ./patches/sketchybar-popup-all-displays.patch
  #   ];
  # });
}
