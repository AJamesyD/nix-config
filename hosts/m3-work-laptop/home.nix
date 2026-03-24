{
  pkgs,
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
    ./sketchybar-theme.nix
  ];

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

      # https://github.com/nixos/nixpkgs/issues/456113
      (cargo-nextest.overrideAttrs (prev: {
        preConfigure = ''
          export PATH="$PATH:/usr/sbin"
        '';
      }))
    ];

    stateVersion = "25.11";
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

    ghostty = {
      enable = true;
      package = null; # installed via Homebrew cask
      settings = {
        # Fonts
        font-family = "IBM Plex Mono";
        font-family-bold = "IBM Plex Mono";
        font-family-italic = "Victor Mono";
        font-family-bold-italic = "Victor Mono";
        font-size = 16;
        font-thicken = true;

        # Appearance
        theme = "Dark Pastel";
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
      };
    };

    home-manager.enable = true;

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
          size = 16.0;
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
