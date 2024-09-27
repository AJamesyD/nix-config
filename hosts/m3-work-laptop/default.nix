{
  self,
  pkgs,
  ...
}:
{
  imports = [
    ../../common/darwin.nix
    ../../common/nix.nix
  ];
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment = {
    # TODO: par down and move to home-manager installation
    systemPackages =
      with pkgs;
      [
      ];
  };

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
    settings = {
      trusted-users = [ "angaidan" ];
    };
  };

  services = {
    jankyborders = {
      enable = true;
      active_color = "0xffe1e3e4";
      inactive_color = "0xff494d64";
      hidpi = true;
      width = 7.5;
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
    name = "angaidan";
    home = "/Users/angaidan";
  };
}
