{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../common/aws
    ../../common/browser
    ../../common/browser/zen/amazon.nix
    ../../common/dev.nix
    ../../common/ssh.nix
    ../../common/zmx
    ../../modules/home-manager
    ./ghostty
    ./sketchybar-theme.nix
  ];

  stylix.targets.gtk.enable = false;

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

      cargo-nextest

      xcodes
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
    mise = {
      globalConfig = {
        tools = {
          # NOTE: interactive node only; brazil-build's node is pinned separately in
          # common/aws/toolbox.nix (brazil-cli.runtimes). Editing this list does not
          # change brazil's node.
          node = [
            # NOTE: First one becomes default
            "24" # krypton
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
      "sketchybar" = {
        enable = true;
        source = ./sketchybar;
        recursive = true;
      };

      "mistty" = {
        enable = true;
        source = ./mistty;
        recursive = true;
      };
    };
  };

  programs.toolbox.currentPlatform = "osx";
  programs.toolbox.aim.mcpServers.aws-outlook-mcp = { };
}
