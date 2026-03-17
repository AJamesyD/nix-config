{ pkgs, ... }:
{
  imports = [
    ./claude.nix
  ];

  home.packages = [
    pkgs.opencode
    (pkgs.callPackage ../../pkgs/claude-code-acp { })
    (pkgs.callPackage ../../pkgs/mcp-hub { })
  ];

  # OpenCode requires these env vars for features that have no config-file
  # equivalent (as of 2026-03). Set here so they apply in every shell session,
  # not just when direnv activates in the opencode project directory.
  home.sessionVariables = {
    OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
    OPENCODE_ENABLE_EXA = "1";
  };
}
