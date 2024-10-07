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
      accept-flake-config = true;
      flake-registry = "/etc/nix/registry.json";

      experimental-features = [
        "auto-allocate-uids"
        "configurable-impure-env"
        "flakes"
        "nix-command"
      ];

      allowed-users = [ "@wheel" ];
      build-users-group = "nixbld";
      builders-use-substitutes = true;
      trusted-users = [
        "root"
        "@wheel"
      ];

      substituters = [
        "https://nix-config.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-config.cachix.org-1:Vd6raEuldeIZpttVQfrUbLvXJHzzzkS0pezXCVVjDG4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      connect-timeout = 5;
      http-connections = 0;

      cores = 0;
      max-jobs = "auto";
    };
  };
}
