{
  imports = [
    ./claude.nix
  ];

  # OpenCode requires these env vars for features that have no config-file
  # equivalent (as of 2026-03). Set here so they apply in every shell session,
  # not just when direnv activates in the opencode project directory.
  home.sessionVariables = {
    OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
    OPENCODE_ENABLE_EXA = "1";
  };

  xdg.configFile = {
    "mise/default-node-packages" = {
      text = ''
        @zed-industries/claude-code-acp
        mcp-hub
        opencode-ai
      '';
    };
  };
}
