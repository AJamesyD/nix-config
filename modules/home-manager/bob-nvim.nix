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
    home.packages = with pkgs; [
      (rustPlatform.buildRustPackage {
        pname = "bob-nvim";
        version = "4.1.2";

        src = fetchFromGitHub {
          owner = "MordechaiHadad";
          repo = "bob";
          rev = "v4.1.2";
          sha256 = "sha256-l4WfMvRPvnqra4jiK35w2SwfgxeRCYLl3ZWtD2UTQqw=";
        };

        cargoHash = "sha256-bcDCbAOFth3/o+USoJY1NPZyPWyZA3jhruRMnPo8kOQ=";
        doCheck = false;
      })
    ];
  };

}
