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
        version = "4.1.6";

        src = fetchFromGitHub {
          owner = "MordechaiHadad";
          repo = "bob";
          rev = "v4.1.6";
          sha256 = "sha256-XI/oNGKLXQ/fpB6MojhTsEgmmPH1pHECD5oZgc1r4rQ=";
        };

        cargoHash = "sha256-YSZcYTGnMnN/srh8Z15toq+GIyRKfFd+pGkFQl5gCuo=";
        doCheck = false;
      })
    ];
  };

}
