# Enable each stylix target only when the thing it themes is enabled.
#
# NOTE: stylix enables every target by default, so a target whose program
#   upstream removed breaks eval on every host, as wayprompt did on 2026-11-23:
#   https://github.com/AJamesyD/nix-config/pull/38
#   Only helps when upstream leaves a lib.mkRemovedOptionModule stub; an option
#   deleted outright still fails, since mkIf false does not hide undeclared
#   options.
#
# TODO: delete this file once stylix gates targets on module availability:
#   https://github.com/nix-community/stylix/pull/2561
#
# NOTE: reads `options` and `config` of whichever scope imports it, so one file
#   serves both home-manager and nix-darwin.
{
  config,
  options,
  lib,
  ...
}:
let
  targets = options.stylix.targets;

  # NOTE: removing, renaming or retyping an option leaves a stub in its place
  #   (lib.mkRemovedOptionModule, lib.mkRenamedOptionModule,
  #   lib.mkChangedOptionModule). No stub is a bool option with a default, and
  #   every real `enable` is. Defining a stub fails eval; reading one throws or
  #   warns. stylix dropped wayprompt this way:
  #   https://github.com/nix-community/stylix/pull/2559
  isRealEnable = option: lib.isOption option && option ? default && option.type.name == "bool";

  isToggleable = target: isRealEnable (targets.${target}.enable or null);
  toggleableTargets = lib.filter isToggleable (lib.attrNames targets);

  # NOTE: stylixWouldEnable goes first so a gated-off target never reads its
  #   program; stylix's swaylock target recurses otherwise.
  shouldEnable =
    target:
    stylixWouldEnable target
    && (lib.elem target alwaysEnabledTargets || lib.any isEnabledAt (candidatePathsFor target));

  # NOTE: stylix computes this from stylix.autoEnable and the target's platform
  #   gate, so reading it keeps both.
  stylixWouldEnable = target: targets.${target}.enable.default;

  # NOTE: font-packages installs stylix's fonts and has no program to follow.
  alwaysEnabledTargets = [ "font-packages" ];

  candidatePathsFor =
    target:
    pathOverrides.${target} or [
      "programs.${target}"
      "services.${target}"
    ];

  # NOTE: a target that sets its own switch must not be listed here: following
  #   it recurses forever. stylix's gtk target sets gtk.enable, so
  #   `gtk = [ "gtk" ];` fails on every host.
  pathOverrides = {
    fontconfig = [ "fonts.fontconfig" ];
    zed = [ "programs.zed-editor" ];
    hyprland = [ "wayland.windowManager.hyprland" ];
    sway = [ "wayland.windowManager.sway" ];
    river = [ "wayland.windowManager.river" ];
    i3 = [ "xsession.windowManager.i3" ];
  };

  isEnabledAt =
    optionPath:
    let
      enablePath = lib.splitString "." optionPath ++ [ "enable" ];
    in
    # NOTE: check `options` first: getAttrFromPath aborts on a missing path.
    isRealEnable (lib.attrByPath enablePath null options) && lib.getAttrFromPath enablePath config;
in
{
  # NOTE: mkDefault so a plain assignment next to a program's own config can
  #   opt out, e.g. `stylix.targets.neovim.enable = false;` in common/editor.
  stylix.targets = lib.genAttrs toggleableTargets (target: {
    enable = lib.mkDefault (shouldEnable target);
  });
}
