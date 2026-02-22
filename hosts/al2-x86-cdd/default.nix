{
  pkgs,
  ...
}:
{
  imports = [
    ../../common/aws.nix
    ../../common/dev.nix
    ../../common/nix-hm.nix
  ];

  home = {
    packages = with pkgs; [
      (lib.hiPrio opensshWithKerberos)
      krb5

      ruby

      stylua

      # https://github.com/nixos/nixpkgs/issues/456113
      cargo-nextest
    ];
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.11"; # Please read the comment before changing.
  };

  programs = {
    bob-nvim = {
      enable = true;
    };
    mise = {
      enable = true;
      globalConfig = {
        tool_alias = {
          node = "node:ssh://git.amazon.com/pkg/RtxNode";
        };
        tools = {
          node =
            let
              postinstall = ''xargs npm i -g < "$MISE_NODE_DEFAULT_PACKAGES_FILE"'';
            in
            [
              # TODO: move to aliases once RtxNode gets it together
              # "lts-job" # v22
              # "lts-iron" # v20
              # "lts-hydrogen" # v18
              # NOTE: First one becomes default
              {
                version = "lts";
                inherit postinstall;
              }
              {
                version = "22";
                inherit postinstall;
              }
              {
                version = "20";
                inherit postinstall;
              }
              {
                version = "18";
                inherit postinstall;
              }
            ];
        };
      };
    };
    zsh = {
      enable = true;
      shellAliases = {
        auth = "mwinit -o";
        nixup = # bash
          ''
            ghauth
            nix flake update --flake ~/.config/nix --option access-tokens "github.com=$GITHUB_TOKEN"
            home-manager switch --flake ~/.config/nix#al2-x86-cdd --option access-tokens "github.com=$GITHUB_TOKEN"
            zsource
          '';
        up = "sudo yum upgrade -y && nixup";
        # Borrowed from https://github.com/shell-pool/shpool/issues/49#issue-2355077641
        shll = # bash
          ''
            # shpool session selector
            # keybindings:
            #     k/x to kill
            #     a/n/enter to attach
            # Shortcut: ctrl+a then w
            shpool_choose() {
            	cmd_output=$(
            		shpool list | tail -n +2 | cut -f1 | fzf \
            			--bind 'k:execute(shpool kill {})' \
            			--bind 'x:execute(shpool kill {})' \
            			--bind 'a:execute(shpool attach --force {})' \
            			--bind 'n:execute(shpool attach --force {})' \
            			--preview 'shpool list | tail -n +2 | sed -n "$(({n}+1))"p' \
            			--bind "change:reload(shpool list | tail -n +2)" \
            			--reverse \
            			--height=~100% \
            			--preview-window down:wrap \
            			--header "Shpool sessions" \
            			--no-select-1 \
            			--no-exit-0
            	)

            	# notify-send "$cmd_output"
            	[ -n "$cmd_output" ] && shpool attach --force "$cmd_output"
            }

            shpool_choose
          '';
      };
    };
  };

  services.shpool = {
    enable = true;
    settings = {
      session_restore_mode = "screen";
      keybinding = [
        {
          binding = "Ctrl-a Ctrl-q";
          action = "detach";
        }
      ];
    };
  };
}
