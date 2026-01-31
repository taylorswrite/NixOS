{ self, ... }:
{
  flake.nixosModules.printing = { config, pkgs, ... }: {
    services.printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };

    # Auto-Discovery for Network Printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # GUI
    environment.systemPackages = [ pkgs.system-config-printer ];
  };
}
