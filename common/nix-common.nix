{
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 28d";
    };

    settings = {
      # Retain build outputs reachable from existing GC roots. Prevents
      # nix-collect-garbage from deleting devshell tool binaries (treefmt,
      # nil, etc.) that pre-commit hooks reference via store paths.
      # Recommended by nix-direnv. Costs ~30% more store space.
      keep-outputs = true;

      download-buffer-size = 500 * 1024 * 1024; # 500MB
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      connect-timeout = 5;
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
