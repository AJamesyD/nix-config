{
  config,
  lib,
  pkgs,
  ...
}:
let
  tmux-which-key = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-which-key";
    version = "2024-07-08";
    src = pkgs.fetchFromGitHub {
      owner = "alexwforsythe";
      repo = "tmux-which-key";
      rev = "1f419775caf136a60aac8e3a269b51ad10b51eb6";
      hash = "sha256-X7FunHrAexDgAlZfN+JOUJvXFZeyVj9yu6WRnxMEA8E=";
    };
    rtpFilePath = "plugin.sh.tmux";
  };
in
{
  home = {
    packages = with pkgs; [
      gum
      sesh
    ];
  };
  programs = {
    fzf = {
      enable = true;
      tmux = {
        enableShellIntegration = true;
      };
    };
    tmux = {
      enable = true;
      aggressiveResize = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 0;
      historyLimit = 300000;
      keyMode = "vi";
      mouse = false; # Will intercept hyperlink handling in Alacritty
      newSession = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = catppuccin.overrideAttrs (oldAttrs: {
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "tmux";
              rev = "v1.0.3";
              hash = "sha256-p0xrk4WXNoVJfekA/L3cxIVrLqjFbBe2S/rc/6JXz6M=";
            };
          });

          extraConfig = # tmux
            ''
              set -g @catppuccin_flavor 'mocha'

              set -g @truncated_directory_text "#{s|#{HOME}|~|;s|/local~|~|;s|/workplace/angaidan|~|;s|/.*/([^/^~]*/)|/…/\\1|:pane_current_path}"

              set -g @catppuccin_window_number_position "right"
              set -g @catppuccin_window_default_fill "number"
              set -g @catppuccin_window_current_fill "number"
              set -g @catppuccin_window_default_text "#{window_name}"
              set -g @catppuccin_window_current_text "#{window_name}#{?window_zoomed_flag,(),}"

              # TODO: Move back to "slanted" when fixed upstream
              set -g @catppuccin_window_status_style "custom"
              set -g @catppuccin_window_left_separator "█"
              set -g @catppuccin_window_middle_separator " █"
              set -g @catppuccin_window_right_separator "█ "

              set -g @catppuccin_status_left_separator  ""
              set -g @catppuccin_status_right_separator " "
              set -g @catppuccin_status_fill "all"
              set -g @catppuccin_status_connect_separator "yes"

              set -g @catppuccin_directory_text "#{E:@truncated_directory_text}"
              set -g @catppuccin_date_time_text "%H:%M"

              # More prefix modes
              set -g @prefix_mode_highlight "#{E:@thm_red}"
              set -g @copy_mode_highlight "#{E:@thm_lavender}"
              set -g @empty_mode_highlight "#{E:@thm_green}"
              set -g @fallback_mode_highlight "#{?pane_in_mode,#{E:@copy_mode_highlight},#{E:@empty_mode_highlight}}"
              set -g @catppuccin_session_color "#{?client_prefix,#{E:@prefix_mode_highlight},#{E:@fallback_mode_highlight}}"
            '';
        }
        {
          plugin = fingers;
          extraConfig = # tmux
            ''
              set -g @fingers-key F
              set -g @fingers-enabled-builtin-patterns uuid,sha,url,path
            '';
        }
        {
          plugin = pain-control;
          extraConfig = # tmux
            ''

            '';
        }
        {
          plugin = resurrect;
          extraConfig = # tmux
            ''
              set -g @resurrect-dir '${config.xdg.dataHome}/tmux/resurrect'
              set -g @resurrect-capture-pane-contents 'on'

              set -g @resurrect-strategy-vim 'session'
              set -g @resurrect-strategy-nvim 'session'
            '';
        }
        {
          plugin = tmux-fzf;
          extraConfig = # tmux
            ''
              # Avoid collision with tmux-fingers
              TMUX_FZF_LAUNCH_KEY="C-f"
            '';
        }
        vim-tmux-navigator
        {
          plugin = tmux-which-key;
          extraConfig = # tmux
            ''
              set -g @tmux-which-key-xdg-plugin-path tmux-plugins/tmux-which-key
              set -g @tmux-which-key-disable-autobuild 1
              set -g @tmux-which-key-xdg-enable 1
            '';
        }
        # NOTE: continuum must come last to ovoid overrides of status-right
        {
          plugin = continuum;
          extraConfig = # tmux
            ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '5'
            '';
        }
      ];
      secureSocket = false;
      shell = "${pkgs.zsh}/bin/zsh";
      shortcut = "a";
      terminal = "tmux-256color";
      extraConfig = # tmux
        ''
          # -- Options ----------------------------------------------------------------
          # Experiment with 2nd prefix
          set-option -g prefix2 C-b

          # update the env when attaching to an existing session
          set -ga update-environment -r

          set -g default-command ${(lib.getExe pkgs.zsh)}

          set -g status-position top
          # For Catpuccin
          set -g status-right-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_directory}"
          set -ag status-right "#{E:@catppuccin_status_date_time}"
          set -ag status-right "#{E:@catppuccin_status_session}"

          setw -q -g utf8 on

          set -g status-interval 1

          set -as terminal-features "alacritty*:RGB"
          set -as terminal-features "alacritty*:clipboard"
          set -as terminal-features "alacritty*:ccolour"
          set -as terminal-features "alacritty*:cstyle"
          set -as terminal-features "alacritty*:focus"
          set -as terminal-features "alacritty*:hyperlinks"
          set -as terminal-features "alacritty*:strikethrough"
          set -as terminal-features "alacritty*:title"
          set -as terminal-features "alacritty*:usstyle"

          set -as terminal-features "xterm-kitty*:RGB"
          set -as terminal-features "xterm-kitty*:clipboard"
          set -as terminal-features "xterm-kitty*:ccolour"
          set -as terminal-features "xterm-kitty*:cstyle"
          set -as terminal-features "xterm-kitty*:focus"
          set -as terminal-features "xterm-kitty*:hyperlinks"
          set -as terminal-features "xterm-kitty*:strikethrough"
          set -as terminal-features "xterm-kitty*:title"
          set -as terminal-features "xterm-kitty*:usstyle"

          set -g display-panes-time 800
          set -g display-time 1000

          setw -g automatic-rename on
          set -g renumber-windows on
          set -g set-titles on
          set -g set-titles-string "#S / #W"

          setw -g monitor-activity off
          set -g visual-activity off

          set -g set-clipboard on

          setw -g xterm-keys on

          # Enable image preview in yazi ( https://yazi-rs.github.io/docs/image-preview )
          set -g allow-passthrough on

          # skip "kill-pane 1? (y/n)" prompt
          bind-key x kill-pane

          # don't exit from tmux when closing a session
          set -g detach-on-destroy off


          # -- Bindings ----------------------------------------------------------------
          # -- Misc --
          bind : command-prompt
          bind r refresh-client


          # -- Session --
          # bind C-c new-session # create session
          # bind C-f command-prompt -p find-session 'switch-client -t %%'
          bind-key "K" display-popup -E -w 40% "sesh connect \"$(
            sesh list -i | gum filter --limit 1 --placeholder 'Pick a sesh' --height 50 --prompt='⚡'
          )\""


          # -- Window --
          bind p previous-window
          bind C-p previous-window
          bind n next-window
          bind C-n next-window

          # -- Pane --
          unbind %
          unbind '"'

          # https://github.com/mrjones2014/smart-splits.nvim?tab=readme-ov-file#tmux
          # Smart pane switching with awareness of Neovim splits.
          bind-key -n C-h if -F "#{@pane-is-vim}" 'send-keys C-h' 'select-pane -L'
          bind-key -n C-j if -F "#{@pane-is-vim}" 'send-keys C-j' 'select-pane -D'
          bind-key -n C-k if -F "#{@pane-is-vim}" 'send-keys C-k' 'select-pane -U'
          bind-key -n C-l if -F "#{@pane-is-vim}" 'send-keys C-l' 'select-pane -R'

          # Smart pane resizing with awareness of Neovim splits.
          bind-key -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'resize-pane -L 3'
          bind-key -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'resize-pane -D 3'
          bind-key -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'resize-pane -U 3'
          bind-key -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'resize-pane -R 3'


          # -- Layout --
          bind + select-layout main-horizontal
          bind = select-layout main-vertical


          # -- Scrolling --
          bind-key -T root WheelUpPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
          bind-key -T root WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"
          bind-key -T copy-mode-vi WheelUpPane send-keys -X halfpage-up
          bind-key -T copy-mode-vi WheelDownPane send-keys -X halfpage-down


          # -- Control --
          bind Enter copy-mode # enter copy mode
          bind p paste-buffer -p  # paste from the top paste buffer
          bind P choose-buffer    # choose which buffer to paste from

          bind -T copy-mode-vi v send -X begin-selection # start selecting text with "v"
          bind -T copy-mode-vi C-v send -X rectangle-toggle
          bind -T copy-mode-vi y send -X copy-selection-and-cancel # copy text with "y"
          bind -T copy-mode-vi Escape send -X cancel
          bind -T copy-mode-vi ^ send -X start-of-line
          bind -T copy-mode-vi $ send -X end-of-line

          # copy to X11 clipboard
          if -b 'command -v xsel > /dev/null 2>&1' 'bind y run -b "\"\$TMUX_PROGRAM\" \''${TMUX_SOCKET:+-S \"\$TMUX_SOCKET\"} save-buffer - | xsel -i -b"'
          if -b '! command -v xsel > /dev/null 2>&1 && command -v xclip > /dev/null 2>&1' 'bind y run -b "\"\$TMUX_PROGRAM\" \''${TMUX_SOCKET:+-S \"\$TMUX_SOCKET\"} save-buffer - | xclip -i -selection clipboard >/dev/null 2>&1"'

          # copy to Wayland clipboard
          if -b 'command -v wl-copy > /dev/null 2>&1' 'bind y run -b "\"\$TMUX_PROGRAM\" \''${TMUX_SOCKET:+-S \"\$TMUX_SOCKET\"} save-buffer - | wl-copy"'

          # copy to macOS clipboard
          if -b 'command -v pbcopy > /dev/null 2>&1' 'bind y run -b "\"\$TMUX_PROGRAM\" \''${TMUX_SOCKET:+-S \"\$TMUX_SOCKET\"} save-buffer - | pbcopy"'
          if -b 'command -v reattach-to-user-namespace > /dev/null 2>&1' 'bind y run -b "\"\$TMUX_PROGRAM\" \''${TMUX_SOCKET:+-S \"\$TMUX_SOCKET\"} save-buffer - | reattach-to-usernamespace pbcopy"'

          # copy to Windows clipboard
          if -b 'command -v clip.exe > /dev/null 2>&1' 'bind y run -b "\"\$TMUX_PROGRAM\" \''${TMUX_SOCKET:+-S \"\$TMUX_SOCKET\"} save-buffer - | clip.exe"'
          if -b '[ -c /dev/clipboard ]' 'bind y run -b "\"\$TMUX_PROGRAM\" \''${TMUX_SOCKET:+-S \"\$TMUX_SOCKET\"} save-buffer - > /dev/clipboard"'
        '';
    };
  };
}
