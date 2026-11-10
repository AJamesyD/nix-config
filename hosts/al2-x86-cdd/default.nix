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
    ../../common/stylix
    ../../common/zmx
  ];

  dconf.enable = false;

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

  # NOTE: services.rex implies programs.rex, which installs the xterm-rex
  #   terminfo entry for the Mac client's TERM. The server should bind only the
  #   local rex.socket (ssh is the access boundary); do not add extraListen or
  #   tailscale. Verify no non-loopback listener after deploy. Run
  #   `loginctl enable-linger` once so it survives logout.
  services.rex.enable = true;
  # NOTE: AL2's OpenSSH 7.4 is below the 7.8 Rex's ssh guard needs, and this
  #   host is not a Rex client.
  programs.rex.sshGuard = false;

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
