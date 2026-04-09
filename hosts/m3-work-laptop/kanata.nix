{
  pkgs,
  ...
}:
let
  kbdConfig = pkgs.writeText "kanata.kbd" ''
    (defcfg
      process-unmapped-keys yes
      tap-hold-require-prior-idle 150
      macos-dev-names-include (
        "Apple Internal Keyboard / Trackpad"
      )
    )

    (defalias
      ;; Left hand: CAGS (ctrl, alt, gui, shift)
      a (tap-hold-release 200 200 a lctl)
      s (tap-hold-release 200 200 s lalt)
      d (tap-hold-release 200 200 d lmet)
      f (tap-hold-release 200 200 f lsft)

      ;; Right hand: SGAC (shift, gui, alt, ctrl)
      j (tap-hold-release 200 200 j rsft)
      k (tap-hold-release 200 200 k rmet)
      l (tap-hold-release 200 200 l ralt)
      ; (tap-hold-release 200 200 ; rctl)
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
