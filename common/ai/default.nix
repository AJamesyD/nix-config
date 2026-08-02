_: {
  imports = [
    ./generic.nix
    ./claude.nix
    ./pi.nix
    ./symposium.nix
  ];

  home.sessionVariables = {
    AWS_BEDROCK_FORCE_CACHE = "1";
  };
}
