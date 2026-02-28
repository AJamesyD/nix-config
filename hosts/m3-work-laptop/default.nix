{
  pkgs,
  ...
}:
{
  imports = [
    ../../common/darwin.nix
    ../../common/nix-common.nix
  ];
  environment = {
    systemPath = [
      # Comes from XQuartz
      "/opt/X11/bin"
    ];
  };

  homebrew = {
    taps = [
      {
        name = "caarlos0/tap";
      }
      {
        name = "FelixKratz/formulae";
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
        name = "terminal-notifier";
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
        name = "orbstack";
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
        name = "zed@preview";
        greedy = true;
      }
      {
        name = "zen";
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

  # nix-darwin requires a hostname; this is the machine's hardware UUID
  networking.hostName = "80a99738471f";

  nix = {
    settings = {
      max-substitution-jobs = 20;
      trusted-users = [ "angaidan" ];
    };
  };

  system = {
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
    uid = 503;
  };
}
