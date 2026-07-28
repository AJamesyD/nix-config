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

        al2-x86-cdd = "ssh -t $CDD_HOSTNAME_AL2_X86 zsh -l";
      };
      siteFunctions = {
        clean = # bash
          ''
            _timed() { timeout "$1" "''${@:2}" || { [[ $? -eq 124 ]] && printf '\e[33m  ↳ %s timed out after %ss\e[0m\n' "$2" "$1"; }; true; }

            printf '\e[2m[clean] nix store\e[0m\n'
            nix-clean

            printf '\e[2m[clean] package manager caches\e[0m\n'
            command -v brazil-package-cache &>/dev/null && _timed 60 brazil-package-cache clean --days=7
            ${lib.optionalString pkgs.stdenv.isDarwin "_timed 60 brew cleanup --prune=all"}
            _timed 60 npm cache clean --force
            _timed 60 uv cache clean
            command -v go &>/dev/null && _timed 60 go clean -modcache

            printf '\e[2m[clean] dev tool caches\e[0m\n'
            command -v toolbox &>/dev/null && _timed 60 toolbox clean
            rm -rf ~/.builder-mcp/logs
            rm -rf ~/.local/share/opencode/log
            rm -rf ~/.gradle/caches

            printf '\e[2m[clean] temp files\e[0m\n'
            rm -rf ~/.cache/nix ~/.cache/zig ~/.cache/bazel ~/.cache/puppeteer
            rm -rf ~/.npm/_npx
            # --print0/--null: space-safe, --will-cite: no nag, --owner: skip others' files
            _timed 120 bash -c 'LC_ALL=C ${pkgs.fd}/bin/fd --changed-before 2d --print0 --owner $(id -u) . /tmp | ${pkgs.parallel}/bin/parallel --null --will-cite rm -rf {} 2>/dev/null'

            ${lib.optionalString pkgs.stdenv.isDarwin ''
              printf '\e[2m[clean] macOS app caches\e[0m\n'
              rm -rf ~/Library/Caches/com.spotify.client
              rm -rf ~/Library/Application\ Support/Spotify/PersistentCache
              rm -rf ~/Library/Caches/zen
              rm -rf ~/Library/Application\ Support/Slack/Cache
              rm -rf ~/Library/Application\ Support/Slack/Service\ Worker
              rm -rf ~/Library/Application\ Support/com.apple.wallpaper
              rm -rf ~/Library/Containers/com.apple.wallpaper.agent/Data
              rm -rf ~/Library/Application\ Support/zoom.us/asr
            ''}
          '';
      };
    };
  };
}
