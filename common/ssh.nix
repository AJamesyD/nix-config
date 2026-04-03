# WSSH manages ~/.ssh/config (ProxyCommand entries for off-VPN access).
# Do not use programs.ssh: it takes over ~/.ssh/config and breaks WSSH.
_: {
  home.file.".ssh/config.d/base.conf".text = ''
    # Clipboard forwarding for pbcopy/pbpaste over SSH
    Host dev-dsk-* *.amazon.com !git.amazon.com
      RemoteForward 2224 localhost:2224
      RemoteForward 2225 localhost:2225

    Host *
      AddKeysToAgent yes
      KbdInteractiveAuthentication no
      IdentitiesOnly yes
      ServerAliveCountMax 5
      ServerAliveInterval 60
      StrictHostKeyChecking accept-new
  '';
}
