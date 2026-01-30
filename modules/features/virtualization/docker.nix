{ self, ... }:
{
  flake.nixosModules.docker = { config, pkgs, ... }: {
    virtualisation.docker = {
      enable = true;
      # Optional: Enable auto-prune to save space
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    # Automatically add your user to the docker group
    users.users."${config.my.user}".extraGroups = [ "docker" ];
  };
}
