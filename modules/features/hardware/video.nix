{ self, ... }:
{
  flake.nixosModules.video = { config, pkgs, ... }: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # User Permissions for Webcam and Backlight control)
    users.users."${config.my.user}".extraGroups = [ "video" ];

    environment.systemPackages = with pkgs; [
      # vlc
      # mpv
    ];
  };
}
