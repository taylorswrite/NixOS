{ inputs, self, ... }:
{
  flake.darwinConfigurations.hidan = inputs.darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      inputs.home-manager.darwinModules.home-manager

      self.darwinModules.fish
      self.darwinModules.git
      self.darwinModules.nvim
      self.darwinModules.starship
      self.darwinModules.kitty
      self.darwinModules.direnv
      self.darwinModules.aerospace

      (
        { config, lib, pkgs, ... }:
        {
          options.my = {
            user = lib.mkOption {
              type = lib.types.str;
              default = "william";
            };
            githubUser = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = "taylorswrite";
            };
            githubKeyHash = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
          };

          config = {
            system.primaryUser = "william";
            networking.hostName = "hidan";
            nix.settings.experimental-features = "nix-command flakes";
            system.stateVersion = 4;
            ids.gids.nixbld = 350;
            my.user = "william";
            users.users."${config.my.user}" = {
              home = "/Users/${config.my.user}";
            };

            features.git = {
              enable = true;
              userName = "William Martinez";
              userEmail = "wtmartinez@ucla.edu";
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users."${config.my.user}" = {
                home.stateVersion = "25.11"; 
              };
            };
          };
        }
      )
    ];
  };
}
