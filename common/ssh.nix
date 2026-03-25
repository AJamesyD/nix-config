_: {
  home.file.".ssh/config.d/base.conf".text = ''
    # Clipboard forwarding for pbcopy/pbpaste over SSH
    Host dev-dsk-* *.amazon.com !git.amazon.com
      RemoteForward 2224 localhost:2224
      RemoteForward 2225 localhost:2225

    # Security-hardened defaults — see Research Findings for rationale
    Host *
      AddKeysToAgent yes
      ChallengeResponseAuthentication no
      IdentitiesOnly yes
      ServerAliveCountMax 5
      ServerAliveInterval 60
      StrictHostKeyChecking accept-new
  '';
}
