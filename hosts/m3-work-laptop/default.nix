{
  self,
  pkgs,
  ...
}:
{
  imports = [
    ../../common/darwin.nix
    ../../common/nix-hm.nix
  ];
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment = {
    systemPackages = with pkgs; [
      (lib.hiPrio opensshWithKerberos)

      (pkgs.callPackage "${toString pkgs.path}/pkgs/applications/office/libreoffice/darwin/default.nix"
        { }
      )

      alacritty
      kitty
    ];
    systemPath = [
      # Comes from XQuartz
      "/opt/X11/bin"
    ];
  };

  fonts.packages = [
    # TODO: Reduce duplication with terminals
    (pkgs.nerdfonts.override {
      fonts = [
        "FiraCode"
        "Hack"
        "IBMPlexMono"
        "JetBrainsMono"
        "VictorMono"
      ];
    })
  ];

  homebrew = {
    enable = true;
    taps = [
      {
        name = "amazon/homebrew-amazon";
        clone_target = "ssh://git.amazon.com/pkg/HomebrewAmazon";
        force_auto_update = true;
      }
      {
        name = "caarlos0/tap";
      }
      {
        name = "homebrew/services";
      }
      {
        name = "nikitabobko/tap";
      }
    ];
    brews = [
      {
        name = "xdg-open-svc";
        restart_service = "changed";
        start_service = true;
      }
    ];
    casks = [
      {
        name = "aerospace";
        greedy = true;
      }
      {
        name = "amazon-acronyms";
        greedy = true;
      }
      {
        name = "obsidian";
        greedy = true;
      }
      {
        name = "raycast";
        greedy = true;
      }
      {
        name = "spotify";
        greedy = true;
      }
      {
        name = "xquartz";
        greedy = true;
      }
      {
        name = "zoom";
        greedy = true;
      }
      {
        name = "zulip";
        greedy = true;
      }
    ];
  };

  home-manager = {
    users.angaidan = import ./home.nix;
  };

  # TODO: Is this safe to change?
  networking.hostName = "80a99738471f";

  nix = {
    linux-builder = {
      enable = true;
      config =
        { ... }:
        {
          # Lie in order to turn features on
          # _module.args.hostType = "nixos";
          _module.args.hostType = "darwin";
          imports = [ ../../common/nix-sys.nix ];
        };
      ephemeral = true;
      maxJobs = 4;
    };
    settings = {
      max-substitution-jobs = 20;
      trusted-users = [ "angaidan" ];
    };
  };

  services = {
    jankyborders = {
      enable = true;
      active_color = "0xffe1e3e4";
      inactive_color = "0xee494d64";
      width = 10.0;
    };
  };

  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      dock = {
        persistent-apps = [
          "Applications/Microsoft Outlook.app"
          "Applications/Amazon Chime.app"
          "Applications/Slack.app"
          "${pkgs.alacritty}/Applications/Alacritty.app"
        ];
      };
      spaces = {
        # This is for AeroSpace
        spans-displays = true;
      };
    };

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 5;
  };

  # Declare the user that will be running `nix-darwin`.
  users.users.angaidan = {
    home = "/Users/angaidan";
    name = "angaidan";
    shell = "/sbin/nologin";
  };
}
