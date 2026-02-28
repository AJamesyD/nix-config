{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  tmux-which-key = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-which-key";
    version = "2024-07-08";
    src = inputs.tmux-which-key;
    rtpFilePath = "plugin.sh.tmux";
  };
in
{
  xdg.configFile."tmux-plugins/tmux-which-key/config.yaml" = {
    source = ./which-key.yaml;
    force = true; # Plugin creates this file on first run; force ensures Nix wins
  };

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
      mouse = false; # Keyboard-only workflow; links clickable natively with mouse off
      newSession = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = catppuccin.overrideAttrs (oldAttrs: {
            src = inputs.catppuccin-tmux;
          });

          extraConfig = # tmux
            ''
              set -g @catppuccin_flavor "mocha"
              set -g @catppuccin_status_background "none"

              set -g @catppuccin_window_number_position "right"
              set -g @catppuccin_window_text "#{window_name}"
              set -g @catppuccin_window_current_text "#{window_name}#{?window_zoomed_flag,(),}"

              set -g @truncated_directory_text "#{s|#{HOME}|~|;s|/local~|~|;s|/workplace/angaidan|~|;s|/.*/([^/^~]*/)|/…/\\1|:pane_current_path}"
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
        # NOTE: continuum must come last to avoid overrides of status-right
        {
          plugin = continuum;
          extraConfig = # tmux
            ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '5'
            '';
        }
      ];
      # NOTE: socket in /tmp — fine for single-user machines.
      # On shared hosts, consider secureSocket = true (/run/user/$UID).
      secureSocket = false;
      shell = "${pkgs.zsh}/bin/zsh";
      # Prefix is C-b (default). C-a is freed for which-key root table binding.
      terminal = "tmux-256color";
      extraConfig = # tmux
        ''
          # -- Options --

          # update the env when attaching to an existing session
          set -ga update-environment -r

          set -g status-position top

          # For Catppuccin
          set -g status-left-length 100
          set -g status-left "#{?client_prefix,#[bg=#{E:@thm_red},fg=#{E:@thm_crust}] PREFIX #[default] ,#{?pane_in_mode,#[bg=#{E:@thm_lavender},fg=#{E:@thm_crust}] COPY #[default] ,}}"
          set -g status-right-length 100
          set -g status-right "#{E:@catppuccin_status_directory}"
          set -ag status-right "#{E:@catppuccin_status_session}"

          set -g status-interval 5

          set -as terminal-features "xterm-ghostty:RGB:clipboard:ccolour:cstyle:focus:hyperlinks:strikethrough:title:usstyle"
          set -as terminal-features "xterm-kitty:RGB:clipboard:ccolour:cstyle:focus:hyperlinks:strikethrough:title:usstyle"

          set -g display-panes-time 800
          set -g display-time 1000

          setw -g automatic-rename on
          set -g renumber-windows on
          set -g set-titles on
          set -g set-titles-string "#S / #W"

          setw -g monitor-activity off
          set -g visual-activity off

          set -g set-clipboard on

          # Enable image preview in yazi ( https://yazi-rs.github.io/docs/image-preview )
          set -g allow-passthrough on

          # skip "kill-pane 1? (y/n)" prompt
          bind-key x kill-pane

          # Cycle windows
          bind-key C-a next-window
          bind-key C-b previous-window

          # Smart split: horizontal if pane is wide, vertical otherwise
          bind-key n if-shell '[ #{pane_width} -gt $((#{pane_height} * 2)) ]' \
            'splitw -h -c "#{pane_current_path}"' \
            'splitw -v -c "#{pane_current_path}"'

          # Prefer next session on destroy; detach only when none left (tmux 3.4+)
          set -g detach-on-destroy no-detached

          # -- Root-table bindings (vim-aware, not prefix-triggered) --
          # https://github.com/mrjones2014/smart-splits.nvim?tab=readme-ov-file#tmux
          # Smart pane switching with awareness of Neovim splits.
          bind-key -n C-h if -F "#{@pane-is-vim}" 'send-keys C-h' 'select-pane -L'
          bind-key -n C-j if -F "#{@pane-is-vim}" 'send-keys C-j' "if '[ \"#{pane_current_command}\" = \"lazygit\" ]' 'send-keys C-j' 'select-pane -D'"
          bind-key -n C-k if -F "#{@pane-is-vim}" 'send-keys C-k' "if '[ \"#{pane_current_command}\" = \"lazygit\" ]' 'send-keys C-k' 'select-pane -U'"
          bind-key -n C-l if -F "#{@pane-is-vim}" 'send-keys C-l' 'select-pane -R'

          # Smart pane resizing with awareness of Neovim splits.
          bind-key -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'resize-pane -L 3'
          bind-key -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'resize-pane -D 3'
          bind-key -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'resize-pane -U 3'
          bind-key -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'resize-pane -R 3'

          # -- Scrolling --
          bind-key -T root WheelUpPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
          bind-key -T root WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"
          bind-key -T copy-mode-vi WheelUpPane send-keys -X halfpage-up
          bind-key -T copy-mode-vi WheelDownPane send-keys -X halfpage-down

          # -- Copy mode --
          bind -T copy-mode-vi v send -X begin-selection # start selecting text with "v"
          bind -T copy-mode-vi C-v send -X rectangle-toggle
          bind -T copy-mode-vi y send -X copy-selection-and-cancel # copy text with "y"
          bind -T copy-mode-vi Escape send -X cancel
          bind -T copy-mode-vi ^ send -X start-of-line
          bind -T copy-mode-vi $ send -X end-of-line

        '';
    };
  };
}
