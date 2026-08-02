_: {
  home.sessionVariables = {
    # Amazon CRIS-routed model endpoints (override generic.nix mkDefault values)
    ANTHROPIC_MODEL = "us.anthropic.claude-opus-4-6-v1";
    ANTHROPIC_DEFAULT_OPUS_MODEL = "us.anthropic.claude-opus-4-6-v1";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "us.anthropic.claude-sonnet-4-6";
  };
}
