{
  pkgs,
  ...
}:
{
  nix = {
    # TODO: nix-darwin's gc scheduling via launchd may be unreliable.
    #   Multiple community configs (Mic92, ryan4yin) disable nix.gc.automatic
    #   on darwin and use a custom launchd daemon or manual gc instead.
    #   Monitor whether this interval actually fires; switch to a custom
    #   launchd.daemons entry if it doesn't.
    gc.interval = {
      Weekday = 0;
      Hour = 3;
      Minute = 0;
    };
    # TODO: auto-optimise-store on darwin may hit NixOS/nix#7273
    #   ("cannot link tmp-link to .links: File exists"). ryan4yin disables
    #   it on darwin for this reason. Disable if the error appears in logs.
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
