{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../common/ai
    ../../common/aws
    ../../common/browser
    ../../common/browser/zen/amazon.nix
    ../../common/dev.nix
    ../../common/ssh.nix
    ../../common/zmx
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
    zsh = {
      enable = true;
      shellAliases = {
        auth = "mwinit -f -s";
        up = "nixup";
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
    };
  };

  programs.toolbox.currentPlatform = "osx";
  programs.toolbox.aim.mcpServers.aws-outlook-mcp = { };
}
