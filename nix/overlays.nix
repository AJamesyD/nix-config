# Auto-discover overlays from ../overlays/ and compose into a single
# default overlay applied to the shared pkgs instance.
{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  overlayDir = ../overlays;
  overlayFiles = lib.filterAttrs (n: v: v == "regular" && lib.hasSuffix ".nix" n) (
    builtins.readDir overlayDir
  );
  localOverlays = lib.mapAttrsToList (f: _: import (overlayDir + "/${f}")) overlayFiles;
in
{
  flake.overlays.default = lib.composeManyExtensions localOverlays;

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        config = {
          allowUnfree = true;
          allowAliases = true;
        };
        localSystem = system;
        overlays = [ inputs.self.overlays.default ];
      };
    };
}
