{ inputs, self, ... }:
{
  flake.nixosModules.thinkpadKmonad = { lib, config, pkgs, ... }:
  let
    cfg = config.my.features.thinkpadKmonad;
  in
  {
    options.my.features.thinkpadKmonad = {
      enable = lib.mkEnableOption "KMonad keyboard remapper";
    };

    config = lib.mkIf cfg.enable {
      # 1. Ensure KMonad is installed
      environment.systemPackages = [ pkgs.kmonad ];

      # 2. Service Configuration
      services.kmonad = {
        enable = true;
        keyboards = {
          "thinkpad-internal" = {
            # The specific device path for the ThinkPad T480 internal keyboard
            device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";

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
                esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  power del
                grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
                tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
                caps a    s    d    f    g    h    j    k    l    ;    '    ret
                lsft z    x    c    v    b    n    m    ,    .    /    rsft
                lctl fn   lmet lalt           spc            ralt menu left up   rght
                                                                        down
              )

              (defalias
                esc_ctl esc
                hm_a (tap-hold 150 a lalt)
                hm_s (tap-hold 150 s lsft)
                hm_d (tap-hold 150 d lmet)
                hm_f (tap-hold 150 f lctl)
                hm_j (tap-hold 150 j rctl)
                hm_k (tap-hold 150 k rmet)
                hm_l (tap-hold 150 l rsft)
                hm_sc (tap-hold 150 ; ralt)
                g_nav (tap-hold 150 g (layer-toggle nav_layer))
                h_nums (tap-hold 150 h (layer-toggle h_num_layer))
              )

              (deflayer main
                esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  power del
                grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
                tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
                @esc_ctl @hm_a @hm_s @hm_d @hm_f @g_nav @h_nums @hm_j @hm_k @hm_l @hm_sc ' ret
                lsft z    x    c    v    b    n    m    ,    .    /    rsft
                lctl fn   lmet lalt      spc      ralt menu left up   rght
                                                                down
              )

              (deflayer nav_layer
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    _    _    _    _    _    =    -    \(    \)    ]    _    _    _
                _    @hm_a @hm_s @hm_d @hm_f @g_nav left down up   rght @hm_k @hm_l @hm_sc
                _    _    _    _    _    caps bspc del  grv  .    /    _
                _    _    _    _          _          _    _    _    _    _
                                                                _
              )

              (deflayer h_num_layer
                _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    _    _    _    _    _    _    _    _    _    _    _    _    _
                _    1    2    3    4    5    _    _    _    _    _    _    _    _
                _    6    7    8    9    0    @h_nums @hm_j @hm_k @hm_l @hm_sc ' _
                _    _    _    _    _    _    _    _    _    _    _    _
                _    _    _    _          _          _    _    _    _    _
                                                                _
              )
            '';
          };
        };
      };
    };
  };
}
