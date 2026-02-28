{ inputs, ... }:
{
  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
    ./activation.nix
    ./ai
    ./editor.nix
    ./git.nix
    ./languages.nix
    ./packages.nix
    ./programs.nix
    ./session.nix
    ./shell
    ./tmux
    ./zellij
  ];
}
