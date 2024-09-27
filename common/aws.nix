{ config, pkgs, ... }:
{
  home = {
    sessionPath =
      if !pkgs.stdenv.isDarwin then
        [
          # Ensure consumed envs end up on PATH
          "/apollo/env/bt-rust/bin"
        ]
      else
        [
          "${config.home.homeDirectory}/.toolbox/bin"
        ];
  };

  programs = {
    zsh = {
      envExtra = ''
        export DEV_DESK_HOSTNAME='dev-dsk-angaidan-2b-8ba1a9f5.us-west-2.amazon.com'
        export DEV_DESK_HOSTNAME_ARM='dev-dsk-angaidan-2a-e67dd8f6.us-west-2.amazon.com'
      '';
      sessionVariables = {
        BRAZIL_PLATFORM_OVERRIDE =
          if pkgs.stdenv.hostPlatform.isAarch64 then
            "AL2_aarch64"
          else if pkgs.stdenv.hostPlatform.isx86_64 then
            "AL2_x86_64"
          else
            null;
      };
      shellAliases = {
        bb = "brazil-build";
        bba = "brazil-build apollo-pkg";
        bre = "brazil-runtime-exec";
        brc = "brazil-recursive-cmd";
        bws = "brazil ws";
        bwsuse = "bws use -p";
        bwscreate = "bws create -n";
        bbr = "brc brazil-build";
        bball = "brc --allPackages";
        bbb = "brc --allPackages brazil-build";
        bbra = "bbr apollo-pkg";

        devdesk = "ssh -XY $DEV_DESK_HOSTNAME";
        devdesk-arm = "ssh -XY $DEV_DESK_HOSTNAME_ARM";
      };
    };
  };

  programs.zsh.initExtraBeforeCompInit = ''
    fpath+=("${config.home.homeDirectory}/.zsh/completion")
    fpath+=("${config.home.homeDirectory}/.brazil_completion/zsh_completion")
  '';
}
