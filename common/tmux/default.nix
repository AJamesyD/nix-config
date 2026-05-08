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
  # Pre-build which-key init.tmux from config YAML at Nix build time so every
  # machine gets a correct init.tmux without needing python3 at tmux runtime.
  # The vendored pyyaml submodule is empty in the Nix source, so we patch the
  # import to use the Nix-provided package instead.
  tmux-which-key-init =
    pkgs.runCommand "tmux-which-key-init"
      {
        nativeBuildInputs = [ (pkgs.python3.withPackages (ps: [ ps.pyyaml ])) ];
      }
      ''
        cp ${inputs.tmux-which-key}/plugin/build.py build.py
        substituteInPlace build.py --replace-fail "from pyyaml.lib import yaml" "import yaml"
        mkdir -p $out
        python3 build.py ${./which-key.yaml} $out/init.tmux
      '';
in
{
  # Catppuccin plugin handles tmux theming; stylix's base16 conf
  # runs after catppuccin's run-shell and overwrites its colors.
  stylix.targets.tmux.enable = false;

  xdg.configFile."tmux-plugins/tmux-which-key/config.yaml" = {
    source = ./which-key.yaml;
    force = true; # Plugin creates this file on first run; force ensures Nix wins
  };
  xdg.configFile."sesh/sesh.toml".source = ./sesh.toml;
  xdg.dataFile."tmux-plugins/tmux-which-key/init.tmux" = {
    source = "${tmux-which-key-init}/init.tmux";
    force = true; # Plugin copies init.example.tmux on first run; force ensures Nix wins
  };

  home = {
    packages = with pkgs; [
      gum
      sesh
    ];
  };
  programs = {
    tmux = {
      enable = true;
      aggressiveResize = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 0;
      focusEvents = true;
      historyLimit = 300000;
      keyMode = "vi";
      # Keyboard-only workflow; links clickable natively with mouse off
      mouse = false;
      disableConfirmationPrompt = true;
      newSession = false;
      # HM ordering: for each plugin, extraConfig is emitted then run-shell.
      # The main extraConfig block comes AFTER all plugins. Anything set there
      # overwrites what plugins did in their run-shell. Set status-left/right
      # in a plugin extraConfig (before continuum), not in the main block.
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

              set -g @truncated_directory_text "#{s|#{HOME}|~|;s|/local~|~|;s|/workplace/${config.home.username}|~|;s|/.*/([^/^~]*/)|/…/\\1|:pane_current_path}"
              set -g @catppuccin_directory_text "#{E:@truncated_directory_text}"

              # More prefix modes
              set -g @prefix_mode_highlight "#{E:@thm_red}"
              set -g @copy_mode_highlight "#{E:@thm_lavender}"
              set -g @empty_mode_highlight "#{E:@thm_green}"
              set -g @fallback_mode_highlight "#{?pane_in_mode,#{E:@copy_mode_highlight},#{E:@empty_mode_highlight}}"
              set -g @catppuccin_session_color "#{?client_prefix,#{E:@prefix_mode_highlight},#{E:@fallback_mode_highlight}}"

              # Status bar layout (set here, before continuum, so continuum can
              # append its save trigger to status-right without being overwritten)
              set -g status-left-length 100
              set -g status-left "#{?client_prefix,#[bg=#{E:@thm_red},fg=#{E:@thm_crust}] PREFIX #[default] ,#{?pane_in_mode,#[bg=#{E:@thm_lavender},fg=#{E:@thm_crust}] COPY #[default] ,}}"
              set -g status-right-length 100
              set -g status-right "#{E:@catppuccin_status_directory}"
              set -ag status-right "#{E:@catppuccin_status_session}"
            '';
        }
        pain-control
        {
          plugin = resurrect.overrideAttrs (_: {
            src = inputs.tmux-resurrect;
            # The github: fetcher doesn't fetch submodules, so lib/tmux-test is
            # absent and its symlinks dangle. The test infra isn't needed at runtime.
            dontCheckForBrokenSymlinks = true;
          });
          extraConfig = # tmux
            ''
              set -g @resurrect-dir '${config.xdg.dataHome}/tmux/resurrect'
              set -g @resurrect-capture-pane-contents 'on'

              set -g @resurrect-strategy-vim 'session'
              set -g @resurrect-strategy-nvim 'session'
            '';
        }
        {
          plugin = tmux-fzf.overrideAttrs (_: {
            src = inputs.tmux-fzf;
          });
          extraConfig = # tmux
            ''
              TMUX_FZF_LAUNCH_KEY="F"
            '';
        }
        {
          plugin = tmux-which-key;
          extraConfig = # tmux
            ''
              set -g @tmux-which-key-xdg-plugin-path tmux-plugins/tmux-which-key
              set -g @tmux-which-key-disable-autobuild 1  # Nix pre-builds init.tmux; no python3 needed at runtime
              set -g @tmux-which-key-xdg-enable 1
            '';
        }
        # continuum must be the last plugin. It prepends #(continuum_save.sh)
        # to status-right at run-shell time. Any later status-right set kills auto-save.
        {
          plugin = continuum.overrideAttrs (_: {
            src = inputs.tmux-continuum;
          });
          extraConfig = # tmux
            ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '5'
            '';
        }
      ];
      secureSocket = true;
      shell = "${pkgs.zsh}/bin/zsh";
      # Prefix is C-b (default). C-a is freed for which-key root table binding.
      terminal = "tmux-256color";
      extraConfig = builtins.readFile ./extra.conf;
    };
  };
}
