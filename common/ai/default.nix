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
    (pkgs.callPackage ../../pkgs/claude-code-acp { })
    # programs.mcp manages config only; mcp-hub provides the server binary
    (pkgs.callPackage ../../pkgs/mcp-hub { })
  ];

  home.sessionVariables = {
    # -- OpenCode --
    OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
    OPENCODE_ENABLE_EXA = "1";
    OPENCODE_DISABLE_AUTOUPDATE = "1"; # nix manages the binary
    OPENCODE_EXPERIMENTAL_PLAN_MODE = "1"; # structured 5-phase planning workflow
    OPENCODE_DISABLE_LSP_DOWNLOAD = "1"; # use nix-provided LSPs from PATH

    # -- Claude Code --
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"; # disables autoupdater, telemetry, error reporting, feedback
    USE_BUILTIN_RIPGREP = "0"; # use system rg (common/cli.nix) instead of bundled copy
  };
}
