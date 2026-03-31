{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../common/darwin.nix
    ../../common/nix-common.nix
    ./aerospace.nix
  ];

  homebrew = {
    taps = [
      {
        name = "caarlos0/tap";
      }
    ];
    brews = [
      {
        # TODO: Unfuck CargoBrazil integration
        name = "rust-analyzer";
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
        # Service auto-starts via LaunchAgent plist on login.
        # start_service/restart_service trigger brew services JSON
        # parsing that fails under darwin-rebuild's sudo context.
      }
    ];
    casks = [
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

  networking.hostName = "m3-work-laptop";

  nix = {
    settings = {
      max-substitution-jobs = 20;
      trusted-users = [ "angaidan" ];
    };
  };

  services.sketchybar.enable = true;

  # JankyBorders: colored window borders. The nix-darwin module manages launchd
  # lifecycle and passes all config as CLI args (no config file needed).
  # Color values must stay in sync with sketchybar-theme.nix (border_active).
  services.jankyborders = {
    enable = true;
    style = "round";
    active_color = "0xffe1e3e4";
    inactive_color = "0xee494d64";
    width = 10.0;
    hidpi = true;
    # ax_focus uses the Accessibility API for focus detection, which is more
    # accurate with AeroSpace but requires TCC permission. The nix store path
    # changes on rebuild, invalidating path-based TCC grants. Disabled until
    # a .app bundle wrapper (like sketchybar's) is added to stabilize TCC.
    ax_focus = false;
  };

  # Point launchd at a stable .app bundle path so macOS TCC identifies
  # sketchybar by CFBundleIdentifier (client_type=0) instead of bare nix
  # store path. This makes Accessibility permission survive nix rebuilds.
  # The activation script below keeps the bundle in sync with the nix store.
  launchd.user.agents.sketchybar.serviceConfig.ProgramArguments = lib.mkForce [
    "/Applications/SketchyBar.app/Contents/MacOS/sketchybar"
  ];

  system = {
    # Copy the .app bundle from the nix store to /Applications and codesign it.
    # The nix store is read-only, so codesign must target a mutable copy.
    # rsync --checksum avoids unnecessary copies when the binary hasn't changed.
    activationScripts.postActivation.text = ''
      echo "syncing SketchyBar.app bundle..." >&2
      ${pkgs.rsync}/bin/rsync \
        --archive \
        --checksum \
        --copy-unsafe-links \
        --delete \
        "${pkgs.sketchybar}/Applications/SketchyBar.app/" \
        "/Applications/SketchyBar.app/"

      echo "codesigning SketchyBar.app bundle..." >&2
      /usr/bin/codesign -fs - --identifier "com.local.sketchybar" \
        "/Applications/SketchyBar.app" 2>&1 || true
    '';

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
