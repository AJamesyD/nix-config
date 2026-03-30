{
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 28d";
    };

    settings = {
      accept-flake-config = true;
      download-buffer-size = 500 * 1024 * 1024; # 500MB
      experimental-features = [
        "auto-allocate-uids"
        "configurable-impure-env"
        "flakes"
        "nix-command"
      ];
      connect-timeout = 5;
      # TODO: http-connections = 0 (unlimited) is broken since Nix 2.34.
      #   PR #14993 computes maxQueueSize = httpConnections * 5, so 0 = no downloads.
      #   https://github.com/NixOS/nix/pull/14993
      #   Restore `http-connections = 0;` once fixed upstream.
    };
  };
}
