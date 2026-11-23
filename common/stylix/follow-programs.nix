# Enable each stylix target only when the thing it themes is enabled.
#
# NOTE: stylix enables every target by default, so a stale target for an app we
#   never use can break eval. 2026-11-23: home-manager removed programs.wayprompt
#   while stylix still set it, failing every host.
#
# TODO: delete this file once stylix gates targets on module availability
#   upstream: https://github.com/nix-community/stylix/pull/2561 (discussion
#   https://github.com/nix-community/stylix/discussions/2560).
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
  toggleableTargets = lib.filter (target: targets.${target} ? enable) (lib.attrNames targets);

  alwaysEnabledTargets = [ "font-packages" ];

  # NOTE: a target that sets its own switch must not be listed here: following
  #   it recurses forever, and tryEval cannot catch that. stylix's gtk target
  #   sets gtk.enable, so `gtk = [ "gtk" ];` fails on every host.
  pathOverrides = {
    fontconfig = [ "fonts.fontconfig" ];
    zed = [ "programs.zed-editor" ];
    hyprland = [ "wayland.windowManager.hyprland" ];
    sway = [ "wayland.windowManager.sway" ];
    river = [ "wayland.windowManager.river" ];
    i3 = [ "xsession.windowManager.i3" ];
  };

  candidatePathsFor =
    target:
    pathOverrides.${target} or [
      "programs.${target}"
      "services.${target}"
    ];

  isEnabledAt =
    optionPath:
    let
      enablePath = lib.splitString "." optionPath ++ [ "enable" ];
      enableValue = builtins.tryEval (lib.getAttrFromPath enablePath config);
    in
    # NOTE: check the option before reading config. A removed option
    #   (lib.mkRemovedOptionModule) is one bare option with no `enable` child,
    #   and reading a renamed option throws, which tryEval turns into false.
    lib.hasAttrByPath enablePath options
    && lib.isOption (lib.getAttrFromPath enablePath options)
    && enableValue.success
    && enableValue.value;

  # NOTE: stylix computes this from stylix.autoEnable and the target's platform
  #   gate, so reading it keeps both.
  stylixWouldEnable = target: targets.${target}.enable.default or true;

  # NOTE: stylixWouldEnable goes first so a gated-off target never reads its
  #   program; stylix's swaylock target relies on that to avoid recursion.
  shouldEnable =
    target:
    stylixWouldEnable target
    && (lib.elem target alwaysEnabledTargets || lib.any isEnabledAt (candidatePathsFor target));
in
{
  # NOTE: mkDefault so a plain assignment next to a program's own config can
  #   opt out, e.g. `stylix.targets.neovim.enable = false;` in common/editor.
  stylix.targets = lib.genAttrs toggleableTargets (target: {
    enable = lib.mkDefault (shouldEnable target);
  });
}
