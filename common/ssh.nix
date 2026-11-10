# WSSH manages ~/.ssh/config (ProxyCommand entries for off-VPN access).
# Do not use programs.ssh: it takes over ~/.ssh/config and breaks WSSH.
_: {
  home.file.".ssh/config.d/base.conf".text = ''
    # NOTE: Rex's TERM fallback, written by `rex terminfo setup`. Rex also
    #   Includes it from ~/.ssh/config, but WSSH owns that file and may drop
    #   the line, so include it here too. ssh ignores a missing file.
    Include ~/.config/rex/ssh_config

    # Clipboard forwarding for pbcopy/pbpaste over SSH
    Host dev-dsk-* *.amazon.com !git.amazon.com
      RemoteForward 2224 localhost:2224
      RemoteForward 2225 localhost:2225
      ControlMaster auto
      ControlPath ~/.ssh/control-%C
      ControlPersist 12h

    Host *
      AddKeysToAgent yes
      KbdInteractiveAuthentication no
      IdentitiesOnly yes
      ServerAliveCountMax 5
      ServerAliveInterval 60
      StrictHostKeyChecking accept-new
  '';
}
