{
  pkgs,
  ...
}:
{
  imports = [
    ../../common/aws.nix
    ../../common/dev.nix
    ../../common/nix.nix
  ];

  home = {
    packages = with pkgs; [
      (lib.hiPrio opensshWithKerberos)
      stylua
    ];
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.05"; # Please read the comment before changing.
  };

  programs = {
    mise = {
      enable = true;
      globalConfig = {
        plugins = {
          node = "ssh://git.amazon.com/pkg/RtxNode";
        };
        tools = {
          node = [
            # TODO: move to aliases once RtxNode gets it together
            # "lts-gallium" # v16
            # "lts-hydrogen" # v18
            # "20" # iron
            "16.20.0"
            "18.20.2"
            "20.10.0"
          ];
        };
      };
    };
    zsh = {
      enable = true;
      shellAliases = {
        auth = "mwinit -o && kinit -f";
        nixup = # bash
          ''
            ghauth &&
            nix flake update --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN"
            home-manager switch --flake ~/.config/nix#x86-dev-desk --option access-tokens "github.com=$GITHUB_TOKEN"
            zsource''; # Cannot have newline at end of command or else it won't be chainable
        up = "sudo yum upgrade -y && rustup update && nixup";
      };
    };
  };

  targets.genericLinux.enable = true;
}
