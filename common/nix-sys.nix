{
  pkgs,
  ...
}:
{
  nix = {
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
        "@wheel"
      ];

      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      cores = 0;
      max-jobs = "auto";
    };
  };
}
