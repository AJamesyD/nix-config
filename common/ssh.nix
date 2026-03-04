_: {
  home.file.".ssh/config.d/base.conf".text = ''
    # Security-hardened defaults — see Research Findings for rationale
    Host *
      AddKeysToAgent yes
      ChallengeResponseAuthentication no
      IdentitiesOnly yes
      ServerAliveCountMax 5
      ServerAliveInterval 60
  '';
}
