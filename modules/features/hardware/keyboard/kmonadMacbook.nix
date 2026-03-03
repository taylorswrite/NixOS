{ ... }:
{
  flake.darwinModules.kmonadMacbook = { lib, config, pkgs, ... }: {
    environment.systemPackages = [ pkgs.kmonad ];

    # 2. Service Configuration
    services.kmonad = {
      enable = true;
      keyboards = {
        "macbook-internal" = {
          # KMonad on macOS uses IOKit for device grabbing. 
          # "Apple Internal Keyboard / Trackpad" is the standard identifier for MacBooks.
          device = "Apple Internal Keyboard / Trackpad";
          
          defcfg = {
            enable = true;
            fallthrough = true;
            allowCommands = true;
            compose = {
              key = "ralt";
              delay = 5;
            };
          };

          config = ''
            (defsrc
              esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
              grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
              tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
              caps a    s    d    f    g    h    j    k    l    ;    '    ret
              lsft z    x    c    v    b    n    m    ,    .    /    rsft up
              fn   lctl lalt lmet           spc            rmet ralt left down rght
            )

            (defalias
              esc_ctl esc
              hm_a (tap-hold-next-release 150 a lalt)
              hm_s (tap-hold-next-release 150 s lsft)
              hm_d (tap-hold-next-release 150 d lmet)
              hm_f (tap-hold-next-release 150 f lctl)
              hm_j (tap-hold-next-release 150 j rctl)
              hm_k (tap-hold-next-release 150 k rmet)
              hm_l (tap-hold-next-release 150 l rsft)
              hm_sc (tap-hold-next-release 150 ; ralt)
              g_nav (tap-hold-next-release 150 g (layer-toggle nav_layer))
              h_nums (tap-hold-next-release 150 h (layer-toggle h_num_layer))
            )

            (deflayer main
              esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
              grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
              tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
              @esc_ctl @hm_a @hm_s @hm_d @hm_f @g_nav @h_nums @hm_j @hm_k @hm_l @hm_sc ' ret
              lsft z    x    c    v    b    n    m    ,    .    /    rsft up
              fn   lctl lalt lmet           spc            rmet ralt left down rght
            )

            (deflayer nav_layer
              _    _    _    _    _    _    _    _    _    _    _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _    _    _
              _    _    _    _    _    _    =    -    \(   \)   ]    _    _    _
              _    @hm_a @hm_s @hm_d @hm_f @g_nav left down up   rght @hm_k @hm_l @hm_sc
              _    _    _    _    _    caps -    -    grv  .    /    _    _
              _    _    _    _              _              _    _    _    _    _
            )

            (deflayer h_num_layer
              _    _    _    _    _    _    _    _    _    _    _    _    _
              _    _    _    _    _    _    _    _    _    _    _    _    _    _
              _    1    2    3    4    5    _    _    _    _    _    _    _    _
              _    6    7    8    9    0    @h_nums @hm_j @hm_k @hm_l @hm_sc ' _
              _    _    _    \    [    ]    _    _    _    _    _    _    _
              _    _    _    _              _              _    _    _    _    _
            )
          '';
        };
      };
    };
  };
}
