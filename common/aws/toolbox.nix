# NOTE: Tools managed here must NOT also appear in home.packages.
# Toolbox provides Amazon-specific wrappers (credentials, routing).
# Nix manages open-source tools without Amazon integrations.
{ pkgs, lib, ... }:
{
  programs.toolbox = {
    enable = true;

    # Specialized modules (handle registries, config files, defaults)
    aim = {
      enable = true;
      mcpServers = {
        cr-guide-mcp = { };
        sage-plus-service-mcp = { };
        slack-mcp = { };
      };
    };

    brazil-cli = {
      enable = true;

      settings = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        # NOTE: lowercase `packagecache` is the host-side cache section.
        # Distinct from the module's auto-generated `[packageCache]` (capital C) sandbox section.
        packagecache = {
          cacheRoot = "/Volumes/brazil-pkg-cache";
          visibleCacheRoot = "/Volumes/brazil-pkg-cache";
        };
      };

      # NOTE: Node/ruby for brazil-build (npm-pretty-much / cdk-build), pinned to nixpkgs and
      # set declaratively: brazil.prefs is a read-only nix store symlink, so `brazil setup`
      # (which writes the same keys) fails with EACCES. Keys follow brazil's `[cli "bin"]`
      # scheme: node<major>x and ruby<major><minor>. Add e.g. node26x the same way for a new
      # major. Darwin-only: this host-path override is only needed on macOS; the al2 CDD does
      # not use it.
      runtimes = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        node24x = "${pkgs.nodejs_24}/bin/node";
        node22x = "${pkgs.nodejs_22}/bin/node";
        ruby34 = "${pkgs.ruby_3_4}/bin/ruby";
      };
    };

    cr.enable = true;
    eda.enable = true;
    kiro.cli.enable = true;
    # NOTE: toolbox rust-analyzer only supports AL2; nix provides it on darwin.
    rust-analyzer.enable = pkgs.stdenv.hostPlatform.isLinux;

    registries = {
      bh.uri = "s3://buildertoolbox-bh-us-west-2/tools.json";
      cr-guide.uri = "s3://code-review-guide-toolbox-registry/tools.json";
    };

    tools = {
      ada.enable = true;
      axe.enable = true;
      barium.enable = true;
      bh.enable = true;
      bemol.enable = true;
      builder-mcp.enable = true;
      claude-code.enable = true;
      code-search.enable = true;
      cr-guide.enable = true;
      create.enable = true;
      gordian-knot.enable = true;
      ion.enable = true;
      pipeline.enable = true;
    };
  };
}
