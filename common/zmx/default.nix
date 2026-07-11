{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ../../pkgs/zmx { })
  ];

  programs.zsh.initContent = ''
    # zmx's built-in detach (ctrl+\) is hardcoded; remap to C-a C-q for
    # consistency with tmux/zellij/shpool. Unreachable inside tmux (C-a is
    # intercepted as prefix), but zmx sessions don't nest inside tmux.
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
  '';
}
