{
  config,
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
  ];

  home.sessionVariables = {
    PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi";
    PI_SKIP_VERSION_CHECK = "1";
    PI_TELEMETRY = "0";
    PI_CACHE_RETENTION = "long";
  };
}
