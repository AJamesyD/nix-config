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

        ### Move focus ###
        cmd-shift-f = "fullscreen";

        cmd-shift-h = "focus left --boundaries all-monitors-outer-frame --boundaries-action stop";
        cmd-shift-j = "focus down --boundaries all-monitors-outer-frame --boundaries-action stop";
        cmd-shift-k = "focus up --boundaries all-monitors-outer-frame --boundaries-action stop";
        cmd-shift-l = "focus right --boundaries all-monitors-outer-frame --boundaries-action stop";

        cmd-shift-1 = "workspace 1-dev";
        cmd-shift-d = "workspace 1-dev";
        cmd-shift-2 = "workspace 2-browser";
        cmd-shift-b = "workspace 2-browser";
        cmd-shift-3 = "workspace 3-admin";
        cmd-shift-a = "workspace 3-admin";
        cmd-shift-4 = "workspace 4-chat";
        cmd-shift-c = "workspace 4-chat";
        cmd-shift-5 = "workspace 5-video-call";
        cmd-shift-v = "workspace 5-video-call";
        cmd-shift-6 = "workspace 6";
        cmd-shift-7 = "workspace 7";
        cmd-shift-8 = "workspace 8";
        cmd-shift-9 = "workspace 9-entertainment";
        cmd-shift-e = "workspace 9-entertainment";
        cmd-shift-0 = "workspace 0-misc";
        cmd-shift-m = "workspace 0-misc";
        cmd-shift-i = "workspace ignored";

        ### Move windows within workspace ###
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

        ### Move workspaces and windows within workspaces ###
        cmd-shift-alt-ctrl-h = "move-node-to-monitor left --focus-follows-window";
        cmd-shift-alt-ctrl-j = "move-node-to-monitor down --focus-follows-window";
        cmd-shift-alt-ctrl-k = "move-node-to-monitor up --focus-follows-window";
        cmd-shift-alt-ctrl-l = "move-node-to-monitor right --focus-follows-window";

        cmd-shift-alt-ctrl-left = "move-workspace-to-monitor left";
        cmd-shift-alt-ctrl-down = "move-workspace-to-monitor down";
        cmd-shift-alt-ctrl-up = "move-workspace-to-monitor up";
        cmd-shift-alt-ctrl-right = "move-workspace-to-monitor right";

        cmd-shift-alt-ctrl-1 = "move-node-to-workspace 1-dev --focus-follows-window";
        cmd-shift-alt-ctrl-d = "move-node-to-workspace 1-dev --focus-follows-window";
        cmd-shift-alt-ctrl-2 = "move-node-to-workspace 2-browser --focus-follows-window";
        cmd-shift-alt-ctrl-b = "move-node-to-workspace 2-browser --focus-follows-window";
        cmd-shift-alt-ctrl-3 = "move-node-to-workspace 3-admin --focus-follows-window";
        cmd-shift-alt-ctrl-a = "move-node-to-workspace 3-admin --focus-follows-window";
        cmd-shift-alt-ctrl-4 = "move-node-to-workspace 4-chat --focus-follows-window";
        cmd-shift-alt-ctrl-c = "move-node-to-workspace 4-chat --focus-follows-window";
        cmd-shift-alt-ctrl-5 = "move-node-to-workspace 5-video-call --focus-follows-window";
        cmd-shift-alt-ctrl-v = "move-node-to-workspace 5-video-call --focus-follows-window";
        cmd-shift-alt-ctrl-6 = "move-node-to-workspace 6 --focus-follows-window";
        cmd-shift-alt-ctrl-7 = "move-node-to-workspace 7 --focus-follows-window";
        cmd-shift-alt-ctrl-8 = "move-node-to-workspace 8 --focus-follows-window";
        cmd-shift-alt-ctrl-9 = "move-node-to-workspace 9-entertainment --focus-follows-window";
        cmd-shift-alt-ctrl-e = "move-node-to-workspace 9-entertainment --focus-follows-window";
        cmd-shift-alt-ctrl-0 = "move-node-to-workspace 0-misc --focus-follows-window";
        cmd-shift-alt-ctrl-m = "move-node-to-workspace 0-misc --focus-follows-window";
        cmd-shift-alt-ctrl-i = "move-node-to-workspace ignored --focus-follows-window";

        ### Misc ###
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
      run = [
        "layout floating" # https://ghostty.org/docs/help/macos-tiling-wms
        "move-node-to-workspace 1-dev"
      ];
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
      run = "move-node-to-workspace 2-browser";
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
      run = "move-node-to-workspace 4-chat";
    }
    {
      "if" = {
        app-id = "org.zulip.zulip-electron";
      };
      run = "move-node-to-workspace 4-chat";
    }
    {
      "if" = {
        app-id = "com.amazon.Amazon-Chime";
      };
      run = "move-node-to-workspace 5-video-call";
    }
    {
      "if" = {
        app-id = "us.zoom.xos";
      };
      run = "move-node-to-workspace 5-video-call";
    }
    {
      "if" = {
        app-id = "com.spotify.client";
      };
      run = "move-node-to-workspace 9-entertainment";
    }
    {
      "if" = {
        app-id = "com.cisco.anyconnect.gui";
      };
      run = [
        "layout floating"
        "move-node-to-workspace 0-misc"
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
      run = "move-node-to-workspace 0-misc";
    }
  ];
  workspace-to-monitor-force-assignment = {
    "1-dev" = [
      "p32"
      "secondary"
    ];
    "2-browser" = "built-in";
    "3-admin" = [
      "p27"
      "dell"
      "secondary"
    ];
    "4-chat" = "built-in";
    "5-video-call" = "built-in";
    "9-entertainment" = [
      "p27"
      "dell"
      "secondary"
    ];
    "0-misc" = "built-in";
    ignored = [
      "p32"
      "secondary"
    ];
  };
}
