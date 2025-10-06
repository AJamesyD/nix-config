_:

{
  programs = {
    zellij = {
      # TODO: Re-enable when I figure out why it launches automatically
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };
    zsh = {
      shellAliases = {
        zja = # bash
          ''
            zellij a "$(zellij list-sessions --no-formatting --short | fzf --prompt='attach> ')"
          '';
        zjd = # bash
          ''
            zellij delete-session "$(zellij list-sessions --no-formatting --short | fzf --prompt='delete> ')"
          '';
      };
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "zellij" = {
        enable = true;
        source = ../users/angaidan/.config/zellij;
        recursive = true;
      };
    };
  };
}
