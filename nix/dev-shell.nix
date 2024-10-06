{
  config,
  self',
  pkgs,
  ...
}:
{
  default = pkgs.mkShell {
    name = "nix-config";

    nativeBuildInputs = with pkgs; [
      # Nix
      nil
      nix-output-monitor
      nix-tree
      # self'.packages.cachix
      # self'.packages.nix-fast-build
      statix

      # Shell
      shellcheck
      shfmt

      # Misc
      pre-commit
    ];
    # ++ config.pre-commit.settings.enabledPackages;
    shellHook = ''
      ${config.pre-commit.installationScript}
    '';
  };
}
