{
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 28";
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
      http-connections = 0;
    };
  };
}
