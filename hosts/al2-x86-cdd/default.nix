{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../common/aws
    ../../common/dev.nix
    ../../common/ssh.nix
    ../../common/nix-common.nix
    ../../common/stylix.nix
  ];

  dconf.enable = false;
  stylix.targets.gtk.enable = false;

  gtk.gtk4.theme = null;

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
      initContent = ''
        # zmx has no configurable detach key (hardcoded ctrl+\).
        # Map C-a C-q to `zmx detach` so it matches tmux/zellij/shpool.
        zmx-detach() {
          [[ -n "$ZMX_SESSION" ]] || return
          {
            local d="''${XDG_STATE_HOME:-$HOME/.local/state}/sessions/zmx-scrollback"
            local f="$d/$ZMX_SESSION.txt"
            [[ -d "$d" ]] || mkdir -p "$d"
            timeout 5 zmx history "$ZMX_SESSION" |
              tail -n "''${SESSION_PERSIST_SCROLLBACK_LINES:-10000}" > "$f.tmp" && mv "$f.tmp" "$f"
          } &!
          zmx detach
        }
        zle -N zmx-detach
        bindkey '^A^Q' zmx-detach

        spk() {
          local name
          name=$(shpool list | tail -n +2 | cut -f1 | fzf --prompt='kill> ' --no-select-1 --no-exit-0) || return
          shpool kill "$name" 2>/dev/null && session-forget shpool "$name" 2>/dev/null
        }
      '';
      shellAliases = {
        auth = "mwinit -o";
        up = "sudo yum upgrade -y && nixup";
        spa = # bash
          ''
            shpool attach --force "$(shpool list | tail -n +2 | cut -f1 | fzf --prompt='attach> ' --no-select-1 --no-exit-0)" 2>/dev/null
          '';
        # Borrowed from https://github.com/shell-pool/shpool/issues/49#issue-2355077641
        shll = lib.removeSuffix "\n" (builtins.readFile ./shll.sh);
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

  programs.toolbox.currentPlatform = "alinux";
}
