{
  config,
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [
    inputs.llm-agents.packages.${pkgs.system}.claude-code
    (pkgs.callPackage ../../pkgs/claude-code-acp { })
  ];

  home.sessionVariables = {
    CLAUDE_CODE_USE_BEDROCK = "1";
    CLAUDE_CODE_EFFORT_LEVEL = "high";
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
    CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1";
    CLAUDE_CODE_NO_FLICKER = "1";
    CLAUDE_CODE_TMUX_TRUECOLOR = "1";
    CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
    ANTHROPIC_MODEL = "us.anthropic.claude-opus-4-6-v1";
    # Disable auto-compaction: prefer fresh sessions with handoff notes
    DISABLE_AUTO_COMPACT = "1";
    # Model picker and subagent defaults (us. prefix = US-geo CRIS routing)
    ANTHROPIC_DEFAULT_OPUS_MODEL = "us.anthropic.claude-opus-4-6-v1";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "us.anthropic.claude-sonnet-4-6";
  };
}
