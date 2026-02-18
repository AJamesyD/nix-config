{
  imports = [
    ./claude.nix
    ./ollama.nix
  ];

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
