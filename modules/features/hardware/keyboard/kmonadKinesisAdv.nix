{ inputs, self, ... }:
{
  flake.nixosModules.kmonadKinesisAdv = { lib, config, pkgs, ... }: {
    environment.systemPackages = [ pkgs.kmonad ];
    services.kmonad = {
      enable = true;
      keyboards = {
        "kinesis-adv" = {
          device = "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-if01-event-kbd";
          
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
              =    1    2    3    4    5    6    7    8    9    0    -
              tab  q    w    e    r    t    y    u    i    o    p    bksl
              esc  a    s    d    f    g    h    j    k    l    ;    '
              lsft z    x    c    v    b    n    m    ,    .    /    rsft
              `    ins  left rght                up   down [    ]
                             lctl lalt                rmeta rctl
                                  bspc del            ret  spc
                                  home end            pgup pgdn
            )

            (defalias
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
              =    1    2    3    4    5    6    7    8    9    0    -
              tab  q    w    e    r    t    y    u    i    o    p    bksl
              esc @hm_a @hm_s @hm_d @hm_f @g_nav @h_nums @hm_j @hm_k @hm_l @hm_sc '
              lsft z    x    c    v    b    n    m    ,    .    /    esc
              `    caps left rght                up   down [    ]
                             lctl lalt                rmeta rctl
                                  bspc del            ret  spc
                                  home end            pgup pgdn
            )

            (deflayer nav_layer
              _    _    _    _    _    _    _    _    _    _    _    _
              _    _    _    _    _    _    =    -    lprn rprn [    ]
              _    @hm_a @hm_s @hm_d @hm_f @g_nav left down up   rght _    _
              _    _    _    _    _    _    caps caps grv  .    /    _
              _    _    _    _                    _    _    _    _
                        _    _                    _    _
                             _    _               _    _
                             _    _               _    _
            )

            (deflayer h_num_layer
              _    _    _    _    _    _    _    _    _    _    _    _
              _    1    2    3    4    5    _    _    _    _    _    _
              _    6    7    8    9    0    @h_nums @hm_j @hm_k @hm_l @hm_sc _
              _    _    _    bksl [    ]    _    _    _    _    _    _
              _    _    _    _                    _    _    _    _
                        _    _                    _    _
                             _    _               _    _
                             _    _               _    _
            )
          '';
        };
      };
    };
  };
}
