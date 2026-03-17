{
  config,
  lib,
  pkgs,
  ...
}:
let
  brazilCompletionDir = "${config.home.homeDirectory}/.brazil_completion";
  user = config.home.username;
in
{
  home = {
    # Persistent socket avoids repeated auth handshakes for git operations
    file.".ssh/config.d/aws.conf".text = ''
      Host git.amazon.com
        ControlMaster auto
        ControlPath ~/.ssh/control-%C
        ControlPersist 12h
        User ${user}
    '';

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

            if command -v axe >/dev/null 2>&1; then
            	run --quiet axe completion zsh >"$ZCOMPDIR/_axe"
            fi

            if command -v ada >/dev/null 2>&1; then
            	run --quiet ada completion zsh >"$ZCOMPDIR/_ada"
            fi

            if command -v eda >/dev/null 2>&1; then
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
      # Point brazil package cache at the case-sensitive APFS volume (macOS only).
      # Without this, brazil defaults to ~/brazil-pkg-cache on the
      # case-insensitive root volume and warns on every cache operation.
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      brazilPackageCache =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "brazil"
          ] # bash
          ''
            if [[ -d /Volumes/brazil-pkg-cache ]]; then
            	run brazil prefs --key packagecache.cacheRoot --value /Volumes/brazil-pkg-cache --global
            	run brazil prefs --key packagecache.visibleCacheRoot --value /Volumes/brazil-pkg-cache --global
            else
            	_iWarn "brazil-pkg-cache volume not found. Create it with: diskutil apfs addVolume \"\$(diskutil apfs list | awk -F: '/Container Reference/{gsub(\" \",\"\"); print \$2}')\" 'Case-sensitive APFS' brazil-pkg-cache"
            fi
          '';
    };

    packages = with pkgs; [
      awscli2
      cdk
    ];

    sessionPath = [
      "${config.home.homeDirectory}/.toolbox/bin"
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [ "/apollo/env/bt-rust/bin" ];
  };

  # bemol: generate ty.toml alongside pyright/pylance for Brazil
  # Python packages so ty can resolve third-party imports.
  xdg.configFile."bemol/bemol.toml".text = ''
    [Python]
    language-servers = ['ty', 'pyright', 'pylance']
  '';

  programs = {
    git = {
      settings = {
        # Read by the `cr` CLI (CRUX)
        amazon = {
          append-cr-url = true;
          pull-request-by-default = true;
        };
        user = {
          email = "angaidan@amazon.com";
          name = "Aidan De Angelis";
        };
        init.defaultBranch = "mainline";
      };
    };
    jujutsu.settings = {
      user = {
        name = "Aidan De Angelis";
        email = "angaidan@amazon.com";
      };
      git.push-bookmark-prefix = "angaidan/push-";
    };
    zsh = {
      initContent = lib.mkMerge [
        # Toolbox before nix-profile so Amazon tools take precedence
        ''
          path=("$HOME/.toolbox/bin" ''${path:#$HOME/.toolbox/bin})
        ''
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
            ${lib.optionalString pkgs.stdenv.isDarwin "brew cleanup --prune=all"}
            npm cache clean --force
            uv cache clean
            ${pkgs.fd}/bin/fd --changed-before 2d . /tmp | ${pkgs.parallel}/bin/parallel --will-cite rm -rf
          '';

        al2-x86-cdd = "ssh -t $CDD_HOSTNAME_AL2_X86 zsh -l";
      };
    };
  };
}
