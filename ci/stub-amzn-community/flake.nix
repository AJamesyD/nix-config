{
  description = "CI stub for AmznNix-Community (no-op homeModules.default)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = _: {
    homeModules.default =
      { lib, ... }:
      {
        options.programs.toolbox = lib.mkOption {
          type = lib.types.submodule { freeformType = lib.types.attrs; };
          default = { };
        };
      };
  };
}
