{
  nix = {
    gc = {
      # NOTE: fallback only. Primary GC is `nh clean` (via nix-clean alias)
      #   which supports generation-count retention. This threshold should
      #   stay >= nh clean's --keep-since value to avoid deleting generations
      #   that nh clean would preserve.
      automatic = true;
      options = "--delete-older-than 14d";
    };

    settings = {
      # Retain build outputs reachable from existing GC roots. Prevents
      # garbage collection from deleting devshell tool binaries (treefmt,
      # nil, etc.) that pre-commit hooks reference via store paths.
      # Recommended by nix-direnv. Costs ~30% more store space.
      keep-outputs = true;

      # Trigger GC when free disk space drops below 10 GB. Daemon-side
      # setting: on multi-user Linux installs (Determinate Nix), this
      # only takes effect from /etc/nix/nix.conf or nix.custom.conf,
      # not from the home-manager-generated ~/.config/nix/nix.conf.
      # On nix-darwin, nix-daemon.nix writes it to /etc/nix/nix.conf.
      min-free = 10 * 1024 * 1024 * 1024;

      download-buffer-size = 500 * 1024 * 1024; # 500MB
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      connect-timeout = 5;
      narinfo-cache-negative-ttl = 5 * 60;
      stalled-download-timeout = 60;
      tarball-ttl = 24 * 60 * 60;
      # TODO: re-enable once Determinate Nix ships Nix 2.34+
      #   (currently 2.33.4 in Determinate Nix 3.18.1). Check with:
      #   `determinate-nixd version` or `nix config show lint-url-literals`
      # lint-url-literals = "warn";
      # TODO: http-connections = 0 (unlimited) may cause issues on Nix 2.35+.
      #   PR #14993 (merged 2026-01-14) limits active curl handles; 0 may mean
      #   no queue. Default 25 is reasonable. Test before changing.
      #   https://github.com/NixOS/nix/pull/14993
    };
  };
}
