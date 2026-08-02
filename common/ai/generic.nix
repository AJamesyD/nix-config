{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.mcp.enable = true;

  home.packages = with pkgs; [
    opencode
    (callPackage ../../pkgs/rtk { })
    (callPackage ../../pkgs/mcp-hub { })
    (callPackage ../../pkgs/claude-code-acp { })
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
  ];

  home.sessionVariables = {
    CLAUDE_CODE_EFFORT_LEVEL = mkDefault "high";
    CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = mkDefault "1";
    CLAUDE_CODE_NO_FLICKER = mkDefault "1";
    CLAUDE_CODE_TMUX_TRUECOLOR = mkDefault "1";
    CLAUDE_CONFIG_DIR = mkDefault "${config.xdg.configHome}/claude";
    ANTHROPIC_MODEL = mkDefault "claude-opus-4-6";
    DISABLE_AUTO_COMPACT = mkDefault "1";
    ANTHROPIC_DEFAULT_OPUS_MODEL = mkDefault "claude-opus-4-6";
    ANTHROPIC_DEFAULT_SONNET_MODEL = mkDefault "claude-sonnet-4-6";

    OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
    OPENCODE_ENABLE_EXA = "1";
    OPENCODE_DISABLE_AUTOUPDATE = "1";
    OPENCODE_EXPERIMENTAL_PLAN_MODE = "1";
    OPENCODE_DISABLE_LSP_DOWNLOAD = "1";

    PI_SKIP_VERSION_CHECK = "1";
    PI_TELEMETRY = "0";
    PI_CACHE_RETENTION = "long";
  };
}
