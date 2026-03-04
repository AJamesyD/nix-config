{ config, ... }:
{
  home.file.".ssh/config.d/base.conf".text =
    let
      user = config.home.username;
    in
    ''
      # Security-hardened defaults — see Research Findings for rationale
      Host *
        AddKeysToAgent yes
        ChallengeResponseAuthentication no
        IdentitiesOnly yes
        ServerAliveCountMax 5
        ServerAliveInterval 60

      # Persistent socket avoids repeated auth handshakes for git operations
      Host git.amazon.com
        ControlMaster auto
        ControlPath ~/.ssh/control-%C
        ControlPersist 12h
        User ${user}
    '';
}
