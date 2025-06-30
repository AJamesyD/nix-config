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
      userEmail = "angaidan@amazon.com";
      userName = "Aidan De Angelis";
    };
    zsh = {
      initContent = lib.mkMerge [
        (lib.mkOrder 550
          # bash
          ''
            path+=("$ZCOMPDIR")
            fpath+=("$ZCOMPDIR")

            local BRAZIL_ZSH_COMPLETION="${brazilCompletionDir}/zsh_completion"
            if [[ -f "$BRAZIL_ZSH_COMPLETION" ]]; then
                    source "$BRAZIL_ZSH_COMPLETION"
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

        DEV_DESK_HOSTNAME_AL2_X86 = "i-0350c0ed5d6a69b55";
        DEV_DESK_HOSTNAME_AL2023_X86 = "i-0636016045fe041a8";
        DEV_DESK_HOSTNAME_AL2023_ARM = "i-087650b5a8686c1a4";
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

        devdesk-al2-x86 = "ssh -t $DEV_DESK_HOSTNAME_AL2_X86 zsh -l";
        devdesk-al2023-x86 = "ssh -t $DEV_DESK_HOSTNAME_AL2023_X86 zsh -l";
        devdesk-al2023-arm = "ssh -t $DEV_DESK_HOSTNAME_AL2023_ARM zsh -l";
      };
    };
  };
  xdg = {
    enable = true;
    configFile = {
      "mcphub/servers.json" = {
        text = builtins.toJSON {
          mcpServers = {
            "awslabs.core-mcp-server" = {
              disabled = false;
              command = "uvx";
              args = [
                "awslabs.core-mcp-server@latest"
              ];
              autoApprove = [
                "prompt_understanding"
              ];
              env = {
                "FASTMCP_LOG_LEVEL" = "ERROR";
              };
            };
            "awslabs.cdk-mcp-server" = {
              disabled = false;
              command = "uvx";
              args = [
                "awslabs.cdk-mcp-server@latest"
              ];
              autoApprove = [
                "CDKGeneralGuidance"
                "GetAwsSolutionsConstructPattern"
              ];
              env = {
                FASTMCP_LOG_LEVEL = "ERROR";
              };
            };
            "awslabs.aws-documentation-mcp-server" = {
              disabled = false;
              command = "uvx";
              args = [ "awslabs.aws-documentation-mcp-server@latest" ];
              autoApprove = [
                "read_documentation"
                "search_documentation"
              ];
              env = {
                "FASTMCP_LOG_LEVEL" = "ERROR";
              };
            };
            amzn-mcp = {
              disabled = false;
              command = "amzn-mcp";
              args = [ ];
              autoApprove = [
                "read_internal_wesites"
                "search_internal_code"
                "search_internal_websites"
              ];
              env = { };
            };
            wasabi = {
              disabled = false;
              command = "wasabi";
              args = [ "--mcp-server" ];
              autoApprove = [
                "BrazilBuildAnalyzerTool"
                "CRRevisionCreator"
                "CheckFilepathforCAZ"
                "CrCheckout"
                "Delegate"
                "InternalCodeSearchTool"
                # "InternalSearch"
                # "ReadInternalWebsites"
                "WorkspaceGitDetails"
                "WorkspaceSearch"
              ];
            };
          };
          nativeMCPServers = [

          ];
        };
      };
      # MISE_NODE_DEFAULT_PACKAGES_FILE must be set
      "mise/default-node-packages" = {
        text = ''
          mcp-hub
        '';
      };
    };
  };
}
