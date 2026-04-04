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
    #   ("cannot link tmp-link to .links: File exists"). Fixed on master
    #   (PR #14676, 2025-12-01) but not in 2.34.x. Remove after upgrading to 2.35+.
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
