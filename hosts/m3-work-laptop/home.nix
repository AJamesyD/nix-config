{
  config,
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

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      "${config.xdg.configHome}/aerospace/aerospace.toml" = {
        source = (pkgs.formats.toml { }).generate "aerospace.toml" (import ./aerospace.nix);
      };
    };

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

      (rustPlatform.buildRustPackage rec {
        pname = "ion-cli";
        version = "v0.7.0";

        src = fetchFromGitHub {
          owner = "amazon-ion";
          repo = pname;
          rev = version;
          sha256 = "sha256-b9ZUp3ES6yJZ/YPU2kFoGHUz/HcBr+x60DwCe1Y8Z/E=";
        };
        cargoHash = "sha256-vY9F+DP3Mfr3zUi3Pyu8auDleqQ1KDT5PpfwdnWUVX8=";
        doCheck = false;
      })
    ];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.05"; # Please read the comment before changing.
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
      enable = true;
      globalConfig = {
        tools = {
          node = [
            "lts-gallium" # v16
            "lts-hydrogen" # v18
            "20" # iron
          ];
        };
      };
    };
    neovide = {
      enable = true;
      settings = {
        fork = true;
        idle = true; # TODO: best if false?
        font = {
          normal = [ "BlexMono Nerd Font" ];
          size = 16.0;
          edging = "antialias"; # TODO: try subpixelantialias?
        };

      };
    };
    zsh = {
      enable = true;
      shellAliases = {
        auth = "mwinit -f -s && kinit -f";
        nixup = # bash
          ''
            ghauth &&
            nix flake update --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN"
            darwin-rebuild switch --flake ~/.config/nix#m3-work-laptop --option access-tokens "github.com=$GITHUB_TOKEN" &&
            zsource''; # Cannot have newline at end of command or else it won't be chainable
        up = "nixup";
        neovide-ssh = # bash
          ''
            rm /tmp/nvim.sock &>/dev/null;
            (ssh -XY -L /tmp/nvim.sock:/tmp/nvim.sock $DEV_DESK_HOSTNAME \
            'export PATH="/home/angaidan/.nix-profile/bin:$PATH" &&
            nvim --headless --listen /tmp/nvim.sock' &) &&
            sleep 3s &&
            neovide --server=/tmp/nvim.sock'';
      };
    };
  };
}
