{
  pkgs,
  ...
}:
{
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 28";
    };

    package = pkgs.nixVersions.latest;

    settings = {
      accept-flake-config = true;
      substituters = [
        "https://nix-config.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-config.cachix.org-1:Vd6raEuldeIZpttVQfrUbLvXJHzzzkS0pezXCVVjDG4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      experimental-features = [
        "auto-allocate-uids"
        "configurable-impure-env"
        "flakes"
        "nix-command"
      ];
      connect-timeout = 5;
      http-connections = 0;
      flake-registry = "/etc/nix/registry.json";
    };
  };
}
