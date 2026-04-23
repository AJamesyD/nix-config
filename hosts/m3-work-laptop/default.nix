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
      serviceLabel ? null,
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

      ${lib.optionalString (serviceLabel != null) ''
        # Restart so the process loads the freshly-signed binary
        launchctl kickstart -k "gui/$(id -u)/${serviceLabel}" 2>/dev/null || true
      ''}
    '';

  aerospace-swipe = pkgs.callPackage ../../pkgs/aerospace-swipe { };
in
{
  imports = [
    ../../common/darwin.nix
    ../../common/nix-common.nix
    ../../common/stylix.nix
    ./aerospace.nix
    ./kanata.nix
    ./hammerspoon.nix
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
        greedy = true;
      }
      {
        name = "ghostty";
        greedy = true;
      }
      {
        name = "hammerspoon";
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
    };
  };

  services.sketchybar.enable = true;

  # JankyBorders: colored window borders. The nix-darwin module manages launchd
  # lifecycle and passes all config as CLI args (no config file needed).
  services.jankyborders = {
    enable = true;
    style = "round";
    width = 10.0;
    # HiDPI quadruples per-border texture memory (~15 MB/window).
    # Disabled to reduce ~310 MB baseline to ~80 MB across 20 windows.
    hidpi = false;
    ax_focus = true;
    # 50% alpha on inactive border so it fades into background.
    # Uses stylix base03 (comments/muted) for theme durability.
    inactive_color = lib.mkForce "0x80${config.lib.stylix.colors.base03}";
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
      "order=${cfg.order}"
    ];

  system = {
    activationScripts.postActivation.text = ''
      ${mkTccApp {
        src = "${pkgs.sketchybar}/Applications/SketchyBar.app";
        name = "SketchyBar";
        identifier = "com.local.sketchybar";
        serviceLabel = "org.nixos.sketchybar";
      }}
      ${mkTccApp {
        src = "${pkgs.jankyborders}/Applications/JankyBorders.app";
        name = "JankyBorders";
        identifier = "com.local.jankyborders";
        serviceLabel = "org.nixos.jankyborders";
      }}
      ${mkTccApp {
        src = "${aerospace-swipe}/Applications/AerospaceSwipe.app";
        name = "AerospaceSwipe";
        identifier = "com.acsandmann.swipe";
        entitlements = "${aerospace-swipe}/share/aerospace-swipe/entitlements.plist";
        serviceLabel = "com.acsandmann.swipe";
      }}

      # HACK: neutralize Amazon Connections (no official opt-out exists).
      #   ACME re-deploys the app, so this must re-apply on every rebuild.
      #   Remove if Amazon adds an official disable mechanism.
      #   Context: https://sage.amazon.com/posts/1459829
      conn_main="/Applications/AmazonConnections.app/Contents/Resources/app/main.js"
      if [ -f "$conn_main" ] && ! head -1 "$conn_main" | grep -q 'app.quit' 2>/dev/null; then
        cp "$conn_main" "''${conn_main}.bak"
        printf 'require("electron").app.quit();\n' > "$conn_main"
        echo "neutralized Amazon Connections (backup at ''${conn_main}.bak)" >&2
      fi
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
