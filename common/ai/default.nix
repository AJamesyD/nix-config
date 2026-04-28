{ pkgs, ... }:
{
  imports = [
    ./claude.nix
    ./pi.nix
    ./rtk.nix
    ./symposium.nix
  ];

  programs.mcp = {
    enable = true;
  };

  home.packages = [
    pkgs.opencode
    (pkgs.callPackage ../../pkgs/mcp-hub { })
  ];

  home.sessionVariables = {
    AWS_BEDROCK_FORCE_CACHE = "1";

    OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
    OPENCODE_ENABLE_EXA = "1";
    OPENCODE_DISABLE_AUTOUPDATE = "1";
    OPENCODE_EXPERIMENTAL_PLAN_MODE = "1";
    OPENCODE_DISABLE_LSP_DOWNLOAD = "1";
  };
}
