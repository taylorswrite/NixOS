{ inputs, self, ... }:
{
  flake.darwinConfigurations.hidan = inputs.darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [

      (
        { config, pkgs, ... }:
        {
          networking.hostName = "hidan";
          services.nix-daemon.enable = true;
          nix.settings.experimental-features = "nix-command flakes";
          system.stateVersion = 4;
        }
      )
    ];
  };
}
