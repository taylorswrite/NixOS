{ self, ... }:
{
  flake.nixosModules.wifiImpala = { config, pkgs, lib, ... }: {
    networking.networkmanager.enable = lib.mkForce false;

    networking.wireless.iwd = {
      enable = true;
      settings = {
        IPv6.Enabled = true;
        General.EnableNetworkConfiguration = true;
      };
    };
    services.resolved.enable = true;

    environment.systemPackages = [ pkgs.impala ];
  };

  flake.nixosModules.wifiStandard = { config, pkgs, ... }: {
    networking.networkmanager.enable = true;
    networking.wireless.iwd.enable = false;
  };
}
