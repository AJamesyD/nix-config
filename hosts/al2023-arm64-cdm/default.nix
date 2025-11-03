{
  pkgs,
  ...
}:
{
  imports = [
    ../../common/aws.nix
    ../../common/dev.nix
    ../../common/nix-hm.nix
  ];

  home = {
    packages = with pkgs; [
      (lib.hiPrio opensshWithKerberos)
      krb5

      ruby

      stylua

      # https://github.com/nixos/nixpkgs/issues/456113
      cargo-nextest
    ];
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.11"; # Please read the comment before changing.
  };

  programs = {
    mise = {
      enable = true;
      globalConfig = {
        tools = {
          node = [
            # NOTE: First one becomes default
            "20" # iron
            "lts-hydrogen" # v18
            "lts-gallium" # v16
          ];
        };
      };
    };
    zsh = {
      enable = true;
      shellAliases = {
        auth = "mwinit -o";
        nixup = # bash
          ''
            ghauth
            nix flake update --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN"
            home-manager switch --flake ~/.config/nix#al2023-arm64-cdm --option access-tokens "github.com=$GITHUB_TOKEN"
            zsource''; # Cannot have newline at end of command or else it won't be chainable
        up = # bash
          ''
            sudo yum upgrade -y
            nixup
          '';
      };
    };
  };

  services.shpool.enable = true;
}
