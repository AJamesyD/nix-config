# Zen Browser configuration via zen-browser-flake.
# Binary installed via Homebrew cask; Nix manages config only.
{ inputs, ... }:
{
  imports = [ inputs.zen-browser.homeModules.default ];

  programs.zen-browser = {
    enable = true;
    package = null; # Homebrew cask manages the binary
    profiles.default = {
      isDefault = true;
      settings = import ./settings.nix;
    };
  };

  # Files not covered by zen-browser-flake's HM module
  home.file =
    let
      zenProfile = "Library/Application Support/Zen/Profiles/default";
    in
    {
      "${zenProfile}/zen-keyboard-shortcuts.json".source = ./zen-keyboard-shortcuts.json;
      "${zenProfile}/handlers.json".source = ./handlers.json;
    };
}
