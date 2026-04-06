{
  config,
  pkgs,
  lib,
  ...
}:
let
  mkTccApp =
    {
      src,
      name,
      identifier,
      entitlements ? null,
    }:
    ''
      echo "syncing ${name}.app bundle..." >&2
      ${pkgs.rsync}/bin/rsync \
        --archive --checksum --copy-unsafe-links --delete \
        "${src}/" "/Applications/${name}.app/"

      echo "codesigning ${name}.app bundle..." >&2
      /usr/bin/codesign \
        ${lib.optionalString (entitlements != null) "--entitlements \"${entitlements}\""} \
        -fs - --identifier "${identifier}" \
        "/Applications/${name}.app" 2>&1 || true
    '';

  aerospace-swipe = pkgs.callPackage ../../pkgs/aerospace-swipe { };
in
{
  imports = [
    ../../common/darwin.nix
    ../../common/nix-common.nix
    ../../common/stylix.nix
    ./aerospace.nix
  ];

  homebrew = {
    taps = [
      {
        name = "caarlos0/tap";
      }
    ];
    brews = [
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
        name = "block-goose";
      }
      {
        name = "ghostty";
      }
      {
        name = "hammerspoon";
      }
      {
        name = "neovide-app";
      }
      {
        name = "orbstack";
      }
      {
        name = "visual-studio-code";
      }
      {
        name = "zed";
      }
      {
        name = "zed@preview";
      }
      {
        name = "zen";
      }
      {
        name = "zulip";
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
    };
  };

  services.sketchybar.enable = true;

  # JankyBorders: colored window borders. The nix-darwin module manages launchd
  # lifecycle and passes all config as CLI args (no config file needed).
  services.jankyborders = {
    enable = true;
    style = "round";
    width = 10.0;
    hidpi = true;
    ax_focus = true;
  };

  # Point launchd at a stable .app bundle path so macOS TCC identifies
  # sketchybar by CFBundleIdentifier (client_type=0) instead of bare nix
  # store path. This makes Accessibility permission survive nix rebuilds.
  # The activation script below keeps the bundle in sync with the nix store.
  launchd.user.agents.sketchybar.serviceConfig.ProgramArguments = lib.mkForce [
    "/Applications/SketchyBar.app/Contents/MacOS/sketchybar"
  ];

  # TCC stabilization: run from a stable .app bundle so Accessibility
  # permission survives nix rebuilds. Args duplicate the nix-darwin module's
  # optionalArg construction because ProgramArguments can't self-reference.
  launchd.user.agents.jankyborders.serviceConfig.ProgramArguments =
    let
      cfg = config.services.jankyborders;
      bool = b: if b then "on" else "off";
    in
    lib.mkForce [
      "/Applications/JankyBorders.app/Contents/MacOS/borders"
      "style=${cfg.style}"
      "width=${toString cfg.width}"
      "hidpi=${bool cfg.hidpi}"
      "active_color=${cfg.active_color}"
      "inactive_color=${cfg.inactive_color}"
      "ax_focus=${bool cfg.ax_focus}"
      "blur_radius=${toString cfg.blur_radius}"
      "order=${cfg.order}"
    ];

  system = {
    activationScripts.postActivation.text = ''
      ${mkTccApp {
        src = "${pkgs.sketchybar}/Applications/SketchyBar.app";
        name = "SketchyBar";
        identifier = "com.local.sketchybar";
      }}
      ${mkTccApp {
        src = "${pkgs.jankyborders}/Applications/JankyBorders.app";
        name = "JankyBorders";
        identifier = "com.local.jankyborders";
      }}
      ${mkTccApp {
        src = "${aerospace-swipe}/Applications/AerospaceSwipe.app";
        name = "AerospaceSwipe";
        identifier = "com.acsandmann.swipe";
        entitlements = "${aerospace-swipe}/share/aerospace-swipe/entitlements.plist";
      }}
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
