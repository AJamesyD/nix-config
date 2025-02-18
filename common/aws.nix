{
  config,
  lib,
  pkgs,
  ...
}:
let
  brazilCompletionDir = "${config.home.homeDirectory}/.brazil_completion";
in
{
  home = {
    activation = {
      builderToolbox =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "envSetup"
          ] # bash
          ''
            run --quiet toolbox completion zsh >"$ZCOMPDIR/_toolbox"
            run --quiet toolbox update
            run --quiet toolbox clean

            if $(command -v axe 2>&1 >/dev/null); then
                    run --quiet axe completion zsh >"$ZCOMPDIR/_axe"
            fi

            if $(command -v ada 2>&1 >/dev/null); then
                    run --quiet ada completion zsh >"$ZCOMPDIR/_ada"
            fi
          '';
      brazil =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "builderToolbox"
          ] # bash
          ''
            # Brazil will write ~/.brazil_completion/zsh_completion then fail to modify .zshrc
            run --silence brazil setup completion --shell zsh || true
          '';
    };
    sessionPath =
      if !pkgs.stdenv.isDarwin then
        [
          # Ensure consumed envs end up on PATH
          "/apollo/env/bt-rust/bin"
          "${config.home.homeDirectory}/.toolbox/bin"
        ]
      else
        [
          "${config.home.homeDirectory}/.toolbox/bin"
        ];
  };

  programs = {
    git = {
      userEmail = "angaidan@amazon.com";
      userName = "Aidan De Angelis";
    };
    zsh = {
      initExtraBeforeCompInit = # bash
        ''
          path+=("$ZCOMPDIR")
          fpath+=("$ZCOMPDIR")

          local BRAZIL_ZSH_COMPLETION="${brazilCompletionDir}/zsh_completion"
          if [[ -f "$BRAZIL_ZSH_COMPLETION" ]]; then
                  source "$BRAZIL_ZSH_COMPLETION"
          else
                  echo "WARNING: brazil zsh completions have not been set up"
          fi
        '';
      sessionVariables = {
        # From default .zshrc written by `brazil setup completion`
        # if you wish to use IMDS set AWS_EC2_METADATA_DISABLED=false
        AWS_EC2_METADATA_DISABLED = true;
        BRAZIL_PLATFORM_OVERRIDE =
          if pkgs.stdenv.hostPlatform.isAarch64 then
            "AL2_aarch64"
          else if pkgs.stdenv.hostPlatform.isx86_64 then
            "AL2_x86_64"
          else
            null;

        DEV_DESK_HOSTNAME = "dev-dsk-angaidan-2b-8ba1a9f5.us-west-2.amazon.com";
        DEV_DESK_HOSTNAME_ARM = "dev-dsk-angaidan-2a-e67dd8f6.us-west-2.amazon.com";
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

        cb-dry-run = "/apollo/env/bt-rust/bin/rust-customer-dry-runs";

        devdesk = "ssh -t $DEV_DESK_HOSTNAME zsh -l";
        devdesk-arm = "ssh -t $DEV_DESK_HOSTNAME_ARM zsh -l";
      };
    };
  };
}
