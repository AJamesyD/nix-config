{
  config,
  lib,
  pkgs,
  ...
}:
let
  catpuccinPluginPath = "${config.xdg.dataHome}/tmux/catppuccin-plugins";
in
{
  home.file = {
    "${catpuccinPluginPath}/prefix_highlight.sh" = {
      text = # bash
        ''
          show_prefix_highlight() { # This function name must match the module name!
            local index icon color text module

            tmux_batch_setup_status_module "prefix_highlight"

            # tmux_batch_options_commands+=(set-option -gq @prefix_highlight_fg "colour55")
            # tmux_batch_options_commands+=(set-option -gq @prefix_highlight_bg "colour100")
            # tmux_batch_options_commands+=(set-option -gq @prefix_highlight_empty_attr "fg=green,bg=green")
            # tmux_batch_options_commands+=(set-option -gq @prefix_highlight_copy_mode_attr "fg=yellow,bg=yellow,bold")

            run_tmux_batch_commands

            index=$1 # This variable is used internally by the module loader in order to know the position of this module

            # TODO: figure this thing out
            color=$( get_tmux_option "@catppuccin_prefix_highlight_color" "#{?client_prefix,$thm_magenta,#{?pane_in_mode,$thm_yellow,$thm_black}}")
            text=$(  get_tmux_option "@catppuccin_prefix_highlight_text"  "#{prefix_highlight}" )

            module=$( build_status_module "$index" "$icon" "$color" "$text" )

            echo "$module"
          }
        '';
    };
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
      mouse = true; # Remove once good
      newSession = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = catppuccin;
          extraConfig = # tmux
            ''
              set -g @catppuccin_flavor 'mocha'
              set -g @catppuccin_custom_plugin_dir "${catpuccinPluginPath}"

              set -g @catppuccin_window_default_fill "number"
              set -g @catppuccin_window_current_fill "number"
              # set -g @catppuccin_window_default_text "#{s|#{HOME}|~|;s|/local~|~|;s|/.*/([^/^~]*/)|/…/\\1|:pane_current_path}"
              set -g @catppuccin_window_default_text "#{W}"
              set -g @catppuccin_window_current_text "#{s|#{HOME}|~|;s|/local~|~|;s|/.*/([^/^~]*/)|/…/\\1|:pane_current_path}#{?window_zoomed_flag,(),}"
              set -g @catppuccin_window_left_separator "█"
              set -g @catppuccin_window_middle_separator "  █"
              set -g @catppuccin_window_right_separator "█ "
              set -g @catppuccin_window_number_position "right"
              set -g @catppuccin_window_status "icon"

              set -g @catppuccin_status_fill "all"
              set -g @catppuccin_status_connect_separator "yes"
              set -g @catppuccin_status_left_separator  ""
              set -g @catppuccin_status_right_separator " "
              set -g @catppuccin_status_modules_right "prefix_highlight directory date_time"

              set -g @catppuccin_directory_text "#{s|#{HOME}|~|;s|/local~|~|:pane_current_path}"
              set -g @catppuccin_date_time_text "%H:%M"
            '';
        }
        {
          plugin = continuum;
          extraConfig = # tmux
            ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '5'
            '';
        }
        {
          plugin = prefix-highlight;
          extraConfig = # tmux
            ''
              set -g @prefix_highlight_prefix_prompt 'Prefix'
              set -g @prefix_highlight_empty_prompt  'Tmux'
              set -g @prefix_highlight_show_copy_mode 'on'
              set -g @prefix_highlight_copy_prompt   'Copy'
            '';
        }
        {
          plugin = resurrect;
          extraConfig = # tmux
            ''
              set -g @resurrect-dir '${config.xdg.dataHome}/tmux/resurrect'
              set -g @resurrect-capture-pane-contents 'on'
            '';
        }
        # {
        #   plugin = tmuxplugin-sessionx;
        #   extraConfig = # tmux
        #     '''';
        # }
        {
          plugin = tmux-fzf;
          extraConfig = # bash
            '''';
        }
        vim-tmux-navigator
      ];
      secureSocket = false;
      shortcut = "a";
      terminal = "tmux-256color";
      extraConfig = # tmux
        ''
          # -- Options ----------------------------------------------------------------
          set -g update-environment -r
          set -g default-command ${(lib.getExe pkgs.zsh)}

          set -g status-position top
          set -q -g status-utf8 on # expect UTF-8 (tmux < 2.2)
          setw -q -g utf8 on

          set -g status-interval 1

          set -as terminal-features ",*:clipboard"
          set -as terminal-features ",*:extkeys"
          set -as terminal-features ",*:focus"
          set -as terminal-features ",*:hyperlinks"
          set -as terminal-features ",*:RGB"
          set -as terminal-features ",*:strikethrough"
          set -as terminal-features ",*:usstyle"

          set -g display-panes-time 800
          set -g display-time 1000

          setw -g automatic-rename on
          set -g renumber-windows on
          set -g set-titles on

          setw -g monitor-activity on
          set -g visual-activity off

          set -g set-clipboard on

          setw -g xterm-keys on
          # -- Bindings ----------------------------------------------------------------
          # -- Misc --
          bind : command-prompt
          bind r refresh-client

          # -- Session/Window/Pane --
          bind C-c new-session # create session
          bind C-f command-prompt -p find-session 'switch-client -t %%' # find session

          unbind n
          unbind p
          bind -r C-h previous-window # select previous window
          bind -r C-l next-window     # select next window

          unbind %
          bind | split-window -h -c "#{pane_current_path}"

          unbind '"'
          bind -  split-window -v -c "#{pane_current_path}"

          bind C-o rotate-window

          # pane navigation
          bind -r h select-pane -L  # move left
          bind -r j select-pane -D  # move down
          bind -r k select-pane -U  # move up
          bind -r l select-pane -R  # move right
          bind > swap-pane -D       # swap current pane with the next one
          bind < swap-pane -U       # swap current pane with the previous one

          # https://github.com/mrjones2014/smart-splits.nvim?tab=readme-ov-file#tmux
          # Smart pane resizing with awareness of Neovim splits.
          bind-key -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'resize-pane -L 3'
          bind-key -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'resize-pane -D 3'
          bind-key -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'resize-pane -U 3'
          bind-key -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'resize-pane -R 3'

          bind + select-layout main-horizontal
          bind = select-layout main-vertical

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
