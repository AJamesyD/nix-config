{ pkgs, ... }:
{
  imports = [
    ./claude.nix
    ./rtk.nix
    ./symposium.nix
  ];

  programs.mcp = {
    enable = true;
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
  };

  home.packages = [
    # programs.mcp manages config only; mcp-hub provides the server binary
    (pkgs.callPackage ../../pkgs/mcp-hub { })
  ];

  home.sessionVariables = {
    OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
    OPENCODE_ENABLE_EXA = "1";
    # nix manages the binary
    OPENCODE_DISABLE_AUTOUPDATE = "1";
    OPENCODE_EXPERIMENTAL_PLAN_MODE = "1";
    # use nix-provided LSPs from PATH
    OPENCODE_DISABLE_LSP_DOWNLOAD = "1";
  };
}
