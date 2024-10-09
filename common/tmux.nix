{
  config,
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
          set -g update-environment -r

          set -g status-position top

          set -g status-interval 1

          set -ag terminal-overrides ",alacritty*:Tc,foot*:Tc,xterm-kitty*:Tc,xterm-256color:Tc"

          set -as terminal-features ",alacritty*:RGB,foot*:RGB,xterm-kitty*:RGB"
          set -as terminal-features ",alacritty*:hyperlinks,foot*:hyperlinks,xterm-kitty*:hyperlinks"
          set -as terminal-features ",alacritty*:usstyle,foot*:usstyle,xterm-kitty*:usstyle"

          set -g display-panes-time 800
          set -g display-time 1000

          setw -g automatic-rename
          set -g renumber-windows on
          set -g set-titles on

          setw -g monitor-activity on
          set -g visual-activity off

          set -g set-clipboard on

          bind C-a last-window
          bind R source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."

          bind : command-prompt
          bind r refresh-client
          bind L clear-history

          bind space next-window
          bind bspace previous-window
          bind enter next-layout

          bind h  select-pane -L
          bind j  select-pane -D
          bind k  select-pane -U
          bind l  select-pane -R

          unbind %
          bind | split-window -h -c "#{pane_current_path}"

          unbind '"'
          bind -  split-window -v -c "#{pane_current_path}"

          bind C-o rotate-window

          bind + select-layout main-horizontal
          bind = select-layout main-vertical

          bind a last-pane
          bind q display-panes
          bind c new-window
          bind t next-window
          bind T previous-window

          bind [ copy-mode
          bind ] paste-buffer
          bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
          bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

          # https://github.com/mrjones2014/smart-splits.nvim?tab=readme-ov-file#tmux
          # Smart pane resizing with awareness of Neovim splits.
          bind-key -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'resize-pane -L 3'
          bind-key -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'resize-pane -D 3'
          bind-key -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'resize-pane -U 3'
          bind-key -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'resize-pane -R 3'
        '';
    };
  };
}
