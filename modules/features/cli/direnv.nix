{ self, ... }:
{
  flake.nixosModules.direnv = { config, ... }: {
    home-manager.users."${config.my.user}" = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableFishIntegration = true;
        silent = true;
      };
    };
  };
}
