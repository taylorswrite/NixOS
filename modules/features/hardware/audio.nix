{ self, ... }:
{
  flake.nixosModules.audio = { config, pkgs, ... }: {
    security.rtkit.enable = true;

    # Pipewire Audio Stack
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # User Permissions
    users.users."${config.my.user}".extraGroups = [ "audio" ];

    environment.systemPackages = with pkgs; [
      pulsemixer  # CLI volume control
      pavucontrol # GUI volume control
    ];
  };
}
