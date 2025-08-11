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

      shpool
    ];
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.11"; # Please read the comment before changing.
  };

  programs = {
    mise = {
      enable = true;
      globalConfig = {
        alias = {
          node = "node:ssh://git.amazon.com/pkg/RtxNode";
        };
        tools = {
          node = [
            # TODO: move to aliases once RtxNode gets it together
            # "lts-job" # v22
            # "lts-iron" # v20
            # "lts-hydrogen" # v18
            # NOTE: First one becomes default
            "22"
            "20"
            "18"
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
            home-manager switch --flake ~/.config/nix#al2-x86-cdd --option access-tokens "github.com=$GITHUB_TOKEN"
            zsource
          '';
        up = "sudo yum upgrade -y && nixup";
      };
    };
  };

  # TODO: Extract to nix module
  systemd.user = {
    enable = true;
    # From https://github.com/shell-pool/shpool/blob/master/systemd/shpool.service
    services.shpool = {
      Unit = {
        Description = "Shpool - Shell Session Pool";
        Requires = [ "shpool.socket" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.shpool}/bin/shpool daemon";
        KillMode = "mixed";
        TimeoutStopSec = "2s";
        SendSIGHUP = "yes";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # From https://github.com/shell-pool/shpool/blob/master/systemd/shpool.socket
    sockets.shpool = {
      Unit = {
        description = "Shpool Shell Session Pooler";
      };

      Socket = {
        ListenStream = "%t/shpool/shpool.socket";
        SocketMode = "0600";
      };

      Install = {
        WantedBy = [ "sockets.target" ];
      };
    };
  };

  targets.genericLinux.enable = true;
}
