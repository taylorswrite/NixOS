{ ... }:
let
  sharedModule = { config, ... }: {
    home-manager.users."${config.my.user}" = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableFishIntegration = true;
        silent = true;
      };
    };
  };
in
{
  flake.nixosModules.direnv = sharedModule;
  flake.darwinModules.direnv = sharedModule;
}
