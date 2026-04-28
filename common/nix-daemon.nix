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
