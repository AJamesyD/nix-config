{
  pkgs,
  ...
}:
let
  kbdConfig = pkgs.writeText "kanata.kbd" ''
    (defcfg
      process-unmapped-keys yes
      macos-dev-names-include (
        "Apple Internal Keyboard / Trackpad"
      )
    )

    (defhands
      (left q w e r t a s d f g z x c v b)
      (right y u i o p h j k l ; n m , . /)
    )

    (defalias
      ;; Left hand: CAGS
      a (tap-hold-opposite-hand-release 250 a lctl
        (same-hand tap) (timeout hold) (unknown-hand hold))
      s (tap-hold-opposite-hand-release 250 s lalt
        (same-hand tap) (timeout hold) (unknown-hand hold))
      d (tap-hold-opposite-hand-release 200 d lmet
        (same-hand tap) (timeout hold) (unknown-hand hold))
      f (tap-hold-opposite-hand-release 200 f lsft
        (same-hand tap) (timeout hold) (unknown-hand hold))

      ;; Right hand: mirrored CAGS
      j (tap-hold-opposite-hand-release 200 j rsft
        (same-hand tap) (timeout hold) (unknown-hand hold))
      k (tap-hold-opposite-hand-release 200 k rmet
        (same-hand tap) (timeout hold) (unknown-hand hold))
      l (tap-hold-opposite-hand-release 250 l ralt
        (same-hand tap) (timeout hold) (unknown-hand hold))
      ; (tap-hold-opposite-hand-release 250 ; rctl
        (same-hand tap) (timeout hold) (unknown-hand hold))
    )

    (defsrc
      f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      caps a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft
      fn   lctl lalt lmet           spc            rmet ralt
    )

    (deflayer default
      brdn brup mctl sls  dtn  dnd  prev pp   next mute vold volu
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      caps @a   @s   @d   @f   g    h    @j   @k   @l   @;   '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft
      fn   lctl lalt lmet           spc            rmet ralt
    )
  '';
in
{
  services.kanata = {
    enable = true;
    kanata-bar.enable = true;
    kanata-bar.settings.kanata_bar.autostart_kanata = true;
    configSource = kbdConfig;
  };
}
