# NOTE: Tools managed here must NOT also appear in home.packages.
# Toolbox provides Amazon-specific wrappers (credentials, routing).
# Nix manages open-source tools without Amazon integrations.
{ pkgs, ... }:
{
  programs.toolbox = {
    enable = true;

    # Specialized modules (handle registries, config files, defaults)
    aim.enable = true;
    brazil-cli.enable = true;
    cr.enable = true;
    eda.enable = true;
    kiro.cli.enable = true;
    rust-analyzer.enable = pkgs.stdenv.isLinux;

    registries.cr-guide.uri = "s3://code-review-guide-toolbox-registry/tools.json";

    tools = {
      ada.enable = true;
      barium.enable = true;
      bemol.enable = true;
      builder-mcp.enable = true;
      claude-code.enable = true;
      cr-guide.enable = true;
      pipeline.enable = true;
    };
  };
}
