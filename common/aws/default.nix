{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = config.home.username;
in
{
  imports = [ ./toolbox.nix ];

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
      toolboxCompletions =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "envSetup"
            "toolboxTools"
          ] # bash
          ''
            # Don't use `run --quiet` for completion generation: it redirects stdout
            # to /dev/null internally, so `run --quiet cmd > file` produces empty files
            toolbox completion zsh >"$ZCOMPDIR/_toolbox" 2>/dev/null

            if command -v axe >/dev/null 2>&1; then
            	axe completion zsh >"$ZCOMPDIR/_axe" 2>/dev/null
            fi

            if command -v ada >/dev/null 2>&1; then
            	ada completion zsh >"$ZCOMPDIR/_ada" 2>/dev/null
            fi

            if command -v eda >/dev/null 2>&1; then
            	eda completions zsh >"$ZCOMPDIR/_eda" 2>/dev/null
            fi
          '';
    };

    packages = with pkgs; [
      awscli2
      aws-cdk-cli
    ];

    sessionPath = lib.optionals pkgs.stdenv.isLinux [ "/apollo/env/bt-rust/bin" ];
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
      includes =
        let
          personalDirs = [
            "~/Code/"
            "~/.config/"
          ];
        in
        map (dir: {
          # gitdir/i: for case-insensitive match (~/Code vs ~/code on Linux)
          condition = "gitdir/i:${dir}";
          contents.user.email = "aidandeangelis@berkeley.edu";
        }) personalDirs;
    };
    jujutsu.settings = {
      user = {
        name = "Aidan De Angelis";
        email = "angaidan@amazon.com";
      };
      git.push-bookmark-prefix = "angaidan/push-";
      "--scope" =
        map
          (dir: {
            condition.repositories = [ dir ];
            user.email = "aidandeangelis@berkeley.edu";
          })
          [
            "~/Code/"
            "~/code/"
            "~/.config/"
          ];
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
            local _bz_comp=(~/.toolbox/tools/brazilcli/*/bin/brazil_completion.zsh(NOm[1]))
            if [[ -n "$_bz_comp" ]]; then
            	functions[__saved_compinit]=$functions[compinit]
            	compinit() { : }
            	source "$_bz_comp"
            	functions[compinit]=$functions[__saved_compinit]
            	unfunction __saved_compinit
            fi
          ''
        )
        (builtins.readFile ./brazil-context-hook.zsh)
      ];
      sessionVariables = {
        # From default .zshrc written by `brazil setup completion`
        # if you wish to use IMDS set AWS_EC2_METADATA_DISABLED=false
        AWS_EC2_METADATA_DISABLED = "true";
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
            brazil-package-cache clean --days=7
            ${lib.optionalString pkgs.stdenv.isDarwin "brew cleanup --prune=all"}
            npm cache clean --force
            uv cache clean
            toolbox clean
            rm -rf ~/.cache/nix ~/.cache/zig ~/.cache/bazel ~/.cache/puppeteer
            rm -rf ~/.npm/_npx
            rm -rf ~/.builder-mcp/logs
            rm -rf ~/.local/share/opencode/log
            rm -rf ~/.gradle/caches
            go clean -modcache 2>/dev/null || true
            ${lib.optionalString pkgs.stdenv.isDarwin ''rm -rf ~/Library/Caches/com.spotify.client ~/Library/Application\ Support/com.apple.wallpaper ~/Library/Application\ Support/Spotify/PersistentCache ~/Library/Caches/zen ~/Library/Application\ Support/Slack/Cache ~/Library/Application\ Support/Slack/Service\ Worker ~/Library/Containers/com.apple.wallpaper.agent/Data ~/Library/Application\ Support/zoom.us/asr''}
            ${pkgs.fd}/bin/fd --changed-before 2d . /tmp | ${pkgs.parallel}/bin/parallel --will-cite rm -rf {} 2>/dev/null
          '';

        al2-x86-cdd = "ssh -t $CDD_HOSTNAME_AL2_X86 zsh -l";
      };
    };
  };
}
