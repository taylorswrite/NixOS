{ inputs, self, ... }:
{
  flake.nixosModules.kmonadKinesisAdv = { lib, config, pkgs, ... }: {
    environment.systemPackages = [ pkgs.kmonad ];
    services.kmonad = {
      enable = true;
      keyboards = {
        "kinesis-adv" = {
          # Verify this exact path on 'pain' using: ls -l /dev/input/by-id/
          device = "usb-Kinesis_Kinesis_Adv360_360555127546-if01-event-kbd";
          
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
              esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  pause
              =    1    2    3    4    5    6    7    8    9    0    -    \
              tab  q    w    e    r    t    y    u    i    o    p    [    ]
              caps a    s    d    f    g    h    j    k    l    ;    '    ret
              lsft z    x    c    v    b    n    m    ,    .    /    rsft up
              `    ins  left rght                up   down [    ]         down
                        lctl lalt                rmeta rctl
                             spc  bspc           pgdn ent
                             volu vold           pgup
            )

            (deflayer main
              esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  pause
              =    1    2    3    4    5    6    7    8    9    0    -    \
              tab  q    w    e    r    t    y    u    i    o    p    [    ]
              caps a    s    d    f    g    h    j    k    l    ;    '    ret
              lsft z    x    c    v    b    n    m    ,    .    /    rsft up
              `    ins  left rght                up   down [    ]         down
                        lctl lalt                rmeta rctl
                             spc  bspc           pgdn ent
                             volu vold           pgup
            )
          '';
        };
      };
    };
  };
}
