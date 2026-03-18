{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ../../pkgs/symposium { })
  ];

  # v2.0.1 uses ~/.symposium/ on all platforms (dirs::home_dir, not dirs::config_dir)
  home.file.".symposium/config/agent.json".text = builtins.toJSON {
    agent.local = {
      command = "kiro-cli";
      args = [ "acp" ];
    };
  };
}
