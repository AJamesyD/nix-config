{
  config,
  pkgs,
  lib,
  ...
}:
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
        name = "ghostty";
      }
      {
        name = "block-goose";
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
      trusted-users = [ "angaidan" ];
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

  # Same TCC stabilization as sketchybar: run from a stable .app bundle
  # so Accessibility permission survives nix rebuilds.
  # TODO: replace with a jankyborders overlay (like overlays/sketchybar.nix)
  # to avoid duplicating the nix-darwin module's arg construction logic.
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

            echo "syncing JankyBorders.app bundle..." >&2
            mkdir -p /Applications/JankyBorders.app/Contents/MacOS
            cat > /Applications/JankyBorders.app/Contents/Info.plist <<'PLIST'
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
        "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleExecutable</key>
        <string>borders</string>
        <key>CFBundleIdentifier</key>
        <string>com.local.jankyborders</string>
        <key>CFBundleName</key>
        <string>JankyBorders</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
      </dict>
      </plist>
      PLIST
            printf 'APPL????' > /Applications/JankyBorders.app/Contents/PkgInfo
            ${pkgs.rsync}/bin/rsync \
              --archive \
              --checksum \
              "${config.services.jankyborders.package}/bin/borders" \
              "/Applications/JankyBorders.app/Contents/MacOS/borders"

            echo "codesigning JankyBorders.app bundle..." >&2
            /usr/bin/codesign -fs - --identifier "com.local.jankyborders" \
              "/Applications/JankyBorders.app" 2>&1 || true
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
