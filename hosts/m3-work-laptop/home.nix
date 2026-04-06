{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../common/aws.nix
    ../../common/browser
    ../../common/browser/zen/amazon.nix
    ../../common/dev.nix
    ../../common/ssh.nix
    ../../modules/home-manager
    ./hammerspoon.nix
    ./sketchybar-theme.nix
  ];

  gtk.gtk4.theme = null;

  home = {
    username = "angaidan";
    homeDirectory = "/Users/angaidan";

    packages = with pkgs; [
      # Fonts
      nerd-fonts.blex-mono
      nerd-fonts.hack
      nerd-fonts.victor-mono
      hack-font
      ibm-plex
      sketchybar-app-font
      victor-mono

      halloy

      qmk
      keymapviz

      # https://github.com/nixos/nixpkgs/issues/456113
      (cargo-nextest.overrideAttrs (prev: {
        preConfigure = ''
          export PATH="$PATH:/usr/sbin"
        '';
      }))
    ];

    stateVersion = "25.11";

    activation.loginItems = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /usr/bin/osascript <<'APPLESCRIPT'
        tell application "System Events"
          set currentItems to the name of every login item
          set desiredItems to {{name:"Raycast", path:"/Applications/Raycast.app"}, {name:"Obsidian", path:"/Applications/Obsidian.app"}, {name:"Slack", path:"/Applications/Slack.app"}, {name:"zoom.us", path:"/Applications/zoom.us.app"}, {name:"Microsoft Outlook", path:"/Applications/Microsoft Outlook.app"}, {name:"ACME", path:"/Applications/ACME.app"}}
          repeat with desired in desiredItems
            if (name of desired) is not in currentItems then
              make login item at end with properties {path:path of desired, hidden:false}
            end if
          end repeat
        end tell
      APPLESCRIPT
    '';
  };

  launchd = {
    enable = true;
    agents = {
      pbcopy = {
        enable = true;
        config = {
          inetdCompatibility = {
            Wait = false;
          };
          KeepAlive = {
            Crashed = true;
            SuccessfulExit = false;
          };
          Label = "localhost.pbcopy";
          ProcessType = "Background";
          ProgramArguments = [ "/usr/bin/pbcopy" ];
          RunAtLoad = true;
          Sockets = {
            Listener = {
              SockNodeName = "127.0.0.1";
              SockServiceName = "2224";
            };
          };
        };
      };
      pbpaste = {
        enable = true;
        config = {
          inetdCompatibility = {
            Wait = false;
          };
          KeepAlive = {
            Crashed = true;
            SuccessfulExit = false;
          };
          Label = "localhost.pbpaste";
          ProcessType = "Background";
          ProgramArguments = [ "/usr/bin/pbpaste" ];
          RunAtLoad = true;
          Sockets = {
            Listener = {
              SockNodeName = "127.0.0.1";
              SockServiceName = "2225";
            };
          };
        };
      };
    };
  };

  programs = {
    git = {
      settings.user.email = "angaidan@amazon.com";
      includes = [
        {
          condition = "gitdir:~/Code/";
          contents.user.email = "aidandeangelis@berkeley.edu";
        }
        {
          condition = "gitdir:~/.config/";
          contents.user.email = "aidandeangelis@berkeley.edu";
        }
      ];
    };

    jujutsu.settings."--scope" = [
      {
        condition.repositories = [ "~/Code/" ];
        user.email = "aidandeangelis@berkeley.edu";
      }
      {
        condition.repositories = [ "~/.config/" ];
        user.email = "aidandeangelis@berkeley.edu";
      }
    ];

    ghostty = {
      enable = true;
      package = null; # installed via Homebrew cask
      settings = {
        # Stylix sets font-family (BlexMono Nerd Font) from stylix.fonts.monospace
        font-family-italic = "Victor Mono";
        font-family-bold-italic = "Victor Mono";
        font-size = 16;
        font-thicken = true;

        custom-shader = [
          "~/.config/ghostty/shaders/cursor_blaze_no_trail.glsl"
          "~/.config/ghostty/shaders/cursor_smear.glsl"
        ];

        # Window
        window-padding-color = "background";
        macos-titlebar-style = "tabs";
        confirm-close-surface = true;

        # Tiling WM (AeroSpace) compatibility
        # https://ghostty.org/docs/help/macos-tiling-wms
        # https://github.com/nikitabobko/AeroSpace/issues/68
        macos-window-shadow = false;
        resize-overlay = "never";
        window-padding-balance = true;
        window-step-resize = false;

        # Mouse
        mouse-hide-while-typing = true;

        # Misc
        auto-update = "check";
        shell-integration-features = "cursor,sudo,ssh-env,ssh-terminfo";
        working-directory = "home";

        # Splits
        unfocused-split-opacity = 0.85;
        split-divider-color = "#585b70";
        split-inherit-working-directory = true;
        window-save-state = "always";
        macos-option-as-alt = true;

        # Quick terminal
        quick-terminal-position = "top";
        quick-terminal-screen = "mouse";
        quick-terminal-autohide = true;

        keybind = [

          # --- Splits (leader) ---

          "ctrl+a>shift+backslash=new_split:right"
          "ctrl+a>minus=new_split:down"
          "ctrl+a>n=new_split:auto"
          "ctrl+a>x=close_surface"
          "ctrl+a>z=toggle_split_zoom"
          "ctrl+a>equal=equalize_splits"

          # --- Split navigation (leader-based so Ctrl+h/j/k/l
          #     passes through to Neovim/smart-splits first) ---

          "ctrl+a>ctrl+h=goto_split:left"
          "ctrl+a>ctrl+j=goto_split:bottom"
          "ctrl+a>ctrl+k=goto_split:top"
          "ctrl+a>ctrl+l=goto_split:right"

          # --- Tabs (leader) ---

          "ctrl+a>c=new_tab"
          "ctrl+a>tab=last_tab"
          "ctrl+a>comma=prompt_tab_title"
          "ctrl+a>h=previous_tab"
          "ctrl+a>l=next_tab"

          "ctrl+a>one=goto_tab:1"
          "ctrl+a>two=goto_tab:2"
          "ctrl+a>three=goto_tab:3"
          "ctrl+a>four=goto_tab:4"
          "ctrl+a>five=goto_tab:5"
          "ctrl+a>six=goto_tab:6"
          "ctrl+a>seven=goto_tab:7"
          "ctrl+a>eight=goto_tab:8"
          "ctrl+a>nine=goto_tab:9"

          # --- Resize mode (modal: ctrl+a r to enter, esc to exit) ---

          "ctrl+a>r=activate_key_table:resize"

          "resize/h=resize_split:left,20"
          "resize/j=resize_split:down,20"
          "resize/k=resize_split:up,20"
          "resize/l=resize_split:right,20"
          "resize/equal=equalize_splits"
          "resize/escape=deactivate_key_table"
          "resize/catch_all=ignore"

          # --- Window ---

          "ctrl+a>shift+c=new_window"
          "ctrl+a>f=toggle_fullscreen"

          # --- Meta ---

          "performable:ctrl+c=copy_to_clipboard"
          "ctrl+a>ctrl+a=text:\\x01"
          "ctrl+a>escape=end_key_sequence"
          "ctrl+a>shift+r=reload_config"
          "global:cmd+grave_accent=toggle_quick_terminal"
        ];
      };
    };

    mise = {
      globalConfig = {
        tools = {
          node = [
            # NOTE: First one becomes default
            "lts"
            "22" # jod
            "20" # iron
          ];
        };
      };
    };

    neovide = {
      enable = true;
      package = null; # installed via Homebrew cask
      settings = {
        fork = true;
        frame = "full";
        no-multigrid = false;
        title-hidden = true;
        maximized = true;

        font = {
          size = lib.mkForce 16.0;
          edging = "subpixelantialias";

          normal = [
            {
              family = "BlexMono Nerd Font";
              style = "Regular";
            }
          ];
          italic = {
            family = "VictorMono Nerd Font";
            style = "Italic";
          };
          bold = {
            family = "BlexMono Nerd Font";
            style = "Bold";
          };
          bold_italic = {
            family = "VictorMono Nerd Font";
            style = "Bold Italic";
          };
        };
      };
    };
    zsh = {
      enable = true;
      shellAliases = {
        auth = "mwinit -f -s";
        up = "nixup";
        neovide-ssh = # bash
          ''
            (ssh -L 6666:localhost:6666 "$CDD_HOSTNAME_AL2_X86" \
            	'nvim --headless --listen localhost:6666' &) &&
            	sleep 1s &&
            	neovide --server=localhost:6666'';
      };
    };
  };

  xdg = {
    enable = true;
    configFile = {
      # Ghostty shader files (config managed by programs.ghostty)
      "ghostty/shaders" = {
        enable = true;
        source = ./ghostty/shaders;
        recursive = true;
      };

      "sketchybar" = {
        enable = true;
        source = ./sketchybar;
        recursive = true;
      };
    };
  };
}
