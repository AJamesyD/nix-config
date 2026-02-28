_: {
  programs = {
    go = {
      enable = true;
      env = {
        goBin = ".local/bin.go";
      };
    };
    java = {
      enable = true;
    };
    mise = {
      enable = true;
      globalConfig = {
        settings = {
          legacy_version_file = false;
          yes = true;
        };
        tool_alias = {
          usage = "usage:jdx/mise-usage";
        };
        tools = {
          # NOTE: First one becomes default
          python = [
            "3.12"
          ];
          usage = [
            "latest"
          ];
        };
      };
    };
    uv = {
      enable = true;
    };
  };

  xdg.configFile = {
    "mise/config.toml" = {
      onChange = # bash
        ''
          run --quiet mise plugins install --all --yes --quiet
          run --quiet mise install --yes --quiet
        '';
    };
  };
}
