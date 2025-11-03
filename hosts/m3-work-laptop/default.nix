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
    systemPath = [
      # Comes from XQuartz
      "/opt/X11/bin"
    ];
  };

  homebrew = {
    enable = true;
    taps = [
      {
        name = "caarlos0/tap";
      }
      {
        name = "FelixKratz/formulae";
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
        name = "borders";
      }
      {
        # TODO: Unfuck CargoBrazil integration
        name = "rust-analyzer";
      }
      {
        name = "sketchybar";
      }
      # For mise python-build
      {
        name = "openssl";
      }
      {
        name = "readline";
      }
      {
        name = "sqlite3";
      }
      {
        name = "tcl-tk";
      }
      {
        name = "xz";
      }
      {
        name = "zlib";
      }
      # For Ruby 2.7 build
      {
        name = "libffi";
      }
      {
        name = "libyaml";
      }
      {
        name = "rbenv";
      }
      {
        name = "ruby-build";
      }
      # Other
      {
        name = "ruby@3.2";
      }
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
      # {
      #   name = "eloston-chromium";
      #   args = {
      #     no_quarantine = true;
      #   };
      #   greedy = true;
      # }
      {
        name = "ghostty";
        greedy = true;
      }
      {
        name = "block-goose";
        greedy = true;
      }
      {
        name = "neovide-app";
        greedy = true;
      }
      {
        name = "obsidian";
        greedy = true;
      }
      {
        name = "orbstack";
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
        name = "visual-studio-code";
        greedy = true;
      }
      {
        name = "xquartz";
        greedy = true;
      }
      {
        name = "zed";
        greedy = true;
      }
      {
        name = "zen";
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
      download-buffer-size = 500 * 1024 * 1024; # 500MB
      max-substitution-jobs = 20;
      trusted-users = [ "angaidan" ];
    };
  };

  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      dock = {
        persistent-apps = [
          "Applications/Microsoft Outlook.app"
          "Applications/Obsidian.app"
          "Applications/Amazon Chime.app"
          "Applications/zoom.us.app"
          "Applications/Slack.app"
          "Applications/Zulip.app"
          "Applications/Zen.app"
          "Applications/Ghostty.app"
        ];
      };
      spaces = {
        # This is for AeroSpace
        spans-displays = true;
      };
    };

    primaryUser = "angaidan";

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
