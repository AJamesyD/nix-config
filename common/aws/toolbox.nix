# NOTE: Tools managed here must NOT also appear in home.packages.
# Toolbox provides Amazon-specific wrappers (credentials, routing).
# Nix manages open-source tools without Amazon integrations.
{ pkgs, lib, ... }:
{
  programs.toolbox = {
    enable = true;

    # Specialized modules (handle registries, config files, defaults)
    aim.enable = true;
    brazil-cli.enable = true;
    cr.enable = true;
    eda.enable = true;
    kiro.cli.enable = true;
    # NOTE: toolbox rust-analyzer only supports AL2; nix provides it on darwin.
    rust-analyzer.enable = pkgs.stdenv.isLinux;

    registries.cr-guide.uri = "s3://code-review-guide-toolbox-registry/tools.json";
    registries.bh.uri = "s3://buildertoolbox-bh-us-west-2/tools.json";

    brazil-cli.settings = lib.optionalAttrs pkgs.stdenv.isDarwin {
      # NOTE: lowercase `packagecache` is the host-side cache section.
      # Distinct from the module's auto-generated `[packageCache]` (capital C) sandbox section.
      packagecache = {
        cacheRoot = "/Volumes/brazil-pkg-cache";
        visibleCacheRoot = "/Volumes/brazil-pkg-cache";
      };
    };

    # NOTE: Node for brazil-build (npm-pretty-much / cdk-build), pinned to nixpkgs and set
    # declaratively: brazil.prefs is a read-only nix store symlink, so `brazil setup --node`
    # (which writes the same key) fails with EACCES. The `node<major>x` key under
    # `[cli "bin"]` is brazil's scheme; add e.g. node22x the same way for another major.
    # Darwin-only: the al2 CDD uses RtxNode via mise.
    brazil-cli.runtimes = lib.optionalAttrs pkgs.stdenv.isDarwin {
      node24x = "${pkgs.nodejs_24}/bin/node";
    };

    tools = {
      ada.enable = true;
      barium.enable = true;
      bh = {
        enable = true;
        extraFlags = lib.optionals pkgs.stdenv.isDarwin [
          "--force-os"
          "osx_arm64"
        ];
      };
      bemol.enable = true;
      builder-mcp.enable = true;
      claude-code.enable = true;
      create.enable = true;
      cr-guide.enable = true;
      pipeline.enable = true;
    };
  };
}
