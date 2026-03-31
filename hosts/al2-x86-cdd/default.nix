{
  pkgs,
  ...
}:
{
  imports = [
    ../../common/aws.nix
    ../../common/dev.nix
    ../../common/ssh.nix
    ../../common/nix-common.nix
    ../../common/stylix.nix
  ];

  home = {
    packages = with pkgs; [
      (lib.hiPrio opensshWithKerberos)
      krb5

      ruby

      stylua

      (callPackage ../../pkgs/zmx { })
    ];
    stateVersion = "25.11"; # Please read the comment before changing.
  };

  programs = {
    bob-nvim = {
      enable = true;
    };
    mise = {
      globalConfig = {
        tool_alias = {
          node = "node:ssh://git.amazon.com/pkg/RtxNode";
        };
        tools = {
          node = [
            # NOTE: First one becomes default
            "lts"
            "22"
            "20"
            "18"
          ];
        };
      };
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = [ "config.d/*.conf" ];
      # Defaults (AddKeysToAgent, IdentitiesOnly, StrictHostKeyChecking, etc.)
      # live in config.d/base.conf via common/ssh.nix
      matchBlocks."*" = { };
    };
    zsh = {
      enable = true;
      shellAliases = {
        auth = "mwinit -o";
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
      prompt_prefix = "";
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
