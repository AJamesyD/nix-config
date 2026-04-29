{
  pkgs,
  ...
}:
{
  nix = {
    gc.interval = {
      Weekday = 0;
      Hour = 3;
      Minute = 0;
    };
    optimise = {
      automatic = true;
    };
    package = pkgs.nixVersions.latest;
    settings = {
      flake-registry = "/etc/nix/registry.json";

      allowed-users = [ "@wheel" ];
      build-users-group = "nixbld";
      builders-use-substitutes = true;
      trusted-users = [
        "root"
        "angaidan"
      ];

      cores = 0;
      max-jobs = "auto";
    };
  };
}
