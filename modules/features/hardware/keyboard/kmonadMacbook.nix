{ inputs, self, ... }:
{
  flake.darwinModules.kmonadMacbook = { lib, config, pkgs, ... }: 
  let
    # Pull the kmonad binary directly from the upstream flake
    kmonadPkg = inputs.kmonad.packages.${pkgs.system}.kmonad;

    kmonadConfigText = ''
      (defcfg
        input  (iokit-name "Apple Internal Keyboard / Trackpad")
        output (kext)
        fallthrough true
        allow-cmd true
      )

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
  in {
    environment.systemPackages = [ kmonadPkg ];

    # Create a static path for the config so launchd always finds it
    environment.etc."kmonad/config.kbd".text = kmonadConfigText;

    launchd.daemons.kmonad = {
      serviceConfig = {
        # Using the absolute path in the system profile prevents permission loss on updates
        ProgramArguments = [ 
          "/run/current-system/sw/bin/kmonad" 
          "/etc/kmonad/config.kbd" 
        ];
        RunAtLoad = true;
        KeepAlive = true;
        UserName = "root";
        StandardOutPath = "/var/log/kmonad.out.log";
        StandardErrorPath = "/var/log/kmonad.err.log";
      };
    };
  };
}
