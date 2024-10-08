{
  pkgs,
  ...
}:
let
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
  home.packages = [
    nerd_fonts
  ];
  programs = {
    alacritty = {
      enable = true;
      settings = {
        import = [
          "${pkgs.alacritty-theme}/aura.toml"
        ];
        env = {
          TERM = "alacritty";
        };
        window = {
          decorations = "Buttonless";
          option_as_alt = "Both";
          resize_increments = true;
        };
        font = {
          normal = {
            family = "BlexMono Nerd Font";
            style = "Regular";
          };
          size = 16.0;
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
        ];
      };
    };
    kitty = {
      enable = true;
      font = {
        name = "VictorMono Nerd Font Mono";
        package = nerd_fonts;
        size = 16.0;
      };
      settings = {
        # Font
        disable_ligatures = "cursor";
        symbol_map = "U+E000-U+F1AF0 VictorMono Nerd Font";
        modify_font = {
          cell_height = "-2px";
        };

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
      };
    };
  };
}
