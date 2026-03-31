{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.programs.bob-nvim;
in
{
  options.programs.bob-nvim = {
    enable = mkEnableOption "bob-nvim";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.callPackage ../../pkgs/bob-nvim { })
    ];
  };
}
