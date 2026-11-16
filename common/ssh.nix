# NOTE: On the Mac, WSSH owns ~/.ssh/config and Includes config.d/*.conf before its
#   block, so options here win and forwards add up. Keep WSSH's block stock; put
#   every override in nix.
# WARN: Don't use programs.ssh: it takes over ~/.ssh/config and breaks WSSH.
# WARN: Forwards and ControlMaster go only on interactive aliases (aws/default.nix).
#   Tools ssh by FQDN and inherit anything set on a hostname pattern.
_: {
  home.file.".ssh/config.d/base.conf".text = ''
    # NOTE: Rex's TERM fallback, written by `rex terminfo setup`. Rex also
    #   Includes it from ~/.ssh/config, but WSSH owns that file and may drop
    #   the line, so include it here too. ssh ignores a missing file.
    Include ~/.config/rex/ssh_config

    Host *
      AddKeysToAgent yes
      KbdInteractiveAuthentication no
      IdentitiesOnly yes
      ServerAliveCountMax 5
      ServerAliveInterval 60
      StrictHostKeyChecking accept-new
  '';
}
