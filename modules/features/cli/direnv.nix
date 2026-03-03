{ ... }:
let
  sharedModule = { config, ... }: {
    home-manager.users."${config.my.user}" = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableFishIntegration = true;
        # Consider setting silent to false temporarily to debug if it's loading
        silent = false; 
      };

      # Manually force the hook if the integration is being stubborn
      programs.fish.interactiveShellInit = ''
        direnv hook fish | source
      '';
    };
  };
in
{
  flake.nixosModules.direnv = sharedModule;
  flake.darwinModules.direnv = sharedModule;
}
