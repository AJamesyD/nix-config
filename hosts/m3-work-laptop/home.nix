{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../common/aws.nix
    ../../common/dev.nix
    ./terminals.nix
  ];

  home = {
    username = "angaidan";
    homeDirectory = "/Users/angaidan";

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
      qmk
      keymapviz

      # https://github.com/nixos/nixpkgs/issues/456113
      (cargo-nextest.overrideAttrs (prev: {
        preConfigure = ''
          export PATH="$PATH:/usr/sbin"
        '';
      }))
    ];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.11"; # Please read the comment before changing.
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
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    mise = {
      enable = true;
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
    zsh = {
      enable = true;
      initContent = lib.mkMerge [
        (lib.mkOrder 550
          # bash
          ''
            eval "$(brew shellenv)"
          ''
        )
      ];
      shellAliases = {
        auth = "mwinit -f -s";
        nixup = # bash
          ''
            ghauth
            nix flake update --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN"
            sudo darwin-rebuild switch --flake ~/.config/nix#m3-work-laptop --option access-tokens "github.com=$GITHUB_TOKEN"
            zsource
          '';
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
      "aerospace/aerospace.toml" = {
        enable = true;
        source = ../../users/angaidan/.config/aerospace/aerospace.toml;
        onChange = # bash
          ''
            export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"

            aerospace reload-config
          '';
      };
      "borders/bordersrc" = {
        enable = true;
        executable = true;
        source = ../../users/angaidan/.config/borders/bordersrc;
        onChange = # bash
          ''
            export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"

            brew services restart borders
          '';
      };
      "ghostty" = {
        enable = true;
        source = ../../users/angaidan/.config/ghostty;
        recursive = true;
      };
      "neovide/config.toml" = {
        enable = true;
        text = # toml
          ''
            fork = true
            frame = "full"
            no-multigrid = false
            title-hidden = true
            maximized = true


            [font]
            size = 16.0
            edging = "subpixelantialias"

            [font.normal]
            family = "BlexMono Nerd Font"
            style = "Regular"

            [font.italic]
            family = "VictorMono Nerd Font"
            style = "Italic"

            [font.bold]
            family = "BlexMono Nerd Font"
            style = "Bold"

            [font.bold_italic]
            family = "VictorMono Nerd Font"
            style = "Bold Italic"
          '';
      };
      "sketchybar" = {
        enable = true;
        source = ../../users/angaidan/.config/sketchybar;
        recursive = true;
        onChange = # bash
          ''
            export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"

            sketchybar --reload
          '';
      };
    };
  };
}
