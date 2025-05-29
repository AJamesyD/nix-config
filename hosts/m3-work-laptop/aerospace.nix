{
  after-login-command = [ ];
  start-at-login = true;
  enable-normalization-flatten-containers = true;
  enable-normalization-opposite-orientation-for-nested-containers = true;
  accordion-padding = 30;
  default-root-container-layout = "tiles";
  default-root-container-orientation = "auto";
  key-mapping = {
    preset = "qwerty";
  };
  on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
  on-focus-changed = [ "move-mouse window-lazy-center" ];
  automatically-unhide-macos-hidden-apps = true;
  gaps = {
    inner = {
      horizontal = 10;
      vertical = 10;
    };
    outer = {
      left = 5;
      bottom = 5;
      top = 5;
      right = 5;
    };
  };
  mode = {
    main = {
      binding = {
        # TODO: Find use for https://nikitabobko.github.io/AeroSpace/commands#summon-workspace
        cmd-h = [ ]; # Disable "hide application"
        cmd-alt-h = [ ]; # Disable "hide others"

        cmd-shift-f = "fullscreen";

        cmd-shift-h = "focus left --boundaries all-monitors-outer-frame --boundaries-action stop";
        cmd-shift-j = "focus down --boundaries all-monitors-outer-frame --boundaries-action stop";
        cmd-shift-k = "focus up --boundaries all-monitors-outer-frame --boundaries-action stop";
        cmd-shift-l = "focus right --boundaries all-monitors-outer-frame --boundaries-action stop";

        cmd-shift-alt-h = "exec-and-forget aerospace move left && aerospace move-mouse window-lazy-center";
        cmd-shift-alt-j = "exec-and-forget aerospace move down && aerospace move-mouse window-lazy-center";
        cmd-shift-alt-k = "exec-and-forget aerospace move up && aerospace move-mouse window-lazy-center";
        cmd-shift-alt-l = "exec-and-forget aerospace move right && aerospace move-mouse window-lazy-center";

        cmd-shift-alt-period = "layout horizontal vertical";
        cmd-shift-alt-comma = "layout tiles accordion";

        cmd-shift-alt-left = "resize width -50";
        cmd-shift-alt-down = "resize height +50";
        cmd-shift-alt-up = "resize height -50";
        cmd-shift-alt-right = "resize width +50";
        cmd-shift-alt-minus = "resize smart -50";
        cmd-shift-alt-equal = "resize smart +50";

        cmd-shift-alt-ctrl-h = "move-node-to-monitor left --focus-follows-window";
        cmd-shift-alt-ctrl-j = "move-node-to-monitor down --focus-follows-window";
        cmd-shift-alt-ctrl-k = "move-node-to-monitor up --focus-follows-window";
        cmd-shift-alt-ctrl-l = "move-node-to-monitor right --focus-follows-window";

        cmd-shift-alt-1 = "workspace 1-dev";
        cmd-shift-alt-d = "workspace 1-dev";
        cmd-shift-alt-2 = "workspace 2-firefox";
        cmd-shift-alt-f = "workspace 2-firefox";
        cmd-shift-alt-3 = "workspace 3-admin";
        cmd-shift-alt-a = "workspace 3-admin";
        cmd-shift-alt-4 = "workspace 4-slack";
        cmd-shift-alt-s = "workspace 4-slack";
        cmd-shift-alt-5 = "workspace 5-chime";
        cmd-shift-alt-c = "workspace 5-chime";
        cmd-shift-alt-6 = "workspace 6-entertainment";
        cmd-shift-alt-e = "workspace 6-entertainment";
        cmd-shift-alt-7 = "workspace 7-misc";
        cmd-shift-alt-m = "workspace 7-misc";
        cmd-shift-alt-8 = "workspace 8";
        cmd-shift-alt-i = "workspace ignored";

        cmd-shift-alt-ctrl-1 = "move-node-to-workspace 1-dev --focus-follows-window";
        cmd-shift-alt-ctrl-d = "move-node-to-workspace 1-dev --focus-follows-window";
        cmd-shift-alt-ctrl-2 = "move-node-to-workspace 2-firefox --focus-follows-window";
        cmd-shift-alt-ctrl-f = "move-node-to-workspace 2-firefox --focus-follows-window";
        cmd-shift-alt-ctrl-3 = "move-node-to-workspace 3-admin --focus-follows-window";
        cmd-shift-alt-ctrl-a = "move-node-to-workspace 3-admin --focus-follows-window";
        cmd-shift-alt-ctrl-4 = "move-node-to-workspace 4-slack --focus-follows-window";
        cmd-shift-alt-ctrl-s = "move-node-to-workspace 4-slack --focus-follows-window";
        cmd-shift-alt-ctrl-5 = "move-node-to-workspace 5-chime --focus-follows-window";
        cmd-shift-alt-ctrl-c = "move-node-to-workspace 5-chime --focus-follows-window";
        cmd-shift-alt-ctrl-6 = "move-node-to-workspace 6-entertainment --focus-follows-window";
        cmd-shift-alt-ctrl-e = "move-node-to-workspace 6-entertainment --focus-follows-window";
        cmd-shift-alt-ctrl-7 = "move-node-to-workspace 7-misc --focus-follows-window";
        cmd-shift-alt-ctrl-m = "move-node-to-workspace 7-misc --focus-follows-window";
        cmd-shift-alt-ctrl-8 = "move-node-to-workspace 8 --focus-follows-window";
        cmd-shift-alt-ctrl-9 = "move-node-to-workspace 9 --focus-follows-window";
        cmd-shift-alt-ctrl-i = "move-node-to-workspace ignored --focus-follows-window";

        cmd-shift-alt-ctrl-r = # bash
          ''
            exec-and-forget aerospace reload-config
            aerospace enable off
            aerospace enable on
          '';
      };
    };
  };
  on-window-detected = [
    {
      "if" = {
        # sudo fingerprint/password prompt
        app-name-regex-substring = "SecurityAgent";
      };
      run = "layout floating";
    }
    {
      "if" = {
        app-id = "com.apple.finder";
      };
      run = "layout floating";
    }
    {
      "if" = {
        app-id = "com.apple.systempreferences";
      };
      run = "layout floating";
    }
    {
      "if" = {
        app-id = "com.raycast.macos";
      };
      run = "layout floating";
    }
    {
      "if" = {
        app-id = "org.alacritty";
      };
      run = "move-node-to-workspace 1-dev";
    }
    {
      "if" = {
        app-id = "com.mitchellh.ghostty";
      };
      run = "move-node-to-workspace 1-dev";
    }
    {
      "if" = {
        app-id = "net.kovidgoyal.kitty";
      };
      run = "move-node-to-workspace 1-dev";
    }
    {
      "if" = {
        window-title-regex-substring = "neovide";
      };
      run = "move-node-to-workspace 1-dev";
    }
    {
      "if" = {
        # OrbStack
        app-id = "dev.kdrag0n.MacVirt";
      };
      run = "move-node-to-workspace 1-dev";
    }
    {
      "if" = {
        app-id = "org.mozilla.firefox";
      };
      run = "move-node-to-workspace 2-firefox";
    }
    {
      "if" = {
        window-title-regex-substring = "Reminder";
        app-id = "com.microsoft.Outlook";
      };
      run = [
        "layout floating"
        "move-node-to-workspace 3-admin"
      ];
    }
    {
      "if" = {
        app-id = "com.microsoft.Outlook";
      };
      run = "move-node-to-workspace 3-admin";
    }
    {
      "if" = {
        app-id = "md.obsidian";
      };
      run = "move-node-to-workspace 3-admin";
    }
    {
      "if" = {
        app-id = "com.tinyspeck.slackmacgap";
      };
      run = "move-node-to-workspace 4-slack";
    }
    {
      "if" = {
        app-id = "com.amazon.Amazon-Chime";
      };
      run = "move-node-to-workspace 5-chime";
    }
    {
      "if" = {
        app-id = "org.chromium.Chromium";
      };
      run = "move-node-to-workspace 6-entertainment";
    }
    {
      "if" = {
        app-id = "com.spotify.client";
      };
      run = "move-node-to-workspace 6-entertainment";
    }
    {
      "if" = {
        app-id = "com.cisco.anyconnect.gui";
      };
      run = [
        "layout floating"
        "move-node-to-workspace 7-misc"
      ];
    }
    {
      "if" = {
        app-id = "org.xquartz.X11";
      };
      run = "move-node-to-workspace ignored";
    }
    {
      # Fallback for all other windows
      run = "move-node-to-workspace 7-misc";
    }
  ];
  workspace-to-monitor-force-assignment = {
    "1-dev" = [
      "p32"
      "secondary"
    ];
    "2-firefox" = "built-in";
    "3-admin" = [
      "p27"
      "dell"
      "secondary"
    ];
    "4-slack" = "built-in";
    "5-chime" = "built-in";
    "6-entertainment" = [
      "p27"
      "dell"
      "secondary"
    ];
    "7-misc" = "built-in";
    ignored = [
      "p32"
      "secondary"
    ];
  };
}
