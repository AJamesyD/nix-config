_: {
  imports = [
    ./generic.nix
    ./claude.nix
    ./symposium.nix
  ];

  home = {
    sessionVariables = {
      AWS_BEDROCK_FORCE_CACHE = "1";
    };

    # Pi's native auth: env takes priority over process env (no runtime override).
    file.".pi/agent/auth.json".text = builtins.toJSON {
      amazon-bedrock = {
        type = "api_key";
        env = {
          AWS_PROFILE = "bedrock";
          AWS_REGION = "us-west-2";
        };
      };
    };
  };
}
