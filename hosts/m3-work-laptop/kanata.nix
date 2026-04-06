{ pkgs, ... }:
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
      a (tap-hold-opposite-hand 250 a lctl (require-prior-idle 150) (unknown-hand hold))
      s (tap-hold-opposite-hand 250 s lalt (require-prior-idle 150) (unknown-hand hold))
      d (tap-hold-opposite-hand 200 d lmet (require-prior-idle 150) (unknown-hand hold))
      f (tap-hold-opposite-hand 200 f lsft (require-prior-idle 150) (unknown-hand hold))

      ;; Right hand: mirrored CAGS
      j (tap-hold-opposite-hand 200 j rsft (require-prior-idle 150) (unknown-hand hold))
      k (tap-hold-opposite-hand 200 k rmet (require-prior-idle 150) (unknown-hand hold))
      l (tap-hold-opposite-hand 250 l ralt (require-prior-idle 150) (unknown-hand hold))
      ; (tap-hold-opposite-hand 250 ; rctl (require-prior-idle 150) (unknown-hand hold))
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
    configSource = kbdConfig;
  };
}
