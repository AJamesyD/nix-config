{
  pkgs,
  ...
}:
{
  # AeroSpace: tiling window manager. The nix-darwin module generates TOML
  # from these settings and manages launchd lifecycle (start-at-login is
  # handled internally via launchd, not the AeroSpace config flag).
  services.aerospace = {
    enable = true;
    settings = {
      # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 30;

      default-root-container-layout = "tiles";

      default-root-container-orientation = "auto";

      # Mouse follows focus when focused monitor changes
      # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
      # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
      on-focus-changed = [ "move-mouse window-lazy-center" ];

      # Effectively turn off macOS "Hide application" (cmd-h) feature
      # Also see: https://nikitabobko.github.io/AeroSpace/goodies#disable-hide-app
      automatically-unhide-macos-hidden-apps = true;

      # Notify Sketchybar about workspace change
      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "/run/current-system/sw/bin/sketchybar --trigger aerospace_workspace_change AEROSPACE_FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE AEROSPACE_PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
      ];

      # Notify Sketchybar about binding mode changes
      # on-mode-changed takes Aerospace commands (not a process array like exec-on-*).
      on-mode-changed = [
        "exec-and-forget /run/current-system/sw/bin/sketchybar --trigger aerospace_mode_change AEROSPACE_MODE=\"$(${pkgs.aerospace}/bin/aerospace list-modes --current 2>/dev/null || echo main)\""
      ];

      # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
      key-mapping.preset = "qwerty";

      # Gaps between windows (inner-*) and between monitor edges (outer-*).
      gaps = {
        inner = {
          horizontal = 10;
          vertical = 10;
        };
        outer = {
          bottom = 5;
          left = 5;
          right = 5;
          top = 10; # To accommodate Sketchybar
        };
      };

      mode = {
        # 'main' binding mode declaration
        # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
        main.binding = {
          "cmd-h" = [ ]; # Disable "hide application"
          "cmd-alt-h" = [ ]; # Disable "hide others"

          ### Move focus ###
          "cmd-shift-f" = "fullscreen";

          "cmd-shift-h" = "focus left --boundaries all-monitors-outer-frame --boundaries-action stop";
          "cmd-shift-j" = "focus down --boundaries all-monitors-outer-frame --boundaries-action stop";
          "cmd-shift-k" = "focus up --boundaries all-monitors-outer-frame --boundaries-action stop";
          "cmd-shift-l" = "focus right --boundaries all-monitors-outer-frame --boundaries-action stop";

          "cmd-shift-1" = "workspace 1-dev";
          "cmd-shift-2" = "workspace 2-browser";
          "cmd-shift-3" = "workspace 3-admin";
          "cmd-shift-4" = "workspace 4-chat";
          "cmd-shift-5" = "workspace 5-video-call";
          "cmd-shift-6" = "workspace 6";
          "cmd-shift-7" = "workspace 7";
          "cmd-shift-8" = "workspace 8";
          "cmd-shift-9" = "workspace 9-entertainment";
          "cmd-shift-0" = "workspace 0-misc";
          "cmd-shift-d" = "workspace 1-dev";
          "cmd-shift-b" = "workspace 2-browser";
          "cmd-shift-a" = "workspace 3-admin";
          "cmd-shift-c" = "workspace 4-chat";
          "cmd-shift-v" = "workspace 5-video-call";
          "cmd-shift-e" = "workspace 9-entertainment";
          "cmd-shift-m" = "workspace 0-misc";
          "cmd-shift-i" = "workspace ignored";

          # Toggle between current and previous workspace ("other")
          "cmd-shift-o" = "workspace-back-and-forth";

          # Enter service mode (rare layout operations, see mode.service.binding)
          "cmd-shift-semicolon" = "mode service";

          # Enter resize mode (repeated fine-grained window sizing, see mode.resize.binding)
          "cmd-shift-alt-r" = "mode resize";

          ### Move windows within workspace ###
          "cmd-shift-alt-comma" = "layout tiles accordion";
          "cmd-shift-alt-period" = "layout horizontal vertical";
          "cmd-shift-alt-slash" = "layout floating tiling";

          "cmd-shift-alt-equal" = "resize smart +50";
          "cmd-shift-alt-minus" = "resize smart -50";

          "cmd-shift-alt-left" = "resize width -50";
          "cmd-shift-alt-down" = "resize height +50";
          "cmd-shift-alt-up" = "resize height -50";
          "cmd-shift-alt-right" = "resize width +50";

          "cmd-shift-alt-h" =
            "exec-and-forget (aerospace move left --boundaries all-monitors-outer-frame --boundaries-action fail && aerospace move-mouse window-lazy-center) || move-node-to-window left --focus-follows-window";
          "cmd-shift-alt-j" =
            "exec-and-forget (aerospace move down --boundaries all-monitors-outer-frame --boundaries-action fail && aerospace move-mouse window-lazy-center) || move-node-to-window down --focus-follows-window";
          "cmd-shift-alt-k" =
            "exec-and-forget (aerospace move up --boundaries all-monitors-outer-frame --boundaries-action fail && aerospace move-mouse window-lazy-center) || move-node-to-window up --focus-follows-window";
          "cmd-shift-alt-l" =
            "exec-and-forget (aerospace move right --boundaries all-monitors-outer-frame --boundaries-action fail && aerospace move-mouse window-lazy-center) || move-node-to-window right --focus-follows-window";

          ### Move workspaces and windows within workspaces ###
          "cmd-shift-alt-ctrl-left" = "move-workspace-to-monitor left";
          "cmd-shift-alt-ctrl-down" = "move-workspace-to-monitor down";
          "cmd-shift-alt-ctrl-up" = "move-workspace-to-monitor up";
          "cmd-shift-alt-ctrl-right" = "move-workspace-to-monitor right";

          "cmd-shift-alt-ctrl-1" = "move-node-to-workspace 1-dev --focus-follows-window";
          "cmd-shift-alt-ctrl-2" = "move-node-to-workspace 2-browser --focus-follows-window";
          "cmd-shift-alt-ctrl-3" = "move-node-to-workspace 3-admin --focus-follows-window";
          "cmd-shift-alt-ctrl-4" = "move-node-to-workspace 4-chat --focus-follows-window";
          "cmd-shift-alt-ctrl-5" = "move-node-to-workspace 5-video-call --focus-follows-window";
          "cmd-shift-alt-ctrl-6" = "move-node-to-workspace 6 --focus-follows-window";
          "cmd-shift-alt-ctrl-7" = "move-node-to-workspace 7 --focus-follows-window";
          "cmd-shift-alt-ctrl-8" = "move-node-to-workspace 8 --focus-follows-window";
          "cmd-shift-alt-ctrl-9" = "move-node-to-workspace 9-entertainment --focus-follows-window";
          "cmd-shift-alt-ctrl-0" = "move-node-to-workspace 0-misc --focus-follows-window";
          "cmd-shift-alt-ctrl-a" = "move-node-to-workspace 3-admin --focus-follows-window";

          "cmd-shift-alt-ctrl-d" = "move-node-to-workspace 1-dev --focus-follows-window";
          "cmd-shift-alt-ctrl-b" = "move-node-to-workspace 2-browser --focus-follows-window";
          "cmd-shift-alt-ctrl-c" = "move-node-to-workspace 4-chat --focus-follows-window";
          "cmd-shift-alt-ctrl-v" = "move-node-to-workspace 5-video-call --focus-follows-window";
          "cmd-shift-alt-ctrl-e" = "move-node-to-workspace 9-entertainment --focus-follows-window";
          "cmd-shift-alt-ctrl-m" = "move-node-to-workspace 0-misc --focus-follows-window";
          "cmd-shift-alt-ctrl-i" = "move-node-to-workspace ignored --focus-follows-window";

          ### Misc ###
          "cmd-shift-alt-ctrl-r" =
            "exec-and-forget aerospace reload-config; aerospace enable off; aerospace enable on";
        };

        # Service mode: one-shot commands for rare layout operations
        # Entry: Cmd+Shift+; (semicolon tap, right pinky home on split columnar)
        # All bindings auto-return to main mode. Sketchybar shows available keys.
        service.binding = {
          esc = "mode main";
          r = [
            "flatten-workspace-tree"
            "mode main"
          ];
          b = [
            "balance-sizes"
            "mode main"
          ];
          f = [
            "layout floating tiling"
            "mode main"
          ];
          x = [
            "close-all-windows-but-current"
            "mode main"
          ];
          n = [
            "mode main"
            "macos-native-fullscreen"
          ];

          # Swap windows (Shift = "move" convention from main mode)
          "shift-h" = [
            "swap left"
            "mode main"
          ];
          "shift-j" = [
            "swap down"
            "mode main"
          ];
          "shift-k" = [
            "swap up"
            "mode main"
          ];
          "shift-l" = [
            "swap right"
            "mode main"
          ];

          # Join with direction (create nested containers)
          h = [
            "join-with left"
            "mode main"
          ];
          j = [
            "join-with down"
            "mode main"
          ];
          k = [
            "join-with up"
            "mode main"
          ];
          l = [
            "join-with right"
            "mode main"
          ];
        };

        # Resize mode: persistent (bare keys stay in mode for repeated adjustments)
        # Entry: Cmd+Shift+Alt+R
        # Unlike service mode, resize keys do NOT auto-return to main.
        # Use esc or enter to exit when done.
        resize.binding = {
          esc = "mode main";
          enter = "mode main";
          h = "resize width -50";
          j = "resize height +50";
          k = "resize height -50";
          l = "resize width +50";
          minus = "resize smart -50";
          equal = "resize smart +50";
          b = [
            "balance-sizes"
            "mode main"
          ];
          f = [
            "fullscreen"
            "mode main"
          ];
        };
      };

      on-window-detected = [
        {
          "if".app-name-regex-substring = "SecurityAgent";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.finder";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.systempreferences";
          run = "layout floating";
        }
        {
          "if".app-id = "com.raycast.macos";
          run = "layout floating";
        }
        {
          "if".app-id = "org.alacritty";
          run = "move-node-to-workspace 1-dev";
        }
        # Ghostty uses native macOS tabs, which the macOS API exposes as separate
        # windows. AeroSpace tiles each tab as its own window without this workaround.
        # Float by default, then manually unfloat (cmd-shift-alt-slash) when needed.
        # Tracking: https://github.com/nikitabobko/AeroSpace/issues/68
        # See also: https://ghostty.org/docs/help/macos-tiling-wms
        {
          "if".app-id = "com.mitchellh.ghostty";
          run = [
            "layout floating"
            "move-node-to-workspace 1-dev"
          ];
        }
        {
          "if".app-id = "net.kovidgoyal.kitty";
          run = "move-node-to-workspace 1-dev";
        }
        {
          "if".window-title-regex-substring = "neovide";
          run = [
            "layout floating"
            "move-node-to-workspace 1-dev"
          ];
        }
        {
          "if".app-id = "dev.kdrag0n.MacVirt";
          run = "move-node-to-workspace 1-dev";
        }
        {
          "if".app-id = "com.electron.goose";
          run = "move-node-to-workspace 1-dev";
        }
        {
          "if".app-id = "dev.zed.Zed-Preview";
          run = "move-node-to-workspace 1-dev";
        }
        {
          "if".app-id = "dev.zed.Zed";
          run = "move-node-to-workspace 1-dev";
        }
        {
          "if".app-id = "org.mozilla.firefox";
          run = "move-node-to-workspace 2-browser";
        }
        {
          "if".app-id = "app.zen-browser.zen";
          run = "move-node-to-workspace 2-browser";
        }
        {
          "if" = {
            app-id = "com.microsoft.Outlook";
            window-title-regex-substring = "Reminder";
          };
          run = [
            "layout floating"
            "move-node-to-workspace 3-admin"
          ];
        }
        {
          "if".app-id = "com.microsoft.Outlook";
          run = "move-node-to-workspace 3-admin";
        }
        {
          "if".app-id = "md.obsidian";
          run = "move-node-to-workspace 3-admin";
        }
        {
          "if" = {
            app-id = "com.tinyspeck.slackmacgap";
            window-title-regex-substring = "Huddle";
          };
          run = "move-node-to-workspace 5-video-call";
        }
        {
          "if".app-id = "com.tinyspeck.slackmacgap";
          run = "move-node-to-workspace 4-chat";
        }
        {
          "if".app-id = "org.zulip.zulip-electron";
          run = "move-node-to-workspace 4-chat";
        }
        {
          "if".app-id = "com.amazon.Amazon-Chime";
          run = "move-node-to-workspace 5-video-call";
        }
        {
          "if".app-id = "us.zoom.xos";
          run = "move-node-to-workspace 5-video-call";
        }
        {
          "if".app-id = "com.spotify.client";
          run = "move-node-to-workspace 9-entertainment";
        }
        {
          "if".app-id = "com.cisco.anyconnect.gui";
          run = [
            "layout floating"
            "move-node-to-workspace 0-misc"
          ];
        }
        {
          run = "move-node-to-workspace 0-misc";
        }
      ];

      # Monitor assignments
      # Work:  P32p-20 (2) = horizontal main, P32p-20 (1) = vertical, Built-in = laptop
      # Home:  P32p-20 (single, no suffix) = horizontal main, Dell = vertical, Built-in = laptop
      workspace-to-monitor-force-assignment = {
        "0-misc" = "built-in";
        "1-dev" = [
          "P32p-20 \\(2\\)"
          "P32p-20"
          "secondary"
        ];
        "2-browser" = "built-in";
        "3-admin" = [
          "P32p-20 \\(1\\)"
          "dell"
          "secondary"
        ];
        "4-chat" = "built-in";
        "5-video-call" = "built-in";
        "9-entertainment" = [
          "P32p-20 \\(1\\)"
          "dell"
          "secondary"
        ];
        ignored = [
          "P32p-20 \\(2\\)"
          "P32p-20"
          "secondary"
        ];
      };
    };
  };
}
