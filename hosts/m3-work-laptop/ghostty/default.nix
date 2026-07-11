{ pkgs, ... }:
{
  home.packages = [
    pkgs.ghostty-bin.terminfo # Homebrew-managed Ghostty has no nix package to provide this
  ];

  programs.ghostty = {
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

      # AeroSpace tiling WM compatibility
      # https://ghostty.org/docs/help/macos-tiling-wms
      macos-window-shadow = false;
      resize-overlay = "never";
      window-padding-balance = true;
      window-step-resize = false;

      mouse-hide-while-typing = true;

      auto-update = "check";
      # TODO(ghostty>=1.3.2): switch back to "stable" once the scrollback memory
      #   leak fix ships: https://github.com/ghostty-org/ghostty/pull/10251
      auto-update-channel = "tip";
      shell-integration-features = true;
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
        # Splits
        "ctrl+a>shift+backslash=new_split:right"
        "ctrl+a>minus=new_split:down"
        "ctrl+a>n=new_split:auto"
        "ctrl+a>x=close_surface"
        "ctrl+a>z=toggle_split_zoom"
        "ctrl+a>equal=equalize_splits"
        "ctrl+a>h=goto_split:left"
        "ctrl+a>j=goto_split:bottom"
        "ctrl+a>k=goto_split:top"
        "ctrl+a>l=goto_split:right"

        # Tabs
        "ctrl+a>c=new_tab"
        "ctrl+a>tab=last_tab"
        "ctrl+a>comma=prompt_tab_title"
        "ctrl+a>shift+h=previous_tab"
        "ctrl+a>shift+l=next_tab"
        "ctrl+a>one=goto_tab:1"
        "ctrl+a>two=goto_tab:2"
        "ctrl+a>three=goto_tab:3"
        "ctrl+a>four=goto_tab:4"
        "ctrl+a>five=goto_tab:5"
        "ctrl+a>six=goto_tab:6"
        "ctrl+a>seven=goto_tab:7"
        "ctrl+a>eight=goto_tab:8"
        "ctrl+a>nine=goto_tab:9"

        # Resize mode (ctrl+a r to enter, esc to exit)
        "ctrl+a>r=activate_key_table:resize"
        "resize/h=resize_split:left,20"
        "resize/j=resize_split:down,20"
        "resize/k=resize_split:up,20"
        "resize/l=resize_split:right,20"
        "resize/equal=equalize_splits"
        "resize/escape=deactivate_key_table"
        "resize/catch_all=ignore"

        # Window / meta
        "ctrl+a>shift+c=new_window"
        "ctrl+a>f=toggle_fullscreen"
        "performable:ctrl+c=copy_to_clipboard"
        "ctrl+a>ctrl+a=text:\\x01"
        "ctrl+a>escape=end_key_sequence"
        "ctrl+a>shift+r=reload_config"
        "global:cmd+grave_accent=toggle_quick_terminal"
      ];
    };
  };

  xdg.configFile."ghostty/shaders" = {
    source = ./shaders;
    recursive = true;
  };
}
