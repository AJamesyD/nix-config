{
  config,
  lib,
  pkgs,
  ...
}:
# let
#   kitty_icon = pkgs.fetchFromGitHub {
#     owner = "diegobit";
#     repo = "kitty-icon";
#     rev = "0deabe1aab102d8052b4b12b38631ce2ca16d6b0";
#     sha256 = "sha256-vZCNNVfdCTYPiSSXtug7xfW3c0Cx/H0S3w+f1q3Prgs=";
#   };
# in
{
  home = {
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.blex-mono
      nerd-fonts.victor-mono
      fira-code
      ibm-plex
      victor-mono
    ];
  };

  programs = {
    alacritty = {
      enable = true;
      settings = {
        general = {
          import = [
            "${pkgs.alacritty-theme}/aura.toml"
          ];
        };

        env = {
          TERM = "alacritty";
        };
        window = {
          decorations = "Buttonless";
          option_as_alt = "Both";
          resize_increments = true;
        };
        font = {
          size = 16.0;
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
          shell = {
            program = "${(lib.getExe pkgs.zsh)}";
            args = [ "-l" ];
          };
          osc52 = "CopyPaste";
        };
        mouse = {
          hide_when_typing = true;
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
      enable = false;
      settings = {
        # Fonts
        font_family = "Fira Code";
        bold_font = "Fira Code";
        italic_font = "Victor Mono Italic";
        bold_italic_font = "Victor Mono";
        font_size = 16.0;
        disable_ligatures = "cursor";
        modify_font = ''
          cell_height = "-1px";
        '';

        # Text cursor customization
        cursor_trail = 3;
        cursor_trail_decay = "0.1 0.3";
        # cursor_trail_start_threshold = 2;

        # Scrollback
        scrollback_lines = 5000;

        # Mouse
        show_hyperlink_targets = "yes";
        strip_trailing_spaces = "smart";

        # Performance tuning
        input_delay = 2;
        sync_to_monitor = "no";

        # Terminal bell
        enable_audio_bell = "no";

        # Window layout
        hide_window_decorations = "titlebar-only";
        window_border_width = "0.0pt";
        confirm_os_window_close = 0;

        # Tab bar
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_switch_strategy = "left";
        tab_title_template = "{index}:{title}";

        # OS specific
        macos_option_as_alt = "both";
        macos_quit_when_last_window_closed = "yes";

        # Keyboard shortcuts
        kitty_mod = "ctrl+alt";
      };
      themeFile = "Dark_Pastel";
    };
  };

  # xdg = {
  #   enable = true;
  #   configFile = {
  #     "kitty/kitty.app.icns" = {
  #       source = "${kitty_icon}/kitty.icns";
  #     };
  #     "kitty/kitty.app.png" = {
  #       source = "${kitty_icon}/kitty.png";
  #     };
  #   };
  # };
}
