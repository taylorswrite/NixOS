{ inputs, self, ... }:
{
  flake.darwinConfigurations.hidan = inputs.darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      inputs.home-manager.darwinModules.home-manager
      inputs.nix-homebrew.darwinModules.nix-homebrew

      # Must be darwinModules not nixosModules.
      self.darwinModules.fish
      self.darwinModules.git
      self.darwinModules.nvim
      self.darwinModules.starship
      self.darwinModules.kitty
      self.darwinModules.direnv
      self.darwinModules.aerospace
      self.darwinModules.dev
      self.darwinModules.tmux
      self.darwinModules.kmonadMacbook

      (
        { config, lib, pkgs, ... }:
        {
          # User and Github configuration variables
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
            my.user = "william";
            system.primaryUser = "${config.my.user}";
            networking.hostName = "hidan";
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = "nix-command flakes";
            system.stateVersion = 4;
            ids.gids.nixbld = 350;
            users.users."${config.my.user}" = {
              home = "/Users/${config.my.user}";
            };
            nix-homebrew = {
              enable = true;
              user = "${config.my.user}";
              autoMigrate = true;
            };
            homebrew = {
              enable = true;
              onActivation.cleanup = "zap";
              taps = [];
              brews = [];
              casks = [
                "mullvad-vpn"
                "betterdisplay"
                "amethyst"
                "karabiner-elements"
              ];
            };

            system.activationScripts.postActivation.text = ''
              # Force macOS Directory Services to use the Nix-managed shell
              dscl . -create /Users/${config.my.user} UserShell /run/current-system/sw/bin/fish
            '';
            # Setting Github configuration variables.
            features.git = {
              enable = true;
              userName = "William Martinez";
              userEmail = "wtmartinez@ucla.edu";
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # Backup conflicting configurations instead of overwriting
              backupFileExtension = "backup";
              users."${config.my.user}" = {
                programs.fish.shellAliases = {
                  nixup = "sudo darwin-rebuild switch --flake ~/.nix/#${config.networking.hostName}";
                };
                home.stateVersion = "25.11"; 
              };
            };
            
          };
        }
      )
    ];
  };
}
