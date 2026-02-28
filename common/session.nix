{ config, ... }:
{
  home = {
    # since zsh.dotDir is set, still create ~/.zshrc so that it is write-protected against
    # random programs trying to append to it
    file = {
      ".zshrc" = {
        text = # bash
          ''
            # This file is intentionally empty.

            # When zsh.dotDir is set, still create ~/.zshrc so that it is write-protected against
            # random programs trying to append to it
          '';
      };
    };

    preferXdgDirectories = true;
    sessionVariables = {
      EDITOR = "nvim";
      LESSHISTFILE = "${config.xdg.dataHome}/less_history";

      BACON_PREFS = "${config.xdg.configHome}/bacon/prefs.toml";

      # $BAT_THEME reused by git delta
      BAT_THEME = "tokyonight-night";

      GOPROXY = "direct";

      MISE_NODE_DEFAULT_PACKAGES_FILE = "${config.xdg.configHome}/mise/default-node-packages";
      MISE_PYTHON_DEFAULT_PACKAGES_FILE = "${config.xdg.configHome}/mise/default-python-packages";
      # https://github.com/jdx/mise/issues/3099
      MISE_LIBGIT2 = "false";
    };
  };

  xdg.enable = true;
}
