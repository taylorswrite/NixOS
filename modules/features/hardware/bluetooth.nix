{ self, ... }:
{
  flake.nixosModules.bluetooth = { config, pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true; 
        };
      };
    };

    # GUI
    # services.blueman.enable = true;

    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
      bluetui
    ];
  };
}
