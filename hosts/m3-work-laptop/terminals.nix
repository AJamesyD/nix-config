{
  config,
  lib,
  pkgs,
  ...
}:
let
  kitty_icon = pkgs.fetchFromGitHub {
    owner = "diegobit";
    repo = "kitty-icon";
    rev = "0deabe1aab102d8052b4b12b38631ce2ca16d6b0";
    sha256 = "sha256-vZCNNVfdCTYPiSSXtug7xfW3c0Cx/H0S3w+f1q3Prgs=";
  };
  # TODO: Reduce duplication with fonts.packages
  nerd_fonts = pkgs.nerdfonts.override {
    fonts = [
      "FiraCode"
      "Hack"
      "IBMPlexMono"
      "JetBrainsMono"
      "VictorMono"
    ];
  };
in
{
  home = {
    packages = [
      nerd_fonts
    ];
  };

  programs = {
    alacritty = {
      enable = true;
      settings = {
        # General
        import = [
          "${pkgs.alacritty-theme}/aura.toml"
        ];
        shell = {
          program = "${(lib.getExe pkgs.zsh)}";
        };
        working_directory = "${config.home.homeDirectory}";

        # The rest
        env = {
          TERM = "alacritty";
        };
        window = {
          decorations = "Buttonless";
          option_as_alt = "Both";
          resize_increments = true;
        };
        font = {
          size = 18.0;
          normal = {
            family = "BlexMono Nerd Font";
            style = "Regular";
          };
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
        colors = {
          primary = {
            background = "#000000";
          };
          selection = {
            background = "#5f5987"; # Make Aura theme selections easier to read
          };
        };
        cursor = {
          style = {
            blinking = "On";
            shape = "Beam";
          };
          vi_mode_style = {
            blinking = "Off";
            shape = "Underline";
          };
        };
        terminal = {
          osc52 = "CopyPaste";
        };
        keyboard.bindings = [
          {
            key = "Back";
            mods = "Command";
            chars = "";
          }
          {
            key = "t";
            mods = "Command";
            action = "CreateNewWindow";
          }
          {
            key = "f";
            mods = "Command";
            action = "None";
          }
        ];
      };
    };
    kitty = {
      enable = true;
      font = {
        name = "VictorMono Nerd Font Mono";
        package = nerd_fonts;
        size = 18.0;
      };
      package = pkgs.kitty.overrideAttrs (oldAttrs: {
        postInstall =
          lib.optionalString pkgs.stdenv.isDarwin
            # bash
            ''
              cp "${kitty_icon}/kitty.icns" "$out/Applications/kitty.app/Contents/Resources/kitty.icns"
              cp "${kitty_icon}/kitty.icns" "$out/Applications/kitty.app/Contents/Resources/SIGNAL_kitty.icns"
            '';
      });
      settings = {
        # Font
        font_family = ''"family=${config.programs.kitty.font.name} style=Medium"'';
        disable_ligatures = "cursor";
        symbol_map = "U+E000-U+F1AF0 VictorMono Nerd Font";
        modify_font = ''
          cell_height = "-2px";
        '';

        # Performance
        input_delay = 2;
        sync_to_monitor = "no";

        # Terminal Bell
        enable_audio_bell = "no";

        # Window Layout
        hide_window_decorations = "yes";
        confirm_os_window_close = 0;

        # Tab Bar
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{index}:{title}";

        # OS Specific
        macos_option_as_alt = "yes";
        macos_quit_when_last_window_closed = "yes";
      };
      themeFile = "Dark_Pastel";
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "kitty/kitty.app.icns" = {
        source = "${kitty_icon}/kitty.icns";
      };
      "kitty/kitty.app.png" = {
        source = "${kitty_icon}/kitty.png";
      };
    };
  };
}
