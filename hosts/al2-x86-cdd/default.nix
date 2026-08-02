{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../common/ai
    ../../common/aws
    ../../common/dev.nix
    ../../common/ssh.nix
    ../../common/nix-common.nix
    ../../common/stylix.nix
    ../../common/zmx
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
    ];
    # nixpkgs-unstable bumped to 26.11 before home-manager updated its version string.
    # Safe: our home-manager input follows our nixpkgs.
    enableNixpkgsReleaseCheck = false;
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
    };
    zsh = {
      enable = true;
      initContent = ''
        spk() {
          local name
          name=$(shpool list | tail -n +2 | cut -f1 | fzf --prompt='kill> ' --no-select-1 --no-exit-0) || return
          shpool kill "$name" 2>/dev/null && session-forget shpool "$name" 2>/dev/null
        }

        spa() {
          local name
          name=$(shpool list | tail -n +2 | cut -f1 | fzf --prompt='attach> ' --no-select-1 --no-exit-0) || return
          _mux_attach "$name" shpool attach --force "$name" 2>/dev/null
        }
      '';
      shellAliases = {
        auth = "mwinit -o";
        up = "sudo yum upgrade -y && nixup";

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
