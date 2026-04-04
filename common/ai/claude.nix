{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ../../pkgs/claude-code-acp { })
  ];
}
