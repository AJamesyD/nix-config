{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkPackageOption
    ;

  cfg = config.programs.worktrunk;
in
{
  options.programs.worktrunk = {
    enable = mkEnableOption "worktrunk, a git worktree manager";

    package = mkPackageOption pkgs "worktrunk" { };

    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Suppress first-run prompts that try to write to config.toml.
    # Without these, worktrunk asks interactively and writes the answer
    # to its config file (which may not exist or may be read-only).
    home.sessionVariables = {
      WORKTRUNK_SKIP_SHELL_INTEGRATION_PROMPT = "true";
      WORKTRUNK_SKIP_COMMIT_GENERATION_PROMPT = "true";
    };

    # Shell function that lets `wt switch` change the shell's working directory
    programs.zsh.initContent = mkIf cfg.enableZshIntegration ''
      eval "$(${getExe cfg.package} config shell init zsh)"
    '';
  };
}
