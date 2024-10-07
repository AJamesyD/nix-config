{
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 28";
    };

    settings = {
      accept-flake-config = true;
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
