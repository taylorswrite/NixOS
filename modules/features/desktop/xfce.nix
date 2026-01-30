{ self, ... }:
{
  flake.nixosModules.xfce = { config, lib, pkgs, ... }: {

    services.xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    environment.systemPackages = with pkgs; [
      xfce4-whiskermenu-plugin
      xfce4-terminal
    ];
  };
}
