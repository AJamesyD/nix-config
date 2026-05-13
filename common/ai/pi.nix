{
  config,
  inputs,
  pkgs,
  ...
}:
let
  # Wrap Pi with Bedrock credentials (matches OpenCode's profile)
  # Uses conditional defaults so explicit AWS_PROFILE override works:
  #   AWS_PROFILE=other pi  # uses "other" profile
  #   pi                    # uses "bedrock" profile
  # Note: subprocess pollution is unavoidable - shell commands Pi spawns
  # will inherit these vars. Override per-command if needed.
  piWithBedrock = pkgs.writeShellScriptBin "pi" ''
    export AWS_PROFILE="''${AWS_PROFILE:-bedrock}"
    export AWS_REGION="''${AWS_REGION:-us-west-2}"
    exec ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi}/bin/pi "$@"
  '';
in
{
  home.packages = [
    piWithBedrock
  ];

  home.sessionVariables = {
    PI_SKIP_VERSION_CHECK = "1";
    PI_TELEMETRY = "0";
    PI_CACHE_RETENTION = "long";
  };
}
