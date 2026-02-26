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
            export PATH="$PATH:${config.home.homeDirectory}/.toolbox/bin"

            run --quiet toolbox completion zsh >"$ZCOMPDIR/_toolbox"
            run --quiet toolbox update
            run --quiet toolbox clean

            if $(command -v axe 2>&1 >/dev/null); then
            	run --quiet axe completion zsh >"$ZCOMPDIR/_axe"
            fi

            if $(command -v ada 2>&1 >/dev/null); then
            	run --quiet ada completion zsh >"$ZCOMPDIR/_ada"
            fi

            if $(command -v eda 2>&1 >/dev/null); then
            	run --quiet eda completions zsh >"$ZCOMPDIR/_eda"
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

    packages = with pkgs; [
      awscli2
      cdk
    ];

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
      settings.user = {
        email = "angaidan@amazon.com";
        name = "Aidan De Angelis";
      };
    };
    zsh = {
      initContent = lib.mkMerge [
        (lib.mkOrder 550
          # bash
          ''
            local BRAZIL_ZSH_COMPLETION="${brazilCompletionDir}/zsh_completion"
            if [[ -f "$BRAZIL_ZSH_COMPLETION" ]]; then
            	# PERF: brazil_completion.zsh calls compinit internally — suppress
            	# the redundant call (already done earlier) but allow bashcompinit.
            	functions[__saved_compinit]=$functions[compinit]
            	compinit() { : }
            	source "$BRAZIL_ZSH_COMPLETION"
            	functions[compinit]=$functions[__saved_compinit]
            	unfunction __saved_compinit
            else
            	echo "WARNING: brazil zsh completions have not been set up"
            fi
          ''
        )
      ];
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

        CDD_HOSTNAME_AL2_X86 = "dev-dsk-angaidan-2a-4351fd5e.us-west-2.amazon.com";
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

        clean = # bash
          ''
            nix-clean
            brazil-package-cache clean
            ${pkgs.fd}/bin/fd --changed-before 2d . /tmp | ${pkgs.parallel}/bin/parallel --will-cite rm -rf
          '';

        al2-x86-cdd = "ssh -t $CDD_HOSTNAME_AL2_X86 zsh -l";
      };
    };
  };
}
