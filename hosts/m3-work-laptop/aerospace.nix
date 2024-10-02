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
  gaps = {
    inner = {
      horizontal = 10;
      vertical = 10;
    };
    outer = {
      left = 10;
      bottom = 10;
      top = 10;
      right = 10;
    };
  };
  mode = {
    main = {
      binding = {
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

        cmd-shift-alt-ctrl-h = ''
          exec-and-forget var="$(aerospace list-windows --focused --format "%{window-id}")" && \
          aerospace move-node-to-monitor left && aerospace focus --window-id $var; unset var
        '';
        cmd-shift-alt-ctrl-j = ''
          exec-and-forget var="$(aerospace list-windows --focused --format "%{window-id}")" && \
          aerospace move-node-to-monitor down && aerospace focus --window-id $var; unset var
        '';
        cmd-shift-alt-ctrl-k = ''
          exec-and-forget var="$(aerospace list-windows --focused --format "%{window-id}")" && \
          aerospace move-node-to-monitor up && aerospace focus --window-id $var; unset var
        '';
        cmd-shift-alt-ctrl-l = ''
          exec-and-forget var="$(aerospace list-windows --focused --format "%{window-id}")" && \
          aerospace move-node-to-monitor right && aerospace focus --window-id $var; unset var
        '';
        /*
          Workspace mapping
          1: Terminal (sometimes also firefox)
          2: Firefox
          3: Slack
          4: Chime
          5: Admin (Obsidian + Outlook)
          6: Miscellaneous (e.g. Spotify)
        */
        alt-1 = "workspace dev";
        alt-2 = "workspace firefox";
        alt-3 = "workspace slack";
        alt-4 = "workspace chime";
        alt-5 = "workspace admin";
        alt-6 = "workspace misc";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-a = "workspace admin";
        alt-c = "workspace chime";
        alt-f = "workspace firefox";
        alt-m = "workspace misc";
        alt-s = "workspace slack";
        alt-t = "workspace term";

        shift-alt-1 = "move-node-to-workspace dev";
        shift-alt-2 = "move-node-to-workspace firefox";
        shift-alt-3 = "move-node-to-workspace slack";
        shift-alt-4 = "move-node-to-workspace chime";
        shift-alt-5 = "move-node-to-workspace admin";
        shift-alt-6 = "move-node-to-workspace misc";
        shift-alt-7 = "move-node-to-workspace 7";
        shift-alt-8 = "move-node-to-workspace 8";
        shift-alt-9 = "move-node-to-workspace 9";
        shift-alt-a = "move-node-to-workspace admin";
        shift-alt-c = "move-node-to-workspace chime";
        shift-alt-f = "move-node-to-workspace firefox";
        shift-alt-m = "move-node-to-workspace misc";
        shift-alt-s = "move-node-to-workspace slack";
        shift-alt-t = "move-node-to-workspace term";

        cmd-shift-alt-ctrl-r = ''
          exec-and-forget aerospace reload-config && \
          aerospace enable off && \
          aerospace enable on && \
        '';
        cmd-shift-alt-ctrl-q = "enable off";
        cmd-shift-alt-ctrl-s = "enable on";
      };
    };
  };
  on-window-detected = [
    {
      "if" = {
        app-id = "org.alacritty";
      };
      run = "move-node-to-workspace dev";
    }
    {
      "if" = {
        window-title-regex-substring = "neovide";
      };
      run = "move-node-to-workspace dev";
    }
    {
      "if" = {
        app-id = "com.amazon.Amazon-Chime";
      };
      run = "move-node-to-workspace chime";
    }
    {
      "if" = {
        app-id = "com.cisco.anyconnect.gui";
      };
      check-further-callbacks = true;
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
        app-id = "org.mozilla.firefox";
      };
      run = "move-node-to-workspace firefox";
    }
    {
      "if" = {
        app-id = "com.microsoft.Outlook";
      };
      run = "move-node-to-workspace admin";
    }
    {
      "if" = {
        app-id = "md.obsidian";
      };
      run = "move-node-to-workspace admin";
    }
    {
      "if" = {
        app-id = "com.tinyspeck.slackmacgap";
      };
      run = "move-node-to-workspace slack";
    }
    {
      "if" = {
        app-id = "com.apple.systempreferences";
      };
      run = "layout floating";
    }
    {
      # Fallback for all other windows
      run = "move-node-to-workspace misc";
    }
  ];
  workspace-to-monitor-force-assignment = {
    admin = [
      "p27"
      "dell"
      "secondary"
    ];
    chime = "built-in";
    dev = [
      "p32"
      "secondary"
    ];
    firefox = "built-in";
    slack = "built-in";
    misc = "built-in";
  };
}
